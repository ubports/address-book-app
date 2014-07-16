set(CONTACT_SHARE_QMLS
    ContactSharePage.qml
)

install(FILES ${CONTACT_SHARE_QMLS}
    DESTINATION ${ADDRESS_BOOK_APP_DIR}/imports/ContactShare
)

# make the files visible on qtcreator
add_custom_target(contact_share_QmlFiles ALL SOURCES ${CONTACT_SHARE_QMLS})
