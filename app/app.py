"""Module providing a function printing python version."""
import os
from applicationinsights import TelemetryClient
from dotenv import load_dotenv

load_dotenv()

appi_key = os.environ['APPLICATION_INSIGHTS_INSTRUMENTATION_KEY']

tc = TelemetryClient(appi_key)

tc.track_event('Test event')
tc.track_trace('Test trace', { 'foo': 'bar' })
tc.track_metric('My Metric', 42)

# try:
#     raise Exception('blah')
# except:
#     tc.track_exception()

tc.flush()
