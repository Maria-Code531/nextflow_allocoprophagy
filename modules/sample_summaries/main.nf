process SAMPLE_SUMMARIES {
    
    tag "$meta.id $meta.chr" 
    container "kautharomar/mbmixture:v1.0" 
    publishDir("${params.outdir}/sample_summaries", mode: "copy")

    input:
    tuple val(meta), path(readcounts), path(genotypes)

    output:
    tuple val(meta), path("*/sample_results_chr*.rds"), emit: distance_sample_summaries
    tuple val(meta), path("*/pair_results_chr*.rds"), emit: mixture_sample_summaries            


    script:
    """
    mkdir -p sample_${meta.id}
    get_sample_summaries_sample_by_sample.R ${meta.id} ${meta.chr} ${readcounts} sample_${meta.id} $genotypes
    """
    /*
    The Rscript takes the following arguments:
    [1]: sample_id = the sample id,                       e.g. 001_test
    [2]: chr = the chromosome number,                     e.g. 1
    [3]: readcount_file = the readcounts file,            e.g. chr1_readcount.rds
    [4]: outdir = the output directory, with sample name, e.g. sample_001_test
    [5]: genotypes = the genotypes file,                  e.g. imp_snp_1.RData
    
    the outputs are:
    [1]: distances -> in file <SAMPLE_ID>/sample_results_chr<CHR>.rds,  e.g. 001_test/sample_results_chr1.rds
    [2]: mixtures -> in file <SAMPLE_ID>/pair_results_chr<CHR>.rds,     e.g. 001_test/pair_results_chr1.rds
    */

}

