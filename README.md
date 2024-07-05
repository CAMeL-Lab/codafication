# CODAfication


This repo contains code and pretrained models to reproduce the results in our paper [Exploiting Dialect Identification
in Automatic Dialectal Text Normalization](https://arxiv.org/pdf/2407.03020).


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



## Hugging Face Integration:
We make our CODAfication models publicly available on [Hugging Face]().


## License:

This repo is available under the MIT license. See the [LICENSE](LICENSE) for more info.

## Citation

If you find the code or data in this repo helpful, please cite our [paper](https://arxiv.org/pdf/2407.03020):

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
