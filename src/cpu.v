module cpu (
    input clk,
    input rst,
    input [7:0] data_in,
    input clr_data_in,
    input dsp_ar,
    input set_ar,
    input r_mem,
    input w_mem,
    input start_cpu,
    input stop_cpu,
    output [7:0] data_out,
    output run_cpu
);

    reg S;
    reg [2:0] SC;
    localparam 
        T0 = 3'd0, 
        T1 = 3'd1, 
        T2 = 3'd2, 
        T3 = 3'd3, 
        T4 = 3'd4, 
        T5 = 3'd5,
        T6 = 3'd6; 

    reg [4:0] PC;
    reg [4:0] AR;
    reg [7:0] IR;
    reg [7:0] DR;
    reg [7:0] AC;
    reg [7:0] INPR;
    reg [7:0] OUTR;

    wire [7:0] D;

    reg [7:0] mem [32:0];


    always @(posedge clk or posedge rst) begin

        if (rst) begin
            SC <= 0;
            PC <= 0;
            OUTR <= 0;
            AR <= 0;
            S <= 0;
            INPR <= 0;
            OUTR <= 0;
            // Inicializar memoria a 0 durante reset asíncrono
            for (integer i = 0; i < 32; i = i + 1) begin
                mem[i] <= 0;
            end
        end else begin
            S <= (start_cpu & ~S) | (~stop_cpu & S);

            if (S == 0) begin 

                if (clr_data_in) begin
                    INPR <= 0;
                    OUTR <= 0;
                end else if (data_in) begin
                    INPR <= data_in | INPR;
                    OUTR <= data_in | OUTR;
                end

                else if (dsp_ar) begin
                    OUTR <= AR;
                end
                else if (set_ar) begin
                    AR <= INPR[4:0];
                end

                else if (w_mem) begin
                    mem[AR] <= INPR;
                end
                else if (r_mem) begin
                    OUTR <= mem[AR];
                end

            end else begin
                if ( (D[7] && SC == T3) ||
                    ((D[0] || D[1] || D[2] || D[5]) && SC == T5) ||
                    ((D[3] || D[4]) && SC == T4) ||
                    (D[6] && SC == T6)
                    ) begin
                    SC <= 0;
                end else SC <= SC + 1;
            
                case (SC)
                    T0: begin
                        AR <= PC;
                    end
                    T1: begin
                        IR <= mem[AR];
                        PC <= PC + 1;
                    end
                    T2: begin
                        AR <= IR[4:0];
                    end
                    T3: begin
                        if (D[7]) begin
                            if (IR[0]) begin
                                AC <= ~AC;
                            end
                            if (IR[1]) begin
                                AC <= AC + 1;
                            end
                            if (IR[2]) begin
                                S <= 0;
                            end
                            if (IR[3] && AC == 0) begin
                                PC <= PC + 1;
                            end
                            if (IR[4]) begin
                                OUTR <= AC;
                            end
                        end
                    end
                    T4: begin
                        if (D[0] || D[1] || D[2] || D[5] || D[6]) begin
                            DR <= mem[AR];
                        end
                        if (D[3]) begin
                            mem[AR] <= AC;
                        end
                        if (D[4]) begin
                            PC <= AR;
                        end
                        
                    end
                    T5: begin
                        if (D[0]) begin
                            AC <= AC & DR;
                        end
                        if (D[1]) begin
                            AC <= AC + DR;
                        end
                        if (D[2]) begin
                            AC <= DR;
                        end
                        if (D[5]) begin
                            AC <= AC - DR;
                        end
                        if (D[6]) begin
                            DR <= DR + 1;
                        end
                    end
                    T6: begin
                        if (D[6]) begin
                            mem[AR] <= DR;
                            if (DR == 0) begin
                                PC <= PC + 1;
                            end
                        end
                    end
                endcase
            end
        end
    end
    
    // Decodificador de instruccion de IR
    assign D = 1 << IR[7:5];

    assign data_out = OUTR;
    assign run_cpu = S;

endmodule