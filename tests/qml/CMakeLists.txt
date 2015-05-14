find_program(QMLTESTRUNNER_BIN
    NAMES qmltestrunner
    PATHS /usr/lib/*/qt5/bin
    NO_DEFAULT_PATH
)

macro(DECLARE_QML_TEST TST_NAME TST_QML_FILE)
    if(RUN_TESTS_OFFSCREEN)
        set(COMMAND_SUFFIX -platform offscreen)
    else()
        set(COMMAND_SUFFIX "")
    endif()
    add_test(NAME ${TST_NAME}
        WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
        COMMAND ${QMLTESTRUNNER_BIN} ${COMMAND_SUFFIX} -import ${imports_BINARY_DIR} -input ${CMAKE_CURRENT_SOURCE_DIR}/${TST_QML_FILE}
    )
    set(TEST_ENVIRONMENT "QT_QPA_PLATFORM=minimal\;QT_QPA_FONTDIR=.")
    set_tests_properties(${TST_NAME} PROPERTIES
                          ENVIRONMENT ${TEST_ENVIRONMENT})
endmacro()

if(QMLTESTRUNNER_BIN)
    declare_qml_test("contact_list" tst_ContactList.qml)
    declare_qml_test("Contact_list_model" tst_ContactListModel.qml)
    declare_qml_test("Contact_list_view" tst_ContactListView.qml)
    declare_qml_test("contact_editor" tst_ContactEditor.qml)
    declare_qml_test("contact_avatar" tst_ContactAvatar.qml)
    declare_qml_test("list_with_actions" tst_ListWithActions.qml)
    declare_qml_test("contact_preview_page" tst_ContactPreviewPage.qml)
    declare_qml_test("vcard_parser" tst_VCardParser.qml)
else()
    message(WARNING "Qml tests disabled: qmltestrunner not found")
endif()

set(QML_TST_FILES
    ContactUtil.js
    tst_ContactEditor.qml
    tst_ContactAvatar.qml
    tst_ContactList.qml
    tst_ContactListModel.qml
    tst_ContactListView.qml
    tst_ListWithActions.qml
    tst_ContactPreviewPage.qml
    tst_VCardParser.qml
)
add_custom_target(tst_QmlFiles ALL SOURCES ${QML_TST_FILES})
