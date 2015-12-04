
x=0;
cd /shared/cBench_V1.1
#benchmarks=*
x=`expr $x + 1`;
for i in $benchmarks
do
if [ -d "$i" ]
then
 tmp=$PWD
 cd $i
 if [ -d "src_work" ]
 then

for j in `seq 1 1`;
   do
    echo "#################################################### execution ####################################################"
    echo "Dataset: $j"

docker run --name=execution_container_"$i"_"$x" -v /shared:/shared ubuntu /bin/bash -c "cd /shared/cBench_V1.1/$i/src_work/ && ./__run $j"

docker rm -f execution_container_"$i"_"$x"

echo $x;
 
   done
  fi

done 
