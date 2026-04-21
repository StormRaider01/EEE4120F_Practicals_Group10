`timescale 1ns / 1ps
`include "../src/Parameter.v"

module InstructionMemory_tb;

    reg  [15:0] pc;
    wire [15:0] instruction;

    // Instantiate the Unit Under Test (UUT)
    InstructionMemory uut (
        .pc(pc), 
        .instruction(instruction)
    );

    // Waveform dump for GTKWave report requirements [cite: 24]
    initial begin
        $dumpfile("../waves/im_tb.vcd");
        $dumpvars(0, InstructionMemory_tb);
    end

    integer fail_count;
    integer test_id;
    
    // Array to hold the "Answer Key" for verification
    reg [15:0] expected [0:14];

    initial begin
        fail_count = 0;
        test_id    = 1;

        $display("=== InstructionMemory Testbench ===");

        // --- Step 1: Manual Mapping of your test.prog binary ---
        expected[0]  = 16'b0000010000000000;
        expected[1]  = 16'b0000010001000001;
        expected[2]  = 16'b0010000001010000;
        expected[3]  = 16'b0001001010000000;
        expected[4]  = 16'b0011000001010000;
        expected[5]  = 16'b0111000001010000;
        expected[6]  = 16'b1000000001010000;
        expected[7]  = 16'b1001000001010000;
        expected[8]  = 16'b0010000000000000;
        expected[9]  = 16'b1011000001000001;
        expected[10] = 16'b1100000001000000;
        expected[11] = 16'b1101000000000000;
        expected[12] = 16'b0000000000000000;
        expected[13] = 16'b0000000000000000;
        expected[14] = 16'b0000000000000000;

        // --- Step 2: Walk PC through byte-addresses ---
        // Every StarCore instruction is 2 bytes (16 bits) [cite: 80, 107]
        for (integer j = 0; j < 15; j = j + 1) begin
            pc = j * 2; 
            #5; // Wait for combinational logic to settle [cite: 197]
            
            if (instruction !== expected[j]) begin
                $display("FAIL [T%0d]: PC=%0d got %b exp %b", 
                         test_id, pc, instruction, expected[j]);
                fail_count = fail_count + 1;
            end else begin
                $display("PASS [T%0d]: PC=%0d instruction matched", test_id, pc);
            end
            test_id = test_id + 1;
        end

        // --- Step 3: Summary ---
        $display("");
        if (fail_count == 0)
            $display("=== ALL %0d TESTS PASSED ===", test_id - 1);
        else
            $display("=== %0d / %0d TESTS FAILED ===", fail_count, test_id - 1);
        
        $finish; // End simulation [cite: 150]
    end

endmodule