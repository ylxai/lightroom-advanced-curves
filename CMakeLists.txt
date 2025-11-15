cmake_minimum_required(VERSION 3.25)

project(PhotoStudioPro 
    VERSION 1.0.0
    DESCRIPTION "Professional Image Processing Suite"
    LANGUAGES CXX C)

# Modern C++ standard
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# Build configuration
set(CMAKE_BUILD_TYPE Release CACHE STRING "Build type")

# Project options
option(ENABLE_DIRECTML "Enable DirectML support on Windows" ON)
option(ENABLE_OPENCL "Enable OpenCL support" ON)
option(ENABLE_TESTING "Enable testing" ON)
option(BUILD_PLUGINS "Build example plugins" ON)
option(BUILD_SDK "Build SDK components" ON)

# Platform detection
if(WIN32)
    set(PLATFORM_WINDOWS TRUE)
elseif(APPLE)
    set(PLATFORM_MACOS TRUE)
elseif(UNIX)
    set(PLATFORM_LINUX TRUE)
endif()

message(STATUS "Building PhotoStudio Pro v${PROJECT_VERSION}")
message(STATUS "Platform: ${CMAKE_SYSTEM_NAME}")
message(STATUS "C++ Standard: ${CMAKE_CXX_STANDARD}")

# Find required packages
find_package(Qt6 6.5 REQUIRED COMPONENTS 
    Core Widgets Quick Qml OpenGL)
find_package(OpenCV 4.8 REQUIRED)
find_package(PkgConfig REQUIRED)

# LibRAW
pkg_check_modules(LIBRAW REQUIRED libraw>=0.21.0)

# LCMS2
pkg_check_modules(LCMS2 REQUIRED lcms2>=2.14)

# OpenCL (optional)
if(ENABLE_OPENCL)
    find_package(OpenCL)
    if(OpenCL_FOUND)
        set(OPENCL_ENABLED TRUE)
        message(STATUS "OpenCL support enabled")
    else()
        message(WARNING "OpenCL not found - GPU acceleration disabled")
    endif()
endif()

# DirectML (Windows only)
if(PLATFORM_WINDOWS AND ENABLE_DIRECTML)
    find_package(DirectML QUIET)
    if(DirectML_FOUND)
        set(DIRECTML_ENABLED TRUE)
        message(STATUS "DirectML support enabled")
    else()
        message(WARNING "DirectML not found - AI features disabled")
    endif()
endif()

# Compiler-specific flags
if(CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /W4 /WX- /permissive-")
    set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} /O2 /DNDEBUG")
elseif(CMAKE_CXX_COMPILER_ID STREQUAL "GNU" OR CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -Wextra -pedantic")
    set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -O3 -DNDEBUG")
endif()

# Source files
set(CORE_SOURCES
    src/core/Application.cpp
    src/core/ConfigManager.cpp
    src/core/ImageProcessor.cpp
    src/core/RAWProcessor.cpp
    src/core/ColorManager.cpp
    src/core/CurveEditor.cpp
    src/core/FormatCodec.cpp
    src/core/MetadataReader.cpp
    src/core/MemoryManager.cpp
    src/core/ThreadManager.cpp
    src/core/PerformanceProfiler.cpp
    src/core/PluginManager.cpp
)

set(GPU_SOURCES
    src/gpu/GPUManager.cpp
    src/gpu/OpenCLProcessor.cpp
    src/gpu/KernelManager.cpp
)

if(DIRECTML_ENABLED)
    list(APPEND GPU_SOURCES src/gpu/DirectMLProcessor.cpp)
endif()

set(UI_SOURCES
    src/ui/MainWindow.cpp
    src/ui/ImageViewer.cpp
    src/ui/CurveWidget.cpp
    src/ui/ColorPicker.cpp
    src/ui/ToolPalette.cpp
    src/ui/AdjustmentPanel.cpp
    src/ui/FileManager.cpp
    src/ui/PreferencesDialog.cpp
)

set(API_SOURCES
    src/api/PublicAPI.cpp
    src/api/PluginInterface.cpp
    src/api/ScriptEngine.cpp
)

# Main executable
add_executable(PhotoStudioPro
    src/main.cpp
    ${CORE_SOURCES}
    ${GPU_SOURCES}
    ${UI_SOURCES}
    ${API_SOURCES}
)

# Link libraries
target_link_libraries(PhotoStudioPro
    Qt6::Core
    Qt6::Widgets
    Qt6::Quick
    Qt6::Qml
    Qt6::OpenGL
    ${OpenCV_LIBS}
    ${LIBRAW_LIBRARIES}
    ${LCMS2_LIBRARIES}
)

if(OPENCL_ENABLED)
    target_link_libraries(PhotoStudioPro OpenCL::OpenCL)
    target_compile_definitions(PhotoStudioPro PRIVATE OPENCL_ENABLED)
endif()

if(DIRECTML_ENABLED)
    target_link_libraries(PhotoStudioPro DirectML::DirectML)
    target_compile_definitions(PhotoStudioPro PRIVATE DIRECTML_ENABLED)
endif()

# Include directories
target_include_directories(PhotoStudioPro PRIVATE
    src/
    ${OpenCV_INCLUDE_DIRS}
    ${LIBRAW_INCLUDE_DIRS}
    ${LCMS2_INCLUDE_DIRS}
)

# Compile definitions
target_compile_definitions(PhotoStudioPro PRIVATE
    QT_NO_DEPRECATED_WARNINGS
    QT_DISABLE_DEPRECATED_BEFORE=0x060000
    APP_VERSION="${PROJECT_VERSION}"
)

# Resources
qt6_add_resources(PhotoStudioPro "resources"
    PREFIX "/"
    FILES
        assets/icons/app_icon.svg
        assets/themes/dark.qss
        assets/themes/light.qss
        assets/curves/presets.json
        assets/images/splash.png
)

# QML integration
qt6_add_qml_module(PhotoStudioPro
    URI PhotoStudio
    VERSION 1.0
    QML_FILES
        src/ui/qml/MainInterface.qml
        src/ui/qml/CurveEditor.qml
        src/ui/qml/ColorGrading.qml
        src/ui/qml/ImageViewer.qml
)

# SDK Library (optional)
if(BUILD_SDK)
    add_subdirectory(sdk)
endif()

# Plugins (optional)
if(BUILD_PLUGINS)
    add_subdirectory(plugins)
endif()

# Testing
if(ENABLE_TESTING)
    enable_testing()
    add_subdirectory(tests)
endif()

# Installation
install(TARGETS PhotoStudioPro
    BUNDLE DESTINATION .
    LIBRARY DESTINATION lib
    RUNTIME DESTINATION bin
)

# Platform-specific packaging
include(CPack)

if(PLATFORM_WINDOWS)
    set(CPACK_GENERATOR "NSIS")
    set(CPACK_NSIS_DISPLAY_NAME "PhotoStudio Pro")
elseif(PLATFORM_MACOS)
    set(CPACK_GENERATOR "DragNDrop")
    set(CPACK_DMG_VOLUME_NAME "PhotoStudio Pro")
elseif(PLATFORM_LINUX)
    set(CPACK_GENERATOR "DEB;RPM")
    set(CPACK_DEBIAN_PACKAGE_MAINTAINER "PhotoStudio Team")
endif()

# Print configuration summary
message(STATUS "Configuration Summary:")
message(STATUS "  Build Type: ${CMAKE_BUILD_TYPE}")
message(STATUS "  Qt Version: ${Qt6_VERSION}")
message(STATUS "  OpenCV Version: ${OpenCV_VERSION}")
message(STATUS "  OpenCL: ${OPENCL_ENABLED}")
message(STATUS "  DirectML: ${DIRECTML_ENABLED}")
message(STATUS "  Testing: ${ENABLE_TESTING}")
message(STATUS "  SDK: ${BUILD_SDK}")
message(STATUS "  Plugins: ${BUILD_PLUGINS}")