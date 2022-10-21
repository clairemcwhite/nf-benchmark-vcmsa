
export MAX_N_PID_4_TCOFFEE=`cat /proc/sys/kernel/pid_max`
t_coffee -seq ${seqs} -tree ${guide_tree} \
         -outfile ${id}.prog.${align_method}.with.${tree_method}.tree.aln 
