module UART_RX_Top #(parameter DATA_WIDTH = 8)(
	
	input   wire   						CLK_TX,
    input   wire                        CLK_RX,
    input   wire   						RST,
    input   wire   						PAR_TYP,
    input   wire   						PAR_EN,
    input   wire  [5:0] 				prescale,
    input 	wire   						S_RX_IN,

    //////////////////////others/////////////////////////
    /*input  wire							start_chk_en,
    input  wire							par_chk_en,
    input  wire							stp_chk_en,
    input  wire							edge_bit_count_en,
    input  wire							data_samp_en,
    input  wire							deser_en,

    output         [4:0] 				edge_cnt, // 0 : 31
    output         [3:0] 				bit_cnt,   // 0 : 10

    output	       						start_glitch,  // not define reg here (all signals are wires in top)
    output	       						par_err,
    output	       						stp_err,*/
    //////////////////////////////////////////
    output     							Data_Valid,
    output         [DATA_WIDTH-1 : 0]	P_DATA
);

    wire  [4:0] edge_cnt_wr;  // 0 : 31
    wire  [3:0] bit_cnt_wr;   // 0 : 10

    wire        start_glitch_wr,
	       	    sampled_bit_wr,
                sample_out_flag_wr,
                par_err_wr,
                stp_err_wr,

                start_chk_en_wr,
                par_chk_en_wr,
                stp_chk_en_wr,
                edge_bit_count_en_wr,
                data_samp_en_wr,
                deser_en_wr;

UART_RX_edge_bit_counter edge_bit_cnt(
.CLK              (CLK_RX),
.RST              (RST),
.prescale         (prescale),
.PAR_EN           (PAR_EN),
.edge_bit_count_en(edge_bit_count_en_wr),
.edge_cnt         (edge_cnt_wr),
.bit_cnt          (bit_cnt_wr)
);

UART_RX_Data_Sampling Data_samp(
.CLK            (CLK_RX),
.RST            (RST),
.prescale       (prescale),
.edge_cnt       (edge_cnt_wr),
.bit_cnt        (bit_cnt_wr),
.data_samp_en   (data_samp_en_wr),
.S_RX_IN        (S_RX_IN),
.sampled_bit    (sampled_bit_wr),
.sample_out_flag(sample_out_flag_wr)	
);

UART_RX_FSM FSM (
.CLK              (CLK_RX),
.RST              (RST),
.prescale         (prescale),
.edge_cnt         (edge_cnt_wr),
.S_RX_IN          (S_RX_IN),
.par_err          (par_err_wr),
.stp_err          (stp_err_wr),
.PAR_EN           (PAR_EN),
.bit_cnt          (bit_cnt_wr),
.start_glitch     (start_glitch_wr),
.par_chk_en       (par_chk_en_wr),
.start_chk_en     (start_chk_en_wr),
.stp_chk_en       (stp_chk_en_wr),
.data_samp_en     (data_samp_en_wr),
.edge_bit_count_en(edge_bit_count_en_wr),
.deser_en         (deser_en_wr),
.Data_Valid       (Data_Valid)
);

UART_RX_Parity_check parity_chk (
.CLK        (CLK_RX),
.RST        (RST),
.sampled_bit(sampled_bit_wr),
.PAR_TYP    (PAR_TYP),
.P_DATA     (P_DATA),
.par_chk_en (par_chk_en_wr),
.par_err    (par_err_wr)
);

UART_RX_Start_check start_chk (
.CLK         (CLK_RX),
.RST         (RST),
.sampled_bit (sampled_bit_wr),
.start_chk_en(start_chk_en_wr),
.start_err   (start_glitch_wr)
);

UART_RX_Stop_check stop_chk (
.CLK        (CLK_RX),
.RST        (RST),
.stp_chk_en (stp_chk_en_wr),
.sampled_bit(sampled_bit_wr),
.stp_err    (stp_err_wr)
);

UART_RX_deserializer # (.DATA_WIDTH(DATA_WIDTH)) Deser(
.CLK        (CLK_RX),
.RST        (RST),
.deser_en   (deser_en_wr),
.sampled_bit(sampled_bit_wr),
.sample_out_flag(sample_out_flag_wr),
.prescale   (prescale),
.edge_cnt   (edge_cnt_wr),
.P_DATA     (P_DATA)
);

endmodule : UART_RX_Top