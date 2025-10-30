cmake_minimum_required(VERSION 3.11)
project(apriltag)

find_package(OpenCV QUIET)

if(CMAKE_BUILD_TYPE STREQUAL "Debug")
	add_definitions(-Wall -Wpedantic -Werror)
elseif(CMAKE_BUILD_TYPE STREQUAL "")
	set(CMAKE_BUILD_TYPE
		"Release"
		CACHE
			STRING
			"Choose the type of build, options are: None Debug Release RelWithDebInfo MinSizeRel."
			FORCE
	)
endif()

if(NOT CMAKE_CURRENT_SOURCE_DIR STREQUAL CMAKE_SOURCE_DIR)
	set(APRILTAG_IMPORTED 1)
endif(NOT CMAKE_CURRENT_SOURCE_DIR STREQUAL CMAKE_SOURCE_DIR)

aux_source_directory(common COMMON_SRC)

set(APRILTAG_SRCS apriltag.c apriltag_pose.c apriltag_quad_thresh.c)

# Library
file(GLOB TAG_FILES ${PROJECT_SOURCE_DIR}/tag*.c)
set_source_files_properties(SOURCE ${TAG_FILES} PROPERTIES COMPILE_FLAGS -O0)

add_library(apriltag STATIC ${APRILTAG_SRCS} ${COMMON_SRC} ${TAG_FILES})

target_compile_options(apriltag PRIVATE -fPIC)

if(MSVC)
	# FindThreads will not find pthread.h with MSVC winmm is necessary for
	# __imp_timeGetTime
	find_library(PTHREAD_LIBRARIES NAMES pthreads)
	target_link_libraries(apriltag PUBLIC ${PTHREAD_LIBRARIES} winmm)
else()
	find_package(Threads REQUIRED)
	target_link_libraries(apriltag PUBLIC Threads::Threads m)
endif()

set_target_properties(apriltag PROPERTIES SOVERSION 3 VERSION 3.1.3)

include(GNUInstallDirs)
target_include_directories(
	apriltag
	PUBLIC "$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/>"
		   "$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/common>"
		   "$<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>/apriltag"
)

# install header file hierarchy
file(
	GLOB_RECURSE HEADER_FILES
	RELATIVE ${PROJECT_SOURCE_DIR}
	*.h
)
foreach(HEADER ${HEADER_FILES})
	string(REGEX MATCH "(.*)[/\\]" DIR ${HEADER})
	install(FILES ${HEADER}
			DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/${PROJECT_NAME}/${DIR}
	)
endforeach()
