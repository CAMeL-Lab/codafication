for split in train dev test
do

    python preprocess.py \
        --input_file /home/ba63/coda-did/data/${split}/${split}.tsv \
        --control_token none \
        --output_file /home/ba63/coda-did/data/${split}/${split}

done


# gold control tokens
for split in train dev test
do
    for token in msa_phrase da_phrase city digit
    do
        python preprocess.py \
            --input_file /home/ba63/coda-did/data/${split}/${split}.tsv \
            --control_token $token \
            --mode gold \
            --output_file /home/ba63/coda-did/data/${split}/${split}_${token}_gold
    done 
done


# pred control tokens
for split in dev test
do
    for token in msa_phrase da_phrase city digit
    do
        python preprocess.py \
            --input_file /home/ba63/coda-did/data/${split}/${split}.tsv \
            --control_token $token \
            --mode pred \
            --output_file /home/ba63/coda-did/data/${split}/${split}_${token}_pred \

    done
done
