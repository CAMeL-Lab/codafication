# Data


We used the [MADAR Coda Corpus](https://camel.abudhabi.nyu.edu/madar-coda-corpus/) to train and evaluate our models. We randomly split the data into [train](train/train.tsv) (70%), [dev](train/dev.tsv) (15%), and [test](test/test.tsv) (15%).


## Preprocessing, Alignment, and M2 Edits:

### Preprocessing:

We preprocess the data before using it to train our models. The preprocessing simply includes removing double spaces from both the raw and the codafied versions of the text. Moreover, we use the [CAMeL Tools](https://github.com/CAMeL-Lab/camel_tools/tree/master) dialect identification component to obtain the dialectal control tokens we describe in our paper.

The above steps are applied using the [utils/preprocess_data.sh](utils/preprocess_data.sh) script. Running this script creates the following files for each of the [train](train), [dev](dev), and [test](test) splits:

1. `[train|dev|test].preproc.tsv`: the processed train, dev, and test splits from the MADAR Coda Corpus in a tsv format.
2. `[train|dev|test].json`: the processed train, dev, and test splits from the MADAR Coda Corpus in a json format. These are the files we use to train and evaluate our systems **without** using control tokens.
3. `[train|dev|test]_gold.[dial].[tsv|json]`: the processed train, dev, and test splits from the MADAR Coda Corpus for each one of the five city dialects we are modeling, where `dial` represents the city dialct (i.e., BEI, CAI, DOH, RAB, TUN). We use the **gold** dialectal label to identify the dialect of the input sentences. Therefore, these files will have the same number of examples.
4. `[train|dev|test]_pred.[dial].[tsv|json]`:  the processed train, dev, and test splits from the MADAR Coda Corpus for each one of the five city dialects we are modeling, where `dial` represents the city dialct (i.e., BEI, CAI, DOH, RAB, TUN). We use the **predicted** dialectal label to identify the dialect of the input sentences. Therefore, these files will *not* have the same number of examples.
5. `[train|dev|test]_[control_token]_gold.json`: the processed train, dev, and test splits from the MADAR Coda Corpus for each of the control token strategies we modeled (i.e., City, MSA Phrase, DA Phrase, Digit). We use the **gold** dialectal label to identify the dialect of the input sentences when applying the control tokens. The `train_[control_token]_gold.json` files are the ones we use to train our systems **with** control tokens, whereas the `[dev|test]_[control_token]_gold.json` are the ones we use of the our Oracle experiments to evaluate the systems.
6. `[dev|test]_[control_token]_pred.json`: the processed dev and test splits from the MADAR Coda Corpus for each of the control token strategies we modeled (i.e., City, MSA Phrase, DA Phrase, Digit). We use the **predicted** dialectal label to identify the dialect of the input sentences when applying the control tokens. We use these files to evaluate our the systems train **with** control tokens.


### Alignments and M2 Edits:

We obtain alignments for all raw and codafied sentence pairs. We use the alignments of the `dev` and `test` splits to create m2edits. The m2edits are needed for the evaluation using the m2scorer, which is our main evaluation metric.

The alignment algorithm we use is described in [Alhafni et al., 2023](https://aclanthology.org/2023.emnlp-main.396.pdf). We use their publicly available [alignment code](https://github.com/CAMeL-Lab/arabic-gec/tree/master/alignment) to obtain the alignments. Running the `utils/create_m2edits.sh` script creates the alignment for each of the train, dev, and test splits as well as the alignments for each of the five city dialects (for the dev and test splits). The script also creates the m2edits for the dev and test splits as well as the edits for each of the five city dialects. The alignments and m2edits can be found in the [alignment](alignment) and [m2-files](m2-files) directories, respectively. 
