#!/bin/bash
# This script plots either heatmap ("heatmap" option) or a (Z-1)/rho vs and TUres vs 1000/T plot ("zu" option)
# The folder where this script is run in should contain only .res files
heatmap_or_zu=$1

if [ "$heatmap_or_zu" == "heatmap" ]
then
	outfile=$2
	MW=$3
	z_wt=$4
	u_wt=$5	
	rm -rf $outfile
	plot_or_deviation="deviation"
elif  [ "$heatmap_or_zu" == "zu" ]
then
	MW=$2	
	plot_or_deviation="plot"
fi

for i in *.target.res
do
	cat $i | awk '{print $2, $3, $4, $5, $6}' > $i.temp
	score=$(python3.6 ~/Git/TranSFF/Scripts/Compare_MBAR_and_direct_sim.py $plot_or_deviation CassandraRdr.res $i.temp $i.png $MW $z_wt $u_wt)
	rm $i.temp

	if [ "$heatmap_or_zu" == "heatmap" ]
	then
		head=${i::-11}
		tail=${head:136}
		sig=${tail::-4} 
		eps=${tail:6}
		echo $sig $eps $score >> $outfile
	fi
done

if [ "$heatmap_or_zu" == "heatmap" ]
then
gnuplot -persist << PLOT
	set terminal pngcairo size 750,750 enhanced font "Times,20"
	set termoption dashe
	set output '${outfile}.png'
	set autoscale x
	set autoscale y

	set ylabel "{/Symbol s} [A]"
	set xlabel "{/Symbol e}/k_B [K]"

	#set palette rgbformula -7,2,8
	#set cbrange [0:100]

	set xtics 4 out
	set ytics 0.01 out

	set xrange[108:126]
	set yrange[3.73:3.77]

	plot '$outfile' using 2:1:3 with image
PLOT
fi