set(CONTACT_SETTINGS_QMLS
    MyselfPhoneNumbersModel.qml
    SettingsPage.qml
)

install(FILES ${CONTACT_SETTINGS_QMLS}
    DESTINATION ${ADDRESS_BOOK_APP_DIR}/imports/Settings
)

# make the files visible on qtcreator
add_custom_target(contact_settings_QmlFiles ALL SOURCES ${CONTACT_SETTINGS_QMLS})
