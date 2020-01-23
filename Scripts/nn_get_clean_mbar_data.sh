CD=${PWD}
last_n_lines_to_remove=$1

if [ "$last_n_lines_to_remove" == "" ]
then
    last_n_lines_to_remove="0"
fi

for i in 1 2 3 4 5 6 7 8 9
do
    rm -rf $CD/${i}.res
done

for folder in `ls -d Sample*/ | sort -V`
do cd $folder
    for iline in 1 2 3 4 5 6 7 8 9
    do iline=$((iline+1))
        line=$(sed "${iline}q;d" *.trhozures.res)
        folder=${PWD##*/}
        string="${folder} ${line}"
        echo "${string:6}" | sed 's/_/ /g' | sed 's/ -/_/g' | sed 's/-/ /g' | sed 's/_/ -/g' | sed 's/e /e-/g' >> $CD/$((iline-1)).res
    done
    cd ..
done

for i in 1 2 3 4 5 6 7 8 9
do
    cat $CD/${i}.res | head -n -${last_n_lines_to_remove} > $CD/${i}.tmp
    mv $CD/${i}.tmp $CD/${i}.res
done