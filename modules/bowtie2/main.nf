
// TODO: Change <YOUR_MODULE_NAME> to the name of your module.
process BOWTIE2 {

    // Here we use the meta.id as a tag. This will show in the terminal while running.
    // It is useful to identify which sample is being processed at the moment. Not an essential line, but a good practice.
    tag "$meta.id"
    // Here we define in which container the process will run. Will will explain better how containers work later in the course.
    // For now, you can ignore this line.
    // If you did not manage to install Docker, please call us and we will help you update this line correspondingly.
    container "community.wave.seqera.io/library/bowtie2_htslib_samtools_pigz:edeb13799090a2a6"
    // This line will copy the output files to the specified directory.
    // Params.outdir is defined in the nextflow.config file.
    // You can change it to any directory you want either by modifying 
    // the nextflow.config file or by passing the parameter when running the pipeline with --outdir.
    // We will also explain better how to use config files later in the course ad you can now rely on this set up for testing.
    publishDir("${params.outdir}/alignment", mode: 'copy')

    input:
    tuple val(meta), path(reads)
    tuple val(meta_index), path(index)
    // TODO: Define your inputs.
    // You will need 2 tuples:
    // - the first tuple should contain the meta information and the reads files.
    // - the second tuple should contain the meta information and the index files.
    // call the meta for the first tuple `meta` and the meta for the second tuple `meta_index`.

    output:
    tuple val(meta), path("${meta.id}.bam"), emit: bowtie_ch
    // TODO: Define your outputs.
    // emit the following outputs:
    // - a tuple with the meta and the bam file.

    script:
    // TODO: Complete the command line below to run Bowtie2.
    // Remember you can check the Bowtie2 documentation.
    // You can assume you have paired-end reads and unpaired reads.
    // TODO: use the -x option to specify the index files. This should be the id of the meta_index tuple.
    // TODO: pass your input files
    // -1 for the first read, -2 for the second read, and -U for unpaired reads.
    // EXTRA TODO: use the -p option to use the number of CPUs allocated to the task for bowtie
    // EXTRA TODO: use the --threads option to use the number of CPUs allocated to the task for samtools

    """
    bowtie2 \\
        -x ${meta_index.id} \\
        -1 ${reads[0]} \\
        -2 ${reads[1]} \\
        -U ${reads[2]} ${reads[3]} \\
        | samtools view -Sb > ${meta.id}.bam
    """


}