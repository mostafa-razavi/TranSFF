#!/bin/bash
CD=${PWD}

Forcefiled_name="TraPPE-SWF"
molecules_array="IC4 IC5 IC6 23MB 2MH 25MH 34MH NP IC8 22MB 22MP 22MH 33MH"
para_file="$HOME/myProjects/GOMC/ITIC/TraPPE-SWF_branched-alkanes_CH3-3.723-101.68_CH2-3.993-51.28_CH1-4.709-12.74_CT-6.222-1.7/TraPPE-SWF_Alkanes_CH3-3.723-101.68_CH2-3.993-51.28_CH1-4.709-12.74_CT-6.222-1.7.par"
config_filename="FSWITCH_4M_rc1214_light.conf"
Nproc=26 #$(nproc)
select="all"
nblocks="5"
OutputName="nvt"
gomc_exe_address="$HOME/Git/GOMC/GOMC-FSHIFT2-SWF-HighPrecisionPDB-StartFrame/bin/GOMC_CPU_NVT"

#============Plots Settings=============
LitsatExt="trappe-gcmc"
LitsatLabel="TraPPE-GCMC"
ITIC_trhozures_filename="trhozures.res TraPPE.res"
ITIC_trhozures_label="$Forcefiled_name TraPPE"
trimZ="no-trimZ" 
trimU="yes-trimU"


#======================================
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
    bash $HOME/Git/TranSFF/Scripts/ITIC/plot_vle.sh ${molec} trhozures.res $Forcefiled_name "$LitsatExt" "$LitsatLabel"   # last two arguments (lit. extention and label) could be arrays
    bash $HOME/Git/TranSFF/Scripts/ITIC/plot_zures.sh ${molec} "$ITIC_trhozures_filename" "$ITIC_trhozures_label" $trimZ $trimU
    cd $CD
done