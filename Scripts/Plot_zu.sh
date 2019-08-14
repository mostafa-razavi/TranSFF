#!/bin/bash
# This script plots (Z-1)/rho vs and TUres vs 1000/T plot side by side
# Example:
# bash ~/Git/TranSFF/Scripts/Plot_zu.sh 30.07 target.res CassandraRdr.res

MW=$1
mbar_file_name_tail_keyword=$2
true_data_file=$3

for i in *.$mbar_file_name_tail_keyword
do
	plot_or_deviation="plot"
	python3.6 ~/Git/TranSFF/Scripts/Compare_MBAR_and_direct_sim.py $plot_or_deviation $true_data_file $true_label $i $i.png $MW
done