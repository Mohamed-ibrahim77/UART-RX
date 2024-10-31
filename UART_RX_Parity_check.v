module UART_RX_Parity_check (

	input   wire   CLK,
    input   wire   RST,
    input   wire   PAR_TYP,
    input   wire   par_chk_en,   
    input   wire   sampled_bit,
    input   wire   [7:0] P_DATA,

    output  reg   par_err
);
	
	reg 		recieved_par;  // [8]   >> parity bit from data_sampling
	reg 		calculated_par;
	reg  [7:0]  recieved_data; // [7:0] >> data from deser 

always @(posedge CLK or negedge RST) begin 
	if(~RST) begin
		par_err <= 0;
		recieved_par <= 0;  
		calculated_par <= 0;
		recieved_data <= 8'b0; 	
	end 
	else if (par_chk_en) begin

		recieved_data <= P_DATA;
		recieved_par <= sampled_bit;

		if (PAR_TYP) begin //odd parity
			calculated_par <= ~^ recieved_data;

			if (calculated_par == recieved_par) begin
				par_err <= 0;
			end
			else begin
				par_err <= 1;				
			end
		end
		else begin //even parity
			calculated_par <=  ^ recieved_data;

			if (calculated_par == recieved_par) begin
				par_err <= 0;
			end
			else begin
				par_err <= 1;				
			end
		end
	end
end

endmodule : UART_RX_Parity_check