set(AB_CONTACT_VIEW_QMLS
    ActionButton.qml
    BasicFieldView.qml
    ContactDetailAddressesView.qml
    ContactDetailAvatarView.qml
    ContactDetailEmailsView.qml
    ContactDetailGroupWithTypeView.qml
    ContactDetailNameView.qml
    ContactDetailOnlineAccountsView.qml
    ContactDetailOrganizationsView.qml
    ContactDetailPhoneNumbersView.qml
    ContactDetailPhoneNumberView.qml
    ContactDetailSyncTargetView.qml
    ContactDetailWithTypeView.qml
    ContactFetchError.qml
    #ContactHeaderView.qml
    ContactViewPage.qml
    qmldir
)

# make the files visible on qtcreator
add_custom_target(contact_view_QmlFiles ALL SOURCES ${AB_CONTACT_VIEW_QMLS})

if(INSTALL_COMPONENTS)
    install(FILES ${AB_CONTACT_VIEW_QMLS} DESTINATION ${ADDRESS_BOOK_QMLPLUGIN_INSTALL_PREFIX}/ContactView)
endif()

#copy qml files to build dir to make it possible to run without install
foreach(QML_FILE ${AB_CONTACT_VIEW_QMLS})
  add_custom_command(TARGET contact_view_QmlFiles PRE_BUILD
                     COMMAND ${CMAKE_COMMAND} -E
                         copy ${CMAKE_CURRENT_SOURCE_DIR}/${QML_FILE} ${CMAKE_CURRENT_BINARY_DIR}/)
endforeach()

if (NOT ${CMAKE_CURRENT_BINARY_DIR} STREQUAL ${CMAKE_CURRENT_SOURCE_DIR})
    add_dependencies(copyqmlfiles contact_view_QmlFiles)
endif()
