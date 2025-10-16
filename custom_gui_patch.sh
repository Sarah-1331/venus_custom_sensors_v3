#!/bin/sh
# === Custom VenusOS GUI Patch Script ===
# This script edits statusbar.qml and adds custom sensor rows + icons.

# Backup the original file first
cp /opt/victronenergy/gui-v2/Victron/VenusOS/components/statusbar.qml \
   /opt/victronenergy/gui-v2/Victron/VenusOS/components/statusbar.qml.bak

# Insert custom QML section before rightSideRow definition
sed -i '/Row { *id: rightSideRow/ i \
// === Custom Live Sensor Row with Icons (Final) ===\n\
Row {\n\
    id: liveSensorRow\n\
    spacing: 16\n\
    anchors.verticalCenter: parent.verticalCenter\n\
    anchors.right: clockLabel.left\n\
    anchors.rightMargin: 20\n\
    visible: !breadcrumbs.visible\n\
\n\
    VeQuickItem { id: internalTemp; uid: "dbus/com.victronenergy.temperature.adc_builtin_temp_3/Temperature" }\n\
    VeQuickItem { id: externalTemp; uid: "dbus/com.victronenergy.temperature.adc_builtin_temp_2/Temperature" }\n\
    VeQuickItem { id: fridgeTemp;   uid: "dbus/com.victronenergy.temperature.adc_builtin_temp_1/Temperature" }\n\
    VeQuickItem { id: waterLevel;   uid: "dbus/com.victronenergy.tank.adc_gxtank_HQ2233VFF4U_0/Level" }\n\
    VeQuickItem { id: waterCapacity; uid: "dbus/com.victronenergy.tank.adc_gxtank_HQ2233VFF4U_0/Capacity" }\n\
\n\
    Row {\n\
        spacing: 4\n\
        Image { source: \"file:///data/custom-icons/temp.svg\"; width: 20; height: 20; fillMode: Image.PreserveAspectFit }\n\
        Label { text: internalTemp.valid ? internalTemp.value.toFixed(1) + \"°C\" : \"--.-°C\"; color: \"white\"; font.bold: true; font.pixelSize: 18 }\n\
    }\n\
\n\
    Row {\n\
        spacing: 4\n\
        Image { source: \"file:///data/custom-icons/external.svg\"; width: 20; height: 20; fillMode: Image.PreserveAspectFit }\n\
        Label { text: externalTemp.valid ? externalTemp.value.toFixed(1) + \"°C\" : \"--.-°C\"; color: \"white\"; font.bold: true; font.pixelSize: 18 }\n\
    }\n\
\n\
    Row {\n\
        spacing: 4\n\
        Image { source: \"file:///data/custom-icons/snowflake.svg\"; width: 20; height: 20; fillMode: Image.PreserveAspectFit }\n\
        Label { text: fridgeTemp.valid ? fridgeTemp.value.toFixed(1) + \"°C\" : \"--.-°C\"; color: \"white\"; font.bold: true; font.pixelSize: 18 }\n\
    }\n\
}\n\
\n\
Row {\n\
    id: water\n\
    spacing: 16\n\
    anchors.verticalCenter: parent.verticalCenter\n\
    anchors.left: connectivityRow.right\n\
    anchors.leftMargin: 20\n\
    visible: !breadcrumbs.visible\n\
\n\
    Row {\n\
        spacing: 4\n\
        Image { source: \"file:///data/custom-icons/water.svg\"; width: 20; height: 20; fillMode: Image.PreserveAspectFit }\n\
        Label {\n\
            text: waterLevel.valid ? (waterCapacity.valid ? ((waterLevel.value / 100.0) * waterCapacity.value * 1000).toFixed(0) + \"L\" : (waterLevel.value.toFixed(0) + \"%\")) : \"--\"\n\
            color: \"white\"; font.bold: true; font.pixelSize: 18\n\
        }\n\
    }\n\
}\n\
// === End Custom Live Sensor Row ===' \
/opt/victronenergy/gui-v2/Victron/VenusOS/components/statusbar.qml

# Restart GUI to apply QML changes
svc -t /service/start-gui

# Create icon directory
mkdir -p /data/custom-icons

# Write SVG icons
cat > /data/custom-icons/temp.svg <<'EOF'
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"
     fill="none" stroke="white" stroke-width="1.6"
     stroke-linecap="round" stroke-linejoin="round">
  <path d="M3 11L12 3l9 8"/>
  <path d="M5 10v10h14V10"/>
  <path d="M9 21V13h6v8"/>
</svg>
EOF

cat > /data/custom-icons/external.svg <<'EOF'
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="1.5">
  <circle cx="12" cy="12" r="10"/>
  <path d="M4 9c4 1.5 12 1.5 16 0M4 15c4-1.5 12-1.5 16 0"/>
  <path d="M10 2c2 3 3 7 3 10s-1 7-3 10M15 3c1.5 2.5 2.5 6 2.5 9s-1 6.5-2.5 9"/>
  <path d="M3 12.5c5 1.5 13 1.5 18 0"/>
</svg>
EOF

cat > /data/custom-icons/snowflake.svg <<'EOF'
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"
     fill="none" stroke="white" stroke-width="1.6"
     stroke-linecap="round" stroke-linejoin="round">
  <g transform="translate(12,12)">
    <g id="arm">
      <line x1="0" y1="-10" x2="0" y2="0"/>
      <line x1="-2" y1="-8" x2="0" y2="-10"/>
      <line x1="2" y1="-8" x2="0" y2="-10"/>
    </g>
    <use href="#arm" transform="rotate(60)"/>
    <use href="#arm" transform="rotate(120)"/>
    <use href="#arm" transform="rotate(180)"/>
    <use href="#arm" transform="rotate(240)"/>
    <use href="#arm" transform="rotate(300)"/>
  </g>
</svg>
EOF

cat > /data/custom-icons/water.svg <<'EOF'
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"
     fill="none" stroke="white" stroke-width="1.6"
     stroke-linecap="round" stroke-linejoin="round">
  <path d="M12 2s-5 5-5 8a5 5 0 1 0 10 0c0-3-5-8-5-8zM12 20a3 3 0 0 1-3-3c0-2 2-5 3-6 1 1 3 4 3 6a3 3 0 0 1-3 3z"/>
</svg>
EOF

chmod 644 /data/custom-icons/*.svg

# Restart GUI again to load new icons
svc -t /service/start-gui

echo "=== Custom GUI patch applied successfully ==="
