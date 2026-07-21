# Install script for directory: /home/rba/git/doss/fuzz_benchmark/targets/poppler/repo/cpp

# Set the install prefix
if(NOT DEFINED CMAKE_INSTALL_PREFIX)
  set(CMAKE_INSTALL_PREFIX "/usr/local")
endif()
string(REGEX REPLACE "/$" "" CMAKE_INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}")

# Set the install configuration name.
if(NOT DEFINED CMAKE_INSTALL_CONFIG_NAME)
  if(BUILD_TYPE)
    string(REGEX REPLACE "^[^A-Za-z0-9_]+" ""
           CMAKE_INSTALL_CONFIG_NAME "${BUILD_TYPE}")
  else()
    set(CMAKE_INSTALL_CONFIG_NAME "debug")
  endif()
  message(STATUS "Install configuration: \"${CMAKE_INSTALL_CONFIG_NAME}\"")
endif()

# Set the component getting installed.
if(NOT CMAKE_INSTALL_COMPONENT)
  if(COMPONENT)
    message(STATUS "Install component: \"${COMPONENT}\"")
    set(CMAKE_INSTALL_COMPONENT "${COMPONENT}")
  else()
    set(CMAKE_INSTALL_COMPONENT)
  endif()
endif()

# Install shared libraries without execute permission?
if(NOT DEFINED CMAKE_INSTALL_SO_NO_EXE)
  set(CMAKE_INSTALL_SO_NO_EXE "1")
endif()

# Is this installation the result of a crosscompile?
if(NOT DEFINED CMAKE_CROSSCOMPILING)
  set(CMAKE_CROSSCOMPILING "FALSE")
endif()

# Set path to fallback-tool for dependency-resolution.
if(NOT DEFINED CMAKE_OBJDUMP)
  set(CMAKE_OBJDUMP "/usr/bin/objdump")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib" TYPE STATIC_LIBRARY FILES "/home/rba/git/doss/fuzz_benchmark/targets/poppler/work/poppler/cpp/libpoppler-cpp.a")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/poppler/cpp" TYPE FILE FILES
    "/home/rba/git/doss/fuzz_benchmark/targets/poppler/repo/cpp/poppler-destination.h"
    "/home/rba/git/doss/fuzz_benchmark/targets/poppler/repo/cpp/poppler-document.h"
    "/home/rba/git/doss/fuzz_benchmark/targets/poppler/repo/cpp/poppler-embedded-file.h"
    "/home/rba/git/doss/fuzz_benchmark/targets/poppler/repo/cpp/poppler-font.h"
    "/home/rba/git/doss/fuzz_benchmark/targets/poppler/repo/cpp/poppler-font-private.h"
    "/home/rba/git/doss/fuzz_benchmark/targets/poppler/repo/cpp/poppler-global.h"
    "/home/rba/git/doss/fuzz_benchmark/targets/poppler/repo/cpp/poppler-image.h"
    "/home/rba/git/doss/fuzz_benchmark/targets/poppler/repo/cpp/poppler-page.h"
    "/home/rba/git/doss/fuzz_benchmark/targets/poppler/repo/cpp/poppler-page-renderer.h"
    "/home/rba/git/doss/fuzz_benchmark/targets/poppler/repo/cpp/poppler-page-transition.h"
    "/home/rba/git/doss/fuzz_benchmark/targets/poppler/repo/cpp/poppler-rectangle.h"
    "/home/rba/git/doss/fuzz_benchmark/targets/poppler/repo/cpp/poppler-toc.h"
    "/home/rba/git/doss/fuzz_benchmark/targets/poppler/work/poppler/cpp/poppler_cpp_export.h"
    "/home/rba/git/doss/fuzz_benchmark/targets/poppler/work/poppler/cpp/poppler-version.h"
    )
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for each subdirectory.
  include("/home/rba/git/doss/fuzz_benchmark/targets/poppler/work/poppler/cpp/tests/cmake_install.cmake")

endif()

string(REPLACE ";" "\n" CMAKE_INSTALL_MANIFEST_CONTENT
       "${CMAKE_INSTALL_MANIFEST_FILES}")
if(CMAKE_INSTALL_LOCAL_ONLY)
  file(WRITE "/home/rba/git/doss/fuzz_benchmark/targets/poppler/work/poppler/cpp/install_local_manifest.txt"
     "${CMAKE_INSTALL_MANIFEST_CONTENT}")
endif()
