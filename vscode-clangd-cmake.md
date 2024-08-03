# How to configure clangd C++ intellisense in CMake project

Use this in .vscode/settings.json, note that we disable the annoying automatic header insertion feature.

In this example, cmake outputs to different build directories based on build type, and then `compile_commands.json` is copied to the `./build` dir, so that it can be found by clangd even if the build directory is elsewhere.

```json
{
    "clangd.arguments": [
        "--background-index",
        "--compile-commands-dir=${workspaceFolder}/build",
        "--header-insertion=never",
    ],
    "cmake.buildDirectory": "${workspaceFolder}/build/${buildType}",
    "cmake.copyCompileCommands": "${workspaceFolder}/build/compile_commands.json",
    "cmake.preferredGenerators": [
        "Ninja"
    ],
}
```

Make sure your cmake is using [Ninja](https://github.com/ninja-build/ninja) as build system.

In your cmake, make sure you have output compile_commands.json

```cmake
# export compile commands
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
```

