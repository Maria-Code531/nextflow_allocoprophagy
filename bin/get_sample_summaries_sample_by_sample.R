#!/usr/bin/env Rscript

#### COMMAND LINE ARGUMENTS:
args = commandArgs(trailingOnly=TRUE)
sample_id=args[1]
chr=args[2] # just number
readcount_file=args[3] # readcount directory
outdir=args[4] # output directory, with sample name
genotypes=args[5] # directory with genotypes

# load readcounts
readcounts <- readRDS(file.path(readcount_file))
# if readcounts empty, store empty files and exit
if(nrow(readcounts) == 0){
  cat("no readcounts result, storing empty dataset to", outdir, "\n")
  sample_result = pair_result = vector(mode = "list", length =1)
  
  saveRDS(sample_result, paste0(outdir,"/sample_results_chr", chr, ".rds"))
  saveRDS(pair_result, paste0(outdir,"/pair_results_chr", chr, ".rds"))
  cat("quitting chr", chr,"\n")
  q("no", status = 0)
}


# get summaries for each cecum sample against all DNA samples, one chr
load(genotypes) 

# get ID of samples in genotypes, to align with cecum sample names
geno_id <- rownames(imp_snps)

# listing files of readcounts
# getting ID of samples in cecum sample (mb, for microbiome)
cecum_id <- sapply(strsplit( sample_id, "_"), "[", 1)

# check that all IDs with imp_snps data
cat(cecum_id,"\n")
cat(geno_id,"\n")
stopifnot(all(cecum_id %in% geno_id))
sample_result <- pair_result <- vector("list", length(readcount_file))
names(sample_result) <- names(pair_result) <- cecum_id

# find the position of the reads from cecum sample in the SNPs from genotypes
snpinfo_row <- match(readcounts$pos, snpinfo$pos) 

# should all have been found
stopifnot(!any(is.na(readcounts$pos)))

# column in genotype file
imp_snps_col <- snpinfo$gencol[snpinfo_row]

#Solution to the allele swap
#renaming readcounts columns as they are the opposite of the snps from the genotypes
colnames(readcounts) = c("pos", "allele2", "allele1", "count2", "count1")

stopifnot(all(snpinfo[imp_snps_col ,"allele1"] == readcounts[,"allele1"]))
stopifnot(all(snpinfo[imp_snps_col ,"allele2"] == readcounts[,"allele2"]))

# create object to contain the results for the single samples
sample_result[[1]] <- array(0, dim=c(nrow(imp_snps), 3, 2))
dimnames(sample_result[[1]]) <- list(rownames(imp_snps), c("AA", "AB", "BB"), c("A", "B"))

# count As and Bs in cecum sample at each type of g locus: j 1(homo A); 2(hetero); 3(homo BB)
#i = 1 # run when getting to understand each step
#j = 1 # run when getting to understand each step
for(i in 1:nrow(imp_snps)) {
  g <- imp_snps[i, imp_snps_col]
  for(j in 1:3) {
    sample_result[[1]][i,j,1] <- sum(readcounts$count1[!is.na(g) & g==j])
    sample_result[[1]][i,j,2] <- sum(readcounts$count2[!is.na(g) & g==j])
  }
}

# create object to contain the results for sample pairs
pair_result[[1]] <- array(0, dim=c(nrow(imp_snps), 3, 3, 2))
dimnames(pair_result[[1]]) <- list(rownames(imp_snps), c("AA", "AB", "BB"),
                                       c("AA", "AB", "BB"), c("A", "B"))

# count As and Bs in cecum sample at each combination of of g with g0 loci
g0 <- imp_snps[cecum_id, imp_snps_col]
#i=1
for(i in 1:nrow(imp_snps)) {
  # print(i)
  g <- imp_snps[i, imp_snps_col]
  for(j in 1:3) {
    for(k in 1:3) {
      pair_result[[1]][i,j,k,1] <- sum(readcounts$count1[!is.na(g0) & g0==j & !is.na(g) & g==k])
      pair_result[[1]][i,j,k,2] <- sum(readcounts$count2[!is.na(g0) & g0==j & !is.na(g) & g==k])
    }
  }
}

# Saving output files
saveRDS(sample_result, paste0(outdir,"/sample_results_chr", chr, ".rds"))
saveRDS(pair_result, paste0(outdir,"/pair_results_chr", chr, ".rds"))

