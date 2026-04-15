import Quickshell
import Quickshell.Io
import QtQuick

PanelWindow {
  id: panel
  
  anchors {
    top: true
    left: true
    bottom: true
  }

  width: 30
  exclusiveZone: 0
  color: 'transparent'

  mask: Region {
    item: content
  }

  Rectangle {
    id: content
    width: 30
    height: parent.height
    
    x: panelActive ? 0 : -29
    color: '#ffffff'
    opacity: panelActive ? 1 : 0

    property bool panelActive: false

    Behavior on x { 
      NumberAnimation {
        duration: 300;
        easing.type: Easing.OutCubic
      } 
    }

    Behavior on opacity { 
      NumberAnimation {
        duration: 300
      } 
    }

    MouseArea {
      id: mainMouseArea
      anchors.fill: parent
      hoverEnabled: true
      onEntered: content.panelActive = true
      onExited: content.panelActive = false
      
      onPositionChanged: (mouse) => {
        var mapped = battery.mapFromItem(mainMouseArea, mouse.x, mouse.y)
        battery.showStatus = battery.contains(Qt.point(mapped.x, mapped.y))
      }
    }

    Text {
      id: clock
      font {
        weight: 900;
        pointSize: 9
      }
      anchors {
        top: parent.top;
        horizontalCenter: parent.horizontalCenter;
        topMargin: 5
      }
      Process {
        id: dateProc
        command: ['date', '+%H\n%M\n%S\n— \n%d\n%m\n%y']
        running: true
        stdout: StdioCollector {
          onStreamFinished: clock.text = this.text
        }
      }
      Timer {
        interval: 1000;
        running: true;
        repeat: true;
        onTriggered: dateProc.running = true
      }
    }

    Text {
      id: volume
      font {
        weight: 900; pointSize: 9
      }
      anchors {
        bottom: parent.bottom;
        horizontalCenter: parent.horizontalCenter;
        bottomMargin: 35
      }
      Process {
        id: volumeProc
        command: ['sh', '-c', '~/.config/quickshell/scripts/pa.sh > ~/.config/quickshell/tmp/pa.txt && cat ~/.config/quickshell/tmp/pa.txt']
        running: true
        stdout: StdioCollector {
          onStreamFinished: volume.text = this.text
        }
      }
      Timer {
        interval: 100;
        running: true;
        repeat: true;
        onTriggered: volumeProc.running = true
      }
    }

    Text {
      id: bright
      font {
        weight: 900; pointSize: 9
      }
      anchors {
        bottom: parent.bottom;
        horizontalCenter: parent.horizontalCenter;
        bottomMargin: 20
      }
      Process {
        id: brightProc
        command: ['sh', '-c', '~/.config/quickshell/scripts/bright.sh > ~/.config/quickshell/tmp/bright.txt && cat ~/.config/quickshell/tmp/bright.txt']
        running: true
        stdout: StdioCollector {
          onStreamFinished: bright.text = this.text
        }
      }
      Timer {
        interval: 100;
        running: true;
        repeat: true;
        onTriggered: brightProc.running = true
      }
    }

    Text {
      id: battery
      font {
        weight: 900; pointSize: 9
      }
      property string batteryPercentage: ''
      property string batteryStatus: ''
      property bool showStatus: false
      text: showStatus ? (batteryStatus.length > 0 ? batteryStatus.charAt(0) : '') : batteryPercentage
      anchors {
        bottom: parent.bottom;
        horizontalCenter: parent.horizontalCenter;
        bottomMargin: 5
      }
      
      Process {
        id: batteryProc
        command: ['cat', '/sys/class/power_supply/BAT1/capacity']
        running: true
        stdout: StdioCollector {
          onStreamFinished: battery.batteryPercentage = this.text
        }
      }
      Process {
        id: batteryStatusProc
        command: ['cat', '/sys/class/power_supply/BAT1/status']
        running: true
        stdout: StdioCollector {
          onStreamFinished: battery.batteryStatus = this.text
        }
      }
      Timer {
        interval: 1000; running: true; repeat: true
        onTriggered: {
          batteryProc.running = true;
          batteryStatusProc.running = true
        }
      }
    }
  }
}
