set(CONTACT_LIST_QMLS
    ContactListPage.qml
    ContactExporter.qml
    OnlineAccountsMessage.qml
    PageWithBottomEdge.qml
    VCardImportDialog.qml
)

install(FILES ${CONTACT_LIST_QMLS}
    DESTINATION ${ADDRESS_BOOK_APP_DIR}/imports/ContactList
)

# make the files visible on qtcreator
add_custom_target(contact_list_QmlFiles ALL SOURCES ${CONTACT_LIST_QMLS})
