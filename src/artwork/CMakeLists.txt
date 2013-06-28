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
    facebook.png
    favorite-selected.png
    favorite-unselected.png
    settings.png
    skype.png
    twitter.png
)

install(FILES ${ADDRESS_BOOK_APP_ICON}
    DESTINATION ${CMAKE_INSTALL_DATADIR}/icons/hicolor/48x48/apps
)

install(FILES ${ADDRESS_BOOK_APP_ARTWORK}
    DESTINATION ${ADDRESS_BOOK_APP_DIR}/artwork
)


