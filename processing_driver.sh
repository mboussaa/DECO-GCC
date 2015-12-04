# This is a sample script driver for testing GCC
#
# init 
#
#chmod

# generate optimization options using Novelty Search
#
#rm -rf GCCFlagsGenerator
#git clone https://github.com/mboussaa/GCCFlagsGenerator.git
#cd GCCFlagsGenerator
#mvn clean
#mvn install;
rm -rf /shared/statistics
mkdir /shared/statistics
rm -rf /shared/tmp
mkdir /shared/tmp
# avoid overhead by removing all containers 
#
echo "remove all containers";
docker stop $(docker ps -a -q);
docker rm $(docker ps -a -q);

# run CAdvisor
#
echo "run CAdvisor container";
docker run --volume=/:/rootfs:ro --volume=/var/run:/var/run:rw --volume=/sys:/sys:ro --volume=/var/lib/docker/:/var/lib/docker:ro --publish=8080:8080 --detach=true --name=cadvisor --restart=always google/cadvisor:latest -logtostderr -storage_driver=influxdb -storage_driver_host=10.0.0.22:8086 -storage_driver_db=cadvisorDB

# run InfluxDB
#
echo "run InfluxDB Time Series DB container";
docker run -d -p 8083:8083 -p 8086:8086 --expose 8090 --expose 8099 -e PRE_CREATE_DB="cadvisorDB" --name=influxdb tutum/influxdb:0.8.8
#sleep 160 ;

x=0;
cd /shared/cBench_V1.1
file="/shared/GCCFlagsGenerator/NS-gcc.txt"
while read -r line
do
export CCC_OPTS=$line
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
#x=`expr $x + 1`;
  # *** process directory ***
    echo "#################################################### compilation ###################################################"
  echo $i
  cd src_work
  ./__compile $COMPILER
  echo ""
  ls -l a.out
  echo ""
  # *************************

#rm -rf /shared/statistics
#mkdir /shared/statistics
#

for j in `seq 1 1`;
   do
    echo "#################################################### execution ####################################################"
    echo "Dataset: $j"
#  source __find_data_set $j 100 
#echo $cmd;

#rm /shared/epoch_time.csv;


   
#docker run --name=execution_container -v /shared:/shared ubuntu /bin/bash -c "cd /shared/cBench_V1.1/$i/src_work/ && time(./__run $cmd)";   
#date +%s >> "/shared/epoch_time.csv"
#rm /shared/epoch_time.csv;
#docker run --name=execution_container_"$x" -v /shared:/shared ubuntu /bin/bash -c "cd /shared/cBench_V1.1/$i/src_work/ && TIMEFORMAT='%3R' &&  time(./__run $j 1) 2>> /shared/statistics/time_'$i'.csv"
#docker run --name=execution_container_"$x" -v /shared:/shared ubuntu /bin/bash -c " cd /shared/cBench_V1.1/$i/src_work/ && TIMEFORMAT='%3R' &&  time(./__run $j 20) 2>> /shared/statistics/time_'$i'.csv && sleep 1"
docker run --memory-swap -1  --name=execution_container_"$i"_"$x" -v /shared:/shared ubuntu /bin/bash -c "cd /shared/cBench_V1.1/$i/src_work/ && ./__run $j 50000000"
#docker run --name=execution_container_"$x" -v /shared:/shared ubuntu /bin/bash -c " sleep 2"
#docker run --name=execution_container_"$x" -v /shared:/shared ubuntu /bin/bash -c "time(sleep 1) 2>> /shared/statistics/time_'$i'.csv"

#date +%s >> "/shared/epoch_time.csv"
#docker stop execution_container_"$x" @
 docker rm -f  execution_container_"$i"_"$x"
#cd /shared/cBench_V1.1/$i/src_work/ && TIMEFORMAT='%3R' &&  time(./__run $j 20) 2>> /shared/statistics/timeOPT_"$i".csv 
#s=1;
echo $x;
# request InfluxDB and get stats about memory consumption
#
#echo "request InfluxDB and get stats about memory consumption";

#echo "go"
done;


 fi
 cd $tmp
fi

done


echo "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^NEW SEQUENCE^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"

done < "$file"
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




#echo "create matrix of time, CPU and Memory consumptions"
#paste -d ',' /shared/stats/time_O0.csv /shared/stats/time_O1.csv /shared/stats/time_O2.csv /shared/stats/time_O3.csv /shared/stats/time_O4.csv > /shared/matrix/time.csv;
#paste -d ',' /shared/stats/cpu_O0.csv /shared/stats/cpu_O1.csv /shared/stats/cpu_O2.csv /shared/stats/cpu_O3.csv /shared/stats/cpu_O4.csv > /shared/matrix/cpu_temp.csv;
#paste -d ',' /shared/stats/mem_O0.csv /shared/stats/mem_O1.csv /shared/stats/mem_O2.csv /shared/stats/mem_O3.csv /shared/stats/mem_O4.csv > /shared/matrix/mem_temp.csv;
#tac /shared/matrix/mem_temp.csv > /shared/matrix/mem.csv
#tac /shared/matrix/cpu_temp.csv > /shared/matrix/cpu.csv
#rm /shared/matrix/mem_temp.csv /shared/matrix/cpu_temp.csv
