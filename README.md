``` sh
mvn clean package

aws s3 cp s3://commoncrawl/crawl-data/CC-MAIN-2020-50/segments/1606141163411.0/warc/CC-MAIN-20201123153826-20201123183826-00001.warc.gz warc
aws s3 cp s3://commoncrawl/crawl-data/CC-MAIN-2020-50/segments/1606141163411.0/warc/CC-MAIN-20201123153826-20201123183826-00000.warc.gz warc

aws s3 cp s3://commoncrawl/crawl-data/CC-MAIN-2020-50/segments/1606141163411.0/warc/ warc --recursive

rm warc/index.lst
for f in `ls warc | grep '.gz$'`; do echo $PWD/warc/$f >> warc/index.lst; done

docker compose up -d

./ES_IndexInit.sh

storm local --local-ttl 9999999 target/benchmark-1.0-SNAPSHOT.jar  org.apache.storm.flux.Flux benchmark.flux 

```



