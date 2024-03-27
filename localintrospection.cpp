#include "localintrospection.h"

#include <ve_commandevent.h>
#include <vcmp_componentdata.h>
#include <vcmp_entitydata.h>
#include <vcmp_introspectiondata.h>
#include <vs_veinhash.h>
#include <entitycomponentmap.h>

#include <QJsonArray>

LocalIntrospection::LocalIntrospection(VeinStorage::VeinHash *t_storage, QObject *t_parent) :
  VeinEvent::EventSystem(t_parent),
  m_storage(t_storage)
{

}

void LocalIntrospection::processEvent(QEvent *t_event)
{
  using namespace VeinEvent;
  using namespace VeinComponent;

  if(t_event->type()==CommandEvent::getQEventType())
  {
    CommandEvent *cEvent = nullptr;
    EventData *evData = nullptr;
    cEvent = static_cast<CommandEvent *>(t_event);
    Q_ASSERT(cEvent != nullptr);
    evData = cEvent->eventData();
    Q_ASSERT(evData != nullptr);

    if(evData->entityId() == 200000)  //binary-logger id
    {
      evData->setEventOrigin(VeinEvent::EventData::EventOrigin::EO_LOCAL);
      evData->setEventTarget(VeinEvent::EventData::EventTarget::ET_LOCAL);
      if(cEvent->eventSubtype() == CommandEvent::EventSubtype::TRANSACTION)
      {
        if(evData->type() == ComponentData::dataType())
        {
          ComponentData *cData=nullptr;
          cData = static_cast<ComponentData *>(evData);
          Q_ASSERT(cData != nullptr);
          if(cData->eventCommand() == ComponentData::Command::CCMD_FETCH)
          {
            //validate the fetch event
            cEvent->setEventSubtype(VeinEvent::CommandEvent::EventSubtype::NOTIFICATION);
          }
        }
        else if(evData->type() == EntityData::dataType())
        {
          EntityData *eData=nullptr;
          eData = static_cast<EntityData *>(evData);
          Q_ASSERT(eData != nullptr);
          if(eData->eventCommand() == EntityData::Command::ECMD_SUBSCRIBE)
          {
            //validate the subscribe event
            cEvent->setEventSubtype(VeinEvent::CommandEvent::EventSubtype::NOTIFICATION);
          }
        }
      }

      if(cEvent->eventSubtype() == CommandEvent::EventSubtype::NOTIFICATION)
      {
        if(evData->type() == EntityData::dataType())
        {
          EntityData *eData=nullptr;
          eData = static_cast<EntityData *>(evData);
          Q_ASSERT(eData != nullptr);

          if(eData->eventCommand() == EntityData::Command::ECMD_SUBSCRIBE)
          {
            qDebug() << "Processing command event:" << cEvent << "with command ECMD_SUBSCRIBE, entityId:" << eData->entityId();
            IntrospectionData *newData=nullptr;
            QJsonObject tmpObject;

            tmpObject = getJsonIntrospection(eData->entityId());
            if(tmpObject.isEmpty() == false)
            {
              newData = new IntrospectionData();
              newData->setEntityId(eData->entityId());
              newData->setJsonData(tmpObject);
              CommandEvent *newEvent = new CommandEvent(CommandEvent::EventSubtype::NOTIFICATION, newData);
              /// @note sets the peer id to be the sender peer id, used for unicasting the message
              newEvent->setPeerId(cEvent->peerId());

              qDebug() << "Sending introspection event:" << newEvent;

              emit sigSendEvent(newEvent);
              cEvent->accept();
            }
            else
            {
              qWarning() << "Empty introspection object:" << tmpObject;
              Q_ASSERT(false);
            }
          }
        }
        else if(evData->type() == ComponentData::dataType())
        {
          ComponentData *cData=nullptr;
          cData = static_cast<ComponentData *>(evData);
          Q_ASSERT(cData != nullptr);

          if(cData->eventCommand() == VeinComponent::ComponentData::Command::CCMD_FETCH)
          {
            //qDebug() << "Processing command event:" << cEvent << "with command CCMD_FETCH, entityId:" << cData->entityId() << "componentName:" << cData->componentName();

            cData->setNewValue(m_storage->getStoredValue(cData->entityId(), cData->componentName()));
          }
        }
      }
    }
  }
}

QJsonObject LocalIntrospection::getJsonIntrospection(int t_entityId) const
{
  QJsonObject retVal;

  if(m_storage->hasEntity(t_entityId))
  {
    const QStringList keyList = m_storage->getEntityComponents(t_entityId);
    retVal.insert(QString("components"), QJsonArray::fromStringList(keyList));
  }

  return retVal;
}
