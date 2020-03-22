# This script generates ITIC directories for GOMC simulation
# Run this script with arguments:
#
#	gomc_input_file_replacements=( gomc_input_file_name Restart parameter_file Potential LRC Rcut PressureCalc RunSteps EqSteps AdjSteps CoordinatesFreq RestartFreq ConsoleFreq BlockAverageFreq OutputName )
#	bash MakeITIC_GOMC.sh ITIC_file_name "${gomc_input_file_replacements[@]}"
#
# Or without arguments:
#
#   bash MakeITIC_GOMC.sh
#
# S. Mostafa Razavi (sr87@zips.uakron.edu)



#!bin/bash
set -e

if [ "$1" == "" ]	# If the script is run with no arguments, it's assumed that all the necessary files are in Files directory, and the simulation command values are set manually below:
then
	ITICinp=$(ls Files/*.itic)
	gomc_input_file_name="nvt.inp"
	
	Restart="false"
	parameter_file=$(basename -- "$(ls Files/*.par)")
	Potential="VDW"
	LRC="true"
	Rcut="12"
	RcutFactor="3.0"
	Rswitch="10.0"
	PressureCalc="1000"
	RunSteps="10000000"
	EqSteps="500000"
	AdjSteps="1000"
	CoordinatesFreq="100000"
	RestartFreq="1000000"
	ConsoleFreq="1000"
	BlockAverageFreq="1000"
	OutputName="out"	

else	# If the script is called with at least one arguments, it is assumed that all other arguments are also provided.

	ITICinp=$1; shift
	gomc_input_file_replacements=( "$@" )

	gomc_input_file_name="${gomc_input_file_replacements[0]}"
	Restart="${gomc_input_file_replacements[1]}"
	parameter_file="${gomc_input_file_replacements[2]}"
	Potential="${gomc_input_file_replacements[3]}"
	LRC="${gomc_input_file_replacements[4]}"
	Rcut="${gomc_input_file_replacements[5]}"
	RcutFactor="${gomc_input_file_replacements[6]}"
	Rswitch="${gomc_input_file_replacements[7]}"
	PressureCalc="${gomc_input_file_replacements[8]}"
	RunSteps="${gomc_input_file_replacements[9]}"
	EqSteps="${gomc_input_file_replacements[10]}"
	AdjSteps="${gomc_input_file_replacements[11]}"
	CoordinatesFreq="${gomc_input_file_replacements[12]}"
	RestartFreq="${gomc_input_file_replacements[13]}"
	ConsoleFreq="${gomc_input_file_replacements[14]}"
	BlockAverageFreq="${gomc_input_file_replacements[15]}"
	OutputName="${gomc_input_file_replacements[16]}"
fi
#========Isochores Settings=================

Tic1=$(grep "T_IC1:" ${ITICinp} | awk '{ $1="";print $0}'); Tic1=($Tic1)
Nic1=$(grep "NMOL_IC1:" ${ITICinp} | awk '{ $1="";print $0}'); Nic1=($Nic1)
   
Tic2=$(grep "T_IC2:" ${ITICinp} | awk '{ $1="";print $0}'); Tic2=($Tic2)
Nic2=$(grep "NMOL_IC2:" ${ITICinp} | awk '{ $1="";print $0}'); Nic2=($Nic2)

Tic3=$(grep "T_IC3:" ${ITICinp} | awk '{ $1="";print $0}'); Tic3=($Tic3)
Nic3=$(grep "NMOL_IC3:" ${ITICinp} | awk '{ $1="";print $0}'); Nic3=($Nic3)

Tic4=$(grep "T_IC4:" ${ITICinp} | awk '{ $1="";print $0}'); Tic4=($Tic4)
Nic4=$(grep "NMOL_IC4:" ${ITICinp} | awk '{ $1="";print $0}'); Nic4=($Nic4)

Tic5=$(grep "T_IC5:" ${ITICinp} | awk '{ $1="";print $0}');  Tic5=($Tic5)
Nic5=$(grep "NMOL_IC5:" ${ITICinp} | awk '{ $1="";print $0}'); Nic5=($Nic5)

Tic6=$(grep "T_IC6:" ${ITICinp} | awk '{ $1="";print $0}');  Tic6=($Tic6)
Nic6=$(grep "NMOL_IC6:" ${ITICinp} | awk '{ $1="";print $0}'); Nic6=($Nic6)

Tic7=$(grep "T_IC7:" ${ITICinp} | awk '{ $1="";print $0}');  Tic7=($Tic7)
Nic7=$(grep "NMOL_IC7:" ${ITICinp} | awk '{ $1="";print $0}'); Nic7=($Nic7)

Tic8=$(grep "T_IC8:" ${ITICinp} | awk '{ $1="";print $0}');  Tic8=($Tic8)
Nic8=$(grep "NMOL_IC8:" ${ITICinp} | awk '{ $1="";print $0}'); Nic8=($Nic8)

Tic9=$(grep "T_IC9:" ${ITICinp} | awk '{ $1="";print $0}');  Tic9=($Tic9)
Nic9=$(grep "NMOL_IC9:" ${ITICinp} | awk '{ $1="";print $0}'); Nic9=($Nic9)

Tic10=$(grep "T_IC10:" ${ITICinp} | awk '{ $1="";print $0}');  Tic10=($Tic10)
Nic10=$(grep "NMOL_IC10:" ${ITICinp} | awk '{ $1="";print $0}'); Nic10=($Nic10)

rhosIC=$(grep "RHO_IC:" ${ITICinp} | awk '{ $1="";print $0}'); rhosIC=($rhosIC)

#========Isotherm Settings==================

rhoIT1=$(grep "RHO_IT1:" ${ITICinp} | awk '{ $1="";print $0}'); rhoIT1=($rhoIT1)
Nit1=$(grep "NMOL_IT1:" ${ITICinp} | awk '{ $1="";print $0}') ; Nit1=($Nit1)

rhoIT2=$(grep "RHO_IT2:" ${ITICinp} | awk '{ $1="";print $0}'); rhoIT2=($rhoIT2)
Nit2=$(grep "NMOL_IT2:" ${ITICinp} | awk '{ $1="";print $0}'); Nit2=($Nit2)

rhoIT3=$(grep "RHO_IT3:" ${ITICinp} | awk '{ $1="";print $0}'); rhoIT3=($rhoIT3)
Nit3=$(grep "NMOL_IT3:" ${ITICinp} | awk '{ $1="";print $0}'); Nit3=($Nit3)

rhoIT4=$(grep "RHO_IT4:" ${ITICinp} | awk '{ $1="";print $0}'); rhoIT4=($rhoIT4)
Nit4=$(grep "NMOL_IT4:" ${ITICinp} | awk '{ $1="";print $0}'); Nit4=($Nit4)

rhoIT5=$(grep "RHO_IT5:" ${ITICinp} | awk '{ $1="";print $0}'); rhoIT5=($rhoIT5)
Nit5=$(grep "NMOL_IT5:" ${ITICinp} | awk '{ $1="";print $0}'); Nit5=($Nit5)

rhoIT6=$(grep "RHO_IT6:" ${ITICinp} | awk '{ $1="";print $0}'); rhoIT6=($rhoIT6)
Nit6=$(grep "NMOL_IT6:" ${ITICinp} | awk '{ $1="";print $0}'); Nit6=($Nit6)

rhoIT7=$(grep "RHO_IT7:" ${ITICinp} | awk '{ $1="";print $0}'); rhoIT7=($rhoIT7)
Nit7=$(grep "NMOL_IT7:" ${ITICinp} | awk '{ $1="";print $0}'); Nit7=($Nit7)

rhoIT8=$(grep "RHO_IT8:" ${ITICinp} | awk '{ $1="";print $0}'); rhoIT8=($rhoIT8)
Nit8=$(grep "NMOL_IT8:" ${ITICinp} | awk '{ $1="";print $0}'); Nit8=($Nit8)

rhoIT9=$(grep "RHO_IT9:" ${ITICinp} | awk '{ $1="";print $0}'); rhoIT9=($rhoIT9)
Nit9=$(grep "NMOL_IT9:" ${ITICinp} | awk '{ $1="";print $0}'); Nit9=($Nit9)

rhoIT10=$(grep "RHO_IT10:" ${ITICinp} | awk '{ $1="";print $0}'); rhoIT10=($rhoIT10)
Nit10=$(grep "NMOL_IT10:" ${ITICinp} | awk '{ $1="";print $0}'); Nit10=($Nit10)

TsIT=$(grep "T_IT:" ${ITICinp} | awk '{ $1="";print $0}'); TsIT=($TsIT)
   

#========Simulation Settings================

MW=$(grep "MW:" ${ITICinp} | awk '{ print $2}')
NmolecOverride=$1

#========Isochores==========================
i=0
if [ ! -d "IC" ] ; then mkdir IC/; fi
for rho in "${rhosIC[@]}"
	do
	mkdir ${rho}
	k=-1
	i=$(($i+1))
	if [ "$i" -eq "1" ]; then Tic="${Tic1[@]}"; Nic="${Nic1[@]}"; fi
	if [ "$i" -eq "2" ]; then Tic="${Tic2[@]}"; Nic="${Nic2[@]}"; fi
	if [ "$i" -eq "3" ]; then Tic="${Tic3[@]}"; Nic="${Nic3[@]}"; fi
	if [ "$i" -eq "4" ]; then Tic="${Tic4[@]}"; Nic="${Nic4[@]}"; fi
	if [ "$i" -eq "5" ]; then Tic="${Tic5[@]}"; Nic="${Nic5[@]}"; fi
	if [ "$i" -eq "6" ]; then Tic="${Tic6[@]}"; Nic="${Nic6[@]}"; fi
	if [ "$i" -eq "7" ]; then Tic="${Tic7[@]}"; Nic="${Nic7[@]}"; fi
	if [ "$i" -eq "8" ]; then Tic="${Tic8[@]}"; Nic="${Nic8[@]}"; fi
	if [ "$i" -eq "9" ]; then Tic="${Tic9[@]}"; Nic="${Nic9[@]}"; fi
	if [ "$i" -eq "10" ]; then Tic="${Tic10[@]}"; Nic="${Nic10[@]}"; fi
	Nic=($Nic)
	countSimExist=0
	for T in ${Tic} 
		do
		k=$(($k+1))
		thisfolder="IC/${rho}/${T}/" 
		if [ ! -d "$thisfolder" ]; then 

			mkdir ${T}

			N=${Nic[k]}
			L=$(echo "scale=15; e((1/3)*l($N*$MW/$rho/0.6022140857)) "   | bc -l)

			cp Files/${gomc_input_file_name} .

			sed -i -e "s/some_Temperature/$T/g" ${gomc_input_file_name}
			sed -i -e "s/some_box_length/$L/g" ${gomc_input_file_name}
			sed -i -e "s/rhoGCC_NNN/${rho}_${N}/g" ${gomc_input_file_name}
			sed -i -e "s/some_Restart/${Restart}/g" ${gomc_input_file_name}
			sed -i -e "s/some_parameter_file/${parameter_file}/g" ${gomc_input_file_name}
			sed -i -e "s/some_Potential/${Potential}/g" ${gomc_input_file_name}
			sed -i -e "s/some_LRC/${LRC}/g" ${gomc_input_file_name}
			sed -i -e "s/some_Rcut/${Rcut}/g" ${gomc_input_file_name}
			sed -i -e "s/some_R_cut_Factor/${RcutFactor}/g" ${gomc_input_file_name}
			sed -i -e "s/some_Rswitch/${Rswitch}/g" ${gomc_input_file_name}
			sed -i -e "s/some_PressureCalc/${PressureCalc}/g" ${gomc_input_file_name}
			sed -i -e "s/some_RunSteps/${RunSteps}/g" ${gomc_input_file_name}
			sed -i -e "s/some_EqSteps/${EqSteps}/g" ${gomc_input_file_name}
			sed -i -e "s/some_AdjSteps/${AdjSteps}/g" ${gomc_input_file_name}
			sed -i -e "s/some_CoordinatesFreq/${CoordinatesFreq}/g" ${gomc_input_file_name}
			sed -i -e "s/some_Freq_Restart/${RestartFreq}/g" ${gomc_input_file_name}
			sed -i -e "s/some_ConsoleFreq/${ConsoleFreq}/g" ${gomc_input_file_name}
			sed -i -e "s/some_BlockAverageFreq/${BlockAverageFreq}/g" ${gomc_input_file_name}
			sed -i -e "s/some_OutputName/${OutputName}/g" ${gomc_input_file_name}

			mv ${gomc_input_file_name} ${T}/
			mv ${T} ${rho}

		else 
			echo "SMR: $thisfolder folder Exists. The simulation has been previously done" 
			countSimExist=$(($countSimExist+1))
		fi

	done

	if [ "$countSimExist" == "0" ];then 
		mv ${rho} IC
	else
		if test "$(ls -A "${rho}")"; then #checks if dir is not empty
			mv $rho/* IC/$rho; rm -r $rho
		else
			rm -r $rho
		fi
	fi
done

#========Isotherms===========================
j=0
if [ ! -d "IT" ] ; then mkdir IT/; fi
for T in "${TsIT[@]}" 
	do
	mkdir ${T}
	l=-1
	j=$(($j+1))

	if [ "$j" -eq "1" ]; then rhoIT="${rhoIT1[@]}";	Nit="${Nit1[@]}"; fi
	if [ "$j" -eq "2" ]; then rhoIT="${rhoIT2[@]}";	Nit="${Nit2[@]}"; fi
	if [ "$j" -eq "3" ]; then rhoIT="${rhoIT3[@]}"; Nit="${Nit3[@]}"; fi
	if [ "$j" -eq "4" ]; then rhoIT="${rhoIT4[@]}"; Nit="${Nit4[@]}"; fi
	if [ "$j" -eq "5" ]; then rhoIT="${rhoIT5[@]}";	Nit="${Nit5[@]}"; fi
	if [ "$j" -eq "6" ]; then rhoIT="${rhoIT6[@]}";	Nit="${Nit6[@]}"; fi
	if [ "$j" -eq "7" ]; then rhoIT="${rhoIT7[@]}"; Nit="${Nit7[@]}"; fi
	if [ "$j" -eq "8" ]; then rhoIT="${rhoIT8[@]}"; Nit="${Nit8[@]}"; fi
	if [ "$j" -eq "9" ]; then rhoIT="${rhoIT9[@]}"; Nit="${Nit9[@]}"; fi
	if [ "$j" -eq "10" ]; then rhoIT="${rhoIT10[@]}"; Nit="${Nit10[@]}"; fi
	Nit=($Nit)
	countSimExist=0
	for rho in ${rhoIT} 
		do
		l=$(($l+1))
		thisfolder="IT/${T}/${rho}/" 
		if [ ! -d "$thisfolder" ]; then 
			mkdir ${rho}

			N=${Nit[l]}
			L=$(echo "scale=15; e((1/3)*l($N*$MW/$rho/0.6022140857)) "   | bc -l)

			cp Files/${gomc_input_file_name} .

			sed -i -e "s/some_Temperature/$T/g" ${gomc_input_file_name}
			sed -i -e "s/some_box_length/$L/g" ${gomc_input_file_name}
			sed -i -e "s/rhoGCC_NNN/${rho}_${N}/g" ${gomc_input_file_name}
			sed -i -e "s/some_Restart/${Restart}/g" ${gomc_input_file_name}
			sed -i -e "s/some_parameter_file/${parameter_file}/g" ${gomc_input_file_name}
			sed -i -e "s/some_Potential/${Potential}/g" ${gomc_input_file_name}
			sed -i -e "s/some_LRC/${LRC}/g" ${gomc_input_file_name}
			sed -i -e "s/some_Rcut/${Rcut}/g" ${gomc_input_file_name}
			sed -i -e "s/some_R_cut_Factor/${RcutFactor}/g" ${gomc_input_file_name}
			sed -i -e "s/some_Rswitch/${Rswitch}/g" ${gomc_input_file_name}			
			sed -i -e "s/some_PressureCalc/${PressureCalc}/g" ${gomc_input_file_name}
			sed -i -e "s/some_RunSteps/${RunSteps}/g" ${gomc_input_file_name}
			sed -i -e "s/some_EqSteps/${EqSteps}/g" ${gomc_input_file_name}
			sed -i -e "s/some_AdjSteps/${AdjSteps}/g" ${gomc_input_file_name}
			sed -i -e "s/some_CoordinatesFreq/${CoordinatesFreq}/g" ${gomc_input_file_name}
			sed -i -e "s/some_Freq_Restart/${RestartFreq}/g" ${gomc_input_file_name}
			sed -i -e "s/some_ConsoleFreq/${ConsoleFreq}/g" ${gomc_input_file_name}
			sed -i -e "s/some_BlockAverageFreq/${BlockAverageFreq}/g" ${gomc_input_file_name}
			sed -i -e "s/some_OutputName/${OutputName}/g" ${gomc_input_file_name}


			mv ${gomc_input_file_name} ${rho}/
			mv ${rho} ${T}
		else 
			echo "SMR: $thisfolder folder Exists. The simulation has been previously done"
			countSimExist=$(($countSimExist+1))
		fi
	done
	if [ "$countSimExist" == "0" ];then 
		mv ${T} IT
	else
		if test "$(ls -A "${T}")"; then #checks if dir is not empty
			mv $T/* IT/$T; rm -r $T
		else
			rm -r $T
		fi
	fi
done
