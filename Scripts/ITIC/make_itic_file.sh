#!/bin/bash
CD=${PWD}

nick_names=(C2E C3E 1C4E 1C5E 1C6E 1C7E 1C8E c-2C4E t-2C4E c-2C5E t-2C5E 13C4E 15C6E IC4E 2M13C4E)
nmolec=(600 400 300 240 200 170 150 300 300 240 240 300 200 300 240)
CASN_array=(74-85-1 115-07-1 106-98-9 109-67-1 592-41-6 592-76-7 111-66-0 590-18-1 624-64-6 627-20-3 646-04-8 106-99-0 592-42-7 115-11-7 78-79-5)
DipprID_array=(201 202 204 209 216 234 250 205 206 210 211 303 310 207 309)

i=-1
for CASN in ${CASN_array[@]}
do 
    i=$((i+1))
    echo ${nick_names[i]} $CASN ${nmolec[i]}
    mkdir $CD/${nick_names[i]}
    cd $CD/${nick_names[i]}
    bash ~/Git/Dippr/DipprExtractCASN.sh $CASN

    DipprID=${DipprID_array[i]}
    #DipprID=$(bash ~/Git/Dippr/DipprExtractCASN.sh $CASN)
    cp $HOME/Git/DipprFiles/gif/${DipprID}.gif ./${nick_names[i]}.gif
    cp $HOME/Git/DipprFiles/mol/S_${DipprID}.mol ./${nick_names[i]}.mol
    cp $HOME/Git/DipprFiles/pdb/S_${DipprID}.pdb ./${nick_names[i]}.pdb-aa
    bash $HOME/Git/N2C/C2PDB.sh $CASN
    mv $CASN.pdb ${nick_names[i]}.pdb
    rm $CASN.gif

    $HOME/Git/TranSFF/Scripts/ITIC/ITIC_pick $CASN
    mv RunITIC.inp ${nick_names[i]}.itic
done