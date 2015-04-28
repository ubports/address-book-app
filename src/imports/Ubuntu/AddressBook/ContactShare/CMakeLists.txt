set(AB_CONTACT_SHARE_QMLS
    ContactSharePage.qml
    qmldir
)

install(FILES ${AB_CONTACT_SHARE_QMLS}
    DESTINATION ${ADDRESS_BOOK_APP_DIR}/imports/ContactShare
)

# make the files visible on qtcreator
add_custom_target(contact_share_QmlFiles ALL SOURCES ${AB_CONTACT_SHARE_QMLS})

if(INSTALL_COMPONENTS)
    install(FILES ${AB_CONTACT_SHARE_QMLS} DESTINATION ${ADDRESS_BOOK_QMLPLUGIN_INSTALL_PREFIX}/ContactShare)
endif()

#copy qml files to build dir to make it possible to run without install
foreach(QML_FILE ${AB_CONTACT_SHARE_QMLS})
  add_custom_command(TARGET contact_share_QmlFiles PRE_BUILD
                     COMMAND ${CMAKE_COMMAND} -E
                         copy ${CMAKE_CURRENT_SOURCE_DIR}/${QML_FILE} ${CMAKE_CURRENT_BINARY_DIR}/)
endforeach()

if (NOT ${CMAKE_CURRENT_BINARY_DIR} STREQUAL ${CMAKE_CURRENT_SOURCE_DIR})
    add_dependencies(copyqmlfiles contact_share_QmlFiles)
endif()
