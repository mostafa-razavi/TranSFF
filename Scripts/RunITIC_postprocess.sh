#!/bin/bash
# This script obtain the block averages of
#
# Example:
# bash ~/Git/TranSFF/Scripts/RunITIC_postprocess.sh C12 FSHIFT_BULK_LONG.conf nvt 5 REFPROP_select5.res REFPROP dsim.png

molec_name=$1
config_filename=$2 
OutputName=$3 
nblocks=$4 
true_data_file_name=$5 
true_data_file_label=$6
png_output=$7

config_file="$HOME/Git/TranSFF/Scripts/${config_filename}"
RunSteps=$(grep -R "RunSteps" $config_file | awk '{print $2}')
BlockAverageFreq=$(grep -R "BlockAverageFreq" $config_file | awk '{print $2}')
ndataskip=$(echo "($RunSteps/$BlockAverageFreq)/2" | bc )
bash $HOME/Git/TranSFF/Scripts/GONvtRdr/GONVT_BlockAvg.sh Blk_${OutputName}_BOX_0.dat $ndataskip $nblocks

MW=$(grep "MW:" $HOME/Git/TranSFF/Molecules/${molec_name}/${molec_name}.itic | awk '{print $2}')
python3.6 $HOME/Git/TranSFF/Scripts/plot_sim_vs_true_data.py $MW $HOME/Git/TranSFF/Data/${molec_name}/$true_data_file_name $true_data_file_label $png_output trhozures.res

