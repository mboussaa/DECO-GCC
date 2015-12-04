x=0;
cd /shared/cBench_V1.1
#file="/shared/GCCFlagsGenerator/NS-gcc.txt"
#while read -r line
#do
export CCC_OPTS=$1
COMPILER=gcc
#benchmarks=*
benchmarks=`cat bench_list`
#./all__delete_work_dirs
#./all__create_work_dirs
x=`expr $x + 1`;
for i in $benchmarks
do
if [ -d "$i" ]
then
 tmp=$PWD
 cd $i
 if [ -d "src_work" ]
 then
    echo "#################################################### compilation ###################################################"
  echo $i
  cd src_work
  ./__compile $COMPILER
  echo ""
  ls -l a.out
  echo ""

 fi
 cd $tmp
fi

done
