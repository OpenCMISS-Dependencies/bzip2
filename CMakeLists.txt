
 # ***** BEGIN LICENSE BLOCK *****
 # Version: MPL 1.1/GPL 2.0/LGPL 2.1
 #
 # The contents of this file are subject to the Mozilla Public License Version
 # 1.1 (the "License"); you may not use this file except in compliance with
 # the License. You may obtain a copy of the License at
 # http://www.mozilla.org/MPL/
 #
 # Software distributed under the License is distributed on an "AS IS" basis,
 # WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
 # for the specific language governing rights and limitations under the
 # License.
 #
 # The Original Code is cmgui
 #
 # The Initial Developer of the Original Code is
 # Auckland Uniservices Ltd, Auckland, New Zealand.
 # Portions created by the Initial Developer are Copyright (C) 2005
 # the Initial Developer. All Rights Reserved.
 #
 # Contributor(s): 
 #
 # Alternatively, the contents of this file may be used under the terms of
 # either the GNU General Public License Version 2 or later (the "GPL"), or
 # the GNU Lesser General Public License Version 2.1 or later (the "LGPL"),
 # in which case the provisions of the GPL or the LGPL are applicable instead
 # of those above. If you wish to allow use of your version of this file only
 # under the terms of either the GPL or the LGPL, and not to allow others to
 # use your version of this file under the terms of the MPL, indicate your
 # decision by deleting the provisions above and replace them with the notice
 # and other provisions required by the GPL or the LGPL. If you do not delete
 # the provisions above, a recipient may use your version of this file under
 # the terms of any one of the MPL, the GPL or the LGPL.
 #
 # ***** END LICENSE BLOCK ***** */

cmake_minimum_required(VERSION 3.0)

project( BZIP2 LANGUAGES C VERSION 1.0.6)
option( BZIP2_BUILD_RECOVER "Build bzip2recover${CMAKE_EXECUTABLE_SUFFIX} application" TRUE )
option(BUILD_TESTS "${PROJECT_NAME} - Build tests" ON)

if( NOT BZIP2_BUILD_RECOVER )
	set( EXCLUDE_RECOVER EXCLUDE_FROM_ALL )
endif()

set( LIBRARY_SRCS
	blocksort.c
	bzlib.c
	compress.c
	crctable.c
	decompress.c
	huffman.c
	randtable.c )
set( LIBRARY_PUBLIC_HDRS
	bzlib.h )
set( LIBRARY_PRIVATE_HDRS
	bzlib_private.h )
set( BZIP2_SRCS
	bzip2.c )
set( RECOVER_SRCS
	bzip2recover.c )

set( CMAKE_MFC_FLAG 0 )

if( WIN32 AND BUILD_SHARED_LIBS)
	set( LIBRARY_WIN32_XTRAS 
		libbz2.def )
endif()

add_library(bz2 ${LIBRARY_SRCS} ${LIBRARY_PUBLIC_HDRS} ${LIBRARY_PRIVATE_HDRS} ${LIBRARY_WIN32_XTRAS})
if(MSVC)
    target_compile_definitions(bz2 PRIVATE _CRT_SECURE_NO_WARNINGS WIN32 _FILE_OFFSET_BITS=64)
    target_compile_options(bz2 PRIVATE -MD -nologo)
endif()
# For intel we need to link against the irc support library
# Dont know why it's not linked automatically as it's a compiler aux library
# See https://software.intel.com/de-de/articles/unresolved-external-symbol-_intel_fast_memcpy
if (CMAKE_C_COMPILER_ID STREQUAL Intel)
    target_link_libraries(bz2 INTERFACE irc)
endif()
add_executable(bzip2 ${EXCLUDE_BZIP2} ${BZIP2_SRCS})
add_executable(bzip2recover ${EXCLUDE_RECOVER} ${RECOVER_SRCS} )

target_link_libraries(bzip2 bz2)
target_link_libraries(bzip2recover bz2)

if(WIN32 AND BUILD_SHARED_LIBS)
	set_target_properties(bzip2 PROPERTIES IMPORT_SUFFIX _dll.lib)
endif()

if (BUILD_TESTS)
    if (UNIX)
        enable_testing()
        file(GLOB SAMPLE_FILES ${CMAKE_CURRENT_SOURCE_DIR}/sample*)
        file(COPY ${SAMPLE_FILES} DESTINATION ${CMAKE_CURRENT_BINARY_DIR})
        MACRO(ADDTEST NAME ARGS INFILE TARGET)
            add_test(${NAME} ${CMAKE_COMMAND}
                    -DCMD=${CMAKE_CURRENT_BINARY_DIR}/bzip2${CMAKE_EXECUTABLE_SUFFIX}
                    -DARGS=${ARGS}
                    -DINFILE=${CMAKE_CURRENT_SOURCE_DIR}/${INFILE}
                    -DTARGET=${CMAKE_CURRENT_SOURCE_DIR}/${TARGET}
                    -P ${CMAKE_CURRENT_SOURCE_DIR}/testhelper.cmake)
        ENDMACRO()
        ADDTEST(compression_level1 -1 sample1.ref sample1.bz2)
        ADDTEST(compression_level2 -2 sample2.ref sample2.bz2)
        ADDTEST(compression_level3 -3 sample3.ref sample3.bz2)
        ADDTEST(decompression_level1 -d sample1.bz2 sample1.ref)
        ADDTEST(decompression_level2 -d sample2.bz2 sample2.ref)
        ADDTEST(decompression_level3 -ds sample3.bz2 sample3.ref)
    else()
        message(WARNING "Tests not implemented on non-unix platforms")
    endif()
endif()

install(TARGETS bz2 EXPORT bzip2-config
	DESTINATION lib
	INCLUDES DESTINATION include )
install(TARGETS bzip2 EXPORT bzip2-config
	DESTINATION bin)
install( FILES ${LIBRARY_PUBLIC_HDRS} DESTINATION include )
install(EXPORT bzip2-config DESTINATION ${PACKAGE_CONFIG_DIR})   
include(CMakePackageConfigHelpers)
WRITE_BASIC_PACKAGE_VERSION_FILE(${CMAKE_CURRENT_BINARY_DIR}/bzip2-config-version.cmake
    COMPATIBILITY AnyNewerVersion)
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/bzip2-config-version.cmake DESTINATION ${PACKAGE_CONFIG_DIR})