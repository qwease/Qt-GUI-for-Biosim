#!/usr/bin/gnuplot --persist

# Set the output format and size
set term png size 2000, 400
set output "./images/diversity.png"

# Set labels, title, and axis
set xlabel "Epoch"
set ylabel "Scaled Diversity"
set title "Diversity over Time"

# Set the y-range based on the expected scaled values
set yrange [ 0:1 ]



# Set grid
set grid

# Plot the data
plot "./logs/epoch-log.txt" using 1:3 with lines lw 2 linecolor "purple" title "Diversity"

set output
