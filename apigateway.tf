resource "aws_apigatewayv2_api" "main" {
  name          = "${var.project}-http-api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_route" "main" {
  api_id    = aws_apigatewayv2_api.main.id
  route_key = "POST /slack/mailArrived"
  target    = "integrations/${aws_apigatewayv2_integration.main.id}"
}

resource "aws_apigatewayv2_integration" "main" {
  api_id             = aws_apigatewayv2_api.main.id
  connection_type    = "INTERNET"
  integration_method = "POST"
  integration_uri    = aws_lambda_function.mail_triggered_app.invoke_arn
  integration_type   = "AWS_PROXY"
}

# set Automatic stage deploy
resource "aws_apigatewayv2_stage" "main" {
  api_id      = aws_apigatewayv2_api.main.id
  auto_deploy = true
  name        = var.apigw_stage_name
}

# Grant API Gateway permission to invoke Lambda
resource "aws_lambda_permission" "allow_apigateway" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.mail_triggered_app.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.main.execution_arn}/*/*"
}
