import logging
from mle import CBR, build_ngrams
from data_utils import Dataset
import re
import argparse


logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


class Rewriter:
    def __init__(self, cbr_model):

        self.cbr_model = cbr_model

    def rewrite(self, dataset, output_path):
        rewritten_sents = []
        oov_cnt = 0

        for i, example in enumerate(dataset):
            src_tokens = example.src_tokens
            src_tokens = [token for tokens in src_tokens for token in tokens.split()]

            for token in src_tokens:
                assert len(token.split(' ')) == 1

            tokens_ngrams = build_ngrams(src_tokens,
                                         ngrams=self.cbr_model.ngrams,
                                         pad_left=True)

            rewritten_sent = []

            logger.info(f'{i}')
            logger.info(' '.join(src_tokens))
            logger.info('\n')

            # rewrting

            for j in range(len(src_tokens)):
                cbr_candidates = self.cbr_model[tokens_ngrams[j]]

                if cbr_candidates:
                    rewritten_token = max(cbr_candidates.items(),
                                        key=lambda x: x[1])[0]
                    rewritten_sent.append(rewritten_token)
                else:
                    logger.info(f'OOV: {src_tokens[j]}')
                    oov_cnt += 1
                    rewritten_sent.append(src_tokens[j])

            rewritten_sent = ' '.join(rewritten_sent)

            rewritten_sent = re.sub(' +', ' ', rewritten_sent)
            logger.info(rewritten_sent)
            logger.info('\n')

            rewritten_sents.append(rewritten_sent)

        logger.info(f"OOVs: {oov_cnt}")

        write_data(output_path, rewritten_sents)


def write_data(path, data):
    with open(path, mode='w') as f:
        f.write('\n'.join(data))
        f.write('\n')


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--train_file')
    parser.add_argument('--test_file')
    parser.add_argument('--cbr_ngrams', type=int)
    parser.add_argument('--output_path')

    args = parser.parse_args()


    train_data = Dataset(raw_data_path=args.train_file)

    test_data = Dataset(raw_data_path=args.test_file)

    logger.info(f'Building the CBR model on {args.train_file}')

    cbr_model = CBR.build_model(train_data,
                                ngrams=args.cbr_ngrams)
    rewriter = Rewriter(cbr_model=cbr_model)

    rewritten_data = rewriter.rewrite(test_data, output_path=args.output_path)


