module fusion_unit (
    input clk,
    input [3:0] in,
    input [3:0] weight,
    input [2:0] in_width,
    input [2:0] weight_width,
    input s_in,
    input s_weight,
    output reg [7:0] psum_fwd
    );

    reg [3:0] in_reg;
    reg [3:0] weight_reg;
    reg [2:0] in_width_reg;
    reg [2:0] weight_width_reg;
    reg s_in_reg;
    reg s_weight_reg;

    wire [2:0] shift0;
    wire [2:0] shift1;
    wire [2:0] shift2;
    wire [2:0] shift3;


    wire [9:0] prod0;
    wire [9:0] prod1;
    wire [9:0] prod2;
    wire [9:0] prod3;

    wire [1:0] weight_signed, in_signed;

    always @(posedge clk) begin
        in_reg <= in;
        weight_reg <= weight;
        in_width_reg <= in_width;
        weight_width_reg <= weight_width;
        s_in_reg <= s_in;
        s_weight_reg <= s_weight;
        psum_fwd <= prod0 + prod1 + prod2 + prod3;;
    end

    assign weight_signed = (weight_width_reg == 3'b100) ? 2'b10 : 2'b11;
    assign in_signed = (in_width_reg == 3'b100) ? 2'b10 : 2'b11;

    shift_lookup sl(
        .in_width(in_width_reg),
        .weight_width(weight_width_reg),
        .row0({shift1, shift0}),
        .row1({shift3, shift2})
    );

    bitbrick bb0(
        .x(in_reg[1:0]),
        .s_x(s_in_reg & in_signed[0]),
        .y(weight_reg[1:0]),
        .s_y(s_weight_reg & weight_signed[0]),
        .shift(shift0),
        .prod(prod0)
    );

    bitbrick bb1(
        .x(in_reg[1:0]),
        .s_x(s_in_reg & in_signed[0]),
        .y(weight_reg[3:2]),
        .s_y(s_weight_reg & weight_signed[1]),
        .shift(shift1),
        .prod(prod1)
    );

    bitbrick bb2(
        .x(in_reg[3:2]),
        .s_x(s_i_reg & in_signed[1]),
        .y(weight_reg[1:0]),
        .s_y(s_weight_reg & weight_signed[0]),
        .shift(shift2),
        .prod(prod2)
    );
        
    bitbrick bb3(
        .x(in_reg[3:2]),
        .s_x(s_in_reg & in_signed[1]),
        .y(weight_reg[3:2]),
        .s_y(s_weight_reg & weight_signed[1]),
        .shift(shift3),
        .prod(prod3)
    );

endmodule

    