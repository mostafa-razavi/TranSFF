#!/bin/bash
molec=$1
ITIC_trhozures_filename=($2)
ITIC_trhozures_label=($3)
trimZ="$4"
trimU="$5"

PT=(6 6 6 6 6)
PC=(red blue green orange cyan)
OutFile="${molec}_zures.png"

i=-1
for filename in "${ITIC_trhozures_filename[@]}"
do
    i=$((i+1))
    if [ -e  "${filename}" ]; then ITIC_trhozures_address[i]="${filename}"; else ITIC_trhozures_address[i]="$HOME/Git/TranSFF/Data/${molec}/${filename}"; fi
done

for i in $(seq 0 1 10)
do
    if [ "${ITIC_trhozures_address[i]}" == "" ]; then ITIC_trhozures_address[i]="empty"; fi
done

REFPROP="empty"
REFPROP="$HOME/Git/TranSFF/Data/${molec}/REFPROP.res"


#======================Trim Plots=========================
T_IT=$(grep 'T_IT:' "$HOME/Git/TranSFF/Molecules/${molec}/${molec}.itic" | awk '{print $2}')
RHO_IT2=$(grep 'RHO_IT2:' "$HOME/Git/TranSFF/Molecules/${molec}/${molec}.itic" | awk '{print $2}')
i=-1
for filename in "${ITIC_trhozures_filename[@]}"
do
    i=$((i+1))    
    UresMaxIC[i]=$(sed '23q;d' "${ITIC_trhozures_address[i]}" | awk '{print $4}' )
    ZMinIT[i]=$(sed '16q;d' "${ITIC_trhozures_address[i]}" | awk '{print $3}' )
done

IFS=$'\n'
UresMaxIC=$(echo "${UresMaxIC[*]}" | sort -nr | head -n1)   
ZMinIT=$(echo "${ZMinIT[*]}" | sort -nr | tail -n1)
TUresMaxIC=$(echo "scale=4; $UresMaxIC*$T_IT*0.95" | bc )

if [ "$trimZ" == "yes-trimZ" ]; then
    Zm1rhoMinIC=$(echo "scale=4; ($ZMinIT-1)/$RHO_IT2*1.4" | bc )
else
    Zm1rhoMinIC=""
fi

if [ "$trimU" == "yes-trimU" ]; then
    TUresMaxIC=$(echo "scale=4; $UresMaxIC*$T_IT*0.95" | bc )
else
    TUresMaxIC=""
fi


#============Gnuplot Script Starts==========#
gnuplot -persist <<PLOT
set terminal pngcairo size 1500,750 enhanced font "Times,20"
set termoption dashe
set output '${OutFile}'
set autoscale x
set autoscale y

##########################################
############ Start multiplot #############
##########################################
set multiplot layout 1,2 rowsfirst


##########################################
# --- (Z-1)/rho vs rho
##########################################
set xlabel "{/Symbol r} [{g/cm^3}]" offset 0,0.6,0
set ylabel "(Z-1)/{/Symbol r} [{cm^3/g}]"
set key on inside left top
set yrange[$Zm1rhoMinIC:]

plot \
'$REFPROP' skip 1 u 2:((\$3-1)/\$2) with points lw 2 pt 4 ps 2 lc rgb "black" title "REFPROP" ,\
'${ITIC_trhozures_address[0]}' skip 1 u 2:((\$3-1)/\$2) with points lw 2 pt ${PT[0]} ps 2 lc rgb "${PC[0]}" title "  ${ITIC_trhozures_label[0]}" ,\
'${ITIC_trhozures_address[1]}' skip 1 u 2:((\$3-1)/\$2) with points lw 2 pt ${PT[1]} ps 2 lc rgb "${PC[1]}" title "  ${ITIC_trhozures_label[1]}" ,\
'${ITIC_trhozures_address[2]}' skip 1 u 2:((\$3-1)/\$2) with points lw 2 pt ${PT[2]} ps 2 lc rgb "${PC[2]}" title "  ${ITIC_trhozures_label[2]}" ,\
'${ITIC_trhozures_address[3]}' skip 1 u 2:((\$3-1)/\$2) with points lw 2 pt ${PT[3]} ps 2 lc rgb "${PC[3]}" title "  ${ITIC_trhozures_label[3]}" ,\
'${ITIC_trhozures_address[4]}' skip 1 u 2:((\$3-1)/\$2) with points lw 2 pt ${PT[4]} ps 2 lc rgb "${PC[4]}" title "  ${ITIC_trhozures_label[4]}" ,\

unset key
unset label
unset yrange

##########################################
# --- Tu^res vs 1000/T
##########################################
set xlabel "1000/T [K^{-1}]"
set ylabel 'T~U{.6\^} ^{res} [K]'
set key on inside right top
set yrange[:$TUresMaxIC]

plot \
'$REFPROP' skip 1 u (1000/\$1):(\$4*\$1) with points lw 2 pt 4 ps 2 lc rgb "black" title "REFPROP" ,\
'${ITIC_trhozures_address[0]}' skip 1 u (1000/\$1):(\$4*\$1) with points lw 2 pt ${PT[0]} ps 2 lc rgb "${PC[0]}" title "${ITIC_trhozures_label[0]}" ,\
'${ITIC_trhozures_address[1]}' skip 1 u (1000/\$1):(\$4*\$1) with points lw 2 pt ${PT[1]} ps 2 lc rgb "${PC[1]}" title "${ITIC_trhozures_label[1]}" ,\
'${ITIC_trhozures_address[2]}' skip 1 u (1000/\$1):(\$4*\$1) with points lw 2 pt ${PT[2]} ps 2 lc rgb "${PC[2]}" title "${ITIC_trhozures_label[2]}" ,\
'${ITIC_trhozures_address[3]}' skip 1 u (1000/\$1):(\$4*\$1) with points lw 2 pt ${PT[3]} ps 2 lc rgb "${PC[3]}" title "${ITIC_trhozures_label[3]}" ,\
'${ITIC_trhozures_address[4]}' skip 1 u (1000/\$1):(\$4*\$1) with points lw 2 pt ${PT[4]} ps 2 lc rgb "${PC[4]}" title "${ITIC_trhozures_label[4]}" ,\

unset key
unset label
unset yrange

##########################################
############ End multiplot ###############
##########################################
unset multiplot
unset label


PLOT
