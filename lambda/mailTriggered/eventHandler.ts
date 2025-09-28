// Check if the message is an email forwarding message
export const isEmailForwardingMessage = (event: any): boolean => {
  return (
    event.subtype === 'file_share' &&
    event.files &&
    Array.isArray(event.files) &&
    event.files.some((file: any) => file.filetype === 'email')
  )
}

// Extract email content from forwarding message
export const extractEmailContent = (event: any): string | null => {
  if (!isEmailForwardingMessage(event)) {
    return null
  }

  const emailFile = event.files.find((file: any) => file.filetype === 'email')
  return emailFile?.plain_text || emailFile?.preview_plain_text || null
}

// Extract payment ID from email content
export const extractPaymentId = (emailContent: string): string | null => {
  const paymentIdMatch = emailContent.match(/支払ID:\s*(\d+)/)
  return paymentIdMatch ? paymentIdMatch[1] : null
}