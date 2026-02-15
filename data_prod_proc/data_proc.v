module data_proc (
    input  wire        clk,
    input  wire        rstn,

    input  wire [7:0]  pixel_in,
    input  wire        valid_in,
    output wire        ready,

    output reg  [7:0]  pixel_out,
    output reg         valid_out
);

    reg [1:0] mode;                 // 0x00
    reg [7:0] kernel [0:8];         // 0x04 (9 x 8-bit)
    reg       status;               // 0x10

    assign ready = 1'b1;  // always ready (simple design)

    integer i;

    

    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            mode   <= 2'b00;     // default BYPASS
            status <= 1'b0;

            for (i = 0; i < 9; i = i + 1)
                kernel[i] <= 8'd1;  // default kernel = all 1
        end
        else begin
            status <= valid_in;   // status = data activity
        end
    end

   

    reg [15:0] conv_sum;

    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            pixel_out <= 8'd0;
            valid_out <= 1'b0;
        end
        else begin
            valid_out <= valid_in;

            if (valid_in) begin
                case (mode)

                    2'b00: begin
                        // BYPASS
                        pixel_out <= pixel_in;
                    end

                    2'b01: begin
                        // INVERT
                        pixel_out <= ~pixel_in;
                    end

                    2'b10: begin
                        // SIMPLE CONVOLUTION
                        // Using only center kernel tap for simplicity
                        conv_sum = pixel_in * kernel[4];
                        pixel_out <= conv_sum[7:0];
                    end

                    2'b11: begin
                        // NOT IMPLEMENTED
                        pixel_out <= 8'd0;
                    end

                endcase
            end
        end
    end

endmodule

