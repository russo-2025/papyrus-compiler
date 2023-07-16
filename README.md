# Compiler

Open source compiler for the Papyrus scripting language used in Skyrim Special Edition. ***Work in progress.***

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

read           converts pex file into a readable format and outputs it to console

disassembly     converts pex file into a readable format and writes result to file

create-dump    ...
```

#### Сompile command arguments:

```
-i, -input      folder with files(*.psc) to compile

-o, -output     folder for compiled files(*.pex)

-h, -headers-dir  folder with header files

-nocache        compile all files, regardless of the modification date

-original       compile using a vanilla compiler

-silent         disable output of messages and errors to console

-silent         disable output of messages and errors to console

-verbose        ...TODO

-stats          ...TODO

-use-threads    use threads to generate files
```

#### Examples:

```
papyrus compile -nocache -i "D:\Steam\steamapps\common\Skyrim Special Edition\Data\Scripts\Source" -o "../test-files/compiled/skyrimSources"
papyrus compile -nocache -i "../test-files/compiler" -o "../test-files/compiled"
papyrus compile -i "../../RH-workspace/scripts" -o ""../../RH-workspace/compiled""
papyrus read "../test-files/compiled/ABCD.pex"
papyrus create-dump "../folder_with_pex_files"
```

## Links

- [VS Code Extension: Papyrus Language Tools](https://github.com/joelday/papyrus-lang)
- [Creation Kit Papyrus Reference](https://www.creationkit.com/index.php?title=Category:Papyrus)
- [Compiled Script File Format](https://en.uesp.net/wiki/Skyrim_Mod:Compiled_Script_File_Format)
- [Caprica](https://github.com/Orvid/Caprica)
A compiler for the Papyrus scripting language used by the Creation Engine.
- [Champollion](https://github.com/Orvid/Champollion)
A PEX to Papyrus Decompiler for Fallout 4
- [PapyrusDotNet](https://github.com/zerratar/PapyrusDotNet)
PapyrusDotNet - A .NET Papyrus Compiler for Fallout 4 and Skyrim
- [open-papyrus/docs](https://open-papyrus.github.io/docs/Papyrus_Language_Reference/index.html)
- [open-papyrus/papyrus-compiler](https://github.com/open-papyrus/papyrus-compiler) - (WIP, Rust lang) Open-source compiler for the Papyrus scripting language of Bethesda games.


