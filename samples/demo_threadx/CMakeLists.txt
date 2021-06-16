# The following lines of boilerplate have to be in your project's
# CMakeLists in this exact order for cmake to work correctly
cmake_minimum_required(VERSION 3.15)

set(COMPONENTS xtensa)
# set(EXTRA_COMPONENT_DIRS "../../azure-rtos/components")

include($ENV{IDF_PATH}/tools/cmake/project.cmake)

project(demo-threadx)
