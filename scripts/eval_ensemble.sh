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


m2_scorer=/home/ba63/codafication/eval_m2.py
m2_edits=/home/ba63/codafication/data/m2-files/dev.m2
DATA_DIR=/home/ba63/codafication/data/dev

# MODELS_DIR=/scratch/ba63/codafication/models/bart_ensemble
MODELS_DIR=/scratch/ba63/codafication/models/t5_ensemble


# gold evaluation
cat  $MODELS_DIR/bei/BEI_gold.dev.gen.txt \
     $MODELS_DIR/cai/CAI_gold.dev.gen.txt \
     $MODELS_DIR/doh/DOH_gold.dev.gen.txt \
     $MODELS_DIR/rab/RAB_gold.dev.gen.txt \
     $MODELS_DIR/tun/TUN_gold.dev.gen.txt  > $MODELS_DIR/dev_gold.gen.txt


printf "Evaluating $MODELS_DIR/dev_gold.gen.txt\n"

python $m2_scorer \
    --system_output $MODELS_DIR/dev_gold.gen.txt \
    --m2_file $m2_edits

python /home/ba63/codafication/wer.py \
    --preds $MODELS_DIR/dev_gold.gen.txt \
    --gold $DATA_DIR/dev.json \
    >> $MODELS_DIR/dev_gold.gen.txt.m2


# pred evaluation
# we have to sort the predictions before we do the aggregate evaluation

# 1. getting the ids of the sentences in pred
awk 'FNR>1' $DATA_DIR/dev_pred.BEI.tsv $DATA_DIR/dev_pred.CAI.tsv \
            $DATA_DIR/dev_pred.DOH.tsv  $DATA_DIR/dev_pred.RAB.tsv \
            $DATA_DIR/dev_pred.TUN.tsv | cut -f2 > $MODELS_DIR/dev_pred.ids

# 2. aggregating the predictions and sorting them based on the example ids
# this step is needed to ensure that the sentences are in right order

cat $MODELS_DIR/bei/BEI_pred.dev.gen.txt \
    $MODELS_DIR/cai/CAI_pred.dev.gen.txt \
    $MODELS_DIR/doh/DOH_pred.dev.gen.txt \
    $MODELS_DIR/rab/RAB_pred.dev.gen.txt \
    $MODELS_DIR/tun/TUN_pred.dev.gen.txt  > $MODELS_DIR/dev_pred.gen.unsorted.txt

paste $MODELS_DIR/dev_pred.ids $MODELS_DIR/dev_pred.gen.unsorted.txt \
      | sort -t$'\t' -k1 -n | cut -f2 > $MODELS_DIR/dev_pred.gen.txt


printf "Evaluating $MODELS_DIR/dev_pred.gen.txt\n"

python $m2_scorer \
    --system_output $MODELS_DIR/dev_pred.gen.txt \
    --m2_file $m2_edits

python /home/ba63/codafication/wer.py \
    --preds $MODELS_DIR/dev_pred.gen.txt \
    --gold $DATA_DIR/dev.json \
    >> $MODELS_DIR/dev_pred.gen.txt.m2
