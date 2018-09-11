#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
label: "samtools flagstat"
baseCommand: ["/opt/samtools/bin/samtools", "flagstat"]
requirements:
    - class: ResourceRequirement
      ramMin: 4000
    - class: DockerRequirement
      dockerPull: mgibio/cle
stdout: flagstat.out
inputs:
    cram:
        type: File
        inputBinding:
            position: 1
        secondaryFiles: [^.crai]
outputs:
    flagstats:
        type: stdout
