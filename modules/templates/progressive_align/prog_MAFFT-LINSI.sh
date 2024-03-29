
export MAX_N_PID_4_TCOFFEE=`cat /proc/sys/kernel/pid_max`
t_coffee -other_pg seq_reformat -in ${guide_tree} -input newick -in2 ${seqs} -input2 fasta_seq -action +newick2mafftnewick >> ${id}.mafftnewick

newick2mafft.rb 1.0 ${id}.mafftnewick > ${id}.mafftbinary

linsi --clustalout --treein ${id}.mafftbinary ${seqs} > ${id}.prog.${align_method}.with.${tree_method}.tree.aln
