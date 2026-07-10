#!/bin/bash
#
# Compile, assemble, link, and disassemble main.lang, placing all
# generated artifacts into a "build" directory next to this script.
# Assumes "link.ld" lives in the same directory as this script, and
# the source file lives at "src/main.lang" relative to this script.
#
# Usage:
#   ./toy_compile.sh

# Exit immediately if any command fails
set -e

# Resolve the directory this script lives in, regardless of the caller's cwd
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="${SCRIPT_DIR}/build"
LINKER_SCRIPT="${SCRIPT_DIR}/link.ld"
LANG_FILE="${SCRIPT_DIR}/src/main.lang"

# Sanity check: make sure the linker script actually exists
if [ ! -f "$LINKER_SCRIPT" ]; then
    echo "Error: Linker script not found at ${LINKER_SCRIPT}"
    exit 1
fi

# Sanity check: make sure the source file actually exists
if [ ! -f "$LANG_FILE" ]; then
    echo "Error: Source file not found at ${LANG_FILE}"
    exit 1
fi

# Derive the basename (without extension) from the lang file's filename,
# ignoring any directory components.
FILENAME="$(basename "$LANG_FILE")"
BASENAME="${FILENAME%.*}"

# Create the build directory if it doesn't already exist
mkdir -p "$BUILD_DIR"

OUT_PREFIX="${BUILD_DIR}/${BASENAME}"

echo -e "Compiling ${LANG_FILE}...\n"
/opt/my-compiler/release/compile "${LANG_FILE}"

# Move generated assembly file into the build directory
echo -e "\nMoving ${SCRIPT_DIR}/src/${BASENAME}.s to ${BUILD_DIR}/...\n"
mv "${SCRIPT_DIR}/src/${BASENAME}.s" "${BUILD_DIR}/"
ASM_FILE="${OUT_PREFIX}.s"

echo -e "Assembling ${ASM_FILE}...\n"
riscv-none-elf-as -march=rv32i -mabi=ilp32 -mno-relax -o "${OUT_PREFIX}.o" "${ASM_FILE}"

echo -e "Linking into ${OUT_PREFIX}.elf using ${LINKER_SCRIPT}...\n"
riscv-none-elf-ld -T "${LINKER_SCRIPT}" -nostdlib -o "${OUT_PREFIX}.elf" "${OUT_PREFIX}.o"

echo -e "Disassembling final ELF into ${OUT_PREFIX}.disasm...\n"
riscv-none-elf-objdump -d "${OUT_PREFIX}.elf" > "${OUT_PREFIX}.disasm"

echo -e "Extracting raw binary...\n"
riscv-none-elf-objcopy -O binary "${OUT_PREFIX}.elf" "${OUT_PREFIX}.bin"

echo -e "Formatting hex for Verilog...\n"
riscv-none-elf-objcopy -O verilog "${OUT_PREFIX}.elf" "${OUT_PREFIX}.hex"

echo -e "Build complete! ${OUT_PREFIX}.hex and ${OUT_PREFIX}.disasm are ready in ${BUILD_DIR}.\n"