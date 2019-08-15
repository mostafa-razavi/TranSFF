#!/bin/bash
# This script plots (Z-1)/rho vs and TUres vs 1000/T plot side by side
# Example:
# bash ~/Git/TranSFF/Scripts/Plot_zu.sh 30.07 CassandraRdr.res target.res "Cassandra"

MW=$1
true_data_file=$2
mbar_file_name_tail_keyword=$3
true_data_label=$4

for i in *.$mbar_file_name_tail_keyword
do
	mbar_data_file="$i"
	output_figure_filename="${mbar_data_file}_${true_data_label}.png"
	python3.6 ~/Git/TranSFF/Scripts/plot_mbar_vs_true_data.py $MW $true_data_file $mbar_data_file $true_data_label $output_figure_filename
done