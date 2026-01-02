

# 🌡️ Venus OS Custom Sensors — Installer v3

A lightweight enhancement for the **Victron Venus OS GUI** that adds **live environmental readings** directly to the **top status bar**.

Displays:

* Internal temperature
* External temperature
* Fridge temperature
* Water tank level

All with **custom white SVG icons** for a clean, native look.

---

## ✨ Features

* 📊 Displays live sensor data directly in the **Venus OS status bar**
* 🎨 Clean white icons for consistent visual style:

  * 🌡️ **Internal temperature** (`temp.svg`)
  * 🌬️ **External temperature** (`external.svg`)
  * ❄️ **Fridge temperature** (`snowflake.svg`)
  * 💧 **Water tank level** (`water.svg`)
* 💾 Automatic backup of the original `statusbar.qml`
* ⚡ One-command **install / uninstall**
* 🔄 GUI auto-restart after changes

---

## 🧠 How It Works

This installer injects a small custom **QML block** into:

```
/opt/victronenergy/gui-v2/Victron/VenusOS/components/statusbar.qml
```

The block is inserted **just before the right-hand control row**, allowing live **D-Bus sensor data** to be displayed without breaking existing UI logic.

All SVG icons are stored in:

```
/data/custom-icons/
```

---

## ⚙️ Installation

1. **SSH into your Venus device**
   (Cerbo GX, Raspberry Pi Venus OS, etc.)

2. Run the installer:

```bash
wget -O /data/Sensors.sh "https://raw.githubusercontent.com/Sarah-1331/venus_custom_sensors_v3/main/sensors.sh"
bash /data/sensors.sh

```

---

# 

## 🔹 Restore the orignals

### 1️⃣ **Use a small temporary script to remove **

```bash
wget -O /data/remove.sh "https://raw.githubusercontent.com/Sarah-1331/venus_custom_sensors_v3/main/remove.sh"
bash /data/remove.sh
```
---



Just say the word 👍
