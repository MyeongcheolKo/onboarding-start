`default_nettype none

module spi_module(
    input wire COPI,
    input wire nCS,
    input wire SCLK,
    input wire clk,
    input wire rst_n,
    output reg [7:0] en_reg_out_7_0,
    output reg [7:0] en_reg_out_15_8,
    output reg [7:0] en_reg_pwm_7_0,
    output reg [7:0] en_reg_pwm_15_8,
    output reg [7:0] pwm_duty_cycle
);
    reg sclk_ff1, sclk_ff2, nCS_ff1, nCS_ff2, COPI_ff1, COPI_ff2;
    reg prev_sclk, prev_nCS;
    reg [15:0] received_data;
    reg [4:0] data_counter;
    reg transaction_start;

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            sclk_ff1 <= 0;
            sclk_ff2 <= 0;
            nCS_ff1 <= 0;
            nCS_ff2 <= 0;
            COPI_ff1 <= 0;
            COPI_ff2 <= 0;
            prev_sclk <= 0;
            prev_nCS <= 0;
            transaction_start <= 0;
            en_reg_out_7_0 <= 0;
            en_reg_out_15_8 <= 0;
            en_reg_pwm_7_0 <= 0;
            en_reg_pwm_15_8 <= 0;
            pwm_duty_cycle <= 0;

        end else begin
            // synchronize SCLK, COPI, nCS
            sclk_ff1 <= SCLK;
            nCS_ff1 <= nCS;
            COPI_ff1 <= COPI;
            sclk_ff2 <= sclk_ff1;
            nCS_ff2 <= nCS_ff1;
            COPI_ff2 <= COPI_ff1;

            // store previous values for edge detection
            prev_sclk <= sclk_ff2;
            prev_nCS <= nCS_ff2;

            if(prev_nCS == 1 && nCS_ff2 == 0) begin     // nCS falling edge, transaction start
                transaction_start <= 1'b1;
                data_counter <= 0;
                received_data <= 0;
            end else if(prev_nCS == 0 && nCS_ff2 == 1) begin    // nCS rising edge, transaction complete
                transaction_start <= 0;
                if(data_counter == 16 && received_data[15] == 1'b1) begin     // write mode
                    case (received_data[14:8])      // 7 bit address
                        7'h00:
                            en_reg_out_7_0 <= received_data[7:0];
                        7'h01:
                            en_reg_out_15_8 <= received_data[7:0];
                        7'h02:
                            en_reg_pwm_7_0 <= received_data[7:0];
                        7'h03:
                            en_reg_pwm_15_8 <= received_data[7:0];
                        7'h04:
                            pwm_duty_cycle <= received_data[7:0];
                        default: ; // other adresses are ignored
                    endcase
                end
            end

            if(transaction_start && sclk_ff2 == 1 && prev_sclk == 0) begin       // SCLK rising edge, read data
                received_data <= {received_data[14:0], COPI_ff2};
                data_counter <= data_counter + 1; 
            end

            
        end
    end

endmodule
