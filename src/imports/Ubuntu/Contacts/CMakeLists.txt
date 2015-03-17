set(CONTACT_COMPONENTS_PLUGIN "ubuntu-contacts-qml")

set(CONTACT_COMPONENTS_QMLS
    ActionButton.qml
    BasicFieldView.qml
    ContactAvatar.qml
    ContactDelegate.qml
    ContactDetailAddressesView.qml
    ContactDetailAvatarView.qml
    ContactDetailBase.qml
    ContactDetailEmailsView.qml
    ContactDetailGroupBase.qml
    ContactDetailGroupWithTypeBase.qml
    ContactDetailGroupWithTypeView.qml
    ContactDetailOnlineAccountsView.qml
    ContactDetailOnlineAccountTypeModel.qml
    ContactDetailOrganizationsView.qml
    ContactDetailPhoneNumbersView.qml
    ContactDetailPhoneNumberTypeModel.qml
    ContactDetailPhoneNumberView.qml
    ContactDetailPickerPhoneNumberDelegate.qml
    ContactDetailWithTypeView.qml
    ContactFetch.qml
    ContactList.js
    ContactListButtonDelegate.qml
    ContactListModel.qml
    ContactListView.qml
    ContactPreviewPage.qml
    ContactSimpleListView.qml
    Contacts.js
    FastScroll.js
    FastScroll.qml
    ListItemWithActionsCheckBox.qml
    ListItemWithActions.qml
    MostCalledList.qml
    MostCalledModel.qml
    MultipleSelectionListView.qml
    MultipleSelectionVisualModel.qml
    OnlineAccountsDummy.qml
    OnlineAccountsHelper.qml
    PageWithBottomEdge.qml
    qmldir
    SectionDelegate.qml
    SIMCardImportPage.qml
    SubtitledWithColors.qml
    VCardParser.qml
)

set(CONTACT_COMPONENTS_SRC
    contacts.h
    contacts.cpp
    mostcalledproxymodel.h
    mostcalledproxymodel.cpp
    plugin.h
    plugin.cpp
    simcardcontacts.h
    simcardcontacts.cpp
)

include_directories(
    ${QOfono_INCLUDE_DIRS}
)

add_library(${CONTACT_COMPONENTS_PLUGIN} MODULE
    ${CONTACT_COMPONENTS_SRC}
)

target_link_libraries(${CONTACT_COMPONENTS_PLUGIN}
    ${QOfono_LIBRARIES}
)

qt5_use_modules(${CONTACT_COMPONENTS_PLUGIN} Core Contacts Qml Quick DBus)

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

