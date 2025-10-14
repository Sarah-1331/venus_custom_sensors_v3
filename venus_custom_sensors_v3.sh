#!/bin/bash
# ===============================================================
#  Venus OS Custom Sensors Installer v3
#  Adds live internal, external, fridge, and water readings to
#  the top status bar, with matching white icons.
#  Includes auto-backup and --remove restore option.
# ===============================================================

QML_PATH="/opt/victronenergy/gui-v2/Victron/VenusOS/components/statusbar.qml"
BACKUP_PATH="${QML_PATH}.backup"
ICON_DIR="/data/custom-icons"

# ---------------------------------------------------------------
#  Helper: Restart GUI
# ---------------------------------------------------------------
restart_gui() {
    echo "[INFO] Restarting Venus GUI..."
    svc -t /service/start-gui
}

# ---------------------------------------------------------------
#  Remove / Restore Mode
# ---------------------------------------------------------------
if [[ "$1" == "--remove" ]]; then
    echo "== Venus Custom Sensors Uninstaller =="
    if [[ -f "$BACKUP_PATH" ]]; then
        echo "[INFO] Restoring original statusbar.qml..."
        cp "$BACKUP_PATH" "$QML_PATH"
    else
        echo "[WARN] No backup found at $BACKUP_PATH."
    fi
    if [[ -d "$ICON_DIR" ]]; then
        echo "[INFO] Removing $ICON_DIR..."
        rm -rf "$ICON_DIR"
    fi
    restart_gui
    echo "[DONE] Custom sensors removed and GUI restored."
    exit 0
fi

# ---------------------------------------------------------------
#  Install Mode
# ---------------------------------------------------------------
echo "== Venus Custom Sensors Installer v3 =="

# Backup if missing
if [[ ! -f "$BACKUP_PATH" ]]; then
    echo "[INFO] Creating backup of statusbar.qml..."
    cp "$QML_PATH" "$BACKUP_PATH"
else
    echo "[INFO] Backup already exists at $BACKUP_PATH"
fi

# Only inject once
if grep -q "liveSensorRow" "$QML_PATH"; then
    echo "[INFO] Custom sensors already injected — skipping edit."
else
    echo "[INFO] Injecting custom sensor QML block..."
    tmpfile=$(mktemp)
    awk '
        /Label {/,/}/ {
            if ($0 ~ /text: ClockTime.currentTime/) clock_end=1
        }
        clock_end && /Row { *id: rightSideRow/ && !done {
            print ""
            print "// === Custom Live Sensor Row with Icons (v3) ==="
            print "Row {"
            print "    id: liveSensorRow"
            print "    spacing: 16"
            print "    anchors.verticalCenter: parent.verticalCenter"
            print "    anchors.right: clockLabel.left"
            print "    anchors.rightMargin: 20"
            print "    visible: !breadcrumbs.visible"
            print ""
            print "    // — D-Bus Bindings —"
            print "    VeQuickItem { id: internalTemp; uid: \"dbus/com.victronenergy.temperature.adc_builtin_temp_3/Temperature\" }"
            print "    VeQuickItem { id: externalTemp; uid: \"dbus/com.victronenergy.temperature.adc_builtin_temp_2/Temperature\" }"
            print "    VeQuickItem { id: fridgeTemp;   uid: \"dbus/com.victronenergy.temperature.adc_builtin_temp_1/Temperature\" }"
            print "    VeQuickItem { id: waterLevel;   uid: \"dbus/com.victronenergy.tank.adc_gxtank_HQ2233VFF4U_0/Level\" }"
            print ""
            print "    // — Internal Temp —"
            print "    Row {"
            print "        spacing: 4"
            print "        Image { source: \"file:///data/custom-icons/temp.svg\"; width: 22; height: 22; fillMode: Image.PreserveAspectFit }"
            print "        Label { text: internalTemp.valid ? internalTemp.value.toFixed(1) + \"°C\" : \"--.-°C\"; color: \"white\"; font.bold: true; font.pixelSize: 18 }"
            print "    }"
            print ""
            print "    // — External Temp —"
            print "    Row {"
            print "        spacing: 4"
            print "        Image { source: \"file:///data/custom-icons/external.svg\"; width: 22; height: 22; fillMode: Image.PreserveAspectFit }"
            print "        Label { text: externalTemp.valid ? externalTemp.value.toFixed(1) + \"°C\" : \"--.-°C\"; color: \"white\"; font.bold: true; font.pixelSize: 18 }"
            print "    }"
            print ""
            print "    // — Fridge Temp —"
            print "    Row {"
            print "        spacing: 4"
            print "        Image { source: \"file:///data/custom-icons/snowflake.svg\"; width: 22; height: 22; fillMode: Image.PreserveAspectFit }"
            print "        Label { text: fridgeTemp.valid ? fridgeTemp.value.toFixed(1) + \"°C\" : \"--.-°C\"; color: \"white\"; font.bold: true; font.pixelSize: 18 }"
            print "    }"
            print "}"
            print ""
            print "Row {"
            print "    id: water"
            print "    spacing: 16"
            print "    anchors.verticalCenter: parent.verticalCenter"
            print "    anchors.left: connectivityRow.right"
            print "    anchors.leftMargin: 20"
            print "    visible: !breadcrumbs.visible"
            print ""
            print "    // — Water Tank Level —"
            print "    Row {"
            print "        spacing: 4"
            print "        Image { source: \"file:///data/custom-icons/water.svg\"; width: 22; height: 22; fillMode: Image.PreserveAspectFit }"
            print "        Label { text: waterLevel.valid ? (waterLevel.value * 234).toFixed(0) + \"L\" : \"--L\"; color: \"white\"; font.bold: true; font.pixelSize: 18 }"
            print "    }"
            print "}"
            print "// === End Custom Live Sensor Row ==="
            done=1
        }
        { print }
    ' "$QML_PATH" > "$tmpfile"
    cp "$tmpfile" "$QML_PATH"
    rm "$tmpfile"
fi

# ---------------------------------------------------------------
#  Install Icons
# ---------------------------------------------------------------
echo "[INFO] Installing custom icons..."
mkdir -p "$ICON_DIR"

# Internal Temperature Icon
cat > "$ICON_DIR/temp.svg" <<'EOF'
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none"
     stroke="white" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round">
  <path d="M14 8V4a4 4 0 0 0-8 0v4a6 6 0 1 0 8 0zM12 20.5a3.5 3.5 0 1 1-3.5-3.5c0-1.2.6-2.3 1.5-2.9V6.5a2.5 2.5 0 0 1 5 0v7.6c.9.7 1.5 1.7 1.5 2.9a3.5 3.5 0 0 1-3.5 3.5z"/>
</svg>
EOF

# External Temperature Icon (final wind/globe)
cat > "$ICON_DIR/external.svg" <<'EOF'
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"
     fill="none" stroke="white" stroke-width="1.6"
     stroke-linecap="round" stroke-linejoin="round">
  <circle cx="12" cy="12" r="9"/>
  <path d="M3 12h18"/>
  <path d="M12 3a15 15 0 0 1 0 18"/>
  <path d="M5 5a15 15 0 0 1 14 14"/>
</svg>
EOF

# Fridge Temperature Icon
cat > "$ICON_DIR/snowflake.svg" <<'EOF'
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"
     fill="none" stroke="white" stroke-width="1.6"
     stroke-linecap="round" stroke-linejoin="round">
  <path d="M12 2v20M4 12h16M5 5l14 14M19 5L5 19"/>
</svg>
EOF

# Water Tank Icon
cat > "$ICON_DIR/water.svg" <<'EOF'
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"
     fill="none" stroke="white" stroke-width="1.6"
     stroke-linecap="round" stroke-linejoin="round">
  <path d="M12 2s-5 5-5 8a5 5 0 1 0 10 0c0-3-5-8-5-8zM12 20a3 3 0 0 1-3-3c0-2 2-5 3-6 1 1 3 4 3 6a3 3 0 0 1-3 3z"/>
</svg>
EOF

chmod 644 "$ICON_DIR"/*.svg
restart_gui
echo "[DONE] Installation complete. Venus GUI updated with custom sensors."
