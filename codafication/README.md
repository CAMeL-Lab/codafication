# Experiments:



## Training:

### Maximum Likelihood Estimation (MLE):
The MLE model we describe in our paper exploits the [alignments](../data/alignment) we obtain over the training data to map raw words to their CODAfied versions. Running the MLE model is done using the [mle/run_rewrite.sh](mle/run_rewrite.sh) script:

```bash
train_file=/path/to/train/alignment/file
test_file=/path/to/test/alignment/file
output_path=/path/to/output

python rewriter.py \
    --train_file $train_file \
    --test_file  $test_file \
    --cbr_ngrams 2 \
    --output_path $output_path

```

### Seq2Seq Models:
We provide scripts to reproduce the CODAfication models we built by fine-tuning [AraBART](https://huggingface.co/moussaKam/AraBART) and [AraT5-v2](https://huggingface.co/UBC-NLP/AraT5v2-base-1024). It is important to note that you need to specify the correct training file corresponding to each experiment. We provide a detailed description of the data we used to build our CODAfication models [here](../data). Each of the provided scripts will have a variant of the following code based on the experiment we'd like to run:

```bash
MODEL=/path/to/model # or huggingface model id
TRAIN_FILE=/path/to/train/file
OUTPUT_DIR=/path/to/output/dir
STEPS=1500
BATCH_SIZE=16

python run_coda.py \
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
```

Running the [scripts/bart_train.sh](scripts/bart_train.sh) and [scripts/t5_train.sh](scripts/t5_train.sh) bash scripts reproduces all of the `Joint` models we report on in our paper (with and without control tokens). The `Ensemble` models can be reproduced by running the [scripts/bart_train_ensemble.sh](scripts/bart_train_ensemble.sh) and [scripts/t5_train_ensemble.sh](scripts/t5_train_ensemble.sh) bash scripts.

We also provide the scripts we used during inference to generate CODAfied outputs using the fine-tuned models. For the `Joint` models inference, you would need to run [scripts/generate.sh](scripts/generate.sh), and for the `Ensemble` models inference, you would need to run [scripts/generate_ensemble.sh](scripts/generate_ensemble.sh)


## Evaluation:

We evaluate our models by using the MaxMax (M<sup>2</sup>) Scorer and Word Error Rate (WER). Running [scripts/eval.sh](scripts/eval.sh) [eval-mode] [test-split] would evaluate the `Joint` models, where [eval-mode] is either `gold` or `pred` and [test-split] is either `dev` or `test`. Running [scripts/eval_ensemble.sh](scripts/eval_ensemble.sh) would evaluate the `Ensemble` models.

In terms of the dialect-specific evaluation, you'd first need to run [scripts/get_dialect_pred.sh](scripts/get_dialect_pred.sh) [test-split] to get the dialect-specific predictions. Then you'd need to run [scripts/eval_dialect.sh](scripts/eval_dialect.sh) [test-split], where [test-split] is either `dev` or `test`.



    
