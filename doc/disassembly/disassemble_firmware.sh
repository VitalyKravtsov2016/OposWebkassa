#!/usr/bin/env bash
# disassemble_firmware.sh
#
# Дизассемблирует чистый бинарный файл прошивки ARM Cortex-M3.
#
# Использование:
#   ./disassemble_firmware.sh <firmware.bin> [base_address]
#
# Аргументы:
#   <firmware.bin>   Путь к файлу прошивки в формате raw binary.
#   [base_address]   Базовый адрес загрузки (по умолчанию 0x08000000 для STM32).
#
# Примеры:
#   ./disassemble_firmware.sh upd_ldr_133.bin
#   ./disassemble_firmware.sh upd_ldr_133.bin 0x08000000
#
# Зависимости: arm-none-eabi-objcopy, arm-none-eabi-objdump (GNU Arm Embedded Toolchain)

set -euo pipefail

# ── аргументы ──────────────────────────────────────────────────────────────
if [ $# -lt 1 ]; then
    echo "Использование: $0 <firmware.bin> [base_address]" >&2
    exit 1
fi

BIN_FILE="$1"
BASE_ADDR="${2:-0x08000000}"

if [ ! -f "$BIN_FILE" ]; then
    echo "Ошибка: файл '$BIN_FILE' не найден." >&2
    exit 1
fi

# ── производные имена файлов ────────────────────────────────────────────────
BASENAME="${BIN_FILE%.bin}"
ELF_FILE="${BASENAME}.elf"
ASM_FILE="${BASENAME}.asm"

# ── проверка инструментов ───────────────────────────────────────────────────
for tool in arm-none-eabi-objcopy arm-none-eabi-objdump; do
    if ! command -v "$tool" >/dev/null 2>&1; then
        echo "Ошибка: '$tool' не найден. Установите GNU Arm Embedded Toolchain." >&2
        echo "  Ubuntu/Debian: sudo apt-get install gcc-arm-none-eabi binutils-arm-none-eabi" >&2
        echo "  macOS:         brew install --cask gcc-arm-embedded" >&2
        exit 1
    fi
done

# ── шаг 1: конвертация binary → ELF ────────────────────────────────────────
echo "[1/2] Конвертация '$BIN_FILE' → '$ELF_FILE' (базовый адрес: $BASE_ADDR) ..."
arm-none-eabi-objcopy \
    --input-target  binary \
    --output-target elf32-littlearm \
    --binary-architecture arm \
    --set-start "$BASE_ADDR" \
    --change-section-vma .data="$BASE_ADDR" \
    "$BIN_FILE" "$ELF_FILE"

# ── шаг 2: дизассемблирование ───────────────────────────────────────────────
echo "[2/2] Дизассемблирование '$ELF_FILE' → '$ASM_FILE' ..."
arm-none-eabi-objdump \
    --disassemble-all \
    --architecture=arm \
    --disassembler-options=force-thumb \
    --show-raw-insn \
    -C \
    "$ELF_FILE" > "$ASM_FILE"

echo ""
echo "Готово. Результат записан в '$ASM_FILE'."
echo "Для просмотра: less '$ASM_FILE'"
