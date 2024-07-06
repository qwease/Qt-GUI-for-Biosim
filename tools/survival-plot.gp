#!/usr/bin/gnuplot --persist

# Set the output format and size
set term png size 2000, 400
set output "./images/survivors.png"

# Set labels and title
set xlabel "Epoch"
set ylabel "Survivors"
set title "Survivors over Time"

set mxtics
set yrange [ 0:4000 ]
set key lmargin

# Set grid
set grid

ScaleSurvivors(s) = s

# Plot the data
plot "./logs/epoch-log.txt" using 1:2 with lines lw 2 linecolor "green" title "Survivors"
