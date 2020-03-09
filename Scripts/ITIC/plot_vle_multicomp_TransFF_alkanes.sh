# This script 
# Example:
OutFile="TransFF_C1-C2-C4-C8-C12-C16_vle.png"

molec[0]="C1"
molec[1]="C2"
molec[2]="C4"
molec[3]="C8"
molec[4]="C12"
molec[5]="C16"
molec[6]=""
molec[7]=""
molec[8]=""

Litsat2Label[0]="methane"
Litsat2Label[1]="ethane"
Litsat2Label[2]="n-btane"
Litsat2Label[3]="n-octane"
Litsat2Label[4]="n-dodecane"
Litsat2Label[5]="hexadecane"
Litsat2Label[6]=""
Litsat2Label[7]=""
Litsat2Label[8]=""

Expsat[0]="$HOME/Git/TranSFF/Expsat/${molec[0]}.dipsat"
Expsat[1]="$HOME/Git/TranSFF/Expsat/${molec[1]}.dipsat"
Expsat[2]="$HOME/Git/TranSFF/Expsat/${molec[2]}.dipsat"
Expsat[3]="$HOME/Git/TranSFF/Expsat/${molec[3]}.dipsat"
Expsat[4]="$HOME/Git/TranSFF/Expsat/${molec[4]}.dipsat"
Expsat[5]="$HOME/Git/TranSFF/Expsat/${molec[5]}.dipsat"
Expsat[6]="$HOME/Git/TranSFF/Expsat/${molec[6]}.dipsat"
Expsat[7]="$HOME/Git/TranSFF/Expsat/${molec[7]}.dipsat"
Expsat[8]="$HOME/Git/TranSFF/Expsat/${molec[8]}.dipsat" 

ExpsatLabel[0]=""
ExpsatLabel[1]=""
ExpsatLabel[2]=""
ExpsatLabel[3]=""
ExpsatLabel[4]=""
ExpsatLabel[5]=""
ExpsatLabel[6]=""
ExpsatLabel[7]=""
ExpsatLabel[8]=""

Litsat1[0]="$HOME/Git/TranSFF/Litsat/${molec[0]}.trappe-itic-razavi"
Litsat1[1]="$HOME/Git/TranSFF/Litsat/${molec[1]}.trappe-itic-razavi"
Litsat1[2]="$HOME/Git/TranSFF/Litsat/${molec[2]}.trappe-itic-razavi"
Litsat1[3]="$HOME/Git/TranSFF/Litsat/${molec[3]}.trappe-itic-razavi"
Litsat1[4]="$HOME/Git/TranSFF/Litsat/${molec[4]}.trappe-itic-razavi"
Litsat1[5]="$HOME/Git/TranSFF/Litsat/${molec[5]}.trappe-itic-razavi"
Litsat1[6]="$HOME/Git/TranSFF/Litsat/${molec[6]}.trappe-itic-razavi"
Litsat1[7]="$HOME/Git/TranSFF/Litsat/${molec[7]}.trappe-itic-razavi"
Litsat1[8]="$HOME/Git/TranSFF/Litsat/${molec[8]}.trappe-itic-razavi"

Litsat1Label[0]=""
Litsat1Label[1]=""
Litsat1Label[2]=""
Litsat1Label[3]=""
Litsat1Label[4]=""
Litsat1Label[5]=""
Litsat1Label[6]=""
Litsat1Label[7]=""
Litsat1Label[8]=""

Litsat2[0]="$HOME/Git/TranSFF/Litsat/${molec[0]}.transff-itic-razavi"
Litsat2[1]="$HOME/Git/TranSFF/Litsat/${molec[1]}.transff-itic-razavi"
Litsat2[2]="$HOME/Git/TranSFF/Litsat/${molec[2]}.transff-itic-razavi"
Litsat2[3]="$HOME/Git/TranSFF/Litsat/${molec[3]}.transff-itic-razavi"
Litsat2[4]="$HOME/Git/TranSFF/Litsat/${molec[4]}.transff-itic-razavi"
Litsat2[5]="$HOME/Git/TranSFF/Litsat/${molec[5]}.transff-itic-razavi"
Litsat2[6]="$HOME/Git/TranSFF/Litsat/${molec[6]}.transff-itic-razavi"
Litsat2[7]="$HOME/Git/TranSFF/Litsat/${molec[7]}.transff-itic-razavi"
Litsat2[8]="$HOME/Git/TranSFF/Litsat/${molec[8]}.transff-itic-razavi"



PT1=(6 4 8  10 12 14 16 18 1 2 3)
PT2=(6 4 8  10 12 14 16 18 1 2 3)

PS1=(2 2 2 2 2 2 2 2 2 2 2 2)
PS2=(2 2 2 2 2 2 2 2 2 2 2 2)

PC1=("black" "black" "black" "black" "black" "black" "black" "black" "black" )
PC2=("blue" "red" "green" "orange" "magenta" "purple" "cyan" "purple" "black")


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
set key on inside right bottom

plot \
"${Expsat[0]}" skip 1 u (1000/\$1):(log(\$2)) with lines lw 2 lc rgb "black"  title "${ExpsatLabel[0]}",\
"${Expsat[1]}" skip 1 u (1000/\$1):(log(\$2)) with lines lw 2 lc rgb "black"  notitle,\
"${Expsat[2]}" skip 1 u (1000/\$1):(log(\$2)) with lines lw 2 lc rgb "black"  notitle,\
"${Expsat[3]}" skip 1 u (1000/\$1):(log(\$2)) with lines lw 2 lc rgb "black"  notitle,\
"${Expsat[4]}" skip 1 u (1000/\$1):(log(\$2)) with lines lw 2 lc rgb "black"  notitle,\
"${Expsat[5]}" skip 1 u (1000/\$1):(log(\$2)) with lines lw 2 lc rgb "black"  notitle,\
"${Expsat[6]}" skip 1 u (1000/\$1):(log(\$2)) with lines lw 2 lc rgb "black"  notitle,\
"${Expsat[7]}" skip 1 u (1000/\$1):(log(\$2)) with lines lw 2 lc rgb "black"  notitle,\
"${Expsat[8]}" skip 1 u (1000/\$1):(log(\$2)) with lines lw 2 lc rgb "black"  notitle,\
\
'${Litsat1[0]}' skip 1 u (1000/\$1):(log(\$4)) with points pt ${PT1[0]} ps ${PS1[0]} lw 3 lc rgb "${PC1[0]}"  title "${Litsat1Label[0]}",\
'${Litsat1[1]}' skip 1 u (1000/\$1):(log(\$4)) with points pt ${PT1[1]} ps ${PS1[1]} lw 3 lc rgb "${PC1[1]}"  title "${Litsat1Label[1]}",\
'${Litsat1[2]}' skip 1 u (1000/\$1):(log(\$4)) with points pt ${PT1[2]} ps ${PS1[2]} lw 3 lc rgb "${PC1[2]}"  title "${Litsat1Label[2]}",\
'${Litsat1[3]}' skip 1 u (1000/\$1):(log(\$4)) with points pt ${PT1[3]} ps ${PS1[3]} lw 3 lc rgb "${PC1[3]}"  title "${Litsat1Label[3]}",\
'${Litsat1[4]}' skip 1 u (1000/\$1):(log(\$4)) with points pt ${PT1[4]} ps ${PS1[4]} lw 3 lc rgb "${PC1[4]}"  title "${Litsat1Label[4]}",\
'${Litsat1[5]}' skip 1 u (1000/\$1):(log(\$4)) with points pt ${PT1[5]} ps ${PS1[5]} lw 3 lc rgb "${PC1[5]}"  title "${Litsat1Label[5]}",\
'${Litsat1[6]}' skip 1 u (1000/\$1):(log(\$4)) with points pt ${PT1[6]} ps ${PS1[6]} lw 3 lc rgb "${PC1[6]}"  title "${Litsat1Label[6]}",\
'${Litsat1[7]}' skip 1 u (1000/\$1):(log(\$4)) with points pt ${PT1[7]} ps ${PS1[7]} lw 3 lc rgb "${PC1[7]}"  title "${Litsat1Label[7]}",\
'${Litsat1[8]}' skip 1 u (1000/\$1):(log(\$4)) with points pt ${PT1[8]} ps ${PS1[8]} lw 3 lc rgb "${PC1[8]}"  title "${Litsat1Label[8]}",\
\
'${Litsat2[0]}' skip 1 u (1000/\$1):(log(\$4)) with points pt ${PT1[0]} ps ${PS2[0]} lw 3 lc rgb "${PC2[0]}"  title "${Litsat2Label[0]}",\
'${Litsat2[1]}' skip 1 u (1000/\$1):(log(\$4)) with points pt ${PT1[1]} ps ${PS2[1]} lw 3 lc rgb "${PC2[1]}"  title "${Litsat2Label[1]}",\
'${Litsat2[2]}' skip 1 u (1000/\$1):(log(\$4)) with points pt ${PT1[2]} ps ${PS2[2]} lw 3 lc rgb "${PC2[2]}"  title "${Litsat2Label[2]}",\
'${Litsat2[3]}' skip 1 u (1000/\$1):(log(\$4)) with points pt ${PT1[3]} ps ${PS2[3]} lw 3 lc rgb "${PC2[3]}"  title "${Litsat2Label[3]}",\
'${Litsat2[4]}' skip 1 u (1000/\$1):(log(\$4)) with points pt ${PT1[4]} ps ${PS2[4]} lw 3 lc rgb "${PC2[4]}"  title "${Litsat2Label[4]}",\
'${Litsat2[5]}' skip 1 u (1000/\$1):(log(\$4)) with points pt ${PT1[5]} ps ${PS2[5]} lw 3 lc rgb "${PC2[5]}"  title "${Litsat2Label[5]}",\
'${Litsat2[6]}' skip 1 u (1000/\$1):(log(\$4)) with points pt ${PT1[6]} ps ${PS2[6]} lw 3 lc rgb "${PC2[6]}"  title "${Litsat2Label[6]}",\
'${Litsat2[7]}' skip 1 u (1000/\$1):(log(\$4)) with points pt ${PT1[7]} ps ${PS2[7]} lw 3 lc rgb "${PC2[7]}"  title "${Litsat2Label[7]}",\
'${Litsat2[8]}' skip 1 u (1000/\$1):(log(\$4)) with points pt ${PT1[8]} ps ${PS2[8]} lw 3 lc rgb "${PC2[8]}"  title "${Litsat2Label[8]}",\

unset key
unset label

##########################################
# --- Binodal
##########################################
set xlabel "{/Symbol r} [{g/cm^3}]"
set ylabel "T [K]"
#set key on inside center bottom
#set xrange [-0.05:]

plot \
"${Expsat[0]}" u 3:1 smooth csplines with lines lt 1 lw 2 lc rgb "black" title "${ExpsatLabel[0]}",\
"${Expsat[1]}" u 3:1 smooth csplines with lines lt 1 lw 2 lc rgb "black" notitle,\
"${Expsat[2]}" u 3:1 smooth csplines with lines lt 1 lw 2 lc rgb "black" notitle,\
"${Expsat[3]}" u 3:1 smooth csplines with lines lt 1 lw 2 lc rgb "black" notitle,\
"${Expsat[4]}" u 3:1 smooth csplines with lines lt 1 lw 2 lc rgb "black" notitle,\
"${Expsat[5]}" u 3:1 smooth csplines with lines lt 1 lw 2 lc rgb "black" notitle,\
"${Expsat[6]}" u 3:1 smooth csplines with lines lt 1 lw 2 lc rgb "black" notitle,\
"${Expsat[7]}" u 3:1 smooth csplines with lines lt 1 lw 2 lc rgb "black" notitle,\
"${Expsat[8]}" u 3:1 smooth csplines with lines lt 1 lw 2 lc rgb "black" notitle,\
\
"${Litsat1[0]}" skip 1 u 2:1 with points pt ${PT1[0]} ps ${PS1[0]} lw 3 lc rgb "${PC1[0]}" title "${Litsat1Label[0]}",\
"${Litsat1[1]}" skip 1 u 2:1 with points pt ${PT1[1]} ps ${PS1[1]} lw 3 lc rgb "${PC1[1]}" title "${Litsat1Label[1]}",\
"${Litsat1[2]}" skip 1 u 2:1 with points pt ${PT1[2]} ps ${PS1[2]} lw 3 lc rgb "${PC1[2]}" title "${Litsat1Label[2]}",\
"${Litsat1[3]}" skip 1 u 2:1 with points pt ${PT1[3]} ps ${PS1[3]} lw 3 lc rgb "${PC1[3]}" title "${Litsat1Label[3]}",\
"${Litsat1[4]}" skip 1 u 2:1 with points pt ${PT1[4]} ps ${PS1[4]} lw 3 lc rgb "${PC1[4]}" title "${Litsat1Label[4]}",\
"${Litsat1[5]}" skip 1 u 2:1 with points pt ${PT1[5]} ps ${PS1[5]} lw 3 lc rgb "${PC1[5]}" title "${Litsat1Label[5]}",\
"${Litsat1[6]}" skip 1 u 2:1 with points pt ${PT1[6]} ps ${PS1[6]} lw 3 lc rgb "${PC1[6]}" title "${Litsat1Label[6]}",\
"${Litsat1[7]}" skip 1 u 2:1 with points pt ${PT1[7]} ps ${PS1[7]} lw 3 lc rgb "${PC1[7]}" title "${Litsat1Label[7]}",\
"${Litsat1[8]}" skip 1 u 2:1 with points pt ${PT1[8]} ps ${PS1[8]} lw 3 lc rgb "${PC1[8]}" title "${Litsat1Label[8]}",\
\
"${Litsat2[0]}" skip 1 u 2:1 with points pt ${PT1[0]} ps ${PS2[0]} lw 3 lc rgb "${PC2[0]}" title "${Litsat2Label[0]}",\
"${Litsat2[1]}" skip 1 u 2:1 with points pt ${PT1[1]} ps ${PS2[1]} lw 3 lc rgb "${PC2[1]}" title "${Litsat2Label[1]}",\
"${Litsat2[2]}" skip 1 u 2:1 with points pt ${PT1[2]} ps ${PS2[2]} lw 3 lc rgb "${PC2[2]}" title "${Litsat2Label[2]}",\
"${Litsat2[3]}" skip 1 u 2:1 with points pt ${PT1[3]} ps ${PS2[3]} lw 3 lc rgb "${PC2[3]}" title "${Litsat2Label[3]}",\
"${Litsat2[4]}" skip 1 u 2:1 with points pt ${PT1[4]} ps ${PS2[4]} lw 3 lc rgb "${PC2[4]}" title "${Litsat2Label[4]}",\
"${Litsat2[5]}" skip 1 u 2:1 with points pt ${PT1[5]} ps ${PS2[5]} lw 3 lc rgb "${PC2[5]}" title "${Litsat2Label[5]}",\
"${Litsat2[6]}" skip 1 u 2:1 with points pt ${PT1[6]} ps ${PS2[6]} lw 3 lc rgb "${PC2[6]}" title "${Litsat2Label[6]}",\
"${Litsat2[7]}" skip 1 u 2:1 with points pt ${PT1[7]} ps ${PS2[7]} lw 3 lc rgb "${PC2[7]}" title "${Litsat2Label[7]}",\
"${Litsat2[8]}" skip 1 u 2:1 with points pt ${PT1[8]} ps ${PS2[8]} lw 3 lc rgb "${PC2[8]}" title "${Litsat2Label[8]}",\


unset key
unset label
unset xrange

##########################################
# --- Hvap
##########################################
set xlabel "{T} [{K}]"
set ylabel "{{/Symbol D}H_{v} [KJ/mol]}"
#set key on inside left bottom

plot \
"${Expsat[0]}" u 1:4 smooth csplines with lines lt 1 lw 2 lc rgb "black" title "     ${ExpsatLabel[0]}",\
"${Expsat[1]}" u 1:4 smooth csplines with lines lt 1 lw 2 lc rgb "black" notitle,\
"${Expsat[2]}" u 1:4 smooth csplines with lines lt 1 lw 2 lc rgb "black" notitle,\
"${Expsat[3]}" u 1:4 smooth csplines with lines lt 1 lw 2 lc rgb "black" notitle,\
"${Expsat[4]}" u 1:4 smooth csplines with lines lt 1 lw 2 lc rgb "black" notitle,\
"${Expsat[5]}" u 1:4 smooth csplines with lines lt 1 lw 2 lc rgb "black" notitle,\
"${Expsat[6]}" u 1:4 smooth csplines with lines lt 1 lw 2 lc rgb "black" notitle,\
"${Expsat[7]}" u 1:4 smooth csplines with lines lt 1 lw 2 lc rgb "black" notitle,\
"${Expsat[8]}" u 1:4 smooth csplines with lines lt 1 lw 2 lc rgb "black" notitle,\
\
"${Litsat1[0]}" skip 1 u 1:5 with points pt ${PT1[0]} ps ${PS1[0]} lw 3 lc rgb "${PC1[0]}" title "     ${Litsat1Label[0]}",\
"${Litsat1[1]}" skip 1 u 1:5 with points pt ${PT1[1]} ps ${PS1[1]} lw 3 lc rgb "${PC1[1]}" title "     ${Litsat1Label[1]}",\
"${Litsat1[2]}" skip 1 u 1:5 with points pt ${PT1[2]} ps ${PS1[2]} lw 3 lc rgb "${PC1[2]}" title "     ${Litsat1Label[2]}",\
"${Litsat1[3]}" skip 1 u 1:5 with points pt ${PT1[3]} ps ${PS1[3]} lw 3 lc rgb "${PC1[3]}" title "     ${Litsat1Label[3]}",\
"${Litsat1[4]}" skip 1 u 1:5 with points pt ${PT1[4]} ps ${PS1[4]} lw 3 lc rgb "${PC1[4]}" title "     ${Litsat1Label[4]}",\
"${Litsat1[5]}" skip 1 u 1:5 with points pt ${PT1[5]} ps ${PS1[5]} lw 3 lc rgb "${PC1[5]}" title "     ${Litsat1Label[5]}",\
"${Litsat1[6]}" skip 1 u 1:5 with points pt ${PT1[6]} ps ${PS1[6]} lw 3 lc rgb "${PC1[6]}" title "     ${Litsat1Label[6]}",\
"${Litsat1[7]}" skip 1 u 1:5 with points pt ${PT1[7]} ps ${PS1[7]} lw 3 lc rgb "${PC1[7]}" title "     ${Litsat1Label[7]}",\
"${Litsat1[8]}" skip 1 u 1:5 with points pt ${PT1[8]} ps ${PS1[8]} lw 3 lc rgb "${PC1[8]}" title "     ${Litsat1Label[8]}",\
\
"${Litsat2[0]}" skip 1 u 1:5 with points pt ${PT1[0]} ps ${PS2[0]} lw 3 lc rgb "${PC2[0]}" title "     ${Litsat2Label[0]}",\
"${Litsat2[1]}" skip 1 u 1:5 with points pt ${PT1[1]} ps ${PS2[1]} lw 3 lc rgb "${PC2[1]}" title "     ${Litsat2Label[1]}",\
"${Litsat2[2]}" skip 1 u 1:5 with points pt ${PT1[2]} ps ${PS2[2]} lw 3 lc rgb "${PC2[2]}" title "     ${Litsat2Label[2]}",\
"${Litsat2[3]}" skip 1 u 1:5 with points pt ${PT1[3]} ps ${PS2[3]} lw 3 lc rgb "${PC2[3]}" title "     ${Litsat2Label[3]}",\
"${Litsat2[4]}" skip 1 u 1:5 with points pt ${PT1[4]} ps ${PS2[4]} lw 3 lc rgb "${PC2[4]}" title "     ${Litsat2Label[4]}",\
"${Litsat2[5]}" skip 1 u 1:5 with points pt ${PT1[5]} ps ${PS2[5]} lw 3 lc rgb "${PC2[5]}" title "     ${Litsat2Label[5]}",\
"${Litsat2[6]}" skip 1 u 1:5 with points pt ${PT1[6]} ps ${PS2[6]} lw 3 lc rgb "${PC2[6]}" title "     ${Litsat2Label[6]}",\
"${Litsat2[7]}" skip 1 u 1:5 with points pt ${PT1[7]} ps ${PS2[7]} lw 3 lc rgb "${PC2[7]}" title "     ${Litsat2Label[7]}",\
"${Litsat2[8]}" skip 1 u 1:5 with points pt ${PT1[8]} ps ${PS2[8]} lw 3 lc rgb "${PC2[8]}" title "     ${Litsat2Label[8]}",\

unset key
unset label

##########################################
############ End multiplot ###############
##########################################
unset multiplot
unset label


PLOT
