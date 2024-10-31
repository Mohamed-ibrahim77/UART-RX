module UART_RX_Data_Sampling (
	
	input   wire   		CLK,
    input   wire   		RST,
    input   wire   		data_samp_en,
    input   wire  [5:0] prescale,
    input 	wire   		S_RX_IN, 
    input   wire  [4:0] edge_cnt, // 0 : 31
    input   wire  [3:0] bit_cnt,   // 0 : 10

    output  wire        sampled_bit,
    output  reg         sample_out_flag
);
    
    reg       over_sampled_bit_1;
    reg       over_sampled_bit_2;
    reg       over_sampled_bit_3;

    reg       majority_sampled_bit;  

always @(posedge CLK or negedge RST) begin 
    if(~RST) begin
        majority_sampled_bit <= 0;
        sample_out_flag <= 0;
    end 
    else if (data_samp_en) begin

        /*over_sampled_bit_1 <= 0;
        over_sampled_bit_2 <= 0;
        over_sampled_bit_3 <= 0;*/

        if (edge_cnt == (prescale/2)-1) begin
            over_sampled_bit_1 <= S_RX_IN;
            //over_sampled_bit_2 <= 0;
            //over_sampled_bit_3 <= 0;

        end
        if (edge_cnt == (prescale/2)) begin
            over_sampled_bit_2 <= S_RX_IN;
            //over_sampled_bit_1 <= 0;
            //over_sampled_bit_3 <= 0;

        end
        if (edge_cnt == (prescale/2)+1) begin
            over_sampled_bit_3 <= S_RX_IN;
            //over_sampled_bit_2 <= 0;
            //over_sampled_bit_1 <= 0;
        end
        if (edge_cnt == prescale-2) begin // majority //*

            if (bit_cnt == 1) sample_out_flag <= 1;

            case ({over_sampled_bit_1, over_sampled_bit_2, over_sampled_bit_3})
                
                3'b000 : majority_sampled_bit <= 0;
                3'b001 : majority_sampled_bit <= 0;   
                3'b010 : majority_sampled_bit <= 0;
                3'b011 : majority_sampled_bit <= 1;
                3'b100 : majority_sampled_bit <= 0;
                3'b101 : majority_sampled_bit <= 1;
                3'b110 : majority_sampled_bit <= 1;
                3'b111 : majority_sampled_bit <= 1;
            endcase
        end
        
    end
end

assign sampled_bit = majority_sampled_bit;

endmodule : UART_RX_Data_Sampling