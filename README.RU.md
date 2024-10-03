# Papyrus Compiler

Компилятор скриптового языка Papyrus с открытым исходным кодом. На данный момент компилятор поддерживает только Skyrim (тестировался на Skyrim SE/AE). 

Компилятор был создан для следующих целей:
1. **Понимание языков программирования:** Проект разработан для того, чтобы глубже понять, как работают языки программирования.
2. **Эксперименты с языком V:** Использует язык программирования V для реализации.
3. **Ускорение компиляции:** Стандартный компилятор Papyrus работает очень медленно, поэтому данный проект направлен на оптимизацию этого процесса.
4. **Улучшенные сообщения об ошибках:** Предоставляет более качественные и понятные сообщения об ошибках для упрощения отладки.

## Оглавление
- [Использование](#использование)
  - [Команды](#команды)
  - [Аргументы команды `compile`](#аргументы-команды-compile)
  - [Примеры использования](#примеры-использования)
  - [Файлы заголовков/импортов](#файлы-заголовковимпортов)
- [Сборка](#сборка)
  - [Требования](#требования)
- [Тестирование](#тестирование)
- [Ссылки](#ссылки)

## Использование
1. Скачайте архив с компилятором со страницы [Github Releases](https://github.com/russo-2025/papyrus-compiler/releases) и распакуйте его.
2. Откройте консоль в директории, куда распаковали компилятор.
3. Используйте следующий синтаксис для работы с компилятором:

```
papyrus <command> [arguments]
```

### Команды:
- `compile`: Компилирует файлы с расширением `.psc` в бинарный формат `.pex`.
- `read`: Читает и дизассемблирует файл с расширением `.pex`, выводя его содержимое в человекочитаемом формате в консоль.
- `disassembly`: Читает и дизассемблирует файл с расширением `.pex`, сохраняя содержимое в человекочитаемом формате в текстовый файл.
- `create-dump`: Создаёт файл `dump.json` с информацией о `.pex` файлах, находящихся в указанной директории.
- `help`: Выводит список доступных команд и их описание.

### Аргументы команды `compile`:
С командой `compile` могут использоваться следующие аргументы:

- `-i`, `-input`: Указывает каталог с `.psc` файлами или `.psc` файл для компиляции.
- `-o`, `-output`: Указывает каталог для сохранения скомпилированных `.pex` файлов.
- `-h`, `-headers-dir`: Указывает каталог с .psc файлами заголовков/импортов, которые будут проанализированы компилятором, но не будут скомпилированы. Используется для того, чтобы компилятор знал о существующих скриптах (`Form`, `ObjectReference`, `Actor`, ...) и их методах/функциях/свойствах/переменных. Смотрите раздел «Файлы заголовков/импортов».
- `-nocache`: Игнорирует кэш и принудительно компилирует все файлы.
- `-silent`: Отключает вывод сообщений об ошибках в консоль.
- `-original`: Использует оригинальный компилятор Papyrus для компиляции.
- `-stats`: Сохраняет статистику по скомпилированным файлам в .md файлы (количество вызовов функций, наследований, файлов).
- `-check`: Проверяет синтаксис .psc файлов без генерации .pex файлов.
- `-verbose`: ...

### Примеры использования
Ниже приведены несколько примеров, демонстрирующих использование различных команд и аргументов компилятора для компиляции скриптов, чтения скомпилированных скриптов и т.д.

#### Компиляция всех скриптов в директории с игнорированием кэша:
```bash
papyrus compile -nocache -i "D:\Steam\steamapps\common\Skyrim Special Edition\Data\Scripts\Source" -o "../test-files/compiled/skyrimSources"
```
Эта команда компилирует все скрипты (кэш игнорируется), расположенные в `D:\Steam\steamapps\common\Skyrim Special Edition\Data\Scripts\Source`, и помещает скомпилированные `.pex` файлы в каталог `../test-files/compiled/skyrimSources`.

#### Компиляция всех скриптов в директории:
```bash
papyrus compile -i "../../RH-workspace/scripts" -o "../../RH-workspace/compiled"
```
Эта команда компилирует все скрипты, расположенные в `../../RH-workspace/scripts`, и помещает скомпилированные `.pex` файлы в каталог `../../RH-workspace/compiled`.

#### Компиляция скриптов с использованием файлов заголовков/импортов:
```bash
papyrus compile -nocache -h "D:\Steam\steamapps\common\Skyrim Special Edition\Data\Scripts\Source" -i "../test-files/compiler" -o "../test-files/compiled" 
```
Эта команда скомпилирует все скрипты из каталога `../test-files/compiler` в каталог `../test-files/compiled`, а недостающая информация об объектах (`Form`, `ObjectReference`, `Actor` и т.д.) будет взята из `.psc` файлов в каталоге `D:\Steam\steamapps\common\Skyrim Special Edition\Data\Scripts\Source`.

#### Чтение скомпилированного `.pex` файла:
```bash
papyrus read "../test-files/compiled/ABCD.pex"
```

#### Создание JSON-дампа `.pex` файлов:
```bash
papyrus create-dump "../folder_with_pex_files"
```
Создает JSON-файл `dump.json`, содержащий некоторую информацию обо всех `.pex` файлах, расположенных в каталоге `../folder_with_pex_files`. Вот как это будет выглядеть:
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

### Файлы заголовков/импортов
По умолчанию компилятор не знает о существующих скриптах (`Form`, `ObjectReference`, `Actor` и т.д.), их наследовании (`ObjectReference` -> `Form`) и доступных методах/функциях/свойствах/переменных. 

Вы можете исправить это двумя способами:
1. Укажите путь к каталогу с оригинальными скриптами (например, `..\Skyrim\Data\Scripts\Source`) с помощью аргумента `-h "..."`.
2. Создайте каталог с заголовочными файлами, указывающими существующие объекты и их методы, функции и т.д., и укажите его с помощью аргумента `-h "..."`.

Пример заголовочного файла `Actor.psc`:
```papyrus
ScriptName Actor extends ObjectReference

Function EquipItem(Form akItem, bool abPreventRemoval = false, bool abSilent = false) native
```

Проанализировав этот файл, компилятор узнает о существовании объекта `Actor`, его наследовании от `ObjectReference` и наличии функции `EquipItem` с соответствующими аргументами (для некоторых из которых есть значения по умолчанию). Флаг `native` позволяет пропустить написание тела функции в заголовочном файле, так как эти скрипты используются только для анализа. Это значительно ускоряет компиляцию.

Скрипты из каталога, указанного аргументом `-h "..."`, НЕ БУДУТ скомпилированы и помещены в каталог, указанный с помощью `-o "..."`.

## Сборка

### Требования:
- [V compiler da228e9 (weekly.2024.36)](https://github.com/vlang/v/releases/tag/weekly.2024.36)

```bash
v -o "bin\papyrus.exe" -prod -gc none compiler.v
```

## Тестирование

```bash
v -stats test modules
```

## Ссылки
- [Papyrus docs](https://ck.uesp.net/wiki/Category:Papyrus)
- [VS Code Extension: Papyrus Language Tools](https://github.com/joelday/papyrus-lang)
- [Creation Kit Papyrus Reference](https://www.creationkit.com/index.php?title=Category:Papyrus)
- [Compiled Script File Format](https://en.uesp.net/wiki/Skyrim_Mod:Compiled_Script_File_Format)
- [Caprica](https://github.com/Orvid/Caprica) - A compiler for the Papyrus scripting language used by the Creation Engine.
- [Champollion](https://github.com/Orvid/Champollion) - A PEX to Papyrus Decompiler for Fallout 4
- [PapyrusDotNet](https://github.com/zerratar/PapyrusDotNet) - PapyrusDotNet - A .NET Papyrus Compiler for Fallout 4 and Skyrim
- [Open Papyrus - Docs](https://open-papyrus.github.io/docs/Papyrus_Language_Reference/index.html)
- [Open Papyrus - Compiler](https://github.com/open-papyrus/papyrus-compiler) - (WIP, Rust lang) Open-source compiler for the Papyrus scripting language of Bethesda games.