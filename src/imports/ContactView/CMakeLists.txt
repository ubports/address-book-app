set(CONTACT_VIEW_QMLS
    ContactDetailSyncTargetView.qml
    ContactFetchError.qml
    ContactView.qml
)

install(FILES ${CONTACT_VIEW_QMLS}
    DESTINATION ${ADDRESS_BOOK_APP_DIR}/imports/ContactView
)

# make the files visible on qtcreator
add_custom_target(contact_view_QmlFiles ALL SOURCES ${CONTACT_VIEW_QMLS})
