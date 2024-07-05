#!/usr/bin/env bash
#SBATCH -p nvidia
# SBATCH -q nlp
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

# MODELS_DIR=/scratch/ba63/codafication/models/bart
MODELS_DIR=/scratch/ba63/codafication/models/t5
DATA_DIR=/home/ba63/codafication/data/$2

if [ "$1" != "gold" ] && [ "$1" != "pred" ]; then
    printf "Prediction mode has to be either gold or pred!"
fi

if [ "$2" != "dev" ] && [ "$2" != "test" ]; then
    printf "Test mode has to be either dev or test!"
fi


if [ "$1" = "gold" ]; then
    models=(
        ${MODELS_DIR}/city
        ${MODELS_DIR}/msa_phrase
        ${MODELS_DIR}/da_phrase
        ${MODELS_DIR}/digit
    )

    TEST_FILES=(
        ${DATA_DIR}/${2}_city_gold.json
        ${DATA_DIR}/${2}_msa_phrase_gold.json
        ${DATA_DIR}/${2}_da_phrase_gold.json
        ${DATA_DIR}/${2}_digit_gold.json
    )
    pred_files=(
        ${MODELS_DIR}/city/city_gold.${2}.gen
        ${MODELS_DIR}/msa_phrase/msa_phrase_gold.${2}.gen
        ${MODELS_DIR}/da_phrase/da_phrase_gold.${2}.gen
        ${MODELS_DIR}/digit/digit_gold.${2}.gen
    )

elif [ "$1" = "pred" ]; then
    models=(
        ${MODELS_DIR}/raw
        ${MODELS_DIR}/city
        ${MODELS_DIR}/msa_phrase
        ${MODELS_DIR}/da_phrase
        ${MODELS_DIR}/digit
    )

    TEST_FILES=(
        ${DATA_DIR}/${2}.json
        ${DATA_DIR}/${2}_city_pred.json
        ${DATA_DIR}/${2}_msa_phrase_pred.json
        ${DATA_DIR}/${2}_da_phrase_pred.json
        ${DATA_DIR}/${2}_digit_pred.json
    )

    pred_files=(
        ${MODELS_DIR}/raw/raw.${2}.gen
        ${MODELS_DIR}/city/city_pred.${2}.gen
        ${MODELS_DIR}/msa_phrase/msa_phrase_pred.${2}.gen
        ${MODELS_DIR}/da_phrase/da_phrase_pred.${2}.gen
        ${MODELS_DIR}/digit/digit_pred.${2}.gen
    )

fi

sys=${models[$SLURM_ARRAY_TASK_ID]}
test_file=${TEST_FILES[$SLURM_ARRAY_TASK_ID]}
pred_file=${pred_files[$SLURM_ARRAY_TASK_ID]}

printf "Running inference on ${test_file}\n"
printf "Generating outputs using: ${sys}\n"

python /home/ba63/codafication/generate.py \
        --model_name_or_path $sys \
        --source_lang src \
        --target_lang tgt \
        --test_file $test_file \
        --per_device_eval_batch_size 16 \
        --output_dir $sys \
        --num_beams 5 \
        --num_return_sequences 1 \
        --max_target_length 200 \
        --predict_with_generate \
        --prediction_file $pred_file
