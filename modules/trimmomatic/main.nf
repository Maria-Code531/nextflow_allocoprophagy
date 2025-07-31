process TRIMMOMATIC {
    // Here we use the meta.id as a tag. This will show in the terminal while running.
    // It is useful to identify which sample is being processed at the moment. Not an essential line, but a good practice.
    tag "$meta.id"
    // Here we define in which container the process will run. Will will explain better how containers work later in the course.
    // For now, you can ignore this line.
    // If you did not manage to install Docker, please call us and we will help you update this line correspondingly.
    container "quay.io/biocontainers/trimmomatic:0.39--hdfd78af_2"
    // This line will copy the output files to the specified directory.
    // Params.outdir is defined in the nextflow.config file.
    // You can change it to any directory you want either by modifying
    // the nextflow.config file or by passing the parameter when running the pipeline with --outdir.
    // We will also explain better how to use config files later in the course ad you can now rely on this set up for testing.
    publishDir("${params.outdir}/trimmomatic", mode: 'copy')
    input:
    // TODO: Define your inputs.
    tuple val(meta), path(reads)
    path(adapters)
    // Trimmomatic will nead both reads and adapters as input.
    // The reads will be paired and the adapters will be a single file.
    // You can find an example in the data folder.
    output:
    tuple val(meta), path("${meta.id}_output_forward_paired.fq.gz"), path("${meta.id}_output_reverse_paired.fq.gz"), emit: paired
    tuple val(meta), path("${meta.id}_output_forward_unpaired.fq.gz"), path("${meta.id}_output_reverse_unpaired.fq.gz"), emit: unpaired
    // TODO: Define your outputs.
    // emit the following outputs:
    // - paired_reads: a tuple with the meta and the two paired reads files.
    // - unpaired_reads: a tuple with the meta and the two unpaired reads files.
    // - log: a tuple with the meta and the log file.
    script:
    // TODO: Complete the command line below to run Trimmomatic.
    // Remember you can check the trimmomatic documentation.
    // You can assume you have paired-end reads.
    // Your output files should have the following naming convention:
    // - *.paired.trim_1.fastq.gz
    // - *.unpaired.trim_1.fastq.gz
    // - *.paired.trim_2.fastq.gz
    // - *.unpaired.trim_2.fastq.gz
    // EXTRA TODO: use the -threads option to use the number of CPUs allocated to the task!
    // EXTRA TODO: how could you pass the adapters file to the command line using $args?
    """
    trimmomatic PE \
        -trimlog ${meta.id}.log \
        $reads \
        ${meta.id}_output_forward_paired.fq.gz \
        ${meta.id}_output_forward_unpaired.fq.gz \
        ${meta.id}_output_reverse_paired.fq.gz \
        ${meta.id}_output_reverse_unpaired.fq.gz \
        ILLUMINACLIP:adapters.fa:2:30:10:2:keepBothReads LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36
    """
}