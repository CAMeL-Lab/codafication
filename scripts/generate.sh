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



sys=/scratch/ba63/coda-did/models/t5/gip_new
test_file=/scratch/ba63/coda-did/data/test/gip_gold.json
pred_file=gip_gold.test.gen

printf "Running inference on ${test_file}\n"
printf "Generating outputs using: ${sys}\n"

python generate.py \
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


# ensemble generate
# for x in rab bei cai tun doh
# do
#         sys=/scratch/ba63/coda-did/models/t5/separated/$x
#         for y in gold pred
#         do 
#                 test_file=/scratch/ba63/coda-did/data/dev/separated/dev_${y}.${x^^}.json
#                 pred_file=${x^^}_${y}.gen

#                 printf "Running inference on ${test_file}\n"
#                 printf "Generating outputs using: ${sys}\n"

#                 python generate.py \
#                         --model_name_or_path $sys \
#                         --source_lang src \
#                         --target_lang tgt \
#                         --test_file $test_file \
#                         --per_device_eval_batch_size 16 \
#                         --output_dir $sys \
#                         --num_beams 5 \
#                         --num_return_sequences 1 \
#                         --max_target_length 200 \
#                         --predict_with_generate \
#                         --prediction_file $pred_file

#         done


# done