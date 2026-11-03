# iOS app shell

This standalone UIKit target is a Phase 1 launchable app shell, separated from the game's native dependencies so CI can validate and package the iOS app-bundle path before the engine port is ready. It displays a status screen and does **not** run the Rigs of Rods game.

Configure and build on a macOS GitHub Actions runner with Xcode:

```sh
cmake -S tools/ios/shell -B build-ios-shell -G Xcode \
  -DCMAKE_SYSTEM_NAME=iOS -DCMAKE_OSX_DEPLOYMENT_TARGET=15.0 \
  -DCMAKE_OSX_ARCHITECTURES=arm64
cmake --build build-ios-shell --config Release -- -sdk iphoneos CODE_SIGNING_ALLOWED=NO
```

The resulting unsigned IPA is a CI artifact for testing/re-signing; it is not a signed App Store app. Phase 2 must connect the game's C++ initialization and frame loop, iOS lifecycle/render surface, input, and platform-specific dependencies.
