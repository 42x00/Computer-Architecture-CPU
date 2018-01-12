`include "defines.v"

module id( 

	input wire							rst,
	input wire[`InstAddrBus]			pc_i,
	input wire[`InstBus]          		inst_i,

	//处于执行阶段的指令的一些信息，用于解决load相关
	input wire[`AluOpBus]				ex_aluop_i,
	
	//处于执行阶段的指令要写入的目的寄存器信息
	input wire							ex_wreg_i,
	input wire[`RegBus]					ex_wdata_i,
	input wire[`RegAddrBus]       		ex_wd_i,
	
	//处于访存阶段的指令要写入的目的寄存器信息
	input wire							mem_wreg_i,
	input wire[`RegBus]					mem_wdata_i,
	input wire[`RegAddrBus]       		mem_wd_i,
	
	input wire[`RegBus]           		reg1_data_i,
	input wire[`RegBus]           		reg2_data_i,
	
	//branch_prediction
	input wire 		     		  		pre_take_or_not,
    input wire		     		  		pre_sel,
	
	output reg							is_branch_o,
	output reg							take_or_not_o,
	output reg							pre_true_o,
	output wire							sel_o,
	output wire [`InstAddrBus] 			pc_o,		

	//送到regfile的信息
	output reg                    		reg1_read_o,
	output reg                    		reg2_read_o,     
	output reg[`RegAddrBus]       		reg1_addr_o,
	output reg[`RegAddrBus]       		reg2_addr_o, 	      
	
	//送到执行阶段的信息
	output reg[`AluOpBus]         		aluop_o,
	output reg[`AluSelBus]        		alusel_o,
	output reg[`RegBus]           		reg1_o,
	output reg[`RegBus]           		reg2_o,
	output reg[`RegAddrBus]       		wd_o,
	output reg                    		wreg_o,
	output wire[`RegBus]          		inst_o,
	
	output reg                    		branch_flag_o,
	output reg[`RegBus]           		branch_target_address_o,       
	output reg[`RegBus]           		link_addr_o,
	
	output reg                   		stallreq_branch,	
	output wire                  		stallreq_load	
);

	wire[`OpcodeBus] op = inst_i[6:0];
	wire[`Funct3Bus] funct3 = inst_i[14:12];
	wire[`Funct7Bus] funct7 = inst_i[31:25];
	
	reg[`RegBus]	 imm;
	reg instvalid;
	wire[`RegBus] pc_plus_4;
	
	reg stallreq_for_reg1_loadrelate;
	reg stallreq_for_reg2_loadrelate;
	wire pre_inst_is_load;
	
	assign pc_plus_4 = pc_i + 4;
	assign stallreq_load = stallreq_for_reg1_loadrelate | stallreq_for_reg2_loadrelate;
	assign pre_inst_is_load = ( (ex_aluop_i == `EXE_LB_OP) || 
  								(ex_aluop_i == `EXE_LBU_OP)||
  								(ex_aluop_i == `EXE_LH_OP) ||
  								(ex_aluop_i == `EXE_LHU_OP)||
  								(ex_aluop_i == `EXE_LW_OP) ) ? 1'b1 : 1'b0;

	assign inst_o = inst_i;
	
	assign sel_o = pre_sel;
	assign pc_o = pc_i;
  
	always @ (*) begin	
		if (rst == `RstEnable) begin
			aluop_o <= `EXE_NOP_OP;
			alusel_o <= `EXE_RES_NOP;
			wd_o <= `NOPRegAddr;
			wreg_o <= `WriteDisable;
			instvalid <= `InstValid;
			reg1_read_o <= 1'b0;
			reg2_read_o <= 1'b0;
			reg1_addr_o <= `NOPRegAddr;
			reg2_addr_o <= `NOPRegAddr;
			imm <= 32'h0;
			link_addr_o <= `ZeroWord;
			branch_target_address_o <= `ZeroWord;
			branch_flag_o <= `NotBranch;
			is_branch_o <= 1'b0;
			take_or_not_o <= 1'b0;
			pre_true_o <= 1'b0;
			stallreq_branch <= 1'b0;
		end else begin
			aluop_o <= `EXE_NOP_OP;
			alusel_o <= `EXE_RES_NOP;
			wd_o <= inst_i[11:7];	      //写入寄存器
			wreg_o <= `WriteDisable;
			instvalid <= `InstInvalid;	   
			reg1_read_o <= 1'b0;
			reg2_read_o <= 1'b0;
			reg1_addr_o <= inst_i[19:15]; //读寄存器1
			reg2_addr_o <= inst_i[24:20]; //读寄存器2
			imm <= `ZeroWord;
			link_addr_o <= `ZeroWord;
			branch_target_address_o <= `ZeroWord;
			branch_flag_o <= `NotBranch;	
			is_branch_o <= 1'b0;
			take_or_not_o <= 1'b0;
			pre_true_o <= 1'b0;
			stallreq_branch <= 1'b0;
			case (op)
				`OP_OP_IMM: begin
					case(funct3)
						`FUNCT3_ADDI: begin
							wreg_o <= `WriteEnable;		
							aluop_o <= `EXE_ADD_OP;
							alusel_o <= `EXE_RES_ARITHMETIC; 
							reg1_read_o <= 1'b1;	
							reg2_read_o <= 1'b0;	  	
							imm <= {{21{inst_i[31]}}, inst_i[30:20]};		
							instvalid <= `InstValid;
						end
						`FUNCT3_SLTI: begin
							wreg_o <= `WriteEnable;		
							aluop_o <= `EXE_SLT_OP;
							alusel_o <= `EXE_RES_ARITHMETIC; 
							reg1_read_o <= 1'b1;	
							reg2_read_o <= 1'b0;	  	
							imm <= {{21{inst_i[31]}}, inst_i[30:20]};		
							instvalid <= `InstValid;
						end
						`FUNCT3_SLTIU: begin
							wreg_o <= `WriteEnable;		
							aluop_o <= `EXE_SLTU_OP;
							alusel_o <= `EXE_RES_ARITHMETIC; 
							reg1_read_o <= 1'b1;	
							reg2_read_o <= 1'b0;	  	
							imm <= {{21{inst_i[31]}}, inst_i[30:20]};		
							instvalid <= `InstValid;
						end
						`FUNCT3_XORI: begin
							wreg_o <= `WriteEnable;		
							aluop_o <= `EXE_XOR_OP;
							alusel_o <= `EXE_RES_LOGIC;	
							reg1_read_o <= 1'b1;	
							reg2_read_o <= 1'b0;	  	
							imm <= {{21{inst_i[31]}}, inst_i[30:20]};	
							instvalid <= `InstValid;
						end
						`FUNCT3_ORI: begin
							wreg_o <= `WriteEnable;		
							aluop_o <= `EXE_OR_OP;
							alusel_o <= `EXE_RES_LOGIC; 
							reg1_read_o <= 1'b1;	
							reg2_read_o <= 1'b0;	  	
							imm <= {{21{inst_i[31]}}, inst_i[30:20]};	
							instvalid <= `InstValid;
						end
						`FUNCT3_ANDI: begin
							wreg_o <= `WriteEnable;		
							aluop_o <= `EXE_AND_OP;
							alusel_o <= `EXE_RES_LOGIC;	
							reg1_read_o <= 1'b1;	
							reg2_read_o <= 1'b0;	  	
							imm <= {{21{inst_i[31]}}, inst_i[30:20]};	
							instvalid <= `InstValid;
						end
						`FUNCT3_SLLI: begin
							wreg_o <= `WriteEnable;		
							aluop_o <= `EXE_SLL_OP;
							alusel_o <= `EXE_RES_SHIFT; 
							reg1_read_o <= 1'b1;	
							reg2_read_o <= 1'b0;	  	
							imm[4:0] <= inst_i[24:20];		 
							instvalid <= `InstValid;
						end
						`FUNCT3_SRLI_SRAI: begin
							if (funct7 == `FUNCT7_SRL) begin
								wreg_o <= `WriteEnable;		
								aluop_o <= `EXE_SRL_OP;
								alusel_o <= `EXE_RES_SHIFT; 
								reg1_read_o <= 1'b1;	
								reg2_read_o <= 1'b0;	  	
								imm[4:0] <= inst_i[24:20];		 
								instvalid <= `InstValid;
							end else begin
								wreg_o <= `WriteEnable;		
								aluop_o <= `EXE_SRA_OP;
								alusel_o <= `EXE_RES_SHIFT; 
								reg1_read_o <= 1'b1;	
								reg2_read_o <= 1'b0;	  	
								imm[4:0] <= inst_i[24:20];		 
								instvalid <= `InstValid;
							end
						end
						default:	begin
						end
					endcase
				end
				`OP_OP: begin
					case(funct3)
						`FUNCT3_ADD_SUB: begin
							if (funct7 == `FUNCT7_ADD) begin
								wreg_o <= `WriteEnable;		
								aluop_o <= `EXE_ADD_OP;
		  						alusel_o <= `EXE_RES_ARITHMETIC;		
								reg1_read_o <= 1'b1;	
								reg2_read_o <= 1'b1;
		  						instvalid <= `InstValid;	
							end else begin
								wreg_o <= `WriteEnable;		
								aluop_o <= `EXE_SUB_OP;
		  						alusel_o <= `EXE_RES_ARITHMETIC;		
								reg1_read_o <= 1'b1;	
								reg2_read_o <= 1'b1;
		  						instvalid <= `InstValid;	
							end
						end
						`FUNCT3_SLL: begin
							wreg_o <= `WriteEnable;		
							aluop_o <= `EXE_SLL_OP;
							alusel_o <= `EXE_RES_SHIFT; 
							reg1_read_o <= 1'b1;	
							reg2_read_o <= 1'b1;	 	 
							instvalid <= `InstValid;
						end
						`FUNCT3_SLT: begin
							wreg_o <= `WriteEnable;		
							aluop_o <= `EXE_SLT_OP;
		  					alusel_o <= `EXE_RES_ARITHMETIC;		
							reg1_read_o <= 1'b1;	
							reg2_read_o <= 1'b1;
		  					instvalid <= `InstValid;	
						end
						`FUNCT3_SLTU: begin
							wreg_o <= `WriteEnable;		
							aluop_o <= `EXE_SLTU_OP;
		  					alusel_o <= `EXE_RES_ARITHMETIC;		
							reg1_read_o <= 1'b1;	
							reg2_read_o <= 1'b1;
		  					instvalid <= `InstValid;	
						end
						`FUNCT3_XOR: begin
							wreg_o <= `WriteEnable;		
							aluop_o <= `EXE_XOR_OP;
		  					alusel_o <= `EXE_RES_LOGIC;		
							reg1_read_o <= 1'b1;	
							reg2_read_o <= 1'b1;	
		  					instvalid <= `InstValid;	
						end
						`FUNCT3_SRL_SRA: begin
							if (funct7 == `FUNCT7_SRL) begin
								wreg_o <= `WriteEnable;		
								aluop_o <= `EXE_SRL_OP;
								alusel_o <= `EXE_RES_SHIFT; 	
								reg1_read_o <= 1'b1;	
								reg2_read_o <= 1'b1;	
								instvalid <= `InstValid;
							end else begin
								wreg_o <= `WriteEnable;		
								aluop_o <= `EXE_SRA_OP;
								alusel_o <= `EXE_RES_SHIFT; 	
								reg1_read_o <= 1'b1;	
								reg2_read_o <= 1'b1;	
								instvalid <= `InstValid;
							end
						end
						`FUNCT3_OR: begin
							wreg_o <= `WriteEnable;		
							aluop_o <= `EXE_OR_OP;
		  					alusel_o <= `EXE_RES_LOGIC;		
							reg1_read_o <= 1'b1;	
							reg2_read_o <= 1'b1;	
		  					instvalid <= `InstValid;	
						end
						`FUNCT3_AND: begin
							wreg_o <= `WriteEnable;		
							aluop_o <= `EXE_AND_OP;
		  					alusel_o <= `EXE_RES_LOGIC;		
							reg1_read_o <= 1'b1;	
							reg2_read_o <= 1'b1;	
		  					instvalid <= `InstValid;	
						end
						default: begin
						end
					endcase
				end
				`OP_LUI: begin
					wreg_o <= `WriteEnable;		
					aluop_o <= `EXE_SLL_OP;
					alusel_o <= `EXE_RES_JUMP_BRANCH; 
					reg1_read_o <= 1'b0;	
					reg2_read_o <= 1'b0;
					link_addr_o <= {inst_i[31:12], {12{1'b0}}};
					instvalid <= `InstValid;	
				end
				`OP_AUIPC: begin
					wreg_o <= `WriteEnable;		
					aluop_o <= `EXE_ADD_OP;
					alusel_o <= `EXE_RES_JUMP_BRANCH; 
					reg1_read_o <= 1'b0;	
					reg2_read_o <= 1'b0;
					link_addr_o <= pc_i + {inst_i[31:12], {12{1'b0}}};
					instvalid <= `InstValid;	
				end
				`OP_JAL: begin
					wreg_o <= `WriteEnable;		
					aluop_o <= `EXE_JAL_OP;
					alusel_o <= `EXE_RES_JUMP_BRANCH; 
					reg1_read_o <= 1'b0;	
					reg2_read_o <= 1'b0;
					link_addr_o <= pc_plus_4;
					branch_target_address_o <= pc_i + {{12{inst_i[31]}}, inst_i[19:12], inst_i[20], inst_i[30:21],1'b0};
					branch_flag_o <= `Branch;	  	
					instvalid <= `InstValid;
					stallreq_branch <= 1'b1;
				end
				`OP_JALR: begin
					wreg_o <= `WriteEnable;		
					aluop_o <= `EXE_JALR_OP;
					alusel_o <= `EXE_RES_JUMP_BRANCH;   
					reg1_read_o <= 1'b1;	
					reg2_read_o <= 1'b0;
					link_addr_o <= pc_plus_4;
					branch_target_address_o <= reg1_o + {{21{inst_i[31]}}, inst_i[30:20]};
					branch_flag_o <= `Branch;
					instvalid <= `InstValid;	
					stallreq_branch <= 1'b1;
				end
				`OP_BRANCH: begin
					case(funct3)
						`FUNCT3_BEQ: begin
							wreg_o <= `WriteDisable;		
							aluop_o <= `EXE_BEQ_OP;
							alusel_o <= `EXE_RES_JUMP_BRANCH; 
							reg1_read_o <= 1'b1;	
							reg2_read_o <= 1'b1;
							instvalid <= `InstValid;	
							is_branch_o <= 1'b1;
							if(reg1_o == reg2_o) begin
								take_or_not_o <= 1'b1;
								if(pre_take_or_not == 1'b1)
									pre_true_o <= 1'b1;
								else begin
									pre_true_o <= 1'b0;
									branch_target_address_o <= pc_i + {{20{inst_i[31]}}, inst_i[7], inst_i[30:25], inst_i[11:8], 1'b0};
									branch_flag_o <= `Branch;	  
									stallreq_branch <= 1'b1;
								end
							end
						end
						`FUNCT3_BNE: begin
							wreg_o <= `WriteDisable;		
							aluop_o <= `EXE_BLEZ_OP;
							alusel_o <= `EXE_RES_JUMP_BRANCH; 
							reg1_read_o <= 1'b1;	
							reg2_read_o <= 1'b1;
							instvalid <= `InstValid;	
							is_branch_o <= 1'b1;
							if(reg1_o != reg2_o) begin
								take_or_not_o <= 1'b1;
								if(pre_take_or_not == 1'b1)
									pre_true_o <= 1'b1;
								else begin
									pre_true_o <= 1'b0;
									branch_target_address_o <= pc_i + {{20{inst_i[31]}}, inst_i[7], inst_i[30:25], inst_i[11:8], 1'b0};
									branch_flag_o <= `Branch;	  
									stallreq_branch <= 1'b1;
								end	  	
							end
						end
						`FUNCT3_BLT: begin
							wreg_o <= `WriteDisable;		
							aluop_o <= `EXE_BGEZAL_OP;
							alusel_o <= `EXE_RES_JUMP_BRANCH; 
							reg1_read_o <= 1'b1;	
							reg2_read_o <= 1'b1;
							instvalid <= `InstValid;	
							is_branch_o <= 1'b1;
							if($signed(reg1_o) < $signed(reg2_o)) begin
								take_or_not_o <= 1'b1;
								if(pre_take_or_not == 1'b1)
									pre_true_o <= 1'b1;
								else begin
									pre_true_o <= 1'b0;
									branch_target_address_o <= pc_i + {{20{inst_i[31]}}, inst_i[7], inst_i[30:25], inst_i[11:8], 1'b0};
									branch_flag_o <= `Branch;	  
									stallreq_branch <= 1'b1;
								end	
							end	
						end
						`FUNCT3_BGE: begin
							wreg_o <= `WriteDisable;		
							aluop_o <= `EXE_BGEZAL_OP;
							alusel_o <= `EXE_RES_JUMP_BRANCH; 
							reg1_read_o <= 1'b1;	
							reg2_read_o <= 1'b1;
							instvalid <= `InstValid;	
							is_branch_o <= 1'b1;
							if($signed(reg1_o) > $signed(reg2_o)) begin
								take_or_not_o <= 1'b1;
								if(pre_take_or_not == 1'b1)
									pre_true_o <= 1'b1;
								else begin
									pre_true_o <= 1'b0;
									branch_target_address_o <= pc_i + {{20{inst_i[31]}}, inst_i[7], inst_i[30:25], inst_i[11:8], 1'b0};
									branch_flag_o <= `Branch;	  
									stallreq_branch <= 1'b1;
								end  	
							end	
						end
						`FUNCT3_BLTU: begin
							wreg_o <= `WriteDisable;		
							aluop_o <= `EXE_BGEZAL_OP;
							alusel_o <= `EXE_RES_JUMP_BRANCH; 
							reg1_read_o <= 1'b1;	
							reg2_read_o <= 1'b1;
							instvalid <= `InstValid;
							is_branch_o <= 1'b1;
							if(reg1_o < reg2_o) begin
								take_or_not_o <= 1'b1;
								if(pre_take_or_not == 1'b1)
									pre_true_o <= 1'b1;
								else begin
									pre_true_o <= 1'b0;
									branch_target_address_o <= pc_i + {{20{inst_i[31]}}, inst_i[7], inst_i[30:25], inst_i[11:8], 1'b0};
									branch_flag_o <= `Branch;	  
									stallreq_branch <= 1'b1;
								end 	
							end	
						end
						`FUNCT3_BGEU: begin
							wreg_o <= `WriteDisable;		
							aluop_o <= `EXE_BGEZAL_OP;
							alusel_o <= `EXE_RES_JUMP_BRANCH; 
							reg1_read_o <= 1'b1;	
							reg2_read_o <= 1'b1;
							instvalid <= `InstValid;	
							is_branch_o <= 1'b1;
							if(reg1_o > reg2_o) begin
								take_or_not_o <= 1'b1;
								if(pre_take_or_not == 1'b1)
									pre_true_o <= 1'b1;
								else begin
									pre_true_o <= 1'b0;
									branch_target_address_o <= pc_i + {{20{inst_i[31]}}, inst_i[7], inst_i[30:25], inst_i[11:8], 1'b0};
									branch_flag_o <= `Branch;	  
									stallreq_branch <= 1'b1;
								end  	
							end	
						end
						default: begin
						end
					endcase
				end
				`OP_LOAD: begin
					case(funct3)
						`FUNCT3_LB: begin
							wreg_o <= `WriteEnable;		
							aluop_o <= `EXE_LB_OP;
							alusel_o <= `EXE_RES_LOAD_STORE; 
							reg1_read_o <= 1'b1;	
							reg2_read_o <= 1'b0;
							instvalid <= `InstValid;	
						end
						`FUNCT3_LH: begin
							wreg_o <= `WriteEnable;		
							aluop_o <= `EXE_LH_OP;
							alusel_o <= `EXE_RES_LOAD_STORE; 
							reg1_read_o <= 1'b1;	
							reg2_read_o <= 1'b0;
							instvalid <= `InstValid;	
						end
						`FUNCT3_LW: begin
							wreg_o <= `WriteEnable;		
							aluop_o <= `EXE_LW_OP;
							alusel_o <= `EXE_RES_LOAD_STORE; 
							reg1_read_o <= 1'b1;	
							reg2_read_o <= 1'b0;
							instvalid <= `InstValid;	
						end
						`FUNCT3_LBU: begin
							wreg_o <= `WriteEnable;		
							aluop_o <= `EXE_LBU_OP;
							alusel_o <= `EXE_RES_LOAD_STORE; 
							reg1_read_o <= 1'b1;	
							reg2_read_o <= 1'b0;
							instvalid <= `InstValid;	
						end
						`FUNCT3_LHU: begin
							wreg_o <= `WriteEnable;		
							aluop_o <= `EXE_LHU_OP;
							alusel_o <= `EXE_RES_LOAD_STORE; 
							reg1_read_o <= 1'b1;	
							reg2_read_o <= 1'b0;
							instvalid <= `InstValid;	
						end
						default: begin
						end
					endcase
				end
				`OP_STORE: begin
					case(funct3)
						`FUNCT3_SB: begin
							wreg_o <= `WriteDisable;		
							aluop_o <= `EXE_SB_OP;
							alusel_o <= `EXE_RES_LOAD_STORE; 
							reg1_read_o <= 1'b1;	
							reg2_read_o <= 1'b1; 
							instvalid <= `InstValid;	
						end
						`FUNCT3_SH: begin
							wreg_o <= `WriteDisable;		
							aluop_o <= `EXE_SH_OP;
							alusel_o <= `EXE_RES_LOAD_STORE; 
							reg1_read_o <= 1'b1;	
							reg2_read_o <= 1'b1; 
							instvalid <= `InstValid;	
						end
						`FUNCT3_SW: begin
							wreg_o <= `WriteDisable;		
							aluop_o <= `EXE_SW_OP;
							alusel_o <= `EXE_RES_LOAD_STORE; 
							reg1_read_o <= 1'b1;	
							reg2_read_o <= 1'b1; 
							instvalid <= `InstValid;	
						end
						default: begin
						end
					endcase
				end
				default: begin
				end
			endcase
			
		  
		end       //if
	end         //always
	

	always @ (*) begin
		stallreq_for_reg1_loadrelate <= `NoStop;	
		if(rst == `RstEnable) begin
			reg1_o <= `ZeroWord;	
		end else if(pre_inst_is_load == 1'b1 && ex_wd_i == reg1_addr_o 
								&& reg1_read_o == 1'b1 ) begin
			stallreq_for_reg1_loadrelate <= `Stop;							
		end else if((reg1_read_o == 1'b1) && (ex_wreg_i == 1'b1) 
								&& (ex_wd_i == reg1_addr_o)) begin
			reg1_o <= ex_wdata_i; 
		end else if((reg1_read_o == 1'b1) && (mem_wreg_i == 1'b1) 
								&& (mem_wd_i == reg1_addr_o)) begin
			reg1_o <= mem_wdata_i; 			
	  end else if(reg1_read_o == 1'b1) begin
			reg1_o <= reg1_data_i;
	  end else if(reg1_read_o == 1'b0) begin
			reg1_o <= imm;
	  end else begin
			reg1_o <= `ZeroWord;
	  end
	end
	
	always @ (*) begin
		stallreq_for_reg2_loadrelate <= `NoStop;
		if(rst == `RstEnable) begin
			reg2_o <= `ZeroWord;
		end else if(pre_inst_is_load == 1'b1 && ex_wd_i == reg2_addr_o 
								&& reg2_read_o == 1'b1 ) begin
			stallreq_for_reg2_loadrelate <= `Stop;			
		end else if((reg2_read_o == 1'b1) && (ex_wreg_i == 1'b1) 
								&& (ex_wd_i == reg2_addr_o)) begin
			reg2_o <= ex_wdata_i; 
		end else if((reg2_read_o == 1'b1) && (mem_wreg_i == 1'b1) 
								&& (mem_wd_i == reg2_addr_o)) begin
			reg2_o <= mem_wdata_i;			
	  end else if(reg2_read_o == 1'b1) begin
			reg2_o <= reg2_data_i;
	  end else if(reg2_read_o == 1'b0) begin
			reg2_o <= imm;
	  end else begin
			reg2_o <= `ZeroWord;
	  end
	end

endmodule