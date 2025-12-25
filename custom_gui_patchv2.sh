#!/bin/sh
# =================================================================
# Venus OS Custom Live Sensor Installer (Overlay-aware)
# =================================================================

# Paths
REL_STATUSBAR="Victron/VenusOS/components/StatusBar.qml"
ICON_DIR="/data/custom-icons"
CUSTOM_ROW="/data/custom_live_sensor_row.qml"

# Detect overlay
if [ -d "/data/apps/overlay-fs/data/gui-v2/upper" ]; then
    echo "Overlay detected. Using overlay upper layer."
    UPPER_BASE="/data/apps/overlay-fs/data/gui-v2/upper"
    STATUSBAR_QML="$UPPER_BASE/$REL_STATUSBAR"
    # Create full folder hierarchy
    mkdir -p "$(dirname "$STATUSBAR_QML")"
    # Copy original if not already present
    if [ ! -f "$STATUSBAR_QML" ]; then
        cp "/opt/victronenergy/gui-v2/$REL_STATUSBAR" "$STATUSBAR_QML"
    fi
else
    echo "Overlay NOT detected. Modifying original file directly."
    STATUSBAR_QML="/opt/victronenergy/gui-v2/$REL_STATUSBAR"
fi

# 1️⃣ Backup QML
echo "Backing up $STATUSBAR_QML..."
cp "$STATUSBAR_QML" "${STATUSBAR_QML}.bak.$(date +%Y%m%d%H%M%S)"

# 2️⃣ Write the custom live sensor row
cat > "$CUSTOM_ROW" <<'EOF'
// === Custom Live Sensor Row ===
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

    Row {
        spacing: 4
        Image {
            width: 20; height: 20
            fillMode: Image.PreserveAspectFit
            source: themeMode.value === 1
                ? "file:///data/custom-icons/tempB.svg"
                : "file:///data/custom-icons/temp.svg"
        }
        Label {
            text: internalTemp.valid ? internalTemp.value.toFixed(1) + "°C" : "--.-°C"
            font.bold: true; font.pixelSize: 18
        }
    }

    Row {
        spacing: 4
        Image {
            width: 20; height: 20
            fillMode: Image.PreserveAspectFit
            source: themeMode.value === 1
                ? "file:///data/custom-icons/externalB.svg"
                : "file:///data/custom-icons/external.svg"
        }
        Label {
            text: externalTemp.valid ? externalTemp.value.toFixed(1) + "°C" : "--.-°C"
            font.bold: true; font.pixelSize: 18
        }
    }

    Row {
        spacing: 4
        Image {
            width: 20; height: 20
            fillMode: Image.PreserveAspectFit
            source: themeMode.value === 1
                ? "file:///data/custom-icons/snowflakeB.svg"
                : "file:///data/custom-icons/snowflake.svg"
        }
        Label {
            text: fridgeTemp.valid ? fridgeTemp.value.toFixed(1) + "°C" : "--.-°C"
            font.bold: true; font.pixelSize: 18
        }
    }
}
EOF

# 3️⃣ Inject the custom row before "Row { id: connectivityRow"
TMP_FILE="${STATUSBAR_QML}.tmp"
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
}' "$STATUSBAR_QML" > "$TMP_FILE" && mv "$TMP_FILE" "$STATUSBAR_QML"

# 4️⃣ Create icons directory
mkdir -p "$ICON_DIR"

# 5️⃣ Write SVG icons (white and black)
write_svg() {
    cat > "$ICON_DIR/$1" <<EOF
$2
EOF
}

# White icons
write_svg temp.svg '<svg ...white temp svg content.../>'
write_svg external.svg '<svg ...white external svg content.../>'
write_svg snowflake.svg '<svg ...white snowflake svg content.../>'
write_svg water.svg '<svg ...white water svg content.../>'

# Black icons
write_svg tempB.svg '<svg ...black temp svg content.../>'
write_svg externalB.svg '<svg ...black external svg content.../>'
write_svg snowflakeB.svg '<svg ...black snowflake svg content.../>'
write_svg waterB.svg '<svg ...black water svg content.../>'

# 6️⃣ Restart GUI
echo "Restarting GUI..."
svc -t /service/start-gui

echo "Installation complete! Original backup at ${STATUSBAR_QML}.bak"
