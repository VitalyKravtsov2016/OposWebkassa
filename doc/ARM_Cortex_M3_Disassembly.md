# Дизассемблирование файлов для ARM Cortex-M3

В данном документе описаны инструменты, которые можно использовать для дизассемблирования бинарных файлов (прошивок, ELF-файлов) под архитектуру ARM Cortex-M3.

---

## 1. arm-none-eabi-objdump

Часть **GNU Arm Embedded Toolchain**. Наиболее распространённый инструмент для работы с ELF-файлами под ARM Cortex-M3.

**Установка:**

- Windows: [GNU Arm Embedded Toolchain](https://developer.arm.com/downloads/-/gnu-rm)
- Linux: `sudo apt-get install gcc-arm-none-eabi`

**Использование (ELF-файл):**

```bash
arm-none-eabi-objdump -d program.elf
```

**Использование (чистый бинарник):**

```bash
arm-none-eabi-objdump -D -b binary -m arm -M force-thumb program.bin
```

> Флаг `-M force-thumb` нужен для Cortex-M3, который работает в режиме Thumb/Thumb-2.

---

## 2. Ghidra

Бесплатный реверс-инжиниринговый фреймворк от NSA с поддержкой ARM Cortex-M.

- Официальный сайт: https://ghidra-sre.org/
- Поддерживает дизассемблирование и **декомпиляцию** в псевдокод C.
- Графический интерфейс.
- Поддерживает форматы: ELF, PE, raw binary.

**Запуск:**

1. Скачать и распаковать Ghidra.
2. Запустить `ghidraRun` (или `ghidraRun.bat` на Windows).
3. Создать проект, импортировать файл, выбрать архитектуру `ARM Cortex` / `Thumb-2`.

---

## 3. IDA Pro / IDA Free

Коммерческий дизассемблер с расширенной поддержкой ARM.

- Сайт: https://hex-rays.com/ida-pro/
- Бесплатная версия (IDA Free): https://hex-rays.com/ida-free/
- Поддерживает Thumb и Thumb-2 инструкции Cortex-M3.
- Мощный анализ, граф потока управления, скриптование (IDAPython).

---

## 4. Radare2 / Cutter

Бесплатный кроссплатформенный фреймворк для реверс-инжиниринга.

- Сайт: https://rada.re/
- Cutter (GUI для Radare2): https://cutter.re/

**Установка (Linux):**

```bash
sudo apt-get install radare2
```

**Дизассемблирование ELF-файла:**

```bash
r2 -A program.elf
```

**Дизассемблирование чистого бинарника (Thumb-режим):**

```bash
r2 -A -a arm -b 16 program.bin
```

> `-b 16` указывает разрядность инструкций Thumb (16/32-бит для Thumb-2).

---

## 5. Стандартный objdump (binutils)

Если в системе установлен binutils с поддержкой ARM, можно воспользоваться обычным `objdump`:

```bash
objdump -d program.elf
```

> Убедитесь, что версия `objdump` собрана с поддержкой целевой архитектуры ARM.

---

## Рекомендации

| Задача                              | Инструмент                     |
|-------------------------------------|--------------------------------|
| Быстрый просмотр ELF/бинарника      | arm-none-eabi-objdump          |
| Детальный анализ, декомпиляция      | Ghidra (бесплатно)             |
| Профессиональный анализ             | IDA Pro                        |
| Командная строка + скриптование     | Radare2                        |
| GUI для Radare2                     | Cutter                         |

---

## Примечание по режимам ARM

ARM Cortex-M3 использует исключительно набор инструкций **Thumb / Thumb-2**. При дизассемблировании чистых бинарных файлов (`.bin`) обязательно указывайте Thumb-режим:

- `arm-none-eabi-objdump`: флаг `-M force-thumb`
- `radare2`: флаг `-b 16`
- Ghidra / IDA: выбрать процессор `ARM Cortex / Thumb`
