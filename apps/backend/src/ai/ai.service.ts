import { Injectable, Logger } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { resolveBranchInfo } from '../common/utils/branch-resolver.util';
import { ChatRequestDto } from './dto/chat-request.dto';

@Injectable()
export class AiService {
  private readonly logger = new Logger(AiService.name);

  constructor(private readonly prisma: PrismaService) {}

  async chat(dto: ChatRequestDto, user: any) {
    return this._processChat(dto, user, false);
  }

  async publicChat(dto: ChatRequestDto) {
    return this._processChat(dto, null, true);
  }

  private async _processChat(dto: ChatRequestDto, user: any, isPublic: boolean) {
    const rawBranchId = dto.branchId || user?.branchId;
    let branchInfo: any = null;
    let branchId = rawBranchId;

    if (rawBranchId) {
      branchInfo = await resolveBranchInfo(this.prisma, rawBranchId);
      if (branchInfo) branchId = branchInfo.id;
    }

    // 1. Fetch live authoritative library statistics
    const [totalSeats, availableSeats, totalMembers, occupiedLockers] = await Promise.all([
      branchId
        ? this.prisma.seat.count({ where: { branchId } })
        : this.prisma.seat.count(),
      branchId
        ? this.prisma.seat.count({ where: { branchId, status: 'AVAILABLE' } })
        : this.prisma.seat.count({ where: { status: 'AVAILABLE' } }),
      branchId
        ? this.prisma.member.count({ where: { branchId, isActive: true } })
        : this.prisma.member.count({ where: { isActive: true } }),
      branchId
        ? this.prisma.locker.count({ where: { branchId, status: 'OCCUPIED' } })
        : this.prisma.locker.count({ where: { status: 'OCCUPIED' } }),
    ]);

    const unassignedLockers = Math.max(0, 9 - occupiedLockers);
    const branchName =
      branchInfo?.name ||
      (rawBranchId?.toLowerCase().includes('mehdawal') ? 'Mehdawal' : 'Khalilabad');

    const liveStats = {
      branchName,
      totalSeats: totalSeats || (branchName.toLowerCase().includes('mehdawal') ? 65 : 72),
      availableSeats,
      totalLockers: 9,
      unassignedLockers,
      occupiedLockers,
      activeMembers: totalMembers,
    };

    const userName = isPublic ? 'Student/Visitor' : user?.name || 'Administrator';
    const userRole = isPublic ? 'MEMBER' : user?.role || 'ADMIN';

    const systemPrompt = `You are **ChintaMani AI**, the official intelligent assistant for Chintamani Library Management System.

## Identity
- Library Director: Manglesh Mani Tripathi | Hotline: +91 9415919277 | Alternate: +91 7388389944
- Branches: Khalilabad Campus & Mehdawal Campus, Sant Kabir Nagar, Uttar Pradesh
- Ecosystem developed by: Prashant Mani Tripathi

## Live ${branchName} Branch Statistics (authoritative, real-time)
- **Active Scholars:** ${liveStats.activeMembers} registered members
- **Study Hall Seating:** ${liveStats.totalSeats} single-hall seats total | **${liveStats.availableSeats} currently available**
- **Secure Lockers:** 9 personal storage units (L01–L09) | **${liveStats.unassignedLockers} unassigned** | ${liveStats.occupiedLockers} assigned | ₹200/month
- **Library Hours:** 06:00 AM – 11:00 PM, every day of the year

## Premium Facilities
- 5G High-Speed Wi-Fi (unlimited data)
- Pure RO Mineral Drinking Water
- 100% Automatic Power Backup Generator
- Fully Air-Conditioned Silent Study Environment
- Biometric & Universal 4D QR Self-Attendance System

## Rules & Policies
- Strict silence in all study zones
- No hazardous or prohibited materials in personal lockers
- Monthly dues must be cleared before the 5th of each month
- Attendance must be marked daily (Self-service via QR Portal or Biometric)
- Lost ID cards must be reported within 24 hours

## Response Formatting Rules (STRICTLY FOLLOW)
1. Always use **bold** for key numbers, names, and important values (e.g., **₹200/month**, **06:00 AM**)
2. Use bullet points (• ) for lists of features, rules, or options
3. Use numbered lists (1. 2. 3.) for steps or sequential information
4. Use ## Section Heading for separating major topics in longer responses
5. Keep responses **concise and factual** — 3 to 8 lines maximum unless a detailed breakdown is explicitly requested
6. Never fabricate statistics — always use the live data provided above
7. Never reveal internal admin screens or credentials to public/member users
8. If asked about something outside library scope, politely redirect to library topics
9. Always end with a helpful closing line offering further assistance when appropriate
10. ${isPublic ? 'You are speaking to a student or visitor (external portal). Be welcoming, student-friendly, and helpful. Do NOT mention admin-only features like member directory, locker assignments, or internal dashboards.' : `Current User: ${userName} (Role: ${userRole}). You may mention relevant admin navigation screens when helpful.`}`;

    const apiKey = process.env.GEMINI_API_KEY;

    // 2. Call Gemini API if key is configured
    if (apiKey && apiKey.trim().length > 5) {
      try {
        const contents: any[] = [];

        // Add conversation history (last 8 messages)
        if (dto.history && dto.history.length > 0) {
          for (const item of dto.history.slice(-8)) {
            contents.push({
              role: item.role === 'model' ? 'model' : 'user',
              parts: [{ text: item.text }],
            });
          }
        }

        // Inject system prompt into the user turn
        contents.push({
          role: 'user',
          parts: [
            {
              text: `SYSTEM CONTEXT (follow strictly):\n${systemPrompt}\n\n---\nUser Message: ${dto.message}`,
            },
          ],
        });

        const url = `https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${apiKey}`;
        const response = await fetch(url, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            contents,
            generationConfig: {
              temperature: 0.4,
              topK: 32,
              topP: 0.9,
              maxOutputTokens: 512,
            },
          }),
          signal: AbortSignal.timeout(15000),
        });

        if (response.ok) {
          const data: any = await response.json();
          const text = data.candidates?.[0]?.content?.parts?.[0]?.text;
          if (text) {
            return { reply: text.trim(), model: 'gemini-1.5-flash', liveStats };
          }
        } else {
          this.logger.warn(`Gemini API returned ${response.status}`);
        }
      } catch (err: any) {
        this.logger.error(`Gemini error: ${err?.message}`);
      }
    }

    // 3. Deterministic fallback engine with structured formatting
    const fallbackReply = this._generateStructuredFallback(dto.message, liveStats, userName, isPublic);
    return {
      reply: fallbackReply,
      model: apiKey ? 'gemini-fallback' : 'chintamani-knowledge-engine',
      liveStats,
    };
  }

  private _generateStructuredFallback(
    message: string,
    stats: any,
    userName: string,
    isPublic: boolean,
  ): string {
    const q = message.toLowerCase();

    if (q.includes('locker') || q.includes('vault')) {
      return (
        `## Locker Status — ${stats.branchName}\n\n` +
        `There are exactly **9 personal lockers** (L01–L09) in ${stats.branchName}.\n\n` +
        `• **${stats.unassignedLockers} lockers** are currently Unassigned (available)\n` +
        `• **${stats.occupiedLockers} lockers** are Assigned to scholars\n` +
        `• Monthly rental: **₹200/month**\n\n` +
        (isPublic
          ? 'Contact the library desk or Director to request a locker assignment.'
          : 'Manage locker assignments in the **Locker Vault** section.')
      );
    }

    if (q.includes('seat') || q.includes('chair') || q.includes('capacity') || q.includes('hall')) {
      return (
        `## Seat Availability — ${stats.branchName}\n\n` +
        `The single study hall has **${stats.totalSeats} seats** total.\n\n` +
        `• **${stats.availableSeats} seats** are currently Available ✓\n` +
        `• **${stats.totalSeats - stats.availableSeats} seats** are Occupied\n\n` +
        (isPublic
          ? 'Visit the library in person or use the **New Admission** form to reserve a seat.'
          : 'Review the full hall layout in the **Single Hall Seats** section.')
      );
    }

    if (q.includes('timing') || q.includes('hour') || q.includes('time') || q.includes('open') || q.includes('close')) {
      return (
        `## Library Timings\n\n` +
        `Chintamani Library is open **every day of the year**:\n\n` +
        `• **Opens:** 06:00 AM\n` +
        `• **Closes:** 11:00 PM\n` +
        `• **Total study hours:** 17 hours/day\n\n` +
        `Both Khalilabad and Mehdawal campuses follow the same schedule with **100% power backup** and Wi-Fi throughout.`
      );
    }

    if (q.includes('director') || q.includes('contact') || q.includes('helpline') || q.includes('phone') || q.includes('manglesh')) {
      return (
        `## Director Contact\n\n` +
        `**Manglesh Mani Tripathi**\n` +
        `Library Director, Chintamani Library\n\n` +
        `• **Primary:** +91 9415919277\n` +
        `• **Alternate:** +91 7388389944\n\n` +
        `Available for urgent inquiries, admissions, and operational matters.`
      );
    }

    if (q.includes('fee') || q.includes('due') || q.includes('payment') || q.includes('renew') || q.includes('cost') || q.includes('price')) {
      return (
        `## Fees & Due Payments\n\n` +
        `Monthly membership fees vary by plan and shift selection.\n\n` +
        `• Dues must be cleared **before the 5th** of each month\n` +
        `• **Locker rental:** ₹200/month (if assigned)\n` +
        `• UPI payments are accepted directly via the Member Portal\n\n` +
        (isPublic
          ? 'Use the **Fee Payment** option in this portal to pay dues via UPI.'
          : 'Send WhatsApp reminders and manage dues in the **Due Payments & Fees** section.')
      );
    }

    if (q.includes('qr') || q.includes('portal') || q.includes('attendance') || q.includes('scan')) {
      return (
        `## QR & Attendance\n\n` +
        `Chintamani Library offers a **Universal 4D QR Self-Attendance** system.\n\n` +
        `• Scholars scan their unique QR code at entry/exit\n` +
        `• Biometric attendance is also available at the front desk\n` +
        `• Admins can view the **Universal QR Portal** from the top bar\n\n` +
        `Attendance must be marked **daily** as per library policy.`
      );
    }

    if (q.includes('facility') || q.includes('wifi') || q.includes('water') || q.includes('ac') || q.includes('amenities')) {
      return (
        `## Library Facilities — ${stats.branchName}\n\n` +
        `• **5G High-Speed Wi-Fi** — unlimited access\n` +
        `• **Pure RO Mineral Water** — complimentary\n` +
        `• **100% Power Backup** — automatic generator, zero downtime\n` +
        `• **Air-Conditioned Environment** — silent, temperature-controlled\n` +
        `• **Biometric + QR Attendance** — fast, self-service check-in\n` +
        `• **Secure Personal Lockers** (L01–L09) — ₹200/month`
      );
    }

    if (q.includes('member') || q.includes('scholar') || q.includes('student') || q.includes('active')) {
      return (
        `## Member Statistics — ${stats.branchName}\n\n` +
        `• **Active Scholars:** ${stats.activeMembers} registered members\n` +
        `• **Available Seats:** ${stats.availableSeats} of ${stats.totalSeats}\n` +
        `• **Unassigned Lockers:** ${stats.unassignedLockers} of 9\n\n` +
        (isPublic
          ? 'Use **New Admission** to register and join Chintamani Library.'
          : 'View the complete member directory in the **Members** section.')
      );
    }

    // Default greeting / general response
    return (
      `## ${isPublic ? 'Welcome to Chintamani Library' : `Welcome, ${userName}!`}\n\n` +
      `**${stats.branchName} Campus — Live Status:**\n\n` +
      `• **Available Seats:** ${stats.availableSeats} of ${stats.totalSeats}\n` +
      `• **Unassigned Lockers:** ${stats.unassignedLockers} of 9\n` +
      (isPublic ? '' : `• **Active Scholars:** ${stats.activeMembers}\n`) +
      `\nI can help you with seat availability, locker status, library timings, fee information, and more. What would you like to know?`
    );
  }
}
