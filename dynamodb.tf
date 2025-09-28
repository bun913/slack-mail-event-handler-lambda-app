resource "aws_dynamodb_table" "event_triggered" {
  name         = "TestEventTable"
  billing_mode = "PROVISIONED"
  // Change these settings for your app
  read_capacity  = 3
  write_capacity = 3
  hash_key       = "eventId"

  attribute {
    name = "eventId"
    type = "S"
  }

  // If you want to delete your data automatically
  ttl {
    attribute_name = "expirationDate"
    enabled        = true
  }
}
