#!/usr/bin/env bash
#SBATCH -p nvidia
#SBATCH -q nlp
# use gpus
#SBATCH --gres=gpu:a100:1
# memory
#SBATCH --mem=220GB
# Walltime format hh:mm:ss
#SBATCH --time=40:00:00
# Output and error files
#SBATCH -o job.%J.out
#SBATCH -e job.%J.err
#SBATCH --array=0-4

nvidia-smi

MODEL=/scratch/ba63/BERT_models/AraBART
DATA_DIR=/home/ba63/codafication/data/train
OUTPUT_DIR=/scratch/ba63/codafication/models/bart

TRAIN_FILES=(
    ${DATA_DIR}/train.json
    ${DATA_DIR}/train_city_gold.json
    ${DATA_DIR}/train_msa_phrase_gold.json
    ${DATA_DIR}/train_da_phrase_gold.json
    ${DATA_DIR}/train_digit_gold.json
)

OUTPUT_DIRS=(
    ${OUTPUT_DIR}/raw
    ${OUTPUT_DIR}/city
    ${OUTPUT_DIR}/msa_phrase
    ${OUTPUT_DIR}/da_phrase
    ${OUTPUT_DIR}/digit
)

TRAIN_FILE=${TRAIN_FILES[$SLURM_ARRAY_TASK_ID]}
OUTPUT_DIR=${OUTPUT_DIRS[$SLURM_ARRAY_TASK_ID]}

STEPS=1500
BATCH_SIZE=16

python /home/ba63/codafication/run_coda.py \
    --model_name_or_path $MODEL \
    --do_train \
    --optim adamw_torch \
    --source_lang src \
    --target_lang tgt \
    --train_file $TRAIN_FILE \
    --save_steps $STEPS \
    --num_train_epochs 10 \
    --output_dir $OUTPUT_DIR \
    --per_device_train_batch_size $BATCH_SIZE \
    --per_device_eval_batch_size $BATCH_SIZE \
    --max_target_length 200 \
    --seed 42 \
    --overwrite_cache \
    --overwrite_output_dir
