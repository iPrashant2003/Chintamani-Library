export interface IWhatsappProvider {
  send(phone: string, message: string): Promise<{ success: boolean; ref?: string }>;
}

export class MockWhatsappProvider implements IWhatsappProvider {
  async send(phone: string, message: string): Promise<{ success: boolean; ref?: string }> {
    console.log(`[WHATSAPP MOCK] To: ${phone} | Message: ${message}`);
    return { success: true, ref: `wa-mock-${Date.now()}` };
  }
}
