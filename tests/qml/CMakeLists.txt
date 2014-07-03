add_test(NAME qmltestrunner
	 WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
    	 COMMAND xvfb-run -a -s "-screen 0 1024x768x24" qmltestrunner -import ${imports_BINARY_DIR} -input ${CMAKE_SOURCE_DIR}/tests/qml
)
