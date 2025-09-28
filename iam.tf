### Lambda
resource "aws_iam_role" "lambda_role" {
  name               = "${var.project}-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "policy" {
  name        = "${var.project}-lambda-policy"
  path        = "/"
  description = "${var.project} Lambda Role to execute DynamoDB"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        // CloudWatch Logs permissions
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        // Parameter Store permissions - restricted to specific parameters
        Action = [
          "ssm:GetParameter"
        ]
        Effect = "Allow"
        Resource = [
          aws_ssm_parameter.slack_bot_token.arn,
          aws_ssm_parameter.slack_signin_secret.arn
        ]
      },
      {
        // KMS permissions for Parameter Store decryption
        Action = [
          "kms:Decrypt"
        ]
        Effect = "Allow"
        Resource = [
          "arn:aws:kms:*:*:key/*"
        ]
        Condition = {
          StringEquals = {
            "kms:ViaService" = "ssm.*.amazonaws.com"
          }
        }
      },
      {
        // DynamoDB permissions - restricted to project tables
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Query",
          "dynamodb:Scan",
          "dynamodb:BatchGetItem",
          "dynamodb:BatchWriteItem"
        ]
        Effect = "Allow"
        Resource = [
          aws_dynamodb_table.event_triggered.arn,
          "${aws_dynamodb_table.event_triggered.arn}/index/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role = aws_iam_role.lambda_role.name
  // I plan to use DynamoDB later, so I use the basic role to use it
  // FYI: https://dev.classmethod.jp/articles/lambda-get-paramater/
  policy_arn = aws_iam_policy.policy.arn
}

### API Gateway
resource "aws_iam_role" "api_gateway_role" {
  name               = "${var.project}-apigateway-role"
  assume_role_policy = data.aws_iam_policy_document.api_gateway_assume_role.json
}

resource "aws_iam_role_policy_attachment" "api_gateway_policy_logs" {
  role       = aws_iam_role.api_gateway_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"
}

resource "aws_iam_role_policy_attachment" "api_gateway_policy_lambda" {
  role       = aws_iam_role.api_gateway_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaRole"
}

data "aws_iam_policy_document" "api_gateway_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      type        = "Service"
      identifiers = ["apigateway.amazonaws.com"]
    }
  }
}
