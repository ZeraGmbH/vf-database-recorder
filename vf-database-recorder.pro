TEMPLATE = app
TARGET = vf-database-recorder

#dependencies
VEIN_DEP_EVENT = 1
VEIN_DEP_COMP = 1
VEIN_DEP_PROTOBUF = 1
VEIN_DEP_NET = 1
VEIN_DEP_TCP = 1
VEIN_DEP_HELPER = 1
VEIN_DEP_HASH = 1
VEIN_DEP_QML = 1
VEIN_DEP_BINARY_LOGGER = 1

exists( ../../vein-framework.pri ) {
  include(../../vein-framework.pri)
}

QT += qml quick sql network

CONFIG += c++11

SOURCES += main.cpp \
    localintrospection.cpp

RESOURCES += qml.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Default rules for deployment.
include(deployment.pri)

HEADERS += \
    localintrospection.h
