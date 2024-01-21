"""Application Insights example application."""
import os
from dotenv import load_dotenv

from azure.monitor.opentelemetry import configure_azure_monitor
from opentelemetry import trace

load_dotenv()

appi_key = os.environ['APPLICATION_INSIGHTS_CONNECTION_STRING']

configure_azure_monitor(
    connection_string=appi_key,
)

tracer = trace.get_tracer(__name__)

with tracer.start_as_current_span("hello"):
    print("Hello, World!")

input()
