set(CONTACT_COMPONENTS_PLUGIN "ubuntu-contacts-qml")

set(CONTACT_COMPONENTS_QMLS
    ActionButton.qml
    ContactAvatar.qml
    ContactDelegate.qml
    ContactDetailOnlineAccountTypeModel.qml
    ContactDetailPhoneNumberTypeModel.qml
    ContactDetailPickerPhoneNumberDelegate.qml
    ContactFetch.qml
    ContactList.js
    ContactListButtonDelegate.qml
    ContactListModel.qml
    ContactListView.qml
    ContactSimpleListView.qml
    Contacts.js
    FastScroll.js
    FastScroll.qml
    ListItemWithActionsCheckBox.qml
    ListItemWithActions.qml
    MultipleSelectionListView.qml
    MultipleSelectionVisualModel.qml
    Ofono.qml
    OnlineAccountsDummy.qml
    OnlineAccountsHelper.qml
    PageWithBottomEdge.qml
    qmldir
    SectionDelegate.qml
    SIMList.qml
    SIMCardImportPage.qml
    SubtitledWithColors.qml
    Triangle.qml
    VCardParser.qml
    ContactImportPage.qml
)

set(CONTACT_COMPONENTS_SRC
    contacts.h
    contacts.cpp
    imagescalethread.h
    imagescalethread.cpp
    plugin.h
    plugin.cpp
    simcardcontacts.h
    simcardcontacts.cpp
)

include_directories(
    ${CMAKE_BINARY_DIR}
    ${QOfono_INCLUDE_DIRS}
)

add_library(${CONTACT_COMPONENTS_PLUGIN} SHARED
    ${CONTACT_COMPONENTS_SRC}
)

target_link_libraries(${CONTACT_COMPONENTS_PLUGIN}
    ${QOfono_LIBRARIES}
    Qt5::Core
    Qt5::Contacts
    Qt5::Qml
    Qt5::Quick
    Qt5::DBus
)

# make the files visible on qtcreator
add_custom_target(contact_components_QmlFiles ALL SOURCES ${CONTACT_COMPONENTS_QMLS})

if(INSTALL_COMPONENTS)
    install(FILES ${CONTACT_COMPONENTS_QMLS} DESTINATION ${QMLPLUGIN_INSTALL_PREFIX})
    install(TARGETS ${CONTACT_COMPONENTS_PLUGIN} DESTINATION ${QMLPLUGIN_INSTALL_PREFIX})
endif()


#copy qml files to build dir to make it possible to run without install
foreach(QML_FILE ${CONTACT_COMPONENTS_QMLS})
  add_custom_command(TARGET contact_components_QmlFiles PRE_BUILD
                     COMMAND ${CMAKE_COMMAND} -E
                         copy ${CMAKE_CURRENT_SOURCE_DIR}/${QML_FILE} ${CMAKE_CURRENT_BINARY_DIR}/)
endforeach()

if (NOT ${CMAKE_CURRENT_BINARY_DIR} STREQUAL ${CMAKE_CURRENT_SOURCE_DIR})
    add_dependencies(copyqmlfiles contact_components_QmlFiles)
endif()

