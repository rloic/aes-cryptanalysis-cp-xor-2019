#!/bin/bash
KB=$1;
n=$2;
obj=$3;
model=$4; # {S1Basic, S1Diff, S1XOR}
shift=$5; # {shift, noshift}
rep="./$model-$shift";
mkdir $rep;

T=$(date +%s%N);
file=$model$T;
outSols=$rep/$KB-$n-$obj;

cp $model.mzn /tmp/$file.mzn;
if [ $model == "S1XOR" ];
then
cat XORFiles/$(( KB/32))-$n.txt >> /tmp/$file.mzn;
fi


i=0;
t=0;
DX="Not empty";
if [ $shift == "shift" ]
 then
 echo "Shift"
 cat Heuristics/shift_picat >> /tmp/$file.mzn
 while [[ $DX != '' ]]; do
  MiniZincIDE-2.2.3-bundle-linux/bin/mzn2fzn /tmp/$file.mzn -D "KEY_BITS=$KB;r=$n; objStep1=$obj";
  sh -c "time $HOME/Picat/picat $HOME/Picat/lib/fzn_picat_sat.pi /tmp/$file.fzn " 2&> /tmp/$file-time;
  DX=$(cat /tmp/$file-time | grep 'DX' | sed "s/DX/DX$i/g" );
  DSBK=$(cat /tmp/$file-time | grep 'DSBK' | sed "s/DSBK/DSBK$i/g" );
  time=$(cat /tmp/$file-time | grep 'user\|sys' );
  echo "$time" >> $outSols;
  if [[ $DX != '' ]]; then 
   echo "array [0..r-1, 0..3, 0..4-1] of var 0..1: $DX " >> /tmp/$file.mzn;
   echo "array [0..4*NK-1] of var 0..1: $DSBK " >> /tmp/$file.mzn;
   echo "constraint not ( (forall (i in 0..r-1, j in 0..3, k in 0..4-1)(DX[i,j,k]=DX$i[i,j,k])) /\ " >> /tmp/$file.mzn;
   echo " ( forall (k in 0..4*NK-1)(DSBK[k]=DSBK$i[k]) ));" >> /tmp/$file.mzn;
   echo "$DX" >> $outSols;
   echo "$DSBK" >> $outSols;
   ((i++));
  fi
 done;
else
 echo "No shift"
 cat Heuristics/normal >> /tmp/$file.mzn
 while [[ $DX != '' ]]; do
  MiniZincIDE-2.2.3-bundle-linux/bin/mzn2fzn /tmp/$file.mzn -D "KEY_BITS=$KB;r=$n; objStep1=$obj"; 
  sh -c "time $HOME/Picat/picat $HOME/Picat/lib/fzn_picat_sat.pi /tmp/$file.fzn " 2&> /tmp/$file-time;
  DX=$(cat /tmp/$file-time | grep 'DX' | sed "s/DX/DX$i/g" );
  DK=$(cat /tmp/$file-time | grep 'DK' | sed "s/DK/DK$i/g" );
  DZ=$(cat /tmp/$file-time | grep 'DZ' | sed "s/DZ/DZ$i/g" );

  time=$(cat /tmp/$file-time | grep 'user\|sys' );
  echo "$time" >> $outSols;
  if [[ $DX != '' ]]; then 
   echo "array [0..r-1, 0..3, 0..3] of var 0..1: $DX" >> /tmp/$file.mzn;
   echo "array [0..r-1, 0..3, 0..4] of var 0..1: $DK" >> /tmp/$file.mzn;
   echo "array [0..r-2, 0..3, 0..3] of var 0..1: $DZ" >> /tmp/$file.mzn;
   echo "constraint not ( (forall (i in 0..r-1, j in 0..3, k in 0..3)(DX[i,j,k]=DX$i[i,j,k])) /\ " >> /tmp/$file.mzn;
   echo "               (forall (i in 0..r-1, j in 0..3, k in 0..3)(DK[i,j,k]=DK$i[i,j,k])) /\ " >> /tmp/$file.mzn;
   echo " 		 (forall (i in 0..r-2, j in 0..3, k in 0..3)(DZ[i,j,k]=DZ$i[i,j,k]) ) );  " >> /tmp/$file.mzn;
   echo "$DX" >> $outSols;
   echo "$DK" >> $outSols;
   echo "$DZ" >> $outSols;
   ((i++));
  fi
 done;
fi
rm /tmp/$file*
