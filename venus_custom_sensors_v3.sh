#!/bin/sh
# =================================================================
# Venus OS Custom Live Sensor Installer
# Hard-coded paths, installs live sensor row + icons + restarts GUI
# =================================================================

STATUSBAR_QML="/opt/victronenergy/gui-v2/Victron/VenusOS/components/statusbar.qml"

echo "Backing up original statusbar.qml..."
cp "$STATUSBAR_QML" "${STATUSBAR_QML}.bak"

echo "Injecting custom live sensor row..."
# Use 'awk' to insert lines after clockLabel
awk '
/id: clockLabel/ {
    print
    getline
    print
    print "Row {"
    print "    id: liveSensorRow"
    print "    spacing: 16"
    print "    anchors.verticalCenter: parent.verticalCenter"
    print "    anchors.right: clockLabel.left"
    print "    anchors.rightMargin: 20"
    print "    visible: !breadcrumbs.visible"
    print ""
    print "    VeQuickItem { id: internalTemp; uid: \"dbus/com.victronenergy.temperature.adc_builtin_temp_3/Temperature\" }"
    print "    VeQuickItem { id: externalTemp; uid: \"dbus/com.victronenergy.temperature.adc_builtin_temp_2/Temperature\" }"
    print "    VeQuickItem { id: fridgeTemp;   uid: \"dbus/com.victronenergy.temperature.adc_builtin_temp_1/Temperature\" }"
    print "    VeQuickItem { id: waterLevel;   uid: \"dbus/com.victronenergy.tank.adc_gxtank_HQ2233VFF4U_0/Level\" }"
    print "    VeQuickItem { id: waterCapacity; uid: \"dbus/com.victronenergy.tank.adc_gxtank_HQ2233VFF4U_0/Capacity\" }"
    print "    VeQuickItem { id: themeMode; uid: \"dbus/com.victronenergy.settings/Settings/Gui/ColorScheme\" }"
    print "}"
    next
}
{ print }
' "$STATUSBAR_QML" > "${STATUSBAR_QML}.tmp" && mv "${STATUSBAR_QML}.tmp" "$STATUSBAR_QML"

echo "Creating icon folder..."
mkdir -p /data/custom-icons

echo "Writing SVG icons..."

# === WHITE ICONS ===
cat > /data/custom-icons/temp.svg <<'EOF'
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none"
     stroke="white" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round">
  <path d="M14 8V4a4 4 0 0 0-8 0v4a6 6 0 1 0 8 0zM12 20.5a3.5 3.5 0 1 1-3.5-3.5c0-1.2.6-2.3 1.5-2.9V6.5a2.5 2.5 0 0 1 5 0v7.6c.9.7 1.5 1.7 1.5 2.9a3.5 3.5 0 0 1-3.5 3.5z"/>
</svg>
EOF

cat > /data/custom-icons/external.svg <<'EOF'
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"
     fill="none" stroke="white" stroke-width="1.6"
     stroke-linecap="round" stroke-linejoin="round">
  <circle cx="12" cy="12" r="9"/>
  <path d="M3 12h18"/>
  <path d="M12 3a15 15 0 0 1 0 18"/>
  <path d="M5 5a15 15 0 0 1 14 14"/>
</svg>
EOF

cat > /data/custom-icons/snowflake.svg <<'EOF'
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"
     fill="none" stroke="white" stroke-width="1.6"
     stroke-linecap="round" stroke-linejoin="round">
  <path d="M12 2v20M4 12h16M5 5l14 14M19 5L5 19"/>
</svg>
EOF

cat > /data/custom-icons/water.svg <<'EOF'
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"
     fill="none" stroke="white" stroke-width="1.6"
     stroke-linecap="round" stroke-linejoin="round">
  <path d="M12 2s-5 5-5 8a5 5 0 1 0 10 0c0-3-5-8-5-8zM12 20a3 3 0 0 1-3-3c0-2 2-5 3-6 1 1 3 4 3 6a3 3 0 0 1-3 3z"/>
</svg>
EOF

# === BLACK ICONS ===
cat > /data/custom-icons/tempB.svg <<'EOF'
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none"
     stroke="black" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round">
  <path d="M14 8V4a4 4 0 0 0-8 0v4a6 6 0 1 0 8 0zM12 20.5a3.5 3.5 0 1 1-3.5-3.5c0-1.2.6-2.3 1.5-2.9V6.5a2.5 2.5 0 0 1 5 0v7.6c.9.7 1.5 1.7 1.5 2.9a3.5 3.5 0 0 1-3.5 3.5z"/>
</svg>
EOF

cat > /data/custom-icons/externalB.svg <<'EOF'
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"
     fill="none" stroke="black" stroke-width="1.6"
     stroke-linecap="round" stroke-linejoin="round">
  <circle cx="12" cy="12" r="9"/>
  <path d="M3 12h18"/>
  <path d="M12 3a15 15 0 0 1 0 18"/>
  <path d="M5 5a15 15 0 0 1 14 14"/>
</svg>
EOF

cat > /data/custom-icons/snowflakeB.svg <<'EOF'
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"
     fill="none" stroke="black" stroke-width="1.6"
     stroke-linecap="round" stroke-linejoin="round">
  <path d="M12 2v20M4 12h16M5 5l14 14M19 5L5 19"/>
</svg>
EOF

cat > /data/custom-icons/waterB.svg <<'EOF'
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"
     fill="none" stroke="black" stroke-width="1.6"
     stroke-linecap="round" stroke-linejoin="round">
  <path d="M12 2s-5 5-5 8a5 5 0 1 0 10 0c0-3-5-8-5-8zM12 20a3 3 0 0 1-3-3c0-2 2-5 3-6 1 1 3 4 3 6a3 3 0 0 1-3 3z"/>
</svg>
EOF

echo "Restarting GUI..."
svc -t /service/start-gui

echo "Installation complete! Backup of original file is at ${STATUSBAR_QML}.bak"
