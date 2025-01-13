# IEEE 754 Floating Point Unit (FPU)

This repository contains a Verilog implementation of an IEEE 754 compliant single-precision floating-point unit (FPU). The module supports basic arithmetic operations, comparisons, and other floating-point functionalities for 32-bit floating-point numbers.

## Features

- **Arithmetic Operations**:
  - Addition
  - Subtraction
  - Multiplication
  - Division
- **Other Operations**:
  - Sign inversion
  - Absolute value
  - Greater-than comparison
  - Equality comparison

## Module Overview

### Ports

| Port Name  | Width | Direction | Description                           |
|------------|-------|-----------|---------------------------------------|
| `o_w_out`  | 32    | Output    | Result of the operation               |
| `i_w_op1`  | 32    | Input     | First floating-point operand          |
| `i_w_op2`  | 32    | Input     | Second floating-point operand         |
| `i_w_opsel`| 3     | Input     | Operation selector (see below)        |

### Operation Selector (`i_w_opsel`)

| `i_w_opsel` | Operation        |
|-------------|------------------|
| `3'b000`    | Addition         |
| `3'b001`    | Subtraction      |
| `3'b010`    | Multiplication   |
| `3'b011`    | Division         |
| `3'b100`    | Sign inversion   |
| `3'b101`    | Absolute value   |
| `3'b110`    | Greater comparison (Op1 > Op2) |
| `3'b111`    | Equality comparison (Op1 == Op2) |

## File Structure

📂 hyperspectral_classification

├── fpu.v                    # Verilog implementation of the FPU
├── test_fpu.v               # Testbench for verifying the FPU
├── README.md                # Project documentation


## How to Use

1. **Clone the Repository**:
   git clone https://github.com/yourusername/IEEE754-FPU.git
   cd IEEE754-FPU

2. **Integrate the Module: Add fpu.v to your Verilog project. Instantiate the FPU module in your design**:
fpu my_fpu (
    .o_w_out(result),
    .i_w_op1(op1),
    .i_w_op2(op2),
    .i_w_opsel(opsel)
);

3. **Simulate: Use the provided testbench (test_fpu.v) to simulate the module with your preferred simulator (ModelSim, Vivado, etc.).**
vsim -c -do "run -all" test_fpu

4. **Modify and Extend: Customize the module for your specific needs or extend its functionality.**

## Testing

The repository includes a testbench (test_fpu.v) that verifies the FPU module. It tests various operations, such as addition, subtraction, multiplication, and division, along with comparisons and other features.

Example test case output:
Time = 0, Op1 = 3f800000, Op2 = 40000000, Sel = 000, Result = 40400000
