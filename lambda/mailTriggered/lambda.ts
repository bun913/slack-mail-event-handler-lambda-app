import { Context, Callback, APIGatewayProxyEvent, APIGatewayProxyResultV2 } from "aws-lambda"
import { App, AwsLambdaReceiver } from "@slack/bolt"
import { getParameter } from "./getSecret";

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

  app.message("hello", async ({ message, say }) => {
    console.log(message)
    await say({
      text: `さぁ!お前の罪を数えろ！`
    })
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
