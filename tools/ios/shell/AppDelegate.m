name: iOS build (experimental)
# Default branch builds a working UIKit shell; the full game remains an opt-in experimental port.
on:
  workflow_dispatch:
    inputs:
      attempt_full_game_build:
        description: "Attempt the incomplete full-game iOS build (expected to fail until dependencies and porting work are fixed)"
        required: false
        type: boolean
        default: false
  push:
    branches: [ios-port, ios-port-scaffold]

jobs:
  ios-shell:
    name: Build launchable UIKit shell
    runs-on: macos-14
    steps:
      - uses: actions/checkout@v4
        with: { submodules: recursive }

      - name: Configure shell app
        run: >-
          cmake -S tools/ios/shell -B build-ios-shell -G Xcode
          -DCMAKE_SYSTEM_NAME=iOS
          -DCMAKE_OSX_DEPLOYMENT_TARGET=15.0
          -DCMAKE_OSX_ARCHITECTURES=arm64
          -DCMAKE_XCODE_ATTRIBUTE_CODE_SIGNING_ALLOWED=NO
          -DCMAKE_XCODE_ATTRIBUTE_CODE_SIGNING_REQUIRED=NO
          -DCMAKE_XCODE_ATTRIBUTE_ENABLE_BITCODE=NO

      - name: Build shell app
        run: >-
          cmake --build build-ios-shell --config Release -- -sdk iphoneos
          CODE_SIGNING_ALLOWED=NO

      - name: Package shell IPA
        shell: bash
        run: |
          APP="$(find build-ios-shell -path '*Release-iphoneos/*.app' -type d -print -quit)"
          test -n "$APP" || { echo "No .app bundle found" >&2; exit 1; }
          tools/ios/make_ipa.sh "$APP" RigsOfRods-iOS-Shell.ipa

      - uses: actions/upload-artifact@v4
        with:
          name: RigsOfRods-iOS-shell-unsigned-ipa
          path: RigsOfRods-iOS-Shell.ipa
          if-no-files-found: error

  game-build:
    name: Experimental full game build (incomplete port)
    if: github.event_name == 'workflow_dispatch' && inputs.attempt_full_game_build
    runs-on: macos-14
    steps:
      - uses: actions/checkout@v4
        with: { submodules: recursive }

      - name: Install tooling
        run: |
          pip3 install --break-system-packages conan cmake ninja || pip3 install conan cmake ninja
          conan profile detect --force

      - name: Add Rigs of Rods Conan dependencies remote
        run: conan remote add rigs-of-rods-deps https://conan.cloudsmith.io/rigs-of-rods/deps/ --force

      - name: Build dependencies (iOS arm64; known to require recipe fixes)
        run: conan install . -pr:h=tools/ios/ios-arm64.profile -pr:b=default --build=missing -of build-ios

      - name: Configure game
        run: |
          cmake -S . -B build-ios -G Xcode \
            -DCMAKE_TOOLCHAIN_FILE=build-ios/generators/conan_toolchain.cmake \
            -DCMAKE_SYSTEM_NAME=iOS -DCMAKE_OSX_DEPLOYMENT_TARGET=15.0 \
            -DCMAKE_OSX_ARCHITECTURES=arm64 -DROR_USE_PCH=OFF \
            -DCMAKE_XCODE_ATTRIBUTE_CODE_SIGNING_ALLOWED=NO \
            -DCMAKE_XCODE_ATTRIBUTE_CODE_SIGNING_REQUIRED=NO

      - name: Build game
        run: cmake --build build-ios --config Release -- -sdk iphoneos CODE_SIGNING_ALLOWED=NO

      - name: Package game IPA
        shell: bash
        run: |
          APP="$(find build-ios -path '*Release-iphoneos/*.app' -type d -print -quit)"
          test -n "$APP" || { echo "No .app bundle found" >&2; exit 1; }
          tools/ios/make_ipa.sh "$APP" RigsOfRods-iOS.ipa

      - uses: actions/upload-artifact@v4
        with:
          name: RigsOfRods-iOS-game-unsigned-ipa
          path: RigsOfRods-iOS.ipa
