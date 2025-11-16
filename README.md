# 🌡️ Venus OS Custom Sensors — Installer v3

found an issue with dbus serial battery /data/apps/overlay-fs/data/gui-v2/merged/Victron/VenusOS/components/StatusBar.qml is the file to edit if installed 

A lightweight enhancement for **Victron Venus OS GUI** that adds live environmental readings to the **top status bar** — including **internal temperature**, **external temperature**, **fridge temperature**, and **water tank level** with custom white SVG icons.

---

## ✨ Features

- Displays live sensor data directly in the Venus OS status bar
- Clean white icons for consistent visual style:
  - 🌡️ Internal temperature (`temp.svg`)
  - 🌬️ External temperature (`external.svg`)
  - ❄️ Fridge temperature (`snowflake.svg`)
  - 💧 Water tank level (`water.svg`)
- Automatic backup of the original `statusbar.qml`
- One-command install / uninstall
- GUI auto-restart after changes

---

## 🧠 How It Works

This installer injects a small **custom QML block** into  
`/opt/victronenergy/gui-v2/Victron/VenusOS/components/statusbar.qml`,  
just before the right-hand control row, to show live D-Bus sensor data.

All icons are stored in `/data/custom-icons/`.

---

## ⚙️ Installation

SSH into your Venus device (Cerbo GX, Raspberry Pi Venus, etc.):

```bash
wget https://raw.githubusercontent.com/Sarah-1331/venus_custom_sensors_v3/main/custom_gui_patch.sh -O /data/custom_gui_patch.sh

bash /data/custom_gui_patch.sh
