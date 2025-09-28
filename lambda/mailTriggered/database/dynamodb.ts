import { DynamoDBClient, GetItemCommand } from "@aws-sdk/client-dynamodb"

const dynamoClient = new DynamoDBClient({ region: 'ap-northeast-1' })
const TABLE_NAME = process.env.DYNAMODB_TABLE_NAME || 'TestEventTable'

export interface PaymentEvent {
  eventId: string
  event_type: string
  expected_result: string
  params: string
  expirationDate: number
}

// Get payment event by eventId from DynamoDB
export const getPaymentEvent = async (eventId: string): Promise<PaymentEvent | null> => {
  try {
    const command = new GetItemCommand({
      TableName: TABLE_NAME,
      Key: {
        eventId: { S: eventId }
      }
    })

    const result = await dynamoClient.send(command)

    if (!result.Item) {
      return null
    }

    return {
      eventId: result.Item.eventId?.S || '',
      event_type: result.Item.event_type?.S || '',
      expected_result: result.Item.expected_result?.S || '',
      params: result.Item.params?.S || '',
      expirationDate: parseInt(result.Item.expirationDate?.N || '0')
    }
  } catch (error) {
    console.error('Error getting payment event from DynamoDB:', error)
    return null
  }
}