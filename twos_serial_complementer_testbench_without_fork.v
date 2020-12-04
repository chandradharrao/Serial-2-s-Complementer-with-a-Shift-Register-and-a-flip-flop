module Serial_twosComplementer_Testbench();
    wire y;//this will be the output of the xor selective inverter
    reg [7: 0] data;//the input data
    reg load, shift_control, Clock, reset_b;//control signals
    reg [7: 0] twos_comp;//used to store the pure final output only.

    Serial_twosComplementer stc0 (y, data, load, shift_control, Clock, reset_b);
    
    always @ (posedge Clock, negedge reset_b)//concurrent execution
        if (reset_b == 0)
            twos_comp <= 0;
        else if (shift_control == 1 && load == 0) //shift the bits
            twos_comp <= {y, twos_comp[7: 1]};//concating the wires:y ie output bit of xor with the bits 1:7 of the going to be output wire

        //all the below "Iniial" blocks will run at the same time concurrently
        initial #200 $finish;//this will finish after 200 time units of delay
        
        initial begin 
            $dumpfile("test.vcd");
            $dumpvars(0,Serial_twosComplementer_Testbench);
        end
        
        initial begin//the statements listed under begin block execute sequentially one after the 	other since '=' is used
            Clock = 0; 
            while (1) begin //run an infinite loop to generate clk until simulation finishes
                    #5 Clock = ~Clock; //rising clock edge at 5,10,15,20... 
                end
            end 
        initial begin 
            #2 reset_b = 0;//reset the flip flops at 2nd time unit
            #4 reset_b = ~reset_b;//make reset_b bool -tive at 6th time unit
            end
        //each timing is absolute to when the group started to execte
        initial begin
            data = 8'h5A;//1011010 in binary
            //data = 8'h33;//00110011 in binary
            //data = 8'b1011010;//binary form
            #20 load = 1;//load the data into the shift registers
            #10 load = 0;//after 10s set load to false
            #20 shift_control = 1;//after 20 seconds shift one bit
            begin repeat (8+1) @ (posedge Clock);//The first posedge will trigger the for loop 								and afer 8 posedge the loop is terminated
                //after 8 pos edges of clock cycle we make shift control false to stop shifting of bits since there are only 8 bits
                shift_control = 0;
            end
        end
endmodule
