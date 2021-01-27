#!/bin/bash
#Positional Argument Input. sample dir, tmp_dir, out_dir.
OUT_DIR=/scratch1/fs1/jin810/pb_runs_scratch/crom_test/fq2ubam
TMP_DIR=/scratch1/fs1/jin810/pb_runs_scratch/crom_test/fq2ubam/tmp
#CROM_DIR=/storage1/fs1/jin810/Active/pb_runs/"$project_name"/pb_fq2bam/crom_run/cromwell-executions

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
# create cromwell-executions dir
#export CROM_DIR
#[ ! -d $CROM_DIR ] && mkdir -p $CROM_DIR
#echo "CROM Directory: $CROM_DIR"

#Main Script
bsub -q general -G compute-jin810 -R "select[mem>4GB] span[hosts=1] rusage[mem=4GB]" -a "docker(johnegarza/cromwell:latest)" \
-oo "$OUT_DIR"/bsub.out \
-eo "$OUT_DIR"/bsub.err \
-J cromtest \
/usr/bin/java -Dsystem.input-read-limits.lines=18000000 \
-Dconfig.file="/storage1/fs1/jin810/Active/analysis-workflows/cromwell_wdl/crom_test.conf" \
-Dsystem.job-shell=/bin/sh \
-jar "$STORAGE1"/cromwell/cromwell-54.jar run -i /storage1/fs1/jin810/Active/analysis-workflows/cromwell_wdl/crom_test.json \
/storage1/fs1/jin810/Active/analysis-workflows/cromwell_wdl/crom_test.wdl
