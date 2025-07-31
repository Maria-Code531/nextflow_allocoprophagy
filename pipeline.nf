include {TRIMMOMATIC} from "./modules/trimmomatic/main.nf"
include {BOWTIE2} from "./modules/bowtie2/main.nf"
include {SAMTOOLS_SORT_INDEX_BAM} from "./modules/samtools_sort_index/main.nf"
include {SAMTOOLS_MPILEUP} from "./modules/samtools_mpileup/main.nf"
include {READCOUNTS} from "./modules/readcounts/main.nf"
include {SAMPLE_SUMMARIES} from "./modules/sample_summaries/main.nf"


workflow{
    reads = Channel.fromFilePairs("./data/reads/*_{1,2}.fastq.gz")
                   .map{
                       sample, reads -> [[ id: sample], reads ]
                   }
   
    adapters = Channel.fromPath("./data/reads/*.fa").collect()

    //reads.view()
    //adapters.view()

    TRIMMOMATIC(reads, adapters)

    indexes = Channel.fromPath("./data/bowtie_index/*.bt2")
                   .map{
                        indexes -> [[ id: indexes.baseName.split("\\.")[0] ], indexes]
                    }.groupTuple().collect()

    //indexes.view()

    paired_reads = TRIMMOMATIC.out.paired

    unpaired_reads = TRIMMOMATIC.out.unpaired

    trimmed_reads = paired_reads.combine(unpaired_reads, by:0).map{id, f1, f2, f3, f4 -> [id, [f1, f2, f3, f4]]}
    
    BOWTIE2(trimmed_reads, indexes) 

    alignet_reads = BOWTIE2.out.bowtie_ch

    SAMTOOLS_SORT_INDEX_BAM(alignet_reads)

    samtools_indexes = SAMTOOLS_SORT_INDEX_BAM.out.index_bam
    sorted_reads = SAMTOOLS_SORT_INDEX_BAM.out.sorted_bam

    //samtools_indexes.view()
    //sorted_reads.view()

    chr = Channel.of(1..20)
    sorted_bam_bai = sorted_reads.combine(samtools_indexes, by:0).combine(chr)

    SAMTOOLS_MPILEUP(sorted_bam_bai)
    SAMTOOLS_MPILEUP.out.piled

    pileup = SAMTOOLS_MPILEUP.out.piled.map{meta, chr, file -> [chr.toString(), meta, file]}
    snps = Channel.fromPath("./data/snps/*_pos_alleles.tsv").map{ file -> [file.baseName.split('_')[0].replaceAll('chr', ''), file] }
    input = pileup.combine(snps, by:0).map{chr, meta, file1, file2 -> [[id:meta.id, chr:chr], file1, file2]}

    READCOUNTS(input)
    READCOUNTS.out.counts

    readcounts = READCOUNTS.out
                 .map{
                      meta, pileup -> [meta.chr, meta.id, pileup] 
                 }
    // 2. genotypes from spleen
    genotypes = Channel.fromPath("./data/genotypes/imp_snp_*.RData")
   		               .map { 
    		   	            snps -> [ snps.baseName.replaceAll("imp_snp_", ""), snps ]  
			            }
    readcount_geno = readcounts.combine(genotypes, by: 0)
                               .map{ chr, sample, readcount, genotype -> [[ id: sample, chr: chr ], readcount, genotype]}
    
    // Getting sample summaries - distance and mixture
    SAMPLE_SUMMARIES(readcount_geno)   

    distances = SAMPLE_SUMMARIES.out.distance_sample_summaries
    mixtures = SAMPLE_SUMMARIES.out.mixture_sample_summaries

    distances.view()
    mixtures.view()






    //alignet_reads.view()
}