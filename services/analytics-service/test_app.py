"""
Teste de smoke do analytics-service. O app.py cria clientes boto3 (SQS/
DynamoDB) e já inicia uma thread de worker no import — mockamos
boto3.Session antes de importar para não bater na AWS de verdade no CI.
"""
import os
from unittest.mock import MagicMock, patch

os.environ.setdefault("AWS_REGION", "us-east-1")
os.environ.setdefault("AWS_SQS_URL", "https://sqs.us-east-1.amazonaws.com/000000000000/test-queue")
os.environ.setdefault("AWS_DYNAMODB_TABLE", "ToggleMasterAnalytics")

with patch("boto3.Session", return_value=MagicMock()):
    import app as analytics_app


def test_health_check_returns_ok():
    client = analytics_app.app.test_client()
    response = client.get("/health")
    assert response.status_code == 200
    assert response.get_json() == {"status": "ok"}
