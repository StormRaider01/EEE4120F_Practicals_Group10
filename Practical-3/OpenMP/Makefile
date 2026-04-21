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

# ==========================================
# Execution Rules (Automated 5x Benchmarking)
# ==========================================
benchmark: $(TARGET)
	@echo "Cleaning old outputs to ensure fresh averages..."
	@rm -rf $(OUTPUT_DIR)/*.txt
	@mkdir -p $(OUTPUT_DIR)
	@echo "Starting 5x Averaged OpenMP Benchmark..."
	@for p in $(PROCS); do \
		echo "====================================="; \
		echo "Testing with $$p threads:"; \
		for f in $(FILES); do \
			echo "  -> energy$$f (Running 5 iterations...)"; \
			for run in 1 2 3 4 5; do \
				./$(TARGET) -p $$p -i $(INPUT_DIR)/energy$$f -o $(OUTPUT_DIR)/energy$$f.txt; \
			done; \
		done; \
	done
	@echo "Merging all results into one file..."
	@cat $(OUTPUT_DIR)/energy*.txt > $(OUTPUT_DIR)/all_combined_omp.txt
	@echo "Benchmarking complete! Raw data in $(OUTPUT_DIR)/all_combined_omp.txt"