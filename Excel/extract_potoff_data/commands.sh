#!/bin/bash

awk '{print $0 > "file" NR}' RS='TTT'  data.txt
litsat_fname_array=(IC4.mippesl-gcmc-potoff IC5.mippesl-gcmc-potoff NP.mippesl-gcmc-potoff IC6.mippesl-gcmc-potoff 3MP.mippesl-gcmc-potoff 22MB.mippesl-gcmc-potoff 23MB.mippesl-gcmc-potoff 2MH.mippesl-gcmc-potoff 3MH.mippesl-gcmc-potoff 3EP.mippesl-gcmc-potoff 22MP.mippesl-gcmc-potoff 23MP.mippesl-gcmc-potoff 24MP.mippesl-gcmc-potoff 33MP.mippesl-gcmc-potoff 223MB.mippesl-gcmc-potoff 2MHE.mippesl-gcmc-potoff 3MHE.mippesl-gcmc-potoff 4MHE.mippesl-gcmc-potoff 3EH.mippesl-gcmc-potoff 22MH.mippesl-gcmc-potoff 23MH.mippesl-gcmc-potoff 24MH.mippesl-gcmc-potoff 25MH.mippesl-gcmc-potoff 33MH.mippesl-gcmc-potoff 34MH.mippesl-gcmc-potoff 2M3EP.mippesl-gcmc-potoff 3M3EP.mippesl-gcmc-potoff 223MP.mippesl-gcmc-potoff IC8.mippesl-gcmc-potoff 233MP.mippesl-gcmc-potoff 234MP.mippesl-gcmc-potoff 2233MB.mippesl-gcmc-potoff IC4.mippe-gcmc-potoff IC5.mippe-gcmc-potoff NP.mippe-gcmc-potoff IC6.mippe-gcmc-potoff 3MP.mippe-gcmc-potoff 22MB.mippe-gcmc-potoff 23MB.mippe-gcmc-potoff 2MH.mippe-gcmc-potoff 3MH.mippe-gcmc-potoff 3EP.mippe-gcmc-potoff 22MP.mippe-gcmc-potoff 23MP.mippe-gcmc-potoff 24MP.mippe-gcmc-potoff 33MP.mippe-gcmc-potoff 223MB.mippe-gcmc-potoff 2MHE.mippe-gcmc-potoff 3MHE.mippe-gcmc-potoff 4MHE.mippe-gcmc-potoff 3EH.mippe-gcmc-potoff 22MH.mippe-gcmc-potoff 23MH.mippe-gcmc-potoff 24MH.mippe-gcmc-potoff 25MH.mippe-gcmc-potoff 33MH.mippe-gcmc-potoff 34MH.mippe-gcmc-potoff 2M3EP.mippe-gcmc-potoff 3M3EP.mippe-gcmc-potoff 223MP.mippe-gcmc-potoff IC8.mippe-gcmc-potoff 233MP.mippe-gcmc-potoff 234MP.mippe-gcmc-potoff 2233MB.mippe-gcmc-potoff IC4.trappe-gcmc-potoff IC5.trappe-gcmc-potoff NP.trappe-gcmc-potoff IC6.trappe-gcmc-potoff 3MP.trappe-gcmc-potoff 22MB.trappe-gcmc-potoff 23MB.trappe-gcmc-potoff 2MH.trappe-gcmc-potoff 3MH.trappe-gcmc-potoff 3EP.trappe-gcmc-potoff 22MP.trappe-gcmc-potoff 23MP.trappe-gcmc-potoff 24MP.trappe-gcmc-potoff 33MP.trappe-gcmc-potoff 223MB.trappe-gcmc-potoff 2MHE.trappe-gcmc-potoff 3MHE.trappe-gcmc-potoff 4MHE.trappe-gcmc-potoff 3EH.trappe-gcmc-potoff 22MH.trappe-gcmc-potoff 23MH.trappe-gcmc-potoff 24MH.trappe-gcmc-potoff 25MH.trappe-gcmc-potoff 33MH.trappe-gcmc-potoff 34MH.trappe-gcmc-potoff 2M3EP.trappe-gcmc-potoff 3M3EP.trappe-gcmc-potoff 223MP.trappe-gcmc-potoff IC8.trappe-gcmc-potoff 233MP.trappe-gcmc-potoff 234MP.trappe-gcmc-potoff 2233MB.trappe-gcmc-potoff IC4.nerd-gcmc-potoff IC5.nerd-gcmc-potoff NP.nerd-gcmc-potoff IC6.nerd-gcmc-potoff 3MP.nerd-gcmc-potoff 22MB.nerd-gcmc-potoff 23MB.nerd-gcmc-potoff 2MH.nerd-gcmc-potoff 3MH.nerd-gcmc-potoff 3EP.nerd-gcmc-potoff 22MP.nerd-gcmc-potoff 23MP.nerd-gcmc-potoff 24MP.nerd-gcmc-potoff 33MP.nerd-gcmc-potoff 223MB.nerd-gcmc-potoff 2MHE.nerd-gcmc-potoff 3MHE.nerd-gcmc-potoff 4MHE.nerd-gcmc-potoff 3EH.nerd-gcmc-potoff 22MH.nerd-gcmc-potoff 23MH.nerd-gcmc-potoff 24MH.nerd-gcmc-potoff 25MH.nerd-gcmc-potoff 33MH.nerd-gcmc-potoff 34MH.nerd-gcmc-potoff 2M3EP.nerd-gcmc-potoff 3M3EP.nerd-gcmc-potoff 223MP.nerd-gcmc-potoff IC8.nerd-gcmc-potoff 233MP.nerd-gcmc-potoff 234MP.nerd-gcmc-potoff 2233MB.nerd-gcmc-potoff)
for i in $(seq 2 1 129)
do
    mv file$i file$((i-1))
done

for i in $(seq 1 1 128)
do
    j=$((i-1))
    mv file${i} ${litsat_fname_array[j]}
    sed -i 1d ${litsat_fname_array[j]}
    sed -i '1i\T[K]	ρL[gcc]	    ρV[gcc]	    P[Mpa]	    Hvap[KJ/mol]	ρL+/-	ρV+/-	P+/-	Hvap+/-' ${litsat_fname_array[j]}
    head -n -1 ${litsat_fname_array[j]} > tmp 
    mv tmp ${litsat_fname_array[j]}
done
