set(CONTACT_COMPONENTS_QMLS
    OrganicView.qml
)

install(FILES ${CONTACT_COMPONENTS_QMLS}
    DESTINATION ${ADDRESS_BOOK_APP_DIR}/imports/Components
)

# make the files visible on qtcreator
add_custom_target(contact_components_QmlFiles ALL SOURCES ${CONTACT_COMPONENTS_QMLS})

