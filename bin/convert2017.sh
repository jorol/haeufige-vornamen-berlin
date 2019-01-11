#!/bin/bash

CSV_FOLDER=$1

for i in ${CSV_FOLDER}/*.csv;
    do csvcut -d ';' -c 2,1,3,4 $i > $i.new ;
    csvformat -D ';' $i.new > $i
    rm $i.new
done
