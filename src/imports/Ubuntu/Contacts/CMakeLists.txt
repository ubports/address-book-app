set(CONTACT_COMPONENTS_QMLS
    ContactList.js
    ContactDelegate.qml
    ContactDetailOnlineAccountTypeModel.qml
    ContactDetailPhoneNumberTypeModel.qml
    ContactDetailPickerDelegate.qml
    ContactDetailPickerPhoneNumberDelegate.qml
    ContactListView.qml
    Contacts.js
    ContactSearchListView.qml
    ContactSimpleListView.qml
    DialogButtons.qml
    FavoriteDelegate.qml
    MultipleSelectionListView.qml
    MultipleSelectionVisualModel.qml
    qmldir
)

install(FILES ${CONTACT_COMPONENTS_QMLS}
    DESTINATION ${ADDRESS_BOOK_APP_DIR}/imports/Components
)

# make the files visible on qtcreator
add_custom_target(contact_components_QmlFiles ALL SOURCES ${CONTACT_COMPONENTS_QMLS})
install(FILES ${CONTACT_COMPONENTS_QMLS} DESTINATION ${QMLPLUGIN_INSTALL_PREFIX})

