# 🌡️ Venus OS Custom Sensors — Installer v3

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
- Safe re-installation (no duplicate injection)
- `--remove` option restores backup and removes icons
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
wget https://your-repo-url/venus_custom_sensors_v3.sh -O /data/venus_custom_sensors_v3.sh
chmod +x /data/venus_custom_sensors_v3.sh
/data/venus_custom_sensors_v3.sh
