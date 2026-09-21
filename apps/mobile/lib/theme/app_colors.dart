import 'package:flutter/material.dart';

class AppColors {
  // Atul Residency Luxury Jewel Tones
  // 1. Imperial Gold (Branch cards, emblems, luxury highlights) - DEFAULT THEME
  static const Color goldPrimary = Color(0xFFD4AF37); // Classic Imperial Gold
  static const Color goldAccent = Color(0xFFF59E0B);  // Warm Amber Gold
  static const Color goldBright = Color(0xFFFFDF00);  // Brilliant Gold
  static const Color goldLight = Color(0xFFFEF3C7);   // Soft Champagne
  static const Color goldGlow = Color(0x50D4AF37);    // 30% Gold glow
  static const Color borderGold = Color(0x66D4AF37);  // 40% Gold border

  // PRIMARY BRAND BUTTON ACCENT — Atul Residency Teal (#14B8A6)
  static const Color tealPrimary   = Color(0xFF14B8A6); // Brand Teal
  static const Color tealDark      = Color(0xFF0D9488); // Deep Teal
  static const Color tealLight     = Color(0xFF99F6E4); // Soft Mint
  static const Color tealGlow      = Color(0x5014B8A6); // Teal glow
  static const Color borderTeal    = Color(0x6614B8A6); // Teal border

  // 2. Sapphire & Royal Blue (Finances, revenue, digital library)
  static const Color bluePrimary = Color(0xFF2563EB); // Royal Blue
  static const Color blueRoyal = Color(0xFF1D4ED8);   // Deep Sapphire
  static const Color blueAqua = Color(0xFF00D2FF);    // Electric Aqua Blue
  static const Color blueLight = Color(0xFFDBEAFE);   // Soft Ice Blue
  static const Color blueGlow = Color(0x502563EB);    // 30% Blue glow
  static const Color borderBlue = Color(0x662563EB);  // 40% Blue border

  // 3. Ruby Red (Alerts, expirations, dues, urgent notifications)
  static const Color redPrimary = Color(0xFFEF4444);  // Ruby Red
  static const Color redRuby = Color(0xFFDC2626);     // Deep Crimson
  static const Color redCrimson = Color(0xFFE11D48);  // Rose Crimson / Pinkish Red
  static const Color redLight = Color(0xFFFEE2E2);    // Soft Rose
  static const Color redGlow = Color(0x50EF4444);     // 30% Red glow
  static const Color borderRed = Color(0x66EF4444);   // 40% Red border

  // 4. Jade Emerald & Sea Green
  static const Color emeraldPrimary = Color(0xFF10B981); // Vibrant Emerald
  static const Color seaGreen = Color(0xFF00E5BC);       // Sea Green
  static const Color emeraldJade = Color(0xFF059669);    // Deep Jade
  static const Color emeraldGlow = Color(0x5010B981);    // 30% Emerald glow
  static const Color borderEmerald = Color(0x6610B981); // 40% Emerald border

  // 5. Amethyst Purple (Overview, Expirations & Finances cards)
  static const Color purplePrimary = Color(0xFF8B5CF6); // Amethyst Purple
  static const Color purpleDeep = Color(0xFF7C3AED);    // Deep Royal Violet
  static const Color purpleLight = Color(0xFFC084FC);   // Soft Lavender Purple
  static const Color purpleGlow = Color(0x508B5CF6);    // Purple glow
  static const Color borderPurple = Color(0x668B5CF6);  // Purple border

  // 6. Amber & Warm Bronze & Yellow
  static const Color amberPrimary = Color(0xFFF59E0B);
  static const Color accentYellow = Color(0xFFFACC15);
  static const Color bronze = Color(0xFFCD7F32);

  // Pure Deep Black Backgrounds (Atul Residency Style)
  static const Color bgDark = Color(0xFF000000);         // #000000 Pure Black
  static const Color bgDarkElevated = Color(0xFF0A0A0A); // #0A0A0A Slightly elevated black
  static const Color bgCard = Color(0xFF121212);         // #121212 Obsidian Card
  static const Color bgCardHover = Color(0xFF1A1A1A);    // Hover/press surface
  static const Color bgGlass = Color(0xE60D0D0D);        // 90% opaque obsidian glass
  static const Color bgGlassLight = Color(0x1AFFFFFF);   // 10% frosted overlay

  // Text Hierarchy
  static const Color textPrimary = Color(0xFFFFFFFF);   // Pure crisp white
  static const Color textSecondary = Color(0xFFCBD5E1); // Cool slate white
  static const Color textTertiary = Color(0xFF94A3B8);  // Slate muted
  static const Color textGold = Color(0xFFFDE68A);      // Gold text highlight
  static const Color textCyan = Color(0xFF67E8F9);      // Aqua text
  static const Color textGreen = Color(0xFF67E8F9);     // Backward compatibility alias
  static const Color textDisabled = Color(0xFF64748B);  // Disabled

  // Borders & Glows
  static const Color borderSubtle = Color(0x24FFFFFF);  // 14% subtle white border
  static const Color borderCyan = Color(0x4000C2D7);    // Aqua border
  static const Color borderNeon = Color(0x80D4AF37);    // Neon Gold active border

  // Primary brand aliases - Golden Default Theme
  static const Color primaryGreen = Color(0xFFD4AF37);  // Default primary: Golden
  static const Color primaryTeal = Color(0xFF14B8A6);   // Brand Teal (#14B8A6)
  static const Color primarySeaBlue = Color(0xFF00D2FF);
  static const Color primaryAqua = Color(0xFF00E5BC);
  static const Color primaryDark = Color(0xFF050505);
  static const Color primaryEmerald = Color(0xFF10B981);
  static const Color accentNeon = Color(0xFFFFDF00);    // Brilliant Gold glow
  static const Color accentCyan = Color(0xFF00D2FF);
  static const Color accentElectricBlue = Color(0xFF38BDF8);
  static const Color accentGold = Color(0xFFD4AF37);
  static const Color accentPurple = Color(0xFF8B5CF6);
  static const Color accentOrange = Color(0xFFF97316);
  static const Color accentRed = Color(0xFFEF4444);

  // Status Colors
  static const Color statusActive = Color(0xFF10B981);  // Emerald for active
  static const Color statusExpired = Color(0xFFEF4444); // Red
  static const Color statusPending = Color(0xFFF59E0B); // Amber Gold
  static const Color statusWarning = Color(0xFFF97316); // Orange
  static const Color statusInfo = Color(0xFF2563EB);    // Sapphire Blue

  // Backward compatibility aliases
  static const Color brandCoral = Color(0xFFD4AF37);
  static const Color brandCoralDark = Color(0xFFB45309);
  static const Color memberBlue = Color(0xFF2563EB);
  static const Color expiryRed = Color(0xFFEF4444);
  static const Color collectionGreen = Color(0xFF10B981);
  static const Color checkinRose = Color(0xFF00D2FF);
  static const Color dueOrange = Color(0xFFEF4444);
}
