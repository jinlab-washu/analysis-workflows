
workflow pb_fq2gvcf {
	
	String infq
	Array[String] known_indels_sites_VCFs
	Array[String] known_indels_sites_VCFs_indicies
	String dbsnp_vcf
	String dbsnp_vcf_index
	String hapmap_resource_vcf
	String omni_resource_vcf
	String one_thousand_genomes_resource_vcf
	String mills_resource_vcf
	String axiomPoly_resource_vcf
	String ref
	String project
	
	String outdir
	String tmpdir
	String statsmerge_v2_washu


	call pb_fq2bam {
		input:
			infq = infq,
			ref=ref,
			dbsnp_vcf=dbsnp_vcf,
			known_indels_sites_VCFs =known_indels_sites_VCFs,
			tmpdir =tmpdir,
			outdir=outdir
	}
}
  # call pb_bammetrics {
	#	input:
	#		bam = fq2bam.bam
	#		ref = ref
	#}

	#call pb_haplotypecaller {
	#	input:
	#		ref=ref
	#		bam=fq2bam.bam
	#		recal=recal
	#}

	task pb_fq2bam {
		String ref
		String dbsnp_vcf
		String infq
		String tmpdir
		String outdir
		Array[String] known_indels_sites_VCFs
		command {
			/parabricks/run_pipeline.py fq2bam \
			--ref ${ref} \
			--knownSites ${sep=" --knownSites " known_indels_sites_VCFs} \
			--knownSites ${dbsnp_vcf} \
			--in-fq ${infq} \
			--out-bam ${outdir}/mark_dups_output.bam \
			--num-gpus 2 --x3 \
			--out-recal-file ${outdir}/bqsr_report.txt \
			--out-duplicate-metrics ${outdir}/dup_metrics.txt \
			--tmp-dir ${tmpdir} \
			--bwa-options="-Y"
		}
		runtime {
			docker: "us.gcr.io/ris-appeng-shared-dev/parabricks:v3.2.0"
			gpus: 2
			cpus: 24
			requested_memory: "100GB"
		}
		output {
			File markdupbam = "${outdir}/mark_dups_output.bam"
			File markdupbam_ind = "${outdir}/mark_dups_output.bam.bai"
			File bqsr = "${outdir}/bqsr_report.txt"
		}
}
 
