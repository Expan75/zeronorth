import json
import urllib.parse
import boto3
import logging
from .challenge import service

log = logging.getLogger()
log.debug("loading function")

s3_client = boto3.client("s3")


def on_upload(event: dict, context: dict):

    # debug logging
    fmt_event = json.dumps(event, indent=2)
    fmt_context = json.dumps(context, indent=2)
    log.debug("function was called")
    log.debug(fmt_event)
    log.debug(fmt_context)

    # Get the object from the event and show its content type
    bucket = event["Records"][0]["s3"]["bucket"]["name"]
    key = urllib.parse.unquote_plus(
        event["Records"][0]["s3"]["object"]["key"], encoding="utf-8"
    )
    try:
        matching_records = s3_client.get_object(Bucket=bucket, Key=key)
        record, _ = [o.get()["Body"].read() for o in matching_records]
        record_sum = service.sum_json_numbers(record)
        log.info(f"{record_sum=}")
    except Exception as e:
        log.exception(e)
        log.exception("Error getting object {} from bucket {}.".format(key, bucket))
        raise e
