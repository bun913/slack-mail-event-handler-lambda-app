# archive builded lambda Application
# NOTE: Pleaes make sure that you've finished run `npm run build`
data "archive_file" "mail_triggered_app" {
  type        = "zip"
  source_dir  = "lambda/mailTriggered/dist"
  output_path = "mail_triggered.zip"
}

resource "aws_lambda_function" "mail_triggered_app" {
  filename         = data.archive_file.mail_triggered_app.output_path
  function_name    = "${var.project}-app"
  role             = aws_iam_role.lambda_role.arn
  handler          = "lambda.handler"
  runtime          = "nodejs22.x"
  source_code_hash = data.archive_file.mail_triggered_app.output_base64sha256
  timeout          = 10
  layers = [
    // Use Lambda extensions to use Parameter Store as a Secret Store
    // https://docs.aws.amazon.com/ja_jp/systems-manager/latest/userguide/ps-integration-lambda-extensions.html#ps-integration-lambda-extensions-add
    "arn:aws:lambda:ap-northeast-1:133490724326:layer:AWS-Parameters-and-Secrets-Lambda-Extension:19"
  ]

  environment {
    variables = {
      SLACK_BOT_TOKEN_PARAM_PATH = aws_ssm_parameter.slack_bot_token.name
      SLACK_SIGNIN_SECRET_PATH   = aws_ssm_parameter.slack_signin_secret.name
      DYNAMODB_TABLE_NAME        = aws_dynamodb_table.event_triggered.name
      MENTION_USER_ID            = "YOUR_SLACK_ID"
    }
  }
  depends_on = [aws_cloudwatch_log_group.lambda_log_group]


}

resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/${var.project}-app"
  retention_in_days = 14
}
