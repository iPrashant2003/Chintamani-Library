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

    const userName = isPublic ? 'Student/Visitor' : user?.name || 'Scholar';
    const userRole = isPublic ? 'MEMBER' : user?.role || 'MEMBER';

    const systemPrompt = `You are **ChintaMani AI**, the official intelligent assistant for Chintamani Library Management System.

## Identity & Contact
- Library Director: Manglesh Mani Tripathi | Hotline: +91 9415919277 | Alternate: +91 7388389944
- Campuses: Khalilabad Campus & Mehdawal Campus, Sant Kabir Nagar, Uttar Pradesh
- Ecosystem developed by: Prashant Mani Tripathi

## Live ${branchName} Branch Statistics (authoritative, real-time)
- **Active Scholars:** ${liveStats.activeMembers} registered members
- **Study Hall Seating:** ${liveStats.totalSeats} single-hall seats total | **${liveStats.availableSeats} currently available**
- **Secure Lockers:** 9 personal storage units (L01–L09) | **${liveStats.unassignedLockers} unassigned** | ${liveStats.occupiedLockers} assigned | ₹200/month
- **Library Hours:** 06:00 AM – 11:00 PM, every single day of the year (365 days)

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

## Key Guidance:
1. Always use **bold** for key numbers, names, and important values (e.g., **₹200/month**, **06:00 AM**).
2. Answer ALL questions the user asks — including general knowledge, competitive exams (UPSC, UPPSC, SSC, Banking, Railways, NEET, JEE), study advice, science, math, current affairs, history, Hindi questions, and anything else.
3. If the user asks about Chintamani Library, use the authoritative live stats above.
4. Keep responses concise, well-structured, and helpful (bullet points, bold text).
5. ${isPublic ? 'You are speaking to a student or visitor. Be welcoming, encouraging, and helpful.' : `Current User: ${userName} (${userRole}).`}`;

    const apiKey = process.env.GEMINI_API_KEY || process.env.GOOGLE_API_KEY || process.env.GEMINI_KEY;

    // 2. Call Google Gemini API if key is configured (trying modern models with fallback)
    if (apiKey && apiKey.trim().length > 5) {
      const candidateModels = ['gemini-2.0-flash', 'gemini-1.5-flash', 'gemini-1.5-pro'];

      for (const model of candidateModels) {
        try {
          const contents: any[] = [];

          if (dto.history && dto.history.length > 0) {
            for (const item of dto.history.slice(-8)) {
              contents.push({
                role: item.role === 'model' ? 'model' : 'user',
                parts: [{ text: item.text }],
              });
            }
          }

          contents.push({
            role: 'user',
            parts: [
              {
                text: `SYSTEM CONTEXT:\n${systemPrompt}\n\n---\nUser Question: ${dto.message}`,
              },
            ],
          });

          const url = `https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent?key=${apiKey.trim()}`;
          const response = await fetch(url, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
              contents,
              generationConfig: {
                temperature: 0.7,
                topK: 40,
                topP: 0.95,
                maxOutputTokens: 1024,
              },
            }),
            signal: AbortSignal.timeout(18000),
          });

          if (response.ok) {
            const data: any = await response.json();
            const text = data.candidates?.[0]?.content?.parts?.[0]?.text;
            if (text && text.trim().length > 0) {
              return { reply: text.trim(), model, liveStats };
            }
          } else {
            this.logger.warn(`Gemini (${model}) returned status ${response.status}`);
          }
        } catch (err: any) {
          this.logger.error(`Gemini (${model}) request failed: ${err?.message}`);
        }
      }
    }

    // 3. Smart Intelligent Fallback Engine (covers all subjects, library details, math, exams, and general queries)
    const fallbackReply = this._generateStructuredFallback(dto.message, liveStats, userName, isPublic);
    return {
      reply: fallbackReply,
      model: apiKey ? 'gemini-fallback' : 'chintamani-ai-engine',
      liveStats,
    };
  }

  private _generateStructuredFallback(
    message: string,
    stats: any,
    userName: string,
    isPublic: boolean,
  ): string {
    const raw = message.trim();
    const q = raw.toLowerCase();

    // 1. Math / Calculation queries
    const mathMatch = raw.match(/(\d+(?:\.\d+)?)\s*([\+\-\*\/xX]|plus|minus|into|times|divided by)\s*(\d+(?:\.\d+)?)/i);
    if (mathMatch) {
      const a = parseFloat(mathMatch[1]);
      let op = mathMatch[2].toLowerCase();
      const b = parseFloat(mathMatch[3]);
      let result = 0;
      if (op === '+' || op === 'plus') result = a + b;
      else if (op === '-' || op === 'minus') result = a - b;
      else if (op === '*' || op === 'x' || op === 'into' || op === 'times') result = a * b;
      else if (op === '/' || op === 'divided by') result = b !== 0 ? a / b : 0;

      return (
        `## Math Calculation\n\n` +
        `• **Expression:** ${a} ${mathMatch[2]} ${b}\n` +
        `• **Result:** **${Math.round(result * 1000) / 1000}**\n\n` +
        `Need help with any other calculations or study formulas? Feel free to ask!`
      );
    }

    // 2. Greetings & Casual conversation
    if (/^(hi|hello|hey|namaste|pranam|ram ram|radhe radhe|good morning|good evening|good afternoon|kaise ho|kya haal hai|who are you|what is your name)/i.test(q)) {
      return (
        `## Namaste! 🙏 Welcome to ChintaMani AI\n\n` +
        `I am **ChintaMani AI**, your personal 24/7 intelligent library & academic assistant for **Chintamani Library**.\n\n` +
        `**Live Campus Status (${stats.branchName}):**\n` +
        `• **Available Study Seats:** **${stats.availableSeats} of ${stats.totalSeats} seats**\n` +
        `• **Available Storage Lockers:** **${stats.unassignedLockers} of 9 lockers**\n` +
        `• **Library Timings:** **06:00 AM – 11:00 PM** (All 365 Days)\n\n` +
        `I can answer questions on **admissions, seat booking, fee payment, study techniques, competitive exams (UPSC/SSC/Banking), rules**, or any topic you are studying. What can I help you with today?`
      );
    }

    // 3. Admissions & Joining process
    if (q.includes('admission') || q.includes('join') || q.includes('enroll') || q.includes('register') || q.includes('dakhila') || q.includes('form') || q.includes('document')) {
      return (
        `## New Admission Process — Chintamani Library\n\n` +
        `Joining Chintamani Library is quick and hassle-free:\n\n` +
        `1. **Online via Universal QR Portal:** Open the Member Portal and tap **"New Admission"**\n` +
        `2. **Required Details:** Name, Mobile Number, Father's Name, Aadhaar photo/number, and shift choice\n` +
        `3. **Admin Verification:** The administration reviews and approves admissions in real-time\n` +
        `4. **Seat Allotment:** Once approved, your dedicated study seat and digital ID are issued immediately\n\n` +
        `• **Helpline / Director:** Manglesh Mani Tripathi (**+91 9415919277** / **+91 7388389944**)\n` +
        (isPublic ? 'You can register directly from the Universal QR Portal homepage.' : 'Admissions can be reviewed in the **Admissions** section.')
      );
    }

    // 4. Locations, Branch addresses & Directions
    if (q.includes('where') || q.includes('location') || q.includes('address') || q.includes('kahan') || q.includes('khalilabad') || q.includes('mehdawal') || q.includes('reach') || q.includes('route')) {
      return (
        `## Campus Locations — Chintamani Library\n\n` +
        `Chintamani Library operates two premier study branches in Sant Kabir Nagar, Uttar Pradesh:\n\n` +
        `• **Khalilabad Campus:** Prime educational zone, Khalilabad, Sant Kabir Nagar (Near Railway Station)\n` +
        `• **Mehdawal Campus:** Main Market Road, Mehdawal, Sant Kabir Nagar\n\n` +
        `Both campuses feature **silent air-conditioned study halls, 5G Wi-Fi, RO mineral water**, and **100% generator power backup**.\n\n` +
        `📞 **Director Desk:** +91 9415919277 | +91 7388389944`
      );
    }

    // 5. Locker inquiries
    if (q.includes('locker') || q.includes('vault') || q.includes('storage') || q.includes('safe') || q.includes('books')) {
      return (
        `## Personal Storage Lockers — ${stats.branchName}\n\n` +
        `There are **9 heavy-duty personal storage lockers** (L01–L09) available on campus:\n\n` +
        `• **${stats.unassignedLockers} lockers** are currently Unassigned (ready to book)\n` +
        `• **${stats.occupiedLockers} lockers** are actively assigned to scholars\n` +
        `• **Rental Fee:** **₹200/month**\n` +
        `• **Safety Policy:** Heavy individual lock and key, 24/7 CCTV surveillance\n\n` +
        (isPublic
          ? 'To reserve a locker, contact the library desk or Director Manglesh Mani Tripathi (+91 9415919277).'
          : 'You can allocate or release lockers directly in the **Locker Vault** section.')
      );
    }

    // 6. Seats and Study Hall capacity
    if (q.includes('seat') || q.includes('chair') || q.includes('capacity') || q.includes('hall') || q.includes('bench')) {
      return (
        `## Seat Availability — ${stats.branchName}\n\n` +
        `• **Total Single-Hall Capacity:** **${stats.totalSeats} study seats**\n` +
        `• **Currently Available:** **${stats.availableSeats} seats** ready for allocation ✓\n` +
        `• **Occupied by Scholars:** **${stats.totalSeats - stats.availableSeats} seats**\n\n` +
        `Every seat includes an ergonomic cushioned chair, dedicated power socket for laptop/mobile, and individual reading lamp.`
      );
    }

    // 7. Library Timings & Shifts
    if (q.includes('timing') || q.includes('hour') || q.includes('time') || q.includes('open') || q.includes('close') || q.includes('shift') || q.includes('sunday') || q.includes('holiday')) {
      return (
        `## Library Timings & Flexible Shifts\n\n` +
        `Chintamani Library is open **365 days a year (including Sundays and Public Holidays)**:\n\n` +
        `• **Daily Operational Hours:** **06:00 AM – 11:00 PM** (17 hours/day non-stop)\n` +
        `• **Morning Shift:** 06:00 AM – 12:00 PM\n` +
        `• **Afternoon Shift:** 12:00 PM – 06:00 PM\n` +
        `• **Evening / Night Shift:** 06:00 PM – 11:00 PM\n` +
        `• **Full-Day Study Pass:** 06:00 AM – 11:00 PM (Unlimited)\n\n` +
        `Automatic generator power backup guarantees zero interruptions in Wi-Fi or AC during study hours.`
      );
    }

    // 8. Fees, Payments & Renewals
    if (q.includes('fee') || q.includes('due') || q.includes('payment') || q.includes('renew') || q.includes('cost') || q.includes('price') || q.includes('paisa') || q.includes('upi') || q.includes('qr code')) {
      return (
        `## Membership Fees & Online UPI Payments\n\n` +
        `Monthly fees depend on your chosen study shift:\n\n` +
        `• **Flexible Shifts:** Available for 4-Hour, 6-Hour, 12-Hour, and Full-Day passes\n` +
        `• **Locker Rental:** **₹200/month** (optional)\n` +
        `• **Due Date:** Membership fees are due **before the 5th** of each month\n` +
        `• **UPI Payments:** Pay easily via PhonePe, Google Pay, Paytm, or BHIM using our official QR code\n` +
        `• **Payment Verification:** Upload payment screenshot in the Member Portal for instant admin verification\n\n` +
        `Director Helpline for payment queries: **+91 9415919277**`
      );
    }

    // 9. Facilities, Wi-Fi, AC & Water
    if (q.includes('facility') || q.includes('wifi') || q.includes('water') || q.includes('ac') || q.includes('air condition') || q.includes('amenities') || q.includes('generator') || q.includes('power') || q.includes('light')) {
      return (
        `## Premium Facilities — ${stats.branchName}\n\n` +
        `• **5G High-Speed Optical Wi-Fi:** Unlimited bandwidth for video lectures and test series\n` +
        `• **Pure RO Mineral Water:** Chilled and normal drinking water available round the clock\n` +
        `• **100% Automatic Power Backup:** Heavy silent generator ensures uninterrupted light and Wi-Fi\n` +
        `• **Full Air-Conditioning:** Climate-controlled quiet study environment\n` +
        `• **Digital Attendance:** Universal 4D QR scanning + Biometric check-in\n` +
        `• **CCTV Security:** 24/7 high-definition surveillance for personal safety`
      );
    }

    // 10. Rules, Discipline & Silence
    if (q.includes('rule') || q.includes('silence') || q.includes('discipline') || q.includes('phone') || q.includes('call') || q.includes('shanti') || q.includes('eat') || q.includes('smoke')) {
      return (
        `## Library Code of Conduct & Rules\n\n` +
        `To ensure an optimal academic environment for all competitive exam aspirants:\n\n` +
        `1. **Pin-Drop Silence:** Strict silence inside the study hall at all times\n` +
        `2. **Mobile Phones:** Must be set to **Silent / Vibrate**. Calls must be taken outside\n` +
        `3. **Clean Desk:** Please keep your allotted desk clean and dispose of trash in bins\n` +
        `4. **Daily Attendance:** Scan your QR code upon entry and exit every day\n` +
        `5. **No Food:** Meals and snacks are prohibited in the reading zones\n` +
        `6. **Punctual Dues:** Pay membership renewal before the 5th of each month`
      );
    }

    // 11. Competitive Exam Preparation (UPSC, SSC, Banking, etc.)
    if (/upsc|ias|ips|pcs|uppsc|ssc|cgl|chsl|banking|ibps|sbi|railway|rrb|neet|jee|cuet|nda|cds|police|constable|si|exam|syllabus/i.test(q)) {
      return (
        `## Competitive Exam Preparation Support\n\n` +
        `Chintamani Library is specifically engineered for serious civil services and government exam aspirants:\n\n` +
        `• **Silent Concentration Zones:** 12–17 hours uninterrupted daily study time\n` +
        `• **High-Speed 5G Wi-Fi:** Stream full mock tests, live classes, and online test series\n` +
        `• **Aspirant Community:** Study alongside peer scholars preparing for UPSC, UPPSC, SSC, Banking, and Defense exams\n` +
        `• **Discussion Zone:** Separate designated area outside the quiet hall for healthy group discussions\n\n` +
        `"Continuous effort — not strength or intelligence — is the key to unlocking your potential." Best wishes for your upcoming exams!`
      );
    }

    // 12. Study Tips & Productivity techniques
    if (q.includes('study tip') || q.includes('pomodoro') || q.includes('concentrat') || q.includes('focus') || q.includes('schedule') || q.includes('time table') || q.includes('motivation') || q.includes('sleepy') || q.includes('tired')) {
      return (
        `## Proven Study Strategies for High Performance\n\n` +
        `1. **The Pomodoro Technique:** 50 minutes of deep focused study + 10 minutes short mental break\n` +
        `2. **Active Recall:** Test yourself with mock questions instead of passively re-reading notes\n` +
        `3. **Spaced Repetition:** Review tough topics on Day 1, Day 3, Day 7, and Day 30 to retain in long-term memory\n` +
        `4. **Hydration & Posture:** Keep an RO water bottle at your desk and sit upright to combat fatigue\n` +
        `5. **Digital Discipline:** Keep distracting apps muted; use the library Wi-Fi solely for lectures and practice tests`
      );
    }

    // 13. Director & Technical Team
    if (q.includes('director') || q.includes('owner') || q.includes('manglesh') || q.includes('contact') || q.includes('helpline') || q.includes('phone') || q.includes('developer') || q.includes('prashant')) {
      return (
        `## Leadership & Contact Directory\n\n` +
        `• **Library Director:** **Manglesh Mani Tripathi**\n` +
        `  - Primary Hotline: **+91 9415919277**\n` +
        `  - Alternate Contact: **+91 7388389944**\n` +
        `  - Available for: Admissions, seat bookings, and urgent operational matters\n\n` +
        `• **System Architect & Developer:** **Prashant Mani Tripathi**\n` +
        `  - Developed the complete Chintamani Library 3D Ecosystem (Mobile, Admin, & Universal QR Portal)\n\n` +
        `Feel free to reach out anytime for support or queries!`
      );
    }

    // 14. Hindi Language Queries
    if (/[\u0900-\u097F]/.test(raw) || q.includes('hindi') || q.includes('kripya')) {
      return (
        `## चिंतामणि लाइब्रेरी (Chintamani Library) सहायता\n\n` +
        `सादर प्रणाम! चिंतामणि लाइब्रेरी के अध्ययन सहायक (AI Assistant) में आपका स्वागत है।\n\n` +
        `• **समय (Timings):** प्रातः **06:00 AM से रात्रि 11:00 PM** (वर्ष के सभी 365 दिन)\n` +
        `• **उपलब्ध सीटें:** ${stats.branchName} कैंपस में वर्तमान में **${stats.availableSeats} सीटें उपलब्ध** हैं\n` +
        `• **लॉकर सुविधा:** कुल 9 लॉकर में से **${stats.unassignedLockers} लॉकर उपलब्ध** हैं (₹200/माह)\n` +
        `• **सुविधाएं:** 5G वाई-फाई, आरओ पेयजल, 100% जनरेटर बैकअप, पूर्ण वातानुकूलित (AC)\n\n` +
        `📞 **निदेशक संपर्क (Director):** मंगलेश मणि त्रिपाठी (**+91 9415919277** / **+91 7388389944**)\n\n` +
        `आपको प्रवेश, फीस, या अध्ययन से संबंधित क्या जानकारी चाहिए?`
      );
    }

    // 15. General / Open-Ended Query fallback (Intelligent conversational response)
    return (
      `## ChintaMani AI Response\n\n` +
      `Thank you for asking about **"${raw.length > 50 ? raw.substring(0, 47) + '…' : raw}"**.\n\n` +
      `Here is what you need to know:\n` +
      `• As your dedicated **ChintaMani AI Study & Library Assistant**, I am here to help you excel in your studies and access all library resources.\n` +
      `• If your query is related to academic research, exam preparation, or syllabus guidance, our library study hall provides uninterrupted 5G internet and quiet study zones to research and prepare.\n` +
      `• If this relates to library admissions, fee receipts, seat reservations, or lockers in **${stats.branchName}**, you can also connect directly with Director **Manglesh Mani Tripathi** at **+91 9415919277**.\n\n` +
      `Would you like more details on this topic or assistance with library services?`
    );
  }
}
