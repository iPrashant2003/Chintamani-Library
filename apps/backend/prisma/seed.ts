import { PrismaClient } from '@prisma/client';
import * as bcrypt from 'bcryptjs';

const prisma = new PrismaClient();

async function main() {
  console.log('🌱 Seeding Multi-Tenant LibraryOS database...\n');

  // Clean existing data in reverse relation order
  await prisma.auditLog.deleteMany();
  await prisma.communicationLog.deleteMany();
  await prisma.notification.deleteMany();
  await prisma.qrCode.deleteMany();
  await prisma.paymentTransaction.deleteMany();
  await prisma.payment.deleteMany();
  await prisma.seatAssignment.deleteMany();
  await prisma.lockerAssignment.deleteMany();
  await prisma.attendance.deleteMany();
  await prisma.subscription.deleteMany();
  await prisma.enquiry.deleteMany();
  await prisma.expense.deleteMany();
  await prisma.seat.deleteMany();
  await prisma.locker.deleteMany();
  await prisma.membershipPlan.deleteMany();
  await prisma.member.deleteMany();
  await prisma.permission.deleteMany();
  await prisma.userBranchAccess.deleteMany();
  await prisma.settings.deleteMany();
  await prisma.user.deleteMany();
  await prisma.branch.deleteMany();
  await prisma.tenant.deleteMany();

  console.log('✅ Cleaned existing data');

  const passwordHash = await bcrypt.hash('Admin@1234', 12);
  const staffHash = await bcrypt.hash('Staff@1234', 12);
  const superAdminHash = await bcrypt.hash('SuperAdmin@1234', 12);

  // --- Platform Super Admin ---
  await prisma.user.create({
    data: {
      name: 'Super Admin',
      email: 'superadmin@libraryos.com',
      password: superAdminHash,
      role: 'SUPER_ADMIN',
      phone: '9999999999',
    },
  });
  console.log('✅ Created Super Admin');

  // ==========================================
  // TENANT 1: Chintamani Library (CML)
  // ==========================================
  const tenant1 = await prisma.tenant.create({
    data: {
      name: 'Chintamani Library',
      code: 'CML',
      slug: 'chintamani-library',
      phone: '9876543210',
      email: 'contact@chintamanilibrary.com',
      address: 'Main Road, Khalilabad',
      city: 'Sant Kabir Nagar',
      state: 'Uttar Pradesh',
      country: 'India',
      plan: 'ENTERPRISE',
      status: 'ACTIVE',
    },
  });
  console.log('✅ Created Tenant 1: Chintamani Library (CML)');

  // Branches for Tenant 1
  const khalilabad = await prisma.branch.create({
    data: {
      tenantId: tenant1.id,
      name: 'Chintamani Library – Khalilabad',
      address: 'Main Road, Khalilabad, Sant Kabir Nagar, UP 272175',
      phone: '9876543210',
    },
  });
  const mehdawal = await prisma.branch.create({
    data: {
      tenantId: tenant1.id,
      name: 'Chintamani Library – Mehdawal',
      address: 'Station Road, Mehdawal, Sant Kabir Nagar, UP 272202',
      phone: '9876543211',
    },
  });

  // Users for Tenant 1
  const owner1 = await prisma.user.create({
    data: {
      tenantId: tenant1.id,
      name: 'Manglesh Mani Tripathi',
      email: 'owner@chintamani.com',
      password: passwordHash,
      role: 'OWNER',
      phone: '9999000001',
    },
  });
  const adminKhl = await prisma.user.create({
    data: {
      tenantId: tenant1.id,
      name: 'Rajesh Kumar',
      email: 'admin.khl@chintamani.com',
      password: passwordHash,
      role: 'ADMIN',
      phone: '9999000002',
    },
  });
  const adminMhd = await prisma.user.create({
    data: {
      tenantId: tenant1.id,
      name: 'Suresh Verma',
      email: 'admin.mhd@chintamani.com',
      password: passwordHash,
      role: 'ADMIN',
      phone: '9999000003',
    },
  });
  const staffKhl = await prisma.user.create({
    data: {
      tenantId: tenant1.id,
      name: 'Amit Sharma',
      email: 'staff.khl@chintamani.com',
      password: staffHash,
      role: 'STAFF',
      phone: '9999000004',
    },
  });
  const staffMhd = await prisma.user.create({
    data: {
      tenantId: tenant1.id,
      name: 'Deepak Yadav',
      email: 'staff.mhd@chintamani.com',
      password: staffHash,
      role: 'STAFF',
      phone: '9999000005',
    },
  });

  await prisma.userBranchAccess.createMany({
    data: [
      { userId: owner1.id, branchId: khalilabad.id },
      { userId: owner1.id, branchId: mehdawal.id },
      { userId: adminKhl.id, branchId: khalilabad.id },
      { userId: adminMhd.id, branchId: mehdawal.id },
      { userId: staffKhl.id, branchId: khalilabad.id },
      { userId: staffMhd.id, branchId: mehdawal.id },
    ],
  });

  // Plans for Tenant 1
  const planDefs1 = [
    { name: 'Daily', durationDays: 1, price: 80, includesSeat: true, includesLocker: false },
    { name: 'Monthly', durationDays: 30, price: 600, includesSeat: true, includesLocker: false },
    { name: 'Quarterly', durationDays: 90, price: 1700, includesSeat: true, includesLocker: true },
    { name: 'Half-Yearly', durationDays: 180, price: 3200, includesSeat: true, includesLocker: true },
    { name: 'Yearly', durationDays: 365, price: 6000, includesSeat: true, includesLocker: true },
  ];

  const plans1: Record<string, any[]> = { [khalilabad.id]: [], [mehdawal.id]: [] };
  for (const branch of [khalilabad, mehdawal]) {
    for (const pd of planDefs1) {
      const plan = await prisma.membershipPlan.create({
        data: { ...pd, tenantId: tenant1.id, branchId: branch.id },
      });
      plans1[branch.id].push(plan);
    }
  }

  // Seats for Tenant 1 (50 per branch)
  const seats1: Record<string, any[]> = { [khalilabad.id]: [], [mehdawal.id]: [] };
  for (const branch of [khalilabad, mehdawal]) {
    for (const floor of ['A', 'B']) {
      for (let i = 1; i <= 25; i++) {
        const seat = await prisma.seat.create({
          data: {
            tenantId: tenant1.id,
            seatNumber: `${floor}${i.toString().padStart(2, '0')}`,
            floor,
            branchId: branch.id,
            status: 'AVAILABLE',
          },
        });
        seats1[branch.id].push(seat);
      }
    }
  }

  // Lockers for Tenant 1 (20 per branch)
  const lockers1: Record<string, any[]> = { [khalilabad.id]: [], [mehdawal.id]: [] };
  for (const branch of [khalilabad, mehdawal]) {
    for (let i = 1; i <= 20; i++) {
      const locker = await prisma.locker.create({
        data: {
          tenantId: tenant1.id,
          lockerNumber: `L${i.toString().padStart(2, '0')}`,
          branchId: branch.id,
          status: 'AVAILABLE',
        },
      });
      lockers1[branch.id].push(locker);
    }
  }

  // Members for Tenant 1 (30 per branch)
  const firstNames = [
    'Aarav', 'Vivaan', 'Aditya', 'Vihaan', 'Arjun', 'Sai', 'Reyansh', 'Krishna',
    'Ishaan', 'Shaurya', 'Atharv', 'Advik', 'Pranav', 'Advait', 'Dhruv', 'Kabir',
    'Ritvik', 'Aarush', 'Ayaan', 'Ranveer', 'Priya', 'Ananya', 'Isha', 'Kavya',
    'Riya', 'Sneha', 'Pooja', 'Neha', 'Divya', 'Sakshi',
  ];
  const lastNames = [
    'Sharma', 'Verma', 'Gupta', 'Singh', 'Yadav', 'Patel', 'Kumar', 'Tripathi',
    'Mishra', 'Pandey', 'Dubey', 'Tiwari', 'Jaiswal', 'Maurya', 'Chauhan',
  ];
  const institutes = ['IIT BHU', 'MNNIT Allahabad', 'UPSC Aspirant', 'SSC Aspirant', 'NEET Aspirant', 'JEE Aspirant', 'BHU', 'Self Study'];
  const courses = ['B.Tech', 'M.Tech', 'MBBS', 'Civil Services', 'SSC CGL', 'JEE Preparation', 'NEET Preparation', 'General Studies'];

  function randomPhone(): string {
    return `98${Math.floor(10000000 + Math.random() * 90000000)}`;
  }
  function randomMemberCode(prefix: string): string {
    return `${prefix}-${Math.random().toString(36).substring(2, 8).toUpperCase()}`;
  }
  function randomDate(start: Date, end: Date): Date {
    return new Date(start.getTime() + Math.random() * (end.getTime() - start.getTime()));
  }

  const now = new Date();
  for (const branch of [khalilabad, mehdawal]) {
    let sIdx = 0;
    let lIdx = 0;
    for (let i = 0; i < 30; i++) {
      const firstName = firstNames[i % firstNames.length];
      const lastName = lastNames[Math.floor(Math.random() * lastNames.length)];
      const name = `${firstName} ${lastName}`;
      const gender = i < 20 ? 'Male' : 'Female';

      const member = await prisma.member.create({
        data: {
          tenantId: tenant1.id,
          memberCode: randomMemberCode('CML'),
          name,
          phone: randomPhone(),
          email: `${firstName.toLowerCase()}.${lastName.toLowerCase()}${i}@gmail.com`,
          dob: randomDate(new Date(1995, 0, 1), new Date(2005, 11, 31)),
          address: `${Math.floor(100 + Math.random() * 900)}, Ward ${Math.floor(1 + Math.random() * 15)}, ${branch === khalilabad ? 'Khalilabad' : 'Mehdawal'}`,
          academicInfo: JSON.stringify({
            fatherName: `${lastNames[Math.floor(Math.random() * lastNames.length)]} ${lastName}`,
            gender,
            institute: institutes[Math.floor(Math.random() * institutes.length)],
            course: courses[Math.floor(Math.random() * courses.length)],
            batch: `${2023 + Math.floor(Math.random() * 3)}`,
          }),
          branchId: branch.id,
          isActive: i < 25,
        },
      });

      let subStatus: string;
      let startDate: Date;
      let endDate: Date;
      const planIdx = Math.floor(Math.random() * 4) + 1;
      const plan = plans1[branch.id][planIdx];

      if (i < 20) {
        subStatus = 'ACTIVE';
        startDate = new Date(now);
        startDate.setDate(startDate.getDate() - Math.floor(Math.random() * plan.durationDays * 0.7));
        endDate = new Date(startDate);
        endDate.setDate(endDate.getDate() + plan.durationDays);
      } else if (i < 25) {
        subStatus = 'ACTIVE';
        endDate = new Date(now);
        endDate.setDate(endDate.getDate() + Math.floor(1 + Math.random() * 10));
        startDate = new Date(endDate);
        startDate.setDate(startDate.getDate() - plan.durationDays);
      } else {
        subStatus = 'EXPIRED';
        endDate = new Date(now);
        endDate.setDate(endDate.getDate() - Math.floor(5 + Math.random() * 55));
        startDate = new Date(endDate);
        startDate.setDate(startDate.getDate() - plan.durationDays);
      }

      const seat = i < 25 ? seats1[branch.id][sIdx++] : null;
      const locker = i < 10 ? lockers1[branch.id][lIdx++] : null;

      const subscription = await prisma.subscription.create({
        data: {
          tenantId: tenant1.id,
          memberId: member.id,
          planId: plan.id,
          startDate,
          endDate,
          status: subStatus,
          assignedSeatId: seat?.id || null,
          assignedLockerId: locker?.id || null,
        },
      });

      if (seat && subStatus === 'ACTIVE') {
        await prisma.seat.update({ where: { id: seat.id }, data: { status: 'OCCUPIED' } });
        await prisma.seatAssignment.create({
          data: { seatId: seat.id, subscriptionId: subscription.id },
        });
      }
      if (locker && subStatus === 'ACTIVE') {
        await prisma.locker.update({ where: { id: locker.id }, data: { status: 'OCCUPIED' } });
        await prisma.lockerAssignment.create({
          data: { lockerId: locker.id, subscriptionId: subscription.id },
        });
      }

      await prisma.payment.create({
        data: {
          tenantId: tenant1.id,
          memberId: member.id,
          amount: plan.price,
          method: ['CASH', 'UPI', 'CARD', 'BANK'][Math.floor(Math.random() * 4)] as any,
          status: i < 27 ? 'PAID' : 'PENDING',
          paidAt: i < 27 ? startDate : null,
          txnRef: i < 27 ? `TXN${Date.now()}${i}` : null,
        },
      });

      if (subStatus === 'ACTIVE') {
        for (let d = 0; d < 20; d++) {
          if (Math.random() < 0.7) {
            const checkInDate = new Date(now);
            checkInDate.setDate(checkInDate.getDate() - d);
            checkInDate.setHours(7 + Math.floor(Math.random() * 4), Math.floor(Math.random() * 60), 0, 0);

            const checkOutDate = new Date(checkInDate);
            checkOutDate.setHours(checkInDate.getHours() + 4 + Math.floor(Math.random() * 8));

            await prisma.attendance.create({
              data: {
                tenantId: tenant1.id,
                memberId: member.id,
                branchId: branch.id,
                checkIn: checkInDate,
                checkOut: d > 0 ? checkOutDate : null,
                method: Math.random() > 0.3 ? 'MANUAL' : 'QR',
              },
            });
          }
        }
      }
    }
  }

  // Enquiries for Tenant 1
  const enquiryStatuses = ['NEW', 'CONTACTED', 'INTERESTED', 'CONVERTED', 'NOT_INTERESTED'] as const;
  const enquiryNames = [
    'Rohit Mehra', 'Ankita Jain', 'Vikram Rathore', 'Simran Kaur', 'Mohit Agarwal',
    'Nisha Patel', 'Harsh Vardhan', 'Meera Iyer', 'Sanjay Dubey', 'Komal Tiwari',
  ];
  for (const branch of [khalilabad, mehdawal]) {
    for (let i = 0; i < 10; i++) {
      const followUpDate = new Date(now);
      followUpDate.setDate(followUpDate.getDate() + Math.floor(Math.random() * 7) - 2);

      await prisma.enquiry.create({
        data: {
          tenantId: tenant1.id,
          branchId: branch.id,
          name: enquiryNames[i],
          phone: randomPhone(),
          email: `${enquiryNames[i].split(' ')[0].toLowerCase()}@gmail.com`,
          status: enquiryStatuses[i % 5],
          followUpDate,
          notes: i % 3 === 0 ? 'Interested in monthly plan' : i % 3 === 1 ? 'Wants locker facility' : null,
        },
      });
    }
  }

  // Expenses for Tenant 1
  const expenseCategories = ['ELECTRICITY', 'INTERNET', 'MAINTENANCE', 'SALARY', 'CLEANING', 'EQUIPMENT', 'OTHER'] as const;
  for (const branch of [khalilabad, mehdawal]) {
    for (let monthOffset = 0; monthOffset < 2; monthOffset++) {
      for (const cat of expenseCategories) {
        const amount = Math.floor(1000 + Math.random() * 4000);
        const date = new Date(now);
        date.setMonth(date.getMonth() - monthOffset);
        date.setDate(Math.floor(1 + Math.random() * 28));

        await prisma.expense.create({
          data: {
            tenantId: tenant1.id,
            branchId: branch.id,
            category: cat as any,
            amount,
            description: `${cat.charAt(0) + cat.slice(1).toLowerCase()} expense`,
            date,
          },
        });
      }
    }
  }

  // Settings for Tenant 1
  for (const branch of [khalilabad, mehdawal]) {
    await prisma.settings.create({
      data: {
        tenantId: tenant1.id,
        branchId: branch.id,
        key: 'library_timing',
        value: JSON.stringify({ open: '06:00', close: '23:00' }),
      },
    });
    await prisma.settings.create({
      data: {
        tenantId: tenant1.id,
        branchId: branch.id,
        key: 'currency',
        value: JSON.stringify({ symbol: '₹', code: 'INR' }),
      },
    });
  }

  // ==========================================
  // TENANT 2: City Reading Hub (CRH)
  // ==========================================
  const tenant2 = await prisma.tenant.create({
    data: {
      name: 'City Reading Hub',
      code: 'CRH',
      slug: 'city-reading-hub',
      phone: '9811223344',
      email: 'info@cityreadinghub.com',
      address: 'Hazratganj Main Market',
      city: 'Lucknow',
      state: 'Uttar Pradesh',
      country: 'India',
      plan: 'STANDARD',
      status: 'ACTIVE',
    },
  });
  console.log('✅ Created Tenant 2: City Reading Hub (CRH)');

  const crhCentral = await prisma.branch.create({
    data: {
      tenantId: tenant2.id,
      name: 'City Reading Hub – Central',
      address: 'Hazratganj, Lucknow, UP 226001',
      phone: '9811223344',
    },
  });

  const owner2 = await prisma.user.create({
    data: {
      tenantId: tenant2.id,
      name: 'Vikas Malhotra',
      email: 'owner@cityreadinghub.com',
      password: passwordHash,
      role: 'OWNER',
      phone: '9811000001',
    },
  });
  const staff2 = await prisma.user.create({
    data: {
      tenantId: tenant2.id,
      name: 'Karan Saxena',
      email: 'staff@cityreadinghub.com',
      password: staffHash,
      role: 'STAFF',
      phone: '9811000002',
    },
  });

  await prisma.userBranchAccess.createMany({
    data: [
      { userId: owner2.id, branchId: crhCentral.id },
      { userId: staff2.id, branchId: crhCentral.id },
    ],
  });

  // Plans for Tenant 2
  const planDefs2 = [
    { name: 'Day Pass', durationDays: 1, price: 70, includesSeat: true, includesLocker: false },
    { name: 'Monthly Standard', durationDays: 30, price: 550, includesSeat: true, includesLocker: false },
    { name: 'Quarterly Pro', durationDays: 90, price: 1500, includesSeat: true, includesLocker: true },
  ];
  const plans2: any[] = [];
  for (const pd of planDefs2) {
    const plan = await prisma.membershipPlan.create({
      data: { ...pd, tenantId: tenant2.id, branchId: crhCentral.id },
    });
    plans2.push(plan);
  }

  // Seats for Tenant 2 (30 seats)
  const seats2: any[] = [];
  for (const floor of ['A', 'B']) {
    for (let i = 1; i <= 15; i++) {
      const seat = await prisma.seat.create({
        data: {
          tenantId: tenant2.id,
          seatNumber: `${floor}${i.toString().padStart(2, '0')}`,
          floor,
          branchId: crhCentral.id,
          status: 'AVAILABLE',
        },
      });
      seats2.push(seat);
    }
  }

  // Lockers for Tenant 2 (10 lockers)
  const lockers2: any[] = [];
  for (let i = 1; i <= 10; i++) {
    const locker = await prisma.locker.create({
      data: {
        tenantId: tenant2.id,
        lockerNumber: `L${i.toString().padStart(2, '0')}`,
        branchId: crhCentral.id,
        status: 'AVAILABLE',
      },
    });
    lockers2.push(locker);
  }

  // Members for Tenant 2 (12 members)
  const crhMemberNames = [
    'Aakash Gupta', 'Bhavna Sen', 'Chirag Sethi', 'Devanshi Rai',
    'Eshaan Kapoor', 'Falguni Joshi', 'Gaurav Bhatia', 'Himani Rawat',
    'Inderjit Gill', 'Juhi Chawla', 'Kunal Deshmukh', 'Lavanya Roy'
  ];

  for (let i = 0; i < crhMemberNames.length; i++) {
    const name = crhMemberNames[i];
    const member = await prisma.member.create({
      data: {
        tenantId: tenant2.id,
        memberCode: randomMemberCode('CRH'),
        name,
        phone: randomPhone(),
        email: `${name.toLowerCase().replace(' ', '.')}@gmail.com`,
        dob: randomDate(new Date(1996, 0, 1), new Date(2004, 11, 31)),
        address: `Flat ${101 + i}, Hazratganj, Lucknow`,
        branchId: crhCentral.id,
        isActive: i < 10,
      },
    });

    const plan = plans2[i % plans2.length];
    const subStatus = i < 9 ? 'ACTIVE' : 'EXPIRED';
    const startDate = new Date(now);
    startDate.setDate(startDate.getDate() - 10);
    const endDate = new Date(startDate);
    endDate.setDate(endDate.getDate() + plan.durationDays);

    const seat = i < 9 ? seats2[i] : null;
    const locker = i < 5 ? lockers2[i] : null;

    const subscription = await prisma.subscription.create({
      data: {
        tenantId: tenant2.id,
        memberId: member.id,
        planId: plan.id,
        startDate,
        endDate,
        status: subStatus,
        assignedSeatId: seat?.id || null,
        assignedLockerId: locker?.id || null,
      },
    });

    if (seat && subStatus === 'ACTIVE') {
      await prisma.seat.update({ where: { id: seat.id }, data: { status: 'OCCUPIED' } });
      await prisma.seatAssignment.create({
        data: { seatId: seat.id, subscriptionId: subscription.id },
      });
    }
    if (locker && subStatus === 'ACTIVE') {
      await prisma.locker.update({ where: { id: locker.id }, data: { status: 'OCCUPIED' } });
      await prisma.lockerAssignment.create({
        data: { lockerId: locker.id, subscriptionId: subscription.id },
      });
    }

    await prisma.payment.create({
      data: {
        tenantId: tenant2.id,
        memberId: member.id,
        amount: plan.price,
        method: 'UPI',
        status: 'PAID',
        paidAt: startDate,
        txnRef: `CRH_TXN_${Date.now()}_${i}`,
      },
    });

    if (subStatus === 'ACTIVE') {
      for (let d = 0; d < 10; d++) {
        if (Math.random() < 0.8) {
          const checkInDate = new Date(now);
          checkInDate.setDate(checkInDate.getDate() - d);
          checkInDate.setHours(8 + Math.floor(Math.random() * 3), 15, 0, 0);

          const checkOutDate = new Date(checkInDate);
          checkOutDate.setHours(checkInDate.getHours() + 6);

          await prisma.attendance.create({
            data: {
              tenantId: tenant2.id,
              memberId: member.id,
              branchId: crhCentral.id,
              checkIn: checkInDate,
              checkOut: d > 0 ? checkOutDate : null,
              method: 'QR',
            },
          });
        }
      }
    }
  }

  // Settings for Tenant 2
  await prisma.settings.create({
    data: {
      tenantId: tenant2.id,
      branchId: crhCentral.id,
      key: 'library_timing',
      value: JSON.stringify({ open: '07:00', close: '22:00' }),
    },
  });

  console.log('\n🎉 Multi-Tenant Seed complete! Database ready for LibraryOS.\n');
  console.log('Platform Super Admin:');
  console.log('  Email:    superadmin@libraryos.com / SuperAdmin@1234\n');
  console.log('Tenant 1 (Chintamani Library - CML):');
  console.log('  Owner:    owner@chintamani.com     / Admin@1234');
  console.log('  Admin:    admin.khl@chintamani.com / Admin@1234');
  console.log('  Staff:    staff.khl@chintamani.com / Staff@1234\n');
  console.log('Tenant 2 (City Reading Hub - CRH):');
  console.log('  Owner:    owner@cityreadinghub.com / Admin@1234');
  console.log('  Staff:    staff@cityreadinghub.com / Staff@1234\n');
}

main()
  .catch((e) => {
    console.error('❌ Seed failed:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
