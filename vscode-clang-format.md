# How to use clang-format to unify your coding style

In vscode, install [clang-format plugin](https://github.com/xaverh/vscode-clang-format), and set your formatter to this plugin ([how?](https://stackoverflow.com/questions/30064480/how-do-you-change-the-formatting-options-in-visual-studio-code)).

NOTE: Make sure you DO NOT use `clangd` for formatting, it does not work, use the `clang-format` plugin instead.

In your system, install `clang-format`
- linux: use `apt install clang-format`
- windows: install [llvm](https://llvm.org/builds/), and add `clang-format` to your `PATH` environment

In your workspace, create a `.clang-format` file, and use the followings ([apple style](https://github.com/haaakon/Apple-clang-format)).

```yaml
Language: Cpp
AccessModifierOffset: -2
AlignEscapedNewlinesLeft: false
AlignTrailingComments: true
AllowAllParametersOfDeclarationOnNextLine: true
AllowShortFunctionsOnASingleLine: false
AllowShortIfStatementsOnASingleLine: false
AllowShortLoopsOnASingleLine: false
AlwaysBreakBeforeMultilineStrings: false
AlwaysBreakTemplateDeclarations: false
BinPackParameters: true
BreakBeforeBinaryOperators: false
BreakBeforeBraces: Linux
BreakBeforeTernaryOperators: true
BreakConstructorInitializersBeforeComma: false
ColumnLimit: 0
CommentPragmas: '^ IWYU pragma:'
ConstructorInitializerAllOnOneLineOrOnePerLine: false
ConstructorInitializerIndentWidth: 4
ContinuationIndentWidth: 4
Cpp11BracedListStyle: true
DerivePointerBinding: false
ExperimentalAutoDetectBinPacking: false
IndentCaseLabels: true
IndentFunctionDeclarationAfterType: true
IndentWidth: 4
MaxEmptyLinesToKeep: 2
NamespaceIndentation: None
ObjCSpaceAfterProperty: true
ObjCSpaceBeforeProtocolList: true
ObjCBlockIndentWidth: 4
PenaltyBreakBeforeFirstCallParameter: 19
PenaltyBreakComment: 300
PenaltyBreakFirstLessLess: 120
PenaltyBreakString: 1000
PenaltyExcessCharacter: 1000000
PenaltyReturnTypeOnItsOwnLine: 60
PointerBindsToType: false
SpaceBeforeAssignmentOperators: true
SpaceBeforeParens: ControlStatements
SpaceInEmptyParentheses: false
SpacesBeforeTrailingComments: 1
SpacesInAngles: false
SpacesInContainerLiterals: true
SpacesInCStyleCastParentheses: false
SpacesInParentheses: false
Standard: Cpp11
TabWidth: 8
UseTab: Never
```

In your `.vscode/settings.json` (or the global user settings), use this to format the code each time you press ctrl+s.

This setting only formats c++ automatically, for other options, see this [stackoverflow](https://stackoverflow.com/questions/44831313/how-to-exclude-file-extensions-and-languages-from-format-on-save-in-vscode) and the [language identifiers](https://code.visualstudio.com/docs/languages/identifiers)

```json
{
    "[cpp]": {
        "editor.formatOnSave": true
    }
}
```
