#!bin/bash
CD=${PWD}

GOMC_datfile_L=$1
GOMC_datfile_V=$2
Nskip_lines=$3
Nblocks=$4
output_vle_file=$5

for T in GE/*
do
	cd $CD/$T 
	IFS='/' read -ra IX <<< "$T"
	T=${IX[-1]}

	GOMC_datfile_content=$(cat "$GOMC_datfile_L")
	is_simulation_finishes=$(grep -R "Info: Completed at:" gomc.log | awk '{print$2}')
	rm -rf Blocks_L.avg Blocks_V.avg Blocks_L.std Blocks_V.std
	if [ -e "$GOMC_datfile_L" ] && [ "$GOMC_datfile_content" != "" ] && [ "$is_simulation_finishes" == "Completed" ] ; then
		averages_L=$(python3.6 $HOME/Git/TranSFF/Scripts/GONvtRdr/GOGE_BlockAvg.py ${GOMC_datfile_L} ${GOMC_datfile_V} $Nskip_lines $Nblocks avg | head -n1)
		averages_V=$(python3.6 $HOME/Git/TranSFF/Scripts/GONvtRdr/GOGE_BlockAvg.py ${GOMC_datfile_L} ${GOMC_datfile_V} $Nskip_lines $Nblocks avg | tail -n1)

		stdev_L=$(python3.6 $HOME/Git/TranSFF/Scripts/GONvtRdr/GOGE_BlockAvg.py ${GOMC_datfile_L} ${GOMC_datfile_V} $Nskip_lines $Nblocks std | head -n1)
		stdev_V=$(python3.6 $HOME/Git/TranSFF/Scripts/GONvtRdr/GOGE_BlockAvg.py ${GOMC_datfile_L} ${GOMC_datfile_V} $Nskip_lines $Nblocks std | tail -n1)

		echo $T $averages_L > Blocks_L.avg
		echo $T $averages_V > Blocks_V.avg
		echo $T $stdev_L > Blocks_L.std
		echo $T $stdev_V > Blocks_V.std
	fi
done

cd $CD

tail -q -n1 $CD/GE/*/Blocks_L.avg > $CD/Blocks_L.avg
tail -q -n1 $CD/GE/*/Blocks_L.std > $CD/Blocks_L.std
tail -q -n1 $CD/GE/*/Blocks_V.avg > $CD/Blocks_V.avg
tail -q -n1 $CD/GE/*/Blocks_V.std > $CD/Blocks_V.std
sed -i '1i\T_K TOT_EN EN_INTER EN_TC EN_INTRA(B) EN_INTRA(NB) EN_ELECT EN_REAL EN_RECIP TOTAL_VIR PRESSURE TOT_MOL TOT_DENS HEAT_VAP' $CD/Blocks_L.avg
sed -i '1i\T_K TOT_EN EN_INTER EN_TC EN_INTRA(B) EN_INTRA(NB) EN_ELECT EN_REAL EN_RECIP TOTAL_VIR PRESSURE TOT_MOL TOT_DENS HEAT_VAP' $CD/Blocks_L.std
sed -i '1i\T_K TOT_EN EN_INTER EN_TC EN_INTRA(B) EN_INTRA(NB) EN_ELECT EN_REAL EN_RECIP TOTAL_VIR PRESSURE TOT_MOL TOT_DENS HEAT_VAP' $CD/Blocks_V.avg
sed -i '1i\T_K TOT_EN EN_INTER EN_TC EN_INTRA(B) EN_INTRA(NB) EN_ELECT EN_REAL EN_RECIP TOTAL_VIR PRESSURE TOT_MOL TOT_DENS HEAT_VAP' $CD/Blocks_V.std

MW=$(grep -R MW: $CD/Files/*.gemc | awk '{print$2}')
rm -rf ${output_vle_file}
python3.6 $HOME/Git/TranSFF/Scripts/GONvtRdr/GOGE_blocks_to_vle.py $MW $CD/Blocks_L.avg $CD/Blocks_L.std $CD/Blocks_V.avg $CD/Blocks_V.std >> $CD/${output_vle_file}