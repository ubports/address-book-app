if(NOT CLICK_MODE)
    set(XSCREENSHOT "X-Screenshot=${ADDRESS_BOOK_APP_FULL_DIR}/artwork/address-book-app-preview.png")
    set(ADDRESS_BOOK_APP_ICON "address-book-app")
else()
    set(ADDRESS_BOOK_APP_ICON "address-book-app.svg")
endif()

file(REMOVE ${CMAKE_CURRENT_BINARY_DIR}/${ADDRESS_BOOK_APP_DESKTOP_FILE})
file(STRINGS ${ADDRESS_BOOK_APP_DESKTOP_FILE}.in DESKTOP_FILE_CONTENTS)
foreach(LINE ${DESKTOP_FILE_CONTENTS})
    string(REGEX REPLACE "tr\\\(\"(.*)\"\\\)" "\\1" LINE "${LINE}")
    string(CONFIGURE "${LINE}" LINE)
    file(APPEND ${CMAKE_CURRENT_BINARY_DIR}/${ADDRESS_BOOK_APP_DESKTOP_FILE} "${LINE}\n")
endforeach(LINE)

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
