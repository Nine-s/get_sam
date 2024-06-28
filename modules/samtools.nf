process SAMTOOLS {
    container "biocontainers/samtools:v1.7.0_cv4"
    label 'samtools'
    publishDir params.outdir
    
    input:
    tuple val(sample_name), path(sam_file)
    
    output:
    path("${sam_file}.sorted.bam"), emit: sample_bam 
    
    script:
    """
    samtools view -bS ${sam_file} | samtools sort -o ${sam_file}.sorted.bam -T tmp  
    """
    
}

process SAMTOOLS_MERGE {
    container "biocontainers/samtools:v1.7.0_cv4"
    label 'samtools'
    publishDir params.outdir

    input:
    file out_bam
    
    output:
    tuple val("alignement_gathered.bam"), path("alignement_gathered.bam"), emit: gathered_bam
    
    script:
    """
    samtools merge alignement_gathered.bam ${out_bam}
    """
}
