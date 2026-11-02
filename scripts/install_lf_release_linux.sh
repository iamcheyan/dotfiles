install_lf_release_linux() {
    command_exists lf && return 0
    command_exists curl && command_exists python3 && command_exists tar || {
        print_warning "Installing lf from its release requires curl, python3, and tar"
        return 1
    }

    local arch asset_suffix release_json asset_url expected_sha actual_sha temp_dir
    case "$(uname -m)" in
        x86_64|amd64) arch="amd64" ;;
        aarch64|arm64) arch="arm64" ;;
        *)
            print_warning "No lf release binary is available for Linux $(uname -m)"
            return 1
            ;;
    esac
    asset_suffix="lf-linux-${arch}.tar.gz"
    release_json="$(curl -fsSL https://api.github.com/repos/gokcehan/lf/releases/latest)" || return 1
    asset_url="$(printf '%s' "$release_json" | python3 -c 'import json,sys; d=json.load(sys.stdin); print(next((a["browser_download_url"] for a in d.get("assets",[]) if a["name"] == sys.argv[1]), ""))' "$asset_suffix")"
    expected_sha="$(printf '%s' "$release_json" | python3 -c 'import json,sys; d=json.load(sys.stdin); a=next((a for a in d.get("assets",[]) if a["name"] == sys.argv[1]), {}); print((a.get("digest") or "").removeprefix("sha256:"))' "$asset_suffix")"
    if [[ -z "$asset_url" || ! "$expected_sha" =~ ^[[:xdigit:]]{64}$ ]]; then
        print_warning "Could not find a checksummed lf release for Linux $arch"
        return 1
    fi

    temp_dir="$(mktemp -d)"
    if ! curl -fsSL "$asset_url" -o "$temp_dir/lf.tar.gz"; then
        rm -rf "$temp_dir"
        return 1
    fi
    actual_sha="$(sha256sum "$temp_dir/lf.tar.gz" | awk '{print $1}')"
    if [[ "$actual_sha" != "$expected_sha" ]]; then
        rm -rf "$temp_dir"
        print_error "lf release SHA-256 verification failed"
        return 1
    fi
    if ! tar -xzf "$temp_dir/lf.tar.gz" -C "$temp_dir" lf; then
        rm -rf "$temp_dir"
        print_warning "The lf release archive did not contain the expected binary"
        return 1
    fi
    local install_dir="$HOME/.local/bin"
    mkdir -p "$install_dir"
    install -m 755 "$temp_dir/lf" "$install_dir/lf"
    rm -rf "$temp_dir"
    print_success "Installed lf release to $install_dir/lf"
}
