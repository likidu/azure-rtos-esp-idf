# The following lines of boilerplate have to be in your project's
# CMakeLists in this exact order for cmake to work correctly
cmake_minimum_required(VERSION 3.15)

# Add ThreadX to the component list
set(EXTRA_COMPONENT_DIRS "${CMAKE_CURRENT_SOURCE_DIR}/../../components/azure-rtos/threadx")
# Empty the component list, main will bring in just what it needs
set(COMPONENTS "")

include($ENV{IDF_PATH}/tools/cmake/project.cmake)

# Colorize output
add_compile_options(
  $<$<CXX_COMPILER_ID:GNU>:-fdiagnostics-color=always>
  $<$<CXX_COMPILER_ID:Clang>:-fcolor-diagnostics>
)

project(demo-threadx)
