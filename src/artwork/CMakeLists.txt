set(ADDRESS_BOOK_APP_ICON
    address-book-app.png
)

set(ADDRESS_BOOK_COMPONENTS_ARTWORK
    contact-default@27.png
)

set(ADDRESS_BOOK_APP_ARTWORK
    action-list.png
    add-detail.svg
    add.png
    address-book-app.png
    birthday-cake.svg
    combo-indicator.png
    contact-call.svg
    contact-default-profile.png
    contact-email.svg
    contact-location.png
    contact-message.svg
    delete.png
    edit.png
    edit-remove.png
    favorite-selected.svg
    favorite-unselected.svg
    import-image.svg
    new-contact.svg
    protocol-aim.svg
    protocol-facebook.svg
    protocol-icq.svg
    protocol-jabber.svg
    protocol-msn.svg
    protocol-other.svg
    protocol-qq.svg
    protocol-skype.svg
    protocol-twitter.svg
    protocol-yahoo.svg
    save.png
    select.png
    settings.png
    vertical-div.png
)

install(FILES ${ADDRESS_BOOK_APP_ICON}
    DESTINATION ${CMAKE_INSTALL_DATADIR}/icons/hicolor/48x48/apps
)

install(FILES ${ADDRESS_BOOK_APP_ARTWORK}
    DESTINATION ${ADDRESS_BOOK_APP_DIR}/artwork
)

install(FILES ${ADDRESS_BOOK_COMPONENTS_ARTWORK}
    DESTINATION ${QMLPLUGIN_INSTALL_PREFIX}/artwork
)




