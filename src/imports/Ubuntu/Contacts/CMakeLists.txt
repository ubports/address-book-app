set(CONTACT_COMPONENTS_PLUGIN "ubuntu-contacts-qml")

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
    ContactSimpleListView.qml
    DialogButtons.qml
    FastScroll.qml
    FastScroll.js
    ListItemWithActions.qml
    MostCalledModel.qml
    MultipleSelectionListView.qml
    MultipleSelectionVisualModel.qml
    qmldir
)

set(CONTACT_COMPONENTS_SRC
    mostcalledproxymodel.h
    mostcalledproxymodel.cpp
    plugin.h
    plugin.cpp
)

add_library(${CONTACT_COMPONENTS_PLUGIN} MODULE
    ${CONTACT_COMPONENTS_SRC}
)    

qt5_use_modules(${CONTACT_COMPONENTS_PLUGIN} Core Contacts Qml Quick)

# make the files visible on qtcreator
add_custom_target(contact_components_QmlFiles ALL SOURCES ${CONTACT_COMPONENTS_QMLS})

if(INSTALL_COMPONENTS)
    install(FILES ${CONTACT_COMPONENTS_QMLS} DESTINATION ${QMLPLUGIN_INSTALL_PREFIX})
    install(TARGETS ${CONTACT_COMPONENTS_PLUGIN} DESTINATION ${QMLPLUGIN_INSTALL_PREFIX})
endif()
