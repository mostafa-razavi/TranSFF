#!/bin/bash
molec=$1
ITICfile="$HOME/Git/TranSFF/Molecules/${molec}/${molec}.itic"


CASN=$(grep 'CASN:' ${ITICfile} | awk '{print $2}')
NAME=$(grep 'NAME:' ${ITICfile} | awk '{print $2}')
MW=$(grep 'MW:' ${ITICfile} | awk '{print $2}')
TC=$(grep 'TC:' ${ITICfile} | awk '{print $2}')
PC=$(grep 'PC:' ${ITICfile} | awk '{print $2}')
RhoC=$(grep 'RHOC:' ${ITICfile} | awk '{print $2}')
TIC5=$(grep 'T_IC5:' ${ITICfile} | awk '{print $2}')
DipprLow=$(echo "scale=10;$TIC5*0.95" | bc)
DipprHigh=$(echo "scale=10;$TC*0.98" | bc)
HighestT=$(grep 'T_HIGH:' ${ITICfile} | awk '{print $2}')



~/Git/DipprProp/DipprProp $CASN SVR "cm^3|gm" auto 100 "$molec.dipb2"
DipprSatProp $CASN $DipprLow 50 $DipprHigh "$molec.dipsat"

