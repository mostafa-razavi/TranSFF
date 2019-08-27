#!bin/bash
CD=${PWD}

GOMC_datfile=$1
Nskip_lines=$2
Nblocks=$3


for T in I*/*/*
do
	cd $CD/$T 
	IFS='/' read -ra IX <<< "$T"
	IT_or_IC=${IX[-3]}
	rho_or_T1=${IX[-2]}
	rho_or_T2=${IX[-1]}

	if [ "$IT_or_IC" == "IC" ]; then
		rho=$rho_or_T1
		T=$rho_or_T2
	fi
	if [ "$IT_or_IC" == "IT" ]; then
		rho=$rho_or_T2
		T=$rho_or_T1
	fi
	GOMC_datfile_content=$(cat "$GOMC_datfile")
	if [ -e "$GOMC_datfile" ] && [ "$GOMC_datfile_content" != "" ]; then
		averages=$(python3.6 $HOME/Git/TranSFF/Scripts/GONvtRdr/GONVT_BlockAvg.py ${GOMC_datfile} $Nskip_lines $Nblocks avg) 
		stdev=$(python3.6 $HOME/Git/TranSFF/Scripts/GONvtRdr/GONVT_BlockAvg.py ${GOMC_datfile} $Nskip_lines $Nblocks std)
		echo $T $rho $averages > Blocks.avg
		echo $T $rho $stdev > Blocks.std
	fi
done

cd $CD

tail -q -n1 $CD/I*/*/*/Blocks.avg > $CD/Blocks.avg
tail -q -n1 $CD/I*/*/*/Blocks.std > $CD/Blocks.std
sed -i '1i\T_K RHO_GCC TOT_EN EN_INTER EN_TC EN_INTRA(B) EN_INTRA(NB) EN_ELECT EN_REAL EN_RECIP TOTAL_VIR PRESSURE TOT_MOL TOT_DENS ' $CD/Blocks.avg
sed -i '1i\T_K RHO_GCC TOT_EN EN_INTER EN_TC EN_INTRA(B) EN_INTRA(NB) EN_ELECT EN_REAL EN_RECIP TOTAL_VIR PRESSURE TOT_MOL TOT_DENS ' $CD/Blocks.std

MW=$(grep -R MW: $CD/Files/*.itic | awk '{print$2}')
rm -rf trhozures.res
python3.6 $HOME/Git/TranSFF/Scripts/GONvtRdr/GONVT_blocks_to_trhozures.py $MW intra $CD/Blocks.avg $CD/Blocks.std >> $CD/trhozures.res