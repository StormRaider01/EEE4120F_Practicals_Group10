// // =============================================================================
// // EEE4120F Practical 4 — StarCore-1 Processor
// // File        : StarCore1_tb.v
// // Description : Integration testbench for the full StarCore-1 processor (Task 8).
// //               Runs the program stored in test.prog and verifies processor
// //               behaviour over multiple clock cycles using hierarchical signal
// //               references.
// //
// //               This testbench does NOT drive the processor's datapath signals
// //               directly — it only drives the clock and observes internal state
// //               via hierarchical references.
// //
// // *** IMPORTANT — Expected compile behaviour with the skeleton ***
// // When you first compile this testbench against the skeleton source files,
// // iverilog will report "Unable to bind wire/reg/memory" errors for every
// // hierarchical reference below (uut.DU.pc_current, uut.DU.instr, etc.).
// // This is EXPECTED. Those signals do not yet exist because the Datapath
// // module body is empty. The errors will disappear once you implement the
// // internal signal declarations and sub-module instantiations in Datapath.v
// // and StarCore1.v as required by Tasks 7 and 8.
// //
// // Hierarchical signal reference examples (valid after implementation):
// //   uut.DU.pc_current              — Program Counter (reg in Datapath)
// //   uut.DU.instr                   — Currently fetched instruction word (wire)
// //   uut.DU.alu_result              — ALU output (wire)
// //   uut.DU.zero_flag               — ALU zero flag (wire)
// //   uut.DU.reg_file.reg_array[N]   — Register RN value (inside GPR instance)
// //   uut.DU.dm.memory[N]            — Data memory word N (inside DataMemory instance)
// //   uut.CU.reg_write               — ControlUnit reg_write output
// //   uut.CU.alu_op                  — ControlUnit alu_op output
// //
// // The instance names used here (DU for Datapath, CU for ControlUnit, reg_file
// // for GPR, dm for DataMemory) MUST match the names you use when instantiating
// // those modules in StarCore1.v and Datapath.v respectively.
// //
// // Run:
// //   iverilog -Wall -I ../src -o ../build/star_sim \
// //       ../src/Parameter.v ../src/ALU.v ../src/GPR.v \
// //       ../src/InstructionMemory.v ../src/DataMemory.v \
// //       ../src/ALU_Control.v ../src/ControlUnit.v \
// //       ../src/Datapath.v ../src/StarCore1.v StarCore1_tb.v
// //   cd ../test && ../build/star_sim
// //   gtkwave ../waves/star.vcd &
// // =============================================================================

// `timescale 1ns / 1ps
// `include "../src/Parameter.v"

// module StarCore1_tb;

//     // -------------------------------------------------------------------------
//     // Clock
//     // -------------------------------------------------------------------------
//     reg clk;
//     initial clk = 1'b0;
//     always  #5 clk = ~clk;     // 10 ns period — 100 MHz

//     // -------------------------------------------------------------------------
//     // DUT instantiation
//     // -------------------------------------------------------------------------
//     StarCore1 uut (.clk(clk));

//     // -------------------------------------------------------------------------
//     // Waveform dump — captures ALL signals in the design hierarchy
//     // -------------------------------------------------------------------------
//     initial begin
//         $dumpfile("../waves/star.vcd");
//         $dumpvars(0, StarCore1_tb);
//     end

//     // -------------------------------------------------------------------------
//     // Failure counter
//     // -------------------------------------------------------------------------
//     integer fail_count;
//     integer test_id;

//     initial begin
//         fail_count = 0;
//         test_id    = 1;
//     end

//     // -------------------------------------------------------------------------
//     // Check tasks — compare 16-bit values observed via hierarchical reference
//     // -------------------------------------------------------------------------
//     task check16;
//         input [15:0] got;
//         input [15:0] expected;
//         input [63:0] id;
//         begin
//             if (got !== expected) begin
//                 $display("FAIL [T%0d]: got = 0x%h (%0d), expected = 0x%h (%0d)",
//                          id, got, got, expected, expected);
//                 fail_count = fail_count + 1;
//             end else
//                 $display("PASS [T%0d]: value = 0x%h (%0d)", id, got, got);
//         end
//     endtask

//     // -------------------------------------------------------------------------
//     // Cycle-by-cycle execution trace
//     // This always block fires on every rising clock edge and prints the current
//     // processor state. It is your primary debugging tool.
//     //
//     // TODO: Uncomment this block once Datapath.v is fully implemented.
//     //       Until then, it will cause "Unable to bind" errors because the
//     //       internal signals (pc_current, instr, etc.) do not yet exist.
//     // -------------------------------------------------------------------------
//     always @(posedge clk) begin
//         $display("%0t ns | PC=0x%h | instr=%b | R0=%3d R1=%3d R2=%3d R3=%3d | alu=%0d z=%b",
//             $time,
//             uut.DU.pc_current,
//             uut.DU.instr,
//             uut.DU.reg_file.reg_array[0],
//             uut.DU.reg_file.reg_array[1],
//             uut.DU.reg_file.reg_array[2],
//             uut.DU.reg_file.reg_array[3],
//             uut.DU.alu_result,
//             uut.DU.zero_flag
//         );
//     end
//     //
//     // PLACEHOLDER — prints time only until you uncomment the full trace above.
//     always @(posedge clk) begin
//         $display("%0t ns | clock tick (uncomment trace block when Datapath is implemented)",
//                  $time);
//     end

//     // =========================================================================
//     // MAIN STIMULUS BLOCK
//     // =========================================================================
//     initial begin
//         $display("=== StarCore-1 Integration Testbench ===");
//         $display("=== Program loaded from ./test/test.prog ===");
//         $display("=== Data memory loaded from ./test/test.data ===");
//         $display("");

//         // -----------------------------------------------------------------------
//         // Wait for the simulation to run long enough for your program to
//         // complete at least one full pass. Adjust SIM_TIME in Parameter.v
//         // if your program needs more cycles.
//         // -----------------------------------------------------------------------
//         `SIM_TIME;

//         // -----------------------------------------------------------------------
//         // POST-SIMULATION VERIFICATION
//         //
//         // TODO: After implementing Datapath.v and StarCore1.v, uncomment the
//         //       check16() calls below and fill in the expected values for your
//         //       specific test program.
//         //
//         //       All hierarchical references below (uut.DU.*, uut.DU.reg_file.*,
//         //       uut.DU.dm.*) are commented out because they reference signals
//         //       that do not exist until the Datapath is implemented.
//         //       Uncomment them one section at a time as you complete each task.
//         // -----------------------------------------------------------------------

//         $display("");
//         $display("--- Post-Simulation Verification (implement Datapath first) ---");

//         // -----------------------------------------------------------------------
//         // STEP 1: Verify register values after execution.
//         // Uncomment and fill in expected values after implementing Datapath.v.
//         // -----------------------------------------------------------------------
//         $display("Checking R0 after LD (expect Mem[0] = 0x0001):");
//         check16(uut.DU.reg_file.reg_array[0], 16'h0001, test_id);
//         test_id = test_id + 1;
        
//         $display("Checking R1 after LD (expect Mem[1] = 0x0002):");
//         check16(uut.DU.reg_file.reg_array[1], 16'h0002, test_id);
//         test_id = test_id + 1;
        
//         $display("Checking R2 after ADD R0+R1 (expect 0x0001+0x0002 = 0x0003):");
//         check16(uut.DU.reg_file.reg_array[2], 16'h0003, test_id);
//         test_id = test_id + 1;

//         // -----------------------------------------------------------------------
//         // STEP 2: Verify data memory after ST instruction.
//         // The example program stores R2 to Mem[R1+0] = Mem[2] (address offset 0).
//         // Uncomment after implementing Datapath.v.
//         // -----------------------------------------------------------------------
//         $display("Checking DataMem[2] after ST R2 -> Mem[R1+0]:");
//         check16(uut.DU.dm.memory[2], 16'h0003, test_id);
//         test_id = test_id + 1;

//         //-----------------------------------------------------------------------
//         // STEP 3: Verify additional R-type instruction results.
//         // After SUB R2,R0,R1: R2 = 0x0001 - 0x0002 = 0xFFFF (wrap-around)
//         // NOTE: SUB happens AFTER ST in the example program so R2 changes.
//         // Adjust expected values to match the state at end of SIM_TIME.
//         //-----------------------------------------------------------------------
//         $display("Add your R-type verification checks here...");
//         $display("Checking SUB R2, R0, R1 (expect 0xFFFF):");
//         check16(uut.DU.reg_file.reg_array[2], 16'hFFFF, test_id); 
//         test_id = test_id + 1;
//         // -----------------------------------------------------------------------
//         // STEP 4: Add your own checks for AND, OR, SLT, branch, jump effects.
//         // -----------------------------------------------------------------------
//         $display("Checking R2 after AND (expect R0 & R1):");
//         // If R0=0x0001 and R1=0x0002, R2 should be 0x0000
//         check16(uut.DU.reg_file.reg_array[2], 16'h0000, test_id);
//         test_id = test_id + 1;

//         $display("Checking R3 after SLT (Set on Less Than):");
//         // If R0 < R1 (1 < 2), R3 should be 1
//         check16(uut.DU.reg_file.reg_array[3], 16'h0001, test_id);
//         test_id = test_id + 1;
//         // -----------------------------------------------------------------------
//         // Print register and memory state (safe to uncomment after Task 7)
//         // -----------------------------------------------------------------------
//         $display("");
//         $display("--- Final Register File State ---");
//         $display("R0=0x%h  R1=0x%h  R2=0x%h  R3=0x%h",
//             uut.DU.reg_file.reg_array[0], uut.DU.reg_file.reg_array[1],
//             uut.DU.reg_file.reg_array[2], uut.DU.reg_file.reg_array[3]);
//         $display("R4=0x%h  R5=0x%h  R6=0x%h  R7=0x%h",
//             uut.DU.reg_file.reg_array[4], uut.DU.reg_file.reg_array[5],
//             uut.DU.reg_file.reg_array[6], uut.DU.reg_file.reg_array[7]);
        
//         $display("");
//         $display("--- Final Data Memory State ---");
//         $display("Mem[0]=0x%h  Mem[1]=0x%h  Mem[2]=0x%h  Mem[3]=0x%h",
//             uut.DU.dm.memory[0], uut.DU.dm.memory[1],
//             uut.DU.dm.memory[2], uut.DU.dm.memory[3]);
//         $display("Mem[4]=0x%h  Mem[5]=0x%h  Mem[6]=0x%h  Mem[7]=0x%h",
//             uut.DU.dm.memory[4], uut.DU.dm.memory[5],
//             uut.DU.dm.memory[6], uut.DU.dm.memory[7]);

//         // -----------------------------------------------------------------------
//         // Summary
//         // -----------------------------------------------------------------------
//         $display("");
//         if (fail_count == 0)
//             $display("=== ALL %0d INTEGRATION TESTS PASSED ===", test_id - 1);
//         else
//             $display("=== %0d / %0d INTEGRATION TESTS FAILED ===", fail_count, test_id - 1);

//         $finish;
//     end

// endmodule

// =============================================================================
// EEE4120F Practical 4 — StarCore-1 Processor
// File        : StarCore1_tb.v  (CORRECTED)
// Description : Integration testbench for the full StarCore-1 processor.
//
// Test program summary (test.prog + test.data):
//   Mem[0]=0x0001, Mem[1]=0x0002 (initial data memory)
//   Cycle 1 : LD  R1, 0(R0)     → R1 = 0x0001
//   Cycle 2 : LD  R2, 1(R0)     → R2 = 0x0002
//   Cycle 3 : ADD R3, R1, R2    → R3 = 0x0003
//   Cycle 4 : ST  R3, 0(R1)     → Mem[1] = 0x0003
//   Cycle 5 : SUB R3, R1, R2    → R3 = 0xFFFF (wrap-around)
//   Cycle 6 : AND R3, R1, R2    → R3 = 0x0000
//   Cycle 7 : OR  R3, R1, R2    → R3 = 0x0003
//   Cycle 8 : SLT R3, R1, R2    → R3 = 0x0001 (1 < 2 is true)
//   Cycle 9 : INV R4, R1        → R4 = 0xFFFE
//   Cycle 10: BEQ R1, R2, +1   → no branch (R1 != R2)
//   Cycle 11: BNE R1, R2, 0    → branch taken (R1 != R2), PC loops
//   Cycle 12: JMP 0             → jump back to address 0
//
// Run:
//   iverilog -Wall -I ../src -o ../build/star_sim \
//       ../src/Parameter.v ../src/ALU.v ../src/GPR.v \
//       ../src/InstructionMemory.v ../src/DataMemory.v \
//       ../src/ALU_Control.v ../src/ControlUnit.v \
//       ../src/Datapath.v ../src/StarCore1.v StarCore1_tb.v
//   cd ../test && ../build/star_sim
//   gtkwave ../waves/star.vcd &
// =============================================================================

`timescale 1ns / 1ps
`include "../src/Parameter.v"

module StarCore1_tb;

    // -------------------------------------------------------------------------
    // Clock — 10 ns period (100 MHz)
    // -------------------------------------------------------------------------
    reg clk;
    initial clk = 1'b0;
    always #5 clk = ~clk;

    // -------------------------------------------------------------------------
    // DUT instantiation
    // -------------------------------------------------------------------------
    StarCore1 uut (.clk(clk));

    // -------------------------------------------------------------------------
    // Waveform dump — captures ALL signals in the design hierarchy
    // -------------------------------------------------------------------------
    initial begin
        $dumpfile("../waves/star.vcd");
        $dumpvars(0, StarCore1_tb);
    end

    // -------------------------------------------------------------------------
    // Failure / test counters
    // -------------------------------------------------------------------------
    integer fail_count;
    integer test_id;

    initial begin
        fail_count = 0;
        test_id    = 1;
    end

    // -------------------------------------------------------------------------
    // Check task — compares 16-bit values and prints PASS/FAIL
    // -------------------------------------------------------------------------
    task check16;
        input [15:0] got;
        input [15:0] expected;
        input integer id;
        begin
            if (got !== expected) begin
                $display("FAIL [T%0d]: got=0x%h (%0d)  expected=0x%h (%0d)",
                         id, got, got, expected, expected);
                fail_count = fail_count + 1;
            end else
                $display("PASS [T%0d]: value=0x%h (%0d)", id, got, got);
        end
    endtask

    // -------------------------------------------------------------------------
    // Cycle-by-cycle execution trace
    // Fires on every rising clock edge — primary debugging tool.
    // Shows: time, PC, raw instruction bits, R0-R3, ALU result, zero flag.
    // -------------------------------------------------------------------------
    always @(posedge clk) begin
        $display("%0t ns | PC=0x%04h | instr=%b | R0=%0d R1=%0d R2=%0d R3=%0d R4=%0d | alu=0x%04h z=%b",
            $time,
            uut.DU.pc_current,
            uut.DU.instr,
            uut.DU.reg_file.reg_array[0],
            uut.DU.reg_file.reg_array[1],
            uut.DU.reg_file.reg_array[2],
            uut.DU.reg_file.reg_array[3],
            uut.DU.reg_file.reg_array[4],
            uut.DU.alu_result,
            uut.DU.zero_flag
        );
    end

    // =========================================================================
    // MAIN STIMULUS
    // =========================================================================
    initial begin
        $display("============================================");
        $display("  StarCore-1 Integration Testbench");
        $display("  Program  : ./test/test.prog");
        $display("  Data mem : ./test/test.data");
        $display("============================================");
        $display("");

        // Wait for SIM_TIME (defined in Parameter.v — set to at least 200ns
        // so all 12 active instructions have time to execute).
        `SIM_TIME;

        // =====================================================================
        // POST-SIMULATION VERIFICATION
        // These checks reflect the FINAL register/memory state after SIM_TIME.
        //
        // Because the program loops (JMP 0 at cycle 12), the final state
        // depends on how many iterations complete. Set SIM_TIME so that
        // exactly ONE full pass finishes before the loop restarts, OR verify
        // intermediate values by sampling in the always block above.
        //
        // For a single-pass check, set SIM_TIME = #125 (12 cycles + margin).
        // =====================================================================

        $display("--- Post-Simulation Register Checks ---");

        // T1: R1 loaded from Mem[0] = 0x0001
        $display("T1: R1 after LD R1,0(R0)  — expect 0x0001");
        check16(uut.DU.reg_file.reg_array[1], 16'h0001, test_id);
        test_id = test_id + 1;

        // T2: R2 loaded from Mem[1] = 0x0002
        $display("T2: R2 after LD R2,1(R0)  — expect 0x0002");
        check16(uut.DU.reg_file.reg_array[2], 16'h0002, test_id);
        test_id = test_id + 1;

        // T3: R3 = R1 + R2 = 0x0003  (ADD)
        // T3: R3's final value after all R-type ops complete is 0x0001 (from SLT)
        // The ADD result (0x0003) was correct but later overwritten by SUB/AND/OR/SLT.
        // We verify the ADD was correct indirectly via T4 (Mem[1]=0x0003 from ST R3).
        $display("T3: Mem[0] unmodified (no ST to addr 0) — expect 0x0001");
        check16(uut.DU.dm.memory[0], 16'h0001, test_id);
        test_id = test_id + 1;
        

        // T4: Mem[1] written by ST R3,0(R1) = 0x0003
        $display("T4: Mem[1] after ST R3,0(R1) — expect 0x0003");
        check16(uut.DU.dm.memory[1], 16'h0003, test_id);
        test_id = test_id + 1;

        // NOTE: After ADD the program continues through SUB, AND, OR, SLT, INV.
        // R3 is overwritten each time. Final R3 after SLT = 0x0001.
        // R4 is written only by INV R4,R1 = ~0x0001 = 0xFFFE.

        // T5: R3 after SLT R3,R1,R2 — last write to R3 in the program
        $display("T5: R3 after SLT R3,R1,R2 — expect 0x0001 (1 < 2 is true)");
        check16(uut.DU.reg_file.reg_array[3], 16'h0001, test_id);
        test_id = test_id + 1;

        // T6: R4 after INV R4,R1 = ~0x0001
        $display("T6: R4 after INV R4,R1    — expect 0xFFFE");
        check16(uut.DU.reg_file.reg_array[4], 16'hFFFE, test_id);
        test_id = test_id + 1;

        // T7: R0 must always be 0 (never written in this program)
        $display("T7: R0 untouched          — expect 0x0000");
        check16(uut.DU.reg_file.reg_array[0], 16'h0000, test_id);
        test_id = test_id + 1;

        // =====================================================================
        // Final state dump — useful for waveform cross-checking in report
        // =====================================================================
        $display("");
        $display("--- Final Register File ---");
        $display("R0=0x%04h  R1=0x%04h  R2=0x%04h  R3=0x%04h",
            uut.DU.reg_file.reg_array[0], uut.DU.reg_file.reg_array[1],
            uut.DU.reg_file.reg_array[2], uut.DU.reg_file.reg_array[3]);
        $display("R4=0x%04h  R5=0x%04h  R6=0x%04h  R7=0x%04h",
            uut.DU.reg_file.reg_array[4], uut.DU.reg_file.reg_array[5],
            uut.DU.reg_file.reg_array[6], uut.DU.reg_file.reg_array[7]);

        $display("");
        $display("--- Final Data Memory ---");
        $display("Mem[0]=0x%04h  Mem[1]=0x%04h  Mem[2]=0x%04h  Mem[3]=0x%04h",
            uut.DU.dm.memory[0], uut.DU.dm.memory[1],
            uut.DU.dm.memory[2], uut.DU.dm.memory[3]);
        $display("Mem[4]=0x%04h  Mem[5]=0x%04h  Mem[6]=0x%04h  Mem[7]=0x%04h",
            uut.DU.dm.memory[4], uut.DU.dm.memory[5],
            uut.DU.dm.memory[6], uut.DU.dm.memory[7]);

        // =====================================================================
        // Summary
        // =====================================================================
        $display("");
        if (fail_count == 0)
            $display("=== ALL %0d INTEGRATION TESTS PASSED ===", test_id - 1);
        else
            $display("=== %0d / %0d INTEGRATION TESTS FAILED ===",
                     fail_count, test_id - 1);

        $finish;
    end

endmodule