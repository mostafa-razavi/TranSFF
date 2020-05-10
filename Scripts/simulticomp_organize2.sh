#!/bin/bash
CD=${PWD}
run_name=$1
molecules_array=$2

if [ -d "$CD/$run_name" ]; then
    echo "Run_name folder already exists. Exsiting simulticomp_organize.sh ..."
    exit
else
    mkdir $CD/$run_name
fi

molecules_array=($molecules_array)
for molec in "${molecules_array[@]}"
do 
    mkdir $CD/$run_name/${molec}
    mv $CD/${molec}/i-* $CD/$run_name/${molec}
    rm -rf $CD/${molec}/*.par
done

mv $CD/*.score $CD/$run_name
mv $CD/*.parallel $CD/$run_name
mv $CD/*.log $CD/$run_name
cp $CD/*simulticomp2.py $CD/$run_name
