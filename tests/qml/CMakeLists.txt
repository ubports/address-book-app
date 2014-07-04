find_program(QMLTESTRUNNER_BIN
    NAMES qmltestrunner
    PATHS /usr/lib/*/qt5/bin
    NO_DEFAULT_PATH
)

find_program(XVFB_RUN_BIN
    NAMES xvfb-run
)

if(QMLTESTRUNNER_BIN AND XVFB_RUN_BIN)
    add_test(NAME qmltestrunner
        WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
        COMMAND xvfb-run -a -s "-screen 0 1024x768x24" ${QMLTESTRUNNER_BIN} -import ${imports_BINARY_DIR} -input ${CMAKE_SOURCE_DIR}/tests/qml
    )
else()
    if (NOT QMLTESTRUNNER_BIN)
        message(WARNING "Qml tests disabled: qmltestrunner not found")
    else()
        message(WARNING "Qml tests disabled: xvfb-run not found")
    endif()
endif()
