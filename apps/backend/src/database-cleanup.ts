import { PrismaService } from './prisma/prisma.service';

/**
 * Ensures database contains only genuine data:
 * 1. Permanently removes demo/seed members and all their relations.
 * 2. Permanently removes legacy demo seats (A01-A50, B01-B25).
 * 3. Enforces Single Hall and correct capacities (72 for Khalilabad, 65 for Mehdawal).
 */
export async function runDatabaseCleanup(prisma: PrismaService): Promise<void> {
  try {
    console.log('[DatabaseCleanup] Checking database records for demo data...');

    // 1. Identify Demo Members (from initial seeds)
    const demoFirstNames = [
      'Aarav', 'Vivaan', 'Aditya', 'Vihaan', 'Arjun', 'Sai', 'Reyansh', 'Krishna',
      'Ishaan', 'Shaurya', 'Atharv', 'Advik', 'Pranav', 'Advait', 'Dhruv', 'Kabir',
      'Ritvik', 'Aarush', 'Ayaan', 'Ranveer', 'Priya', 'Ananya', 'Isha', 'Kavya',
      'Riya', 'Sneha', 'Pooja', 'Neha', 'Divya', 'Sakshi'
    ];

    const knownDemoNames = [
      'Vikram Cloud Student',
      'Vikram Khalilabad Student',
      'Aditi Mehdawal Student',
      'Aakash Gupta', 'Bhavna Sen', 'Chirag Sethi', 'Devanshi Rai',
      'Eshaan Kapoor', 'Falguni Joshi', 'Gaurav Bhatia', 'Himani Rawat',
      'Inderjit Gill', 'Juhi Chawla', 'Kunal Deshmukh', 'Lavanya Roy'
    ];

    const allMembers = await prisma.member.findMany({
      select: { id: true, name: true, createdAt: true, memberCode: true }
    });

    const demoMembers = allMembers.filter(m => {
      const isKnown = knownDemoNames.includes(m.name);
      const isSeedDate = m.createdAt.toISOString().startsWith('2026-09-09');
      const firstName = m.name.split(' ')[0];
      const isDemoSeed = isSeedDate && demoFirstNames.includes(firstName);
      return isKnown || isDemoSeed;
    });

    if (demoMembers.length > 0) {
      console.log(`[DatabaseCleanup] Found ${demoMembers.length} demo members to delete...`);
      for (const dm of demoMembers) {
        try {
          await prisma.attendance.deleteMany({ where: { memberId: dm.id } });
          await prisma.payment.deleteMany({ where: { memberId: dm.id } });
          await prisma.seatAssignment.deleteMany({ where: { subscription: { memberId: dm.id } } });
          await prisma.lockerAssignment.deleteMany({ where: { subscription: { memberId: dm.id } } });
          await prisma.subscription.deleteMany({ where: { memberId: dm.id } });
          await prisma.complaint.deleteMany({ where: { memberId: dm.id } });
          await prisma.paymentVerification.deleteMany({ where: { memberId: dm.id } });
          await prisma.feedback.deleteMany({ where: { memberId: dm.id } });
          await prisma.member.delete({ where: { id: dm.id } });
        } catch (e: any) {
          console.error(`[DatabaseCleanup] Error deleting member ${dm.name}:`, e.message);
        }
      }
      console.log(`[DatabaseCleanup] Successfully removed demo members.`);
    }

    // 2. Identify Non-standard Demo Seats (A01..A25, B01..B25, etc.)
    const allSeats = await prisma.seat.findMany({
      include: { branch: { select: { name: true } } }
    });

    const nonStandardSeats = allSeats.filter(s => {
      const branchName = s.branch?.name || '';
      const isKhl = branchName.toLowerCase().includes('khalilabad');
      const prefix = isKhl ? 'K' : 'M';
      const max = isKhl ? 72 : 65;
      const match = s.seatNumber.match(new RegExp(`^${prefix}(\\d{2})$`));
      if (!match) return true;
      const num = parseInt(match[1], 10);
      return num < 1 || num > max;
    });

    if (nonStandardSeats.length > 0) {
      console.log(`[DatabaseCleanup] Found ${nonStandardSeats.length} legacy demo seats to delete...`);
      for (const seat of nonStandardSeats) {
        try {
          await prisma.subscription.updateMany({
            where: { assignedSeatId: seat.id },
            data: { assignedSeatId: null }
          });
          await prisma.seatAssignment.deleteMany({ where: { seatId: seat.id } });
          await prisma.seat.delete({ where: { id: seat.id } });
        } catch (e: any) {
          console.error(`[DatabaseCleanup] Error deleting seat ${seat.seatNumber}:`, e.message);
        }
      }
      console.log(`[DatabaseCleanup] Successfully removed non-standard seats.`);
    }

    // 3. Ensure all remaining seats are set to 'Single Hall'
    await prisma.seat.updateMany({
      where: {
        OR: [
          { seatNumber: { startsWith: 'K' } },
          { seatNumber: { startsWith: 'M' } }
        ]
      },
      data: { floor: 'Single Hall' }
    });

    console.log('[DatabaseCleanup] Database records successfully verified and clean.');
  } catch (err: any) {
    console.error('[DatabaseCleanup] Startup check failed:', err.message);
  }
}
