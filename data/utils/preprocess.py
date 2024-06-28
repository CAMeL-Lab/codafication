import argparse
import json
import re
import copy
from camel_tools.dialectid import DIDModel6


DID = DIDModel6.pretrained()

DA_CITY_MAP = {'BEI': 'بيروت', 'CAI': 'القاهرة', 'DOH': 'الدوحة',
                 'RAB': 'الرباط', 'TUN': 'تونس'}

DA_DIGIT_MAP = {'BEI': '1', 'CAI': '2', 'DOH': '3',
                        'RAB': '4', 'TUN': '5'}

MSA_PHRASE_MAP = {dialect: f'في {dialect_ar} نقول'
                  for dialect, dialect_ar in DA_CITY_MAP.items()}

DA_PHRASE_MAP = {'BEI': 'في بيروت منقول',
                 'CAI': 'في القاهرة بنقول',
                 'DOH': 'في الدوحة نقول',
                 'RAB': 'في الرباط كنقولو',
                 'TUN': 'في تونس نقولو'}

CONTROL_STRATEGIES = {'msa_phrase': MSA_PHRASE_MAP,
                      'da_phrase': DA_PHRASE_MAP,
                      'city': DA_CITY_MAP,
                      'digit': DA_DIGIT_MAP}


def predict_dialect(sent):
    """Predicts the dialect of a sentence using the CAMeL Tools
    MADAR 6 DID model"""

    predictions = DID.predict([sent])

    if predictions[0].top != "MSA":
        scores = predictions[0].scores
        highest = sorted(
            scores.items(), key=lambda x: x[1], reverse=True)[0]
        name = highest[0]
        score = highest[1]

    else:
        scores = predictions[0].scores
        second_highest = sorted(
            scores.items(), key=lambda x: x[1], reverse=True)[1]
        name = second_highest[0]
        score = second_highest[1]

    return name, score


def read_data(path):
    data = []

    with open(path) as f:
        for line in f.readlines()[1:]:
            btec_id, madar_split, dialect, raw, coda = line.strip().split('\t')
            data.append({'btec_id': btec_id, 'dialect': dialect, 'raw': raw, 'coda': coda})
    return data


def preprocess_data(data):
    preprocessed_data = []

    for i, example in enumerate(data):
        raw, coda = example['raw'], example['coda']
        raw = string_clean(raw)
        coda = string_clean(coda)
        pred_dialect, _ = predict_dialect(raw)

        preprocessed_data.append({'btec_id': example['btec_id'],
                                  'example_id': str(i),
                                  'dialect': example['dialect'],
                                  'pred_dialect': pred_dialect,
                                  'raw': raw,
                                  'coda': coda}
                                )
    return preprocessed_data


def string_clean(txt):
    """Removes double spaces from string"""
    txt = re.sub(' +', ' ', txt)
    return txt


def add_control_tokens(example, control_token, mode='gold'):
    _example = copy.deepcopy(example)

    if mode == 'gold':
        gold_dialect = _example['dialect']
        prefix = CONTROL_STRATEGIES[control_token][gold_dialect]
    elif mode == 'pred':
        pred_dialect = _example['pred_dialect']
        prefix = CONTROL_STRATEGIES[control_token][pred_dialect]

    _example['raw'] = prefix + ' ' + _example['raw']

    return _example


def verbalize_dataset(data, control_token, mode):
    if control_token == 'none':
        return data

    verbalized_data = []

    for example in data:
        verbalized_example = add_control_tokens(example, control_token, mode)
        verbalized_data.append(verbalized_example)

    return verbalized_data


def write_data(data, path, extension='json'):
    with open(f'{path}.{extension}', mode='w') as f:
        if extension == 'json':
            for example in data:
                f.write(json.dumps(example, ensure_ascii=False))
                f.write('\n')

        elif extension == 'tsv':
            f.write(f'sentID.BTEC\tsentID\tdialect\tpred_dialect\traw\tCODA\n')
            for example in data:
                f.write(f"{example['btec_id']}\t{example['example_id']}"
                        f"\t{example['dialect']}\t{example['pred_dialect']}"
                        f"\t{example['raw']}\t{example['coda']}\n")



def write_data_pred_dial(data, path, mode, extension='json'):
    if mode == 'gold':
        dial_key = 'dialect'

    elif mode == 'pred':
        dial_key = 'pred_dialect'

    bei = [example for example in data if example[dial_key] == 'BEI']
    cai = [example for example in data if example[dial_key] == 'CAI']
    doh = [example for example in data if example[dial_key] == 'DOH']
    rab = [example for example in data if example[dial_key] == 'RAB']
    tun = [example for example in data if example[dial_key] == 'TUN']

    dialect_data = {'BEI': bei, 'CAI': cai, 'DOH': doh, 'RAB': rab, 'TUN': tun}

    for dialect in dialect_data:
        with open(f'{path}_{mode}.{dialect}.{extension}', mode='w') as f:
            if extension == 'json':
                for example in dialect_data[dialect]:
                    f.write(json.dumps(example, ensure_ascii=False))
                    f.write('\n')

            elif extension == 'tsv':
                f.write(f'sentID.BTEC\tsentID\tdialect\tpred_dialect\traw\tCODA\n')
                for example in dialect_data[dialect]:
                    f.write(f"{example['btec_id']}\t{example['example_id']}"
                            f"\t{example['dialect']}\t{example['pred_dialect']}"
                            f"\t{example['raw']}\t{example['coda']}\n")


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--input_file')
    parser.add_argument('--control_token')
    parser.add_argument('--mode')
    parser.add_argument('--output_file')

    args = parser.parse_args()

    data = read_data(args.input_file)
    processed_data = preprocess_data(data)

    if args.control_token == 'none':
        write_data(processed_data, f'{args.output_file}.preproc', extension='tsv')

        write_data_pred_dial(processed_data,
                             mode='gold',
                             path=f'{args.output_file}',
                             extension='tsv')

        write_data_pred_dial(processed_data,
                            mode='pred',
                            path=f'{args.output_file}',
                            extension='tsv')

        write_data_pred_dial(processed_data,
                             mode='gold',
                             path=args.output_file,
                             extension='json')

        write_data_pred_dial(processed_data,
                             mode='pred',
                             path=args.output_file,
                             extension='json')


    verbalized_data = verbalize_dataset(processed_data,
                                        control_token=args.control_token,
                                        mode=args.mode)

    write_data(verbalized_data, path=args.output_file)

