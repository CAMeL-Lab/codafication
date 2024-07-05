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
model=/scratch/ba63/codafication/models/t5

if [ "$1" != "dev" ] && [ "$1" != "test" ]; then
    printf "Test mode has to be either dev or test!"
fi

if [ "$1" == "dev" ]; then
    exps=('raw' 'city')
else
    exps=('raw' 'da_phrase')
fi

for i in "${!exps[@]}"
do
    exp=${exps[$i]}

    for dialect in BEI TUN CAI DOH RAB
    do
        m2_edits=/home/ba63/codafication/data/m2-files/${1}.${dialect}.m2
        ref=/home/ba63/codafication/data/${1}/${1}_gold.${dialect}.json

        if [ "$exp" = "raw" ]; then
            preds=$model/${exp}/${exp}.${1}.gen.${dialect}.txt
        else
            preds=$model/${exp}/${exp}_pred.${1}.gen.${dialect}.txt
        fi

        printf "Evaluating $preds\n"

        python $m2_scorer \
            --system_output $preds \
            --m2_file $m2_edits

        # check if sentences were skipped during m2 eval before running wer
        if [ -f $preds.pp ]; then
            outputs=$preds.pp
        else
            outputs=$preds
        fi

        python /home/ba63/codafication/utils/wer.py \
            --preds $outputs \
            --gold $ref \
            >> $preds.m2

    done
done