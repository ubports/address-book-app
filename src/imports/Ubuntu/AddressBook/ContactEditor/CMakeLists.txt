set(AB_CONTACT_EDITOR_QMLS
    AvatarImport.qml
    CancelEditDialog.qml
    ComboButtonAddField.qml
    ContactDetailAddressesEditor.qml
    ContactDetailAvatarEditor.qml
    ContactDetailEmailsEditor.qml
    ContactDetailGroupWithTypeEditor.qml
    ContactDetailNameEditor.qml
    ContactDetailOnlineAccountsEditor.qml
    ContactDetailOrganizationsEditor.qml
    ContactDetailPhoneNumbersEditor.qml
    ContactDetailSyncTargetEditor.qml
    ContactDetailWithTypeEditor.qml
    ContactEditorPage.qml
    TextInputDetail.qml
    ValueSelector.qml
    qmldir
)

# make the files visible on qtcreator
add_custom_target(contact_editor_QmlFiles ALL SOURCES ${AB_CONTACT_EDITOR_QMLS})

if(INSTALL_COMPONENTS)
    install(FILES ${AB_CONTACT_EDITOR_QMLS} DESTINATION ${ADDRESS_BOOK_QMLPLUGIN_INSTALL_PREFIX}/ContactEditor)
endif()

#copy qml files to build dir to make it possible to run without install
foreach(QML_FILE ${AB_CONTACT_EDITOR_QMLS})
  add_custom_command(TARGET contact_editor_QmlFiles PRE_BUILD
                     COMMAND ${CMAKE_COMMAND} -E
                         copy ${CMAKE_CURRENT_SOURCE_DIR}/${QML_FILE} ${CMAKE_CURRENT_BINARY_DIR}/)
endforeach()

if (NOT ${CMAKE_CURRENT_BINARY_DIR} STREQUAL ${CMAKE_CURRENT_SOURCE_DIR})
    add_dependencies(copyqmlfiles contact_editor_QmlFiles)
endif()

