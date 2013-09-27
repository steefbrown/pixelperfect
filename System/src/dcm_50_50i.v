


//----------------------------------------------------------------------------
// "Output    Output      Phase     Duty      Pk-to-Pk        Phase"
// "Clock    Freq (MHz) (degrees) Cycle (%) Jitter (ps)  Error (ps)"
//----------------------------------------------------------------------------
// CLK_OUT1___100.000______0.000______50.0______300.000____150.000
// CLK_OUT2____50.000______0.000______50.0______200.000____150.000
// CLK_OUT3____50.000____180.000______50.0______300.000____150.000
//
//----------------------------------------------------------------------------
// "Input Clock   Freq (MHz)    Input Jitter (UI)"
//----------------------------------------------------------------------------
// __primary_________100.000____________0.010

`timescale 1ps/1ps

(* CORE_GENERATION_INFO = "dcm,clk_wiz_v3_6,{component_name=dcm,use_phase_alignment=true,use_min_o_jitter=false,use_max_i_jitter=false,use_dyn_phase_shift=false,use_inclk_switchover=false,use_dyn_reconfig=false,feedback_source=FDBK_AUTO,primtype_sel=DCM_SP,num_out_clk=3,clkin1_period=10.0,clkin2_period=10.0,use_power_down=false,use_reset=true,use_locked=false,use_inclk_stopped=false,use_status=false,use_freeze=false,use_clk_valid=true,feedback_type=SINGLE,clock_mgr_type=MANUAL,manual_override=false}" *)
module dcm_50_50i
 (// Clock in ports
  input         CLK_IN1,
  // Clock out ports
  output        CLK_100,
  output        CLK_50,
  output        CLK_50_inv,
  // Status and control signals
  input         RESET,
  output        CLK_VALID
 );

  // Input buffering
  //------------------------------------
  assign clkin1 = CLK_IN1;


  // Clocking primitive
  //------------------------------------

  // Instantiation of the DCM primitive
  //    * Unused inputs are tied off
  //    * Unused outputs are labeled unused
  wire        psdone_unused;
  wire        locked_int;
  wire [7:0]  status_int;
  wire clkfb;
  wire clk0;
  wire clk180;
  wire clk2x;

  DCM_SP
  #(.CLKDV_DIVIDE          (2.000),
    .CLKFX_DIVIDE          (1),
    .CLKFX_MULTIPLY        (4),
    .CLKIN_DIVIDE_BY_2     ("TRUE"),
    .CLKIN_PERIOD          (10.0),
    .CLKOUT_PHASE_SHIFT    ("NONE"),
    .CLK_FEEDBACK          ("2X"),
    .DESKEW_ADJUST         ("SYSTEM_SYNCHRONOUS"),
    .PHASE_SHIFT           (0),
    .STARTUP_WAIT          ("FALSE"))
  dcm_sp_inst
    // Input clock
   (.CLKIN                 (clkin1),
    .CLKFB                 (clkfb),
    // Output clocks
    .CLK0                  (clk0),
    .CLK90                 (),
    .CLK180                (clk180),
    .CLK270                (),
    .CLK2X                 (clk2x),
    .CLK2X180              (),
    .CLKFX                 (),
    .CLKFX180              (),
    .CLKDV                 (),
    // Ports for dynamic phase shift
    .PSCLK                 (1'b0),
    .PSEN                  (1'b0),
    .PSINCDEC              (1'b0),
    .PSDONE                (),
    // Other control and status signals
    .LOCKED                (locked_int),
    .STATUS                (status_int),
 
    .RST                   (RESET),
    // Unused pin- tie low
    .DSSEN                 (1'b0));

    assign CLK_VALID = ( ( locked_int == 1'b 1 ) && ( status_int[1] == 1'b 0 ) );

  // Output buffering
  //-----------------------------------
  assign clkfb = CLK_100;

  BUFG clkout1_buf
   (.O   (CLK_100),
    .I   (clk2x));


  BUFG clkout2_buf
   (.O   (CLK_50),
    .I   (clk0));

  BUFG clkout3_buf
   (.O   (CLK_50_inv),
    .I   (clk180));



endmodule
