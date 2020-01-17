cmake_minimum_required(VERSION 3.1)

#set project name and language
project(vf-database-recorder LANGUAGES CXX)

#Automoc and RCC ON. Needed in QT projects
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
#C++ 11 Flag
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

#Set project Version
set(VfRecorder_VERSION_MAJOR "0")
set(VfRecorder_VERSION_MINOR "0")
set(VfRecorder_VERSION_PATCH "1")

set(PROJECT_VERSION "${VfRecorder_VERSION_MAJOR}.${VfRecorder_VERSION_MINOR}.${VfRecorder_VERSION_PATCH}")

#Adding cmake functions like feature_summary()
include(FeatureSummary)
include(GNUInstallDirs)

#Find dependecies
find_package(Qt5 COMPONENTS Quick Core Qml Sql Network CONFIG REQUIRED)
find_package(VfEvent REQUIRED)
find_package(VfHelpers REQUIRED)
find_package(VfComponent REQUIRED)
find_package(VfStorageHash REQUIRED)
find_package(VfQml REQUIRED)
find_package(VfNet2 REQUIRED)
find_package(VfLogger REQUIRED)


#sum up project Files 
file(GLOB SOURCES 
    ${PROJECT_SOURCE_DIR}/*.cpp
    )

file(GLOB HEADER
    ${PROJECT_SOURCE_DIR}/*.h
    )

file(GLOB RESOURCES 
    ${PROJECT_SOURCE_DIR}/*.qrc
    )

#create executable
add_executable(VfRecorder
    ${SOURCES}
    ${HEADER}
    ${RESOURCES}
    )


#link dependencies
target_link_libraries(VfRecorder 
    PRIVATE
    Qt5::Core
    Qt5::Qml
    Qt5::Sql
    Qt5::Network
    Qt5::Quick
    VeinMeta::VfEvent
    VeinMeta::VfHelpers
    VeinMeta::VfComponent
    VeinMeta::VfStorageHash
    VeinMeta::VfQml
    VeinMeta::VfNet2
    VeinMeta::VfLogger
    )	




# announce headers - target perspective
target_include_directories(VfRecorder 
    PUBLIC
    $<BUILD_INTERFACE:${MY_LIBRARY_SOURCE_DIR}/include>
    $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/VfRecorder>
    PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}
    )

#install VfRecorder to bin 
install(TARGETS VfRecorder
    EXPORT VfRecorderExport
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    )

# spawn out some info on configuration
feature_summary(WHAT ALL FATAL_ON_MISSING_REQUIRED_PACKAGES)







