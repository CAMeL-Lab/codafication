#!/bin/bash
# Set number of tasks to run
#SBATCH -q nlp
# SBATCH --ntasks=1
# Set number of cores per task (default is 1)
#SBATCH --cpus-per-task=1
# Walltime format hh:mm:ss
#SBATCH --time=47:59:00
# Output and error files
#SBATCH -o job.%J.out
#SBATCH -e job.%J.err


train_file=/home/ba63/codafication/data/alignment/train.txt
test_file=/home/ba63/codafication/data/alignment/dev.txt
output_path=/scratch/ba63/codafication/models/mle/raw.dev.txt


python rewriter.py \
        --train_file $train_file \
        --test_file  $test_file \
        --cbr_ngrams 2 \
        --output_path $output_path
