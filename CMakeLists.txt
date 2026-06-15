cmake_minimum_required(VERSION 3.16)

project(SmartPedalApp VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 6.8 REQUIRED COMPONENTS Quick Qml SerialPort QuickControls2)

qt_standard_project_setup(REQUIRES 6.8)

qt_add_executable(appSmartPedalApp
    source/main.cpp
    source/serialcomm.h
    source/serialcomm.cpp
    source/Filters.cpp
    source/Filters.h
    source/bibs.h
)

qt_add_qml_module(appSmartPedalApp
    URI SmartPedalApp
    VERSION 1.0
    QML_FILES
        ui/Main.qml
        ui/Settings.qml
        ui/Presets.qml
        ui/Connection.qml
)

set_target_properties(appSmartPedalApp PROPERTIES
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(appSmartPedalApp
    PRIVATE Qt6::Quick Qt6::Qml Qt6::SerialPort Qt6::QuickControls2
)

include(GNUInstallDirs)
install(TARGETS appSmartPedalApp
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
