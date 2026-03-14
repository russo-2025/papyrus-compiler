# AGENTS.md — System Prompt for AI Assistants

You are working on **Papyrus Compiler** — an open-source compiler for the Papyrus scripting language (Skyrim SE/AE). The compiler is written in the **V programming language** (vlang.io). It compiles `.psc` (Papyrus Source Code) files into `.pex` (Papyrus Executable) binary files — the same format as Bethesda's official Creation Kit compiler.

---

## Project Structure

```
compiler.v              — Entry point: CLI dispatch (compile, read, disassembly, dump, help, version)
fast.v                  — Benchmarking harness for performance tracking across commits
v.mod                   — V module metadata (version, dependencies)
run.bat                 — Quick-launch script for compilation

modules/
├── pref/               — CLI argument parsing, Preferences struct
├── papyrus/
│   ├── token/          — Token kinds (enum Kind), Position struct
│   ├── scanner/        — Lexer: .psc text → token stream
│   ├── ast/            — AST nodes, type system, symbol table (Table), scopes
│   ├── parser/         — Recursive-descent parser: tokens → AST
│   ├── checker/        — Semantic analysis: type checking, cast validation, scope resolution
│   ├── errors/         — Error/Warning structs, predefined error message constants
│   └── util/           — Helpers: BOM handling, char classification, error formatting
├── pex/                — PEX binary format: data structures, reader, writer, opcodes, dump
├── gen/
│   ├── gen_pex/        — Code generator: AST → PEX bytecode instructions
│   └── ts_binding/     — TypeScript binding generator (secondary feature)
├── builder/            — Orchestrator: drives the full compile pipeline, caching, stats
└── tests/              — Test suite (V's built-in test framework)
```

### Directories that should NOT be modified:
- `modules/tests/*Sources/` — Third-party Skyrim mod source files used as test fixtures. Do not edit.
- `modules/tests/psc_deps/` — 83 Skyrim base class header stubs (Actor.psc, Form.psc, etc.) used as dependencies for tests. Do not edit unless specifically adding new base class stubs.
- `test-files/` — Output directory for compiled test artifacts (.pex files). Not source code.
- `bin/` — Build output directory for the compiler binary.

---

## Compilation Pipeline

The compiler processes files through these stages in order:

```
.psc source → Scanner → Parser → Checker → Gen (gen_pex) → PEX Writer → .pex binary
```

1. **Scanning** (`modules/papyrus/scanner/`) — Character-by-character lexer. Handles `;` line comments, `{block}` comments, `;/ multi-line /;` comments. Case-insensitive keywords. Line continuation with `\`.
2. **Parsing** (`modules/papyrus/parser/`) — Recursive-descent parser producing `[]&ast.File`. Split into: `parser.v` (main + statements), `expr.v` (expressions with precedence climbing), `fn.v` (function/event declarations), `type.v` (type parsing). **Selective header loading**: unknown types are pushed onto `table.deps` stack, resolved by the builder iteratively.
3. **Checking** (`modules/papyrus/checker/`) — Type checking, autocast validation, scope resolution, method resolution via inheritance chains. Split into: `checker.v` (core), `checker_stmt.v` (statements), `checker_expr.v` (expressions).
4. **Code Generation** (`modules/gen/gen_pex/`) — Generates PEX bytecode from AST. Manages temp variables (`::temp0`, `::temp1`, ...), string interning, control flow jump patching. Split into: `gen.v` (main), `gen_stmt.v` (statements), `gen_expr.v` (expressions).
5. **PEX Writing** (`modules/pex/writer.v`) — Big-endian binary serialization. Generic `write[T]()` with compile-time type dispatch.

---

## Key Data Structures

### Type System (`modules/papyrus/ast/types.v`)
- `Type = int` — Index into `Table.types[]`
- Built-in type indices: 1=None, 2=Int, 3=Float, 4=String, 5=Bool, 6=Array, 7-10=typed arrays (String[], Int[], Float[], Bool[])
- `TypeSymbol` — Holds: kind, parent_idx, methods, props, states, vars
- Placeholder types used for forward references, resolved during dependency loading

### Symbol Table (`modules/papyrus/ast/table.v`)
- `Table` — Central registry: `types[]TypeSymbol`, `type_idxs map[string]int`, `fns map[string]Fn`, `deps Stack[string]`
- **All lookups are case-insensitive** (`.to_lower()` on keys)
- Functions keyed as `"objname.fnname"`

### AST Nodes (`modules/papyrus/ast/ast.v`, `expr.v`)
- Top-level: `TopStmt = ScriptDecl | FnDecl | Comment | PropertyDecl | VarDecl | StateDecl`
- Statements: `Stmt = Return | If | While | ExprStmt | AssignStmt | VarDecl | Comment`
- Expressions: `Expr = InfixExpr | IntegerLiteral | FloatLiteral | BoolLiteral | StringLiteral | Ident | CallExpr | SelectorExpr | IndexExpr | ParExpr | PrefixExpr | EmptyExpr | ArrayInit | NoneLiteral | CastExpr`

---

## V Language Conventions Used in This Project

### Naming
- Structs: `PascalCase`
- Functions/methods: `snake_case`
- Enum variants: `snake_case` with `.` prefix (e.g., `.key_if`)
- Constants: `snake_case`
- Module names: lowercase

### V-specific patterns used
- Sum types for AST: `type Expr = InfixExpr | IntegerLiteral | ...`
- Compile-time generics: `$if T is u8 { ... }` in binary read/write
- Performance attributes: `@[inline]`, `@[direct_array_access]`, `@[heap]`
- Result type: `!` operator for error-returning functions
- `mut` receivers for mutable method calls
- `spawn` for parallel code generation (up to 8 threads)

### Comments
- Comments may contain Russian (Cyrillic) text. When you encounter Russian comments during your work, replace them with an English equivalent.

---

## Build & Run Commands

### Build
```bash
# Debug build
v -o "bin\papyrus.exe" compiler.v

# Production build (optimized, no GC)
v -o "bin\papyrus.exe" -prod -gc none compiler.v

# Debug with symbols
v -g -gc none -o "bin\papyrus.exe" compiler.v
```

### Run Tests
```bash
# Run all tests with stats
v -stats test modules

# Run specific test file
v test modules/tests/ast_test.v
```

---

## Testing Conventions

Tests are in `modules/tests/` and use V's built-in test framework (functions prefixed with `fn test_*`).

### Test Categories

| Category | File | Purpose |
|----------|------|---------|
| AST shape | `ast_test.v` | Verify parsed AST node types and properties |
| Error messages | `errors_test.v` | Verify compiler produces correct errors |
| Type casting | `checker_cast_test.v` | Exhaustive autocast/explicit cast matrix |
| PEX codegen | `pex_stmt_test.v` | End-to-end: source → PEX instructions |
| PEX binary | `binary_read_write_test.v`, `pex_read_write_test.v` | Serialize/deserialize roundtrip |
| Project integration | `projects_test.v` | Compile entire real Skyrim mod sources |
| Selective loading | `selective_headers_loading_test.v` | Verify only needed headers are parsed |
| PEX enum ordinals | `pex_test.v` | Validate opcode/value enum values |

### Test Helpers Pattern
Each test file defines its own `compile()` helper tailored to its needs:

- **`ast_test.v`**: `compile(src) → (&ast.File, &ast.Table, []errors.Error)` plus `compile_stmts()`, `compile_stmt()`, `compile_expr()` wrappers for convenience.
- **`errors_test.v`**: Same helpers but return only `[]errors.Error`.
- **`pex_stmt_test.v`**: `compile(src) → &pex.PexFile` (full pipeline round-trip) plus `get_instructions()`.

All test files define `const prefs` with `no_cache: true, output_mode: .silent` and provide fixture scripts as module-level string constants (`src_template`, `other_src`, `parent_src`).

### Test Fixtures
- `modules/tests/psc/` — Small custom `.psc` files for specific tests
- `modules/tests/psc_deps/` — Skyrim base script headers (dependencies for all tests)
- `modules/tests/*Sources/` — Real Skyrim mod source trees for integration tests

---

## Mandatory Rules

### 1. Bug fixes MUST include a test
When fixing a bug, **always** create a test case that covers the bug scenario. Choose the appropriate test file:
- Parser/AST bug → add test in `ast_test.v`
- Type checking / semantic error → add test in `errors_test.v` or `checker_cast_test.v`
- Code generation bug → add test in `pex_stmt_test.v`
- Binary format bug → add test in `binary_read_write_test.v` or `pex_read_write_test.v`

### 2. Run tests after changes
After any code change, run `v -stats test modules` to verify nothing is broken. All existing tests must pass.

### 3. Preserve case-insensitivity
Papyrus is a **case-insensitive language**. All identifier lookups, type resolution, and keyword matching must use `.to_lower()`. Never add case-sensitive comparisons for Papyrus identifiers.

### 4. Error messages must be clear and user-facing
Error messages shown to the user should be clear, lowercase, and descriptive. Avoid technical jargon. Include context like expected vs actual values. Follow the existing style in `errors_test.v` — e.g., `'function takes 1 parameters not 0'`.

### 5. Maintain pipeline separation
Keep the compiler stages cleanly separated:
- **Scanner** should only tokenize, never interpret semantics
- **Parser** should only build AST, never type-check
- **Checker** should only validate, never generate code
- **Gen** should only emit bytecode, never modify AST

### 6. PEX format compliance
Generated `.pex` files must be binary-compatible with Bethesda's Papyrus VM. The format is big-endian. Do not change the opcode enum values or binary layout without verifying against the [Compiled Script File Format](https://en.uesp.net/wiki/Skyrim_Mod:Compiled_Script_File_Format) specification.

### 7. Do not modify third-party test sources
Files in `modules/tests/*Sources/` directories are real-world Skyrim mod scripts. They must not be modified — they serve as regression test fixtures.

---

## How To: Common Tasks

### Add support for a new language feature
1. Add token(s) in `modules/papyrus/token/` if needed
2. Update scanner in `modules/papyrus/scanner/` to recognize new tokens
3. Add AST node(s) in `modules/papyrus/ast/`
4. Update parser in `modules/papyrus/parser/` to produce new AST
5. Add semantic checks in `modules/papyrus/checker/`
6. Add code generation in `modules/gen/gen_pex/`
7. Write tests at each level (AST, errors, PEX output)

### Add a new error message
1. If it's a CLI-level error, add a `pub const msg_*` in `modules/papyrus/errors/errors.v`
2. If it's a checker/parser error, use inline string in the `error()` call
3. Add a test in `errors_test.v` that triggers the error and asserts the exact message

### Add a new integration test project
1. Place source files in a new directory `modules/tests/<ProjectName>Sources/`
2. In `projects_test.v`, add a `const` using `get_source_dir('<ProjectName>Sources', '<required_file.psc>')`
3. Add `fn test_project_<name>()` calling `get_prefs()` + `builder.compile()`
4. The test uses `backend: .check` (type-check only, no PEX output)

### Fix a bug in code generation
1. Write a minimal `.psc` snippet that reproduces the issue
2. Add test in `pex_stmt_test.v` using `compile()` + `get_instructions()`
3. Fix the code in `modules/gen/gen_pex/`
4. Assert on expected PEX opcodes/operands in the test

---

## Module Dependency Graph

```
compiler.v → pref, builder, pex, papyrus.util
builder    → pref, papyrus.{ast, parser, checker, util}, gen.gen_pex, pex
gen_pex    → papyrus.{ast, token, util}, pex, pref
checker    → papyrus.{ast, token, errors, util}, pex, pref
parser     → papyrus.{ast, scanner, token, errors, util}, pex, pref
scanner    → papyrus.{token, util, errors}, pref
ast        → papyrus.{token, util}
pex        → papyrus.util, encoding.binary
pref       → papyrus.errors
```

**Rule**: Do not introduce circular dependencies between modules. The dependency flow is: `compiler.v → builder → {checker, parser, gen_pex} → {ast, scanner, pex} → {token, util, errors}`.

---

## Notable Implementation Details

- **Selective header loading**: Only headers referenced by `table.deps` stack are parsed — not the entire Skyrim script library. This is a key performance optimization.
- **Caching**: File modification times are cached in `.papyrus/*.obj` files. Use `-nocache` to bypass.
- **Parallel codegen**: Enabled with `-use-threads`, divides work across up to 8 OS threads. Parse and check remain sequential.
- **String interning**: PEX uses a shared string table. All strings are interned via `gen_string_ref()` during code generation.
- **Temp variables**: Code generator manages a pool of `::temp0`, `::temp1`, etc. with free/reuse tracking.
- **Built-in methods**: `GetState`, `GotoState`, `onBeginState`, `onEndState` are auto-added to every object. Arrays have `Find`, `RFind`, `Length`.

---

## Papyrus Language Quick Reference

Papyrus is a **case-insensitive**, statically-typed, object-oriented scripting language:
- Types: `Int`, `Float`, `Bool`, `String`, `None`, script objects, arrays (`Type[]`)
- Inheritance: `Scriptname X extends Y`
- Properties: `Auto`, `AutoReadOnly`, full (with get/set)
- States: `State`, `Auto State`
- Events and Functions (can be `native`, `global`)
- Comments: `; line`, `{block}`, `;/ multi-line /;`
- Operators: arithmetic (`+`, `-`, `*`, `/`, `%`), comparison, logical (`&&`, `||`, `!`), string concatenation (`+`), compound assignment (`+=`, `-=`, etc.)
- `as` keyword for explicit type casting
- `new` keyword for array initialization: `new Int[10]`
- `self` refers to the current script object, `parent` calls parent's version of a function
