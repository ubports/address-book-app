if(NOT CLICK_MODE)
    set(XSCREENSHOT "X-Screenshot=${ADDRESS_BOOK_APP_FULL_DIR}/artwork/address-book-app-preview.png")
    set(ADDRESS_BOOK_APP_ICON "address-book-app")
else()
    set(ADDRESS_BOOK_APP_ICON "address-book-app.svg")
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
    install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/${ADDRESS_BOOK_APP_ICON}
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
