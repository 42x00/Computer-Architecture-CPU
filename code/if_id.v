`include "defines.v"

module if_id(

	input wire clk,
	input wire rst,

	//来自控制模块的信息
	/////////////////////////// stall
	input wire[5:0]               stall,	
	
	input wire[`InstAddrBus]	  if_pc,
	input wire[`InstBus]          if_inst,
	
	input wire 		     		  pre_take_or_not_i,
    input wire		     		  pre_sel_i,
	
	output reg 		     		  pre_take_or_not_o,
    output reg		     		  pre_sel_o,
	
	output reg[`InstAddrBus]      id_pc,
	output reg[`InstBus]          id_inst  
	
);

	always @ (posedge clk) begin
		if (rst == `RstEnable) begin
			id_pc <= `ZeroWord;
			id_inst <= `ZeroWord;
			pre_take_or_not_o <= 1'b0;
			pre_sel_o <= 1'b0;
			/////////////////////////// stall
		end else if(stall[1] == `Stop && stall[2] == `NoStop) begin
			id_pc <= `ZeroWord;
			id_inst <= `ZeroWord;	
			pre_take_or_not_o <= 1'b0;
			pre_sel_o <= 1'b0;
		end else if(stall[1] == `NoStop) begin
			id_pc <= if_pc;
			id_inst <= if_inst;
			pre_take_or_not_o <= pre_take_or_not_i;
			pre_sel_o <= pre_sel_i;
		end
	end

endmodule