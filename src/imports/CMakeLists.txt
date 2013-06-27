set(ADDRESS_BOOK_APP_QMLS
    ContactEditor.qml
    ContactList.js
    ContactList.qml
    ContactSettings.qml
    main.qml
)

install(FILES ${ADDRESS_BOOK_APP_QMLS}
    DESTINATION ${ADDRESS_BOOK_APP_DIR}/imports
)
