/*
 * Floating Point Unit (FPU) - IEEE 754 Compliant
 * Author: [Your Name]
 * Description:
 *     This module implements an IEEE 754 single-precision floating-point unit (FPU).
 *     It supports basic arithmetic operations and comparisons for 32-bit floating-point numbers.
 * 
 * Operations:
 * - Addition (3'b000)
 * - Subtraction (3'b001)
 * - Multiplication (3'b010)
 * - Division (3'b011)
 * - Sign inversion (3'b100)
 * - Absolute value (3'b101)
 * - Greater comparison (3'b110)
 * - Equality comparison (3'b111)
 */

module fpu(
    output reg [31:0] o_w_out,   // 32-bit output (result of operation)
    input wire [31:0] i_w_op1,  // First operand
    input wire [31:0] i_w_op2,  // Second operand
    input wire [2:0] i_w_opsel  // Operation selector
);
    // Internal signals for exponent, mantissa, and sign
    reg [7:0] exp1, exp2, exp_out;         // Exponents
    reg [47:0] mant1, mant2;              // Extended mantissas
    reg [23:0] mant1_div, mant2_div;      // Mantissas for division
    reg [48:0] mant_out;                  // Intermediate mantissa result
    reg [47:0] mant_out1;                 // Temporary mantissa result for division
    reg sign1, sign2, sign_out;           // Signs
    reg [95:0] mant_product_full;         // Full mantissa product
    reg [50:0] mant_round;                // For rounding
    reg [47:0] mant_rest;                 // Remainder during division
    reg guard, round, sticky, lsb;        // Rounding-related flags
    integer ok;                           // Helper for division case
    reg [31:0] temp_out;                  // Temporary output

    // Always block to compute results based on the operation selector
    always @(*) begin
        // Extract components of the floating-point inputs
        sign1 = i_w_op1[31]; // Sign bit of operand 1
        exp1 = i_w_op1[30:23]; // Exponent of operand 1
        mant1 = {1'b1, i_w_op1[22:0], 24'b0}; // Mantissa of operand 1 with leading 1

        sign2 = i_w_op2[31]; // Sign bit of operand 2
        exp2 = i_w_op2[30:23]; // Exponent of operand 2
        mant2 = {1'b1, i_w_op2[22:0], 24'b0}; // Mantissa of operand 2 with leading 1

        temp_out = 32'b0; // Initialize temporary output
        mant1_div = {1'b1, i_w_op1[22:0]}; // Mantissa for division
        mant2_div = {1'b1, i_w_op2[22:0]}; // Mantissa for division

        // Determine operation based on operation selector
        case (i_w_opsel)
            // Case 3'b000: Addition
            3'b000: begin
                if (exp1 > exp2) begin
                    mant2 = mant2 >> (exp1 - exp2); // Align mantissa of operand 2
                    exp_out = exp1;
                end else begin
                    mant1 = mant1 >> (exp2 - exp1); // Align mantissa of operand 1
                    exp_out = exp2;
                end

                if (sign1 == sign2) begin
                    mant_out = mant1 + mant2; // Same sign: add
                    sign_out = sign1;
                end else if (mant1 >= mant2) begin
                    mant_out = mant1 - mant2; // Different sign: subtract
                    sign_out = sign1;
                end else begin
                    mant_out = mant2 - mant1;
                    sign_out = sign2;
                end

                if (mant_out[48]) begin
                    mant_out = mant_out >> 1;
                    exp_out = exp_out + 1;
                end else begin
                    while (!mant_out[47] && mant_out != 0) begin
                        mant_out = mant_out << 1;
                        exp_out = exp_out - 1;
                    end
                end

                lsb = mant_out[24];
                guard = mant_out[23];
                round = mant_out[22];
                sticky = |mant_out[21:0];
                if (guard && (round || sticky || lsb)) begin
                    mant_out = mant_out + (1 << 24);
                end

                if (mant_out[48]) begin
                    mant_out = mant_out >> 1;
                    exp_out = exp_out + 1;
                end

                temp_out[31] = sign_out;
                temp_out[30:23] = exp_out;
                temp_out[22:0] = mant_out[46:24];
            end

            // Case 3'b001: Subtraction
            3'b001: begin
                sign2 = ~sign2; // Invert sign of operand 2
                // Reuse addition logic with inverted sign
                if (exp1 > exp2) begin
                    mant2 = mant2 >> (exp1 - exp2);
                    exp_out = exp1;
                end else begin
                    mant1 = mant1 >> (exp2 - exp1);
                    exp_out = exp2;
                end

                if (sign1 == sign2) begin
                    mant_out = mant1 + mant2;
                    sign_out = sign1;
                end else if (mant1 >= mant2) begin
                    mant_out = mant1 - mant2;
                    sign_out = sign1;
                end else begin
                    mant_out = mant2 - mant1;
                    sign_out = sign2;
                end

                if (mant_out[48]) begin
                    mant_out = mant_out >> 1;
                    exp_out = exp_out + 1;
                end else begin
                    while (!mant_out[47] && mant_out != 0) begin
                        mant_out = mant_out << 1;
                        exp_out = exp_out - 1;
                    end
                end

                lsb = mant_out[24];
                guard = mant_out[23];
                round = mant_out[22];
                sticky = |mant_out[21:0];
                if (guard && (round || sticky || lsb)) begin
                    mant_out = mant_out + (1 << 24);
                end

                if (mant_out[48]) begin
                    mant_out = mant_out >> 1;
                    exp_out = exp_out + 1;
                end

                temp_out[31] = sign_out;
                temp_out[30:23] = exp_out;
                temp_out[22:0] = mant_out[46:24];
            end

            // Case 3'b010: Multiplication
            3'b010: begin
                sign_out = sign1 ^ sign2;          // Resultant sign
                exp_out = exp1 + exp2 - 127;       // Add exponents with bias adjustment
                mant_product_full = mant1 * mant2; // Full 48-bit mantissa product

                if (mant_product_full[95]) begin
                    mant_out = mant_product_full[95:48];
                    exp_out = exp_out + 1;
                end else begin
                    mant_out = mant_product_full[94:47];
                end

                lsb = mant_out[24];
                guard = mant_out[23];
                round = mant_out[22];
                sticky = |mant_out[21:0];
                if (guard && (round || sticky || lsb)) begin
                    mant_out = mant_out + (1 << 24);
                end

                if (mant_out[48]) begin
                    mant_out = mant_out >> 1;
                    exp_out = exp_out + 1;
                end

                temp_out[31] = sign_out;
                temp_out[30:23] = exp_out;
                temp_out[22:0] = mant_out[46:24];
            end

            // Case 3'b011: Division
            3'b011: begin
                sign_out = sign1 ^ sign2;
                exp_out = exp1 - exp2 + 126; // Adjust exponent for division
                mant_out1 = (mant1_div << 24) / mant2_div; // Perform division

                while (!mant_out1[47]) begin
                    mant_out1 = mant_out1 << 1;
                    exp_out = exp_out - 1;
                end

                temp_out[31] = sign_out;
                temp_out[30:23] = exp_out;
                temp_out[22:0] = mant_out1[46:24];
            end

            // Case 3'b100: Sign inversion
            3'b100: begin
                temp_out = {~sign1, exp1, i_w_op1[22:0]};
            end

            // Case 3'b101: Absolute value
            3'b101: begin
                temp_out = {1'b0, exp1, i_w_op1[22:0]};
            end

            // Case 3'b110: Greater comparison
            3'b110: begin
                temp_out = (i_w_op1 > i_w_op2) ? 32'h3f800000 : 32'b0;
            end

            // Case 3'b111: Equality comparison
            3'b111: begin
                temp_out = (i_w_op1 == i_w_op2) ? 32'h3f800000 : 32'b0;
            end
        endcase

        o_w_out = temp_out; // Output the final result
    end
endmodule
