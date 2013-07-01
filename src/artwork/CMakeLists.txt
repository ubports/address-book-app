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
    protocol_aim.png
    protocol_facebook.png
    protocol_icq.png
    protocol_irc.png
    protocol_jabber.png
    protocol_msn.png
    protocol_other.png
    protocol_qq.png
    protocol_skype.png
    protocol_yahoo.png
    settings.png
)

install(FILES ${ADDRESS_BOOK_APP_ICON}
    DESTINATION ${CMAKE_INSTALL_DATADIR}/icons/hicolor/48x48/apps
)

install(FILES ${ADDRESS_BOOK_APP_ARTWORK}
    DESTINATION ${ADDRESS_BOOK_APP_DIR}/artwork
)



