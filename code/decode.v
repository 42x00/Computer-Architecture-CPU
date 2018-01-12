case (op)
	`EXE_SPECIAL_INST:	begin
					case (op2)
						5'b00000:	begin
		    			case (op3)
		    				`EXE_OR:	begin
								wreg_o <= `WriteEnable;		
								aluop_o <= `EXE_OR_OP;
								alusel_o <= `EXE_RES_LOGIC; 	
								reg1_read_o <= 1'b1;	
								reg2_read_o <= 1'b1;
								instvalid <= `InstValid;	
							end  
		    				`EXE_AND:	begin
		    					wreg_o <= `WriteEnable;		
								aluop_o <= `EXE_AND_OP;
		  						alusel_o <= `EXE_RES_LOGIC;	  
								reg1_read_o <= 1'b1;	
								reg2_read_o <= 1'b1;	
		  						instvalid <= `InstValid;	
							end  	
		    				`EXE_XOR:	begin
		    					wreg_o <= `WriteEnable;		
								aluop_o <= `EXE_XOR_OP;
		  						alusel_o <= `EXE_RES_LOGIC;		
								reg1_read_o <= 1'b1;	
								reg2_read_o <= 1'b1;	
		  						instvalid <= `InstValid;	
							end  				
		    				`EXE_NOR:	begin
		    					wreg_o <= `WriteEnable;		
								aluop_o <= `EXE_NOR_OP;
		  						alusel_o <= `EXE_RES_LOGIC;		
								reg1_read_o <= 1'b1;	
								reg2_read_o <= 1'b1;	
		  						instvalid <= `InstValid;	
							end 
							`EXE_SLLV: begin
								wreg_o <= `WriteEnable;		
								aluop_o <= `EXE_SLL_OP;
		  						alusel_o <= `EXE_RES_SHIFT;		
								reg1_read_o <= 1'b1;	
								reg2_read_o <= 1'b1;
		  						instvalid <= `InstValid;	
							end 
							`EXE_SRLV: begin
								wreg_o <= `WriteEnable;		
								aluop_o <= `EXE_SRL_OP;
		  						alusel_o <= `EXE_RES_SHIFT;		
								reg1_read_o <= 1'b1;	
								reg2_read_o <= 1'b1;
		  						instvalid <= `InstValid;	
							end 					
							`EXE_SRAV: begin
								wreg_o <= `WriteEnable;		
								aluop_o <= `EXE_SRA_OP;
		  						alusel_o <= `EXE_RES_SHIFT;		
								reg1_read_o <= 1'b1;	
								reg2_read_o <= 1'b1;
		  						instvalid <= `InstValid;			
		  					end
							`EXE_MFHI: begin
								wreg_o <= `WriteEnable;		
								aluop_o <= `EXE_MFHI_OP;
		  						alusel_o <= `EXE_RES_MOVE;   
								reg1_read_o <= 1'b0;	
								reg2_read_o <= 1'b0;
		  						instvalid <= `InstValid;	
							end
							`EXE_MFLO: begin
								wreg_o <= `WriteEnable;		
								aluop_o <= `EXE_MFLO_OP;
		  						alusel_o <= `EXE_RES_MOVE;   
								reg1_read_o <= 1'b0;	
								reg2_read_o <= 1'b0;
		  						instvalid <= `InstValid;	
							end
							`EXE_MTHI: begin
								wreg_o <= `WriteDisable;		
								aluop_o <= `EXE_MTHI_OP;
		  						reg1_read_o <= 1'b1;	
								reg2_read_o <= 1'b0; 
								instvalid <= `InstValid;	
							end
							`EXE_MTLO: begin
								wreg_o <= `WriteDisable;		
								aluop_o <= `EXE_MTLO_OP;
		  						reg1_read_o <= 1'b1;	
								reg2_read_o <= 1'b0; 
								instvalid <= `InstValid;	
							end
							`EXE_MOVN: begin
								aluop_o <= `EXE_MOVN_OP;
		  						alusel_o <= `EXE_RES_MOVE;   
								reg1_read_o <= 1'b1;	
								reg2_read_o <= 1'b1;
		  						instvalid <= `InstValid;
								 if(reg2_o != `ZeroWord) begin
	 								wreg_o <= `WriteEnable;
	 							end else begin
	 								wreg_o <= `WriteDisable;
	 							end
							end
							`EXE_MOVZ: begin
								aluop_o <= `EXE_MOVZ_OP;
		  						alusel_o <= `EXE_RES_MOVE;   reg1_read_o <= 1'b1;	reg2_read_o <= 1'b1;
		  						instvalid <= `InstValid;
							 	if(reg2_o == `ZeroWord) begin
	 								wreg_o <= `WriteEnable;
	 							end else begin
	 								wreg_o <= `WriteDisable;
	 							end		  							
							end
							`EXE_SLT: begin
								wreg_o <= `WriteEnable;		
								aluop_o <= `EXE_SLT_OP;
		  						alusel_o <= `EXE_RES_ARITHMETIC;		
								reg1_read_o <= 1'b1;	
								reg2_read_o <= 1'b1;
		  						instvalid <= `InstValid;	
							end
							`EXE_SLTU: begin
								wreg_o <= `WriteEnable;		
								aluop_o <= `EXE_SLTU_OP;
		  						alusel_o <= `EXE_RES_ARITHMETIC;		
								reg1_read_o <= 1'b1;	
								reg2_read_o <= 1'b1;
		  						instvalid <= `InstValid;	
							end
							`EXE_ADD: begin
								wreg_o <= `WriteEnable;		
								aluop_o <= `EXE_ADD_OP;
		  						alusel_o <= `EXE_RES_ARITHMETIC;		
								reg1_read_o <= 1'b1;	
								reg2_read_o <= 1'b1;
		  						instvalid <= `InstValid;	
							end
							`EXE_ADDU: begin
								wreg_o <= `WriteEnable;		aluop_o <= `EXE_ADDU_OP;
		  						alusel_o <= `EXE_RES_ARITHMETIC;		reg1_read_o <= 1'b1;	reg2_read_o <= 1'b1;
		  						instvalid <= `InstValid;	
							end
							`EXE_SUB: begin
								wreg_o <= `WriteEnable;		
								aluop_o <= `EXE_SUB_OP;
		  						alusel_o <= `EXE_RES_ARITHMETIC;		
								reg1_read_o <= 1'b1;	
								reg2_read_o <= 1'b1;
		  						instvalid <= `InstValid;	
							end
							`EXE_SUBU: begin
								wreg_o <= `WriteEnable;		aluop_o <= `EXE_SUBU_OP;
		  						alusel_o <= `EXE_RES_ARITHMETIC;		reg1_read_o <= 1'b1;	reg2_read_o <= 1'b1;
		  						instvalid <= `InstValid;	
							end
							`EXE_MULT: begin
								wreg_o <= `WriteDisable;		aluop_o <= `EXE_MULT_OP;
		  						reg1_read_o <= 1'b1;	reg2_read_o <= 1'b1; instvalid <= `InstValid;	
							end
							`EXE_MULTU: begin
								wreg_o <= `WriteDisable;		aluop_o <= `EXE_MULTU_OP;
		  						reg1_read_o <= 1'b1;	reg2_read_o <= 1'b1; instvalid <= `InstValid;	
							end 											  											
						    default:	begin
						    end
						endcase
						  
						  
						 end
						default: begin
						
						
						end
					endcase	
					end									  
		  	`EXE_ORI:			begin                        //ORI指令
		  		wreg_o <= `WriteEnable;		
				aluop_o <= `EXE_OR_OP;
		  		alusel_o <= `EXE_RES_LOGIC; 
				reg1_read_o <= 1'b1;	
				reg2_read_o <= 1'b0;	  	
				imm <= {16'h0, inst_i[15:0]};		
				wd_o <= inst_i[20:16];
				instvalid <= `InstValid;	
		  	end
		  	`EXE_ANDI:			begin
		  		wreg_o <= `WriteEnable;		
				aluop_o <= `EXE_AND_OP;
		  		alusel_o <= `EXE_RES_LOGIC;	
				reg1_read_o <= 1'b1;	
				reg2_read_o <= 1'b0;	  	
				imm <= {16'h0, inst_i[15:0]};		
				wd_o <= inst_i[20:16];		  	
				instvalid <= `InstValid;	
			end	 	
		  	`EXE_XORI:			begin
		  		wreg_o <= `WriteEnable;		
				aluop_o <= `EXE_XOR_OP;
		  		alusel_o <= `EXE_RES_LOGIC;	
				reg1_read_o <= 1'b1;	
				reg2_read_o <= 1'b0;	  	
				imm <= {16'h0, inst_i[15:0]};		
				wd_o <= inst_i[20:16];		  	
				instvalid <= `InstValid;	
			end	 		
		  	`EXE_LUI:			begin
		  		wreg_o <= `WriteEnable;		aluop_o <= `EXE_OR_OP;
		  		alusel_o <= `EXE_RES_LOGIC; reg1_read_o <= 1'b1;	reg2_read_o <= 1'b0;	  	
					imm <= {inst_i[15:0], 16'h0};		wd_o <= inst_i[20:16];		  	
					instvalid <= `InstValid;	
				end			
			`EXE_SLTI:			begin
		  		wreg_o <= `WriteEnable;		
				aluop_o <= `EXE_SLT_OP;
		  		alusel_o <= `EXE_RES_ARITHMETIC; 
				reg1_read_o <= 1'b1;	
				reg2_read_o <= 1'b0;	  	
				imm <= {{16{inst_i[15]}}, inst_i[15:0]};		
				wd_o <= inst_i[20:16];		  	
				instvalid <= `InstValid;	
			end
			`EXE_SLTIU:			begin
		  		wreg_o <= `WriteEnable;		
				aluop_o <= `EXE_SLTU_OP;
		  		alusel_o <= `EXE_RES_ARITHMETIC; 
				reg1_read_o <= 1'b1;	
				reg2_read_o <= 1'b0;	  	
				imm <= {{16{inst_i[15]}}, inst_i[15:0]};		
				wd_o <= inst_i[20:16];		  	
				instvalid <= `InstValid;	
			end
			`EXE_ADDI:			begin
		  		wreg_o <= `WriteEnable;		
				aluop_o <= `EXE_ADDI_OP;
		  		alusel_o <= `EXE_RES_ARITHMETIC; 
				reg1_read_o <= 1'b1;	
				reg2_read_o <= 1'b0;	  	
				imm <= {{16{inst_i[15]}}, inst_i[15:0]};		
				wd_o <= inst_i[20:16];		  	
				instvalid <= `InstValid;	
			end
				`EXE_ADDIU:			begin
		  		wreg_o <= `WriteEnable;		aluop_o <= `EXE_ADDIU_OP;
		  		alusel_o <= `EXE_RES_ARITHMETIC; reg1_read_o <= 1'b1;	reg2_read_o <= 1'b0;	  	
					imm <= {{16{inst_i[15]}}, inst_i[15:0]};		wd_o <= inst_i[20:16];		  	
					instvalid <= `InstValid;	
				end
				`EXE_SPECIAL2_INST:		begin
					case ( op3 )
						`EXE_CLZ:		begin
							wreg_o <= `WriteEnable;		aluop_o <= `EXE_CLZ_OP;
		  				alusel_o <= `EXE_RES_ARITHMETIC; reg1_read_o <= 1'b1;	reg2_read_o <= 1'b0;	  	
							instvalid <= `InstValid;	
						end
						`EXE_CLO:		begin
							wreg_o <= `WriteEnable;		aluop_o <= `EXE_CLO_OP;
		  				alusel_o <= `EXE_RES_ARITHMETIC; reg1_read_o <= 1'b1;	reg2_read_o <= 1'b0;	  	
							instvalid <= `InstValid;	
						end
						`EXE_MUL:		begin
							wreg_o <= `WriteEnable;		aluop_o <= `EXE_MUL_OP;
		  				alusel_o <= `EXE_RES_MUL; reg1_read_o <= 1'b1;	reg2_read_o <= 1'b1;	
		  				instvalid <= `InstValid;	  			
						end
						`EXE_MADD:		begin
							wreg_o <= `WriteDisable;		aluop_o <= `EXE_MADD_OP;
		  				alusel_o <= `EXE_RES_MUL; reg1_read_o <= 1'b1;	reg2_read_o <= 1'b1;	  			
		  				instvalid <= `InstValid;	
						end
						`EXE_MADDU:		begin
							wreg_o <= `WriteDisable;		aluop_o <= `EXE_MADDU_OP;
		  				alusel_o <= `EXE_RES_MUL; reg1_read_o <= 1'b1;	reg2_read_o <= 1'b1;	  			
		  				instvalid <= `InstValid;	
						end
						`EXE_MSUB:		begin
							wreg_o <= `WriteDisable;		aluop_o <= `EXE_MSUB_OP;
		  				alusel_o <= `EXE_RES_MUL; reg1_read_o <= 1'b1;	reg2_read_o <= 1'b1;	  			
		  				instvalid <= `InstValid;	
						end
						`EXE_MSUBU:		begin
							wreg_o <= `WriteDisable;		aluop_o <= `EXE_MSUBU_OP;
		  				alusel_o <= `EXE_RES_MUL; reg1_read_o <= 1'b1;	reg2_read_o <= 1'b1;	  			
		  				instvalid <= `InstValid;	
						end						
						default:	begin
						end
					endcase      //EXE_SPECIAL_INST2 case
				end																		  	
		    default:			begin
		    end
		  endcase		  //case op
		  
		  if (inst_i[31:21] == 11'b00000000000) begin
		  	if (op3 == `EXE_SLL) begin
		  		wreg_o <= `WriteEnable;		
				aluop_o <= `EXE_SLL_OP;
		  		alusel_o <= `EXE_RES_SHIFT; 
				reg1_read_o <= 1'b0;	
				reg2_read_o <= 1'b1;	  	
				imm[4:0] <= inst_i[10:6];		
				wd_o <= inst_i[15:11];
				instvalid <= `InstValid;	
			end else if ( op3 == `EXE_SRL ) begin
					wreg_o <= `WriteEnable;		
					aluop_o <= `EXE_SRL_OP;
					alusel_o <= `EXE_RES_SHIFT; 
					reg1_read_o <= 1'b0;	
					reg2_read_o <= 1'b1;	  	
					imm[4:0] <= inst_i[10:6];		
					wd_o <= inst_i[15:11];
					instvalid <= `InstValid;	
				end else if ( op3 == `EXE_SRA ) begin
						wreg_o <= `WriteEnable;		
						aluop_o <= `EXE_SRA_OP;
						alusel_o <= `EXE_RES_SHIFT; 
						reg1_read_o <= 1'b0;	
						reg2_read_o <= 1'b1;	  	
						imm[4:0] <= inst_i[10:6];		
						wd_o <= inst_i[15:11];
						instvalid <= `InstValid;	
				end
			end		  