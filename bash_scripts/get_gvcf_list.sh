#!/bin/bash

#Takes 1 positional argument: gms analysis project ID <analysis_ID>.
#Finds model_ids based of anlaysis project number. Outputs a bsub job to MergeVCFs for all chromosome files ( .g.vcf files)
#for a finsihed model.

analysis_ID=$1
outDIR=/gscmnt/gc2698/jin810/jointcalling/"$analysis_ID"
outfile=/gscmnt/gc2698/jin810/jointcalling/"$analysis_ID"/gvcfs_hg38.list
model_ids=$(genome model list --show=id --filter "analysis_project.id=$analysis_ID")
DIR=/gscmnt/gc2698/jin810/model_data
logs_dir="$outDIR"/logs
#Main loop that iterates through model ids.
#file_array=()
#path_array=()

#Checks if directory already exists. Creates new if it does not.
if [ -d "$outDIR" ]
then
    echo "directory already made for analysis project"
else
    echo "Making directory for $outDIR"
    mkdir -p "$outDIR"
fi

#Makes new .list file for all merged gvcf files
if [ -f "$outfile" ]
then
    echo "gvcf.list already exists...deleting"
    rm "$outfile"
else
    echo "Making new gvcf.list"
fi
touch "$outfile"

for i in $model_ids
do
    #Filters headers of genome model list by length of characters. ID's are about 32 characters in length.
    length=${#i}
    #echo id is "$i" and length is "$length"
    if [ $length -gt 5 ]
    then
        model_sub=( $(genome model list --show=subject --filter "genome_model_id=$i") ) #Saves output as array
        echo subject is ${model_sub[2]}

        #Block below finds builds for all models of an analysis project, gathers .gvcfs, and submits MergeVcf on the gvcfs for each sample (build)
        #Produces an intermediate file that contains a list of all the .gvcf paths named chrom_gvcfs.list.
        build=$(ls "$DIR/$i"/)
        for x in $build
        do
	    outFinal="$outDIR" #Final directory location. Output is now directed here.
            
            #Checks for *merged.vcf.gz in output directory of model_data/MODEL/BUILD/results
            if [ -f "$DIR/$i/$x/results/"*merged.vcf.gz ]
            then
                data=$(ls "$DIR/$i/$x/results/"*merged.vcf.gz)
                echo -e "${model_sub[2]}\t$data"  >> "$outfile"
            else
                echo "merged.vcf.gz file not found for "$x""
            fi

        done
    fi
done

#Checks for a logs directory. Creates one if not found.
if [ -d "$logs_dir" ]
then
    echo log directory already created
else
    mkdir "$logs_dir"
    echo created log directory
fi

#Create cromwell.options file
echo -e "{\n\t"'"final_workflow_outputs_dir"': '"'"$outDIR"'"', \
"\n\t"'"final_workflow_log_dir"': '"'"$logs_dir"'"', \
"\n\t"'"final_call_logs_dir"': '"'"$logs_dir"'"' \
"\n}" > "$outDIR"/cromwell.options