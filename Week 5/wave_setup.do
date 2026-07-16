add wave -divider "Clock and Control"
add wave sim:/tb_i281_cpu/clk
add wave sim:/tb_i281_cpu/rst
add wave -radix unsigned sim:/tb_i281_cpu/dut/pc_value
add wave -radix hexadecimal sim:/tb_i281_cpu/dut/instruction
add wave sim:/tb_i281_cpu/dut/reg_we
add wave sim:/tb_i281_cpu/dut/dmem_we
add wave -radix unsigned sim:/tb_i281_cpu/dut/dmem_addr

add wave -divider "Register File"
add wave -radix unsigned sim:/tb_i281_cpu/dut/registers/regs(0)
add wave -radix unsigned sim:/tb_i281_cpu/dut/registers/regs(1)
add wave -radix unsigned sim:/tb_i281_cpu/dut/registers/regs(2)
add wave -radix unsigned sim:/tb_i281_cpu/dut/registers/regs(3)

add wave -divider "Data Memory"
add wave -radix unsigned sim:/tb_i281_cpu/dut/data_mem/mem(0)
add wave -radix unsigned sim:/tb_i281_cpu/dut/data_mem/mem(1)
add wave -radix unsigned sim:/tb_i281_cpu/dut/data_mem/mem(2)
add wave -radix unsigned sim:/tb_i281_cpu/dut/data_mem/mem(3)
add wave -radix unsigned sim:/tb_i281_cpu/dut/data_mem/mem(4)

restart -f
run 2020 ns
wave zoom full