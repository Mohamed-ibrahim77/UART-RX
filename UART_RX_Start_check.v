module UART_RX_Start_check (

	input   wire   CLK,
    input   wire   RST,
    input   wire   start_chk_en,   
    input   wire   sampled_bit,

    output  reg   start_err	    
);

always @(posedge CLK or negedge RST) begin 
	if(~RST) begin
		start_err <= 0;
	end 
	else if (start_chk_en) begin
		
		if (!sampled_bit) begin // start_bit = 0
			start_err <= 0; 
		end
		else begin // stop_bit = 0
			start_err <= 1; 			
		end
	end
end
endmodule : UART_RX_Start_check