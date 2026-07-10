#!/bin/bash
#
# Compile verilog file of the input path with iverilog
#
# Usage:
#   ./compile_src_sv.sh <verilog_file_path>
#


set -euo pipefail

# get path
FILE_PATH="$1"

# report error if file not found
if [[ ! -f "$FILE_PATH" ]]; then
  echo "Error: $FILE_PATH not found" >&2
  exit 1
fi

echo -e "🎬 Begin Compilation with iverilog:\n"

# compile with iverilog
iverilog -I src/ -g2012 -tnull -o /dev/null "$FILE_PATH"

# syntax ok
echo -e "\n✅ Syntax OK: $FILE_PATH\n"