module UART_RX_FSM (
		
	input   wire  		CLK,
    input   wire  		RST,
    input   wire  		PAR_EN,
    input   wire  		S_RX_IN,
    input   wire  [5:0] prescale, 
    input   wire  [4:0] edge_cnt,  // 0 : 31
    input   wire  [3:0] bit_cnt,   // 0 : 10
    input	wire  		start_glitch,
    input	wire  		par_err,
    input	wire  		stp_err,

    output  reg			start_chk_en,
    output  reg			par_chk_en,
    output  reg			stp_chk_en,
    output  reg			edge_bit_count_en,
    output  reg			data_samp_en,
    output  reg			deser_en,
    output  reg			Data_Valid
);

// state encoding
/*typedef enum reg [2:0] {
    
    IDLE     = 3'b000,
	start    = 3'b001,
	data     = 3'b010,
	parity   = 3'b011,
	stop     = 3'b100,
	err_chk  = 3'b101,
	data_vld = 3'b110

} state_t;
*/
// state encoding
parameter   [2:0]      IDLE     = 3'b000,
                       start    = 3'b001,
					   data     = 3'b010,
					   parity   = 3'b011,
					   stop     = 3'b100,
					   err_chk  = 3'b101,
					   data_vld = 3'b110;
/*
parameter   [2:0]      IDLE     = 3'b000,
                       start    = 3'b001,
					   data     = 3'b011,
					   parity   = 3'b010,
					   stop     = 3'b110,
					   err_chk  = 3'b111,
					   data_vld = 3'b101;
*/
reg         [2:0]  	   curr_st , next_st ;			
reg                    temp_data_valid ;

// state transition
always @ (posedge CLK or negedge RST)
 	begin
  		if(!RST)
   			begin
    			curr_st <= IDLE ;
    			start_chk_en = 1'b0;
				par_chk_en = 1'b0;
				stp_chk_en = 1'b0;
				edge_bit_count_en = 1'b0;
				data_samp_en = 1'b0; 
				deser_en = 1'b0;
				temp_data_valid = 1'b0;
   			end
  		else
   			begin
    			curr_st <= next_st ;
   			end
 	end

// next state & output logic
always @ (*)
 	begin

  		case(curr_st)
  			IDLE  : begin
            			if((!S_RX_IN) && (bit_cnt == 0))begin
							edge_bit_count_en = 1;
							start_chk_en = 1;
							data_samp_en = 1'b1; 

							par_chk_en = 1'b0;
							stp_chk_en = 1'b0;
							deser_en = 1'b0;
							temp_data_valid = 1'b0;
            				
            				next_st = start ;
            			end
							
						else
							next_st = IDLE ; 			
           			end
			
			start : begin
						//if (bit_cnt == 1 && !start_glitch) begin
						if(bit_cnt < 1 && !start_glitch) begin
							
							next_st = start ;
							
						end
						//else if(edge_cnt == 7 || bit_cnt == 1) begin
						else if(bit_cnt == 1) begin
						
							deser_en = 1'b1;

							start_chk_en = 1'b0;
							par_chk_en = 1'b0;
							stp_chk_en = 1'b0;
							temp_data_valid = 1'b0;

							next_st = data ;
						end
						else begin
							next_st = IDLE ;
						end
			        end

  			data  : begin
  						if(bit_cnt < 9 ) begin
							
							next_st = data ;
							
						end
						//else if(edge_cnt == 7 || bit_cnt == 9) begin
						else if(bit_cnt == 9) begin
			  			
			  					if(PAR_EN) begin
			  					//	par_chk_en = 1;
			  						par_chk_en = 0;
									deser_en = 1'b1;

			  					//	data_samp_en = 1'b0;  
									start_chk_en = 1'b0;
									stp_chk_en = 1'b0;
									temp_data_valid = 1'b0;
					  						
					  				next_st = parity ;
			  					end
			  						
              					else begin
			   					//	stp_chk_en = 1;
									par_chk_en = 1'b1;

			  					//	data_samp_en = 1'b0;  
									deser_en = 1'b0;
									start_chk_en = 1'b0;
									temp_data_valid = 1'b0;
	
              						next_st = stop ;
              					end
			   								  
			 				end
						else
			 				next_st = IDLE ; 			
           			end

			parity: begin
						if(bit_cnt < 4'ha ) begin
							
							next_st = parity ;
							
						end
						//else if (edge_cnt == 7 || bit_cnt == 10) begin
						else if (bit_cnt == 4'ha) begin
						//	stp_chk_en = 1;
						//	data_samp_en = 1'b1;  
							par_chk_en = 1'b1;
							
							deser_en = 1'b0;
							start_chk_en = 1'b0;
							temp_data_valid = 1'b0;

							next_st = stop ;
						
						end 
			        end

			stop  : begin
						if(bit_cnt < 4'hb ) begin
							
							next_st = stop ;

							
						end
						else
							stp_chk_en = 1;

							data_samp_en = 0 ;
							par_chk_en = 0;
							next_st = err_chk ; 			
			        end

			err_chk  : begin
						if (par_err || stp_err || start_glitch) begin
							next_st = IDLE ;
						end
						else begin
							next_st = data_vld;
						end
			        end

			data_vld  : begin
						temp_data_valid = 1;

						if(S_RX_IN)
							next_st = IDLE ;
						else
							next_st = start ;	 			
			        end

			default: begin
						next_st = IDLE ; 
			        end	
  		endcase                 	   
	end 

//register output 
always @ (posedge CLK or negedge RST) begin
  		if(!RST) begin
    		Data_Valid <= 1'b0 ;
   		end
  		else begin
    		Data_Valid <= temp_data_valid ;
   		end
end
  
endmodule : UART_RX_FSM