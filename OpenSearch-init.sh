#!/bin/bash

OSHOST=${1:-"http://localhost:9200"}
OSCREDENTIALS=${2:-"-u opensearch:passwordhere"}

for name in status
do
  curl $OSCREDENTIALS -s -XDELETE "$OSHOST/$name/" >  /dev/null
  echo "Deleted '$name' index, now recreating it..."
  curl $OSCREDENTIALS -s -XPUT "$OSHOST/$name" -H 'Content-Type: application/json' --upload-file $name.mapping
  echo ""
done

curl $OSCREDENTIALS "$OSHOST/$name/_count"
