import json


def sum_record_numbers(record: dict) -> float:
    total = 0.0
    for v in record.values():
        if isinstance(v, (int, float)):
            total += v
        elif isinstance(v, dict):
            total += sum_record_numbers(v)
    return total


def sum_json_numbers(raw_json: str) -> float:
    entries = json.loads(raw_json)
    return sum_record_numbers(entries)
