if(CLICK_MODE)
    if(NOT BZR_REVNO)
        set(BZR_REVNO "latest")
    endif(NOT BZR_REVNO)
    configure_file(manifest.json.in ${CMAKE_CURRENT_BINARY_DIR}/manifest.json)
    install(FILES ${CMAKE_CURRENT_BINARY_DIR}/manifest.json
            DESTINATION ${CMAKE_INSTALL_PREFIX})
    install(FILES address-book-apparmor.json
            DESTINATION ${CMAKE_INSTALL_PREFIX})
    install(FILES address-book-content.json
            DESTINATION ${CMAKE_INSTALL_PREFIX})
else(CLICK_MODE)
    install(FILES address-book-content.json
            DESTINATION ${CMAKE_INSTALL_DATADIR}/content-hub/peers
            RENAME address-book-app)
endif(CLICK_MODE)
