#!/bin/bash
CD=${PWD}

molecules_array="C2 C4 C12"
Forcefiled_name="MiPPE"
para_file="$HOME/Git/TranSFF/Forcefields/MiPPE-GEN_Alkanes_3.740-118_4.03-62.par"
config_filename="VDW_BULK_2M.conf"
gomc_exe_address="$HOME/Git/GOMC/GOMC-FSHIFT2-SWF-HighPrecisionPDB-StartFrame/bin/GOMC_CPU_NVT"

nblocks="5"
Nproc=4 #$(nproc)
OutputName="nvt"

rm -rf ${CD}/COMMANDS.parallel
molecules_array=($molecules_array)
for molec in "${molecules_array[@]}"
do 
    mkdir ${CD}/${Forcefiled_name}_${molec}
    cp $HOME/Git/TranSFF/Molecules/${molec}/${molec}_Files.zip ${CD}/${Forcefiled_name}_${molec}
    cd ${CD}/${Forcefiled_name}_${molec}
    unzip ${molec}_Files.zip
    select_itic_points=$(cat $HOME/Git/TranSFF/Molecules/${molec}/${molec}_select5.trho)
    bash ~/Git/TranSFF/Scripts/RunITIC_GOMC_Parallel.sh $molec $para_file $config_filename "$select_itic_points" "$gomc_exe_address" no
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