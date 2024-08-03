# How to use cmake's fetchcontent to get and compile opencv?

```cmake
# in fetch-common.cmake

include(FetchContent)
set(FETCHCONTENT_BASE_DIR ${PROJECT_SOURCE_DIR}/.fetch)
Set(FETCHCONTENT_QUIET FALSE)
```

```cmake
# in fetch-opencv.cmake
# define fetch content location
include(${PROJECT_SOURCE_DIR}/cmake/fetch-common.cmake)

function(fetch_opencv)
    set(oneValueArgs WITH_CONTRIB)
    cmake_parse_arguments(FETCH_OPENCV "" "${oneValueArgs}" "" ${ARGN})

    # use fetched opencv if OPENCV_USE_LATEST is set
    # set(BUILD_opencv_python3 "OFF")
    set(BUILD_opencv_apps "OFF")
    set(BUILD_EXAMPLES "OFF")
    set(BUILD_DOCS "OFF")
    set(BUILD_TESTS "OFF")
    set(BUILD_PERF_TESTS "OFF")
    set(BUILD_opencv_python3 "OFF")
    set(BUILD_opencv_python2 "OFF")
    set(WITH_QT "ON")

    FetchContent_Declare(
        opencv
        GIT_REPOSITORY https://github.com/opencv/opencv.git
        GIT_TAG        4.x
    )
    FetchContent_MakeAvailable(opencv)
    # message(STATUS "OpenCV source dir: ${opencv_SOURCE_DIR}")
    # message(STATUS "OpenCV binary dir: ${opencv_BINARY_DIR}")
    # make sure downstream find_package() can find this opencv
    set(OpenCV_DIR ${CMAKE_CURRENT_BINARY_DIR} PARENT_SCOPE)
endfunction()
```

use it like this

```cmake
option(WITH_LATEST_OPENCV "Download and build the latest version of OpenCV" OFF)
if(WITH_LATEST_OPENCV)
    include(${PROJECT_SOURCE_DIR}/cmake/fetch-opencv.cmake)
    fetch_opencv()
endif()
```
