module UART_RX_deserializer #(parameter DATA_WIDTH = 8)(
    
    input   wire                     CLK,
    input   wire                     RST,   
    input   wire                     deser_en,
    input   wire  [5:0]              prescale,
    input   wire  [4:0]              edge_cnt, // 0 : 31
    input   wire                     sampled_bit,
    input   wire                     sample_out_flag,

    output  reg   [DATA_WIDTH-1 : 0] P_DATA
);

    reg [2:0] bit_count; // Counter to keep track of received bits
    reg [7:0] shift_reg; // Shift register to store the incoming bits

    always @(posedge CLK or negedge RST) begin
        if (!RST) begin
            // Reset all registers
            bit_count <= 3'b0;
            shift_reg <= 8'b0;
            P_DATA    <= 1'b0;

        end 
        else if (deser_en) begin

            if (edge_cnt == prescale-2 && sample_out_flag) begin // majority //*

            // Shift in the serial data
            shift_reg <= {shift_reg[6:0], sampled_bit};
            //@(negedge CLK) bit_count <= bit_count + 1'b1;
            bit_count <= bit_count + 1'b1;

                if (bit_count == 3'b111) begin
                    @(negedge CLK) P_DATA <= shift_reg;
                    bit_count <= 1'b0;  // Reset bit count for next byte
                end

            end

            //shift_reg <= {shift_reg[6:0], sampled_bit};

 
            // When 8 bits have been received, output the parallel data
            /*if (bit_count == 3'b111) begin
                P_DATA <= shift_reg;
                bit_count <= 1'b0;  // Reset bit count for next byte
            end*/
        end
    end

endmodule 
