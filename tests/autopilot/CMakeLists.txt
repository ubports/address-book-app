set(AUTOPILOT_DIR address_book_app)

execute_process(COMMAND python -c "from distutils.sysconfig import get_python_lib; print get_python_lib()"
    OUTPUT_VARIABLE PYTHON_PACKAGE_DIR OUTPUT_STRIP_TRAILING_WHITESPACE)

if(INSTALL_TESTS)
    install(DIRECTORY ${AUTOPILOT_DIR}
        DESTINATION ${PYTHON_PACKAGE_DIR}
    )
endif()

set(AUTOPILOT_ENV "AUTOPILOT_APP=${address-book-main-app_BINARY_DIR}/address-book-app\;QTCONTACTS_MANAGER_OVERRIDE=memory")
declare_autopilot_test(${AUTOPILOT_ENV}
                       address_book_app
                       ${CMAKE_CURRENT_SOURCE_DIR})
