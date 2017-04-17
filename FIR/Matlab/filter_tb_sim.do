onbreak resume
onerror resume
vsim -novopt work.filter_tb
add wave sim:/filter_tb/u_filter/clk
add wave sim:/filter_tb/u_filter/we
add wave sim:/filter_tb/u_filter/rst_n
add wave sim:/filter_tb/u_filter/filter_in
add wave sim:/filter_tb/u_filter/filter_out
add wave sim:/filter_tb/filter_out_ref
run -all
