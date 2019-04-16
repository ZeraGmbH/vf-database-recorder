import QtQuick 2.0
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3
import VeinEntity 1.0

Item {
  anchors.fill: parent

  property QtObject logEntity;

  ColumnLayout {
    anchors.fill: parent

    RowLayout {
      id: row1
      width: parent.width
      TextField {
        id: dbFilePath
        placeholderText: "<PATH TO SAVE DB FILE>"
        Layout.fillWidth: true
      }

      Button {
        text: "Ok"
        onClicked: {
          if(dbFilePath.text.length>0)
          {
            logEntity.DatabaseFile=dbFilePath.text;
          }
        }
      }
    }
    RowLayout {
      id: row2
      //anchors.top: row1.bottom
      width: parent.width
      TextField {
        id: logDuration
        placeholderText: "Duration in ms"
        Layout.fillWidth: true
        validator: RegExpValidator {
          regExp: /[0-9]*/
        }
        onLengthChanged: {
          if(length === 0)
          {
            logEntity.ScheduledLoggingEnabled=false
          }
          else
          {
            logEntity.ScheduledLoggingEnabled=true
          }
        }
      }
      Button {
        text: "Ok"
        onClicked: {
          logEntity.ScheduledLoggingDuration = Number(logDuration.text)
        }
      }
    }

    RowLayout {
      //anchors.top: row2.bottom
      width: parent.width

      Button {
        id: startButton
        text: "Start"
        font.pixelSize: 20
        enabled: logEntity.LoggingEnabled === false && logEntity.DatabaseReady === true && !(logEntity.ScheduledLoggingEnabled && logEntity.ScheduledLoggingDuration === undefined )
        highlighted: true

        onClicked: {
          if(logEntity.LoggingEnabled !== true)
          {
            logEntity.LoggingEnabled=true;
          }
        }
      }

      Item {
        Layout.fillWidth: true
      }

      Button {
        id: stopButton
        text: "Stop"
        font.pixelSize: 20
        enabled: logEntity.LoggingEnabled === true

        onClicked: {
          if(logEntity.LoggingEnabled !== false)
          {
            logEntity.LoggingEnabled=false
          }
        }
      }
    }
    Label {
      text: logEntity.DatabaseFile
    }
    Label {
      text: logEntity.LoggingStatus
    }
    Label {
      text: logEntity.DatabaseReady
    }

    Item {
      Layout.fillHeight: true;
    }
  }
}


