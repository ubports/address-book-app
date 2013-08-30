project(address-book-app)
cmake_minimum_required(VERSION 2.8.9)
set(CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake/modules)

# Find includes in corresponding build directories
set(CMAKE_INCLUDE_CURRENT_DIR ON)

# Instruct CMake to run moc automatically when needed.
set(CMAKE_AUTOMOC ON)

# Standard install paths
include(GNUInstallDirs)

find_package(Qt5Qml)
find_package(Qt5Quick)
find_package(Qt5DBus)

set(ADDRESS_BOOK_APP_DIR ${CMAKE_INSTALL_DATADIR}/address-book-app)
set(ADDRESS_BOOK_APP_FULL_DIR ${CMAKE_INSTALL_FULL_DATADIR}/address-book-app)
set(ADDRESS_BOOK_APP_NAME "Address Book")
set(API_VERSION 0.1)

# for dh_translations to extract the domain
# (regarding syntax consistency, see http://pad.lv/1181187)
set (GETTEXT_PACKAGE "address-book-app")

# Tests
enable_testing()

add_subdirectory(data)
add_subdirectory(src)
add_subdirectory(po)
add_subdirectory(tests)

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
