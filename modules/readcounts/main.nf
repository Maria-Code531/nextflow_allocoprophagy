
process READCOUNTS {
    // Here we use the meta.id and meta.chr as a tag. This will show in the terminal while running.
    // It is useful to identify which sample is being processed at the moment. Not an essential line, but a good practice.
    tag "$meta.id $meta.chr"
    // Here we define in which container the process will run. Will will explain better how containers work later in the course.
    // For now, you can ignore this line.
    // If you did not manage to install Docker, please call us and we will help you update this line correspondingly.
    container "community.wave.seqera.io/library/r-optparse_r-stringr:cf40ec38424ef258"
    // This line will copy the output files to the specified directory.
    // Params.outdir is defined in the nextflow.config file.
    // You can change it to any directory you want either by modifying
    // the nextflow.config file or by passing the parameter when running the pipeline with --outdir.
    // We will also explain better how to use config files later in the course ad you can now rely on this set up for testing.
    publishDir("${params.outdir}/readcounts", mode: "copy")
    input:
    // TODO: Define your inputs (look at the input script below)
    // You will need the a tuple with:
    // - the sample id and the chromosome number, which are stored in the meta
    // - the path to the pileups (have a look in <MODULE>/data/pileups/)
    // - the path to the snp_positions (have a look in <MODULE>/data/genotypes)
    // You can find an example of files in the data folder.
    tuple val(meta), path(pileup), path(snp)
    output:
    // TODO: Define your outputs.
    // emit the output in a tuple:
    // - with meta
    // - and path to readcounts (look at the script outputs below to see the structure)
    // !TIP: when the output has some variable parts, such as the <SAMPLE_ID> or <CHR> you can use a * instead,
    //       in this way you can indicate the general structure of the output, leaving the flexible parts flexible (the * is used to indicate any possible character)
    tuple val(meta), path("*/chr*_readcount.rds"), emit: counts
    script:
    // TODO: substitue the <...> with the input needed
    // !TIP: the SAMPLE_ID is stored in the meta, you can access to it as $meta.id
    // !TIP: the CHR is stored in the meta, you can access to it as $meta.chr
    """
    mkdir -p ${meta.id}
    get_readcounts_from_pileups.R \
    --sample $pileup \
    --geno $snp \
    --chr ${meta.chr} \
    --out "${meta.id}/chr${meta.chr}_readcount.rds"
    """
    /*
    The Rscript takes the following arguments:
    --sample: input pileup file of the sample,      e.g. 001_test/chr1.pup.gz
    --geno: input file to snp positions,            e.g. chr1_pos_alleles.tsv
    --chr: input chromosome number,                 e.g. 1
    --out: output file name,                        e.g. 001_test/chr1_readcount.rds
    */
}