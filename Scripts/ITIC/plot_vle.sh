#!/bin/bash
molec=$1
ITICraw=$2
SimsatLabel=$3
LitsatExt=($4) 
LitsatLabel=($5) 

ITICres="ITIC.out"
OutFile="${molec}_vle.png"

ITICfile="$HOME/Git/TranSFF/Molecules/${molec}/${molec}.itic"
Expsat="$HOME/Git/TranSFF/Expsat/${molec}.dipsat"
ExpsatLabel="DIPPR"

Litsat[0]="$HOME/Git/TranSFF/Litsat/${molec}.${LitsatExt[0]}"
Litsat[1]="$HOME/Git/TranSFF/Litsat/${molec}.${LitsatExt[1]}"

PT=(8 12 10)
PC=("blue" "green" "orange")

CASN=$(grep 'CASN:' ${ITICfile} | awk '{print $2}')
$HOME/Git/TranSFF/Scripts/ITIC/ITIC $CASN $ITICraw $ITICfile | tee $ITICres

keyword3="Saturation Info"
keyword4="Critical Properties"
sed -n "/$keyword3/,/$keyword4/{/$keyword3/b;/$keyword4/b;p}" $ITICres > ITIC.sat
Simsat="ITIC.sat"

#============Gnuplot Script Starts==========#
gnuplot -persist <<PLOT
set terminal pngcairo size 2250,750 enhanced font "Times,20"
set termoption dashe
set output '${OutFile}'
set autoscale x
set autoscale y

##########################################
############ Start multiplot #############
##########################################
set multiplot layout 1,3 rowsfirst


##########################################
# --- Psat
##########################################
set xlabel "1000/T [{K}^{-1}]"
set ylabel "{ln(P^{sat}/MPa)}"
set key on inside right top

plot \
"$Expsat" skip 1 u (1000/\$1):(log(\$2)) with lines lw 2 lc rgb "black"  title "${ExpsatLabel}",\
\
'${Litsat[1]}' skip 1 u (1000/\$1):(log(\$4)) with points pt ${PT[1]} ps 2 lw 3 lc rgb "${PC[1]}"  title "${LitsatLabel[1]}",\
'${Litsat[0]}' skip 1 u (1000/\$1):(log(\$4)) with points pt ${PT[0]} ps 2 lw 3 lc rgb "${PC[0]}"  title "${LitsatLabel[0]}",\
\
"$Simsat" skip 3 u (1000/\$3):(log(\$5)) with points pt 6 ps 2 lw 3 lc rgb "red" title "${SimsatLabel}",\

unset key
unset label

##########################################
# --- Binodal
##########################################
set xlabel "{/Symbol r} [{g/cm^3}]"
set ylabel "T [K]"
set key on inside center bottom
set xrange [-0.05:]

plot \
"$Expsat" u 3:1 smooth csplines with lines lt 1 lw 2 lc rgb "black" title "${ExpsatLabel}",\
\
"${Litsat[1]}" skip 1 u 2:1 with points pt ${PT[1]} ps 2 lw 3 lc rgb "${PC[1]}" title "${LitsatLabel[1]}",\
"${Litsat[0]}" skip 1 u 2:1 with points pt ${PT[0]} ps 2 lw 3 lc rgb "${PC[0]}" title "${LitsatLabel[0]}",\
\
'${Litsat[1]}' skip 1 u 3:1 with points pt ${PT[1]} ps 2 lw 3 lc rgb "${PC[1]}"  notitle,\
'${Litsat[0]}' skip 1 u 3:1 with points pt ${PT[0]} ps 2 lw 3 lc rgb "${PC[0]}"  notitle,\
\
"$Simsat" u 7:3	with points pt 6 ps 2 lw 3 lc rgb "red" title "${SimsatLabel}",\
"$Simsat" u 9:3	with points pt 6 ps 2 lw 3 lc rgb "red" notitle,\

unset key
unset label
unset xrange

##########################################
# --- Hvap
##########################################
set xlabel "{T} [{K}]"
set ylabel "{{/Symbol D}H_{v} [KJ/mol]}"
set key on inside left bottom

plot \
"$Expsat" u 1:4 smooth csplines with lines lt 1 lw 2 lc rgb "black" title "${ExpsatLabel}",\
\
"${Litsat[1]}" skip 1 u 1:5 with points pt ${PT[1]} ps 2 lw 3 lc rgb "${PC[1]}" title "${LitsatLabel[1]}",\
"${Litsat[0]}" skip 1 u 1:5 with points pt ${PT[0]} ps 2 lw 3 lc rgb "${PC[0]}" title "${LitsatLabel[0]}",\
\
"$Simsat" u 3:10	with points pt 6 ps 2 lw 3 lc rgb "red" title "${SimsatLabel}"

unset key
unset label

##########################################
############ End multiplot ###############
##########################################
unset multiplot
unset label


PLOT
