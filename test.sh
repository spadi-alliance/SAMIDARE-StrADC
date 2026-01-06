#!/bin/bash

# Check if the name argument is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <name>"
  echo "Available test folders in the 'tests' directory:"
  ls tests
  exit 1
fi

NAME=$1
TEST_DIR="tests/$NAME"
CFG_FILE="$TEST_DIR/sources.cfg"
OUTPUT_DIR="$TEST_DIR/out"
OUTPUT_FILE="$OUTPUT_DIR/wave"

# Check if the configuration file exists
if [ ! -f "$CFG_FILE" ]; then
  echo "Configuration file $CFG_FILE not found!"
  exit 1
fi

# Create the output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Read the paths from the configuration file
ARGS=$(cat "$CFG_FILE")

# Run iverilog with the arguments
iverilog -o "$OUTPUT_FILE" $ARGS

# Check if iverilog succeeded
if [ $? -eq 0 ]; then
  echo "iverilog completed successfully. Output written to $OUTPUT_FILE"
else
  echo "iverilog failed."
  exit 1
fi

# Run the simulation
vvp "$OUTPUT_FILE"

# Check if the simulation succeeded
if [ $? -eq 0 ]; then
  echo "Simulation completed successfully."
else
  echo "Simulation failed."
  exit 1
fi

# Remove the output file
rm -f "$OUTPUT_FILE"

# Move wave.vcd to the output directory
mv wave.vcd "$OUTPUT_DIR"

# Check if sufer is installed
if ! command -v surfer &> /dev/null; then
  echo "surfer is not installed. Please install it to view the waveforms."
  exit 1
fi

# Check if wave.ron file exists
if [ -f "$TEST_DIR/wave.ron" ]; then
  # Launch surfer with the wave.ron file configuration
    surfer -s "$OUTPUT_DIR/wave.ron" "$OUTPUT_DIR/wave.vcd"
else
    echo "No wave.ron file found. Launching surfer without it."
    surfer "$OUTPUT_DIR/wave.vcd"
fi