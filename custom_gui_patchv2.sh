#!/bin/sh
# =================================================================
# Venus OS Custom Live Sensor Installer (overlay-aware)
# Hard-coded paths, Unix line endings, safe commands
# =================================================================

# ---------- Paths ----------
ORIG_STATUSBAR="/opt/victronenergy/gui-v2/Victron/VenusOS/components/StatusBar.qml"

OVERLAY_BASE="/data/apps/overlay-fs"
UPPER_STATUSBAR="$OVERLAY_BASE/data/opt/victronenergy/gui-v2/upper/Victron/VenusOS/components/StatusBar.qml"

# Default target: original file
STATUSBAR_QML="$ORIG_STATUSBAR"

ICON_DIR="/data/custom-icons"
CUSTOM_ROW="/data/custom_live_sensor_row.qml"

echo "============================================================"
echo " Venus OS Custom Live Sensor Installer (overlay-aware)"
echo "============================================================"
echo

# ---------- Detect overlay-fs and choose target StatusBar.qml ----------

if [ -d "$OVERLAY_BASE" ]; then
    echo "[=] overlay-fs appears to be installed at: $OVERLAY_BASE"

    # Ensure directory for upper StatusBar exists
    mkdir -p "$(dirname "$UPPER_STATUSBAR")"

    if [ -f "$UPPER_STATUSBAR" ]; then
        echo "[=] StatusBar.qml already present in overlay upper:"
        echo "    $UPPER_STATUSBAR"
    else
        echo "[+] StatusBar.qml not yet in overlay upper."

        if [ -f "$ORIG_STATUSBAR" ]; then
            echo "    Copying original StatusBar.qml to overlay upper..."
            cp "$ORIG_STATUSBAR" "$UPPER_STATUSBAR"
            echo "    Done."
        else
            echo "[!] WARNING: original StatusBar.qml not found at:"
            echo "    $ORIG_STATUSBAR"
            echo "    Will continue, but patching may fail."
        fi
    fi

    # Use overlay upper as the file we will modify
    STATUSBAR_QML="$UPPER_STATUSBAR"
    echo "[*] Using OVERLAY file as patch target:"
    echo "    $STATUSBAR_QML"
else
    echo "[=] overlay-fs not detected; will patch ORIGINAL file:"
    echo "    $STATUSBAR_QML"
fi

echo

# 1️⃣ Backup target QML (either overlay upper or original)
echo "Backing up StatusBar.qml..."
if [ -f "$STATUSBAR_QML" ]; then
    BACKUP_PATH="${STATUSBAR_QML}.bak.$(date +%Y%m%d%H%M%S)"
    cp "$STATUSBAR_QML" "$BACKUP_PATH"
    echo "Backup created at: $BACKUP_PATH"
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
write_svg water.svg '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"><path d="M12 2s-5 5-5 8a5 5 0 1 0 10 0c0-3-5-8-5-8zM12 20a3 3 0 0 1-3-3c0-2 2-5 3-6 1 1 3 4 3 6a3 3 0 0 1-3 3z"/></svg>
'

# Black icons
write_svg tempB.svg '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="black" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"><path d="M3 11L12 3l9 8"/><path d="M5 10v10h14V10"/><path d="M9 21V13h6v8"/></svg>'
write_svg externalB.svg '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="black" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="9"/><path d="M3 12h18"/><path d="M12 3a15 15 0 0 1 0 18"/><path d="M5 5a15 15 0 0 1 14 14"/></svg>'
write_svg snowflakeB.svg '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="black" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"><!-- Six identical arms --><g transform="translate(12,12)"><g id="arm"><line x1="0" y1="-10" x2="0" y2="0"/><line x1="-2" y1="-8" x2="0" y2="-10"/><line x1="2" y1="-8" x2="0" y2="-10"/></g><use href="#arm" transform="rotate(60)"/><use href="#arm" transform="rotate(120)"/><use href="#arm" transform="rotate(180)"/><use href="#arm" transform="rotate(240)"/><use href="#arm" transform="rotate(300)"/></g></svg>'
write_svg waterB.svg '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="black" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"><path d="M12 2s-5 5-5 8a5 5 0 1 0 10 0c0-3-5-8-5-8zM12 20a3 3 0 0 1-3-3c0-2 2-5 3-6 1 1 3 4 3 6a3 3 0 0 1-3 3z"/></svg>'

# 6️⃣ Restart GUI
echo "Restarting GUI..."
svc -t /service/start-gui

echo
echo "Installation complete!"
echo "Patched file: $STATUSBAR_QML"
echo "Backup created at: $BACKUP_PATH"
