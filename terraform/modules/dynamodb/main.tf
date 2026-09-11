# Hash key "event_id" confirmado lendo services/analytics-service/app.py
# (dynamodb_client.put_item monta o item com a chave 'event_id': {'S': ...}).
resource "aws_dynamodb_table" "analytics" {
  name         = var.table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "event_id"

  attribute {
    name = "event_id"
    type = "S"
  }

  tags = {
    Name = var.table_name
  }
}
