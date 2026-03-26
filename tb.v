`timescale 1ns/1ps

module top_module_tb;

    // Inputs
    reg clk;
    reg in;
    reg reset;

    // Outputs
    wire done;

    // Instantiate the Unit Under Test (UUT)
    top_module uut (
        .clk(clk),
        .in(in),
        .reset(reset),
        .done(done)
    );

    // Clock generation (100MHz / 10ns period)
    initial clk = 0;
    always #5 clk = ~clk;

    // --- GTKWave Logic ---
    initial begin
        // Name of the output file
        $dumpfile("uart_sim.vcd"); 
        // 0 means dump all signals in the current module and below
        $dumpvars(0, top_module_tb); 
    end

    // Task to send one serial byte (Start=0, 8 Data bits, Stop=1)
    task send_byte(input [7:0] data, input send_correct_stop);
        integer i;
        begin
            // Start bit
            in = 0;
            @(posedge clk);
            
            // 8 Data bits (LSB first)
            for (i = 0; i < 8; i = i + 1) begin
                in = data[i];
                @(posedge clk);
            end
            
            // Stop bit
            in = send_correct_stop ? 1 : 0;
            @(posedge clk);
            
            // Idle high after stop bit
            in = 1;
            @(posedge clk);
        end
    endtask

    initial begin
        // Initialize
        in = 1; 
        reset = 0;

        // Reset Sequence
        repeat(2) @(posedge clk);
        reset = 1;
        repeat(2) @(posedge clk);
        reset = 0;
        @(posedge clk);

        // --- Scenario 1: Successful Byte (0xA5) ---
        $display("Sending 0xA5 with correct stop bit...");
        send_byte(8'hA5, 1);
        
        // --- Scenario 2: Framing Error (Missing Stop Bit) ---
        $display("Sending 0xFF with MISSING stop bit...");
        send_byte(8'hFF, 0); 

        // Wait in WAIT state then return to idle
        repeat(5) @(posedge clk);
        in = 1; 
        repeat(5) @(posedge clk);
        
        $display("Simulation complete. Open uart_sim.vcd in GTKWave.");
        $finish;
    end

endmodule