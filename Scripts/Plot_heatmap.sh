#!/bin/bash
# This script plots a deviation heatmap as a function of sigma and epsilon. Deviation is calculated 
# by Compare_MBAR_and_direct_sim.py script with respect to true data (either direct simualtion or experimental data).
# z_wt and u_wt are given as command-line argument (any number between 0 and 1) where the sum should be 1.
# Last two arguments are sigma and epsilon increments on x and y axis of the heatmap.
# Examples:
# bash ~/Git/TranSFF/Scripts/Plot_heatmap.sh 30.07 target.res CassandraRdr.res 0.5Z_0.5U_all.txt 0.5 0.5 0.002 2

MW=$1
mbar_file_name_tail_keyword=$2
true_data_file=$3
outfile=$4
z_wt=$5
u_wt=$6	
sig_increment=$7
eps_increment=$8

if [ ! -e $outfile ]; then
	for i in *.$mbar_file_name_tail_keyword
	do
		cat $i | awk '{print $2, $3, $4, $5, $6}' > $i.temp
		plot_or_deviation="deviation"
		score=$(python3.6 ~/Git/TranSFF/Scripts/Compare_MBAR_and_direct_sim.py $plot_or_deviation $true_data_file $i.temp $i.png $MW $z_wt $u_wt)
		rm $i.temp
		
		# Obtain sig and epsilon values from file names
		IFS='_' read -ra temp_array <<< "$i"
		sig_eps_sting=${temp_array[-1]}
		sig_eps_sting=$(echo $sig_eps_sting | sed "s/.target.res//g")
		sig_eps_sting=$(echo $sig_eps_sting | sed "s/s/ /g")
		sig_eps_sting=$(echo $sig_eps_sting | sed "s/e/ /g")
		sig_eps_sting=($sig_eps_sting) 
		sig=${sig_eps_sting[0]}
		eps=${sig_eps_sting[1]}

		echo $sig $eps $score >> $outfile
	done
else
	echo "$outfile already exists. The data will be replotted anyway."
fi

min_sig=$(cut -d " " -f1 $outfile | sort -n | head -n1)
max_sig=$(cut -d " " -f1 $outfile | sort -n | tail -n1)
min_eps=$(cut -d " " -f2 $outfile | sort -n | head -n1)
max_eps=$(cut -d " " -f2 $outfile | sort -n | tail -n1)

if [ "$sig_increment" == "" ]; then
	sig_increment="0.001"
fi
if [ "$eps_increment" == "" ]; then
	eps_increment="1.0"
fi

gnuplot -persist << PLOT
	set terminal pngcairo size 750,750 enhanced font "Times,16"
	set termoption dashe
	set output '${outfile}.png'
	set autoscale x
	set autoscale y

	set ylabel "{/Symbol s} [A]"
	set xlabel "{/Symbol e}/k_B [K]"

	#set palette rgbformula -7,2,8
	#set cbrange [0:100]

	set xtics $eps_increment out
	set ytics $sig_increment out

	set xrange[$min_eps:$max_eps]
	set yrange[$min_sig:$max_sig]
	
	plot '$outfile' using 2:1:3 with image
	
	unset key
PLOT