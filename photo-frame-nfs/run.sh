#!/bin/bash

SERVER=$(jq -r '.server' /data/options.json)
PATH_ON_NAS=$(jq -r '.path' /data/options.json)
MOUNTPOINT=$(jq -r '.mountpoint' /data/options.json)
REFRESH_HOURS=$(jq -r '.refresh_hours' /data/options.json)

echo "Starting Photo Frame NFS Mount Add-on"
echo "Server: $SERVER"
echo "Path: $PATH_ON_NAS"
echo "Mountpoint: $MOUNTPOINT"
echo "Refresh every $REFRESH_HOURS hours"

mkdir -p "$MOUNTPOINT"
mkdir -p /config/www/photo-frame

mount_nfs() {
    echo "Mounting NFS..."
    mount -t nfs "$SERVER:$PATH_ON_NAS" "$MOUNTPOINT" -o rw,async,nolock
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

# Initial mount + bind + index
mount_nfs
bind_mount
generate_index

# Loop forever
while true; do
    sleep $((REFRESH_HOURS * 3600))
    generate_index
done
