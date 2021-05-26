set(THREADX_ARCH "xtensa")
set(THREADX_TOOLCHAIN "xcc")

set(TX_USER_FILE "${CMAKE_CURRENT_LIST_DIR}/tx_user.h")

idf_component_register(SRCS "demo_threadx_main.c" INCLUDE_DIRS ".")

# Import threadx library targets
add_subdirectory(lib/threadx)

# Link threadx libraries to main component
target_link_libraries(${COMPONENT_LIB} PUBLIC threadx)
