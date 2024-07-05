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

MODEL=/scratch/ba63/BERT_models/AraT5v2-base-1024
DATA_DIR=/home/ba63/codafication/data/train
OUTPUT_DIR=/scratch/ba63/codafication/models/t5_ensemble

TRAIN_FILES=(
    ${DATA_DIR}/train_gold.BEI.json
    ${DATA_DIR}/train_gold.CAI.json
    ${DATA_DIR}/train_gold.DOH.json
    ${DATA_DIR}/train_gold.RAB.json
    ${DATA_DIR}/train_gold.TUN.json
)

OUTPUT_DIRS=(
    ${OUTPUT_DIR}/bei
    ${OUTPUT_DIR}/cai
    ${OUTPUT_DIR}/doh
    ${OUTPUT_DIR}/rab
    ${OUTPUT_DIR}/tun
)

TRAIN_FILE=${TRAIN_FILES[$SLURM_ARRAY_TASK_ID]}
OUTPUT_DIR=${OUTPUT_DIRS[$SLURM_ARRAY_TASK_ID]}

STEPS=1500
BATCH_SIZE=16

python /home/ba63/codafication/codafication/run_coda.py \
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
