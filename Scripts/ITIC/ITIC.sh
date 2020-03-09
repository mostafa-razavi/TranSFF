#!/bin/bash
molec=$1
ITICraw=$2
Outname=$3

ITICfile="$HOME/Git/TranSFF/Molecules/${molec}/${molec}.itic"

CASN=$(grep 'CASN:' ${ITICfile} | awk '{print $2}')
$HOME/Git/TranSFF/Scripts/ITIC/ITIC $CASN $ITICraw $ITICfile | tee "ITIC.res"

keyword3="Saturation Info"
keyword4="Critical Properties"
echo "T[K]	ρL[gcc]	    ρV[gcc]	    P[Mpa]	    Hvap[KJ/mol]	ρL+/-	ρV+/-	P+/-	Hvap+/-" > $Outname
sed -n "/$keyword3/,/$keyword4/{/$keyword3/b;/$keyword4/b;p}" ITIC.res > ITIC.sat
cat "ITIC.sat" | tail +4 | awk '{print $3,$7,$9,$5,$10}' >> $Outname
