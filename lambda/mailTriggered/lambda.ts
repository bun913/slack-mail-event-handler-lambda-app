import { Context, Callback, APIGatewayProxyEvent, APIGatewayProxyResultV2 } from "aws-lambda"
import { App, AwsLambdaReceiver } from "@slack/bolt"
import { getParameter } from "./getSecret";
import { isEmailForwardingMessage, extractEmailContent } from "./eventHandler";
import { isPaymentEmail, getPaymentResult, extractPaymentId } from "./event/payment";
import { getPaymentEvent } from "./database/dynamodb";

let awsLambdaHandler: AwsLambdaReceiver
let app: App;

const initializeApp = async () => {
  const slackToken = await getParameter(process.env.SLACK_BOT_TOKEN_PARAM_PATH || "")
  const slackSigningSecret = await getParameter(process.env.SLACK_SIGNIN_SECRET_PATH || "")

  awsLambdaHandler = new AwsLambdaReceiver({
    signingSecret: slackSigningSecret
  })

  app = new App({
    token: slackToken,
    receiver: awsLambdaHandler
  });

  // Handle all message events to detect email forwarding
  app.event('message', async ({ event, logger, say, client }) => {
    // Check if this is an email forwarding message
    if (isEmailForwardingMessage(event)) {
      logger.info('Email forwarding detected')

      const emailContent = extractEmailContent(event)
      if (!emailContent) {
        return
      }

      // Check if this is a payment email
      if (!isPaymentEmail(emailContent)) {
        return
      }

      const paymentId = extractPaymentId(emailContent)
      if (!paymentId) {
        return
      }

      const paymentResult = getPaymentResult(emailContent)
      if (!paymentResult) {
        return
      }

      logger.info(`Payment email detected - ID: ${paymentId}, Result: ${paymentResult}`)

      // Look up the payment event in DynamoDB
      const paymentEvent = await getPaymentEvent(paymentId)

      if (!paymentEvent) {
        // No expected result found in DB
        await say({
          text: 'この支払いに対する期待値がDBから見つかりませんでした',
          channel: event.channel,
          thread_ts: event.ts
        })
        return
      }

      // Check if the result matches expectations
      if (paymentEvent.expected_result === paymentResult) {
        // Success - add thumbs up reaction
        await client.reactions.add({
          channel: event.channel,
          timestamp: event.ts,
          name: '+1'
        })
      } else {
        // Mismatch - send thread message with mention
        await say({
          text: `期待する結果と決済が異なります`,
          channel: event.channel,
          thread_ts: event.ts,
        })
      }
    }
  })
}

export const handler = async (
  event: APIGatewayProxyEvent,
  context: Context,
  callback: Callback
): Promise<APIGatewayProxyResultV2> => {
  try {
    if (!app) {
      await initializeApp()
    }

    const result = await awsLambdaHandler.start()
    return await result(event, context, callback)
  } catch (error) {
    console.error('Error in Lambda handler:', error)
    return {
      statusCode: 500,
      body: JSON.stringify({ error: 'Internal server error' })
    }
  }
}
