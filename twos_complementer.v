//used : = for blocking combintionl crkts and <= for non blocking sequential circuits
module xor2 (input wire i0, i1, output wire o);
  //selective complementer using xor and i1 as control
  assign o = i0^i1;
endmodule

module or2 (input wire i0, i1, output wire o);
  //oring for dflip flop input
  assign o = i0|i1;
endmodule

module dfrl (input clk,reset_b,shift_control,inputLSB,output wire out);
  reg df_out;
  wire df_data;

  //calculating the input to the dfrl
  or2 orgate(inputLSB,df_out,df_data);
  //reset and load flip flop
  //the flip flop is read in the posedge but written in neg edge clk cycle hence letting us save 	an entire clock cycle
  always@(posedge clk,negedge reset_b)//sensitive to either pos clk or neg rest_b edge
  if(~reset_b) begin
    df_out <= 0;//reset the flip flop
  end
  else begin
    if(shift_control) begin
      df_out <= df_data;//supply the content to the output of dfrl
    end
  end
  assign out = df_out;
endmodule

module df (input clk, in, output wire out);
  reg df_out;
  always@(posedge clk) df_out <= in;//positive edge triggered DFF
  assign out = df_out;
endmodule

module shiftRegArr(input clk,load,shift_bool,seriallyInpBit,reset_b,input[7:0] data,output wire[7:0] outWires);
  //8 bit shift register with reset and load
  reg [7:0] myShiftRegs;
  always @ (posedge clk, negedge reset_b) //pos edge triggered
  if(reset_b == 0) begin
    myShiftRegs <= 0;
  end
  else begin
    if(load) myShiftRegs = data;//load the input data to be complemented serially
    else if(shift_bool) begin
      myShiftRegs <= {seriallyInpBit,myShiftRegs[7:1]};//inserting the xor's output at msb along with bits 1:7 of input since bit 0/LSB is gone for complementing 
    end
  end
  assign outWires =  myShiftRegs;//store it back in the shiftWires because they need to be serially inputted with twos complement acc to question
endmodule

module Serial_twosComplementer(output y, input [7: 0] data, input load, shift_control, Clock, reset_b);
    
    wire[7:0] shiftwires;//wires passed to shiftRegArr to store the input data and serially get the twos complement of the individual bits
    wire Q;//stores the output from the dfrl which tells wheather to invert or not ie becomes 1 after seing the first 1 bit in input data
    wire inputLSB = shiftwires[0];//this will store the LSB of the input data that will be 	complemented
    
    //instantiating the needed modules below:
    xor2 comp(inputLSB,Q,y);//based on Q(output) recieved from the dffrl it will either complement the inputBit or not and send output via y
    dfrl dffQ(Clock,reset_b,shift_control,inputLSB,Q);//supplies Q for selective inverting after seeing first 1 bit supplied
    shiftRegArr shiftReg0(Clock,load,shift_control,y,reset_b,data,shiftwires[7:0]);
endmodule
