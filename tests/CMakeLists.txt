add_subdirectory(qml)
add_subdirectory(unittest)

if(ENABLE_AUTOPILOT)
    add_subdirectory(autopilot)
    add_subdirectory(data)
endif()
