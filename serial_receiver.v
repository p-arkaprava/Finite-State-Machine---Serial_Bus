module top_module(
    input clk,
    input in,
    input reset,    // Synchronous reset
    output done
); 
    // Using 3 bits to avoid overflow (2'd4 is actually 3'b100)
    parameter IDLE = 3'd0, READ = 3'd1, STOP = 3'd2, WAIT = 3'd3, DONE = 3'd4;
    reg [2:0] state, next_state;
    reg [3:0] bit_cnt;

    // State Register
    always @(posedge clk) begin
        if (reset) state <= IDLE;
        else       state <= next_state;
    end

    // Counter: Only counts during the READ state
    always @(posedge clk) begin
        if (reset)
            bit_cnt <= 0;
        else if (state == READ)
            bit_cnt <= bit_cnt + 1;
        else
            bit_cnt <= 0;
    end
    
    // Next State Logic
    always @(*) begin 
        case (state)
            IDLE: next_state = (in == 0) ? READ : IDLE; // Start bit detected
            
            READ: begin
                // We stay in READ for exactly 8 clock cycles
                if (bit_cnt == 4'd7) next_state = STOP; 
                else                 next_state = READ;
            end
            
            STOP: begin
                // This is the cycle where we sample the stop bit
                if (in == 1) next_state = DONE;   // Success!
                else         next_state = WAIT;   // Framing Error
            end
            
            DONE: begin
                // After one cycle of DONE, check if a new start bit is already here
                next_state = (in == 0) ? READ : IDLE;
            end
            
            WAIT: begin
                // Stay here until the line goes high (idle)
                next_state = (in == 1) ? IDLE : WAIT;
            end
            
            default: next_state = IDLE;
        endcase
    end
    
    // Output: Pulse high for exactly one cycle when valid byte received
    assign done = (state == DONE);

endmodule