## Next release
- ...

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
