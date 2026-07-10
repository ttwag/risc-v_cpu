#!/bin/bash
#
# Compile all file in ./src and run simulation with the given test bench file
#
# Usage:
#   ./run_tb_sv.sh <test_bench_file_path>
#

set -euo pipefail

# get path
FILE_PATH="$1"

# report error if file not found
if [[ ! -f "$FILE_PATH" ]]; then
  echo "Error: $FILE_PATH not found" >&2
  exit 1
fi

# derive sim name from tb filename
FILE=$(basename "$FILE_PATH" .sv)

# compile tb against all source files
mkdir -p sims
echo -e "🎬 Begin Compilation with iverilog:\n"
iverilog -I src/ -g2012 -o "sims/${FILE}_sim" "$FILE_PATH" src/*.sv

# run sim and dump waveform
vvp "sims/${FILE}_sim" -fst +DUMPFILE="sims/${FILE}_dump.fst"
echo -e "\n✅ Simulation Completed\n"
