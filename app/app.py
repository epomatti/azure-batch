"""Module providing a function printing python version."""
import os
from applicationinsights import TelemetryClient
from dotenv import load_dotenv

load_dotenv()

appi_key = os.environ['APPLICATION_INSIGHTS_INSTRUMENTATION_KEY']

tc = TelemetryClient(appi_key)
tc.track_event('Test event')
tc.flush()
