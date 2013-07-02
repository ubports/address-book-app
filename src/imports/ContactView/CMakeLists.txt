set(CONTACT_VIEW_QMLS
    ContactDetailAddress.qml
    ContactDetailAvatar.qml
    ContactDetailEditor.qml
    ContactDetailEditorText.qml
    ContactDetailEmails.qml
    ContactDetailFavorite.qml
    ContactDetailGroupBase.qml
    ContactDetailGroupWithAction.qml
    ContactDetailItem.qml
    ContactDetailName.qml
    ContactDetailOnlineAccounts.qml
    ContactDetailPhoneNumbers.qml
    ContactDetailView.qml
    ContactDetailViewText.qml
    ContactDetailViewWithAction.qml
    ContactEditor.qml
    ContactHeader.qml
)

install(FILES ${CONTACT_VIEW_QMLS}
    DESTINATION ${ADDRESS_BOOK_APP_DIR}/imports/ContactView
)

# make the files visible on qtcreator
add_custom_target(contact_view_QmlFiles ALL SOURCES ${CONTACT_VIEW_QMLS})

