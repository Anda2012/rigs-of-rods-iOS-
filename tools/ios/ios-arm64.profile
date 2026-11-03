# Conan 2 profile for building Rigs of Rods dependencies for a physical iOS device (arm64).
# Use:  conan install . -pr:h=tools/ios/ios-arm64.profile -pr:b=default --build=missing -of build-ios
# Needs macOS + Xcode (xcrun --sdk iphoneos must work).
[settings]
os=iOS
os.version=15.0
os.sdk=iphoneos
arch=armv8
compiler=apple-clang
compiler.version=15
compiler.libcxx=libc++
compiler.cppstd=17
build_type=Release

[options]
*:shared=False

[conf]
tools.cmake.cmaketoolchain:system_name=iOS
tools.apple:enable_bitcode=False
tools.apple:enable_arc=True
