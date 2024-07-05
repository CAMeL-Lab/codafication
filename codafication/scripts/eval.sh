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
m2_edits=/home/ba63/codafication/data/m2-files/${2}.m2
DATA_DIR=/home/ba63/codafication/data/${2}

MODELS_DIR=/scratch/ba63/codafication/models/bart
# MODELS_DIR=/scratch/ba63/codafication/models/t5

if [ "$1" != "gold" ] && [ "$1" != "pred" ]; then
    printf "Prediction mode has to be either gold or pred!"
fi

if [ "$2" != "dev" ] && [ "$2" != "test" ]; then
    printf "Test mode has to be either dev or test!"
fi


pred_files=(
    ${MODELS_DIR}/raw/raw.${2}.gen.txt
    ${MODELS_DIR}/city/city_${1}.${2}.gen.txt
    ${MODELS_DIR}/msa_phrase/msa_phrase_${1}.${2}.gen.txt
    ${MODELS_DIR}/da_phrase/da_phrase_${1}.${2}.gen.txt
    ${MODELS_DIR}/digit/digit_${1}.${2}.gen.txt
)

refs=(
    ${DATA_DIR}/${2}.json
    ${DATA_DIR}/${2}_city_${1}.json
    ${DATA_DIR}/${2}_msa_phrase_${1}.json
    ${DATA_DIR}/${2}_da_phrase_${1}.json
    ${DATA_DIR}/${2}_digit_${1}.json
)

for i in "${!refs[@]}"
do
    pred=${pred_files[$i]}
    ref=${refs[$i]}

    printf "Evaluating ${pred}\n"

    python $m2_scorer \
        --system_output $pred \
        --m2_file $m2_edits

    # check if sentences were skipped during m2 eval before running wer
    if [ -f $pred.pp ]; then
        outputs=$pred.pp
    else
        outputs=$pred
    fi

    python /home/ba63/codafication/utils/wer.py \
        --preds $outputs \
        --gold $ref \
        >> $pred.m2
done


# MLE Eval

# python $m2_scorer \
#     --system_output /scratch/ba63/codafication/models/mle/raw.dev.txt \
#     --m2_file $m2_edits

# python /home/ba63/codafication/utils/wer.py \
#     --preds /scratch/ba63/codafication/models/mle/raw.dev.txt \
#     --gold /home/ba63/codafication/data/dev/dev.json \
#     >> /scratch/ba63/codafication/models/mle/raw.dev.txt.m2


# Do Nothing Eval

# python $m2_scorer \
#     --system_output /scratch/ba63/codafication/models/do_nothing/raw.dev.txt \
#     --m2_file $m2_edits

# python /home/ba63/codafication/utils/wer.py \
#     --preds /scratch/ba63/codafication/models/do_nothing/raw.dev.txt \
#     --gold /home/ba63/codafication/data/dev/dev.json \
#     >> /scratch/ba63/codafication/models/do_nothing/raw.dev.txt.m2