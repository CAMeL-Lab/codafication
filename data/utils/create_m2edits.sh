alignment_dir=/home/ba63/codafication/data/alignment
m2edits_dir=/home/ba63/codafication/data/m2-files


# Creating alignment for the training data
cat /home/ba63/codafication/data/train/train.preproc.tsv | cut -f5 \
    > /home/ba63/codafication/data/train/train.raw

cat /home/ba63/codafication/data/train/train.preproc.tsv | cut -f6 \
    > /home/ba63/codafication/data/train/train.coda

sed -i '1d' /home/ba63/codafication/data/train/train.raw
sed -i '1d' /home/ba63/codafication/data/train/train.coda

python /home/ba63/codafication/alignment/aligner.py \
    --src /home/ba63/codafication/data/train/train.raw \
    --tgt /home/ba63/codafication/data/train/train.coda \
    --output $alignment_dir/train.txt

rm /home/ba63/codafication/data/train/train.raw
rm /home/ba63/codafication/data/train/train.coda

# Creating alignment and m2edits for dev and test splits

for split in dev test
do
    output_dir=/home/ba63/codafication/data/$split

    for dial in BEI CAI DOH RAB TUN none
    do
        if [ $dial == "none" ]; then
            input_file=${split}.preproc.tsv
            raw=${split}.raw
            coda=${split}.coda
            align_out=${split}.txt
            m2edits_out=${split}.m2
        else
            input_file=${split}_gold.${dial}.tsv
            raw=${split}.${dial}.raw
            coda=${split}.${dial}.coda
            align_out=${split}.${dial}.txt
            m2edits_out=${split}.${dial}.m2
        fi

        # creating raw and coda files
        cat $output_dir/$input_file | cut -f5 > $output_dir/$raw
        cat $output_dir/$input_file | cut -f6 > $output_dir/$coda

        sed -i '1d' $output_dir/$raw
        sed -i '1d' $output_dir/$coda

        python /home/ba63/codafication/utils/alignment/aligner.py \
            --src $output_dir/$raw \
            --tgt $output_dir/$coda \
            --output $alignment_dir/$align_out

        python /home/ba63/codafication/utils/alignment/create_m2_file.py \
            --src $output_dir/$raw \
            --tgt $output_dir/$coda \
            --align $alignment_dir/$align_out \
            --output $m2edits_dir/$m2edits_out

        rm $output_dir/$raw
        rm $output_dir/$coda

    done
done
