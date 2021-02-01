name: "crawler"

includes:
    - resource: true
      file: "/crawler-default.yaml"
      override: false

    - resource: false
      file: "crawler-conf.yaml"
      override: true

spouts:
  - id: "spout"
    className: "com.digitalpebble.stormcrawler.warc.WARCSpout"
    parallelism: 1
    constructorArgs:
      - "warc/"
      - "index.lst"

bolts:
  - id: "parse"
    className: "com.digitalpebble.stormcrawler.bolt.JSoupParserBolt"
    parallelism: 4
  - id: "index"
    className: "com.digitalpebble.stormcrawler.indexing.DummyIndexer"
    parallelism: 1
  - id: "status"
    className: "com.digitalpebble.stormcrawler.vespa.persistence.StatusUpdaterBolt"
    parallelism: 1

streams:
  - from: "spout"
    to: "parse"
    grouping:
      type: SHUFFLE
      
  - from: "parse"
    to: "index"
    grouping:
      type: LOCAL_OR_SHUFFLE

  - from: "spout"
    to: "status"
    grouping:
      type: FIELDS
      args: ["url"]
      streamId: "status"
 
  - from: "parse"
    to: "status"
    grouping:
      type: FIELDS
      args: ["url"]
      streamId: "status" 
      
  - from: "index"
    to: "status"
    grouping:
      type: FIELDS
      args: ["url"]
      streamId: "status"
  
