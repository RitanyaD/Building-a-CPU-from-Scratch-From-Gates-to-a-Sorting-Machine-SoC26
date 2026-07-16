module code_memory(
    input      [5:0] addr,
    output     [15:0] instruction
);

reg [15:0] mem [0:63];

initial begin
    $readmemh("bubble_sort.hex", mem);
end

assign instruction = mem[addr];

endmodule