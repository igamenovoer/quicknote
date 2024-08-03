# How to configure clangd C++ intellisense in CMake project

Use this in .vscode/settings.json

```json
{
    "clangd.arguments": [
        "--background-index",
        "--compile-commands-dir=${cmake.buildDirectory}"
    ],
    "cmake.preferredGenerators": [
        "Ninja"
    ]
}
```
Make sure your cmake is using [Ninja](https://github.com/ninja-build/ninja) as build system.

In your cmake, make sure you output compile_commands.json

```cmake
# export compile commands
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
```

