cmake_minimum_required(VERSION 3.18.0)

project(whisper_android)

set(CMAKE_CXX_STANDARD 17)

# Set path to whisper.cpp relative to this file
set(WHISPER_DIR ${CMAKE_CURRENT_SOURCE_DIR}/../../../../../native/whisper.cpp)
set(NATIVE_LIB_DIR ${CMAKE_CURRENT_SOURCE_DIR}/../../../../../native)

# Get whisper version from main CMakeLists.txt
file(READ "${WHISPER_DIR}/CMakeLists.txt" MAIN_CMAKE_CONTENT)
string(REGEX MATCH "project\\(\"whisper\\.cpp\" VERSION ([0-9]+\\.[0-9]+\\.[0-9]+)\\)" VERSION_MATCH "${MAIN_CMAKE_CONTENT}")
if(CMAKE_MATCH_1)
    set(WHISPER_VERSION ${CMAKE_MATCH_1})
else()
    set(WHISPER_VERSION "1.0.0")
endif()

message(STATUS "Whisper version: ${WHISPER_VERSION}")

# Source files
set(SOURCE_FILES
    ${WHISPER_DIR}/src/whisper.cpp
    ${NATIVE_LIB_DIR}/native_lib.cpp
)

find_library(LOG_LIB log)

include(FetchContent)

# Use FetchContent to include ggml with its own CMakeLists.txt
FetchContent_Declare(ggml SOURCE_DIR ${WHISPER_DIR}/ggml)
FetchContent_MakeAvailable(ggml)

# Build library
add_library(whisper SHARED ${SOURCE_FILES})

target_compile_definitions(whisper PUBLIC GGML_USE_CPU)
target_compile_definitions(whisper PRIVATE WHISPER_VERSION="${WHISPER_VERSION}")

# Optimizations
if (NOT ${CMAKE_BUILD_TYPE} STREQUAL "Debug")
    target_compile_options(whisper PRIVATE -O3 -ffast-math)
    # Visibility hidden can cause issues with symbol lookup, commenting out for now
    # target_compile_options(whisper PRIVATE -fvisibility=hidden -fvisibility-inlines-hidden)
    target_compile_options(whisper PRIVATE -ffunction-sections -fdata-sections)
    
    target_link_options(whisper PRIVATE -Wl,--gc-sections)
    target_link_options(whisper PRIVATE -Wl,--exclude-libs,ALL)
endif()

# Architecture-specific optimizations
# Removed -march=armv8.2-a+fp16 as it causes SIGILL on Snapdragon 660 and older chips
# Using default ARM compilation for maximum compatibility
if (${ANDROID_ABI} STREQUAL "armeabi-v7a")
    target_compile_options(whisper PRIVATE -mfpu=neon)
    target_compile_options(ggml PRIVATE -mfpu=neon)
endif()

# Include directories
include_directories(${WHISPER_DIR})
include_directories(${WHISPER_DIR}/include)
include_directories(${WHISPER_DIR}/src)
include_directories(${WHISPER_DIR}/ggml/include)
include_directories(${WHISPER_DIR}/ggml/src)

# Link libraries
target_link_libraries(whisper ${LOG_LIB} android ggml)
