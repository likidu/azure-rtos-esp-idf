idf_build_get_property(idf_target IDF_TARGET)

# idf_component_register(SRCS ""
#     INCLUDE_DIRS "threadx/common/inc" "threadx/ports/${THREADX_ARCH}/${THREADX_TOOLCHAIN}/inc"
#     PRIV_REQUIRES soc ${idf_target})

idf_component_register(SRCS ""
    INCLUDE_DIRS "threadx/common/inc" "threadx/ports/${THREADX_ARCH}/${THREADX_TOOLCHAIN}/inc")

# Needed to for include_next includes to work from within mbedtls
# include_directories("${COMPONENT_DIR}/port/include")

set(THREADX_ARCH "xtensa")
set(THREADX_TOOLCHAIN "xcc")

# Import threadx library targets
add_subdirectory(threadx)

set(threadx_targets threadx)

# set(mbedtls_target_sources "${COMPONENT_DIR}/port/mbedtls_debug.c"
#                            "${COMPONENT_DIR}/port/net_sockets.c")

#[[
# Add port files to mbedtls targets
target_sources(mbedtls PRIVATE ${mbedtls_target_sources})


target_sources(mbedcrypto PRIVATE "${COMPONENT_DIR}/port/esp_hardware.c"
                                  "${COMPONENT_DIR}/port/esp_mem.c"
                                  "${COMPONENT_DIR}/port/esp_timing.c"
                                  "${COMPONENT_DIR}/port/sha/esp_sha.c"
                                  "${COMPONENT_DIR}/port/aes/esp_aes_xts.c"
                                  "${COMPONENT_DIR}/port/aes/esp_aes_common.c"
                                  "${COMPONENT_DIR}/port/aes/${AES_PERIPHERAL_TYPE}/esp_aes.c"
                                  "${COMPONENT_DIR}/port/sha/${SHA_PERIPHERAL_TYPE}/sha.c"
                                  "${SHA_DMA_SRCS}"
                                  "${AES_DMA_SRCS}"
)
]]



# set_property(TARGET mbedcrypto APPEND PROPERTY LINK_INTERFACE_LIBRARIES mbedtls)

# Link threadx libraries to component library
target_link_libraries(${COMPONENT_LIB} PUBLIC ${threadx_targets})


