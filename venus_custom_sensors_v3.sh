#!/bin/sh
# =================================================================
# Venus OS Custom Live Sensor Installer
# Hard-coded paths, Unix line endings, safe commands
# =================================================================

# Paths
STATUSBAR_QML="/opt/victronenergy/gui-v2/Victron/VenusOS/components/statusbar.qml"
ICON_DIR="/data/custom-icons"

# 1️⃣ Backup original QML
echo "Backing up original statusbar.qml..."
if [ -f "$STATUSBAR_QML" ]; then
    cp "$STATUSBAR_QML" "${STATUSBAR_QML}.bak"
else
    echo "Error: $STATUSBAR_QML does not exist!"
    exit 1
fi

# 2️⃣ Inject live sensor row
echo "Injecting custom live sensor row..."
# We'll append our Row just before the rightSideRow declaration
TMP_FILE="${STATUSBAR_QML}.tmp"

# Use sed to insert the Row block before 'id: rightSideRow'
sed -e '/id: rightSideRow/i\
\
    // === Custom Live Sensor Row with Icons (Final) ===\
    Row {\
        id: liveSensorRow;\
        spacing: 16;\
        anchors.verticalCenter: parent.verticalCenter;\
        anchors.right: clockLabel.left;\
        anchors.rightMargin: 20;\
        visible: !breadcrumbs.visible;\
        \
        VeQuickItem { id: internalTemp; uid: "dbus/com.victronenergy.temperature.adc_builtin_temp_3/Temperature" }\
        VeQuickItem { id: externalTemp; uid: "dbus/com.victronenergy.temperature.adc_builtin_temp_2/Temperature" }\
        VeQuickItem { id: fridgeTemp; uid: "dbus/com.victronenergy.temperature.adc_builtin_temp_1/Temperature" }\
        VeQuickItem { id: waterLevel; uid: "dbus/com.victronenergy.tank.adc_gxtank_HQ2233VFF4U_0/Level" }\
        VeQuickItem { id: waterCapacity; uid: "dbus/com.victronenergy.tank.adc_gxtank_HQ2233VFF4U_0/Capacity" }\
        VeQuickItem { id: themeMode; uid: "dbus/com.victronenergy.settings/Settings/Gui/ColorScheme" }\
        \
        // Internal Temp\
        Row { spacing: 4;\
            Image { width: 20; height: 20; fillMode: Image.PreserveAspectFit;\
                source: themeMode.value === 1 ? "'"$ICON_DIR"'/tempB.svg" : "'"$ICON_DIR"'/temp.svg" }\
            Label { text: internalTemp.valid ? internalTemp.value.toFixed(1) + "°C" : "--.-°C"; font.bold: true; font.pixelSize: 18 }\
        }\
        // External Temp\
        Row { spacing: 4;\
            Image { width: 20; height: 20; fillMode: Image.PreserveAspectFit;\
                source: themeMode.value === 1 ? "'"$ICON_DIR"'/externalB.svg" : "'"$ICON_DIR"'/external.svg" }\
            Label { text: externalTemp.valid ? externalTemp.value.toFixed(1) + "°C" : "--.-°C"; font.bold: true; font.pixelSize: 18 }\
        }\
        // Fridge Temp\
        Row { spacing: 4;\
            Image { width: 20; height: 20; fillMode: Image.PreserveAspectFit;\
                source: themeMode.value === 1 ? "'"$ICON_DIR"'/snowflakeB.svg" : "'"$ICON_DIR"'/snowflake.svg" }\
            Label { text: fridgeTemp.valid ? fridgeTemp.value.toFixed(1) + "°C" : "--.-°C"; font.bold: true; font.pixelSize: 18 }\
        }\
        // Water Tank\
        Row { spacing: 4;\
            Image { width: 20; height: 20; fillMode: Image.PreserveAspectFit;\
                source: themeMode.value === 1 ? "'"$ICON_DIR"'/waterB.svg" : "'"$ICON_DIR"'/water.svg" }\
            Label { text: waterLevel.valid ? (waterCapacity.valid ? ((waterLevel.value / 100.0) * waterCapacity.value * 1000).toFixed(0) + "L" : (waterLevel.value.toFixed(0) + "%")) : "--"; font.bold: true; font.pixelSize: 18 }\
        }\
    }\
    // === End Custom Live Sensor Row ===
' "$STATUSBAR_QML" > "$TMP_FILE" && mv "$TMP_FILE" "$STATUSBAR_QML"

# 3️⃣ Create icons directory
echo "Creating icon directory..."
mkdir -p "$ICON_DIR"

# 4️⃣ Write SVG files (white and black versions)
echo "Writing SVG icons..."

# Helper function to write SVG
write_svg() {
    cat > "$ICON_DIR/$1" <<EOF
$2
EOF
}

# WHITE ICONS
write_svg temp.svg '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"><path d="M14 8V4a4 4 0 0 0-8 0v4a6 6 0 1 0 8 0zM12 20.5a3.5 3.5 0 1 1-3.5-3.5c0-1.2.6-2.3 1.5-2.9V6.5a2.5 2.5 0 0 1 5 0v7.6c.9.7 1.5 1.7 1.5 2.9a3.5 3.5 0 0 1-3.5 3.5z"/></svg>'
write_svg external.svg '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="9"/><path d="M3 12h18"/><path d="M12 3a15 15 0 0 1 0 18"/><path d="M5 5a15 15 0 0 1 14 14"/></svg>'
write_svg snowflake.svg '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"><path d="M12 2v20M4 12h16M5 5l14 14M19 5L5 19"/></svg>'
write_svg water.svg '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"><path d="M12 2s-5 5-5 8a5 5 0 1 0 10 0c0-3-5-8-5-8zM12 20a3 3 0 0 1-3-3c0-2 2-5 3-6 1 1 3 4 3 6a3 3 0 0 1-3 3z"/></svg>'

# BLACK ICONS
write_svg tempB.svg '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="black" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"><path d="M14 8V4a4 4 0 0 0-8 0v4a6 6 0 1 0 8 0zM12 20.5a3.5 3.5 0 1 1-3.5-3.5c0-1.2.6-2.3 1.5-2.9V6.5a2.5 2.5 0 0 1 5 0v7.6c.9.7 1.5 1.7 1.5 2.9a3.5 3.5 0 0 1-3.5 3.5z"/></svg>'
write_svg externalB.svg '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="black" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="9"/><path d="M3 12h18"/><path d="M12 3a15 15 0 0 1 0 18"/><path d="M5 5a15 15 0 0 1 14 14"/></svg>'
write_svg snowflakeB.svg '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="black" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"><path d="M12 2v20M4 12h16M5 5l14 14M19 5L5 19"/></svg>'
write_svg waterB.svg '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="black" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"><path d="M12 2s-5 5-5 8a5 5 0 1 0 10 0c0-3-5-8-5-8zM12 20a3 3 0 0 1-3-3c0-2 2-5 3-6 1 1 3 4 3 6a3 3 0 0 1-3 3z"/></svg>'

# 5️⃣ Restart GUI
echo "Restarting GUI..."
svc -t /service/start-gui

echo "Installation complete. Original file backed up at ${STATUSBAR_QML}.bak"
