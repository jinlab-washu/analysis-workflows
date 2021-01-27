
workflow crom_test {
	
	String infq1
	String infq2
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
			infq1 = infq1,
			infq2 = infq2,
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
		String infq1
		String infq2
		String tmpdir
		String outdir
		command {
			/gatk/gatk FastqToSam \
			-F1 ${infq1} \
			-F2 ${infq2} \
			-SM ch \
			-O ${tmpdir}/test_ubam.bam	
		}
		runtime {
			docker: "broadinstitute/gatk:4.1.9.0"
			cpus: 4
			requested_memory: "20GB"
		}
		output {
			File ubam = "${tmpdir}/test_ubam.bam"
		}
}
 
