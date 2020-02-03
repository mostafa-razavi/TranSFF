#!/bin/bash
CD=${PWD}

molecules_array="C2 C3 C4"
Forcefiled_name="MiPPE"
para_file="$HOME/Git/TranSFF/Forcefields/MiPPE-GEN_Alkanes.par"
config_filename="VDW_6M.conf"
gomc_exe_address="$HOME/Git/GOMC/GOMC-FSHIFT2-SWF-HighPrecisionPDB-StartFrame/bin/GOMC_CPU_NVT"
select="all"
nblocks="5"
Nproc=8 #$(nproc)
OutputName="nvt"

rm -rf ${CD}/COMMANDS.parallel
molecules_array=($molecules_array)
for molec in "${molecules_array[@]}"
do 
    mkdir ${CD}/${molec}
    cp $HOME/Git/TranSFF/Molecules/${molec}/${molec}_Files.zip ${CD}/${molec}
    cd ${CD}/${molec}
    unzip ${molec}_Files.zip
    if [ "$select" == "all" ]; then
        select_itic_points="all"
    else
        select_itic_points=$(cat $HOME/Git/TranSFF/Molecules/${molec}/${molec}_${select}.trho)
    fi
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
    cd ${CD}/${molec}
    bash $HOME/Git/TranSFF/Scripts/GONvtRdr/GONVT_BlockAvg.sh Blk_${OutputName}_BOX_0.dat $ndataskip $nblocks
    bash $HOME/Git/TranSFF/Scripts/GONvtRdr/GONvtRdr.sh nvt.inp ${OutputName}
    bash $HOME/Git/TranSFF/Scripts/ITIC/plot_coexistence.sh ${molec} trhozures.res $Forcefiled_name "mippe-gcmc" "MiPPE-GCMC"   # last two arguments (lit. extention and label) could be arrays
    cd $CD
done