#!/bin/bash nextflow

include { CLUST_SEMANTIC }     from './modules_semanticAlignment.nf' 
// include { TCOFFEE_DEFAULT ; TCOFFEE_QUICKALN ; TCOFFEE_MCOFFEE ; TCOFFEE_ACCURATE ; TCOFFEE_FMCOFFEE ; TCOFFEE_PSICOFFEE ; TCOFFEE_EXPRESSO ; TCOFFEE_PROCOFFEE ; TCOFFEE_3DCOFFEE ; TCOFFEE_TRMSD ; TCOFFEE_RCOFFEE ; TCOFFEE_RCOFFEE_CONSAN ; TCOFFEE_3DALIGN ; TCOFFEE_3DMALIGN }     from './modules_tcoffeeModes.nf' 

workflow ALIGNMENT {
    take:
        seqs_and_embeds
        align_method

    main:
        align_method = align_method.toString().replace("[", "").replace("]", "")
        //println align_method    

        if (align_method == "SEMANTIC"){
            CLUST_SEMANTIC(seqs_and_embeds)

            alignment_method = CLUST_SEMANTIC.out.alignMethod
            alignmentFile = CLUST_SEMANTIC.out.alignmentFile
            metrics = CLUST_SEMANTIC.out.metricFile
        }
    flavour = "clustering"
        
    emit:  
        alignment_method
        alignmentFile
        metrics
        flavour 
}

include { EVALUATION ; METRICS ; GAPS ; EASEL}         from './analysis_evaluation.nf'  

workflow SEMANTIC_ANALYSIS {
  take:
    seqs_and_embeds
    refs_ch
    align_method
    
   main: 

    for(align in align_method){
        println align
        ALIGNMENT(seqs_and_embeds)

        if (params.evaluate){       
            EVALUATION(refs_ch, 
                ALIGNMENT.out.alignmentFile, 
                ALIGNMENT.out.flavour, 
                align,
                "notrees", 
                "NA")
        }
        if (params.metrics){
            METRICS(ALIGNMENT.out.alignmentFile, 
                ALIGNMENT.out.flavour, 
                align,
                "notrees", 
                "NA",
                ALIGNMENT.out.metrics)
        }
        if (params.gapCount){  
            GAPS(ALIGNMENT.out.alignmentFile, 
                ALIGNMENT.out.flavour, 
                align,
                "notrees", 
                "NA")
        }
        if (params.easel){ 
            EASEL( ALIGNMENT.out.alignmentFile, 
                ALIGNMENT.out.flavour, 
                align,
                "notrees", 
                "NA") 
        }
    }
}
