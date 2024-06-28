process EXTRACT_EXONS {
    label 'python'

    input:
    path(annotation)

    output:
    path("out_exons.txt")

    script:
    """ 
    python ${params.baseDir}/bin/hisat2_extract_exons.py ${annotation}  > out_exons.txt
    """
}

process EXTRACT_SPLICE_SITES {
    label 'python'
    container 'biocontainers/hisat2:v2.0.5-1-deb_cv1'

    input:
    path(annotation)

    output:
    path("out_splice_sites.txt")

    script:
    """ 
    python ${params.baseDir}/bin/hisat2_extract_splice_sites.py ${annotation} > out_splice_sites.txt
    """
}

process HISAT2_INDEX_REFERENCE {
    container 'biocontainers/hisat2:v2.0.5-1-deb_cv1'
    label 'hisat2'
    publishDir params.outdir

    input:
    path(reference)
    path(exon)
    path(splice_sites)

    output:
    tuple path(reference), path("${reference.baseName}*.ht2")

    script:
    """
    hisat2-build ${reference} ${reference.baseName} -p ${params.threads} --exon ${exon} --ss ${splice_sites}
    """
}

process HISAT2_INDEX_REFERENCE_MINIMAL {
    container 'biocontainers/hisat2:v2.0.5-1-deb_cv1'
    label 'hisat2'
    publishDir params.outdir

    input:
    path(reference)

    output:
    tuple path(reference), path("${reference.baseName}*.ht2")

    script:
    """
    hisat2-build ${reference} ${reference.baseName} -p ${params.threads} 
    """
}
process HISAT2_ALIGN {
    container 'biocontainers/hisat2:v2.0.5-1-deb_cv1'
    label 'hisat2'
    publishDir params.outdir
 
    input:
    tuple val(sample_name), path(reads)
    tuple path(reference), path(index)

    output:
    tuple val(sample_name), path("${sample_name}*.sam"), emit: sample_sam 

    shell:
    '''
    if [[ (params.strand == "firststrand") ]]; then
    
        hisat2 -x !{reference.baseName} -1 !{reads[0]} -2 !{reads[1]} --new-summary --summary-file !{sample_name}_summary.log --thread !{params.threads} --dta-cufflinks --rna-strandness FR -S !{sample_name}.sam

    elif [[ (params.strand == "secondstrand") ]]; then
    
        hisat2 -x !{reference.baseName} -1 !{reads[0]} -2 !{reads[1]} --new-summary --summary-file !{sample_name}_summary.log --thread !{params.threads} --dta-cufflinks --rna-strandness RF -S !{sample_name}.sam

    elif [[ params.strand == "unstranded" ]]; then
       
        hisat2 -x !{reference.baseName} -1 !{reads[0]} -2 !{reads[1]} --new-summary --summary-file !{sample_name}_summary.log --thread !{params.threads} --dta-cufflinks -S !{sample_name}.sam
    else  
		echo params.strand > error_strandness.txt
		echo "strandness cannot be determined" >> error_strandness.txt
	fi
    '''   
}
