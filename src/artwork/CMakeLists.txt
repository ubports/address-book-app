set(ADDRESS_BOOK_APP_ICON
    address-book-app.png
)

set(ADDRESS_BOOK_APP_ARTWORK
    action-list.png
    add-detail.png
    add.png
    avatar-default.png
    combo-indicator.png
    contact-call.png
    contact-email.png
    contact-location.png
    contact-message.png
    delete.png
    edit.png
    edit-remove.png
    favorite-selected.png
    favorite-unselected.png
    protocol-aim.png
    protocol-facebook.png
    protocol-icq.png
    protocol-irc.png
    protocol-jabber.png
    protocol-msn.png
    protocol-other.png
    protocol-qq.png
    protocol-skype.png
    protocol-yahoo.png
    save.png
    settings.png
    vertical-div.png
)

install(FILES ${ADDRESS_BOOK_APP_ICON}
    DESTINATION ${CMAKE_INSTALL_DATADIR}/icons/hicolor/48x48/apps
)

install(FILES ${ADDRESS_BOOK_APP_ARTWORK}
    DESTINATION ${ADDRESS_BOOK_APP_DIR}/artwork
)




