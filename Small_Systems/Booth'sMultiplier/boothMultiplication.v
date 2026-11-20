module boothMult #(parameter N = 4)(
    input clk,
    input rst,
    input start,          // to start the operation
    input [N-1:0] M,     //Multiplicand
    input [N-1:0] Q,     // Multiplier
    output reg done,        // flag for multiplication done signal
    output [(2*N)-1:0] result
);

/* 
A -> Accumulator
Q -> Multiplier
Qn-1 -> Previous value store

store -> {A3, A2, A1, A0, Q3, Q2, Q1, Q0, Qn-1}
*/
reg [(2*N):0] store;

// a counter to keep track of the shifting
reg [$clog2(N):0] counter;

// to keep track of operation
reg busy;

// the loop for calculation on positive clock edge
always @(posedge clk) begin

    //reset
    if(rst) begin
        busy = 0;
        done = 0;

    end else if (start && !busy) begin
        
        //MSB -> Sign bit, LSB -> Qn-1
        store = {{N{1'b0}}, Q, 1'b0};
        counter = N;      // re-initialize counter for this operation
        busy = 1; // set busy to 1
        done = 0; // keep done 0

    end else if (busy) begin
        // case statment to keep everything clean
        case (store[1:0])
            2'b00: begin
                store = {store[2*N], store[2*N:1]};  //shift right
                counter = counter - 1; //decrement counter
            end
            2'b01: begin
                store[2*N:N+1] = store[2*N:N+1] + M; // add
                store = {store[2*N], store[2*N:1]}; // shift right
                counter = counter - 1; //decrement counter
            end
            2'b10: begin
                store[2*N:N+1] = store[2*N:N+1] - M; // sub 
                store = {store[2*N], store[2*N:1]}; // shift right
                counter = counter - 1; //decrement counter
            end 
            2'b11: begin
                store = {store[2*N], store[2*N:1]}; // shift right
                counter = counter - 1; //decrement counter
            end
        endcase

        // check if counter has reached 0 or not
        if (counter == 0) begin
            busy = 0;
            done = 1;
        end
    end
end

//assign the result
assign result = store[2*N:1];

endmodule