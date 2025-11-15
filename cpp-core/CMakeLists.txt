cmake_minimum_required(VERSION 3.16)
project(AdvancedCurveProcessor VERSION 1.0.0)

# Modern C++ standard (matching PhotoStudio Pro)
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# Build options
option(ENABLE_DIRECTML "Enable DirectML support for AI processing" ON)
option(ENABLE_OPENCL "Enable OpenCL support for GPU acceleration" ON)
option(BUILD_TESTS "Build test suite" ON)
option(BUILD_SHARED_LIBS "Build shared library for Lightroom plugin" ON)

# Configuration
set(CMAKE_BUILD_TYPE Release CACHE STRING "Build type")
set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS "Debug" "Release" "RelWithDebInfo")

# Compiler-specific options
if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU" OR CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -Wextra -O3 -march=native")
    set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -g -O0 -fsanitize=address")
elseif(CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /W4 /O2 /arch:AVX2")
    add_definitions(-D_CRT_SECURE_NO_WARNINGS)
endif()

# Find required dependencies
find_package(OpenCV 4.0 REQUIRED)
find_package(Threads REQUIRED)

message(STATUS "OpenCV version: ${OpenCV_VERSION}")
message(STATUS "OpenCV include: ${OpenCV_INCLUDE_DIRS}")

# Platform-specific dependencies
if(WIN32 AND ENABLE_DIRECTML)
    # Try to find DirectML (from reverse engineering insights)
    find_package(DirectML QUIET)
    if(DirectML_FOUND)
        set(DIRECTML_ENABLED ON)
        message(STATUS "DirectML found - 183 ML operators available")
    else()
        set(DIRECTML_ENABLED OFF)
        message(WARNING "DirectML not found - AI features will be limited")
    endif()
endif()

if(ENABLE_OPENCL)
    find_package(OpenCL QUIET)
    if(OpenCL_FOUND)
        set(OPENCL_ENABLED ON)
        message(STATUS "OpenCL found - GPU acceleration enabled")
    else()
        set(OPENCL_ENABLED OFF)
        message(WARNING "OpenCL not found - GPU acceleration disabled")
    endif()
endif()

# Include directories
include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}/include
    ${CMAKE_CURRENT_SOURCE_DIR}/src
    ${OpenCV_INCLUDE_DIRS}
)

# Source files based on reverse engineering structure
set(CORE_SOURCES
    src/CurveEngine.cpp
    src/ColorManager.cpp
    src/ImageProcessor.cpp
    src/LightroomAPI.cpp
    src/MathUtils.cpp
    src/PerformanceProfiler.cpp
)

# AI/ML sources (based on 183 DirectML operators from DEEP ALGORITHM EXTRACTION)
set(AI_SOURCES
    src/ai/AIProcessor.cpp
    src/ai/CurveSuggestionEngine.cpp
    src/ai/ImageAnalyzer.cpp
    src/ai/MLOperatorRegistry.cpp
    src/ai/DirectMLProcessor.cpp
    src/ai/ProfessionalAIModels.cpp
)

# GPU acceleration sources
set(GPU_SOURCES
    src/gpu/GPUProcessor.cpp
)

if(DIRECTML_ENABLED)
    list(APPEND GPU_SOURCES 
        src/gpu/DirectMLProcessor.cpp
        src/gpu/DirectMLOperators.cpp
    )
endif()

if(OPENCL_ENABLED)
    list(APPEND GPU_SOURCES 
        src/gpu/OpenCLProcessor.cpp
        src/gpu/OpenCLKernels.cpp
    )
endif()

# Curve mathematics (from reverse engineering insights)
set(CURVE_SOURCES
    src/curves/CubicSpline.cpp
    src/curves/BezierCurve.cpp
    src/curves/ParametricCurve.cpp
    src/curves/LookupTable.cpp
)

# Color management (professional features)
set(COLOR_SOURCES
    src/color/ColorSpaceConverter.cpp
    src/color/ICCProfileManager.cpp
    src/color/GamutMapping.cpp
    src/color/CalibrationEngine.cpp
)

# All sources
set(ALL_SOURCES 
    ${CORE_SOURCES} 
    ${AI_SOURCES} 
    ${GPU_SOURCES} 
    ${CURVE_SOURCES} 
    ${COLOR_SOURCES}
)

# Create main shared library for Lightroom
add_library(AdvancedCurveProcessor SHARED ${ALL_SOURCES})

# Set library properties
set_target_properties(AdvancedCurveProcessor PROPERTIES
    VERSION ${PROJECT_VERSION}
    SOVERSION 1
    OUTPUT_NAME "AdvancedCurveProcessor"
    PREFIX ""  # Remove 'lib' prefix on Unix
)

# Link libraries
target_link_libraries(AdvancedCurveProcessor 
    ${OpenCV_LIBS}
    Threads::Threads
)

# Platform-specific linking
if(DIRECTML_ENABLED)
    target_link_libraries(AdvancedCurveProcessor DirectML::DirectML)
    target_compile_definitions(AdvancedCurveProcessor PRIVATE DIRECTML_ENABLED=1)
endif()

if(OPENCL_ENABLED)
    target_link_libraries(AdvancedCurveProcessor OpenCL::OpenCL)
    target_compile_definitions(AdvancedCurveProcessor PRIVATE OPENCL_ENABLED=1)
endif()

# Compiler definitions for reverse engineering features
target_compile_definitions(AdvancedCurveProcessor PRIVATE
    CURVE_PROCESSOR_VERSION="${PROJECT_VERSION}"
    REVERSE_ENGINEERING_INSIGHTS=1
    ML_OPERATORS_COUNT=183
)

# Export symbols for Lightroom integration
if(WIN32)
    target_compile_definitions(AdvancedCurveProcessor PRIVATE
        CURVE_PROCESSOR_EXPORTS=1
    )
endif()

# Install configuration
install(TARGETS AdvancedCurveProcessor
    LIBRARY DESTINATION lib
    RUNTIME DESTINATION bin
    ARCHIVE DESTINATION lib/static
)

install(DIRECTORY include/ 
    DESTINATION include/AdvancedCurveProcessor
    FILES_MATCHING PATTERN "*.h" PATTERN "*.hpp"
)

# Test configuration
if(BUILD_TESTS)
    enable_testing()
    add_subdirectory(tests)
endif()

# Development tools
add_custom_target(format
    COMMAND find ${CMAKE_CURRENT_SOURCE_DIR}/src -name "*.cpp" -o -name "*.h" | 
            xargs clang-format -i -style=file
    COMMENT "Formatting source code"
)

add_custom_target(analyze
    COMMAND cppcheck --enable=all --std=c++20 ${CMAKE_CURRENT_SOURCE_DIR}/src
    COMMENT "Static analysis"
)

# Summary
message(STATUS "=== AdvancedCurveProcessor Configuration ===")
message(STATUS "Build type: ${CMAKE_BUILD_TYPE}")
message(STATUS "C++ Standard: ${CMAKE_CXX_STANDARD}")
message(STATUS "DirectML enabled: ${DIRECTML_ENABLED}")
message(STATUS "OpenCL enabled: ${OPENCL_ENABLED}")
message(STATUS "Build tests: ${BUILD_TESTS}")
message(STATUS "OpenCV version: ${OpenCV_VERSION}")

if(DIRECTML_ENABLED)
    message(STATUS "AI features: 183 DirectML operators available")
else()
    message(STATUS "AI features: Limited (no DirectML)")
endif()

message(STATUS "===========================================")

# Generate compile_commands.json for IDE support
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)