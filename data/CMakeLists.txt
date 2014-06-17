if (CLICK_MODE)
    set(ADDRESSBOOK_APP_ICON "share/icons/hicolor/scalable/apps/contacts-app.svg")
else()
    set(ADDRESSBOOK_APP_ICON "contacts-app")
    set(XSCREENSHOT "X-Screenshot=${ADDRESS_BOOK_APP_FULL_DIR}/artwork/address-book-app-preview.png")
endif()

configure_file(${DESKTOP_FILE}.in.in ${DESKTOP_FILE}.in)
add_custom_target(${DESKTOP_FILE} ALL
         COMMENT "Merging translations into ${DESKTOP_FILE}"
         COMMAND LC_ALL=C ${INTLTOOL_MERGE} -d -u ${CMAKE_SOURCE_DIR}/po ${DESKTOP_FILE}.in ${DESKTOP_FILE} >/dev/null
        )

install(FILES ${CMAKE_CURRENT_BINARY_DIR}/${ADDRESS_BOOK_APP_DESKTOP_FILE}
    DESTINATION ${CMAKE_INSTALL_DATADIR}/applications
)

install(FILES "address-book-app.url-dispatcher"
    DESTINATION ${CMAKE_INSTALL_DATADIR}/url-dispatcher/urls
)
