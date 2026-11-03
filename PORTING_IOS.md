# Rigs of Rods → iOS port (work in progress)

Target: an unsigned `.ipa` that runs inside **LiveContainer** (JIT-less mode; the app is re-signed by LiveContainer
with your SideStore/AltStore certificate). RoR needs no JIT: its physics is native code and AngelScript runs interpreted.

**Status: scaffolding only. Nothing here has been compiled for iOS yet.** The commit adds the build plumbing; the
real engineering work (below) is still open.

## What is done (this branch)
| Area | Change |
|---|---|
| CMake (root) | On `IOS`: `BUILD_SHARED_LIBS=OFF`, no base-content folder |
| `source/main/CMakeLists.txt` | iOS app bundle target (`tools/ios/Info.plist.in`), Apple frameworks instead of `X11`/`-lrt`, Mumble disabled, resources copied into the `.app` |
| `cmake/DependenciesConfig.cmake`, `conanfile.py` | Discord RPC skipped on iOS; all deps forced static |
| `AppContext.cpp/.h` | If OGRE is built static (`OGRE_STATIC_LIB`), plugins are registered via `Ogre::StaticPluginLoader` instead of `dlopen` through `plugins.cfg` (**class/namespace/header unverified against the custom OGRE 1.11.6.1 recipe**) |
| `tools/ios/` | Conan profile (`ios-arm64.profile`), `Info.plist.in`, `make_ipa.sh` |
| `.github/workflows/ios.yml` | macOS-runner build so no local Mac is needed (untested; expected to fail at dependency step first) |

## Known blockers, in the order you will hit them
1. **Dependencies.** `conanfile.py` uses custom recipes (`ogre3d`, `mygui`, `ogre3d-caelum`, `socketw`, `zziplib`, `ois`) from
   `anotherfoxguy` / `rigsofrods` that almost certainly have no iOS support. Each needs checking/forking. For OGRE:
   static build, `RenderSystem_GLES2`, an image codec that works on iOS (STBI or the iOS codec; FreeImage is not available),
   `Plugin_ParticleFX`, `Plugin_OctreeSceneManager`. Caelum must be registered as a static plugin too.
2. **Shaders.** `resources/` contains **24 Cg**, 19 HLSL and 12 GLSL shader files. Cg and HLSL do not exist on iOS, so the Cg
   programs (`general.cg`, `grass.cg`, `nicemetal.cg`, PSSM shadows, ...) must be rewritten as GLSL ES, or replaced by RTSS-generated shaders.
   `plugins.cfg.in` also lists `Plugin_CgProgramManager`, which has to go on iOS.
3. **Window and main loop.** `AppContext::SetUpRendering` creates the window with desktop assumptions. On iOS you need a `UIApplication`
   entry point, an EAGL/GLES view, and RoR's own `while` loop in `main.cpp` has to run from a `CADisplayLink` or a dedicated thread.
4. **Input.** OIS is referenced from ~20 files (`AppContext`, `CameraManager`, `GUIManager`, `OverlayWrapper`, AngelScript bindings...).
   Plan: keep OIS types as the internal event format, write an iOS backend that feeds them from touch + `GameController`
   (gamepad/keyboard), and add on-screen controls.
5. **Paths.** `sys_process_dir`, config/log/content dirs must point into the app's Documents folder (enable file sharing is already in Info.plist).
6. **Performance/memory.** Soft-body physics is heavy and multi-threaded; start with small terrains and light vehicles.

## Milestones
1. Dependencies build for iOS arm64 (CI green through `conan install`).
2. `RoR.app` links; launches and shows a blank GLES2 window on a device.
3. Main menu (MyGUI/ImGui) renders and takes touch.
4. Load a terrain + one vehicle; drive with a gamepad.
5. Touch controls, GLSL ES shader port, polish.

## Build (needs macOS + Xcode)
```
pip install conan
conan profile detect
conan install . -pr:h=tools/ios/ios-arm64.profile -pr:b=default --build=missing -of build-ios
cmake -S . -B build-ios -G Xcode -DCMAKE_TOOLCHAIN_FILE=build-ios/generators/conan_toolchain.cmake \
      -DCMAKE_SYSTEM_NAME=iOS -DCMAKE_OSX_DEPLOYMENT_TARGET=15.0 -DCMAKE_OSX_ARCHITECTURES=arm64 -DROR_USE_PCH=OFF
cmake --build build-ios --config Release -- -sdk iphoneos CODE_SIGNING_ALLOWED=NO
tools/ios/make_ipa.sh build-ios/bin/Release-iphoneos/RoR.app
```
Then in LiveContainer: **+** → pick the `.ipa` → launch.

Licence: GPLv3 (same as upstream); distribute source for any binaries you share.
