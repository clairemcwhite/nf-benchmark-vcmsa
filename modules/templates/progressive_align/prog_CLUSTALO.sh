clustalo --infile=${seqs} \
         --guidetree-in=${guide_tree} \
         --outfmt=clustal \
         -o ${id}.prog.${align_method}.with.${tree_method}.tree.aln
