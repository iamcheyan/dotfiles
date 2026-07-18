#!/usr/bin/env python3
import socket, struct, sys, json

def grpc_web_call(host, http_port, path, proto_body=b''):
    frame = b'\x00' + struct.pack('>I', len(proto_body)) + proto_body
    req = (
        f"POST {path} HTTP/1.1\r\n"
        f"Host: localhost:{http_port}\r\n"
        f"Content-Type: application/grpc-web+proto\r\n"
        f"Content-Length: {len(frame)}\r\n"
        f"X-Grpc-Web: 1\r\n"
        f"Connection: close\r\n"
        f"\r\n"
    ).encode() + frame
    s = socket.create_connection((host, http_port), timeout=5)
    s.sendall(req)
    data = b''
    while True:
        chunk = s.recv(16384)
        if not chunk: break
        data += chunk
    s.close()
    
    idx = data.find(b'\r\n\r\n')
    body_raw = data[idx+4:] if idx >= 0 else data
    result = b''
    i = 0
    while i < len(body_raw):
        nl = body_raw.find(b'\r\n', i)
        if nl == -1: break
        size_str = body_raw[i:nl].decode('ascii', errors='ignore').strip()
        if not size_str:
            i = nl + 2
            continue
        try:
            chunk_size = int(size_str, 16)
        except:
            break
        if chunk_size == 0:
            break
        result += body_raw[nl+2:nl+2+chunk_size]
        i = nl + 2 + chunk_size + 2
    return result[5:] if len(result) >= 5 else result

def read_varint(data, pos):
    result = 0
    shift = 0
    while pos < len(data):
        b = data[pos]
        pos += 1
        result |= (b & 0x7F) << shift
        if not (b & 0x80):
            return result, pos
        shift += 7
    return result, pos

def parse_proto(data):
    pos = 0
    fields = {}
    while pos < len(data):
        try:
            tag, pos = read_varint(data, pos)
        except:
            break
        wire = tag & 0x7
        field = tag >> 3
        if wire == 0:
            val, pos = read_varint(data, pos)
            fields.setdefault(field, []).append(('varint', val))
        elif wire == 1:
            if pos + 8 > len(data): break
            val = struct.unpack_from('<d', data, pos)[0]
            pos += 8
            fields.setdefault(field, []).append(('float64', val))
        elif wire == 2:
            length, pos = read_varint(data, pos)
            if pos + length > len(data): break
            val = data[pos:pos+length]
            pos += length
            fields.setdefault(field, []).append(('bytes', val))
        elif wire == 5:
            if pos + 4 > len(data): break
            val = struct.unpack_from('<f', data, pos)[0]
            pos += 4
            fields.setdefault(field, []).append(('float32', val))
        else:
            break
    return fields

def main():
    if len(sys.argv) < 2:
        print(json.dumps({"ok": False, "error": "Missing HTTP port argument"}))
        sys.exit(1)
        
    http_port = int(sys.argv[1])
    host = "127.0.0.1"
    
    try:
        raw_proto = grpc_web_call(host, http_port, "/exa.language_server_pb.LanguageServerService/RetrieveUserQuotaSummary")
        parsed_outer = parse_proto(raw_proto)
        
        # Outer msg wraps inner msg at Field 1
        inner_bytes = parsed_outer.get(1, [('bytes', b'')])[0][1]
        parsed = parse_proto(inner_bytes)
        
        groups = []
        # Groups are in Field 2 of inner msg
        for g_bytes_entry in parsed.get(2, []):
            g_bytes = g_bytes_entry[1]
            g_fields = parse_proto(g_bytes)
            
            limits = []
            # Limits are in Field 1 of Group msg
            for l_bytes_entry in g_fields.get(1, []):
                l_bytes = l_bytes_entry[1]
                l_fields = parse_proto(l_bytes)
                
                l_id = l_fields.get(1, [('bytes', b'')])[0][1].decode('utf-8', errors='ignore')
                l_name = l_fields.get(2, [('bytes', b'')])[0][1].decode('utf-8', errors='ignore')
                l_type = l_fields.get(3, [('bytes', b'')])[0][1].decode('utf-8', errors='ignore')
                l_frac = l_fields.get(4, [('float32', 1.0)])[0][1]
                
                # ResetTime is submessage Field 6
                reset_secs = 0
                r_bytes_list = l_fields.get(6, [])
                if r_bytes_list:
                    r_fields = parse_proto(r_bytes_list[0][1])
                    reset_secs = r_fields.get(1, [('varint', 0)])[0][1]
                    
                l_desc = l_fields.get(7, [('bytes', b'')])[0][1].decode('utf-8', errors='ignore')
                
                limits.append({
                    "id": l_id,
                    "name": l_name,
                    "type": l_type,
                    "remainingFraction": l_frac,
                    "resetTime": reset_secs,
                    "description": l_desc
                })
                
            g_name = g_fields.get(2, [('bytes', b'')])[0][1].decode('utf-8', errors='ignore')
            g_desc = g_fields.get(3, [('bytes', b'')])[0][1].decode('utf-8', errors='ignore')
            
            groups.append({
                "name": g_name,
                "description": g_desc,
                "limits": limits
            })
            
        print(json.dumps({"ok": True, "groups": groups}))
    except Exception as e:
        print(json.dumps({"ok": False, "error": str(e)}))

if __name__ == "__main__":
    main()
