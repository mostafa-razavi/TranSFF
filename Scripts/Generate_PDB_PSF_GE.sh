#!/bin/bash
CD=${PWD}
molec_name="$1" 

Scripts_path="$HOME/Git/TranSFF/Scripts"
Molecules_path="$HOME/Git/TranSFF/Molecules/$molecule"

cp $Molecules_path/${molec_name}/${molec_name}.gemc .
cp $Molecules_path/${molec_name}/${molec_name}.top .
cp $Molecules_path/${molec_name}/${molec_name}.pdb .

GEMC_file_name=$(ls *.gemc)
pdb_file_name=$(ls *.pdb)
topology_file_name=$(ls *.top)

packmol_input_file_name="packmol.in"
psfgen_input_file_name="psfgen.tcl"

cp $Scripts_path/$packmol_input_file_name .
cp $Scripts_path/$psfgen_input_file_name .

MW=$(grep "MW:" ${GEMC_file_name} | awk '{print $2}')
packmol_exe_address="packmol"
vmd_exe_address="vmd"

rhos1=$(grep "RHO_L:" ${GEMC_file_name} | awk '{ $1="";print $0}'); rhos1=($rhos1)

rhos1=$(grep "RHO_L:" ${GEMC_file_name} | awk '{ $1="";print $0}'); rhos1=($rhos1)
rhos2=$(grep "RHO_V:" ${GEMC_file_name} | awk '{ $1="";print $0}'); rhos2=($rhos2)
rhos=( "${rhos1[@]}" "${rhos2[@]}"  )

Nmolec1=$(grep "NMOL_L:" ${GEMC_file_name} | awk '{ $1="";print $0}'); Nmolec1=($Nmolec1)
Nmolec2=$(grep "NMOL_V:" ${GEMC_file_name} | awk '{ $1="";print $0}'); Nmolec2=($Nmolec2)
Nmolec=( "${Nmolec1[@]}" "${Nmolec2[@]}" )

#========================================================

i=-1
for rho in "${rhos[@]}"
	do
	i=$(($i+1))
	N=${Nmolec[i]}
	if [ ! -e "${rho}" ]
	then
		mkdir "${rho}"
		L=$(echo "scale=15; e((1/3)*l($N*$MW/$rho/0.6022140857)) "   | bc -l)

		cp $CD/$pdb_file_name $CD/"${rho}"/$pdb_file_name 
		cp $CD/"$packmol_input_file_name" $CD/"${rho}"/$packmol_input_file_name
		cp $CD/${topology_file_name} $CD/"${rho}"/${topology_file_name}
		cp $CD/${psfgen_input_file_name} $CD/"${rho}"/${psfgen_input_file_name}

		sed -i "s/"pdbFile"/$pdb_file_name/g" $CD/"${rho}"/$packmol_input_file_name
		sed -i "s/"NNN"/${N}/g" $CD/"${rho}"/$packmol_input_file_name
		sed -i "s/"LLL"/$L/g" $CD/"${rho}"/$packmol_input_file_name

		sed -i "s/"top_file"/$topology_file_name/g" $CD/"${rho}"/$psfgen_input_file_name
		sed -i "s/"some_molec_name"/$molec_name/g" $CD/"${rho}"/$psfgen_input_file_name

		cd "${rho}"

		eval ${packmol_exe_address} < packmol.in
		mv out.txt "${rho}".pdb 

		cp "${rho}".pdb in.pdb
		eval ${vmd_exe_address} < ${psfgen_input_file_name}
		mv out.psf "${rho}".psf

		rm in.pdb $pdb_file_name $packmol_input_file_name ${topology_file_name} ${psfgen_input_file_name}

		cd ..
	else
		echo "${rho}" "directory already exists"
	fi
done