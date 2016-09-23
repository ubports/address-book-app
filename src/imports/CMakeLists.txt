project(imports)

set(ADDRESS_BOOK_APP_QMLS
    ABAdaptivePageLayout.qml
    ABContactListPage.qml
    ABContactEditorPage.qml
    ABContactEditorPageWithEmptyContact.qml
    ABContactViewPage.qml
    ABEmptyState.qml
    ABNewContactBottomEdge.qml
    ABMultiColumnEmptyState.qml
    ContentHubProxy.qml
    MainWindow.qml
)

install(FILES ${ADDRESS_BOOK_APP_QMLS}
    DESTINATION ${ADDRESS_BOOK_APP_DIR}/imports
)

# make the files visible on qtcreator
add_custom_target(address_book_QMlFiles ALL SOURCES ${ADDRESS_BOOK_APP_QMLS})

add_subdirectory(Settings)
add_subdirectory(Ubuntu)
