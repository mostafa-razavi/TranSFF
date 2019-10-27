#!/bin/bash
CD=${PWD}

molecules_array="C1 C2 C4 C8 C12 C16"
Forcefiled_name="TranSFF0"
para_file="$HOME/Git/TranSFF/Forcefields/TranSFF0_Alkanes.par"
config_filename="FSHIFT_BULK_4M.conf"

nblocks="5"
Nproc=$(nproc)
OutputName="nvt"

rm -rf ${CD}/COMMANDS.parallel
molecules_array=($molecules_array)
for molec in "${molecules_array[@]}"
do 
    mkdir ${CD}/${Forcefiled_name}_${molec}
    cp $HOME/Git/TranSFF/Molecules/${molec}/${molec}_Files.zip ${CD}/TranSFF0_${molec}
    cd ${CD}/TranSFF0_${molec}
    unzip ${molec}_Files.zip
    eval "bash ~/Git/TranSFF/Scripts/RunITIC_GOMC_Parallel.sh $molec $para_file $config_filename all no"
    cat COMMANDS.parallel >> ${CD}/COMMANDS.parallel
   rm ${molec}_Files.zip
    cd $CD
done

parallel --jobs $Nproc < COMMANDS.parallel 

config_file="$HOME/Git/TranSFF/Config/${config_filename}"
RunSteps=$(grep -R "RunSteps" $config_file | awk '{print $2}')
BlockAverageFreq=$(grep -R "BlockAverageFreq" $config_file | awk '{print $2}')
ndataskip=$(echo "($RunSteps/$BlockAverageFreq)/2" | bc )
for molec in "${molecules_array[@]}"
do 
    cd ${CD}/${Forcefiled_name}_${molec}
    bash $HOME/Git/TranSFF/Scripts/GONvtRdr/GONVT_BlockAvg.sh Blk_${OutputName}_BOX_0.dat $ndataskip $nblocks
    cd $CD
done