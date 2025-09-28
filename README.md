# Mail to Slack to Lambda App

![design](./docs/design.drawio.svg)

This repository focuses on:

- Transfer Email to a specific Slack channel
  - FYI:https://slack.com/intl/ja-jp/help/articles/206819278-Slack-%E3%81%AB%E3%83%A1%E3%83%BC%E3%83%AB%E3%82%92%E9%80%81%E4%BF%A1%E3%81%99%E3%82%8B
- Setting a Slack App by using AWS Lambda and API Gateway
  - FYI: WIP
  - Sorry, the article is written in Japanese only

## How to deploy

### Build your lambda application

```
cd lambda/mailTriggered
```

### Terraform apply

```bash
terraform apply
```
