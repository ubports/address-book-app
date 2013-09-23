set(CONTACT_EDIT_QMLS
    ContactDetailAddressesEditor.qml
    ContactDetailAvatarEditor.qml
    ContactDetailEmailsEditor.qml
    ContactDetailGroupWithTypeEditor.qml
    ContactDetailNameEditor.qml
    ContactDetailOnlineAccountsEditor.qml
    ContactDetailPhoneNumbersEditor.qml
    ContactDetailWithTypeEditor.qml
    ContactEditor.qml
    ContactFetchError.qml
    EditToolbar.qml
    KeyboardRectangle.qml
    StandardAnimation.qml
    TextInputDetail.qml
    ValueSelector.qml
)

install(FILES ${CONTACT_EDIT_QMLS}
    DESTINATION ${ADDRESS_BOOK_APP_DIR}/imports/ContactEdit
)

# make the files visible on qtcreator
add_custom_target(contact_edit_QmlFiles ALL SOURCES ${CONTACT_EDIT_QMLS})
