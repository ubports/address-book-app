set(ADDRESS_BOOK_APP_ICON "address-book-app.svg")
set(ADDRESS_BOOK_APP_SPLASH "address-book-app-splash.svg")
set(ADDRESS_BOOK_APP_SYMBOLIC_ICON "address-book-app-symbolic.svg")
set(ADDRESS_BOOK_ARTWORK_PATH "${ADDRESS_BOOK_APP_FULL_DIR}/artwork")

if(NOT CLICK_MODE)
    set(XSCREENSHOT "X-Screenshot=${ADDRESS_BOOK_ARTWORK_PATH}/address-book-app-preview.png")
endif()

configure_file(${DESKTOP_FILE}.in.in ${DESKTOP_FILE}.in)
add_custom_target(${DESKTOP_FILE} ALL
         COMMENT "Merging translations into ${DESKTOP_FILE}"
         COMMAND LC_ALL=C ${INTLTOOL_MERGE} -d -u ${CMAKE_SOURCE_DIR}/po ${DESKTOP_FILE}.in ${DESKTOP_FILE} >/dev/null
)

if(CLICK_MODE)
    install(FILES ${CMAKE_CURRENT_BINARY_DIR}/${ADDRESS_BOOK_APP_DESKTOP_FILE}
        DESTINATION ${CMAKE_INSTALL_BINDIR}
    )
else()
    install(FILES ${CMAKE_CURRENT_BINARY_DIR}/${ADDRESS_BOOK_APP_DESKTOP_FILE}
        DESTINATION ${CMAKE_INSTALL_DATADIR}/applications
    )
endif()

install(FILES "address-book-app.url-dispatcher"
    DESTINATION ${CMAKE_INSTALL_DATADIR}/url-dispatcher/urls
)
