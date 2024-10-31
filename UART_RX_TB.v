
module UART_RX_TB ();

    parameter DATA_WIDTH_TB = 8;
    parameter CLK_PERIOD_RX = 10 ;     // 200 MHz
    parameter CLK_PERIOD_TX = CLK_PERIOD_RX * 8 ;     // 200 MHz

    reg                         CLK_TX_TB;
    reg                         CLK_RX_TB;
    reg                         RST_TB;
    reg                         PAR_TYP_TB;
    reg                         PAR_EN_TB;
    reg   [5:0]                 prescale_TB;
    reg                         S_RX_IN_TB;

    //////////////////////others/////////////////////////
   /* reg                         start_chk_en_TB;
    reg                         par_chk_en_TB;
    reg                         stp_chk_en_TB;
    reg                         edge_bit_count_en_TB;
    reg                         data_samp_en_TB;
    reg                         deser_en_TB;

    wire   [4:0]                edge_cnt_TB; // 0 : 31
    wire   [3:0]                bit_cnt_TB;   // 0 : 10

    wire                        start_glitch_TB;
    wire                        par_err_TB;
    wire                        stp_err_TB;*/
    //////////////////////////////////////////
    wire                        Data_Valid_TB;
    wire   [DATA_WIDTH_TB-1 : 0]   P_DATA_TB;

UART_RX_Top #(.DATA_WIDTH(DATA_WIDTH_TB)) DUT(
.CLK_TX           (CLK_TX_TB),
.CLK_RX           (CLK_RX_TB),
.RST              (RST_TB),
.PAR_TYP          (PAR_TYP_TB),
.S_RX_IN          (S_RX_IN_TB),
.PAR_EN           (PAR_EN_TB),
.prescale         (prescale_TB),
.P_DATA           (P_DATA_TB),
.Data_Valid       (Data_Valid_TB)
);


// Clock Generator 
always #(CLK_PERIOD_TX/2) CLK_TX_TB = ~CLK_TX_TB ;
always #(CLK_PERIOD_RX/2) CLK_RX_TB = ~CLK_RX_TB ;

// initial block 

initial
    begin

    // Initialize inputs
    CLK_TX_TB   = 0;
    CLK_RX_TB   = 0;
    RST_TB      = 0;
    S_RX_IN_TB  = 1;
    PAR_EN_TB   = 1;
    PAR_TYP_TB  = 0;
    prescale_TB = 4'd8;

    // deassert reset
    #(CLK_PERIOD_TX)    RST_TB = 1;
                        S_RX_IN_TB  = 0;
        
    // Send a byte (e.g., 0xA5 = 10100101)
                        
    #(CLK_PERIOD_TX)    S_RX_IN_TB = 1; // MSB        
    #(CLK_PERIOD_TX)    S_RX_IN_TB = 0;
    #(CLK_PERIOD_TX)    S_RX_IN_TB = 1;
    #(CLK_PERIOD_TX)    S_RX_IN_TB = 0;
    #(CLK_PERIOD_TX)    S_RX_IN_TB = 0;
    #(CLK_PERIOD_TX)    S_RX_IN_TB = 1;
    #(CLK_PERIOD_TX)    S_RX_IN_TB = 0;
    #(CLK_PERIOD_TX)    S_RX_IN_TB = 1; // LSB
    
    if (PAR_EN_TB && PAR_TYP_TB)
        #(CLK_PERIOD_TX)   S_RX_IN_TB = 1;
    else
        #(CLK_PERIOD_TX)   S_RX_IN_TB = 0;

    #(CLK_PERIOD_TX)   S_RX_IN_TB = 1;

    // Wait for the output to become valid
    #100;
    if (Data_Valid_TB) begin
        $display("Received parallel output: %b", P_DATA_TB);
    end else begin
        $display("Output not valid yet.");
    end

    // Finish simulation
    #200;
    $stop;
    end

endmodule : UART_RX_TB
