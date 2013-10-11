project(address-book-main-app)

set(ADDRESS_BOOK_APP_BIN address-book-app)

include_directories(
    ${CMAKE_BINARY_DIR}
)


set(ADDRESS_BOOK_APP_SRCS
    addressbookapp.h
    addressbookapp.cpp
    imagescalethread.h
    imagescalethread.cpp
    main.cpp
)

add_executable(${ADDRESS_BOOK_APP_BIN}
    ${ADDRESS_BOOK_APP_SRCS}
)

qt5_use_modules(${ADDRESS_BOOK_APP_BIN} Gui Core Qml Quick)

install(TARGETS ${ADDRESS_BOOK_APP_BIN}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

