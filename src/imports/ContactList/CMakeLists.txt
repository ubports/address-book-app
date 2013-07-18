set(CONTACT_LIST_QMLS
    ContactList.qml
    ContactListPage.qml
    FavoriteList.qml
)

install(FILES ${CONTACT_LIST_QMLS}
    DESTINATION ${ADDRESS_BOOK_APP_DIR}/imports/ContactList
)

# make the files visible on qtcreator
add_custom_target(contact_list_QmlFiles ALL SOURCES ${CONTACT_LIST_QMLS})
