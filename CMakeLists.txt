cmake_minimum_required(VERSION 3.18)
project(papyrus)
set(CMAKE_CXX_STANDARD 17)

option(SKYRIM_DIR "Path to Skyrim" OFF)
if (NOT SKYRIM_DIR)
  message(FATAL_ERROR "SKYRIM_DIR is not specified")
endif()
if (SKYRIM_DIR AND NOT EXISTS ${SKYRIM_DIR}/SkyrimSE.exe)
  message(FATAL_ERROR "Bad SKYRIM_DIR: ${SKYRIM_DIR}")
endif()

add_subdirectory(vm)