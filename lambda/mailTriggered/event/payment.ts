// Payment status messages
const PAYMENT_SUCCESS_MESSAGE = '支払いが完了しました'
const PAYMENT_FAILURE_MESSAGE = '支払いが失敗しました'

// Check if email content indicates payment completion or failure
export const isPaymentEmail = (emailContent: string): boolean => {
  return emailContent.includes(PAYMENT_SUCCESS_MESSAGE) || emailContent.includes(PAYMENT_FAILURE_MESSAGE)
}

// Determine if payment was successful or failed
export const getPaymentResult = (emailContent: string): 'success' | 'fail' | null => {
  if (emailContent.includes(PAYMENT_SUCCESS_MESSAGE)) {
    return 'success'
  } else if (emailContent.includes(PAYMENT_FAILURE_MESSAGE)) {
    return 'fail'
  }

  return null
}

// Extract payment ID from email content
export const extractPaymentId = (emailContent: string): string | null => {
  const paymentIdMatch = emailContent.match(/支払ID:\s*(\d+)/)
  return paymentIdMatch ? paymentIdMatch[1] : null
}