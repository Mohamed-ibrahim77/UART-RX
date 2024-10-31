vlib work

vlog -f source_file.txt

vsim -voptargs=+acc work.UART_RX_TB

add wave *

add wave -position insertpoint sim:/UART_RX_TB/DUT/FSM/*

add wave -position insertpoint  \
sim:/UART_RX_TB/DUT/Data_samp/sampled_bit \
sim:/UART_RX_TB/DUT/Data_samp/sample_out_flag \
sim:/UART_RX_TB/DUT/Data_samp/over_sampled_bit_1 \
sim:/UART_RX_TB/DUT/Data_samp/over_sampled_bit_2 \
sim:/UART_RX_TB/DUT/Data_samp/over_sampled_bit_3 \
sim:/UART_RX_TB/DUT/Data_samp/majority_sampled_bit

add wave -position insertpoint  \
sim:/UART_RX_TB/DUT/parity_chk/recieved_par \
sim:/UART_RX_TB/DUT/parity_chk/calculated_par

add wave -position insertpoint  \
sim:/UART_RX_TB/DUT/Deser/bit_count \
sim:/UART_RX_TB/DUT/Deser/shift_reg

#add wave -position insertpoint sim:/UART_RX_TB/DUT/Data_samp/*

#add wave -position insertpoint sim:/UART_RX_TB/DUT/parity_chk/*

#add wave -position insertpoint sim:/UART_RX_TB/DUT/stop_chk/*

#add wave -position insertpoint sim:/UART_RX_TB/DUT/edge_bit_cnt/*

#add wave -position insertpoint sim:/UART_RX_TB/DUT/Deser/*

#log -r D:/SW\ &\ EDA\ Tools/programming/Sublime\ Text\ (4152)/Sublime\ Projects/Digital\ IC\ Design\ &\ ASIC\ Diploma/Final_System/2)\ UART_RX/transcript.log
run -all