set(ADDRESS_BOOK_APP_ICON
	address-book-app.svg
)

set(ADDRESS_BOOK_APP_ARTWORK
	add.png
	avatar.png
	delete.png
	edit.png
	settings.png
)

install(FILES ${ADDRESS_BOOK_APP_ICON}
    DESTINATION ${CMAKE_INSTALL_DATADIR}/icons/hicolor/scalable/apps
)

install(FILES ${ADDRESS_BOOK_APP_ARTWORK}
    DESTINATION ${ADDRESS_BOOK_APP_DIR}/artwork
)

