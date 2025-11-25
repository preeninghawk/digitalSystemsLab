module InstructionDecoder(
    input [13-1:0] INST,
    output [2-1:0] DA, AA, BA,
    output MB,
    output [4-1:0] FS,
    output MD, RW, MW, PL, JB, BC
    ); 
    wire f1;
    assign f1       =  INST[12] & INST[11];  
      
    assign DA       =  INST[5:4];
    assign AA       =  INST[3:2];
    assign BA       =  INST[1:0];
    assign MB       =  INST[12];
    assign FS[3:1]  =  INST[9:7];
    assign FS[0]    =  INST[6] & (~f1);
    assign MD       =  INST[10];
    assign RW       = ~INST[11];
    assign MW       = ~INST[12] & INST[11];
    assign PL       =  f1;
    assign JB       =  INST[10];
    assign BC       =  INST[6];
endmodule
