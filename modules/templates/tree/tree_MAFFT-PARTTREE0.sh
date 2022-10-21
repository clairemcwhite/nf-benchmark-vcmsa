mafft --anysymbol --retree 0 --treeout --parttree --reorder ${seqs}


export MAX_N_PID_4_TCOFFEE=`cat /proc/sys/kernel/pid_max`
t_coffee -other_pg seq_reformat -in ${seqs}.tree -in2 ${seqs} -input newick -action +mafftnewick2newick > ${id}.${tree_method}.dnd
