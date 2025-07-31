
// TODO: Change <YOUR_MODULE_NAME> to the name of your module.
process SAMTOOLS_MPILEUP {
    // Here we use the meta.id as a tag. This will show in the terminal while running.
    // It is useful to identify which sample is being processed at the moment. Not an essential line, but a good practice.
    tag "$meta.id" // prints the id of the sample that is being analyzed
    // Here we define in which container the process will run. Will will explain better how containers work later in the course.
    // For now, you can ignore this line.
    // If you did not manage to install Docker, please call us and we will help you update this line correspondingly.
    container "quay.io/biocontainers/samtools:1.21--h50ea8bc_0" // the process is run in this container, even tho samtools is not installed
    // This line will copy the output files to the specified directory.
    // Params.outdir is defined in the nextflow.config file.
    // You can change it to any directory you want either by modifying
    // the nextflow.config file or by passing the parameter when running the pipeline with --outdir.
    // We will also explain better how to use config files later in the course ad you can now rely on this set up for testing.
    publishDir "${params.outdir}/samtools_mpileup", mode: 'copy' // publish into this folder
    input:
    // TODO: Define your inputs.
    // You will need a tuple with:
    // - the sample id, which is stored in the meta of both sorted bam and bai files
    // - the path to bam of sorted reads
    // - the path to the corresponding bai file
    // - the chromosome number (as a value)
    // You can find an example of files in the data folder.
    tuple val(meta), path(bam), path(bai), val(chr)
    output:
    // TODO: Define your outputs.
    // emit the following outputs in a tuple:
    // - the meta
    // - the chromosome number (as a value)
    // - the path to pileup file (which need to match the output from the script)
    // !TIP: when the output has some variable parts, such as the <SAMPLE_ID> or <CHR> you can use a * instead
    //       in this way you can indicate the general structure of the output, leaving the flexible parts flexible (the * is used to indicate any possible character)
    tuple val(meta), val(chr), path("${meta.id}/chr*.pup.gz"), emit: piled
    // TODO: substitue the <...> with the input needed
    // !TIP: the SAMPLE_ID is stored in the meta, you can access to it as $meta.id
    script:
    """
    mkdir -p "${meta.id}"
    samtools mpileup --ff 12 -xA -r ${chr} ${bam} \
            --no-output-ins \
            --no-output-del \
            --no-output-ends | gzip > "${meta.id}/chr${chr}.pup.gz"
    """
    // 1. first we create a directory called <SAMPLE_ID> to store the results by chromosome
    // 2. then we execute samtools mpileup
    //    briefly the options are: (you can read for more details here https://www.htslib.org/doc/samtools-mpileup.html)
    //    --ff 12 : Excludes reads that were unmapped (flag 4: read unmapped, flag 8: mate unmapped; 4+8 = 12)
    //    -xA : Disables data-type auto-detection for more predictable output format
    //    -r <CHR_NUMBER> : Restricts analysis to a specific chromosome
    //    --no-output-ins : Suppresses insertion information in the pileup output
    //    --no-output-del : Suppresses deletion information in the pileup output
    //    --no-output-ends - Suppresses information about read start/end positions
    //
    // 3. with gzip we compress the file
}