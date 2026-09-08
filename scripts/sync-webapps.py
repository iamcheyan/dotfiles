#!/usr/bin/env python3
"""
sync-webapps: Cross-platform WebApp synchronization hub.
Connects Safari Web Apps (macOS) and Firefox Web Apps / Desktop Entries (Linux).

Data storage layout:
  ~/.local/share/webapps/
    ├── webapps.json    (Unified WebApp database)
    └── icons/          (Extracted and synced PNG icons)
"""

import argparse
import hashlib
import json
import os
import plistlib
import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

HOME = Path.home()
DEFAULT_DATA_DIR = HOME / ".local" / "share" / "webapps"
CHEZMOI_DATA_DIR = HOME / "chezmoi" / "dot_local" / "share" / "webapps"

def get_data_dir() -> Path:
    """Resolve active data storage directory."""
    if DEFAULT_DATA_DIR.exists() or not CHEZMOI_DATA_DIR.exists():
        DEFAULT_DATA_DIR.mkdir(parents=True, exist_ok=True)
        (DEFAULT_DATA_DIR / "icons").mkdir(parents=True, exist_ok=True)
        return DEFAULT_DATA_DIR
    return CHEZMOI_DATA_DIR

def slugify(text: str) -> str:
    """Generate a clean identifier from text."""
    slug = re.sub(r'[^\w\s-]', '', text.lower().strip())
    slug = re.sub(r'[-\s]+', '-', slug)
    if not slug:
        slug = hashlib.md5(text.encode('utf-8')).hexdigest()[:8]
    return slug

def load_manifest(data_dir: Path) -> dict:
    """Load webapps.json manifest."""
    manifest_file = data_dir / "webapps.json"
    if manifest_file.exists():
        try:
            with open(manifest_file, "r", encoding="utf-8") as f:
                data = json.load(f)
                if isinstance(data, list):
                    return {item["id"]: item for item in data if "id" in item}
                elif isinstance(data, dict):
                    return data
        except Exception as e:
            print(f"Warning: Failed to load {manifest_file}: {e}", file=sys.stderr)
    return {}

def save_manifest(data_dir: Path, manifest: dict):
    """Save webapps.json manifest."""
    manifest_file = data_dir / "webapps.json"
    manifest_file.parent.mkdir(parents=True, exist_ok=True)
    sorted_items = sorted(manifest.values(), key=lambda x: x.get("name", "").lower())
    with open(manifest_file, "w", encoding="utf-8") as f:
        json.dump(sorted_items, f, ensure_ascii=False, indent=2)

# ==========================================
# macOS (Safari Web Apps) Handlers
# ==========================================

def scan_macos_safari_apps(data_dir: Path, manifest: dict) -> int:
    """Scan ~/Applications for Safari Web Apps and update manifest."""
    apps_dir = HOME / "Applications"
    icons_dir = data_dir / "icons"
    icons_dir.mkdir(parents=True, exist_ok=True)
    found_count = 0

    if not apps_dir.exists():
        return 0

    for app in sorted(apps_dir.glob("*.app")):
        plist_path = app / "Contents" / "Info.plist"
        if not plist_path.exists():
            continue
        try:
            with open(plist_path, "rb") as f:
                pl = plistlib.load(f)

            bundle_id = pl.get("CFBundleIdentifier", "")
            template_params = pl.get("LSTemplateApplicationParameters", {})
            is_safari_webapp = (
                "com.apple.Safari.WebApp" in bundle_id or
                template_params.get("CFBundleIdentifier") == "com.apple.Safari.WebApp"
            )
            if not is_safari_webapp:
                continue

            name = pl.get("CFBundleName") or app.stem
            manifest_block = pl.get("Manifest", {})
            url = manifest_block.get("start_url") or pl.get("WKManifestURL")
            if not url:
                continue

            app_id = slugify(name)
            icon_filename = f"{app_id}.png"
            icon_dest = icons_dir / icon_filename

            # Extract icon from ICNS if not yet extracted
            icns_path = app / "Contents" / "Resources" / "ApplicationIcon.icns"
            if icns_path.exists() and not icon_dest.exists():
                try:
                    subprocess.run(
                        ["sips", "-s", "format", "png", str(icns_path), "--out", str(icon_dest)],
                        check=True,
                        stdout=subprocess.DEVNULL,
                        stderr=subprocess.DEVNULL
                    )
                except Exception:
                    pass

            manifest[app_id] = {
                "id": app_id,
                "name": name,
                "url": url,
                "icon": icon_filename if icon_dest.exists() else None,
                "theme_color": manifest_block.get("theme_color"),
                "background_color": manifest_block.get("background_color")
            }
            found_count += 1
        except Exception as e:
            print(f"Error inspecting {app}: {e}", file=sys.stderr)

    return found_count

def generate_macos_safari_app(app_info: dict, data_dir: Path):
    """Generate a Safari Web App bundle on macOS from manifest info."""
    import uuid
    name = app_info["name"]
    url = app_info["url"]
    app_id = app_info["id"]
    app_dir = HOME / "Applications" / f"{name}.app"

    if app_dir.exists():
        return

    contents_dir = app_dir / "Contents"
    resources_dir = contents_dir / "Resources"
    resources_dir.mkdir(parents=True, exist_ok=True)

    template_uuid = str(uuid.uuid4()).upper()
    bundle_id = f"com.apple.Safari.WebApp.{template_uuid}"

    plist_data = {
        "CFBundleIconFile": "ApplicationIcon",
        "CFBundleIdentifier": bundle_id,
        "CFBundleInfoDictionaryVersion": "6.0",
        "CFBundleName": name,
        "CFBundlePackageType": "AAPL",
        "CFBundleShortVersionString": "1.0",
        "CFBundleSupportedPlatforms": ["MacOSX"],
        "CFBundleURLTypes": [
            {
                "CFBundleURLSchemes": ["x-webkit-app-launch"],
                "LSHandlerRank": "None"
            }
        ],
        "CFBundleVersion": "1",
        "LSMinimumSystemVersion": "14.0",
        "LSTemplateApplication": True,
        "LSTemplateApplicationParameters": {
            "CFBundleIdentifier": "com.apple.Safari.WebApp",
            "TemplateAppUUID": template_uuid,
            "defaultarguments": True,
            "teamIdentifier": "0000000000"
        },
        "Manifest": {
            "name": name,
            "short_name": name,
            "start_url": url,
            "display": "standalone"
        },
        "WKManifestURL": url
    }

    if app_info.get("theme_color"):
        plist_data["Manifest"]["theme_color"] = app_info["theme_color"]
    if app_info.get("background_color"):
        plist_data["Manifest"]["background_color"] = app_info["background_color"]

    with open(contents_dir / "Info.plist", "wb") as f:
        plistlib.dump(plist_data, f)

    # Generate ICNS icon from PNG
    icon_filename = app_info.get("icon")
    if icon_filename:
        png_path = data_dir / "icons" / icon_filename
        if png_path.exists():
            icns_target = resources_dir / "ApplicationIcon.icns"
            _png_to_icns(png_path, icns_target)

    # Ad-hoc code sign and register
    try:
        subprocess.run(["codesign", "--force", "--deep", "--sign", "-", str(app_dir)],
                       stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        subprocess.run(["touch", str(app_dir)])
    except Exception:
        pass

def _png_to_icns(png_path: Path, icns_target: Path):
    """Convert a PNG file to a macOS .icns file using sips and iconutil."""
    with tempfile.TemporaryDirectory() as tmp_dir:
        iconset = Path(tmp_dir) / "app.iconset"
        iconset.mkdir()

        sizes = [16, 32, 64, 128, 256, 512]
        for size in sizes:
            subprocess.run([
                "sips", "-z", str(size), str(size), str(png_path),
                "--out", str(iconset / f"icon_{size}x{size}.png")
            ], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            subprocess.run([
                "sips", "-z", str(size * 2), str(size * 2), str(png_path),
                "--out", str(iconset / f"icon_{size}x{size}@2x.png")
            ], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

        subprocess.run([
            "iconutil", "-c", "icns", str(iconset), "-o", str(icns_target)
        ], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

# ==========================================
# Linux (Firefox / Desktop Entry) Handlers
# ==========================================

def generate_linux_desktop_entries(manifest: dict, data_dir: Path):
    """Generate Linux .desktop entries and copy icons for all webapps."""
    desktop_dir = HOME / ".local" / "share" / "applications"
    icons_base = HOME / ".local" / "share" / "icons" / "hicolor" / "512x512" / "apps"
    desktop_dir.mkdir(parents=True, exist_ok=True)
    icons_base.mkdir(parents=True, exist_ok=True)

    for app_id, app in manifest.items():
        name = app["name"]
        url = app["url"]
        icon_file = app.get("icon")

        icon_path_str = "web-browser"
        if icon_file:
            src_icon = data_dir / "icons" / icon_file
            if src_icon.exists():
                dest_icon = icons_base / f"webapp-{app_id}.png"
                shutil.copyfile(src_icon, dest_icon)
                icon_path_str = str(dest_icon)

        desktop_file = desktop_dir / f"webapp-{app_id}.desktop"
        desktop_content = f"""[Desktop Entry]
Version=1.0
Type=Application
Name={name}
Comment=Web App ({name})
Exec=firefox --new-window "{url}"
Icon={icon_path_str}
Terminal=false
StartupWMClass=webapp-{app_id}
Categories=Network;WebBrowser;
"""
        with open(desktop_file, "w", encoding="utf-8") as f:
            f.write(desktop_content)

    if shutil.which("update-desktop-database"):
        try:
            subprocess.run(["update-desktop-database", str(desktop_dir)],
                           stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        except Exception:
            pass

# ==========================================
# CLI Actions
# ==========================================

def action_sync(args):
    data_dir = get_data_dir()
    manifest = load_manifest(data_dir)
    print(f"📁 WebApps 数据存储目录: {data_dir}")

    if sys.platform == "darwin":
        found = scan_macos_safari_apps(data_dir, manifest)
        print(f"🍎 [macOS] 扫描到 {found} 个本地 Safari Web App")
        for app_id, app in manifest.items():
            generate_macos_safari_app(app, data_dir)
    elif sys.platform.startswith("linux"):
        print(f"🐧 [Linux] 为 {len(manifest)} 个 WebApp 生成桌面启动项 (.desktop)...")
        generate_linux_desktop_entries(manifest, data_dir)

    save_manifest(data_dir, manifest)
    print(f"✅ 同步完成！当前清单共收录 {len(manifest)} 个 WebApp")

def action_list(args):
    data_dir = get_data_dir()
    manifest = load_manifest(data_dir)
    print(f"📋 已同步的 WebApp 清单 ({len(manifest)} 个):")
    for app_id, item in sorted(manifest.items(), key=lambda x: x[1].get("name", "").lower()):
        icon_status = "🖼️ " if item.get("icon") else "  "
        print(f"{icon_status} {item['name']:<25} {item['url']}")

def action_add(args):
    data_dir = get_data_dir()
    manifest = load_manifest(data_dir)

    app_id = slugify(args.name)
    icon_filename = None

    if args.icon and os.path.exists(args.icon):
        icons_dir = data_dir / "icons"
        icons_dir.mkdir(parents=True, exist_ok=True)
        icon_filename = f"{app_id}.png"
        shutil.copyfile(args.icon, icons_dir / icon_filename)

    manifest[app_id] = {
        "id": app_id,
        "name": args.name,
        "url": args.url,
        "icon": icon_filename
    }

    save_manifest(data_dir, manifest)
    print(f"➕ 已添加 WebApp: {args.name} ({args.url})")
    action_sync(args)

def main():
    parser = argparse.ArgumentParser(description="跨平台 Safari <-> Firefox WebApps 同步中转工具")
    subparsers = parser.add_subparsers(dest="command")

    parser_sync = subparsers.add_parser("sync", help="同步当前系统的 WebApps (默认)")
    parser_list = subparsers.add_parser("list", help="查看所有收录的 WebApps 清单")
    parser_add = subparsers.add_parser("add", help="手动添加新的 WebApp")
    parser_add.add_argument("name", help="WebApp 名称")
    parser_add.add_argument("url", help="起始 URL")
    parser_add.add_argument("--icon", help="PNG 图标路径", default=None)

    args = parser.parse_args()
    if not args.command or args.command == "sync":
        action_sync(args)
    elif args.command == "list":
        action_list(args)
    elif args.command == "add":
        action_add(args)

if __name__ == "__main__":
    main()
