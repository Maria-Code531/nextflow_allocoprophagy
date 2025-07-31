# A Nextflow pipeline for allocoprophagy detection
[![Nextflow](https://img.shields.io/badge/nextflow%20DSL2-%E2%89%A525.04.2-23aa62.svg)](https://www.nextflow.io/)
[![run with docker](https://img.shields.io/badge/run%20with-docker-0db7ed?labelColor=000000&logo=docker)](https://www.docker.com/)

This is a reproducible and automatic pipeline for the analysis of allocoprophagy detection in mice. 

This was developed in a course during the [UBDS3 summerschool](https://www.bds3.org/) 2025.

## Pipeline overview

1. **Trimmomatic**: remove the adapters 
2. **Bowtie2**: align the reads
3. **Samtools sort and index**: sort and index the bam
4. **Samtools mpileup**: create the pileups
5. **Read counts**: change the format into a matrix
6. **Sample summaries**: estimate distance and mixtures for the final analysis






