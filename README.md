# Compiler

The Papyrus compiler is based on the [V language compiler](https://github.com/vlang/v/tree/master/vlib/v), for use with [Skymp VM](https://github.com/skyrim-multiplayer/skymp/tree/main/skymp5-server/cpp/papyrus_vm_lib) (Not tested in Skyrim)

## Prerequisites

* [V compiler (weekly.2021.33.2)](https://github.com/vlang/v/releases/tag/weekly.2021.33.2)

## Building

1. ```v -cc msvc -m64 -os windows -o "bin\papyrus.exe" -prod -compress -skip-unused -path "@vlib|@vmodules|modules" "compiler"```

## Usage

```papyrus [command] [arguments]```

### Examples:
```
papyrus -compile -nocache -i "../test-files/compiler" -o "../test-files/compiled"
papyrus -compile -nocache -crutches -i "../../RH-workspace/scripts" -o ""../../RH-workspace/compiled""
papyrus -read "../test-files/compiled/ABCD.pex"
```

### Commands:
```
-compile			`papyrus -compile [build flags]`
-read				read the`. pex ' file and outputs the result to the console
				`papyrus -read "path-to-file.pex"`
```

### Build flags:
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