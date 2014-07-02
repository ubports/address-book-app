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


#copy qml files to build dir to make it possible to run without install

add_custom_target(copy_qml)
foreach(QML_FILE ${CONTACT_COMPONENTS_QMLS})
  add_custom_command(TARGET copy_qml PRE_BUILD
                     COMMAND ${CMAKE_COMMAND} -E
                         copy ${CMAKE_CURRENT_SOURCE_DIR}/${QML_FILE} ${CMAKE_CURRENT_BINARY_DIR}/)
endforeach()

if (NOT ${CMAKE_CURRENT_BINARY_DIR} STREQUAL ${CMAKE_CURRENT_SOURCE_DIR})
    add_dependencies(${CONTACT_COMPONENTS_PLUGIN} copy_qml)
endif()
