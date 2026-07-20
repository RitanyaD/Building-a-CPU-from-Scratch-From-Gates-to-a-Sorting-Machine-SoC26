quietly WaveActivateNextPane {} 0

add wave -divider {Clock and PC}
add wave /tb_pipelined_cpu/clk
add wave /tb_pipelined_cpu/rst
add wave -radix unsigned /tb_pipelined_cpu/dut/pc_value

add wave -divider {Pipeline Instructions}
add wave -radix hex /tb_pipelined_cpu/dut/if_instruction
add wave -radix hex /tb_pipelined_cpu/dut/IF_ID_instruction
add wave -radix hex /tb_pipelined_cpu/dut/ID_EX_instruction
add wave -radix hex /tb_pipelined_cpu/dut/EX_MEM_instruction
add wave -radix hex /tb_pipelined_cpu/dut/MEM_WB_instruction

add wave -divider {Hazards and Control Transfer}
add wave /tb_pipelined_cpu/dut/load_use_stall
add wave /tb_pipelined_cpu/dut/flag_use_stall
add wave /tb_pipelined_cpu/dut/data_stall
add wave /tb_pipelined_cpu/dut/ID_EX_branch_taken
add wave /tb_pipelined_cpu/dut/control_transfer_ex
add wave -radix unsigned /tb_pipelined_cpu/dut/branch_target_ex

add wave -divider {Forwarding and EX}
add wave -radix unsigned /tb_pipelined_cpu/dut/ID_EX_rx_data
add wave -radix unsigned /tb_pipelined_cpu/dut/ID_EX_ry_data
add wave -radix unsigned /tb_pipelined_cpu/dut/rx_forwarded
add wave -radix unsigned /tb_pipelined_cpu/dut/ry_forwarded
add wave -radix unsigned /tb_pipelined_cpu/dut/forward_rx_sel
add wave -radix unsigned /tb_pipelined_cpu/dut/forward_ry_sel
add wave -radix unsigned /tb_pipelined_cpu/dut/ex_alu_result

add wave -divider {Register File}
add wave -radix unsigned /tb_pipelined_cpu/dut/registers/regs(0)
add wave -radix unsigned /tb_pipelined_cpu/dut/registers/regs(1)
add wave -radix unsigned /tb_pipelined_cpu/dut/registers/regs(2)
add wave -radix unsigned /tb_pipelined_cpu/dut/registers/regs(3)

add wave -divider {Flags}
add wave /tb_pipelined_cpu/dut/flag_zf
add wave /tb_pipelined_cpu/dut/flag_nf
add wave /tb_pipelined_cpu/dut/flag_of

add wave -divider {Data Memory}
add wave -radix unsigned /tb_pipelined_cpu/dut/data_mem/mem(0)
add wave -radix unsigned /tb_pipelined_cpu/dut/data_mem/mem(1)
add wave -radix unsigned /tb_pipelined_cpu/dut/data_mem/mem(2)
add wave -radix unsigned /tb_pipelined_cpu/dut/data_mem/mem(3)
add wave -radix unsigned /tb_pipelined_cpu/dut/data_mem/mem(4)

restart -f
run 5050 ns
wave zoom full
