# Week 2 — Important Circuits

## Objective
Build a strong foundation in essential digital circuits that serve as the core building blocks of modern digital systems. By the end of this week, you should understand how arithmetic, combinational, and sequential circuits operate, how they are implemented in Verilog.

In the assignment, you will design and implement several hardware components that will later be integrated into your own processor in the later weeks.

Note: The material presented here is intended to serve as a concise overview of the topics. It is highly recommended that you read the textbook sections thoroughly for a deeper understanding and additional examples. You are also encouraged to practice beyond the listed exercises to build stronger intuition and familiarity with digital circuit design.

Also, I'll add another markdown file containing some interesting problems

---

# Circuits

You may have already encountered several circuits while practicing Verilog in Week 1.

At its core, a circuit takes some input values, performs an operation on them, and produces outputs. In many ways, you can think of a circuit as a hardware implementation of a mathematical function.

Circuits are broadly classified into two categories:

- **Combinational circuits**
- **Sequential circuits**

---

# Combinational Circuits

In combinational circuits, the output depends only on the current inputs.

$$\text{outputs} = f(\text{inputs})$$

There is no concept of memory or previous state.

If the inputs change, the outputs change immediately according to the implemented logic (ignoring the propagation delay ofc, output take some time to change after the inputs change in reality).

Some important combinational circuits are:

- Adders / Subtractors
- Multiplexers (MUXes)
- Decoders

---

## Adders / Subtractors
(Read about signed and unsigned integers from the textbook before reading this.)
### Definition / Functionality
Adders perform binary addition, while subtractors perform binary subtraction.

These circuits form the basis of arithmetic operations inside processors and ALUs (Arithmetic Logic Units).

---
<img width="1280" height="245" alt="photo_6097955148110958441_y" src="https://github.com/user-attachments/assets/337a3da9-3bb0-4056-ab4e-a6f4a939742f" />

### Intuition and Relevance
Computers ultimately perform arithmetic using combinations of simple logic gates.

Even complex operations like:
- multiplication,
- address calculation,
- instruction execution,

Relies heavily on adders internally.

Understanding adders is important because:
- CPUs spend significant time performing arithmetic
- Larger arithmetic units are built from smaller adders
- They introduce concepts like carry propagation and overflow

---

### Verilog Code
Half adders do a+b

```verilog
module half_adder(
    input a,
    input b,
    output sum,
    output cout
);

assign sum  = a ^ b;
assign cout = a & b;

endmodule
```
Full adders do a+b+c

```verilog
module full_adder(
    input a,
    input b,
    input cin,
    output sum,
    output cout
);

assign sum  = a ^ b ^ cin;
assign cout = (a & b) | (b & cin) | (a & cin);

endmodule
```
All we have looked at are 1-bit adders; these adders are used to make large adders
<img width="1280" height="542" alt="photo_6097955148110958442_y" src="https://github.com/user-attachments/assets/8fda11ff-15a5-45af-b7e1-008b8e69e2d5" />
This kind of adder is called a ripple carry adder.
It is simple, but the problem is that the full adders have to wait for the carry-in from the previous adder to settle down, so it's slow.
There are other configurations, like the Carry Look Ahead Adder, which deal with this issue. You can look it up if you are interested.

### An interesting remark
Binary addition of single bits without carry is exactly the same as modulo-2 addition
Sometimes the $\oplus$, which is used to represent xor, is synonymously used as modulo 2 addition in math and computer science.

$$ a \^ b = a \oplus b = (a+b)mod2$$

---

## Multiplexers (MUX)

### Definition / Functionality
A multiplexer selects one of several input signals and forwards the selected input to the output based on a select signal.

---
<img width="1280" height="205" alt="photo_6097955148110958445_y" src="https://github.com/user-attachments/assets/3d8e93d1-5429-4443-9693-a21544096a5a" />


### Intuition and Relevance
A multiplexer acts like a digital switch.

Examples:
- Choosing between multiple data sources
- Selecting ALU outputs
- Routing data between registers

MUXes are extremely important because they control the flow of data inside digital systems.

I personally like to think of mux'es like this in my mind
<img width="1280" height="188" alt="photo_6097955148110958446_y" src="https://github.com/user-attachments/assets/47c5891c-05cd-4db9-ac90-a39faba93197" />

Also, whenever you use an if-else condition, it is instantiated as a mux because of the selecting property that it has.
Another interesting thing about muxes is that it is also a universal gate, just like NAND. All digital circuits can be realised using just 2to1 muxes!
This universality is heavily utilized in FPGAs, where digital circuits are primarily implemented using LUTs (Look-Up Tables). Since a multiplexer can be used to realize any Boolean function, LUT-based architectures internally rely on mux-like selection mechanisms to implement arbitrary combinational logic efficiently.

---

### Verilog Code

```verilog
module mux2(
    input a,
    input b,
    input sel,
    output y
);

assign y = sel ? b : a;

endmodule
```

---

## Decoders

### Definition / Functionality
A decoder converts an encoded binary input into a one-hot output.

For an \(n\)-bit input, a decoder usually produces \(2^n\) outputs.

---
<img width="1280" height="226" alt="photo_6097955148110958453_y" src="https://github.com/user-attachments/assets/cc85553b-a7c8-488b-b216-d9c7b1825643" />



### Intuition and Relevance
Decoders are used whenever a specific component needs to be selected.

Applications include:
- Selecting memory locations
- Enabling registers
- Instruction decoding in processors

They are fundamental building blocks in control logic.
They can be thought of as the reverse of a mux, a demux, so to speak


---

### Verilog Code

```verilog
module decoder2to4(
    input [1:0] in,
    output [3:0] out
);

assign out = 4'b0001 << in;

endmodule
```

---

# Sequential Circuits

In sequential circuits, the output depends not only on the current inputs but also on the previous state of the system.

\[
\text{outputs} = f(\text{state}, \text{inputs})
\]

Unlike combinational circuits, sequential circuits have memory.

The stored information representing the current condition of the system is called the **state**.

Some important sequential circuits are:

- RS Latch
- D Latch
- D Flip-Flop
- Registers
- Counters

---

## RS Latch

### Definition / Functionality
An RS (Reset-Set) latch is one of the simplest memory elements.

It can store a single bit of information.

---
<img width="393" height="128" alt="image" src="https://github.com/user-attachments/assets/747a4fc8-7990-4237-8cef-55d514abc17d" />



---

### Intuition and Relevance
The RS latch introduces the fundamental idea of feedback and memory in digital systems.

It demonstrates how a circuit can “remember” previous information even after inputs change.

This may not look like it, but it's a really big deal. Btw, one of the reasons quantum computers and photonic computing systems face challenges is their difficulty in maintaining stable memory or state over time. In our institute, Prof. Kasthuri Saha works on nitrogen-vacancy (NV) centers in diamond, which are among the leading candidates for qubit storage due to their relatively long coherence times and suitability for quantum information storage

---

### Verilog Code

```verilog
module rs_latch(
    input r,
    input s,
    output reg q
);

always @(*) begin
    if (s)
        q = 1'b1;
    else if (r)
        q = 1'b0;
end

endmodule
```

---

## D Latch

### Definition / Functionality
A D latch stores the input value when the enable signal is active.
Or to rephrase, output follows D when the enable signal is active and holds its value otherwise

---
<img width="391" height="129" alt="image" src="https://github.com/user-attachments/assets/e76912d2-b8a7-4068-a38d-0bc6a87527cb" />

---

### Intuition and Relevance
The D latch removes the invalid-state issue present in RS latches and serves as the conceptual foundation for flip-flops and registers.

---

### Verilog Code

```verilog
module d_latch(
    input d,
    input en,
    output reg q
);

always @(*) begin
    if (en)
        q = d;
end

endmodule
```

---

## D Flip-Flop

### Definition / Functionality
A D flip-flop stores data on a clock edge, i.e. Q gets the value of D just before the clock edge.

Note: There are some setup and hold time conditions for a flip-flop to work properly, but it's not that relevant now;but an interested soul can always check it out

---
<img width="399" height="126" alt="image" src="https://github.com/user-attachments/assets/6fe09e85-ccdd-45e4-bedf-6d33b58949e0" />
That triangle generally means that the circuit is an edge-triggered circuit. It is only a triangle that is there, it is positive edge triggered, if there is a circle beside the triangle, its negative edge triggered, and if there is no triangle, it is level triggered (so just a d latch)

---

### Intuition and Relevance
Flip-flops synchronize data movement using a clock signal, making them essential for synchronous digital systems such as processors.

---

### Verilog Code

```verilog
module dff(
    input clk,
    input d,
    output reg q
);

always @(posedge clk)
    q <= d;

endmodule
```

---

## Registers

### Definition / Functionality
Registers store multiple bits of data using collections of flip-flops.

---

<img width="1280" height="262" alt="photo_6097955148110958474_y" src="https://github.com/user-attachments/assets/28fd9161-a261-4892-aec8-16d972e7cd07" />


---

### Intuition and Relevance
Registers are heavily used inside CPUs for:
- Storing intermediate values
- Holding instructions
- Managing addresses and data

They form the backbone of processor datapaths.

---

### Verilog Code

```verilog
module register #(parameter WIDTH = 8)(
    input clk,
    input [WIDTH-1:0] d,
    output reg [WIDTH-1:0] q
);

always @(posedge clk)
    q <= d;

endmodule
```

---

## Counters

### Definition / Functionality
Counters increment or decrement their stored value on each clock cycle.

---

### Intuition and Relevance
Counters are used for:
- Timing
- Frequency division
- Address generation
- Control sequencing

They are among the most commonly used sequential circuits.

---

### Verilog Code

```verilog
module counter4(
    input clk,
    input reset,
    output reg [3:0] count
);

always @(posedge clk or posedge reset) begin
    if (reset)
        count <= 4'b0000;
    else
        count <= count + 1'b1;
end

endmodule
```

---


## Textbook Reference (Brown & Vranesic, 3rd Ed.)

| Topic                          | Section          |
|-------------------------------|------------------|
| Arithmetic circuits For Unsigned integers  | Ch. 3, §3.1–3.2  |
| Signed numbers and Adder/subtractor              | Ch. 3, §3.3.1-3.3.3      |
| Overflow detection            | Ch. 3, §3.3.5  |
| Arithmetic in Verilog         | Ch. 3, §3.5      |
| Multiplexers (detailed)       | Ch. 4, §4.1      |
| Decoders                      | Ch. 4, §4.2      | 
| D Latch and D flipflops       | CH. 5, §5.3,5.4  |
| Registers                     | Ch. 5, §5.8      |
| Counters                      | Ch. 5, §5.9      |
|-------------------------------|------------------|
|Design of Arithmetic circuits using cad tools|Ch. 3,§3.6|
|Verilog for combinational circuits |Ch. 4,§4.6|
|Using verliog constructs for registers and counters|Ch. 5, §5.13|

Note: Floating-point arithmetic won't be needed since we will not be implementing that
---

## Exercises

First, do the problems mentioned below in HDLBits that will build up to these modules, then go to the `Assignment`.

#### Combinational logic
More logic gates, truth tables, combine circuits A and B, ring or vibrate, 256 to 1 4-bit mux, half adder, full adder, adder, subtractor, encoder, decoder

#### Sequential logic
DFF, DFF with reset, DFF with asynchronous reset, DFFs and gates, 4-bit binary counter, Decade counter, 4-bit shift register,3-input LUT

---

