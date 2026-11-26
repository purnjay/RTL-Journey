// THE CONTROL UNIT 

module control_unit(
    input [31:0] inst,      // the instruction 
    output reg [2:0] aluOP,  // opcode for ALU
    output reg mem_rw,      // read or write for data mem  
    output reg alu_src,     // which register goes into alu -> 0 = imm, 1 = rs2
    output reg mem_reg,      // what gets to rd, result of alu or Datamem
    output reg reg_write,    // register enable signal
    output reg branch_step   // step for branch that goes into PC.v
);

// Control unit needs these values from the instruction for the current scope
wire [6:0] opcode = inst[6:0];
wire [2:0] funct3 = inst[14:12];
wire [6:0] funct7 = inst[31:25];

// paramters for opcodes, added additional for future proofing
localparam R_type = 7'b0110011,
           I_type = 7'b0010011,
           I_type2 = 7'b0000011,
           I_type3 = 7'b1100111,
           S_type = 7'b0100011,
           B_type = 7'b1100011,
           J_type = 7'b1101111,
           U_type = 7'b0110111,
           U_type2 = 7'b0010111;
           

always @(*) begin

    //default values before the cases
    aluOP = 3'b000;     // ADD
    alu_src = 1;        // rs2
    mem_rw = 0;         // don't write data mem
    mem_reg = 0;        // rd gets ALU result
    reg_write = 0;      // don't write register
    branch_step = 0;    // not a branch

    case (opcode)
        R_type: begin
            reg_write = 1;
            case ({funct3, funct7})
                {3'h0, 7'h00}: aluOP = 3'b000;  // ADD
                {3'h0, 7'h20}: aluOP = 3'b001;  // SUB
                {3'h7, 7'h00}: aluOP = 3'b010;  // AND
                {3'h6, 7'h00}: aluOP = 3'b011;  // OR 
                {3'h4, 7'h00}: aluOP = 3'b100;  // XOR 
            endcase
        end  
        I_type: begin
                case (funct3)
                    3'h0: begin         //ADDI
                        reg_write = 1;
                        alu_src = 0;     //I
                    end
                endcase
        end
        
        I_type2: begin
                case (funct3) 
                    3'h2: begin          //LW
                        mem_reg = 1;     //rd gets data mem
                        alu_src = 0;     // I
                        reg_write = 1;
                    end 
                endcase
        end
        
        S_type: begin
                case (funct3)
                    3'h2: begin
                        mem_rw = 1'b1;  //SW
                        alu_src = 0;    //I
                    end 
                endcase
        end
        
        B_type: begin
                case (funct3) //BEQ
                    3'h0: begin
                        branch_step = 1;
                        aluOP = 3'b001; // SUB
                    end  
                endcase
        end
    endcase
end
endmodule