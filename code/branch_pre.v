`include "defines.v"

module branch_pre(
	input wire							rst,
	
	//from if
	input wire [`InstAddrBus] 			pc_i,
	input wire [`InstBus]				inst_i,
	
	//from id
	input wire							id_is_branch,
	input wire							id_take_or_not,
	input wire							id_pre_true,
	input wire							id_sel,
	input wire [`InstAddrBus] 			id_pc,											
	
	//to pc_reg
	output reg                    		pre_branch_flag_o,
	output reg[`RegBus]           		pre_branch_target_address_o,
	
	//to id
	output reg							pre_take_or_not,
	output reg							pre_sel
		
);

	reg [0:9] 		     				overall_addr_rec[0:4095];
	reg [1:0]							overall_pre[0:1023];
	
	reg [11:0] 		     				global_rec;
	reg [1:0] 		     				global_pre[0:4095];
	
	reg [0:9] 		    			 	local_addr_rec[0:1023];
	reg [1:0]							local_pre[0:1023];
	
	
	integer i;
	always @ (*)
	begin
		if (rst == `RstEnable) 
		begin
			for(i = 0; i < 4096; i = i + 1)
				overall_addr_rec[i] <= 10'b0;
			for(i = 0; i < 1024; i = i + 1)
				overall_pre[i] <= 2'b0;	
			for(i = 0; i < 4096; i = i + 1)
				global_pre[i] <= 2'b0;
			for(i = 0; i < 1024; i = i + 1)
				local_addr_rec[i] <= 10'b0;
			for(i = 0; i < 1024; i = i + 1)
				local_pre[i] <= 2'b0;
			global_rec <= 12'b0;
			pre_branch_flag_o <= `NotBranch;
			pre_branch_target_address_o <= `ZeroWord;
			pre_take_or_not <= 1'b0;
			pre_sel <= 1'b0;
		end
		else if (inst_i[6:0] == `OP_BRANCH) 
		begin
			pre_branch_flag_o <= 1'b1;
			if (overall_pre[overall_addr_rec[pc_i[13:2]]][1] == 0)
			begin
				pre_sel <= 1'b0;
				if (local_pre[local_addr_rec[pc_i[11:2]]][1] == 0)
				begin
					pre_take_or_not <= 1'b0;
					pre_branch_target_address_o <= pc_i + 4;
				end
				else begin
					pre_take_or_not <= 1'b1;
					pre_branch_target_address_o <= pc_i + {{20{inst_i[31]}}, inst_i[7], inst_i[30:25], inst_i[11:8], 1'b0};
				end
			end
			else begin
				pre_sel <= 1'b1;
				if (global_pre[global_rec][1] == 0)
				begin
					pre_take_or_not <= 1'b0;
					pre_branch_target_address_o <= pc_i + 4;
				end
				else begin
					pre_take_or_not <= 1'b1;
					pre_branch_target_address_o <= pc_i + {{20{inst_i[31]}}, inst_i[7], inst_i[30:25], inst_i[11:8], 1'b0};
				end
			end
		end
		else pre_branch_flag_o <= 1'b0;
	end
	
	always @ (id_is_branch == 1'b1)
	begin
		if (id_pre_true == 1'b1)
		begin
			if (id_sel == 1'b0)
			begin
				if (local_pre[local_addr_rec[id_pc[11:2]]] < 3)
					local_pre[local_addr_rec[id_pc[11:2]]] <= local_pre[local_addr_rec[id_pc[11:2]]] + 1;
			end
			else 
			begin
				if (global_pre[global_rec] < 3)
					global_pre[global_rec] <= global_pre[global_rec] + 1;
			end
		end
		else begin
			if (id_sel == 1'b0)
			begin
				if (local_pre[local_addr_rec[id_pc[11:2]]] > 0)
					local_pre[local_addr_rec[id_pc[11:2]]] <= local_pre[local_addr_rec[id_pc[11:2]]] - 1;
			end
			else 
			begin
				if (global_pre[global_rec] > 0)
				if (global_pre[global_rec] > 0)
					global_pre[global_rec] <= global_pre[global_rec] - 1;
			end
		end
		global_rec <= (global_rec << 1 | id_take_or_not);
		
	end

endmodule