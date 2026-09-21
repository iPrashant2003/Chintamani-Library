export interface IPushProvider {
  send(deviceToken: string, title: string, body: string, data?: Record<string, any>): Promise<{ success: boolean; ref?: string }>;
}

export class MockPushProvider implements IPushProvider {
  async send(deviceToken: string, title: string, body: string, data?: Record<string, any>): Promise<{ success: boolean; ref?: string }> {
    console.log(`[PUSH MOCK] To: ${deviceToken} | Title: ${title} | Body: ${body}`);
    return { success: true, ref: `push-mock-${Date.now()}` };
  }
}
