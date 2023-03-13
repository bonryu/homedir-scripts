#!/bin/bash
readarray lines < <(xrandr | grep '\sconnected'| sed 's/\(.*\) (norm.*/\1/') 

if [ -f "./monitoroutput.txt" ]
then
    output=$(head -n 1 monitoroutput.txt)
    WACOMOUTPUT=$(($output))
else
    touch monitoroutput.txt
    echo 0 > monitoroutput.txt
    WACOMOUTPUT=0
fi

echo "wacom output: $WACOMOUTPUT"
    
displaylines=()
for i in "${lines[@]}"
do
    displaylines+=("$i")
done

allmonitors=("desktop")
a=0
dispnames=()
geometries=()
orientations=()
for d in "${displaylines[@]}"
do
    a+=1
    # echo "$d"
    [[ $d =~ ^[[:alnum:]-]* ]]
    # echo "dn bash_rematch: ${BASH_REMATCH}" 
    dn=${BASH_REMATCH}
    dispnames+=("$dn")

    [[ $d =~ [0-9]+x[0-9]+\+[0-9]+\+[0-9]+ ]]
    # echo "gm bash_rematch: ${BASH_REMATCH}"
    gm=${BASH_REMATCH}
    geometries+=("$gm")
    
    [[ $d =~ (normal)|(left)|(inverted)|(right) ]]
    or=${BASH_REMATCH}
    # echo "or: $or"
    orientations+=("$or")

done

echo ----

for ((i=0; i<${#dispnames[@]}; i++))
do
    echo "${dispnames[i]}.${geometries[i]}.${orientations[i]}."
done

WACOMOUTPUT=$(expr $WACOMOUTPUT + 1)

numoutputs=$(expr ${#dispnames[@]} + 1)
echo "numoutputs: $numoutputs"
if (( WACOMOUTPUT >= (numoutputs) ))
then 
    WACOMOUTPUT=0
fi
echo "wacomoutput: $WACOMOUTPUT"

# If we have a dual monitor setup, then numoutputs is 3. 
# We intend for first monitor to be output 0, 
# second to be 1, and the desktop to be output 2.
# Thus desktop output number is (numoutputs - 1)

# if wacomoutput is less than (numoutputs -1), then
# we can do xsetwacom set ${dispnames[i]}.
# Otherwise, it's the desktop, so we do xsetwacom set desktop

dispnames+=('desktop')
geometries+=(' ')
orientations+=('normal')

dispname=${dispnames[WACOMOUTPUT]}
orientation=${orientations[WACOMOUTPUT]}
case $orientation in
    left)
        rotation='ccw'
        ;;
    right)
        rotation='cw'
        ;;
    inverted)
        rotation='half'
        ;;
    *)
        rotation='none'
        ;;
esac


ids=()
for ID in $(xsetwacom list | cut -f2 | cut -d' ' -f2) 
do 
    ids+=("$ID")
done

types=()
for TYPE in $(xsetwacom list | cut -f3 | cut -d' ' -f2) 
do 
    types+=("$TYPE")
done

echo "dispname: $dispname"
echo "rotation: $rotation"


for ((i=0 ; i<${#types[@]}; i++ ))
do
    xsetwacom set "${ids[i]}" maptooutput "$dispname"
    if [ "${types[i]}" != "PAD" ]
    then
        xsetwacom set "${ids[i]}" rotate "$rotation"
    fi
done

sed -i "1s/.*/$WACOMOUTPUT/" monitoroutput.txt
