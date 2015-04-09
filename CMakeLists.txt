
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

CMAKE_MINIMUM_REQUIRED( VERSION 3.0 )

PROJECT( BZIP2 LANGUAGES C CXX VERSION 1.0.5)
option( BZIP2_BUILD_BZIP2 "Build bzip2${CMAKE_EXECUTABLE_SUFFIX} application" TRUE )
option( BZIP2_BUILD_RECOVER "Build bzip2recover${CMAKE_EXECUTABLE_SUFFIX} application" TRUE )

IF( NOT BZIP2_BUILD_BZIP2 )
	SET( EXCLUDE_BZIP2 EXCLUDE_FROM_ALL )
ENDIF()
IF( NOT BZIP2_BUILD_RECOVER )
	SET( EXCLUDE_RECOVER EXCLUDE_FROM_ALL )
ENDIF()

IF( MSVC )
	ADD_DEFINITIONS( -D_CRT_SECURE_NO_WARNINGS )
ENDIF( MSVC )

SET( LIBRARY_SRCS
	blocksort.c
	bzlib.c
	compress.c
	crctable.c
	decompress.c
	huffman.c
	randtable.c )
SET( LIBRARY_PUBLIC_HDRS
	bzlib.h )
SET( LIBRARY_PRIVATE_HDRS
	bzlib_private.h )
SET( BZIP2_SRCS
	bzip2.c )
SET( RECOVER_SRCS
	bzip2recover.c )

SET( CMAKE_DEBUG_POSTFIX "d" )
SET( CMAKE_MFC_FLAG 0 )

IF( WIN32 AND BUILD_SHARED_LIBS)
	SET( LIBRARY_WIN32_XTRAS 
		libbz2.def )
ENDIF()

ADD_LIBRARY(bzip2 ${LIBRARY_SRCS} ${LIBRARY_PUBLIC_HDRS} ${LIBRARY_PRIVATE_HDRS} ${LIBRARY_WIN32_XTRAS})
ADD_EXECUTABLE(bzip2app ${EXCLUDE_BZIP2} ${BZIP2_SRCS} )
ADD_EXECUTABLE(bzip2recover ${EXCLUDE_RECOVER} ${RECOVER_SRCS} )

TARGET_LINK_LIBRARIES( bzip2app bzip2 )
TARGET_LINK_LIBRARIES( bzip2recover bzip2 )

IF( WIN32 AND NOT BZIP2_BUILD_STATIC_LIB )
	SET_TARGET_PROPERTIES(bzip2 PROPERTIES IMPORT_SUFFIX _dll.lib)
ENDIF()

INSTALL( TARGETS bzip2 EXPORT bzip2-config
	DESTINATION lib
	INCLUDES DESTINATION include )
INSTALL( FILES ${LIBRARY_PUBLIC_HDRS}
	DESTINATION include )
install(EXPORT bzip2-config DESTINATION ${PACKAGE_CONFIG_DIR})   
include(CMakePackageConfigHelpers)
WRITE_BASIC_PACKAGE_VERSION_FILE(${CMAKE_CURRENT_BINARY_DIR}/bzip2-config-version.cmake
    COMPATIBILITY AnyNewerVersion)
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/bzip2-config-version.cmake DESTINATION ${PACKAGE_CONFIG_DIR})