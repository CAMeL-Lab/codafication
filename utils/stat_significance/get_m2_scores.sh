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

m2_scorer=/home/ba63/codafication/utils/eval_m2.py
m2_edits=/home/ba63/codafication/data/m2-files/dev.m2
# m2_edits=/home/ba63/codafication/data/m2-files/test.m2

# sys=/scratch/ba63/codafication/models/t5/raw/raw.dev.gen.txt
sys=/scratch/ba63/codafication/models/t5/city/city_pred.dev.gen.txt

# sys=/scratch/ba63/codafication/models/t5/raw/raw.test.gen.txt
# sys=/scratch/ba63/codafication/models/t5/da_phrase/da_phrase_pred.test.gen.txt

printf "Evaluating ${sys}\n"

python $m2_scorer \
    --system_output $sys \
    --m2_file $m2_edits \
    --mode single
