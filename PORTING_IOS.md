# Rigs of Rods → iOS port (work in progress)

Target: an unsigned `.ipa` that runs inside LiveContainer. This is experimental build scaffolding, not a working iOS port; no iOS build has been verified.

## Build prerequisites
A macOS machine with Xcode, Conan 2, CMake, and Ninja. Custom Conan recipes and several engine dependencies may need iOS support work before dependency installation succeeds.

## Build commands
```sh
pip install conan
conan profile detect
conan install . -pr:h=tools/ios/ios-arm64.profile -pr:b=default --build=missing -of build-ios
cmake -S . -B build-ios -G Xcode -DCMAKE_TOOLCHAIN_FILE=build-ios/generators/conan_toolchain.cmake \
  -DCMAKE_SYSTEM_NAME=iOS -DCMAKE_OSX_DEPLOYMENT_TARGET=15.0 -DCMAKE_OSX_ARCHITECTURES=arm64 -DROR_USE_PCH=OFF
cmake --build build-ios --config Release -- -sdk iphoneos CODE_SIGNING_ALLOWED=NO
tools/ios/make_ipa.sh build-ios/bin/Release-iphoneos/RoR.app
```

This scaffold does not yet implement the iOS app entry point/window and event loop, touch input, iOS user-directory handling, or shader conversion. OGRE static plugin integration and all dependency recipes need verification. See the repository's experimental iOS workflow for an attempted macOS CI build.

The project is GPLv3; provide corresponding source when distributing binaries.
