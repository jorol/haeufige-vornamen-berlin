#!/bin/bash

CSV_FOLDER=$1

for i in ${CSV_FOLDER}/*.csv;
    do csvformat -d ';' $i > $i.new ;
    mv $i.new $i
done
