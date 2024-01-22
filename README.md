# StormCrawler backends benchmarks

This repository contains a StormCrawler topology to evaluate the performance of some of the backends it can use. Crawls tend to be write-heavy; each page visited will yield a large number of outlinks which will 
need persisting in the backend. Often, the StatusUpdaterBolt becomes the bottleneck of a crawl topology.

What we are trying to achieve here is measure the impact of various configurations elements for a given backend and compare the perfs of different backends on the same hardware. We will have one branch per backend, 
with Elasticsearch in the _main_ branch.

## Prerequisite

``` sh
mvn clean package
```

## Get WARC files

```
aws s3 cp s3://commoncrawl/crawl-data/CC-MAIN-2020-50/segments/1606141163411.0/warc/CC-MAIN-20201123153826-20201123183826-00001.warc.gz warc
aws s3 cp s3://commoncrawl/crawl-data/CC-MAIN-2020-50/segments/1606141163411.0/warc/CC-MAIN-20201123153826-20201123183826-00000.warc.gz warc
```
or
```
aws s3 cp s3://commoncrawl/crawl-data/CC-MAIN-2020-50/segments/1606141163411.0/warc/ /data/warc --recursive

rm /data/warc/index.lst
for f in `ls /data/warc | grep '.gz$'`; do echo $PWD/warc/$f >> /data/warc/index.lst; done

```

# Start Elasticsearch instances and configure the status index

```
docker compose up -d --remove-orphans
./ES_IndexInit.sh
```

# Run the benchmark topology

The metric you want to track is `average_persec` from the _status_ bolt

```
2024-01-10 15:56:34,832 92527    1704902194	julien-XPS-15-9520:6700	 15:status     	average_persec         	{received=49300.66101355412}
```

Assuming you are running the topology locally with

```
storm local --local-ttl 9999999 target/benchmark-1.0-SNAPSHOT.jar  org.apache.storm.flux.Flux benchmark.flux | grep average_persec | grep -v received=0.0 > benchmark.metric

```

You can extract the values and compute the average with 

```
./stats.sh benchmark.metric 
```

No need to grep the output in distributed mode, the stats script will automatically retrieve it from the workers metrics and store the content in a _stats_ directory, using the file name
passed as argument.


For the purpose of comparing different configurations and setups, use the code in this branch as a baseline.
The actual perfs depend on the hardware, what we are interested in is getting a measure of improvement relative to the baseline.



