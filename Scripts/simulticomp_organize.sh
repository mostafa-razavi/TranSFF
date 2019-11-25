#!/bin/bash
CD=${PWD}
run_name=$1
molecules_array=$2
if [ -d "$CD/$run_name" ]; then
    echo "Run_name folder already exists. Choose another name and run again..."
    exit
else
    mkdir $CD/$run_name
fi

molecules_array=($molecules_array)
for molec in "${molecules_array[@]}"
do 
    mkdir $CD/$run_name/${molec}
    mv $CD/${molec}/I* $CD/$run_name/${molec}
done

mv $CD/*.score $CD/$run_name
mv $CD/*.log $CD/$run_name
cp $CD/run_trf_multicomp.py $CD/$run_name/run_trf_multicomp.py