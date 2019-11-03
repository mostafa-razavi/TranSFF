#!bin/bash
# This script runs Test_MBAR_accuracy.sh for multiple folders
# Example:
# bash ~/Git/TranSFF/Scripts/Test_MBAR_accuracy_all.sh C12 2 s3.850e127-s4.000e60 "0.5336/547.99 0.6937/368.10 691.00/0.2135 691.00/0.5336 691.00/0.6937" SIG2

molecule=$1
nnbp=$2
reference_folder=$3
selected_itic_points=$4
marker_variation_title=$5
gomc_exe_address=$6

CD=${PWD}
rm -rf $CD/all.scores
rm -rf $CD/ALL.scores
echo "T_DSIM RHO_DSIM Z_DSIM Z_std_DSIM Ures_DSIM Ures_std_DSIM N_DSIM T_MABR RHO_MABR Z_MABR Z_std_MABR Ures_MABR Ures_std_MABR N_MABR Neff_MBAR SIG1 EPS1 SIG2 EPS2" >> $CD/ALL.scores

for i in s*/
do
    prediction_folder=${i::-1}
    bash $HOME/Git/TranSFF/Scripts/Test_MBAR_accuracy.sh ${molecule} ${nnbp} $reference_folder $prediction_folder "$selected_itic_points" $gomc_exe_address

    keyword="N1000_MBAR_${prediction_folder}"
    cd $keyword

    MW=$(grep "MW:" $HOME/Git/TranSFF/Molecules/${molecule}/${molecule}.itic | awk '{print $2}')
    scores=$(python3.6 $HOME/Git/TranSFF/Scripts/calc_trhozures_from_trhozures_data_dev.py $MW dsim.trhozures.res "${keyword}".trhozures.res 0.5 0.5)

    sig_eps_nnn=$(echo $prediction_folder | sed "s/-/ /g")
    sig_eps_nnn=$(echo $sig_eps_nnn | sed "s/s/ /g")
    sig_eps_nnn=$(echo $sig_eps_nnn | sed "s/e/ /g")

    echo ${sig_eps_nnn} $scores >> $CD/all.scores

    rm -rf nbp.temp
    for i in $(seq 1 1 5)
    do
        echo $sig_eps_nnn >> nbp.temp
    done
    sed -e "1d" dsim.trhozures.res > dsim.temp  # direct sim. results without header line 
    sed -e "1d" "${keyword}".trhozures.res > mbar.temp  # mbar results without header line 

    paste dsim.temp mbar.temp nbp.temp > all.temp

    cat all.temp >> $CD/ALL.scores
    rm *.temp
    cd $CD
done

sed -i "s/	/ /g" $CD/ALL.scores

#mark_array=["^", "<", "o", "x", "+", "s", "d", ">", "v", "p", "P", "*", "h", "H", "X"]
#color_array = ["k", "g", "b", "r", "c", "orange", "yello", "purple"]
python3.6 $HOME/Git/TranSFF/Scripts/plot_parity_mbar_vs_dsim.py $CD/ALL.scores parity.png $marker_variation_title "$selected_itic_points"