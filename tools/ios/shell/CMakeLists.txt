cmake_minimum_required(VERSION 3.24)
project(RigsOfRodsIOSShell LANGUAGES C OBJC)

set(CMAKE_OSX_DEPLOYMENT_TARGET "15.0" CACHE STRING "Minimum iOS version")
set(CMAKE_OSX_ARCHITECTURES "arm64" CACHE STRING "iOS device architecture")

add_executable(RoR-iOS-Shell MACOSX_BUNDLE
    main.m
    AppDelegate.m
)

set_target_properties(RoR-iOS-Shell PROPERTIES
    MACOSX_BUNDLE_INFO_PLIST "${CMAKE_CURRENT_SOURCE_DIR}/Info.plist"
    XCODE_ATTRIBUTE_TARGETED_DEVICE_FAMILY "1,2"
    XCODE_ATTRIBUTE_CODE_SIGNING_ALLOWED "NO"
    XCODE_ATTRIBUTE_CODE_SIGNING_REQUIRED "NO"
    XCODE_ATTRIBUTE_CLANG_ENABLE_OBJC_ARC "YES"
)

target_link_libraries(RoR-iOS-Shell PRIVATE "-framework UIKit")
