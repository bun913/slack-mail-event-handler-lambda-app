resource "aws_ssm_parameter" "slack_bot_token" {
  name        = "/${var.project}/slack-bot-token"
  description = "Slack Bot Token"
  type        = "SecureString"
  // NOTE: You should change this manually
  value = "Dummy"

  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "slack_signin_secret" {
  name        = "/${var.project}/slack-signin-secret"
  description = "Slack Bot Token"
  type        = "SecureString"
  // NOTE: You should change this manually
  value = "Dummy"

  lifecycle {
    ignore_changes = [value]
  }
}
