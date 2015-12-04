
x=0;
cd /shared/cBench_V1.1
#file="/shared/GCCFlagsGenerator/NS-gcc.txt"
#while read -r line
#do
export CCC_OPTS=$1
COMPILER=gcc
#benchmarks=*
benchmarks=`cat bench_list`
./all__delete_work_dirs
./all__create_work_dirs
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


for j in `seq 1 1`;
   do
    echo "#################################################### execution ####################################################"
    echo "Dataset: $j"

docker run --name=execution_container_"$i"_"$x" -v /shared:/shared ubuntu /bin/bash -c "cd /shared/cBench_V1.1/$i/src_work/ && ./__run $j"
 
docker rm -f execution_container_"$i"_"$x"

echo $x;

done;


#done < "$file"
sleep 100



x=0;
cd /shared/cBench_V1.1
#benchmarks=*
benchmarks=`cat bench_list`
for i in $benchmarks
do
rm /shared/tmp/influxdb.json	
rm /shared/tmp/memory
if [ -d "$i" ]
then
 tmp=$PWD
 cd $i
 if [ -d "src_work" ]
 then
x=`expr $x + 1`;

for j in `seq 1 1`;
   do

curl -o /shared/tmp/influxdb.json -G 'http://10.0.0.22:8086/db/cadvisorDB/series?u=root&p=root&pretty=true' --data-urlencode "q=select container_name, max(memory_usage) from stats where container_name =~ /.*execution_container_"$i"*/ and memory_usage <> 0 group by container_name"

echo "select container_name, mean(memory_usage) from stats where container_name =~ /.*execution_container_"$i"*/ and memory_usage <> 0 group by container_name"

#python JSON2CSVFILE.py
python /shared/JSON2CSVFILE.py
#exit 0
sort -V /shared/tmp/memory >> /shared/statistics/memory_$i

done;


 fi
 cd $tmp
fi

done

