#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
label: "samtools flagstat"
baseCommand: ["/opt/samtools/bin/samtools", "flagstat"]
requirements:
    - class: ResourceRequirement
      ramMin: 4000
    - class: DockerRequirement
      dockerPull: "mgibio/samtools-cwl:1.0.0"
stdout: "$(inputs.bam.basename).flagstat"
inputs:
    bam:
        type: File
        inputBinding:
            position: 1
        secondaryFiles: [^.bai]
outputs:
    flagstats:
        type: stdout
