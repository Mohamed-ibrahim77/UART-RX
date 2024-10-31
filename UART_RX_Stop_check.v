module UART_RX_Stop_check (

	input   wire   CLK,
    input   wire   RST,
    input   wire   stp_chk_en,   
    input   wire   sampled_bit,

    output  reg   stp_err
);
	
always @(posedge CLK or negedge RST) begin 
	if(~RST) begin
		stp_err <= 0;
	end 
	else if (stp_chk_en) begin
		
		if (sampled_bit) begin // stop_bit = 1
			stp_err <= 0; 
		end
		else begin // stop_bit = 0
			stp_err <= 1; 			
		end
	end
end
endmodule : UART_RX_Stop_check