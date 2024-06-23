#!/usr/bin/env bash
#SBATCH -p nvidia
# use gpus
#SBATCH --gres=gpu:a100:1
# memory
#SBATCH --mem=220GB
# Walltime format hh:mm:ss
#SBATCH --time=40:00:00
# Output and error files
#SBATCH -o job.%J.out
#SBATCH -e job.%J.err

nvidia-smi

MODEL=/scratch/ba63/BERT_models/AraT5v2-base-1024
# OUTPUT_DIR=/scratch/ba63/coda-did/models/t5/separated/cai
# TRAIN_FILE=/scratch/ba63/coda-did/sources/train_sep/train.cai.json


OUTPUT_DIR=/scratch/ba63/coda-did/models/t5/city_new
TRAIN_FILE=/scratch/ba63/coda-did/data/train/city.json

STEPS=1500
BATCH_SIZE=16


python run_coda.py \
    --model_name_or_path $MODEL \
    --do_train \
    --optim adamw_torch \
    --source_lang src \
    --target_lang tgt \
    --train_file  $TRAIN_FILE \
    --save_steps $STEPS \
    --num_train_epochs 10 \
    --output_dir $OUTPUT_DIR \
    --per_device_train_batch_size $BATCH_SIZE \
    --per_device_eval_batch_size $BATCH_SIZE \
    --max_target_length 200 \
    --seed 42 \
    --learning_rate 1e-04 \
    --overwrite_cache \
    --overwrite_output_dir
