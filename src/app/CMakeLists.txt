project(address-book-main-app)

set(ADDRESS_BOOK_APP_BIN address-book-app)

include_directories(
    ${CMAKE_BINARY_DIR}
)


set(ADDRESS_BOOK_APP_SRCS
    addressbookapp.h
    addressbookapp.cpp
    addressbookappdbus.h
    addressbookappdbus.cpp
    imagescalethread.h
    imagescalethread.cpp
    main.cpp
)

qt5_add_dbus_adaptor(ADDRESS_BOOK_APP_SRCS AddressBookApp.xml addressbookappdbus.h  AddressBookAppDBus)

add_executable(${ADDRESS_BOOK_APP_BIN}
    ${ADDRESS_BOOK_APP_SRCS}
)

qt5_use_modules(${ADDRESS_BOOK_APP_BIN} Gui Core Qml Quick DBus)

install(TARGETS ${ADDRESS_BOOK_APP_BIN}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

configure_file(com.canonical.AddressBookApp.service.in com.canonical.AddressBookApp.service)
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/com.canonical.AddressBookApp.service DESTINATION share/dbus-1/services)
