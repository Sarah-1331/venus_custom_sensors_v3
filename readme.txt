# 🌡️ Venus OS Custom GUI Patch

## 🧭 Overview
This patch enhances the **Victron Venus OS GUI** by adding **live temperature and water level sensors** to the **status bar**, displayed next to the clock.  
It also installs custom SVG icons for each sensor and safely restarts the GUI to apply changes.

---

## ⚙️ Features
- 📊 Displays **Internal, External, and Fridge temperatures**
- 💧 Displays **Water tank level or liters**
- 🎨 Adds **custom SVG icons** in `/data/custom-icons`
- 🧩 Fully automated patch script (hardcoded paths)
- 🛡️ Creates a **backup** before modifying system files

---

## 🧰 Requirements
- Venus OS (v3.0 or newer recommended)
- SSH access enabled
- Root privileges
- Basic shell access (`ash` or `bash`)

---

## 🚀 Installation


### 1. Upload the files
Copy this `README.md` and the installer (custom_gui_patch.sh) script to device (e.g. into `/data/custom_gui_patch.sh`).



### 2.Then make it executable:
chmod +x /root/custom_gui_patch.sh



### 3. Run the patch
/data/custom_gui_patch.sh






##  To restore the original VenusOS GUI:

cp /opt/victronenergy/gui-v2/Victron/VenusOS/components/statusbar.qml.bak \
   /opt/victronenergy/gui-v2/Victron/VenusOS/components/statusbar.qml

rm -rf /data/custom-icons

svc -t /service/start-gui
