#!/bin/bash nextflow
params.outdir = 'results'

include {EVAL_ALIGNMENT}      from './modules_evaluateAlignment.nf'
include {EASEL_INFO}          from './modules_evaluateAlignment.nf'
include {GAPS_PROGRESSIVE}    from './modules_evaluateAlignment.nf'
include {METRICS}             from './modules_evaluateAlignment.nf'

include {SEMANTIC_ALIGNER}       from './generateAlignment.nf'   
workflow SEMANTIC_ANALYSIS {
  take:
    seqs_and_embeds
    refs_ch
    model
     
  main:
    SEMANTIC_ALIGNER (seqs_and_embeds, model)

    if (params.evaluate){
      refs_ch
        .cross (SEMANTIC_ALIGNER.out.alignmentFile)
        .map { it -> [ it[1][0], it[1][1], it[0][1] ] }
        .set { alignment_and_ref }  

      EVAL_ALIGNMENT ("semantic", alignment_and_ref, "semantic", "NA","NA")
      EVAL_ALIGNMENT.out.tcScore
                    .map{ it ->  "${it[0]};${it[1]};${it[2]};${it[3]};${it[4]};${it[5].text}" }
                    .collectFile(name: "${workflow.runName}.semantic.tcScore.csv", newLine: true, storeDir:"${params.outdir}/CSV/${workflow.runName}/")
      EVAL_ALIGNMENT.out.spScore
                    .map{ it ->  "${it[0]};${it[1]};${it[2]};${it[3]};${it[4]};${it[5].text}" }
                    .collectFile(name: "${workflow.runName}.semantic.spScore.csv", newLine: true, storeDir:"${params.outdir}/CSV/${workflow.runName}/")
      EVAL_ALIGNMENT.out.colScore
                    .map{ it ->  "${it[0]};${it[1]};${it[2]};${it[3]};${it[4]};${it[5].text}" }
                    .collectFile(name: "${workflow.runName}.semantic.colScore.csv", newLine: true, storeDir:"${params.outdir}/CSV/${workflow.runName}/")
    }

    def gaps_semantic = params.gapCount? GAPS_PROGRESSIVE("semantic", SEMANTIC_ALIGNER.out.alignmentFile, "semantic", "NA","NA") : Channel.empty()
    def metrics_semantic = params.metrics? METRICS("semantic", SEMANTIC_ALIGNER.out.alignmentFile, "semantic", "NA","NA", SEMANTIC_ALIGNER.out.metricFile) : Channel.empty()
    def easel_info = params.easel? EASEL_INFO ("semantic", SEMANTIC_ALIGNER.out.alignmentFile, "semantic", "NA","NA") : Channel.empty()

    emit:
    alignment = SEMANTIC_ALIGNER.out.alignmentFile
}

