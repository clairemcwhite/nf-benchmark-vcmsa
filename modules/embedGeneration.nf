#!/bin/bash nextflow
params.outdir = 'results'

include { set_templates_path } from './functions.nf'
path_templates = set_templates_path()

process EMBED_GENERATION {
    tag "$layers on $id"
    //clusterOptions '--ntasks 1 --gres=gpu:1'
    //publishDir "${params.outdir}/embeddings", mode: 'copy', overwrite: true

    input:
    tuple val(id), path(seqs)
    val(layers)
    path(model)
    val(heads)     
    val(padding)

    output:
    tuple val (id), path ("${id}.pkl"), emit: embeds

    script:
    template "${path_templates}/embed.sh"
}
