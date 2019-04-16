import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3
import VeinEntity 1.0
import VeinLogger 1.0

ApplicationWindow {
  visible: true
  width: 640
  height: 480
  title: qsTr("Database recorder")
  id: root

  readonly property int loggerEntId: 200000;

  VeinLogger {
    id: dataLogger
    recordName: "default"
    initializeValues: true
    //only run script manually
    property var requiredIds: [];
    property var resolvedIds: []; //may only contain ids that are also in requiredIds

    readonly property bool debugBuild: true
    property bool entitiesLoaded: false
    property var loggedValues: ({});
    property QtObject logEntity;

    onLoggedValuesChanged: {
      clearLoggerEntries();
      for(var it in loggedValues)
      {
        var entData = loggedValues[it];
        for(var i=0; i<entData.length; ++i)
        {
          addLoggerEntry(it, entData[i]);
        }
      }
    }

    readonly property bool scriptRunning: loggingEnabled
    onScriptRunningChanged: {
      if(scriptRunning === true)
      {
        console.log("starting logging at", new Date().toLocaleTimeString());
        startLogging();
      }
      else
      {
        console.log("stopped logging at", new Date().toLocaleTimeString());
        stopLogging();
      }
    }

    property string session;
    onSessionChanged: {
      var entIds = VeinEntity.getEntity("_System")["Entities"];
      if(entIds !== undefined)
      {
        if(entIds.indexOf(0) === -1)
        {
          entIds.push(0);
        }
        if(entIds.indexOf(loggerEntId) === -1)
        {
          entIds.push(loggerEntId);
        }
      }
      else
      {
        entIds = [0, loggerEntId];
      }
      for(var tmpId in entIds)
      {
        VeinEntity.entitySubscribeById(entIds[tmpId]);
      }
      dataLogger.requiredIds = entIds;
      dataLogger.resolvedIds = [0];
      entitiesLoaded = true
    }

    Binding on session {
      when: VeinEntity.getEntity("_System")
      value: VeinEntity.getEntity("_System").Session
    }

    function setLoggedEntities()
    {
      var entityIdList = resolvedIds;
      entityIdList.splice(resolvedIds.indexOf(loggerEntId) ,1)
      for(var tmpIndex in resolvedIds)
      {
        //log all components of all entities
        var tmpEntity = VeinEntity.getEntityById(resolvedIds[tmpIndex]);
        dataLogger.loggedValues[String(resolvedIds[tmpIndex])] = tmpEntity.keys();
        dataLogger.loggedValuesChanged();
      }
    }


    Connections {
      target: VeinEntity
      onSigEntityAvailable: {
        var entId = VeinEntity.getEntity(t_entityName).entityId()
        if(dataLogger.requiredIds.indexOf(entId) > -1) //required
        {
          if(dataLogger.resolvedIds.indexOf(entId) < 0) //resolved
          {
            dataLogger.resolvedIds.push(entId);
            var array1 = dataLogger.resolvedIds.sort();
            var array2 = dataLogger.requiredIds.sort();
            if(array1.length === array2.length && array1.every(function(value, index) {
              return value === array2[index]
            }))
            {
              dataLogger.setLoggedEntities();
            }
          }
        }

        if(entId === loggerEntId)
        {
          dataLogger.logEntity = Qt.binding(function(){
            return VeinEntity.getEntity("_BinaryLoggingSystem");
          });
          guiLoader.active = true;
        }
      }
    }
  }

  Component {
    id: settingsComp
    LoggerSettings {
      id: settings
      logEntity: dataLogger.logEntity
      anchors.fill: parent
    }
  }

  Loader {
    id: guiLoader
    sourceComponent: settingsComp
    active: false
    anchors.fill: parent
  }
}
