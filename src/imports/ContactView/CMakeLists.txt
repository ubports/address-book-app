set(CONTACT_VIEW_QMLS
    ContactDetailAvatar.qml
    ContactDetailEditor.qml
    ContactDetailEditorText.qml
    ContactDetailFavorite.qml
    ContactDetailGroup.qml
    ContactDetailItem.qml
    ContactDetailName.qml
    ContactDetailView.qml
    ContactDetailViewText.qml
    ContactDetailViewWithAction.qml
    ContactEditor.qml
    ContactHeader.qml
    DetailTypeUtilities.js
)

install(FILES ${CONTACT_VIEW_QMLS}
    DESTINATION ${ADDRESS_BOOK_APP_DIR}/imports/ContactView
)

