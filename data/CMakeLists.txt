if (CLICK_MODE)
    set(ADDRESSBOOK_APP_ICON "share/icons/hicolor/scalable/apps/contacts-app.svg")
else()
    set(ADDRESSBOOK_APP_ICON "contacts-app")
    set(XSCREENSHOT "X-Screenshot=${ADDRESS_BOOK_APP_FULL_DIR}/artwork/address-book-app-preview.png")
endif()

file(REMOVE ${CMAKE_CURRENT_BINARY_DIR}/${ADDRESS_BOOK_APP_DESKTOP_FILE})
file(STRINGS ${ADDRESS_BOOK_APP_DESKTOP_FILE}.in DESKTOP_FILE_CONTENTS)
foreach(LINE ${DESKTOP_FILE_CONTENTS})
    string(REGEX REPLACE "tr\\\(\"(.*)\"\\\)" "\\1" LINE "${LINE}")
    string(CONFIGURE "${LINE}" LINE)
    file(APPEND ${CMAKE_CURRENT_BINARY_DIR}/${ADDRESS_BOOK_APP_DESKTOP_FILE} "${LINE}\n")
endforeach(LINE)


install(FILES ${CMAKE_CURRENT_BINARY_DIR}/${ADDRESS_BOOK_APP_DESKTOP_FILE}
    DESTINATION ${CMAKE_INSTALL_DATADIR}/applications
)
