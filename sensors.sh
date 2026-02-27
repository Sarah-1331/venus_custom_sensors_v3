#!/bin/sh
# =================================================================
# Venus OS Custom Live Sensor Installer (Overlay-safe)
# =================================================================

# Original target
ORIG_STATUSBAR_QML="/opt/victronenergy/gui-v2/Victron/VenusOS/components/StatusBar.qml"

# Overlay paths
OVERLAY_UPPER="/data/apps/overlay-fs/data/gui-v2/upper"
OVERLAY_STATUSBAR_QML="$OVERLAY_UPPER/Victron/VenusOS/components/StatusBar.qml"

# Determine which file to edit
if [ -d "$OVERLAY_UPPER" ]; then
    echo "✅ Overlay upper found, using overlay copy."

    # Ensure folder structure exists
    mkdir -p "$(dirname "$OVERLAY_STATUSBAR_QML")"

    # Copy original to overlay if missing
    if [ ! -f "$OVERLAY_STATUSBAR_QML" ]; then
        cp "$ORIG_STATUSBAR_QML" "$OVERLAY_STATUSBAR_QML" || {
            echo "❌ Failed to copy original StatusBar.qml to overlay!"
            exit 1
        }
        echo "📝 Original StatusBar.qml copied to overlay."
    else
        echo "ℹ StatusBar.qml already exists in overlay."
    fi

    STATUSBAR_QML="$OVERLAY_STATUSBAR_QML"
else
    echo "⚠ Overlay upper not found, using original file."
    STATUSBAR_QML="$ORIG_STATUSBAR_QML"
fi

echo "Editing: $STATUSBAR_QML"

#!/bin/sh
# =================================================================
# Venus OS Custom Live Sensor Installer
# Hard-coded paths, Unix line endings, safe commands
# =================================================================

# Paths
# STATUSBAR_QML="/opt/victronenergy/gui-v2/Victron/VenusOS/components/StatusBar.qml"
ICON_DIR="/data/custom-icons"
CUSTOM_ROW="/data/custom_live_sensor_row.qml"

# 1️⃣ Backup original QML
echo "Backing up original statusbar.qml..."
if [ -f "$STATUSBAR_QML" ]; then
    cp "$STATUSBAR_QML" "${STATUSBAR_QML}.bak.$(date +%Y%m%d%H%M%S)"
else
    echo "Error: $STATUSBAR_QML does not exist!"
    exit 1
fi

# 2️⃣ Write the custom live sensor row to a temporary file
cat > "$CUSTOM_ROW" <<'EOF'
// === Custom Live Sensor Row with Icons (Final) ===

Row {
    id: liveSensorRow
    spacing: 16
    anchors.verticalCenter: parent.verticalCenter
    anchors.right: clockLabel.left
    anchors.rightMargin: 20
// Always participate in layout, but fade in/out
    visible: true
    opacity: !breadcrumbs.visible ? 1 : 0

    Behavior on opacity {
        enabled: root.animationEnabled
        OpacityAnimator {
            duration: Theme.animation_page_idleOpacity_duration
        }
    }


    // — D-Bus Bindings —
    VeQuickItem { id: internalTemp; uid: "dbus/com.victronenergy.temperature.adc_builtin_temp_3/Temperature" }
    VeQuickItem { id: externalTemp; uid: "dbus/com.victronenergy.temperature.adc_builtin_temp_2/Temperature" }
    VeQuickItem { id: fridgeTemp;   uid: "dbus/com.victronenergy.temperature.adc_builtin_temp_1/Temperature" }
    VeQuickItem { id: hotWaterTemp; uid: "dbus/com.victronenergy.temperature.adc_builtin_temp_0/Temperature" }
    VeQuickItem { id: waterLevel;   uid: "dbus/com.victronenergy.tank.adc_gxtank_HQ2233VFF4U_0/Level" }
    VeQuickItem { id: waterCapacity; uid: "dbus/com.victronenergy.tank.adc_gxtank_HQ2233VFF4U_0/Capacity" }
    VeQuickItem { id: themeMode;     uid: "dbus/com.victronenergy.settings/Settings/Gui/ColorScheme" }

    // — Internal Temp —
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

    // — External Temp —
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

    // — Fridge Temp —
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

Row {
    id: water
    spacing: 4
    anchors.verticalCenter: parent.verticalCenter
    anchors.left: alarmButton.visible && alarmButton.enabled
                    ? alarmButton.right
                  : notificationButton.visible
                    ? notificationButton.right
                  : connectivityRow.right
    anchors.leftMargin: 20
    
    
    
// Always in layout, but fade based on breadcrumbs
    visible: true
    opacity: !breadcrumbs.visible ? 1 : 0

    Behavior on opacity {
        enabled: root.animationEnabled
        OpacityAnimator {
            duration: Theme.animation_page_idleOpacity_duration
        }
    }

    // — Water Tank Level —
    Row {
        spacing: 4
        Image {
            width: 20; height: 20
            fillMode: Image.PreserveAspectFit
            source: themeMode.value === 1
                ? "file:///data/custom-icons/waterB.svg"
                : "file:///data/custom-icons/water.svg"
        }
        Label {
            text: waterLevel.valid
                  ? (waterCapacity.valid
                     ? ((waterLevel.value / 100.0) * waterCapacity.value * 1000).toFixed(0) + "L"
                     : (waterLevel.value.toFixed(0) + "%"))
                  : "--"
            font.bold: true
            font.pixelSize: 18
        }
    }
	
	// — Hot Water Temp —
	Row {
		spacing: 4
		Image {
			width: 20; height: 20
			fillMode: Image.PreserveAspectFit
			source: themeMode.value === 1
            ? "file:///data/custom-icons/hotwaterB.svg"
            : "file:///data/custom-icons/hotwater.svg"
		}
		Label {
			text: hotWaterTemp.valid ? hotWaterTemp.value.toFixed(1) + "°C" : "--.-°C"
			font.bold: true
			font.pixelSize: 18
		}
	}
}


// === End Custom Live Sensor Row ===
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
echo "Creating icon directory..."
mkdir -p "$ICON_DIR"

# 5️⃣ Write SVG files (white and black versions)
echo "Writing SVG icons..."

write_svg() {
    cat > "$ICON_DIR/$1" <<EOF
$2
EOF
}

# White icons
write_svg temp.svg '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"><path d="M3 11L12 3l9 8"/><path d="M5 10v10h14V10"/><path d="M9 21V13h6v8"/></svg>'
write_svg external.svg '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="9"/><path d="M3 12h18"/><path d="M12 3a15 15 0 0 1 0 18"/><path d="M5 5a15 15 0 0 1 14 14"/></svg>'
write_svg snowflake.svg '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"><!-- Six identical arms --><g transform="translate(12,12)"><g id="arm"><line x1="0" y1="-10" x2="0" y2="0"/><line x1="-2" y1="-8" x2="0" y2="-10"/><line x1="2" y1="-8" x2="0" y2="-10"/></g><use href="#arm" transform="rotate(60)"/><use href="#arm" transform="rotate(120)"/><use href="#arm" transform="rotate(180)"/><use href="#arm" transform="rotate(240)"/><use href="#arm" transform="rotate(300)"/></g></svg>'
write_svg water.svg '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"><path d="M12 2s-5 5-5 8a5 5 0 1 0 10 0c0-3-5-8-5-8zM12 20a3 3 0 0 1-3-3c0-2 2-5 3-6 1 1 3 4 3 6a3 3 0 0 1-3 3z"/></svg>'
write_svg hotwater.svg '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"><path d="M12 2s-5 5-5 8a5 5 0 1 0 10 0c0-3-5-8-5-8zM12 20a3 3 0 0 1-3-3c0-2 2-5 3-6 1 1 3 4 3 6a3 3 0 0 1-3 3z"/></svg>'

# Black icons
write_svg tempB.svg '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="black" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"><path d="M3 11L12 3l9 8"/><path d="M5 10v10h14V10"/><path d="M9 21V13h6v8"/></svg>'
write_svg externalB.svg '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="black" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="9"/><path d="M3 12h18"/><path d="M12 3a15 15 0 0 1 0 18"/><path d="M5 5a15 15 0 0 1 14 14"/></svg>'
write_svg snowflakeB.svg '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="black" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"><!-- Six identical arms --><g transform="translate(12,12)"><g id="arm"><line x1="0" y1="-10" x2="0" y2="0"/><line x1="-2" y1="-8" x2="0" y2="-10"/><line x1="2" y1="-8" x2="0" y2="-10"/></g><use href="#arm" transform="rotate(60)"/><use href="#arm" transform="rotate(120)"/><use href="#arm" transform="rotate(180)"/><use href="#arm" transform="rotate(240)"/><use href="#arm" transform="rotate(300)"/></g></svg>'
write_svg waterB.svg '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="black" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"><path d="M12 2s-5 5-5 8a5 5 0 1 0 10 0c0-3-5-8-5-8zM12 20a3 3 0 0 1-3-3c0-2 2-5 3-6 1 1 3 4 3 6a3 3 0 0 1-3 3z"/></svg>'
write_svg hotwaterB.svg '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="black" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"><path d="M12 2s-5 5-5 8a5 5 0 1 0 10 0c0-3-5-8-5-8zM12 20a3 3 0 0 1-3-3c0-2 2-5 3-6 1 1 3 4 3 6a3 3 0 0 1-3 3z"/></svg>'

# 6️⃣ Restart GUI
echo "Restarting GUI..."
svc -t /service/start-gui
svc -t /service/gui-v2

echo "Installation complete! Original backup at ${STATUSBAR_QML}.bak"
