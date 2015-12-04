
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
