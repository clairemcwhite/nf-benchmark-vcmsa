#!/usr/bin/env nextflow

/*
 * Copyright (c) 2017-2020, Centre for Genomic Regulation (CRG) and the authors.
 *
 *   This file is part of 'XXXXXX'.
 *
 *   XXXXXX is free software: you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License as published by
 *   the Free Software Foundation, either version 3 of the License, or
 *   (at your option) any later version.
 *
 *   XXXXXX is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details.
 *
 *   You should have received a copy of the GNU General Public License
 *   along with XXXXXX.  If not, see <http://www.gnu.org/licenses/>.
 */

/* 
 * Main XXX pipeline script
 *
 * @authors
 * Edgar Garriga
 * Jose Espinosa-Carrasco
 */

//  example         https://github.com/nextflow-io/rnaseq-nf/tree/modules
/* 
 * enables modules 
 */
nextflow.enable.dsl = 2

/*
 * defaults parameter definitions
 */

//    ## subdatsets
seq2improve="cryst,blmb,rrm,subt,ghf5,sdr,tRNA-synt_2b,zf-CCHH,egf,Acetyltransf,ghf13,p450,Rhodanese,aat,az,cytb,proteasome,GEL"
top20fam="gluts,myb_DNA-binding,tRNA-synt_2b,biotin_lipoyl,hom,ghf13,aldosered,hla,Rhodanese,PDZ,blmb,rhv,p450,adh,aat,rrm,Acetyltransf,sdr,zf-CCHH,rvp"
//params.seqs ="/users/cn/egarriga/datasets/homfam/combinedSeqs/{${seq2improve}}.fa"

// input sequences to align in fasta format
//params.seqs = "/users/cn/egarriga/datasets/homfam/combinedSeqs/{${top20fam}}.fa"

//params.refs = "/users/cn/egarriga/datasets/homfam/refs/{${top20fam}}.ref"

//params.trees ="/Users/edgargarriga/CBCRG/nf_regressive_modules/results/trees/*.dnd"
params.model ="/scratch/gpfs/cmcwhite/prot_bert_bfd"
params.trees = false
params.seqs = ""
params.tree_methods = "MAFFT-PARTTREE0"
params.alignments = "/scratch/gpfs/cmcwhite/alignments/*aln"
                      //TODO FIX -> reg_UPP
                      //CLUSTALO,FAMSA,MAFFT-FFTNS1,MAFFT-GINSI,MAFFT-SPARSECORE,MAFFT,MSAPROBS,PROBCONS,TCOFFEE,UPP,MUSCLE
params.align_methods = "CLUSTALO,FAMSA,MAFFT-FFTNS1,MAFFT-GINSI,MAFFT-SPARSECORE,MAFFT,MSAPROBS,PROBCONS,TCOFFEE,UPP,MUSCLE"
params.layers = false
params.heads = false
params.padding = 10
params.batch_correct = false

//CLUSTALW-QUICK,CLUSTALW
//FAMSA-SLINK,FAMSA-SLINKmedoid,FAMSA-SLINKparttree,FAMSA-UPGMA,FAMSA-UPGMAmedoid,FAMSA-UPGMAparttree
//MAFFT-DPPARTTREE0,MAFFT-DPPARTTREE1,MAFFT-DPPARTTREE2,MAFFT-DPPARTTREE2size
//MAFFT-FASTAPARTTREE,MAFFT-FFTNS1,MAFFT-FFTNS1mem,MAFFT-FFTNS2,MAFFT-FFTNS2mem
//MAFFT-PARTTREE0,MAFFT-PARTTREE1,MAFFT-PARTTREE2,MAFFT-PARTTREE2size
//MAFFT,MBED
//TCOFFEE-BLENGTH,TCOFFEE-ISWLCAT,TCOFFEE-KM,TCOFFEE-LONGCAT,TCOFFEE-NJ,TCOFFEE-REG,TCOFFEE-SHORTCAT,TCOFFEE-SWL,TCOFFEE-SWLcat,TCOFFEE-UPGMA

//TODO -> test tcoffee trees
//     CLUSTALW-QUICK,CLUSTALW  -> not working on PROG bc they are not rooted

                      //MAFFT-DPPARTTREE0,FAMSA-SLINK,MBED,MAFFT-PARTTREE0
//params.tree_methods = "FAMSA-SLINK"

params.buckets = "30"


params.progressive_align = false
params.regressive_align = false
params.semantic_align = false
params.embeds = false


params.evaluate=true
params.homoplasy=false
params.gapCount=false
params.metrics=false
params.easel=false

// output directory
params.outdir = "$baseDir/results"


log.info """\
         PIPELINE  ~  version 0.1"
         ======================================="
         Input sequences (FASTA)                        : ${params.seqs}
         Input embeddings (pkl)                         : ${params.embeds}
         Input references (Aligned FASTA))              : ${params.refs}
         Input trees (NEWICK)                           : ${params.trees}
         Input secondary structure mask                 : ${params.secstruct}
         Model                                          : ${params.model}
         Padding (# X's added to sequence pre-embed     : ${params.padding}
         Batch correction                               : ${params.batch_correct}
         Embedding layers                               : ${params.layers}
         Embedding heads (file)                         : ${params.heads}
         Alignment methods                              : ${params.align_methods}
         Tree methods                                   : ${params.tree_methods}
         Bucket size                                    : ${params.buckets}
         --##--
         Generate Progressive alignments                : ${params.progressive_align}
         Generate Regressive alignments                 : ${params.regressive_align}
         Generate Semantic alignments                : ${params.semantic_align}
         --##--
         Perform evaluation? Requires reference         : ${params.evaluate}
         Check homoplasy? Only for regressive           : ${params.homoplasy}
         Check gapCount? For progressive                : ${params.gapCount}
         Check metrics?                                 : ${params.metrics}
         Check easel info?                              : ${params.easel}
         --##--
         Output directory (DIRECTORY)                   : ${params.outdir}
         """
         .stripIndent()

// import analysis pipelines
include { TREE_GENERATION } from './modules/treeGeneration'   params(params)
include { EMBED_GENERATION } from './modules/embedGeneration'   params(params)
include { PROG_ANALYSIS } from './modules/prog_analysis'      params(params)
include { SEMANTIC_ANALYSIS } from './modules/semantic_analysis'      params(params)
//include { EVAL_ALIGNMENT } from './modules/modules_evaluateAlignment.nf'   params(params)

// Channels containing sequences
if (params.seqs){
   seqs_ch = Channel.fromPath( params.seqs, checkIfExists: true ).map { item -> [ item.baseName.tokenize(".")[0], item] }
 println seqs_ch
  }

refs_ch = Channel.empty()
if ( params.refs ) {
  refs_ch = Channel.fromPath( params.refs ).map { item -> [ item.baseName, item] }
}

ss_ch = Channel.empty()
if ( params.secstruct ) {
  ss_ch = Channel.fromPath( params.secstruct ).map { item -> [ item.baseName, item] }
}




// Channels for user provided trees or empty channel if trees are to be generated [OPTIONAL]
if ( params.trees ) {
  input_trees = Channel.fromPath(params.trees)
                       .map { item -> [ item.baseName.tokenize('.')[0], item.baseName.tokenize('.')[1], item] }
}
tree_method = params.tree_methods.tokenize(',')
/*
 * main script flow
 */
workflow PIPELINE {
    



    if (params.regressive_align || params.progressive_align){
        def trees = params.trees? input_trees : TREE_GENERATION (seqs_ch, tree_method).trees
    
        seqs_ch
            .cross(trees)
            .map { it -> [ it[1][0], it[1][1], it[0][1], it[1][2] ] }
            .set { seqs_and_trees }
     
     // tokenize params

    align_method = params.align_methods.tokenize(',')
    bucket_list = params.buckets.toString().tokenize(',')     //int to string


    }

    alignment_semantic_r = Channel.empty()
   
    if (params.semantic_align) {
      if (params.embeds) {
          embeds_ch = Channel.fromPath( params.embeds, checkIfExists: true ).map { item -> [ item.baseName.tokenize(".")[0], item] }
      }
      else {
          embeds_ch = EMBED_GENERATION (seqs_ch, params.layers, params.model, params.heads, params.padding).embeds
     } 

     println "embed_ch"
     embeds_ch.view()

     seqs_ch.view()
     seqs_ch
       .cross( embeds_ch )
        .map { it -> [ it[1][0], it[0][1], it[1][1] ] }
        .set { seqs_and_embeds }
    seqs_and_embeds.view()
   
    

       


        SEMANTIC_ANALYSIS(seqs_and_embeds, refs_ch, params.model, params.batch_correct)
        alignment_semantic_r = SEMANTIC_ANALYSIS.out.alignment
    }


    alignment_progressive_r = Channel.empty()
    if (params.progressive_align){
        PROG_ANALYSIS(seqs_and_trees, refs_ch, align_method, tree_method)
        alignment_progressive_r = PROG_ANALYSIS.out.alignment
    }



    emit:
    alignment_semantic = alignment_semantic_r
    alignment_progressive = alignment_progressive_r
}

workflow {
  PIPELINE()
}

/* 
 * completion handler
 */
workflow.onComplete {
	log.info ( workflow.success ? "\nDone!\n" : "Oops .. something went wrong" )
  //TODO script to generate CSV from individual files
}
