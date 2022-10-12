#!/bin/bash

# What's happening here is that we're getting the location of conda in the subshell
source \$(conda info --json | awk '/conda_prefix/ { gsub(/"|,/, "", \$2); print \$2 }')/bin/activate hf-transformers
nvidia-smi

echo $layers
echo $heads
if [ "$layers" = false ] ; then


echo "Selecting heads"
python3 /home/cmcwhite/transformer_infrastructure/hf_embed.py -m ${model} -f ${seqs} -o ${id}.pkl --heads ${heads} --get_sequence_embeddings --get_aa_embeddings --padding $padding

elif [ "$heads" = false ] ; then

echo "Selecting layers"
    python3 /home/cmcwhite/transformer_infrastructure/hf_embed.py -m ${model} -f ${seqs} -o ${id}.pkl --layers ${layers} --get_sequence_embeddings --get_aa_embeddings --padding $padding

else

echo "Provide either layers or head selection"

fi

