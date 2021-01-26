#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
label: "Knight lab bamMetrics - WGS"
baseCommand: ["/opt/bamMetrics"]
requirements:
    - class: DockerRequirement
      dockerPull: "sam16711/bam_metrics:v1"
    - class: ResourceRequirement
      ramMin: 10000
inputs:
    whole_genome_flag:
        type: boolean?
        default: true
        inputBinding:
            prefix: "-g"
            position: 1
    reference:
        type:
            - string
            - File
        inputBinding:
            prefix: "-r"
            position: 2
    output_filename:
        type: string
        default: "bam_metrics.txt"
        inputBinding:
            prefix: "-o"
            position: 3
    cram:
        type: File
        inputBinding:
            position: 4

outputs:
    bam_metrics:
        type: File
        outputBinding:
            glob: $(inputs.output_filename)
