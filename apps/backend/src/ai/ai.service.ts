import { Injectable, Logger } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { resolveBranchInfo } from '../common/utils/branch-resolver.util';
import { ChatRequestDto } from './dto/chat-request.dto';

@Injectable()
export class AiService {
  private readonly logger = new Logger(AiService.name);

  constructor(private readonly prisma: PrismaService) {}

  async chat(dto: ChatRequestDto, user: any) {
    const rawBranchId = dto.branchId || user?.branchId;
    let branchInfo: any = null;
    let branchId = rawBranchId;

    if (rawBranchId) {
      branchInfo = await resolveBranchInfo(this.prisma, rawBranchId);
      if (branchInfo) {
        branchId = branchInfo.id;
      }
    }

    // 1. Fetch live authoritative library statistics for grounded context
    const [totalSeats, availableSeats, totalMembers, totalLockers, occupiedLockers] = await Promise.all([
      branchId ? this.prisma.seat.count({ where: { branchId } }) : this.prisma.seat.count(),
      branchId ? this.prisma.seat.count({ where: { branchId, status: 'AVAILABLE' } }) : this.prisma.seat.count({ where: { status: 'AVAILABLE' } }),
      branchId ? this.prisma.member.count({ where: { branchId, isActive: true } }) : this.prisma.member.count({ where: { isActive: true } }),
      // Valid lockers strictly 9 per branch
      9,
      branchId ? this.prisma.locker.count({ where: { branchId, status: 'OCCUPIED' } }) : this.prisma.locker.count({ where: { status: 'OCCUPIED' } }),
    ]);

    const unassignedLockers = Math.max(0, 9 - occupiedLockers);
    const branchName = branchInfo?.name || (branchId?.includes('mehdawal') ? 'Mehdawal' : 'Khalilabad');

    const liveStats = {
      branchName,
      totalSeats: totalSeats || (branchName.toLowerCase().includes('mehdawal') ? 65 : 72),
      availableSeats,
      totalLockers: 9,
      unassignedLockers,
      occupiedLockers,
      activeMembers: totalMembers,
    };

    const systemPrompt = `You are ChintaMani AI, the official intelligent assistant for Chintamani Library Management System.
Director: Manglesh Mani Tripathi (Hotline: +91 9415919277).
Current User: ${user?.name || 'Administrator'} (Role: ${user?.role || 'ADMIN'}).
Active Branch: ${liveStats.branchName} Branch.

Authoritative Live System Information:
- Seating: ${liveStats.totalSeats} single hall seats in ${liveStats.branchName} (${liveStats.availableSeats} currently available).
- Lockers: Exactly 9 secure personal storage units (L01–L09) in ${liveStats.branchName} (${liveStats.unassignedLockers} unassigned, ${liveStats.occupiedLockers} assigned). Standard fee: ₹200/month.
- Active Scholars: ${liveStats.activeMembers} registered members.
- Library Hours: 06:00 AM – 11:00 PM every day.
- Facilities: 5G High-Speed Wi-Fi, Pure RO Mineral Drinking Water, 100% Automatic Power Backup Generator, Fully Air-Conditioned Silent Environment, Biometric & Universal 4D QR Self-Attendance Scanner.
- Security & Rules: Silence must be observed in study zones. Personal lockers must not store hazardous materials. Dues can be cleared directly from Due Payments.

Instructions:
1. Always be polite, professional, concise, and helpful.
2. Answer based on the authoritative live statistics provided above.
3. If an administrator asks about operational workflows, guide them to the appropriate screen (Seats, Lockers, Members Directory, Due Payments, Universal QR Portal).
4. Never fabricate data or show unofficial branch information. Keep both branches strictly isolated.`;

    const apiKey = process.env.GEMINI_API_KEY;

    // 2. Call Google Gemini API if GEMINI_API_KEY is configured
    if (apiKey && apiKey.trim().length > 5) {
      try {
        const contents: any[] = [];

        // Add conversation history
        if (dto.history && dto.history.length > 0) {
          for (const item of dto.history.slice(-6)) {
            contents.push({
              role: item.role === 'model' ? 'model' : 'user',
              parts: [{ text: item.text }],
            });
          }
        }

        // Add current user prompt
        contents.push({
          role: 'user',
          parts: [{ text: `${systemPrompt}\n\nUser Question: ${dto.message}` }],
        });

        const url = `https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${apiKey}`;
        const response = await fetch(url, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ contents }),
          signal: AbortSignal.timeout(15000),
        });

        if (response.ok) {
          const data: any = await response.json();
          const candidate = data.candidates?.[0];
          const text = candidate?.content?.parts?.[0]?.text;
          if (text) {
            return {
              reply: text.trim(),
              model: 'gemini-1.5-flash',
              liveStats,
            };
          }
        } else {
          this.logger.warn(`Gemini API returned status ${response.status}`);
        }
      } catch (err: any) {
        this.logger.error(`Error communicating with Gemini API: ${err?.message}`);
      }
    }

    // 3. Deterministic Knowledge Fallback Engine using live database metrics
    const fallbackReply = this.generateAuthoritativeFallback(dto.message, liveStats, user);
    return {
      reply: fallbackReply,
      model: apiKey ? 'gemini-fallback' : 'chintamani-knowledge-engine',
      liveStats,
    };
  }

  private generateAuthoritativeFallback(message: string, stats: any, user: any): string {
    const q = message.toLowerCase();

    if (q.includes('locker') || q.includes('vault')) {
      return `In ${stats.branchName}, there are exactly 9 personal lockers (L01–L09). Currently, **${stats.unassignedLockers} lockers are Unassigned** and available for allocation at ₹200/month. You can manage locker assignments in the **Locker Vault** section.`;
    }

    if (q.includes('seat') || q.includes('chair') || q.includes('capacity')) {
      return `${stats.branchName} features a single study hall with **${stats.totalSeats} seats**. Currently, **${stats.availableSeats} seats are Available**. You can review the full hall layout in the **Single Hall Seats** section.`;
    }

    if (q.includes('timing') || q.includes('hour') || q.includes('time') || q.includes('open')) {
      return `Chintamani Library is open daily from **06:00 AM to 11:00 PM** across both Khalilabad and Mehdawal branches with uninterrupted power backup and high-speed Wi-Fi.`;
    }

    if (q.includes('director') || q.includes('contact') || q.includes('phone') || q.includes('helpline') || q.includes('manglesh')) {
      return `You can contact Director **Manglesh Mani Tripathi** directly via the library hotline at **+91 9415919277** for immediate administrative assistance or urgent inquiries.`;
    }

    if (q.includes('fee') || q.includes('due') || q.includes('payment') || q.includes('renew')) {
      return `Membership fees and expiring renewals can be checked under **Due Payments & Fees**. You can also send instant WhatsApp fee reminders directly to scholars from that screen.`;
    }

    if (q.includes('qr') || q.includes('portal') || q.includes('attendance')) {
      return `The **Universal 4D Portal & QR** allows scholars to scan for instant self-attendance and e-agreement verification. You can access it anytime from the top bar or drawer menu.`;
    }

    return `Hello ${user?.name || 'Administrator'}! I am ChintaMani AI. Currently in **${stats.branchName}**, we have **${stats.availableSeats} available seats** (out of ${stats.totalSeats}) and **${stats.unassignedLockers} unassigned lockers** (out of 9). How can I assist you with scholars, seat allocations, or library operations today?`;
  }
}
