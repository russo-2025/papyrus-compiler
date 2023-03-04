# Compiler

The Papyrus compiler is based on the [V language compiler](https://github.com/vlang/v/tree/master/vlib/v). Work in progress.

## Prerequisites

  - [V compiler e9a3817(weekly.2023.08)](https://github.com/vlang/v/releases/tag/weekly.2023.08)
  - Visual Studio

## Building

```bash
v -o "bin\papyrus.exe" -prod -gc none compiler.v
```

## Testing

```bash
v -stats test modules
```

## Usage

```papyrus <command> [arguments]```

#### Commands:

```
compile        compile papyrus files

read           read "*.pex" file and output result to console
```

#### Сompile command arguments:

```
-i, -input      folder with files(*.psc) to compile

-o, -output     folder for compiled files(*.pex)

-h, -headers_dir  ...

-nocache        compile all files, regardless of the modification date

-original       compile using a vanilla compiler

-silent         disable output of messages and errors to console

-verbose
```

#### Examples:

```
papyrus compile -nocache -i "../test-files/compiler" -o "../test-files/compiled"
papyrus compile -i "../../RH-workspace/scripts" -o ""../../RH-workspace/compiled""
papyrus read "../test-files/compiled/ABCD.pex"
```

## List of supported language features

- [x] **Script header line**
  - [x] `Extends`
  - [x] flags
- [x] **Literals** [docs](https://www.creationkit.com/index.php?title=Literals_Reference)
  - [x] boolean
  - [x] integer
  - [x] float
  - [x] string
  - [x] none
- [x] **Operators** [docs](https://www.creationkit.com/index.php?title=Operator_Reference)
  - [x] `= += -= *= /= %=`
  - [x] `+  - *  /  %`
  - [x] ` == != >  <  >= <= || &&`
  - [x] `! () [] , .  ""`
  - [x] casts [docs](https://www.creationkit.com/index.php?title=Cast_Reference)
- [x] **Variables** [docs](https://www.creationkit.com/index.php?title=Variable_Reference)
  - [x] declaration
  - [x] assign
  - [x] object variables
  - [x] function variables
  - [x] default values
- [x] **Arrays** [docs 1](https://www.creationkit.com/index.php?title=Array_Reference) [docs 2](https://www.creationkit.com/index.php?title=Arrays_(Papyrus))
  - [x] declaration
  - [x] constructor
  - [x] length
  - [x] array acces
  - [x] find
- [x] **If** [docs](https://www.creationkit.com/index.php?title=Statement_Reference#If_Statement)
- [x] **While** [docs](https://www.creationkit.com/index.php?title=Statement_Reference#While_Statement)
  - [ ] Variable Lifetime??? [docs](https://www.creationkit.com/index.php?title=Statement_Reference#While_and_Variable_Lifetime)
- [x] **Functions** [docs](https://www.creationkit.com/index.php?title=Function_Reference)
  - [x] declaration
  - [x] flags
    - [x] `Global`
    - [x] `Native`
  - [x] special variables (`Self`, `Parent`)
  - [x] default arguments `Function IncrementValue(int howMuch = 1)` `CallFunc(5.0, 2.4, d = 2.0)`
  - [x] `return`
- [x] **Events** [docs](https://www.creationkit.com/index.php?title=Events_Reference)
  - [x] declaration
  - [x] special variables (`Self`, `Parent`) 
  - [x] calling
- [x] **Properties** [docs](https://www.creationkit.com/index.php?title=Property_Reference)
  - [x] declaration
  - [x] read only
  - [x] assign
  - [x] flags
    - [x] `Hidden`
    - [x] `Conditional`
    - [x] `Auto`
    - [x] `AutoReadOnly`
- [x] **States** [docs](https://www.creationkit.com/index.php?title=State_Reference)
  - [x] declaration
  - [x] flag `auto`
  - [x] empty state
  - [x] `OnBeginState`
  - [x] switching states `GotoState`
  - [x] getting current state `GetState`
  - [x] `onEndState`
  - [ ] effect of states on functions and events???
- [ ] **Imports** [docs 1](https://www.creationkit.com/index.php?title=Script_File_Structure#Imports) [docs 2](https://www.creationkit.com/index.php?title=Function_Reference#Calling_Functions)
- [x] **Comments**
  - [x] single line
  - [x] multi line
  - [ ] documentation comments
- [x] **Line Terminators** `\` [docs](https://www.creationkit.com/index.php?title=Script_File_Structure#Line_Terminators)

## Links

- [Creation Kit Papyrus Reference](https://www.creationkit.com/index.php?title=Category:Papyrus)
- [Compiled Script File Format](https://en.uesp.net/wiki/Skyrim_Mod:Compiled_Script_File_Format)
- [Caprica](https://github.com/Orvid/Caprica)
A compiler for the Papyrus scripting language used by the Creation Engine.
- [Champollion](https://github.com/Orvid/Champollion)
A PEX to Papyrus Decompiler for Fallout 4
- [PapyrusDotNet](https://github.com/zerratar/PapyrusDotNet)
PapyrusDotNet - A .NET Papyrus Compiler for Fallout 4 and Skyrim
- [papyrus-compiler](https://github.com/open-papyrus/papyrus-compiler) - (WIP, Rust lang) Open-source compiler for the Papyrus scripting language of Bethesda games.