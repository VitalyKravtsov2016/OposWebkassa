# Дизассемблирование прошивки ARM Cortex-M3

Данный раздел описывает, как дизассемблировать файл прошивки в формате **raw binary** (`.bin`)
для процессоров ARM Cortex-M3 (например, STM32).

---

## Проблема

При запуске `arm-none-eabi-objdump -d firmware.bin` появляется ошибка:

```
firmware.bin: file format not recognized
```

Это происходит потому, что `objdump` ожидает файл в формате **ELF**, а не чистый бинарник.

---

## Способ 1 — скрипт `disassemble_firmware.sh` (рекомендуется)

```bash
# Сделать скрипт исполняемым (один раз)
chmod +x doc/disassembly/disassemble_firmware.sh

# Запустить
./doc/disassembly/disassemble_firmware.sh upd_ldr_133.bin
# или с явным базовым адресом:
./doc/disassembly/disassemble_firmware.sh upd_ldr_133.bin 0x08000000
```

Скрипт автоматически:
1. Конвертирует `.bin` → `.elf` через `arm-none-eabi-objcopy`.
2. Дизассемблирует `.elf` в `.asm` через `arm-none-eabi-objdump`.

---

## Способ 2 — вручную (GNU Arm Embedded Toolchain)

### Шаг 1. Установка инструментов

**Ubuntu / Debian:**
```bash
sudo apt-get install gcc-arm-none-eabi binutils-arm-none-eabi
```

**macOS (Homebrew):**
```bash
brew install --cask gcc-arm-embedded
```

### Шаг 2. Конвертация binary → ELF

```bash
arm-none-eabi-objcopy \
    --input-target  binary \
    --output-target elf32-littlearm \
    --binary-architecture arm \
    --set-start 0x08000000 \
    --change-section-vma .data=0x08000000 \
    upd_ldr_133.bin upd_ldr_133.elf
```

> **Базовый адрес:** для микроконтроллеров STM32 Flash начинается с `0x08000000`.
> Уточните адрес в документации на конкретный чип.
>
> Флаг `--change-section-vma .data=<addr>` задаёт виртуальный адрес загрузки секции,
> чтобы в дизассемблере отображались корректные адреса инструкций.

### Шаг 3. Дизассемблирование

```bash
arm-none-eabi-objdump \
    --disassemble-all \
    --architecture=arm \
    --disassembler-options=force-thumb \
    --show-raw-insn \
    -C \
    upd_ldr_133.elf > upd_ldr_133.asm
```

- `force-thumb` — важен для Cortex-M3, который выполняет только инструкции Thumb/Thumb-2.
- `--show-raw-insn` — выводит байты инструкций рядом с мнемониками для ручной верификации.
- `-C` — деманглирует имена символов C++ для удобства чтения.

---

## Способ 3 — Radare2

Radare2 работает напрямую с файлами `.bin` без предварительной конвертации.

**Установка:**
```bash
# Ubuntu / Debian
sudo apt-get install radare2

# macOS
brew install radare2
```

**Дизассемблирование:**
```bash
r2 -a arm -b 16 -m 0x08000000 upd_ldr_133.bin
```

Внутри интерактивной сессии Radare2:
```
[0x08000000]> aaa          # проанализировать все функции
[0x08000000]> pd 100       # вывести 100 инструкций начиная с текущего адреса
[0x08000000]> pdf @ main   # дизассемблировать функцию main (если нашёл)
[0x08000000]> q            # выход
```

Для записи в файл без интерактивного режима:
```bash
r2 -a arm -b 16 -m 0x08000000 -q -c 'aaa; pd 999999' upd_ldr_133.bin > upd_ldr_133.asm
```

---

## Способ 4 — Ghidra

1. Скачайте и установите [Ghidra](https://ghidra-sre.org/).
2. Создайте новый проект: **File → New Project**.
3. Импортируйте файл: **File → Import File** → выберите `upd_ldr_133.bin`.
4. В диалоге импорта укажите:
   - **Language:** `ARM:LE:32:Cortex` (или `ARM Cortex-M`)
   - **Base Address:** `0x08000000`
5. Откройте файл в CodeBrowser, нажмите **Yes** на предложение авто-анализа.
6. Используйте окно **Listing** для просмотра дизассемблированного кода.

---

## Параметры базового адреса

| Производитель / серия    | Flash (начало) |
|--------------------------|----------------|
| STM32F1xx, F2xx, F4xx    | `0x08000000`   |
| STM32G0xx, G4xx          | `0x08000000`   |
| NXP LPC1xxx              | `0x00000000`   |
| Nordic nRF51/nRF52       | `0x00000000`   |

---

## Ссылки

- [GNU Arm Embedded Toolchain](https://developer.arm.com/downloads/-/gnu-rm)
- [Radare2](https://rada.re/n/)
- [Ghidra](https://ghidra-sre.org/)
