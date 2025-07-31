#!/usr/bin/env Rscript

cat("Loading libraries \n")
suppressMessages(library("stringr"))
suppressMessages(library("optparse"))

option_list = list(make_option("--sample", action="store", default=NA, type='character'
			       , help="Path to a pileup file with .pup from `samtools mpileup` [required]"),
		   make_option("--geno", action="store", default=NA, type='character',
			       help="Path to DIRECTORY WITH GENOTYPE SNPs per chr [required]"),
		   make_option("--chr", action="store", default=NA, type='character', 
			       help="Chr in analysis [required]"),
		   make_option("--out", action="store", default=NULL, type='character',
			       help="output file, [required]"))

opt = parse_args(OptionParser(option_list=option_list))

cat("Getting options", "\n")
chr=opt$chr #NB: need the quotes to put it as a character
geno=opt$geno
pileup=opt$sample
if(is.null(opt$out)){
	cat("Missing output file name", "\n")
}else{out=opt$out}


# 1. Getting snp pos and alleles
snp_path <- file.path(geno)
snps <- read.delim(file=snp_path, header = F, sep="\t", 
		   col.names = c("chr", "pos", "allele2", "allele1"))

# 2. Getting pileups
file <- file.path(pileup)
cat("Reading pileup from: ",file, "\n")
mpileup <- read.delim(file=file, header=F, quote="", 
				col.names=c("seqnames", "pos", "ref", "count", "nucleotides", "quality"))	
# filtering positions for genotyped snps
mpileup <- mpileup[mpileup$count != 0,,drop=FALSE]
mpileup <- mpileup[mpileup$pos %in% snps$pos,,drop=FALSE]

# if mpileup empty 
# generate empty file 
# quit script
if(nrow(mpileup) == 0){
  cat("no pileup result, storing empty dataset to", out, "\n")
  empty <- data.frame(
    pos = numeric(0),
    allele1 = character(0),
    allele2 = character(0),
    count1=numeric(0),
    count2=numeric(0)
  )
  saveRDS(empty, file=out, compress=T)
  cat("quitting chr", chr,"\n")
  q("no", status = 0)
}


# 3. Getting freq of counts per position
freq <- as.data.frame(table(mpileup$count)); colnames(freq) <- c("counts","freq")
cat("\nSTART chr",chr,"\nn° positions genotyped in mpileup: ", nrow(mpileup), "\nwith freq: \n"); 
print(freq)


# 4. Getting allele counts
cat("getting counts", "\n")
counts <- data.frame(pos=mpileup$pos,
		     A=NA,
		     C=NA,
		     G=NA,
		     T=NA,
		     nucleotides=mpileup$nucleotides)

for (b in c("A", "C", "G", "T")){
	counts[,b] <- str_count(toupper(counts[,"nucleotides"]), b)
}

# 5. Removing pos with 0 count - i.e. A,C,G,T ==0 
counts <- counts[apply(counts[,2:5], 1, function(x) !all(x==0)),]

# 6. Unifing counts for more than one position
tot_count <- data.frame(pos=unique(counts$pos),
		A=NA,
		C=NA,
		G=NA,
		T=NA)

for(b in c("A", "C", "G", "T")){
	c <- tapply(counts[,b],list(counts$pos),sum); 
	m <- match(rownames(c),tot_count$pos); 
	tot_count[m,b] <- c}

# 7. Check count
for(b in c("A", "C", "G", "T")){stopifnot(sum(counts[,b]) == sum(tot_count[,b]))}

# 8. Getting count per allele1 and allele2 respect to genotyped snps
cat("getting count per allele1 and allele2 respect to genotyped snps", "\n")
result <- data.frame(pos=unique(tot_count$pos),
		     allele1=NA,
		     allele2=NA,
		     count1=0,
		     count2=0)

result$allele1 <- snps$allele1[match(result$pos, snps$pos)]
result$allele2 <- snps$allele2[match(result$pos, snps$pos)]

m <- match(result$pos, tot_count$pos)
for(a in c("A", "C", "G", "T")) {
	result[result$allele1==a,"count1"] <- tot_count[m,][result$allele1==a,a]
	result[result$allele2==a,"count2"] <- tot_count[m,][result$allele2==a,a]
}

result <- result[order(result$pos),]
### CHECKING RESULTS
# result[result$count1==2 & 
#        (result$pos %in% mpileup[mpileup$count == 2,"pos"] | result$pos %in% dupli$pos),]

# result[result$count2==2 & 
#        (result$pos %in% mpileup[mpileup$count == 2,"pos"] | result$pos %in% dupli$pos),]

# Comparing counts from result vs original mpileup
# 	discrepancies may be due to:
# 		1. in mpileup I have some position with "count" = N and in "nucleotides" have * - i.e. missing
# 			will not be present in counting
# 		2. have a nucleotide in mpileup but not corresponding to Allele1/2 

cat("Checking counts from result vs original mpileup", "\n")
#getting counts from results
res_tot <- sum(result$count1) + sum(result$count2)

#getting counts from original mpileup
mp_tot <- sum(mpileup$count)

if(res_tot != mp_tot){
	cat("Different count from initial mpileup: ", mp_tot, "\t result count is: ", res_tot, "\n")
	cat("Different count due to : \n")
	eli <- merge(result, tot_count, by="pos")
	diff <- eli[apply(eli[,4:9], 1, function(x){x[1]+x[2] != x[3]+x[4]+x[5]+x[6]}),]
	cat("\tn° different counts: ", 
	    sum(diff$A, diff$C, diff$T, diff$G) - sum(diff$count1,diff$count2), 
	    "\n")
#	print(diff)
	miss <- mpileup[grep("[*]", mpileup$nucleotides), ]
	miss <- miss[miss$count != 0,]
	cat("\tpositions with missing nucleotides: ", nrow(miss), "\n")
	print(miss)
	cat("END chr", chr,"\n")
}else{
	cat("count from initial mpileup equal to result count: ", mp_tot, " == ", res_tot, "\n")
	cat("END chr", chr,"\n")
}

# Saving output
cat("writing file to ", out, "\n")
saveRDS(result, file=out, compress=T)
