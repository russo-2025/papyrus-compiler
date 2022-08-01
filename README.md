# Compiler

The Papyrus compiler is based on the [V language compiler](https://github.com/vlang/v/tree/master/vlib/v), for use with [Skymp VM](https://github.com/skyrim-multiplayer/skymp/tree/main/skymp5-server/cpp/papyrus_vm_lib) (Not tested in Skyrim)

## Prerequisites

  - [V compiler (weekly.2022.30)](https://github.com/vlang/v/releases/tag/weekly.2022.30)

## Building

```bash
v -cc msvc -m64 -os windows -o "bin\papyrus.exe" -prod -compress -skip-unused -path "@vlib|@vmodules|modules" "compiler"
```

## Usage

```papyrus [command] [flags]```

### Examples:

```
papyrus -compile -nocache -i "../test-files/compiler" -o "../test-files/compiled"
papyrus -compile -nocache -crutches -i "../../RH-workspace/scripts" -o ""../../RH-workspace/compiled""
papyrus -read "../test-files/compiled/ABCD.pex"
```

### Commands:

```
-compile        `papyrus -compile [build flags]`

-read           read the`. pex ' file and outputs the result to the console
                    `papyrus -read "path-to-file.pex"`
```

### Flags:

```
-i, -input			folder with files(*.psc) to compile

-o, -output			folder for compiled files(*.pex)

-nocache			by default, the compiler checks the file modification date and compiles 
				        the file if it has changed. `-nocache` flag disables this behavior.

-crutches			replaces the hex number by calling the function `M.StringToInt`
                        `0xFF` -> `M.StringToInt("0xFF")`

-original			compiles files using a standard compiler
			        	(only the `-i` and `-o` flags are available)
```

## List of language syntax features

- [x] Script header line
  - [x] extends
  - [x] flags
- [x] Literals [docs](https://www.creationkit.com/index.php?title=Literals_Reference)
  - [x] boolean
  - [x] integer
  - [x] float
  - [x] string
    - [ ] `\n` Newline
    - [ ] `\t` Tab
    - [ ] `\\` Backslash
    - [ ] `\"` Double quote
  - [x] none
- [x] Operators [docs](https://www.creationkit.com/index.php?title=Operator_Reference)
  - [x] `= += -= *= /= %=`
  - [x] `+  - *  /  %`
  - [x] ` == != >  <  >= <= || &&`
  - [x] `! () [] , .  ""`
  - [x] casts [docs](https://www.creationkit.com/index.php?title=Cast_Reference)
- [x] Variables [docs](https://www.creationkit.com/index.php?title=Variable_Reference)
  - [x] declaration
  - [x] assign
  - [x] object variables
  - [x] function variables
  - [x] default values
- [x] Arrays [docs 1](https://www.creationkit.com/index.php?title=Array_Reference) [docs 2](https://www.creationkit.com/index.php?title=Arrays_(Papyrus))
  - [x] declaration
  - [x] constructor
  - [x] length
  - [x] array acces
  - [x] find
  - [ ] casting??? [docs](https://www.creationkit.com/index.php?title=Arrays_(Papyrus)#Casting_Arrays)
  - [ ] `MyObjectArray[iElement].Disable()`???
- [x] `if` [docs](https://www.creationkit.com/index.php?title=Statement_Reference#If_Statement)
- [x] `while` [docs](https://www.creationkit.com/index.php?title=Statement_Reference#While_Statement)
  - [ ] Variable Lifetime??? [docs](https://www.creationkit.com/index.php?title=Statement_Reference#While_and_Variable_Lifetime)
- [x] Functions [docs](https://www.creationkit.com/index.php?title=Function_Reference)
  - [x] declaration
  - [x] flags
    - [x] global
    - [x] native
  - [x] special variables (`Self`, `Parent`)
  - [x] calling
    - [x] method
    - [x] global
  - [x] default value `Function IncrementValue(int howMuch = 1)` `CallFunc(5.0, 2.4, d = 2.0)`
  - [x] `return`
- [x] Events [docs](https://www.creationkit.com/index.php?title=Events_Reference)
  - [x] declaration
  - [x] special variables (`Self`, `Parent`) 
  - [ ] calling???
- [x] Properties [docs](https://www.creationkit.com/index.php?title=Property_Reference)
  - [x] declaration
  - [x] read only
  - [x] assign
  - [ ] flags
    - [ ] Hidden
    - [ ] Conditional
    - [x] Auto
    - [x] AutoReadOnly
- [x] States [docs](https://www.creationkit.com/index.php?title=State_Reference)
  - [x] declaration
  - [ ] flag `auto` ...
  - [x] empty state (default)
  - [x] `OnBeginState`
  - [x] switching states `GotoState`
  - [x] getting current state `GetState`
  - [ ] effect of states on functions and events???
- [ ] Imports [docs 1](https://www.creationkit.com/index.php?title=Script_File_Structure#Imports) [docs 2](https://www.creationkit.com/index.php?title=Function_Reference#Calling_Functions)
- [x] Comments
  - [x] single line
  - [x] multi line
  - [ ] documentation comments
- [ ] Line Terminators `\` [docs](https://www.creationkit.com/index.php?title=Script_File_Structure#Line_Terminators)

## Links to similar projects

- [Caprica](https://github.com/Orvid/Caprica)
A compiler for the Papyrus scripting language used by the Creation Engine.
- [Champollion](https://github.com/Orvid/Champollion)
A PEX to Papyrus Decompiler for Fallout 4
- [PapyrusDotNet](https://github.com/zerratar/PapyrusDotNet)
PapyrusDotNet - A .NET Papyrus Compiler for Fallout 4 and Skyrim