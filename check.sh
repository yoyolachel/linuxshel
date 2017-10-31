#!/bin/bash
if [ $# -ne 3 ]
  then
  echo "Usage: check.sh [logfile] [KeyCount] [THREAD_NUM]"
  exit 0
fi
THREAD_NUM=$3
KEYNUM=$2
i=1
FAILCOUNT=0
mkfifo tmp
exec 9<>tmp
for ((j=0;j<=THREAD_NUM;j++))
do 
  echo -ne "\n" 1>&9
done
cat ./$1 | while read line
do
 {
   read -u 9
   KEY=`echo $line|grep -o "|"|wc -l`
   if [[ $KEY -eq $KEYNUM ]]; then
    echo "1">>COUNT
   else 
    echo "0">>COUNT
    echo "$i $KEY">>FAILLINE
   fi
   echo -ne "\n" 1>&9
   echo "CurrentProcess is $i"
  }&
   i=$((i+1))
  done
  wait
  rm tmp
  TOTAL_LINE=`cat COUNT|wc -l`
  COUNT_SUM=`cat COUNT|grep "1"|wc -l`
  echo "******CORRECT_PERCENT IS*******"
  percent=$[$COUNT_SUM/$TOTAL_LINE]
  echo $percent|awk '{printf "%.2f%\n",$1*100}'
  rm COUNT
