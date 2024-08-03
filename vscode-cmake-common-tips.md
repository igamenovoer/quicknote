# Some tips about using CMake in vscode

## Change build directories based on build type

This is useful when you switch between build types a lot, can save your building time.
In .vscode/settings.json, add this
```json
{
  ...
  "cmake.buildDirectory": "${workspaceFolder}/build/${buildType}",
}
```
