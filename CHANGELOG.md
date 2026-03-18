## Next Release

### New Features

- Added support for multiple output directories - you can now specify multiple `-o` flags to copy compiled .pex files to multiple locations. #18

...

## V 0.0.4

### New Features

- Added `version` command — run `papyrus version` to display the current compiler version.
- String literals are now accepted as default values for typed properties and function parameters and are automatically converted to the declared type.
  ```
  int Property MyProp = "123" Auto  ; now valid — "123" is converted to 123
  ```
  ```
  Int Function MyFunc(int n1, int n2 = "12")  ; "12" is converted to 12
  EndFunction
  ```

### Improvements

- The compiler now reports an error when a script referenced in `extends` or a variable type cannot be found, instead of failing silently.
- The compiler now reports an error when two scripts with the same name are found in different source folders.
- Added a check that the script name declared in `Scriptname` matches the source file name.
- Default parameter values are now validated to be type-compatible with the declared parameter type.
- Improved error messages to be clearer and more consistent (e.g., "undefined identifier" instead of "variable declaration not found").
- Internal compiler errors now display a structured diagnostic message with version info, a stack trace, and instructions for reporting the issue, instead of crashing with an unhelpful message.

### Fixes

- Fixed incorrect handling of `None` as a default value in properties and function parameters.
- Fixed a compiler crash when `None` was used in arithmetic or logical expressions (e.g., `None + 1`). A proper error message is now shown instead.
- Fixed a compiler crash when an undefined script type was used in expressions that require conversion (for example, `value && true` where `value` has an unknown type). The compiler now reports an undefined type error instead of crashing.
- Fixed an issue where calling a function with default parameters inside a `State` block was not validated correctly (#14).
- Fixed parsing of comments inside parenthesized expressions and call argument lists (for example, `if !(PlayerRef ;/comment/;)`). The compiler now accepts these scripts instead of failing with a parser error.

## V 0.0.3

### Fixes

- **Logical Operators Fix**
  - Fixed `&&` and `||` operators to evaluate expressions correctly.

## V 0.0.2

### Improvements

- **Error Messaging Improvements**
  - Enhanced and added error messages for missing or incorrect arguments when using the console.
  - Fixed the error message when attempting to call a function with fewer arguments than required.

- **Compatibility Enhancements**
  - Improved and fixed compatibility with the latest V compiler version [V compiler f3d2eb1 (weekly.2025.09)](https://github.com/vlang/v/releases/tag/weekly.2025.09).

### Fixes

- **Dependency Resolution During Casting**
  - Fixed an issue with dependency resolution during casting operations, such as `DialogueGenericVampire as VampireQuestScript`. (#8)

## V 0.0.1

### Improvements

- **Header File Parsing Enhanced**
  - Header files are now parsed selectively. For instance, if you only use `Form` and `Game`, only these headers will be parsed from the directories.
  - Header search paths now include folders from the `-i "..."` arguments. For instance, if `-i "src/MyPapyrusFile.psc"` is specified, the `src` folder is added to the search paths.
  - The default search path no longer includes `bin\papyrus-headers`.
  - The `bin\papyrus-headers` folder has been removed.

- **Updated `-i` Argument Handling**
  - The `-i "..."` argument now supports both source directories and specific source files. For example: `-i "src/MyPapyrusFile.psc"`.

- **Improved Original Compiler Integration**
  - Arguments `-i`, `-h`, and `-o` are now passed to the original compiler more accurately when using the `-original` flag.

- **Compatibility Enhancements**
  - Improved and fixed compatibility with the latest V compiler version [V compiler da228e9 (weekly.2024.36)](https://github.com/vlang/v/releases/tag/weekly.2024.36).

- **New Arguments Added**
  - Added the `-check` argument.
  - Added the `-stats` argument.

- **CI/CD and Benchmarking**

### Fixes

- **Line Number Display Bug Fix**
  - Fixed the bug related to incorrect line number display.
