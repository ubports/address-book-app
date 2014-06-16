set(CONTACT_COMMON_QMLS
    ContactDetailBase.qml
    ContactDetailItem.qml
    ContactDetailGroupBase.qml
    ContactDetailGroupWithTypeBase.qml
    KeyboardRectangle.qml
    RemoveContactsDialog.qml
    StandardAnimation.qml
)

install(FILES ${CONTACT_COMMON_QMLS}
    DESTINATION ${ADDRESS_BOOK_APP_DIR}/imports/Common
)

# make the files visible on qtcreator
add_custom_target(contact_common_QmlFiles ALL SOURCES ${CONTACT_COMMON_QMLS})

