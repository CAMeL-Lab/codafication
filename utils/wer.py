import argparse
import json
import evaluate


def read_data(preds_path, refs_path):
    with open(preds_path) as f_pred, open(refs_path) as f_ref:
        preds = [x.strip() for x in f_pred.readlines()]

        if refs_path.endswith('json'):
            refs = [json.loads(x.strip())['coda'] for x in f_ref.readlines()]
        else:
            refs = [x.strip() for x in f_ref.readlines()]

    return preds, refs


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--preds', help='Path to prediction file.')
    parser.add_argument('--gold', help='Path to gold file.')

    args = parser.parse_args()
    preds, refs = read_data(preds_path=args.preds, refs_path=args.gold)

    wer = evaluate.load('wer')
    wer_score =  wer.compute(references=refs, predictions=preds)

    print(f'WER         : {wer_score}')


if __name__ == '__main__':
    main()
