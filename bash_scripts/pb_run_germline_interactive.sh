#!/bin/bash
#Positional Argument Input. sample dir, tmp_dir, out_dir.
project_name=$1
IN_DIR=/storage1/fs1/jin810/Active/pb_runs/"$project_name"
OUT_DIR=/storage1/fs1/jin810/Active/pb_runs/"$project_name"/pb_germline_output
TMP_DIR=/scratch1/fs1/jin810/pb_runs_scratch/"$project_name"
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
export SCRATCH1=/scratch1/fs1/jin810

#use your Active storage for input and output data
export STORAGE1=/storage1/fs1/jin810/Active
export BGA=/storage1/fs1/bga/Active/
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
[ ! -d $TMP_DIR ] && mkdir $TMP_DIR
echo "Temp Directory: $TMP_DIR"
# create out dir
export OUT_DIR
[ ! -d $OUT_DIR ] && mkdir $OUT_DIR
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

bsub -G compute-jin810 -n 32 -M 196GB -R 'rusage[mem=196GB] span[hosts=1]' \
-Is -q general-interactive -gpu "num=4:gmodel=TeslaV100_SXM2_32GB" -a 'docker(registry.gsc.wustl.edu/cpohl/parabricks:v3.0.0)' \
/parabricks/run_pipeline.py germline \
--ref /storage1/fs1/bga/Active/gmsroot/gc2560/core/model_data/2887491634/build21f22873ebe0486c8e6f69c15435aa96/all_sequences.fa \
$input_str \
--knownSites /storage1/fs1/bga/Active/gmsroot/gc2560/core/build_merged_alignments/detect-variants--linus2112.gsc.wustl.edu-jwalker-19443-e48c595a620a432c93e8dd29e4af64f2/snvs.hq.vcf.gz \
--knownSites /storage1/fs1/bga/Active/gmsroot/gc2560/core/build_merged_alignments/detect-variants--linus2112.gsc.wustl.edu-jwalker-20267-00cb8ff552914c17ad66d86031e10d30/indels.hq.vcf.gz \
--knownSites /storage1/fs1/bga/Active/gmsroot/gc2560/core/build_merged_alignments/detect-variants--linus2112.gsc.wustl.edu-jwalker-20211-26b393cc7ab04120ac68cc2cbd4a15df/indels.hq.vcf.gz \
--knownSites /storage1/fs1/bga/Active/gmsroot/gc2709/info/production_reference_GRCh38DH/accessory_vcf/omni25-ld-pruned-20000-2000-0.5-annotated.wchr.sites_only.b38.autosomes_only.vcf.gz \
--out-bam "$OUT_DIR"\output.bam \
--num-gpus 4 --x3 --tmp-dir $TMP_DIR \
--bwa-options="-Y" \--out-bam "$OUT_DIR"\output.bam \
--out-variants "$OUT_DIR"\output.vcf \
--out-recal-file "$OUT_DIR"\report.txt \
--out-duplicate-metrics "$OUT_DIR"\dup_metrics.txt \
--gvcf \
--tmp-dir $TMP_DIR \
--static-quantized-quals 10 \
--static-quantized-quals 20 \
--static-quantized-quals 30
