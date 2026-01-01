#!/bin/sh
# =================================================================
# Venus OS Custom Live Sensor Overlay Installer
# =================================================================

# Paths
STATUSBAR_DIR="/opt/victronenergy/gui-v2/Victron/VenusOS/components"
STATUSBAR_FILE="StatusBar.qml"
STATUSBAR_QML="$STATUSBAR_DIR/$STATUSBAR_FILE"

OVERLAY_NAME="statusbar-overlay"
OVERLAY_BASE="/data/apps/overlay-fs/data/$OVERLAY_NAME"
UPPER="$OVERLAY_BASE/upper"
WORK="$OVERLAY_BASE/work"

ICON_DIR="/data/custom-icons"
CUSTOM_ROW="/data/custom_live_sensor_row.qml"

echo "🚀 Starting Custom Live Sensor Overlay Installer..."

# ------------------------------
# 1️⃣ Check overlay-fs
# ------------------------------
if [ ! -d /data/apps/overlay-fs ]; then
    echo "⚠ overlay-fs not found. Installing..."
    wget -q https://raw.githubusercontent.com/victronenergy/venus-overlay-fs/main/install.sh -O /data/install-overlay-fs.sh
    chmod +x /data/install-overlay-fs.sh
    /bin/sh /data/install-overlay-fs.sh
    echo "✅ overlay-fs installed."
else
    echo "✅ overlay-fs already installed."
fi

# ------------------------------
# 2️⃣ Register overlay directory
# ------------------------------
/bin/sh /data/apps/overlay-fs/add-app-and-directory.sh "$OVERLAY_NAME" "$STATUSBAR_DIR"

# ------------------------------
# 3️⃣ Create overlay upper/work
# ------------------------------
mkdir -p "$UPPER" "$WORK"
echo "✅ Overlay upper/work directories created."

# ------------------------------
# 4️⃣ Mount overlay if not mounted
# ------------------------------
if ! mountpoint -q "$STATUSBAR_DIR"; then
    mount -t overlay overlay -o lowerdir="$STATUSBAR_DIR",upperdir="$UPPER",workdir="$WORK" "$STATUSBAR_DIR"
    echo "✅ Overlay mounted."
else
    echo "⚠ Overlay already mounted."
fi

# ------------------------------
# 5️⃣ Copy original QML to upper layer if missing
# ------------------------------
if [ ! -f "$UPPER/$STATUSBAR_FILE" ]; then
    cp "$STATUSBAR_QML" "$UPPER/" || { echo "❌ Failed to copy original QML!"; exit 1; }
    echo "✅ Original QML copied to overlay upper."
else
    echo "✅ Original QML already exists in overlay upper."
fi

STATUSBAR_OVERLAY="$UPPER/$STATUSBAR_FILE"

# ------------------------------
# 6️⃣ Write custom live sensor row
# ------------------------------
cat > "$CUSTOM_ROW" <<'EOF'
// === Custom Live Sensor Row with Icons ===

Row {
    id: liveSensorRow
    spacing: 16
    anchors.verticalCenter: parent.verticalCenter
    anchors.right: clockLabel.left
    anchors.rightMargin: 20
    visible: true
    opacity: !breadcrumbs.visible ? 1 : 0

    Behavior on opacity {
        enabled: root.animationEnabled
        OpacityAnimator { duration: Theme.animation_page_idleOpacity_duration }
    }

    VeQuickItem { id: internalTemp; uid: "dbus/com.victronenergy.temperature.adc_builtin_temp_3/Temperature" }
    VeQuickItem { id: externalTemp; uid: "dbus/com.victronenergy.temperature.adc_builtin_temp_2/Temperature" }
    VeQuickItem { id: fridgeTemp;   uid: "dbus/com.victronenergy.temperature.adc_builtin_temp_1/Temperature" }
    VeQuickItem { id: waterLevel;   uid: "dbus/com.victronenergy.tank.adc_gxtank_HQ2233VFF4U_0/Level" }
    VeQuickItem { id: waterCapacity; uid: "dbus/com.victronenergy.tank.adc_gxtank_HQ2233VFF4U_0/Capacity" }
    VeQuickItem { id: themeMode;     uid: "dbus/com.victronenergy.settings/Settings/Gui/ColorScheme" }

    // Internal Temp
    Row { spacing:4; Image { width:20;height:20; fillMode:Image.PreserveAspectFit; source: themeMode.value===1?"file:///data/custom-icons/tempB.svg":"file:///data/custom-icons/temp.svg" } Label { text:internalTemp.valid?internalTemp.value.toFixed(1)+"°C":"--.-°C"; font.bold:true; font.pixelSize:18 } }
    // External Temp
    Row { spacing:4; Image { width:20;height:20; fillMode:Image.PreserveAspectFit; source: themeMode.value===1?"file:///data/custom-icons/externalB.svg":"file:///data/custom-icons/external.svg" } Label { text:externalTemp.valid?externalTemp.value.toFixed(1)+"°C":"--.-°C"; font.bold:true; font.pixelSize:18 } }
    // Fridge Temp
    Row { spacing:4; Image { width:20;height:20; fillMode:Image.PreserveAspectFit; source: themeMode.value===1?"file:///data/custom-icons/snowflakeB.svg":"file:///data/custom-icons/snowflake.svg" } Label { text:fridgeTemp.valid?fridgeTemp.value.toFixed(1)+"°C":"--.-°C"; font.bold:true; font.pixelSize:18 } }
    // Water Tank
    Row { spacing:4; Image { width:20;height:20; fillMode:Image.PreserveAspectFit; source: themeMode.value===1?"file:///data/custom-icons/waterB.svg":"file:///data/custom-icons/water.svg" } Label { text:waterLevel.valid?(waterCapacity.valid?((waterLevel.value/100.0)*waterCapacity.value*1000).toFixed(0)+"L":(waterLevel.value.toFixed(0)+"%")):"--"; font.bold:true; font.pixelSize:18 } }
}

// === End Custom Live Sensor Row ===
EOF
echo "✅ Custom live sensor row written."

# ------------------------------
# 7️⃣ Inject custom row into overlay QML
# ------------------------------
TMP_FILE="${STATUSBAR_OVERLAY}.tmp"
awk '
{
    print $0
    if ($0 ~ /^[[:space:]]*id: connectivityRow[[:space:]]*$/) {
        system("cat '"$CUSTOM_ROW"'")
    }
}' "$STATUSBAR_OVERLAY" > "$TMP_FILE" && mv "$TMP_FILE" "$STATUSBAR_OVERLAY"
echo "✅ Custom row injected into overlay QML."

# ------------------------------
# 8️⃣ Create icons directory
# ------------------------------
mkdir -p "$ICON_DIR"
echo "✅ Icon directory created."

# ------------------------------
# 9️⃣ Write all SVG icons
# ------------------------------
write_svg() {
    cat > "$ICON_DIR/$1" <<EOF
$2
EOF
}

# White icons
write_svg temp.svg '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"><path d="M3 11L12 3l9 8"/><path d="M5 10v10h14V10"/><path d="M9 21V13h6v8"/></svg>'
write_svg external.svg '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="9"/><path d="M3 12h18"/><path d="M12 3a15 15 0 0 1 0 18"/><path d="M5 5a15 15 0 0 1 14 14"/></svg>'
write_svg snowflake.svg '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"><g transform="translate(12,12)"><g id="arm"><line x1="0" y1="-10" x2="0" y2="0"/><line x1="-2" y1="-8" x2="0" y2="-10"/><line x1="2" y1="-8" x2="0" y2="-10"/></g><use href="#arm" transform="rotate(60)"/><use href="#arm" transform="rotate(120)"/><use href="#arm" transform="rotate(180)"/><use href="#arm" transform="rotate(240)"/><use href="#arm" transform="rotate(300)"/></g></svg>'
write_svg water.svg '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"><path d="M12 2s-5 5-5 8a5 5 0 1 0 10 0c0-3-5-8-5-8zM12 20a3 3 0 0 1-3-3c0-2 2-5 3-6 1 1 3 4 3 6a3 3 0 0 1-3 3z"/></svg>'

# Black icons
write_svg tempB.svg '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="black" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"><path d="M3 11L12 3l9 8"/><path d="M5 10v10h14V10"/><path d="M9 21V13h6v8"/></svg>'
write_svg externalB.svg '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="black" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="9"/><path d="M3 12h18"/><path d="M12 3a15 15 0 0 1 0 18"/><path d="M5 5a15 15 0 0 1 14 14"/></svg>'
write_svg snowflakeB.svg '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="black" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"><g transform="translate(12,12)"><g id="arm"><line x1="0" y1="-10" x2="0" y2="0"/><line x1="-2" y1="-8" x2="0" y2="-10"/><line x1="2" y1="-8" x2="0" y2="-10"/></g><use href="#arm" transform="rotate(60)"/><use href="#arm" transform="rotate(120)"/><use href="#arm" transform="rotate(180)"/><use href="#arm" transform="rotate(240)"/><use href="#arm" transform="rotate(300)"/></g></svg>'
write_svg waterB.svg '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="black" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"><path d="M12 2s-5 5-5 8a5 5 0 1 0 10 0c0-3-5-8-5-8zM12 20a3 3 0 0 1-3-3c0-2 2-5 3-6 1 1 3 4 3 6a3 3 0 0 1-3 3z"/></svg>'

echo "✅ All custom icons written."

# ------------------------------
# 6️⃣ Restart GUI
# ------------------------------
echo "Restarting GUI..."
svc -t /service/start-gui
svc -t /service/gui-v2

echo "🎉 Installation complete! Original backup of StatusBar.qml stored in overlay upper layer."
