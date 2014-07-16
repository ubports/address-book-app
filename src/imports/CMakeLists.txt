project(imports)

set(ADDRESS_BOOK_APP_QMLS
    MainWindow.qml
)

install(FILES ${ADDRESS_BOOK_APP_QMLS}
    DESTINATION ${ADDRESS_BOOK_APP_DIR}/imports
)

# make the files visible on qtcreator
add_custom_target(address_book_QMlFiles ALL SOURCES ${ADDRESS_BOOK_APP_QMLS})

add_subdirectory(Common)
add_subdirectory(ContactList)
add_subdirectory(ContactView)
add_subdirectory(ContactEdit)
add_subdirectory(ContactShare)
add_subdirectory(Ubuntu)
