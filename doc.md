# Usage

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