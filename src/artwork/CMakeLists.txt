set(ADDRESS_BOOK_APP_ICON
    address-book-app.png
)

set(ADDRESS_BOOK_APP_ARTWORK
    add.png
    avatar-default.png
    contact-call.png
    contact-email.png
    contact-location.png
    delete.png
    edit.png
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
    settings.png
)

install(FILES ${ADDRESS_BOOK_APP_ICON}
    DESTINATION ${CMAKE_INSTALL_DATADIR}/icons/hicolor/48x48/apps
)

install(FILES ${ADDRESS_BOOK_APP_ARTWORK}
    DESTINATION ${ADDRESS_BOOK_APP_DIR}/artwork
)



