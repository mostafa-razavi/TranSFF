#!/bin/bash

ITICres=$1 #"ITIC.out"
Outname=$2
rm -rf $Outname
keyword3="Saturation Info"
keyword4="Critical Properties"
sed -n "/$keyword3/,/$keyword4/{/$keyword3/b;/$keyword4/b;p}" $ITICres > "ITIC.sat"
echo "T[K]	ρL[gcc]	    ρV[gcc]	    P[Mpa]	    Hvap[KJ/mol]	ρL+/-	ρV+/-	P+/-	Hvap+/-" > $Outname
cat "ITIC.sat" | tail +4 | awk '{print $3,$7,$9,$5,$10}' >> $Outname
