set(CONTACT_COMPONENTS_QMLS
    ContactDetailPickerDelegate.qml
    ContactDetailPickerPhoneNumberDelegate.qml
    ContactFavoriteDelegate.qml
    ContactFavoriteListView.qml
    ContactListView.qml
    ContactSimpleListView.qml
    OrganicView.qml
    qmldir
)

install(FILES ${CONTACT_COMPONENTS_QMLS}
    DESTINATION ${ADDRESS_BOOK_APP_DIR}/imports/Components
)

# make the files visible on qtcreator
add_custom_target(contact_components_QmlFiles ALL SOURCES ${CONTACT_COMPONENTS_QMLS})

execute_process(
    COMMAND qmake -query QT_INSTALL_QML
    OUTPUT_VARIABLE QT_IMPORTS_DIR
    OUTPUT_STRIP_TRAILING_WHITESPACE
)
set(QMLPLUGIN_INSTALL_PREFIX "${QT_IMPORTS_DIR}/Ubuntu/Contacts.${API_VERSION}/")
install(FILES ${CONTACT_COMPONENTS_QMLS} DESTINATION ${QMLPLUGIN_INSTALL_PREFIX})

