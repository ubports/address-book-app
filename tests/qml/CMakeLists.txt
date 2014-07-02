add_custom_target(test-qml
    COMMAND QML2_IMPORT_PATH=${imports_BINARY_DIR} qmltestrunner
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
)
