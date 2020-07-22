#!/bin/bash

#Takes 1 positional argument <analysis_ID>. Finds model_ids based of anlaysis project number
analysis_ID=$1
model_ids=$(genome model list --show=id --filter "analysis_project.id=$analysis_ID")
echo $model_ids
DIR=/gscmnt/gc2698/jin810/model_data/

#Loop to determine REAL model id numbers. model_ids will include header of ID column. This filters that information.
for i in $model_ids
do
    length=${#i}
    echo id is "$i" and length is "$length"
    if [ $length -gt 5 ]
    then
        echo "$i" passed test
        ls "$DIR/$i"/*/results/*.tsv
    fi
done
