#!/system/bin/sh

# Copyright (C) 2024 The OrangeFox Recovery Project
# Copyright (C) 2026 chickendrop89
# SPDX-License-Identifier: GPL-3.0-only

LOGMSG() {
	echo "I:$1" >> /tmp/recovery.log;
}

do_prep() {
    recovery_cache="/data/cache/recovery/"
    metadata_directories=(
        "bootstat:0750:system:log"
        "ota:0750:root:system"
        "ota/snapshots:0750:root:system"
		"staged-install:0770:root:system"
        "userspacereboot:0770:root:system"
        "watchdog:0770:root:system"
    )

    mkdir -p "$recovery_cache"

    if mountpoint -q /metadata || mount /metadata 2>/dev/null; then
        D="/metadata/ota"
        LOGMSG "Checking for stale OTA metadata which may block ROM install or formatting..."
        if [ -d "$D" ]; then
            LOGMSG "Wiping $D..."
            rm -rf "$D" 2>/dev/null
        fi
        
        for entry in "${metadata_directories[@]}"; do
            IFS=":" read -r path mode owner group <<< "$entry"
            full_path="/metadata/$path"
            
            mkdir -p "$full_path"
            chmod "$mode" "$full_path"
            chown "$owner:$group" "$full_path"
        done
    else
        LOGMSG "Failed to mount metadata, aborting";
        exit 1
    fi
}

backup_fox() {
	file=$1;

	if [ -f "$file" ]; then
		x=$(unzip -lq "$file" | grep "payload.bin");
		[ -n "$x" ] && return; # standard payload.bin - no need for a backup
	fi

    slot="$(getprop ro.boot.slot_suffix)"
    recovery_partition="recovery"
    [ -n "$slot" ] && recovery_partition="recovery${slot}"

    source="/dev/block/bootdevice/by-name/$recovery_partition";
	destination="/tmp/fox_backup.img";

	if [ ! -f $destination ]; then
		LOGMSG "Backing up OrangeFox to \"$destination\"...";
		dd bs=1048576 if=$source of=$destination >/dev/null 2>&1;
	fi
}

LOGMSG "Running pre-ROM-flash script...";
do_prep;
backup_fox "$@";
exit 0;
