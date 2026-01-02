#!/bin/bash
BACKUP=$(ls -t /opt/victronenergy/gui-v2/Victron/VenusOS/components/StatusBar.qml.bak.* 2>/dev/null | head -n1)
if [ -n "$BACKUP" ]; then
    cp /opt/victronenergy/gui-v2/Victron/VenusOS/components/StatusBar.qml /opt/victronenergy/gui-v2/Victron/VenusOS/components/StatusBar.qml.pre-restore-$(date +%Y%m%d-%H%M%S) 2>/dev/null
    cp "$BACKUP" /opt/victronenergy/gui-v2/Victron/VenusOS/components/StatusBar.qml
    ( svc -t /service/gui-v2 && svc -t /service/start-gui ) &
    echo "✅ StatusBar.qml restored from $BACKUP"
else
    echo "❌ No StatusBar.qml backup found"
fi
