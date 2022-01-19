#!/bin/bash

# What's happening here is that we're getting the location of conda in the subshell
source \$(conda info --json | awk '/conda_prefix/ { gsub(/"|,/, "", \$2); print \$2 }')/bin/activate hf-transformers

python3 /home/cmcwhite/transformer_infrastructure/hf_aligner2.py -i ${seqs} -e ${embeddings} -o ${id}.semantic.aln --model ${model} --exclude

if [ `wc -l key_table.txt | awk '{print \$1}'` -ge "2" ]
then
   echo "Merging aligned clusters and excluded sequences"
   mafft --clustalout --merge key_table.txt --auto all_fastas_aln.fasta > ${id}.semantic.aln
else
   echo "No merge needed"
   cp alignment_group0.clustal.aln ${id}.semantic.aln
fi
