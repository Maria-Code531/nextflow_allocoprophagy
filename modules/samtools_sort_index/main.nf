
process SAMTOOLS_SORT_INDEX_BAM {

    // Here we use the meta.id as a tag. This will show in the terminal while running.
    // It is useful to identify which sample is being processed at the moment. Not an essential line, but a good practice.
    tag "${meta.id}"
    // Here we define in which container the process will run. Will will explain better how containers work later in the course.
    // For now, you can ignore this line.
    // If you did not manage to install Docker, please call us and we will help you update this line correspondingly.
    container 'quay.io/biocontainers/samtools:1.21--h50ea8bc_0'
    // This line will copy the output files to the specified directory.
    // Params.outdir is defined in the nextflow.config file.
    // You can change it to any directory you want either by modifying 
    // the nextflow.config file or by passing the parameter when running the pipeline with --outdir.
    // We will also explain better how to use config files later in the course ad you can now rely on this set up for testing.
    publishDir "${params.outdir}/sorted_alignment" , mode:'copy'

    input:
    // TODO: Define your inputs.
    // The input should be a tuple with the meta information and the bam file.
    tuple val(meta), path(bam)
    output: 
    tuple val(meta), path("${meta.id}_bam_samtools.bam.bai"),emit: index_bam
    tuple val(meta), path("${meta.id}_bam_samtools.bam"),emit: sorted_bam
    // TODO: Define your outputs.
    // emit the following outputs:
    // - sorted_bam: a tuple with the meta and the sorted bam file.
    // - bai: a tuple with the meta and the index file.


	script:
    // TODO: Complete the command line below to run samtools view and samtools sort.
    // TODO: Use below the samtools index <YOUR_SORTED_BAM> command to create the index file from your sorted bam file.
    // EXTRA TODO: use the --threads option to use the number of CPUs allocated to the task!
    """
    samtools view \\
        -b -F 4 \\
        $bam \\
                | samtools sort \\
        -o ${meta.id}_bam_samtools.bam 
    
    # TODO use the samtools index command to create the index file
    samtools index ${meta.id}_bam_samtools.bam
    """

}