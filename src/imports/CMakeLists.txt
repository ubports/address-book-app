set(ADDRESS_BOOK_APP_QMLS
    ContactList.js
    ContactList.qml
    main.qml
)

install(FILES ${ADDRESS_BOOK_APP_QMLS}
    DESTINATION ${ADDRESS_BOOK_APP_DIR}/imports
)

add_subdirectory(ContactView)
