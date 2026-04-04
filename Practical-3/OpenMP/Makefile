# ==========================================
# OpenMP Compiler and Flags
# ==========================================
CC = gcc
CFLAGS = -O3 -Wall -fopenmp
CFLAGS_DEBUG = -g -Wall -fopenmp

# ==========================================
# Targets and Sources
# ==========================================
TARGET = wariara_freights_route
DEBUG_TARGET = wariara_freights_route_debug
SRC = wariara_freights_route.c

# ==========================================
# Directories and Benchmarking Variables
# ==========================================
INPUT_DIR = input
OUTPUT_DIR = output

# Default threads for a standard run
P ?= 12

# Thread counts for benchmarking
PROCS = 1 2 4 8 10 12
FILES = 4 5 6 7 8 9 10

# ==========================================
# Build Rules
# ==========================================

all: $(TARGET) $(DEBUG_TARGET)

.PHONY: clean benchmark run run_debug

clean: 
	rm -rf $(TARGET) $(DEBUG_TARGET) *~ *.o
	rm -rf $(OUTPUT_DIR)/*

$(TARGET): $(SRC)
	$(CC) $(CFLAGS) $< -o $(TARGET)

$(DEBUG_TARGET): $(SRC)
	$(CC) $(CFLAGS_DEBUG) $< -o $(DEBUG_TARGET)

# ==========================================
# Execution Rules (Standard)
# ==========================================

run: $(TARGET)
	@mkdir -p $(OUTPUT_DIR)
	./$(TARGET) -p $(P) -i $(INPUT_DIR)/energy10 -o $(OUTPUT_DIR)/test_out.txt

run_debug: $(DEBUG_TARGET)
	@mkdir -p $(OUTPUT_DIR)
	./$(DEBUG_TARGET) -p $(P) -i $(INPUT_DIR)/energy10 -o $(OUTPUT_DIR)/test_debug.txt

# ==========================================
# Execution Rules (Automated Benchmarking)
# ==========================================

benchmark: $(TARGET)
	@mkdir -p $(OUTPUT_DIR)
	@echo "Starting OpenMP benchmark for Speedup Calculation..."
	@for p in $(PROCS); do \
		echo "====================================="; \
		echo "Testing with $$p threads:"; \
		for f in $(FILES); do \
			echo "  -> energy$$f.txt"; \
			./$(TARGET) -p $$p -i $(INPUT_DIR)/energy$$f -o $(OUTPUT_DIR)/energy$$f.txt; \
		done; \
	done
	@echo "Benchmarking complete. Check the $(OUTPUT_DIR) folder."