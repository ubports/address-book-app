project(test_data)

set(AUTOPILOT_DATA
    vcard.vcf
)

install(FILES ${AUTOPILOT_DATA}
    DESTINATION ${CMAKE_INSTALL_DATADIR}/address-book-app/vcards
)

