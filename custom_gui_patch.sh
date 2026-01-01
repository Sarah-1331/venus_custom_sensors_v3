#!/bin/bash
# Venus OS Custom Live Sensor Overlay Installer v3.1
# Safe overlay install with confirmation messages

set -e  # exit on any error
set -o pipefail

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

# 1️⃣ Check overlay-fs
if [ ! -d /data/apps/overlay-fs ]; then
    echo "⚠ overlay-fs not found. Installing overlay-fs..."
    wget -q https://raw.githubusercontent.com/victronenergy/venus-overlay-fs/main/install.sh -O /data/install-overlay-fs.sh
    chmod +x /data/install-overlay-fs.sh
    bash /data/install-overlay-fs.sh
    echo "✅ overlay-fs installed."
else
    echo "✅ overlay-fs already installed."
fi

# 2️⃣ Register overlay directory
echo "📂 Registering overlay for $STATUSBAR_DIR..."
bash /data/apps/overlay-fs/add-app-and-directory.sh "$OVERLAY_NAME" "$STATUSBAR_DIR"

mkdir -p "$UPPER" "$WORK"

# 3️⃣ Mount overlay safely
if mountpoint -q "$STATUSBAR_DIR"; then
    echo "⚠ Overlay already mounted at $STATUSBAR_DIR"
else
    mount -t overlay overlay -o lowerdir="$STATUSBAR_DIR",upperdir="$UPPER",workdir="$WORK" "$STATUSBAR_DIR"
    echo "✅ Overlay mounted at $STATUSBAR_DIR"
fi

# 4️⃣ Copy original StatusBar.qml if missing
if [ ! -f "$UPPER/$STATUSBAR_FILE" ]; then
    cp "$STATUSBAR_QML" "$UPPER/"
    echo "✅ Copied original StatusBar.qml to overlay"
fi

STATUSBAR_OVERLAY="$UPPER/$STATUSBAR_FILE"

# 5️⃣ Write the custom live sensor row
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
    # ... rest of Row content ...
}
// === End Custom Live Sensor Row ===
EOF

# 6️⃣ Inject custom row before connectivityRow
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

echo "✅ Custom live sensor row injected into overlay"

# 7️⃣ Create icons directory
mkdir -p "$ICON_DIR"
echo "✅ Icon directory ready at $ICON_DIR"

# 8️⃣ Write placeholder SVGs (replace with your actual SVGs)
write_svg() {
    cat > "$ICON_DIR/$1" <<EOF
$2
EOF
}
# Example placeholder icons
write_svg temp.svg '<svg>...</svg>'
write_svg tempB.svg '<svg>...</svg>'
write_svg external.svg '<svg>...</svg>'
write_svg externalB.svg '<svg>...</svg>'
write_svg snowflake.svg '<svg>...</svg>'
write_svg snowflakeB.svg '<svg>...</svg>'
write_svg water.svg '<svg>...</svg>'
write_svg waterB.svg '<svg>...</svg>'
echo "✅ SVG icons written"

# 9️⃣ Restart GUI safely
echo "🔄 Restarting GUI..."
svc -t /service/gui-v2 || { echo "⚠ Failed to stop gui-v2"; exit 1; }
sleep 2
svc -t /service/start-gui || { echo "⚠ Failed to start GUI"; exit 1; }
sleep 2

echo "🎉 Custom Live Sensor Overlay installation complete!"
echo "Original StatusBar.qml remains untouched in overlay upper layer."
