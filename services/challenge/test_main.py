import main


def test_sum_record_numbers():
    result = main.sum_record_numbers({})
    assert result >= 0


def test_sum_json_numbers():
    result = main.sum_json_numbers("{}")
    assert result == 0

    result = main.sum_json_numbers(
        '{"hej": 23, "på": "notanumber", "nested": {"number": 23}}'
    )
    assert result == 23 * 2
