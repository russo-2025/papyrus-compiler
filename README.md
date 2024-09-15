# Papyrus Compiler

An open-source compiler for the Papyrus scripting language. Currently, the compiler only supports Skyrim (tested on Skyrim SE/AE).

The compiler was created for the following purposes:
1. **Understanding Programming Languages:** The project is designed to gain a deeper understanding of how programming languages work.
2. **Experimenting with the V Language:** It uses the V programming language for implementation.
3. **Speeding Up Compilation:** The standard Papyrus compiler is very slow, so this project aims to optimize that process.
4. **Improved Error Messages:** Provides higher quality and more understandable error messages to simplify debugging.

## Сontent
- [Usage](#usage)
  - [Commands](#commands)
  - [Arguments for the `compile` command](#arguments-for-the-compile-command)
  - [Examples](#examples)
  - [Header/Import Files](#headerimport-files)
- [Building](#building)
  - [Requirements](#requirements)
- [Testing](#testing)
- [References](#references)

## Usage
1. Download the archive with the compiler from the [Github Releases](https://github.com/russo-2025/papyrus-compiler/releases) page and extract it.
2. Open a console in the directory where you extracted the compiler.
3. Use the following syntax to work with the compiler:

```
papyrus <command> [arguments]
```

### Commands:
- `compile`: Compiles `.psc` files into the binary `.pex` format.
- `read`: Reads a `.pex` file and outputs its contents in a human-readable format to the console.
- `disassemble`: Disassembles a `.pex` file and saves the result to a text file.
- `create-dump`: Creates a JSON file `dump.json` with information about `.pex` files in the specified directory.

### Arguments for the `compile` command:
The following arguments can be used with the `compile` command:

- `-i`, `-input`: Specifies the directory with `.psc` files or a `.psc` file to compile.
- `-o`, `-output`: Specifies the directory where the compiled `.pex` files will be placed.
- `-h`, `-headers-dir`: Specifies the directory with `.psc` header/import files that will be analyzed by the compiler but not compiled. Used to let the compiler know about existing scripts (`Form`, `ObjectReference`, `Actor`, ...) and their methods/functions/properties/variables. See the "Header/Import Files" section.
- `-nocache`: Ignores the cache and forces compilation of all files.
- `-silent`: Disables output of error messages to the console.
- `-original`: Uses the original Papyrus compiler for compilation.
- `-stats`: Saves statistics on compiled files to .md files (number of function calls, inheritances, files).
- `-check`: Checks the syntax of .psc files without generating .pex files.
- `-verbose`: ...

### Examples
Below are several examples demonstrating the use of various compiler commands and arguments for compiling scripts, reading compiled scripts, etc.

#### Compile all scripts in a directory, ignoring the cache:
```bash
papyrus compile -nocache -i "D:\Steam\steamapps\common\Skyrim Special Edition\Data\Scripts\Source" -o "../test-files/compiled/skyrimSources"
```
This command compiles all scripts (ignoring the cache) located in `D:\Steam\steamapps\common\Skyrim Special Edition\Data\Scripts\Source` and places the compiled `.pex` files in the `../test-files/compiled/skyrimSources` directory.

#### Compile all scripts in a directory:
```bash
papyrus compile -i "../../RH-workspace/scripts" -o "../../RH-workspace/compiled"
```
This command compiles all scripts located in `../../RH-workspace/scripts` and places the compiled `.pex` files in the `../../RH-workspace/compiled` directory.

#### Compile scripts using header/import files:
```bash
papyrus compile -nocache -h "D:\Steam\steamapps\common\Skyrim Special Edition\Data\Scripts\Source" -i "../test-files/compiler" -o "../test-files/compiled" 
```
This command will compile all scripts from the `../test-files/compiler` directory to the `../test-files/compiled` directory, and missing information about objects (`Form`, `ObjectReference`, `Actor`, etc.) will be taken from `.psc` files in the `D:\Steam\steamapps\common\Skyrim Special Edition\Data\Scripts\Source` directory.

#### Reading a compiled `.pex` file:
```bash
papyrus read "../test-files/compiled/ABCD.pex"
```

#### Creating a JSON dump of `.pex` files:
```bash
papyrus create-dump "../folder_with_pex_files"
```
Creates a JSON file `dump.json` containing some information about all `.pex` files located in the `../folder_with_pex_files` directory. Here's what it will look like:
```json
[
  {
    "name": "ActiveMagicEffect",
    "parent_name": "",
    "methods": [
      {
        "name": "RegisterForUpdate",
        "arguments": [
          {
            "name": "afInterval",
            "type": "Float"
          }
        ],
        "return_type": "None",
        "is_native": true,
        "is_global": false
      }
    ],
    "global_functions": [...]
  },
  ...
]
```

### Header/Import Files
By default, the compiler is unaware of existing scripts (`Form`, `ObjectReference`, `Actor`, etc.), their inheritance (`ObjectReference` -> `Form`), and available methods/functions/properties/variables.

You can fix this in two ways:
1. Specify the path to the directory with the original scripts (e.g., `..\Skyrim\Data\Scripts\Source`) using the `-h "..."` argument.
2. Create a directory with header files indicating existing objects and their methods, functions, etc., and specify it using the `-h "..."` argument.

Example of the `Actor.psc` header file:
```papyrus
ScriptName Actor extends ObjectReference

Function EquipItem(Form akItem, bool abPreventRemoval = false, bool abSilent = false) native
```

By analyzing this file, the compiler learns about the existence of the `Actor` object, its inheritance from `ObjectReference`, and the presence of the `EquipItem` function with the corresponding arguments (some of which have default values). The `native` flag allows skipping the writing of the function body in the header file, as these scripts are used only for analysis. This significantly speeds up compilation.

Scripts from the directory specified by the `-h "..."` argument will NOT be compiled and placed in the directory specified by `-o "..."`.

## Building

### Requirements:
- [V compiler da228e9 (weekly.2024.36)](https://github.com/vlang/v/releases/tag/weekly.2024.36)

```bash
v -o "bin\papyrus.exe" -prod -gc none compiler.v
```

## Testing

```bash
v -stats test modules
```

## References
- [VS Code Extension: Papyrus Language Tools](https://github.com/joelday/papyrus-lang)
- [Creation Kit Papyrus Reference](https://www.creationkit.com/index.php?title=Category:Papyrus)
- [Compiled Script File Format](https://en.uesp.net/wiki/Skyrim_Mod:Compiled_Script_File_Format)
- [Caprica](https://github.com/Orvid/Caprica) - A compiler for the Papyrus scripting language used by the Creation Engine.
- [Champollion](https://github.com/Orvid/Champollion) - A PEX to Papyrus Decompiler for Fallout 4
- [PapyrusDotNet](https://github.com/zerratar/PapyrusDotNet) - PapyrusDotNet - A .NET Papyrus Compiler for Fallout 4 and Skyrim
- [Open Papyrus - Docs](https://open-papyrus.github.io/docs/Papyrus_Language_Reference/index.html)
- [Open Papyrus - Compiler](https://github.com/open-papyrus/papyrus-compiler) - (WIP, Rust lang) Open-source compiler for the Papyrus scripting language of Bethesda games.