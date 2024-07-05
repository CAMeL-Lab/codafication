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

# MODELS_DIR=/scratch/ba63/codafication/models/t5_ensemble
MODELS_DIR=/scratch/ba63/codafication/models/bart_ensemble
DATA_DIR=/home/ba63/codafication/data/${2}

if [ "$1" != "gold" ] && [ "$1" != "pred" ]; then
    printf "Prediction mode has to be either gold or pred!"
fi

if [ "$2" != "dev" ] && [ "$2" != "test" ]; then
    printf "Test mode has to be either dev or test!"
fi

models=(
    ${MODELS_DIR}/bei
    ${MODELS_DIR}/cai
    ${MODELS_DIR}/doh
    ${MODELS_DIR}/rab
    ${MODELS_DIR}/tun
)

TEST_FILES=(
    ${DATA_DIR}/${2}_${1}.BEI.json
    ${DATA_DIR}/${2}_${1}.CAI.json
    ${DATA_DIR}/${2}_${1}.DOH.json
    ${DATA_DIR}/${2}_${1}.RAB.json
    ${DATA_DIR}/${2}_${1}.TUN.json
)

pred_files=(
    ${MODELS_DIR}/bei/BEI_${1}.${2}.gen
    ${MODELS_DIR}/cai/CAI_${1}.${2}.gen
    ${MODELS_DIR}/doh/DOH_${1}.${2}.gen
    ${MODELS_DIR}/rab/RAB_${1}.${2}.gen
    ${MODELS_DIR}/tun/TUN_${1}.${2}.gen
)

sys=${models[$SLURM_ARRAY_TASK_ID]}
test_file=${TEST_FILES[$SLURM_ARRAY_TASK_ID]}
pred_file=${pred_files[$SLURM_ARRAY_TASK_ID]}


printf "Running inference on ${test_file}\n"
printf "Generating outputs using: ${sys}\n"

python /home/ba63/codafication/codafication/generate.py \
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
