#!/bin/bash
#Positional Argument Input. sample dir, tmp_dir, out_dir.
project_name=$1
IN_DIR=/storage1/fs1/jin810/Active/pb_runs/NA12878
OUT_DIR=/storage1/fs1/jin810/Active/pb_runs/NA12878/pb_fq2bam/crom_run
TMP_DIR=/storage1/fs1/jin810/Active/pb_runs/NA12878/pb_fq2bam/crom_run/logs
#CROM_DIR=/storage1/fs1/jin810/Active/pb_runs/"$project_name"/pb_fq2bam/crom_run/cromwell-executions

if [ -z $project_name ]; then
	echo No project name entered! You must provide a project name after the script. E.g. ./pb_fq2gvcf.sh NA12878
	exit 1
fi

samples=$( ls -d "$IN_DIR"/samples/*)

#Files must be in specific format. $Sample_name/*.fastq.gz (2 files only)
#Gather Fastq Files for Run
input_str=""
count=0
for s in $samples
do
    echo Samples: "$samples"
    echo Sample: "$s"
    fq=( $( ls -d "$s"/*.fastq.gz ))
    #echo "${#fq[*]}"
    fq1=${fq[0]}
    fq2=${fq[1]}

    #Check for pairs of fastq samples. If more than 2 exit.
    if [ "${#fq[*]}" -ne 2 ];then
        echo Greater or less than 2 fastq found for "$s"!
        exit
    fi

    input_str+="--in-fq $fq1 $fq2"
    echo "$input_str"
done

#use the scratch file system for temp space
export SCRATCH1=/scratch1/fs1/jin810/pb_runs_scratch

#use your Active storage for input and output data
export STORAGE1=/storage1/fs1/jin810/Active
export BGA=/storage1/fs1/bga/Active
# INSTALL path contains the mapping for the parabricks licenses and is required
export LSF_DOCKER_VOLUMES="/scratch1/fs1/ris/application/parabricks:/INSTALL $BGA:$BGA $SCRATCH1:$SCRATCH1 $STORAGE1:$STORAGE1 $HOME:$HOME"

# use host level communications for the GPUs
export LSF_DOCKER_NETWORK=host

# use the debug flag when trying to figure out why your job failed to launch on the cluster
export LSF_DOCKER_RUN_LOGLEVEL=DEBUG

# use the entry point because the parabricks container has other entrypoints but our cluster requires /bin/sh
export LSF_DOCKER_ENTRYPOINT=/bin/sh

# create tmp dir
export TMP_DIR
[ ! -d $TMP_DIR ] && mkdir -p $TMP_DIR
echo "Temp Directory: $TMP_DIR"
# create out dir
export OUT_DIR
[ ! -d $OUT_DIR ] && mkdir -p $OUT_DIR
echo "Out Directory: $OUT_DIR"

export SCRATCH1
[ ! -d $SCRATCH1 ] && mkdir $SCRATCH1
echo "Scratch Directory: $SCRATCH1"

# create cromwell-executions dir
#export CROM_DIR
#[ ! -d $CROM_DIR ] && mkdir -p $CROM_DIR
#echo "CROM Directory: $CROM_DIR"

#Main Script
bsub -q general -G compute-jin810 -R "select[mem>4GB] span[hosts=1] rusage[mem=4GB]" -a "docker(registry.gsc.wustl.edu/apipe-builder/genome_perl_environment:compute1-8)" \
-oo "$OUT_DIR"/bsub.out \
-eo "$OUT_DIR"/bsub.err \
-J "$project_name"_run \
/usr/bin/java -Dsystem.input-read-limits.lines=18000000 \
-Dconfig.file="/storage1/fs1/jin810/Active/analysis-workflows/cromwell_wdl/pb_fq2gvcf_crom_config.conf" \
-Dsystem.job-shell=/bin/sh \
-jar "$STORAGE1"/cromwell/cromwell-54.jar run -i /storage1/fs1/jin810/Active/analysis-workflows/cromwell_wdl/pb_fq2gvcf.json \
/storage1/fs1/jin810/Active/analysis-workflows/cromwell_wdl/pb_fq2gvcf.wdl
