set(CONTACT_COMPONENTS_QMLS
    ContactList.js
    ContactAvatar.qml
    ContactDelegate.qml
    ContactDetailOnlineAccountTypeModel.qml
    ContactDetailPhoneNumberTypeModel.qml
    ContactDetailPickerPhoneNumberDelegate.qml
    ContactFetch.qml
    ContactListView.qml
    Contacts.js
    ContactSearchListView.qml
    ContactSimpleListView.qml
    DialogButtons.qml
    FastScroll.qml
    FastScroll.js
    MultipleSelectionListView.qml
    MultipleSelectionVisualModel.qml
    qmldir
)

# make the files visible on qtcreator
add_custom_target(contact_components_QmlFiles ALL SOURCES ${CONTACT_COMPONENTS_QMLS})

if(INSTALL_COMPONENTS)
    install(FILES ${CONTACT_COMPONENTS_QMLS} DESTINATION ${QMLPLUGIN_INSTALL_PREFIX})
endif()
