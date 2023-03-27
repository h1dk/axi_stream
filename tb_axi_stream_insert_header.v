`timescale 1ns/1ns
module tb_axi_stream_insert_header (); 

	// clock
	reg clk;
	initial begin
		clk = '0;
		forever #(5) clk = ~clk;
	end

	// asynchronous reset
	reg rst_n;
	initial begin
		rst_n <= '0;
		#10
		rst_n <= '1;
	end


	// (*NOTE*) replace reset, clock, others
	parameter      DATA_WD = 32;
	parameter DATA_BYTE_WD = DATA_WD / 8;

	reg                       valid_in;
	reg      [DATA_WD-1 : 0]  data_in;
	reg [DATA_BYTE_WD-1 : 0]  keep_in;
	reg                       last_in;
	wire                      ready_in;

	reg                       valid_insert;
	reg      [DATA_WD-1 : 0]  data_insert;
	reg [DATA_BYTE_WD-1 : 0]  keep_insert;
	wire                      ready_insert;

	wire                      valid_out;
	wire     [DATA_WD-1 : 0]  data_out;
	wire [DATA_BYTE_WD-1 : 0] keep_out;
	wire                      last_out;
	reg                       ready_out;

	axi_stream_insert_header #(
			.DATA_WD(DATA_WD),
			.DATA_BYTE_WD(DATA_BYTE_WD)
		) inst_axi_stream_insert_header (
			.clk           (clk),
			.rst_n         (rst_n),
			.valid_in      (valid_in),
			.data_in       (data_in),
			.keep_in       (keep_in),
			.last_in       (last_in),
			.ready_in      (ready_in),
			.valid_insert  (valid_insert),
			.data_insert   (data_insert),
			.keep_insert   (keep_insert),
			.ready_insert  (ready_insert),
			.valid_out     (valid_out),
			.data_out      (data_out),
			.keep_out      (keep_out),
			.last_out      (last_out),
			.ready_out     (ready_out)
		);

	task init();
		valid_in      <= '0;
		data_in       <= '0;
		keep_in       <= '0;
		last_in       <= '0;
		valid_insert  <= '0;
		data_insert <= '0;
		keep_insert   <= '0;
		ready_out     <= '0;
	endtask

	task start();
		repeat(5)@(posedge clk);
		keep_in       <= 4'b1111;
		last_in       <= 0;
		data_in       <= {$random};
		valid_in  	  <= 1;
		data_insert <= {$random};
		keep_insert   <=  4'b0111;
		valid_insert  <= 1;
		repeat(1)@(posedge clk);
		ready_out     <= 1;
		repeat(2)@(posedge clk);
		data_insert <= {$random};
	endtask

	task drive();
		data_in       <= {$random};
		keep_in       <= 4'b1111;
		@(posedge clk);
	endtask

	task last();
		keep_in       <= 4'b1100;
		last_in       <= 1;
		data_in       <= {$random};
		@(posedge clk);
		last_in       <= 0;
		keep_in       <= 4'b1100;
	endtask

	task nextdata();
		keep_in       <= 4'b1111;
		last_in       <= 0;
		data_in       <= {$random};
		keep_insert   <= 4'b0011;
		repeat(3)@(posedge clk);
		valid_insert  <= 0;	
	endtask

	task last2();
		keep_in       <= 4'b1110;
		last_in       <= 1;
		data_in       <= {$random};
		@(posedge clk);
		last_in       <= 0;
		//keep_in       <= 4'b1110;
		endtask

	task close();
		valid_in  	  <= 0;
		valid_insert  <= 0;
		repeat(2)@(posedge clk);
		ready_out     <= 0;
		@(posedge clk);
	endtask	

	initial begin
		init();

		start();
		repeat(8)drive();
		last();

		nextdata();
		repeat(6)drive();
		last2();

		close();

		repeat(7)@(posedge clk);

		start();
		repeat(5)drive();
		last();

		nextdata();
		repeat(4)drive();
		last2();

		close();

	end

	initial begin
      forever begin
         #100;
         if ($time >= 1000)  $finish ;
      end
   end
initial begin
   $vcdplusfile ("./axi_stream_insert_header.vcd");
   $vcdpluson(0,tb_axi_stream_insert_header);
end

initial begin
	$fsdbDumpfile("./axi_stream_insert_header.fsdb");
	$fsdbDumpvars(0,tb_axi_stream_insert_header);
	$dumpon;
end
endmodule