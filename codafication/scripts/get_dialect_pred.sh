output_dir=/scratch/ba63/codafication/models/t5


if [ "$1" == "dev" ]; then
    exps=('raw' 'city')
else
    exps=('raw' 'da_phrase')
fi

data_dir=/home/ba63/codafication/data/${1}

for i in "${!exps[@]}"
do
    exp=${exps[$i]}

    if [ "$exp" = "raw" ]; then
        gen_output_file=$exp.${1}.gen
    else
        gen_output_file=${exp}_pred.${1}.gen
    fi

    cat $data_dir/${1}.preproc.tsv | cut -f3 | sed 1d | paste - $output_dir/$exp/$gen_output_file.txt | grep "^BEI" | cut -f2 >  $output_dir/$exp/$gen_output_file.BEI.txt

    cat $data_dir/${1}.preproc.tsv | cut -f3 | sed 1d | paste - $output_dir/$exp/$gen_output_file.txt | grep "^CAI" | cut -f2 >  $output_dir/$exp/$gen_output_file.CAI.txt

    cat $data_dir/${1}.preproc.tsv | cut -f3 | sed 1d | paste - $output_dir/$exp/$gen_output_file.txt | grep "^TUN" | cut -f2 >  $output_dir/$exp/$gen_output_file.TUN.txt

    cat $data_dir/${1}.preproc.tsv | cut -f3 | sed 1d | paste - $output_dir/$exp/$gen_output_file.txt | grep "^RAB" | cut -f2 >  $output_dir/$exp/$gen_output_file.RAB.txt

    cat $data_dir/${1}.preproc.tsv | cut -f3 | sed 1d | paste - $output_dir/$exp/$gen_output_file.txt | grep "^DOH" | cut -f2 >  $output_dir/$exp/$gen_output_file.DOH.txt


done