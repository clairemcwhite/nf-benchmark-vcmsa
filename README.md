
This repository was adapted from [nf-benchmark](https://github.com/cbcrg/nf-benchmark) to evaluate the [vcMSA](https://github.com/clairemcwhite/vcmsa) algorithm. 

The original workflow was written by Edgar Garriga ([edgano](https://github.com/edgano)) and Jose Espinosa ([JoseEspinosa](https://github.com/JoseEspinosa)) at the [Center for Genomic Regulation (CRG)](http://www.crg.eu). 



### json parameters
"seqs": The file path pattern for input sequence files to be aligned.

"refs": The file path pattern for gold standard reference alignment files.

"trees": The file path pattern input tree files (only required for non-vcMSA alignments).

"tree_methods": The method to use for tree construction, in this case, "MAFFT-PARTTREE0".

"align_methods": A comma-separated list of alignment methods to evaluate, including "CLUSTALO", "MAFFT-FFTNS1", "MAFFT-SPARSECORE", "MAFFT-GINSI", "TCOFFEE", "MUSCLE", "MSAPROBS", "FAMSA", "PROBCONS", "UPP", and "PSI".

"layers": A space-separated list of layers to use for the transformer model during alignment, from -16 to -1.

"seqsimthresh": The minimum sequence similarity threshold for sequence clustering (default 0.9). Note, optimal value will change with layer selection, reduce for fewer layers.

"flags": Additional flags to be used for alignment, for example "-mnc -mis".

"evaluate": A boolean flag to indicate whether to evaluate the alignment results.

"gapCount": A boolean flag to indicate whether to count gaps.

"metrics": A boolean flag to indicate whether to compute alignment evaluation metrics.

"outdir": The directory where the output files will be saved.

"model": The directory path where the transformer model files are located.

"padding": The number of padding tokens to add to each sequence during embedding.

"batch_correct": A boolean flag for whether to do batch correction or not (default False)

"progressive_align": A boolean flag to indicate whether to perform progressive alignment.

"regressive_align": A boolean flag to indicate whether to perform regressive alignment.

"semantic_align": A boolean flag to indicate whether to perform semantic alignment.

"easel": A boolean flag to indicate whether to use the Easel library for alignment evaluation.

"cpus": The number of CPUs to use during alignment, (default 1)
