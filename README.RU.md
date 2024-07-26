# Papyrus Compiler

Компилятор скриптового языка Papyrus с открытым исходным кодом. На данный момент компилятор поддерживает только Skyrim (тестировался на Skyrim SE/AE). 

Причины создания компилятора:
1. Желание лучше понять, как устроены языки программирования.
2. Желание попробовать язык программирования V.
3. Очень медленная компиляция при использовании стандартного компилятора.
4. Значительно более читаемые и понятные сообщения об ошибках.

## Использование
1. Перейдите на страницу [Github Releases](https://github.com/russo-2025/papyrus-compiler/releases).
2. Скачайте архив с компилятором и распакуйте его.
3. Откройте консоль в директории, куда распаковали компилятор.
4. Используйте следующий синтаксис:

```
papyrus <command> [arguments]
```

### Команды:
- `compile`: Компилирует файлы `.psc` в бинарный формат `.pex`.
- `read`: Конвертирует `.pex` файл в человекочитаемый формат и выводит результат в консоль.
- `disassemble`: Конвертирует `.pex` файл в человекочитаемый формат и записывает результат в текстовый файл.
- `create-dump`: Создает JSON-файл `dump.json` с информацией о `.pex` файлах в указанной директории.

### Аргументы команды `compile`:
С командой `compile` могут использоваться следующие аргументы:

- `-i`, `-input`: Указывает каталог с `.psc` файлами для компиляции.
- `-o`, `-output`: Указывает каталог, куда будут помещены скомпилированные `.pex` файлы.
- `-h`, `-headers-dir`: Указывает каталог с `.psc` файлами, которые будут проанализированы компилятором, но не будут скомпилированы. Используется для того, чтобы компилятор знал о существующих скриптах (`Form`, `ObjectReference`, `Actor`) и их методах/функциях/свойствах/переменных. Смотрите раздел «Файлы заголовков/импортов».
- `-nocache`: Заставляет компилятор компилировать все файлы, независимо от дат их изменения.
- `-silent`: Отключает вывод сообщений об ошибках в консоль.
- `-original`: ...
- `-verbose`: ...
- `-stats`: ...

### Примеры
Ниже приведены несколько примеров, демонстрирующих использование различных команд и аргументов компилятора для компиляции скриптов, чтения скомпилированных скриптов и т.д.

#### Скомпилировать все скрипты в директории, игнорируя кэш:
```bash
papyrus compile --nocache -i "D:\Steam\steamapps\common\Skyrim Special Edition\Data\Scripts\Source" -o "../test-files/compiled/skyrimSources"
```
Эта команда компилирует все скрипты (кэш игнорируется), расположенные в `D:\Steam\steamapps\common\Skyrim Special Edition\Data\Scripts\Source`, и помещает скомпилированные `.pex` файлы в каталог `../test-files/compiled/skyrimSources`.

#### Скомпилировать все скрипты в директории:
```bash
papyrus compile -i "../../RH-workspace/scripts" -o "../../RH-workspace/compiled"
```
Эта команда компилирует все скрипты, расположенные в `../../RH-workspace/scripts`, и помещает скомпилированные `.pex` файлы в каталог `../../RH-workspace/compiled`.

#### Скомпилировать все скрипты в директории, используя аргумент `-h` (headers/imports):
```bash
papyrus compile --nocache -h "D:\Steam\steamapps\common\Skyrim Special Edition\Data\Scripts\Source" -i "../test-files/compiler" -o "../test-files/compiled" 
```
Эта команда скомпилирует все скрипты из каталога `../test-files/compiler` в каталог `../test-files/compiled`, а недостающая информация об объектах (`Form`, `ObjectReference`, `Actor` и т.д.) будет взята из `.psc` файлов в каталоге `D:\Steam\steamapps\common\Skyrim Special Edition\Data\Scripts\Source`.

#### Чтение скомпилированных `.pex` файлов:
```bash
papyrus read "../test-files/compiled/ABCD.pex"
```

#### Создание дампа:
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
- [V compiler e9a3817 (weekly.2023.08)](https://github.com/vlang/v/releases/tag/weekly.2023.08)

```bash
v -o "bin\papyrus.exe" -prod -gc none compiler.v
```

## Тестирование

```bash
v -stats test modules
```

## Ссылки
- [VS Code Extension: Papyrus Language Tools](https://github.com/joelday/papyrus-lang)
- [Creation Kit Papyrus Reference](https://www.creationkit.com/index.php?title=Category:Papyrus)
- [Compiled Script File Format](https://en.uesp.net/wiki/Skyrim_Mod:Compiled_Script_File_Format)
- [Caprica](https://github.com/Orvid/Caprica) - A compiler for the Papyrus scripting language used by the Creation Engine.
- [Champollion](https://github.com/Orvid/Champollion) - A PEX to Papyrus Decompiler for Fallout 4
- [PapyrusDotNet](https://github.com/zerratar/PapyrusDotNet) - PapyrusDotNet - A .NET Papyrus Compiler for Fallout 4 and Skyrim
- [Open Papyrus - Docs](https://open-papyrus.github.io/docs/Papyrus_Language_Reference/index.html)
- [Open Papyrus - Compiler](https://github.com/open-papyrus/papyrus-compiler) - (WIP, Rust lang) Open-source compiler for the Papyrus scripting language of Bethesda games.