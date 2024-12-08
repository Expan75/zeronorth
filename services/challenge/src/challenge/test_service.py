from . import service


def test_sum_record_numbers():
    result = service.sum_record_numbers({})
    assert result >= 0


def test_sum_json_numbers():
    result = service.sum_json_numbers("{}")
    assert result == 0

    result = service.sum_json_numbers(
        '{"hej": 23, "på": "notanumber", "nested": {"number": 23}}'
    )
    assert result == 23 * 2
