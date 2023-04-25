#!/bin/bash nextflow
//params.outdir = 'results'

include { set_templates_path } from './functions.nf'
path_templates = set_templates_path()

process SEMANTIC_ALIGNER {

    tag "semantic on $id"
    time '1h'

    publishDir "${params.outdir}/alignments", pattern: '*.aln', mode: "copy"
    publishDir "${params.outdir}/alignment_files/", pattern: 'alignment*/*', mode: "copy"
    errorStrategy 'ignore'
    //clusterOptions '--ntasks 1 --gres=gpu:1'


    input:
    tuple val(id), path(seqs), path(embeddings)
    path(model)
    val(batch_correct)
    val(seqsimthresh)
    val(flags)
    

    output:
    //val align_method, emit: alignMethod
    tuple val (id), path ("${id}.semantic.aln"), emit: alignmentFile
    path ("${id}.semantic.aln")
    path ("alignment_files_${id}.semantic/*fasta")
    
    path ".command.trace", emit: metricFile

    script:    

    template "${path_templates}/semantic_align/semantic.sh"        
}


process REG_ALIGNER {
    container 'edgano/tcoffee:pdb'
    tag "$align_method - $tree_method - $bucket_size on $id"
    time '1h'
    errorStrategy 'ignore'
    publishDir "${params.outdir}/alignments", pattern: '*.aln'
    //publishDir "${params.outdir}/templates", pattern: '*.template_list'
    //publishDir "${params.outdir}/templates", pattern: '*.prf'

    input:
    tuple val(id), val(tree_method), file(seqs), file(guide_tree)//, file(template), file(library)
    each align_method
    each bucket_size

    output:
    val align_method, emit: alignMethod
    val tree_method, emit: treeMethod
    val bucket_size, emit: bucketSize
    tuple val (id), path ("${id}.*.aln"), emit: alignmentFile
    path "${id}.homoplasy", emit: homoplasyFile
    path ".command.trace", emit: metricFile
    //path "*.template_list", emit: templateFile
    //path "*.prf", emit: templateProfile
    

    script:
    template "${path_templates}/regressive_align/reg_${align_method}.sh"   
}

process PROG_ALIGNER {
    //container 'edgano/tcoffee:pdb'
    //container 'cbcrg/tcoffee@sha256:d249920bffdf9645bebac06225e13ee4407dc7410c60380ff51a8479325cd11f'
    tag "$align_method - $tree_method on $id"

    time '1h'

    errorStrategy 'ignore'
    publishDir "${params.outdir}/alignments", pattern: '*.aln', mode: "copy"

    input:
    tuple val(id), val(tree_method), path(seqs), path(guide_tree)
    each align_method

    output:
    val align_method, emit: alignMethod
    val tree_method, emit: treeMethod
    tuple val (id), path ("${id}.prog.*.tree.aln"), emit: alignmentFile
    path ".command.trace", emit: metricFile

    script:    
    template "${path_templates}/progressive_align/prog_${align_method}.sh"        
}


process POOL_ALIGNER {
    // container 'edgano/tcoffee:pdb'
    container 'cbcrg/tcoffee@sha256:d249920bffdf9645bebac06225e13ee4407dc7410c60380ff51a8479325cd11f'
    tag "$align_method - $tree_method - $bucket_size on $id"
    publishDir "${params.outdir}/alignments", pattern: '*.aln'

    input:
    tuple val(id), val(tree_method), path(seqs), path(guide_tree)
    each align_method
    each bucket_size

    output:
    val align_method, emit: alignMethod
    val tree_method, emit: treeMethod
    val bucket_size, emit: bucketSize
    tuple val (id), path ("${id}.pool_${bucket_size}.${align_method}.with.${tree_method}.tree.aln"), emit: alignmentFile
    path "${id}.homoplasy", emit: homoplasyFile
    path ".command.trace", emit: metricFile

    script:
    template "${path_templates}/pool_align/pool_${align_method}.sh"
}

process TCOFFEE_ALIGNER {
    container 'edgano/tcoffee:protocols'
    tag "$tc_mode  on $id"
    publishDir "${params.outdir}/alignments", pattern: '*.aln'
    time '1h'
    errorStrategy 'ignore'

    //publishDir "${params.cache_path}", pattern: '*.aln'

    input:
    tuple val(id), val(tree_method), file(seqs), file(guide_tree) //, file(template), file(library)
    each tc_mode         

    output:
    tuple val (id), path ("*.aln"), emit: alignmentFile
    path ".command.trace", emit: metricFile
    path "*.aln" optional true          //TCOFFEE.out[2].view()


    script:
    template "${path_templates}/tcoffee_align/tcoffee_${tc_mode}.sh"
}
