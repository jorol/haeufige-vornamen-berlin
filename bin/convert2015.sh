#!/bin/bash

CSV_FOLDER=$1

for i in ${CSV_FOLDER}/*.csv;
    do csvcut -d ';' -c 2,1,3 $i > $i.new ;
    mv $i.new $i
done
