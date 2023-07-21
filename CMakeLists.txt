cmake_minimum_required(VERSION 3.1)

project(vf-database-recorder LANGUAGES CXX)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

set(VfRecorder_VERSION_MAJOR "0")
set(VfRecorder_VERSION_MINOR "0")
set(VfRecorder_VERSION_PATCH "1")
set(PROJECT_VERSION "${VfRecorder_VERSION_MAJOR}.${VfRecorder_VERSION_MINOR}.${VfRecorder_VERSION_PATCH}")

include(FeatureSummary)
include(GNUInstallDirs)

find_package(Qt5 COMPONENTS Quick Core Qml Sql Network CONFIG REQUIRED)
find_package(VfLogger REQUIRED)

file(GLOB SOURCES 
    ${PROJECT_SOURCE_DIR}/*.cpp
    )

file(GLOB HEADER
    ${PROJECT_SOURCE_DIR}/*.h
    )

file(GLOB RESOURCES 
    ${PROJECT_SOURCE_DIR}/*.qrc
    )

add_executable(VfRecorder
    ${SOURCES}
    ${HEADER}
    ${RESOURCES}
    )

target_link_libraries(VfRecorder 
    PRIVATE
    Qt5::Core
    Qt5::Qml
    Qt5::Sql
    Qt5::Network
    Qt5::Quick
    Zera::VfEvent
    Zera::VfComponent
    Zera::VfStorageHash
    Zera::VfNet2
    Zera::VfQml
    VeinMeta::VfLogger
    )

target_include_directories(VfRecorder 
    PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
    )

install(TARGETS VfRecorder
    EXPORT VfRecorderExport
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    )

feature_summary(WHAT ALL FATAL_ON_MISSING_REQUIRED_PACKAGES)
