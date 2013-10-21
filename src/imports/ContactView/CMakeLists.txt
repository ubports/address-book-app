set(CONTACT_VIEW_QMLS
    ActionButton.qml
    BasicFieldView.qml
    ContactDetailAddressesView.qml
    ContactDetailAvatarView.qml
    ContactDetailEmailsView.qml
    ContactDetailFavoriteView.qml
    ContactDetailGroupWithTypeView.qml
    ContactDetailNameView.qml
    ContactDetailOnlineAccountsView.qml
    ContactDetailOrganizationsView.qml
    ContactDetailPhoneNumbersView.qml
    ContactDetailPhoneNumberView.qml
    ContactDetailWithTypeView.qml
    ContactHeaderView.qml
    ContactView.qml
)

install(FILES ${CONTACT_VIEW_QMLS}
    DESTINATION ${ADDRESS_BOOK_APP_DIR}/imports/ContactView
)

# make the files visible on qtcreator
add_custom_target(contact_view_QmlFiles ALL SOURCES ${CONTACT_VIEW_QMLS})
