#!/bin/bash

#SBATCH --job-name=aln_eval        # create a short name for your job

#SBATCH --nodes=1                # node count

#SBATCH --ntasks=1               # total number of tasks across all nodes

#SBATCH --cpus-per-task=8    # cpu-cores per task (>1 if multi-threaded tasks) Number of alignments that will run at once (one per cpu)

#SBATCH --mem-per-cpu=32G         # memory per cpu-core (4G is default)

#SBATCH --gres=gpu:1

#SBATCH --time=00:05:00          # total run time limit (HH:MM:SS)

#SBATCH --mail-type=begin        # send email when job begins

#SBATCH --mail-type=end          # send email when job ends

#SBATCH --mail-user=cmcwhite@princeton.edu



module purge

module load anaconda3/2020.11

conda activate vcmsa_env

module load cudatoolkit/11.3



nvidia-smi



python -m torch.utils.collect_env

export SINGULARITYENV_CUDA_VISIBLE_DEVICES=$CUDA_VISIBLE_DEVICES



basefile=aln_evaluate_20_nopca_16layer_t5_padding10_thr90_nobc_mnc_oldclust

nextflow run $SCRATCH/github/aln_benchmarking/main.nf -params-file ${basefile}.json  -with-singularity file:///scratch/gpfs/cmcwhite//tcoffee_pdb.sif -profile singularity  -with-trace -with-timeline ${basefile}.json.report.html

