set(AB_CONTACT_COMMON_QMLS
    ContactDetailBase.qml
    ContactDetailItem.qml
    ContactDetailGroupBase.qml
    ContactDetailGroupWithTypeBase.qml
    ContactExporter.qml
    KeyboardRectangle.qml
    RemoveContactsDialog.qml
    qmldir
)

# make the files visible on qtcreator
add_custom_target(contact_common_QmlFiles ALL SOURCES ${AB_CONTACT_COMMON_QMLS})

if(INSTALL_COMPONENTS)
    install(FILES ${AB_CONTACT_COMMON_QMLS} DESTINATION ${ADDRESS_BOOK_QMLPLUGIN_INSTALL_PREFIX}/Base)
endif()

#copy qml files to build dir to make it possible to run without install
foreach(QML_FILE ${AB_CONTACT_COMMON_QMLS})
  add_custom_command(TARGET contact_common_QmlFiles PRE_BUILD
                     COMMAND ${CMAKE_COMMAND} -E
                         copy ${CMAKE_CURRENT_SOURCE_DIR}/${QML_FILE} ${CMAKE_CURRENT_BINARY_DIR}/)
endforeach()

if (NOT ${CMAKE_CURRENT_BINARY_DIR} STREQUAL ${CMAKE_CURRENT_SOURCE_DIR})
    add_dependencies(copyqmlfiles contact_common_QmlFiles)
endif()


