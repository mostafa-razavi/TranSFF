#!/bin/bash


#===== Molecule and force field files =====
molecule=$1										# E.g. C1, C2, C4, C12, etc
force_field_file=$2								# E.g. C2_TraPPE-UA.par (in Forcefileds_path) or /path/to/file/TraPPE-UA.par
config_filename=$3								# A file containing GOMC settings (a list of key value pairs e.g. Potential	FSHIFT\n LRC false)
temperature_index_array=$4						# "all" or list of indices corresponding to the desired reduced temperatures listed in ${molecule}.gemc file. i=0, 1, 2, 3, etc. correspond to Tr=0.95, 0.90, 0.85, etc.
gomc_exe_address=$5								# "$HOME/Git/GOMC/GOMC-FSHIFT2-HighPrecisionPDB-StartFrame/bin/GOMC_CPU_NVT"
should_run=$6									# "yes" or "no" (lower case)
#===== Number of CPU cores to use ===== 
Nproc=$(nproc)
if [ "$7" != "" ]; then Nproc="$7"; fi


#===== Important paths =====
Scripts_path="$HOME/Git/TranSFF/Scripts"
Config_path="$HOME/Git/TranSFF/Config"
Molecules_path="$HOME/Git/TranSFF/Molecules/$molecule"
Forcefileds_path="$HOME/Git/TranSFF/Forcefields/$molecule"

#===== Simulation Parameters =====
config_file="$HOME/Git/TranSFF/Config/${config_filename}"

Restart=$(grep -R "Restart" $config_file | head -n1 | awk '{print $2}')
Potential=$(grep -R "Potential" $config_file | awk '{print $2}')
LRC=$(grep -R "LRC" $config_file | awk '{print $2}')
Rcut=$(grep -R "Rcut " $config_file | awk '{print $2}')		# The space in "Rcut " is important to distinguish it from RcutFactor hen sed replacing
RcutFactor=$(grep -R "RcutFactor" $config_file | awk '{print $2}')
Rswitch=$(grep -R "Rswitch" $config_file | awk '{print $2}')
PressureCalc=$(grep -R "PressureCalc" $config_file | awk '{print $2}')
RunSteps=$(grep -R "RunSteps" $config_file | awk '{print $2}')
EqSteps=$(grep -R "EqSteps" $config_file | awk '{print $2}')
AdjSteps=$(grep -R "AdjSteps" $config_file | awk '{print $2}')
CoordinatesFreq=$(grep -R "CoordinatesFreq" $config_file | awk '{print $2}')
RestartFreq=$(grep -R "RestartFreq" $config_file | awk '{print $2}')
ConsoleFreq=$(grep -R "ConsoleFreq" $config_file | awk '{print $2}')
BlockAverageFreq=$(grep -R "BlockAverageFreq" $config_file | awk '{print $2}')
OutputName=$(grep -R "OutputName" $config_file | awk '{print $2}')

#===== Other =====
gomc_input_file_name="gemc.inp"
continue_if_Files_folder_exists="yes"


#=====================
CD=${PWD}
this_scripts=${0}
if [ ! -e "$(basename -- "$this_scripts")" ]; then cp ${this_scripts} .; fi	# Copy the script in the current directory

if [ $continue_if_Files_folder_exists != "yes" ] && [ $continue_if_Files_folder_exists != "no" ]; then echo "continue_if_Files_folder_exists should either be yes or no. Existing..."; exit; fi
if [ -e "Files" ] && [ $continue_if_Files_folder_exists == "yes" ]; then echo "Files folder exists. Proceeding..."; fi
if [ -e "Files" ] && [ $continue_if_Files_folder_exists == "no" ]; then echo "Files folder exists. Exiting..."; exit; fi
if [ ! -e "Files" ]; then 
	mkdir Files
	cd Files 
	cp 
	bash $Scripts_path/Generate_PDB_PSF_GE.sh $molecule
	cd $CD
fi

MW=$(grep "MW:" Files/${molecule}.gemc | awk '{ print $2}')

#========Isotherm Settings==================
Temperatures=$(grep "TEMP:" Files/${molecule}.gemc | awk '{ $1="";print $0}'); Temperatures=($Temperatures)

rhoLs=$(grep "RHO_L:" Files/${molecule}.gemc | awk '{ $1="";print $0}'); rhoLs=($rhoLs)
N_Ls=$(grep "NMOL_L:" Files/${molecule}.gemc | awk '{ $1="";print $0}') ; N_Ls=($N_Ls)

rhoVs=$(grep "RHO_V:" Files/${molecule}.gemc | awk '{ $1="";print $0}'); rhoVs=($rhoVs)
N_Vs=$(grep "NMOL_V:" Files/${molecule}.gemc | awk '{ $1="";print $0}'); N_Vs=($N_Vs)

#========GEMC===========================


if [ "$temperature_index_array" == "all" ]; then
	temperature_index_array=(0 1 2 3 4 5 6 7 8 9 10)
else
	temperature_index_array=($temperature_index_array)
fi

if [ -e "GE" ]; then echo "GE folder already exists. Exiting..."; exit; fi

j=-1
mkdir GE
for T in "${Temperatures[@]}" 
	do
	j=$(($j+1))
	if printf '%s\n' ${temperature_index_array[@]} | grep -q -P "^${j}$"
	then 
		mkdir ${T}
		rhoLGCC=${rhoLs[j]}
		rhoVGCC=${rhoVs[j]}

		N_L=${N_Ls[j]}
		N_V=${N_Vs[j]}

		L_L=$(echo "scale=15; e((1/3)*l($N_L*$MW/$rhoLGCC/0.6022140857)) "   | bc -l)
		L_V=$(echo "scale=15; e((1/3)*l($N_V*$MW/$rhoVGCC/0.6022140857)) "   | bc -l)


		cp $Config_path/$gomc_input_file_name Files

		if [ "${force_field_file::1}" == "/" ]; then # If force_field_file is an absolute path (starts with "/") 
			cp $force_field_file Files
		else	# Or just a file name (the file should be in Forcefileds_path)
			cp $Forcefileds_path/$force_field_file Files
		fi
		parameter_file=$(basename "$force_field_file") 

		cp Files/$gomc_input_file_name .
		
		sed -i -e "s/some_Temperature/$T/g" ${gomc_input_file_name}
		sed -i -e "s/LLL_L/$L_L/g" $gomc_input_file_name
		sed -i -e "s/LLL_V/$L_V/g" $gomc_input_file_name
		sed -i -e "s/rhoLGCC/$rhoLGCC/g" $gomc_input_file_name
		sed -i -e "s/rhoVGCC/$rhoVGCC/g" $gomc_input_file_name
		sed -i -e "s/somr_parameter_file/${force_field_file_name}/g" ${gomc_input_file_name}
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


		mv $gomc_input_file_name ${T}
		mv ${T} GE
	fi
done

rm -rf ${CD}/COMMANDS.parallel
for fol in GE/*; do 
	echo "cd $CD/$fol; $gomc_exe_address $gomc_input_file_name > gomc.log" >> ${CD}/COMMANDS.parallel
done

cd ${CD}
if [ "$should_run" == "yes" ]; then
	parallel --jobs $Nproc < ${CD}/COMMANDS.parallel
	ndataskip=$(echo "($RunSteps/$BlockAverageFreq)/2" | bc )
	nblocks="5"
	echo $ndataskip $nblocks	
	bash $HOME/Git/TranSFF/Scripts/GONvtRdr/GOGE_BlockAvg.sh Blk_${OutputName}_BOX_0.dat Blk_${OutputName}_BOX_1.dat ${ndataskip} $nblocks ${molec}.gemc-razavi
fi

