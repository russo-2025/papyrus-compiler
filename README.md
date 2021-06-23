
## Compiler

The Papyrus compiler is based on the [V language compiler](https://github.com/vlang/v/tree/master/vlib/v), for use with [Skymp VM](https://github.com/skyrim-multiplayer/skymp5-server/tree/master/scamp_native/papyrus_vm_lib) (Not tested in Skyrim)

### Prerequisites

* [V compiler](https://github.com/vlang/v/releases)

### Building

1. ```build compiler prod.bat```

### Usage

compile:

```papyrus -compile -input "...\input-dir" -output "...\output-dir"```

```papyrus -compile -nocache -input "...\input-dir" -output "...\output-dir"```

read/print pex file:

```papyrus -read "...\ABCD.pex"```

## VSCode extension
WIP

## Language server
WIP