# CODAfication


This repo contains code and pretrained models to reproduce the results in our paper [Exploiting Dialect Identification
in Automatic Dialectal Text Normalization](https://arxiv.org/abs/2407.03020).


## Requirements:

The code was written for python>=3.9, pytorch 1.11.1, and transformers 4.22.2. You will need a few additional packages. Here's how you can set up the environment using conda (assuming you have conda and cuda installed):

```bash
git clone https://github.com/CAMeL-Lab/codafication.git
cd coda

conda create -n coda python=3.9
conda activate coda

pip install -r requirements.txt
```

## Experiments and Reproducibility:
[data](data): includes all the data we used throughout our paper to train and test various systems. This includes alignments, m2edits, the MADAR CODA Corpus, and all the utilities we used.

[codafication](codafication): includes the scripts needed to train and evaluate our codafication models.

[utils](utils): includes various scripts used for evaluation and statistical significance.


## Hugging Face Integration:
We make our CODAfication models publicly available on [Hugging Face](https://huggingface.co/collections/CAMeL-Lab/codafication-6687ee4059e2d45fc20ce22b).

```python
from transformers import AutoTokenizer, AutoModelForSeq2SeqLM
from camel_tools.dialectid import DIDModel6
import torch

DID = DIDModel6.pretrained()
DA_PHRASE_MAP = {'BEI': 'في بيروت منقول',
                 'CAI': 'في القاهرة بنقول',
                 'DOH': 'في الدوحة نقول',
                 'RAB': 'في الرباط كنقولو',
                 'TUN': 'في تونس نقولو'}


def predict_dialect(sent):
    """Predicts the dialect of a sentence using the
       CAMeL Tools MADAR 6 DID model"""

    predictions = DID.predict([sent])
    scores = predictions[0].scores

    if predictions[0].top != "MSA":
        # get the highest pred
        pred = sorted(scores.items(),
                      key=lambda x: x[1], reverse=True)[0]
    else:
        # get the second highest pred
        pred = sorted(scores.items(),
                      key=lambda x: x[1], reverse=True)[1]

    dialect = pred[0]
    score = pred[1]

    return dialect, score

tokenizer = AutoTokenizer.from_pretrained('CAMeL-Lab/arat5-coda-did')
model = AutoModelForSeq2SeqLM.from_pretrained('CAMeL-Lab/arat5-coda-did')

text = 'اتنين هامبورجر و اتنين قهوة، لو سمحت. عايزهم تيك اواي.'

pred_dialect, _ = predict_dialect(text)
text = DA_PHRASE_MAP[pred_dialect] + ' ' + text

inputs = tokenizer(text, return_tensors='pt')
gen_kwargs = {'num_beams': 5, 'max_length': 200,
              'num_return_sequences': 1,
              'no_repeat_ngram_size': 0, 'early_stopping': False
              }

codafied_text = model.generate(**inputs, **gen_kwargs)
codafied_text = tokenizer.batch_decode(codafied_text,
                                       skip_special_tokens=True,
                                       clean_up_tokenization_spaces=False)[0]

print(codafied_text)
"اثنين هامبورجر واثنين قهوة، لو سمحت. عايزهم تيك اوي."
```


## License:

This repo is available under the MIT license. See the [LICENSE](LICENSE) for more info.

## Citation

If you find the code or data in this repo helpful, please cite our [paper](https://arxiv.org/abs/2407.03020):

```BibTeX
@inproceedings{alhafni-etal-2024-exploiting,
    title = "Exploiting Dialect Identification in Automatic Dialectal Text Normalization",
    author = "Alhafni, Bashar  and
      Al-Towaity, Sarah  and
      Fawzy, Ziyad  and
      Nassar, Fatema and
      Eryani, Fadhl and
      Bouamor, Houda and
      Habash, Nizar",
    booktitle = "Proceedings of ArabicNLP 2024"
    month = "aug",
    year = "2024",
    address = "Bangkok, Thailand",
    abstract = "Dialectal Arabic is the primary spoken language used by native Arabic speakers in daily communication. The rise of social media platforms has notably expanded its use as a written language. However, Arabic dialects do not have standard orthographies. This, combined with the inherent noise in user-generated content on social media, presents a major challenge to NLP applications dealing with Dialectal Arabic. In this paper, we explore and report on the task of CODAfication, which aims to normalize Dialectal Arabic into the Conventional Orthography for Dialectal Arabic (CODA). We work with a unique parallel corpus of multiple Arabic dialects focusing on five major city dialects. We benchmark newly developed pretrained sequence-to-sequence models on the task of CODAfication. We further show that using dialect identification information improves the performance across all dialects. We make our code, data, and pretrained models publicly available.",
}
```
