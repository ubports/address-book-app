project(address-book-main-app)

set(ADDRESS_BOOK_APP_BIN address-book-app)

include_directories(
    ${CMAKE_BINARY_DIR}
    ${AccountsQt5_INCLUDE_DIRS}
)

set(ADDRESS_BOOK_APP_SRCS
    addressbookapp.h
    addressbookapp.cpp
    buteo-import.h
    buteo-import.cpp
    main.cpp
)

add_executable(${ADDRESS_BOOK_APP_BIN}
    ${ADDRESS_BOOK_APP_SRCS}
)

target_link_libraries(${ADDRESS_BOOK_APP_BIN}
    Qt5::Core
    Qt5::Gui
    Qt5::Qml
    Qt5::Quick
    Qt5::DBus
    Qt5::Contacts
    ${AccountsQt5_LIBRARIES}
)

install(TARGETS ${ADDRESS_BOOK_APP_BIN}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

