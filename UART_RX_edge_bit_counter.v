module UART_RX_edge_bit_counter (

	input   wire   		CLK,
    input   wire   		RST,
    input   wire   		edge_bit_count_en,
    input   wire   		PAR_EN,
    input   wire  [5:0] prescale, 

    output  reg   [4:0] edge_cnt, // 0 : 31
    output  reg   [3:0] bit_cnt   // 0 : 10
);

always @(posedge CLK or negedge RST) begin 
	if(~RST) begin
		edge_cnt <= 0;
		bit_cnt  <= 0;
	end 
	else if (edge_bit_count_en) begin
		
		@(negedge CLK)  edge_cnt <= edge_cnt + 1;
		//edge_cnt <= edge_cnt + 1;

		if (edge_cnt == prescale-1) begin
			bit_cnt  <= bit_cnt  + 1;
			edge_cnt <= 0;
		end

		if ((PAR_EN && (bit_cnt== 4'hb)) || (!PAR_EN && (bit_cnt==4'ha))) begin
			bit_cnt <= 0;
		end
	end
	
end

endmodule : UART_RX_edge_bit_counter