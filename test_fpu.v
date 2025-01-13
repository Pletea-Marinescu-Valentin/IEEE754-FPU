`timescale 1ns / 1ps

module test_fpu;
    // Inputs
    reg [31:0] l_r_op1;  // Operand 1
    reg [31:0] l_r_op2;  // Operand 2
    reg [2:0] l_r_sel;   // Operation selector

    // Outputs
    wire [31:0] l_w_out; // Result

    // Module initialization
    fpu uut (
        .o_w_out(l_w_out),
        .i_w_op1(l_r_op1),
        .i_w_op2(l_r_op2),
        .i_w_opsel(l_r_sel)
    );

    // Simulation tests
    initial begin
        $monitor(
            "Time = %0t | ", $time,
            "Op1 = %h | Op2 = %h | Sel = %b | Result = %h",
            l_r_op1, l_r_op2, l_r_sel, l_w_out
        );

        // Test Case 1: Addition (1.0 + 2.0)
        l_r_op1 = 32'h3f800000; // 1.0
        l_r_op2 = 32'h40000000; // 2.0
        l_r_sel = 3'b000;       // Add
        #10;

        // Test Case 2: Subtraction (2.0 - 1.0)
        l_r_op1 = 32'h40000000; // 2.0
        l_r_op2 = 32'h3f800000; // 1.0
        l_r_sel = 3'b001;       // Subtract
        #10;

        // Test Case 3: Multiplication (1.5 * 2.0)
        l_r_op1 = 32'h3fc00000; // 1.5
        l_r_op2 = 32'h40000000; // 2.0
        l_r_sel = 3'b010;       // Multiply
        #10;

        // Test Case 4: Division (3.0 / 1.5)
        l_r_op1 = 32'h40400000; // 3.0
        l_r_op2 = 32'h3fc00000; // 1.5
        l_r_sel = 3'b011;       // Divide
        #10;

        // Test Case 5: Sign inversion
        l_r_op1 = 32'h40400000; // 3.0
        l_r_op2 = 32'h0;        // Not used
        l_r_sel = 3'b100;       // Sign inversion
        #10;

        // Test Case 6: Absolute value
        l_r_op1 = 32'hc0400000; // -3.0
        l_r_op2 = 32'h0;        // Not used
        l_r_sel = 3'b101;       // Absolute value
        #10;

        // Test Case 7: Greater-than comparison (3.0 > -3.0)
        l_r_op1 = 32'h40400000; // 3.0
        l_r_op2 = 32'hc0400000; // -3.0
        l_r_sel = 3'b110;       // Greater-than comparison
        #10;

        // Test Case 8: Equality comparison (3.0 == 3.0)
        l_r_op1 = 32'h40400000; // 3.0
        l_r_op2 = 32'h40400000; // 3.0
        l_r_sel = 3'b111;       // Equality comparison
        #10;

        $finish; // End simulation
    end
endmodule
