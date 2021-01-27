#!/bin/bash
#Positional Argument Input. project_name 
project_name=$1
IN_DIR=/storage1/fs1/jin810/Active/pb_runs/"$project_name"/haplotypecaller/less_res/result.g.vcf.gz
DB_DIR=/storage1/fs1/jin810/Active/pb_runs/"$project_name"/creategenomicsdb/less_re/database
OUT_DIR=/storage1/fs1/jin810/Active/pb_runs/"$project_name"/importgvcfstodb/less_res
TMP_DIR=/scratch1/fs1/jin810/pb_runs_scratch/"$project_name"/importgvcfstodb/less_res

#Check for project name. If none supplied, exit.
if [ -z $project_name ]; then
        echo No project name entered! You must provide a project name after the script. E.g. ./pb_fq2gvcf.sh NA12878
        exit 1
fi

#use the scratch file system for temp space
export SCRATCH1=/scratch1/fs1/jin810

#use your Active storage for input and output data
export STORAGE1=/storage1/fs1/jin810/Active
export BGA=/storage1/fs1/bga/Active
# INSTALL path contains the mapping for the parabricks licenses and is required
export LSF_DOCKER_VOLUMES="/scratch1/fs1/ris/application/parabricks:/INSTALL $BGA:$BGA $SCRATCH1:$SCRATCH1 $STORAGE1:$STORAGE1 $HOME:$HOME"

# use host level communications for the GPUs
export LSF_DOCKER_NETWORK=host

# use the debug flag when trying to figure out why your job failed to launch on the cluster
#export LSF_DOCKER_RUN_LOGLEVEL=DEBUG

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
# you may need to adjust your cores (-n) and memory (-M and mem) depending on your data set
# 1 GPU server should have 64GB CPU RAM, at least 16 CPU threads
# 2 GPU server should have 100GB CPU RAM, at least 24 CPU threads
# 4 GPU server should have 196GB CPU RAM, at least 32 CPU threads
# you can run this interactive (-Is) or in batch mode in the general or general-interactive queues
# sets GPUs to 4 for LSF and parabricks and probably want to keep this unless your data set is smaller than 5GB test data set
# there is diminishing returns on using more GPUs on small data sets
# the parabricks container and the /parabricks/run_pipeline.py is required
# the last is where you put in any of the pubrun commands like fq2bam, bqsr, applybqsr, haplotypecaller
# see the parabricks docs here: https://www.nvidia.com/en-us/docs/parabricks/

bsub -oo "$OUT_DIR"/out.txt -eo "$OUT_DIR"/err.txt -G compute-jin810 -n 24 -M 100GB -R 'rusage[mem=100GB] span[hosts=1]' \
-q general -gpu "num=2:gmodel=TeslaV100_SXM2_32GB:j_exclusive=yes" -a 'docker(registry.gsc.wustl.edu/cpohl/parabricks:v3.0.0.6)' \
/parabricks/run_pipeline.py creategenomicsdb \
--dir "$DB_DIR" \
--in-gvcf IN_DIR \
--num-threads 4
