#!/bin/bash

SERVER=$(jq -r '.server' /data/options.json)
SHARE=$(jq -r '.share' /data/options.json)
MOUNTPOINT=$(jq -r '.mountpoint' /data/options.json)
SMB_USER=$(jq -r '.smb_user' /data/options.json)
SMB_PASS=$(jq -r '.smb_pass' /data/options.json)
REFRESH_MINUTES=$(jq -r '.refresh_minutes' /data/options.json)

echo "Starting Photo Frame SMB Mount Add-on"
echo "Server: $SERVER"
echo "Share: $SHARE"
echo "Mountpoint: $MOUNTPOINT"
echo "Refresh every $REFRESH_MINUTES minutes"

mkdir -p "$MOUNTPOINT"
mkdir -p /config/www/photo-frame

mount_smb() {
    echo "Mounting SMB..."
    mount -t cifs "//$SERVER/$SHARE" "$MOUNTPOINT" \
        -o username="$SMB_USER",password="$SMB_PASS",vers=3.0,iocharset=utf8,rw
}

bind_mount() {
    echo "Binding to /config/www/photo-frame..."
    mount --bind "$MOUNTPOINT" /config/www/photo-frame
}

generate_index() {
    echo "Generating index.json..."
    OUT="/config/www/photo-frame/index.json"
    echo '{ "images": [' > "$OUT"
    FIRST=1
    for F in "$MOUNTPOINT"/*; do
        if [[ $F =~ \.(jpg|jpeg|png|gif|webp)$ ]]; then
            FILE=$(basename "$F")
            if [ $FIRST -eq 0 ]; then echo "," >> "$OUT"; fi
            echo -n "  \"${FILE}\"" >> "$OUT"
            FIRST=0
        fi
    done
    echo ' ] }' >> "$OUT"
}

mount_smb
bind_mount
generate_index

while true; do
    sleep $((REFRESH_MINUTES * 60))
    generate_index
done

