# 🌡️ Venus OS Custom Sensors — Installer v3

A lightweight enhancement for the Victron Venus OS GUI that adds **live environmental readings** to the top status bar, including:

- Internal temperature
- External temperature
- Fridge temperature
- Water tank level

All readings use **custom white and black SVG icons** stored in `/data/custom-icons/` for a clean, consistent look.

---

## ✨ Features

- Displays live sensor data in the Venus OS status bar  
- White & black icons for theme support:  
  🌡️ `temp.svg` / `tempB.svg` — Internal temperature  
  🌬️ `external.svg` / `externalB.svg` — External temperature  
  ❄️ `snowflake.svg` / `snowflakeB.svg` — Fridge temperature  
  💧 `water.svg` / `waterB.svg` — Water tank level  
- Automatic backup of `StatusBar.qml`  
- One-command install / uninstall  
- GUI auto-restart after changes  
- Uses overlay-fs to **never modify the original system file**  

---

## 🧠 How It Works

The installer:

1. Checks for `overlay-fs` and installs it if missing  
2. Creates an overlay for `/opt/victronenergy/gui-v2/Victron/VenusOS/components`  
3. Copies the original `StatusBar.qml` into the overlay (upper layer)  
4. Injects a small QML block **before the right-hand control row** to show live D-Bus sensor data  
5. Installs all SVG icons in `/data/custom-icons/`  
6. Restarts the GUI automatically  

This ensures the **original system files remain untouched** and your modifications are safe and reversible.

---

## ⚙️ Installation

SSH into your Venus OS device (Cerbo GX, Raspberry Pi Venus, etc.) and run:

```bash
# Download and run the installer
wget -q https://raw.githubusercontent.com/Sarah-1331/guimods/main/install_statusbar_overlay.sh -O /data/custom_gui_patch.sh
chmod +x /data/custom_gui_patch.sh
bash /data/custom_gui_patch.sh
