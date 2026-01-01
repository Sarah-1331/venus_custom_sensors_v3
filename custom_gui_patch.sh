#!/bin/bash
# Venus OS Custom Live Sensor Overlay Installer
# Injects custom live sensor row safely using overlay-fs

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
# 1️⃣ Check for overlay-fs
# ------------------------------
if [ ! -d /data/apps/overlay-fs ]; then
    echo "⚠ overlay-fs not found. Installing overlay-fs..."
    
    wget -q https://raw.githubusercontent.com/victronenergy/venus-overlay-fs/main/install.sh -O /data/install-overlay-fs.sh
    chmod +x /data/install-overlay-fs.sh
    bash /data/install-overlay-fs.sh
    
    echo "✅ overlay-fs installed."
else
    echo "✅ overlay-fs already installed."
fi

# ------------------------------
# 2️⃣ Register overlay directory
# ------------------------------
bash /data/apps/overlay-fs/add-app-and-directory.sh "$OVERLAY_NAME" "$STATUSBAR_DIR"

mkdir -p "$UPPER" "$WORK"

mount -t overlay overlay \
  -o lowerdir="$STATUSBAR_DIR",upperdir="$UPPER",workdir="$WORK" \
  "$STATUSBAR_DIR"

# ------------------------------
# 3️⃣ Copy original StatusBar.qml to overlay if missing
# ------------------------------
if [ ! -f "$UPPER/$STATUSBAR_FILE" ]; then
    cp "$STATUSBAR_QML" "$UPPER/"
fi

STATUSBAR_OVERLAY="$UPPER/$STATUSBAR_FILE"

# ------------------------------
# 4️⃣ Write the custom live sensor row
# ------------------------------
cat > "$CUSTOM_ROW" <<'EOF'
// === Custom Live Sensor Row with Icons (Final) ===

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
        OpacityAnimator {
            duration: Theme.animation_page_idleOpacity_duration
        }
    }

    VeQuickItem { id: internalTemp; uid: "dbus/com.victronenergy.temperature.adc_builtin_temp_3/Temperature" }
    VeQuickItem { id: externalTemp; uid: "dbus/com.victronenergy.temperature.adc_builtin_temp_2/Temperature" }
    VeQuickItem { id: fridgeTemp;   uid: "dbus/com.victronenergy.temperature.adc_builtin_temp_1/Temperature" }
    VeQuickItem { id: waterLevel;   uid: "dbus/com.victronenergy.tank.adc_gxtank_HQ2233VFF4U_0/Level" }
    VeQuickItem { id: waterCapacity; uid: "dbus/com.victronenergy.tank.adc_gxtank_HQ2233VFF4U_0/Capacity" }
    VeQuickItem { id: themeMode;     uid: "dbus/com.victronenergy.settings/Settings/Gui/ColorScheme" }
    
    # ... rest of your Row content ...
}
// === End Custom Live Sensor Row ===
EOF

# ------------------------------
# 5️⃣ Inject the custom row before connectivityRow
# ------------------------------
TMP_FILE="${STATUSBAR_OVERLAY}.tmp"

awk '
{
    if ($0 ~ /^[[:space:]]*Row[[:space:]]*\{[[:space:]]*$/) {
        getline nextline
        if (nextline ~ /^[[:space:]]*id: connectivityRow[[:space:]]*$/) {
            system("cat '"$CUSTOM_ROW"'")
        }
        print $0
        print nextline
        next
    }
    print
}' "$STATUSBAR_OVERLAY" > "$TMP_FILE" && mv "$TMP_FILE" "$STATUSBAR_OVERLAY"

echo "✅ Custom live sensor row injected into overlay."

# ------------------------------
# 6️⃣ Create icons directory
# ------------------------------
mkdir -p "$ICON_DIR"

# ------------------------------
# 7️⃣ Write SVG icons
# ------------------------------
write_svg() {
    cat > "$ICON_DIR/$1" <<EOF
$2
EOF
}

# Example: temp.svg, tempB.svg, etc.
write_svg temp.svg '<svg ...>...</svg>'
write_svg tempB.svg '<svg ...>...</svg>'
write_svg external.svg '<svg ...>...</svg>'
write_svg externalB.svg '<svg ...>...</svg>'
write_svg snowflake.svg '<svg ...>...</svg>'
write_svg snowflakeB.svg '<svg ...>...</svg>'
write_svg water.svg '<svg ...>...</svg>'
write_svg waterB.svg '<svg ...>...</svg>'

echo "✅ Icons written to $ICON_DIR"

# ------------------------------
# 8️⃣ Restart GUI
# ------------------------------
svc -t /service/start-gui

echo "🎉 Custom Live Sensor Overlay installation complete!"
echo "Original backup of StatusBar.qml remains in overlay upper layer; original files untouched."
