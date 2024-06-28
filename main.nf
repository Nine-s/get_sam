
nextflow.enable.dsl = 2

include { FASTP } from './modules/fastp.nf'
include { CHECK_STRANDNESS } from './modules/check_strandness.nf'
include { HISAT2_INDEX_REFERENCE ; HISAT2_INDEX_REFERENCE_MINIMAL ; HISAT2_ALIGN ; EXTRACT_SPLICE_SITES ; EXTRACT_EXONS } from './modules/hisat2.nf'
include { SAMTOOLS ; SAMTOOLS_MERGE } from './modules/samtools.nf'
include { CUFFLINKS } from './modules/cufflinks.nf'
 
params.outdir = 'results'

workflow {

    read_pairs_ch = channel.fromFilePairs( params.reads, checkIfExists: true ) 
    CHECK_STRANDNESS( read_pairs_ch, params.reference_cdna, params.reference_annotation_ensembl )
    HISAT2_INDEX_REFERENCE_MINIMAL( params.reference_genome )
    HISAT2_ALIGN( read_pairs_ch, HISAT2_INDEX_REFERENCE_MINIMAL.out, CHECK_STRANDNESS.out.first() )    
    //FASTP( read_pairs_ch )
    //SAMTOOLS( HISAT2_ALIGN.out.sample_sam )
    //CUFFLINKS( CHECK_STRANDNESS.out, SAMTOOLS.out.sample_bam, params.reference_annotation )
}
