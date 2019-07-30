#!bin/bash
CD=${PWD}
Input_file_name=$1
Output_keyword=$2

for T in I*/*/*
do
	cd $CD/$T 
	
	~/Git/TranSFF/Scripts/GONvtRdr/GONvtRdr Blk_${Output_keyword}_BOX_0.dat $Input_file_name ${Output_keyword}_merged.psf GONvtRdr.results
done
tail -q -n1 $CD/I*/*/*/GONvtRdr.results > $CD/GONvtRdr.res
sed -i '1i\     T(K)  rho(gcc)    P(atm)         Z      Zstd  ePot(kcal/mol)  eMol(kcal/mol)  eVdw(kcal/mol)  IVdw(kcal/mol)        RunSteps         EqSteps nMolec' $CD/GONvtRdr.res