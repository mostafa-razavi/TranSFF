#!/bin/bash
molec=$1
LitsatExt=($2) 
LitsatLabel=($3) 

OutFile="${molec}_vle.png"

Expsat="$HOME/Git/TranSFF/Expsat/${molec}.dipsat"
ExpsatLabel="DIPPR"

Litsat[0]="$HOME/Git/TranSFF/Litsat/${molec}.${LitsatExt[0]}"
Litsat[1]="$HOME/Git/TranSFF/Litsat/${molec}.${LitsatExt[1]}"
Litsat[2]="$HOME/Git/TranSFF/Litsat/${molec}.${LitsatExt[2]}"
Litsat[3]="$HOME/Git/TranSFF/Litsat/${molec}.${LitsatExt[3]}"
Litsat[4]="$HOME/Git/TranSFF/Litsat/${molec}.${LitsatExt[4]}"
Litsat[5]="$HOME/Git/TranSFF/Litsat/${molec}.${LitsatExt[5]}"

PT=(6 8 12 10 14 4)
PC=("red" "blue" "green" "orange" "cyan" "purple")

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
'${Litsat[0]}' skip 1 u (1000/\$1):(log(\$4)) with points pt ${PT[0]} ps 2 lw 3 lc rgb "${PC[0]}"  title "${LitsatLabel[0]}",\
'${Litsat[1]}' skip 1 u (1000/\$1):(log(\$4)) with points pt ${PT[1]} ps 2 lw 3 lc rgb "${PC[1]}"  title "${LitsatLabel[1]}",\
'${Litsat[2]}' skip 1 u (1000/\$1):(log(\$4)) with points pt ${PT[2]} ps 2 lw 3 lc rgb "${PC[2]}"  title "${LitsatLabel[2]}",\
'${Litsat[3]}' skip 1 u (1000/\$1):(log(\$4)) with points pt ${PT[3]} ps 2 lw 3 lc rgb "${PC[3]}"  title "${LitsatLabel[3]}",\
'${Litsat[4]}' skip 1 u (1000/\$1):(log(\$4)) with points pt ${PT[4]} ps 2 lw 3 lc rgb "${PC[4]}"  title "${LitsatLabel[4]}",\
'${Litsat[5]}' skip 1 u (1000/\$1):(log(\$4)) with points pt ${PT[5]} ps 2 lw 3 lc rgb "${PC[5]}"  title "${LitsatLabel[5]}",\
\

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
"${Litsat[0]}" skip 1 u 2:1 with points pt ${PT[0]} ps 2 lw 3 lc rgb "${PC[0]}" title "${LitsatLabel[0]}",\
"${Litsat[1]}" skip 1 u 2:1 with points pt ${PT[1]} ps 2 lw 3 lc rgb "${PC[1]}" title "${LitsatLabel[1]}",\
"${Litsat[2]}" skip 1 u 2:1 with points pt ${PT[2]} ps 2 lw 3 lc rgb "${PC[2]}" title "${LitsatLabel[2]}",\
"${Litsat[3]}" skip 1 u 2:1 with points pt ${PT[3]} ps 2 lw 3 lc rgb "${PC[3]}" title "${LitsatLabel[3]}",\
"${Litsat[4]}" skip 1 u 2:1 with points pt ${PT[4]} ps 2 lw 3 lc rgb "${PC[4]}" title "${LitsatLabel[4]}",\
"${Litsat[5]}" skip 1 u 2:1 with points pt ${PT[5]} ps 2 lw 3 lc rgb "${PC[5]}" title "${LitsatLabel[5]}",\
\
'${Litsat[0]}' skip 1 u 3:1 with points pt ${PT[0]} ps 2 lw 3 lc rgb "${PC[0]}"  notitle,\
'${Litsat[1]}' skip 1 u 3:1 with points pt ${PT[1]} ps 2 lw 3 lc rgb "${PC[1]}"  notitle,\
'${Litsat[2]}' skip 1 u 3:1 with points pt ${PT[2]} ps 2 lw 3 lc rgb "${PC[2]}"  notitle,\
'${Litsat[3]}' skip 1 u 3:1 with points pt ${PT[3]} ps 2 lw 3 lc rgb "${PC[3]}"  notitle,\
'${Litsat[4]}' skip 1 u 3:1 with points pt ${PT[4]} ps 2 lw 3 lc rgb "${PC[4]}"  notitle,\
'${Litsat[5]}' skip 1 u 3:1 with points pt ${PT[5]} ps 2 lw 3 lc rgb "${PC[5]}"  notitle,\

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
"$Expsat" u 1:4 smooth csplines with lines lt 1 lw 2 lc rgb "black" title "     ${ExpsatLabel}",\
\
"${Litsat[0]}" skip 1 u 1:5 with points pt ${PT[0]} ps 2 lw 3 lc rgb "${PC[0]}" title "     ${LitsatLabel[0]}",\
"${Litsat[1]}" skip 1 u 1:5 with points pt ${PT[1]} ps 2 lw 3 lc rgb "${PC[1]}" title "     ${LitsatLabel[1]}",\
"${Litsat[2]}" skip 1 u 1:5 with points pt ${PT[2]} ps 2 lw 3 lc rgb "${PC[2]}" title "     ${LitsatLabel[2]}",\
"${Litsat[3]}" skip 1 u 1:5 with points pt ${PT[3]} ps 2 lw 3 lc rgb "${PC[3]}" title "     ${LitsatLabel[3]}",\
"${Litsat[4]}" skip 1 u 1:5 with points pt ${PT[4]} ps 2 lw 3 lc rgb "${PC[4]}" title "     ${LitsatLabel[4]}",\
"${Litsat[5]}" skip 1 u 1:5 with points pt ${PT[5]} ps 2 lw 3 lc rgb "${PC[5]}" title "     ${LitsatLabel[5]}",\

unset key
unset label

##########################################
############ End multiplot ###############
##########################################
unset multiplot
unset label


PLOT
