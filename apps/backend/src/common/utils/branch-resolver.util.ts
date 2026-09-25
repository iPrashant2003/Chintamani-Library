import { PrismaService } from '../../prisma/prisma.service';

export interface ResolvedBranchInfo {
  id: string;
  name: string;
  isMehdawal: boolean;
  slug: 'mehdawal' | 'khalilabad';
  allIds: string[];
}

export async function resolveBranchInfo(
  prisma: PrismaService,
  branchIdOrSlug?: string,
  tenantId?: string,
): Promise<ResolvedBranchInfo | null> {
  if (!branchIdOrSlug) return null;

  const raw = branchIdOrSlug.trim().toLowerCase();
  const isMehdawal = raw.includes('mehda') || raw === 'mhd';
  const isKhalilabad = raw.includes('khalil') || raw === 'khl';

  let branch: any = null;

  if (isMehdawal) {
    branch = await prisma.branch.findFirst({
      where: {
        AND: [
          tenantId ? { tenantId } : {},
          {
            OR: [
              { name: { contains: 'Mehdawal', mode: 'insensitive' } },
              { address: { contains: 'Mehdawal', mode: 'insensitive' } },
            ],
          },
        ],
      },
      include: { tenant: true },
    });
  } else if (isKhalilabad) {
    branch = await prisma.branch.findFirst({
      where: {
        AND: [
          tenantId ? { tenantId } : {},
          {
            OR: [
              { name: { contains: 'Khalilabad', mode: 'insensitive' } },
              { address: { contains: 'Khalilabad', mode: 'insensitive' } },
            ],
          },
        ],
      },
      include: { tenant: true },
    });
  } else {
    // Try exact ID (UUID)
    branch = await prisma.branch.findFirst({
      where: {
        AND: [
          tenantId ? { tenantId } : {},
          { id: branchIdOrSlug },
        ],
      },
      include: { tenant: true },
    });

    if (!branch) {
      branch = await prisma.branch.findFirst({
        where: {
          AND: [
            tenantId ? { tenantId } : {},
            { name: { contains: branchIdOrSlug, mode: 'insensitive' } },
          ],
        },
        include: { tenant: true },
      });
    }
  }

  if (!branch) return null;

  const branchIsMehdawal = branch.name?.toLowerCase().includes('mehda') ?? isMehdawal;
  const slug = branchIsMehdawal ? 'mehdawal' : 'khalilabad';

  return {
    id: branch.id,
    name: branch.name,
    isMehdawal: branchIsMehdawal,
    slug,
    allIds: [
      branch.id,
      slug,
      `chintamani-${slug}`,
      slug.toUpperCase(),
      `chintamani-${slug}`.toUpperCase(),
    ],
  };
}
