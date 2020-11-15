`timescale 1ns / 1ps

module hamming(
    input           clk,
    input           reset,
    input   [15:0]  in,
    output  [15:0]  out,
    input           on
    );

    logic   [15:0]  shift_reg[512] = {16'd1311, 16'd1311, 16'd1313, 16'd1316, 16'd1320, 16'd1325, 16'd1331, 16'd1339, 16'd1347, 16'd1357, 16'd1368, 16'd1380, 16'd1393, 16'd1407, 16'd1422, 16'd1439, 16'd1456, 16'd1475, 16'd1495, 16'd1515, 16'd1537, 16'd1561, 16'd1585, 16'd1610, 16'd1637, 16'd1664, 16'd1693, 16'd1722, 16'd1753, 16'd1785, 16'd1818, 16'd1852, 16'd1887, 16'd1923, 16'd1960, 16'd1998, 16'd2037, 16'd2077, 16'd2119, 16'd2161, 16'd2204, 16'd2248, 16'd2294, 16'd2340, 16'd2387, 16'd2435, 16'd2484, 16'd2535, 16'd2586, 16'd2638, 16'd2691, 16'd2745, 16'd2799, 16'd2855, 16'd2912, 16'd2969, 16'd3028, 16'd3087, 16'd3147, 16'd3208, 16'd3270, 16'd3333, 16'd3397, 16'd3461, 16'd3526, 16'd3592, 16'd3659, 16'd3727, 16'd3795, 16'd3864, 16'd3934, 16'd4005, 16'd4076, 16'd4148, 16'd4221, 16'd4295, 16'd4369, 16'd4444, 16'd4519, 16'd4595, 16'd4672, 16'd4750, 16'd4828, 16'd4907, 16'd4986, 16'd5066, 16'd5146, 16'd5227, 16'd5309, 16'd5391, 16'd5473, 16'd5556, 16'd5640, 16'd5724, 16'd5809, 16'd5894, 16'd5979, 16'd6065, 16'd6152, 16'd6238, 16'd6325, 16'd6413, 16'd6501, 16'd6589, 16'd6678, 16'd6767, 16'd6856, 16'd6945, 16'd7035, 16'd7125, 16'd7216, 16'd7306, 16'd7397, 16'd7488, 16'd7579, 16'd7671, 16'd7762, 16'd7854, 16'd7946, 16'd8038, 16'd8130, 16'd8223, 16'd8315, 16'd8407, 16'd8500, 16'd8593, 16'd8685, 16'd8778, 16'd8871, 16'd8963, 16'd9056, 16'd9148, 16'd9241, 16'd9334, 16'd9426, 16'd9518, 16'd9611, 16'd9703, 16'd9795, 16'd9887, 16'd9978, 16'd10070, 16'd10161, 16'd10252, 16'd10343, 16'd10434, 16'd10524, 16'd10615, 16'd10705, 16'd10794, 16'd10884, 16'd10973, 16'd11061, 16'd11150, 16'd11238, 16'd11326, 16'd11413, 16'd11500, 16'd11586, 16'd11673, 16'd11758, 16'd11843, 16'd11928, 16'd12013, 16'd12096, 16'd12180, 16'd12263, 16'd12345, 16'd12427, 16'd12508, 16'd12589, 16'd12669, 16'd12749, 16'd12828, 16'd12906, 16'd12984, 16'd13061, 16'd13137, 16'd13213, 16'd13289, 16'd13363, 16'd13437, 16'd13510, 16'd13583, 16'd13654, 16'd13725, 16'd13796, 16'd13865, 16'd13934, 16'd14002, 16'd14069, 16'd14135, 16'd14201, 16'd14266, 16'd14330, 16'd14393, 16'd14455, 16'd14517, 16'd14578, 16'd14637, 16'd14696, 16'd14754, 16'd14811, 16'd14867, 16'd14923, 16'd14977, 16'd15031, 16'd15083, 16'd15135, 16'd15185, 16'd15235, 16'd15284, 16'd15331, 16'd15378, 16'd15424, 16'd15469, 16'd15512, 16'd15555, 16'd15597, 16'd15638, 16'd15677, 16'd15716, 16'd15754, 16'd15790, 16'd15826, 16'd15860, 16'd15894, 16'd15926, 16'd15957, 16'd15987, 16'd16017, 16'd16045, 16'd16072, 16'd16097, 16'd16122, 16'd16146, 16'd16168, 16'd16190, 16'd16210, 16'd16229, 16'd16248, 16'd16265, 16'd16280, 16'd16295, 16'd16309, 16'd16321, 16'd16333, 16'd16343, 16'd16352, 16'd16360, 16'd16367, 16'd16372, 16'd16377, 16'd16380, 16'd16383, 16'd16384, 16'd16384, 16'd16383, 16'd16380, 16'd16377, 16'd16372, 16'd16367, 16'd16360, 16'd16352, 16'd16343, 16'd16333, 16'd16321, 16'd16309, 16'd16295, 16'd16280, 16'd16265, 16'd16248, 16'd16229, 16'd16210, 16'd16190, 16'd16168, 16'd16146, 16'd16122, 16'd16097, 16'd16072, 16'd16045, 16'd16017, 16'd15987, 16'd15957, 16'd15926, 16'd15894, 16'd15860, 16'd15826, 16'd15790, 16'd15754, 16'd15716, 16'd15677, 16'd15638, 16'd15597, 16'd15555, 16'd15512, 16'd15469, 16'd15424, 16'd15378, 16'd15331, 16'd15284, 16'd15235, 16'd15185, 16'd15135, 16'd15083, 16'd15031, 16'd14977, 16'd14923, 16'd14867, 16'd14811, 16'd14754, 16'd14696, 16'd14637, 16'd14578, 16'd14517, 16'd14455, 16'd14393, 16'd14330, 16'd14266, 16'd14201, 16'd14135, 16'd14069, 16'd14002, 16'd13934, 16'd13865, 16'd13796, 16'd13725, 16'd13654, 16'd13583, 16'd13510, 16'd13437, 16'd13363, 16'd13289, 16'd13213, 16'd13137, 16'd13061, 16'd12984, 16'd12906, 16'd12828, 16'd12749, 16'd12669, 16'd12589, 16'd12508, 16'd12427, 16'd12345, 16'd12263, 16'd12180, 16'd12096, 16'd12013, 16'd11928, 16'd11843, 16'd11758, 16'd11673, 16'd11586, 16'd11500, 16'd11413, 16'd11326, 16'd11238, 16'd11150, 16'd11061, 16'd10973, 16'd10884, 16'd10794, 16'd10705, 16'd10615, 16'd10524, 16'd10434, 16'd10343, 16'd10252, 16'd10161, 16'd10070, 16'd9978, 16'd9887, 16'd9795, 16'd9703, 16'd9611, 16'd9518, 16'd9426, 16'd9334, 16'd9241, 16'd9148, 16'd9056, 16'd8963, 16'd8871, 16'd8778, 16'd8685, 16'd8593, 16'd8500, 16'd8407, 16'd8315, 16'd8223, 16'd8130, 16'd8038, 16'd7946, 16'd7854, 16'd7762, 16'd7671, 16'd7579, 16'd7488, 16'd7397, 16'd7306, 16'd7216, 16'd7125, 16'd7035, 16'd6945, 16'd6856, 16'd6767, 16'd6678, 16'd6589, 16'd6501, 16'd6413, 16'd6325, 16'd6238, 16'd6152, 16'd6065, 16'd5979, 16'd5894, 16'd5809, 16'd5724, 16'd5640, 16'd5556, 16'd5473, 16'd5391, 16'd5309, 16'd5227, 16'd5146, 16'd5066, 16'd4986, 16'd4907, 16'd4828, 16'd4750, 16'd4672, 16'd4595, 16'd4519, 16'd4444, 16'd4369, 16'd4295, 16'd4221, 16'd4148, 16'd4076, 16'd4005, 16'd3934, 16'd3864, 16'd3795, 16'd3727, 16'd3659, 16'd3592, 16'd3526, 16'd3461, 16'd3397, 16'd3333, 16'd3270, 16'd3208, 16'd3147, 16'd3087, 16'd3028, 16'd2969, 16'd2912, 16'd2855, 16'd2799, 16'd2745, 16'd2691, 16'd2638, 16'd2586, 16'd2535, 16'd2484, 16'd2435, 16'd2387, 16'd2340, 16'd2294, 16'd2248, 16'd2204, 16'd2161, 16'd2119, 16'd2077, 16'd2037, 16'd1998, 16'd1960, 16'd1923, 16'd1887, 16'd1852, 16'd1818, 16'd1785, 16'd1753, 16'd1722, 16'd1693, 16'd1664, 16'd1637, 16'd1610, 16'd1585, 16'd1561, 16'd1537, 16'd1515, 16'd1495, 16'd1475, 16'd1456, 16'd1439, 16'd1422, 16'd1407, 16'd1393, 16'd1380, 16'd1368, 16'd1357, 16'd1347, 16'd1339, 16'd1331, 16'd1325, 16'd1320, 16'd1316, 16'd1313, 16'd1311, 16'd1311};
    logic [30:0] result;
    
    assign result = $signed(shift_reg[0])*$signed(in);
    assign out = result>>14;
    
    
    always_ff @(posedge clk) begin
            if(on) begin
                shift_reg[0] <= shift_reg[255];
                shift_reg[1:255] <= shift_reg[0:254];
            end
    end
endmodule