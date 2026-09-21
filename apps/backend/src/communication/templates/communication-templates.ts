export const CommunicationTemplates: Record<string, { name: string; template: string }> = {
  PAYMENT_REMINDER: {
    name: 'Payment Reminder',
    template: 'Dear {{name}}, your payment of ₹{{amount}} is due for Chintamani Library. Please pay at the earliest. Contact us for queries.',
  },
  MEMBERSHIP_EXPIRY: {
    name: 'Membership Expiry',
    template: 'Dear {{name}}, your membership at Chintamani Library expires on {{date}}. Renew now to continue uninterrupted access.',
  },
  WELCOME: {
    name: 'Welcome Message',
    template: 'Welcome to Chintamani Library, {{name}}! Your member ID is {{memberCode}}. Seat: {{seat}}. We wish you productive study sessions.',
  },
  ATTENDANCE_REMINDER: {
    name: 'Attendance Reminder',
    template: 'Dear {{name}}, we miss you at Chintamani Library! Visit and maintain your study streak.',
  },
  GENERAL_ANNOUNCEMENT: {
    name: 'General Announcement',
    template: '{{message}}',
  },
  FEE_RECEIPT: {
    name: 'Fee Receipt',
    template: 'Dear {{name}}, payment of ₹{{amount}} received successfully at Chintamani Library. Txn: {{txnRef}}. Thank you!',
  },
};
