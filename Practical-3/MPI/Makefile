# ==========================================
# Original Template Variables
# ==========================================
CC=mpicc
CFLAGS=-O3 -Wall
CFLAGS_DEBUG=-g -Wall
NP=12
ARGS=

# ==========================================
# Automated Benchmarking Variables
# ==========================================
INPUT_DIR = input
OUTPUT_DIR = output
PROCS = 1 2 4 6 8 10 12
FILES = 4 5 6 7 8 9 10

# ==========================================
# Build Rules
# ==========================================

all: wariara_freights_route wariara_freights_route_debug

.PHONY: clean benchmark

clean: 
	rm -rf wariara_freights_route wariara_freights_route_debug *~ *.o
	rm -rf $(OUTPUT_DIR)/*

wariara_freights_route: wariara_freights_route.c
	$(CC) $(CFLAGS) $< -o wariara_freights_route

wariara_freights_route_debug: wariara_freights_route.c
	$(CC) $(CFLAGS_DEBUG) $< -o wariara_freights_route_debug

# ==========================================
# Execution Rules (Original)
# ==========================================

run: wariara_freights_route
	mpirun --use-hwthread-cpus -np $(NP) ./wariara_freights_route $(ARGS)

run_debug: wariara_freights_route_debug
	mpirun --use-hwthread-cpus -np $(NP) ./wariara_freights_route_debug $(ARGS)

# ==========================================
# Execution Rules (Automated Benchmarking)
# ==========================================

benchmark: wariara_freights_route
	@mkdir -p $(OUTPUT_DIR)
	@echo "Starting benchmark for Speedup Calculation..."
	@for p in $(PROCS); do \
		echo "====================================="; \
		echo "Testing with $$p processes:"; \
		for f in $(FILES); do \
			echo "  -> energy$$f"; \
			mpirun --use-hwthread-cpus -np $$p ./wariara_freights_route -i $(INPUT_DIR)/energy$$f -o $(OUTPUT_DIR)/energy$$f.txt; \
		done; \
	done
	@echo "Benchmarking complete. Check the $(OUTPUT_DIR) folder."