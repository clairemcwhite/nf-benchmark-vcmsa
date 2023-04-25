#!/bin/bash

# What's happening here is that we're getting the location of conda in the subshell
source \$(conda info --json | awk '/conda_prefix/ { gsub(/"|,/, "", \$2); print \$2 }')/bin/activate vcmsa_env

nvidia-smi

# Padding zero because embeddings were precomputed
#vcmsa -i ${seqs} -e ${embeddings} -o ${id}.semantic.aln --model ${model} --exclude --seqsimthresh 0.7 --padding 0 --mis  
vcmsa -i ${seqs} -e ${embeddings} -o ${id}.semantic.aln --model ${model} --exclude --seqsimthresh ${seqsimthresh} --padding 0 --log INFO ${flags} 

# Will create file if it doesn't exist
#touch alignment_files_${id}.semantic/${id}.semantic.key_table.txt

#if [ `wc -l alignment_files_${id}.semantic/${id}.semantic.key_table.txt | awk '{print \$1}'` -ge "2" ]


# if a key table was created, mafft is needed to combine alignments
if [ -f "alignment_files_${id}.semantic/${id}.semantic.key_table.txt" ]
then
   echo "Merging aligned clusters and excluded sequences"
   mafft --clustalout --merge alignment_files_${id}.semantic/${id}.semantic.key_table.txt --auto alignment_files_${id}.semantic/${id}.semantic.all_fastas_aln.fasta > ${id}.semantic.aln
else
   echo "No merge needed"
   #cp alignment_files_${id}.semantic/${id}.semantic.alignment_group0.clustal.aln ${id}.semantic.aln
fi
