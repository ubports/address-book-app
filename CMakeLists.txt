project(address-book-app)
cmake_minimum_required(VERSION 2.8.9)
set(CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake)

# Find includes in corresponding build directories
set(CMAKE_INCLUDE_CURRENT_DIR ON)

# Instruct CMake to run moc automatically when needed.
set(CMAKE_AUTOMOC ON)
set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -DQT_QML_DEBUG")

# Standard install paths
include(GNUInstallDirs)
include(autopilot)

find_package(Qt5Qml)
find_package(Qt5Quick)
find_package(Qt5DBus)
find_package(PkgConfig REQUIRED)

pkg_check_modules(QOfono qofono-qt5)

find_program(INTLTOOL_MERGE intltool-merge)
find_program(INTLTOOL_EXTRACT intltool-extract)
find_program(DBUS_RUNNER dbus-test-runner)

if(NOT INTLTOOL_MERGE)
    message(FATAL_ERROR "intltool-merge not found. Try install intltool package;")
endif()
if(NOT INTLTOOL_EXTRACT)
    message(FATAL_ERROR "intltool-extract not found. Try install intltool package;")
endif()

set(ADDRESS_BOOK_APP_DIR ${CMAKE_INSTALL_DATADIR}/address-book-app)
set(ADDRESS_BOOK_APP_FULL_DIR ${CMAKE_INSTALL_FULL_DATADIR}/address-book-app)
set(ADDRESS_BOOK_APP_NAME "Address Book")
set(DESKTOP_FILE address-book-app.desktop)
set(API_VERSION 0.1)

# for dh_translations to extract the domain
# (regarding syntax consistency, see http://pad.lv/1181187)
set(GETTEXT_PACKAGE "address-book-app")

option(INSTALL_TESTS "Install the tests on make install" on)
option(INSTALL_COMPONENTS "Install the Ubuntu contact components" on)
option(CLICK_MODE "Installs to a contained location" off)
option(RUN_TESTS_OFFSCREEN "Run qml tests with offscreen option enabled" on)

# Tests
enable_testing()

# components PATH
if(CLICK_MODE)
    set(QT_IMPORTS_DIR "${ADDRESS_BOOK_APP_DIR}/imports/")
else()
    execute_process(
        COMMAND qmake -query QT_INSTALL_QML
        OUTPUT_VARIABLE QT_IMPORTS_DIR
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )
endif()
if(CLICK_MODE)
    set(CLICK_MODE_ENABLED 1)
    set(CMAKE_INSTALL_PREFIX /)
    set(CMAKE_INSTALL_BINDIR /)
    set(CLICK_TAG click)
    set(ADDRESS_BOOK_APP_BINDIR ".")
    set(QT_EXTRA_IMPORTS_DIR ${QT_IMPORTS_DIR})
    set(INSTALL_TESTS off)
else(CLICK_MODE)
    set(CLICK_MODE_ENABLED 0)
    set(ADDRESS_BOOK_APP_BINDIR ${CMAKE_INSTALL_FULL_BINDIR})
    set(QT_EXTRA_IMPORTS_DIR "")
endif(CLICK_MODE)

set(DESKTOP_EXEC "${ADDRESS_BOOK_APP_BINDIR}/address-book-app")
set(QMLPLUGIN_INSTALL_PREFIX "${QT_IMPORTS_DIR}/Ubuntu/Contacts.${API_VERSION}/")
set(ADDRESS_BOOK_QMLPLUGIN_INSTALL_PREFIX "${QT_IMPORTS_DIR}/Ubuntu/AddressBook/")
set(ADDRESS_BOOK_APP_DESKTOP_FILE address-book-app.desktop)
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11 -Wall")

add_subdirectory(data)
add_subdirectory(src)
add_subdirectory(po)
add_subdirectory(tests)
add_subdirectory(click)

# uninstall target
configure_file("${CMAKE_CURRENT_SOURCE_DIR}/cmake_uninstall.cmake.in"
               "${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake"
               IMMEDIATE @ONLY)
add_custom_target(uninstall "${CMAKE_COMMAND}"
                  -P "${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake")

# config file
configure_file("${CMAKE_CURRENT_SOURCE_DIR}/config.h.in"
               "${CMAKE_CURRENT_BINARY_DIR}/config.h"
               IMMEDIATE @ONLY)
