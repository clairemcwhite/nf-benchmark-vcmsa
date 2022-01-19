replace_U.pl ${seqs}

mafft-sparsecore.rb  --clustalout -i ${seqs} > ${id}.prog.${align_method}.with.NO_TREE.tree.aln
