transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vcom -93 -work work {D:/Temp/FPGA_EPFL/PWM_module/hw/hdl/DE0_Nano_SoC_top_level.vhd}

