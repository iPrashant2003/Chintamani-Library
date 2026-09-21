export interface ISmsProvider {
  send(phone: string, message: string): Promise<{ success: boolean; ref?: string }>;
}

export class MockSmsProvider implements ISmsProvider {
  async send(phone: string, message: string): Promise<{ success: boolean; ref?: string }> {
    console.log(`[SMS MOCK] To: ${phone} | Message: ${message}`);
    return { success: true, ref: `sms-mock-${Date.now()}` };
  }
}
