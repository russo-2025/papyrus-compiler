# papyrus-vm-lib
file(GLOB src "${CMAKE_CURRENT_SOURCE_DIR}/papyrus_vm_lib/*")
list(APPEND src "${CMAKE_SOURCE_DIR}/.clang-format")
add_library(papyrus-vm-lib STATIC ${src})
target_include_directories(papyrus-vm-lib PUBLIC "${CMAKE_CURRENT_SOURCE_DIR}/papyrus_vm_lib")
target_include_directories(papyrus-vm-lib PUBLIC third_party)
if (UNIX)
  target_link_libraries(papyrus-vm-lib PUBLIC stdc++fs)
endif()

# papyrus_test_files
include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/add_papyrus_library.cmake)
add_papyrus_library(NAME papyrus_test_files DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/papyrus_test_files)

# unit
file(GLOB_RECURSE src "${CMAKE_CURRENT_SOURCE_DIR}/unit/*")
list(APPEND src "${CMAKE_SOURCE_DIR}/.clang-format")
add_executable(unit ${src})
target_compile_definitions(unit PRIVATE
  TEST_PEX_DIR=\"${CMAKE_CURRENT_SOURCE_DIR}/papyrus_test_files/standard_scripts\"
  BUILT_PEX_DIR=\"${CMAKE_CURRENT_BINARY_DIR}/pex\"
)
target_include_directories(unit PRIVATE third_party)
target_link_libraries(unit PUBLIC papyrus-vm-lib)

enable_testing()
add_test(NAME test_unit COMMAND unit)