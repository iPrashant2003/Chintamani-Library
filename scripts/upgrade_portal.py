"""
Portal Luxury Upgrade Script
Replaces CSS, header, and landing section with premium designs.
Keeps all functionality and other views intact.
"""
import re

INPUT = 'docs/index.html'
OUTPUT = 'docs/index.html'

with open(INPUT, 'r', encoding='utf-8') as f:
    content = f.read()

# ══════════════════════════════════════════════════════════════════════════════
# 1. REPLACE STYLE BLOCK
# ══════════════════════════════════════════════════════════════════════════════

NEW_CSS = '''  <style>
    :root {
      --bg-base: #080B12;
      --gold-primary: #C9A84C;
      --gold-light: #E8C97A;
      --gold-border: rgba(201, 168, 76, 0.18);
      --glass-surface: rgba(13, 17, 26, 0.82);
    }

    * { box-sizing: border-box; }

    body {
      background-color: #06080E;
      color: #E6E9F0;
      font-family: \'Inter\', sans-serif;
      -webkit-tap-highlight-color: transparent;
      overflow-x: hidden;
      min-height: 100vh;
      position: relative;
    }

    /* ── Ambient Branch Background ── */
    .portal-ambient-bg {
      position: fixed; inset: 0; z-index: -10;
      overflow: hidden; pointer-events: none;
      background-color: #05070B;
    }
    .bg-photo-layer {
      position: absolute; inset: 0;
      background-size: cover; background-position: center 30%;
      opacity: 0; transform: scale(1.05);
      transition: opacity 0.8s cubic-bezier(0.4,0,0.2,1), transform 1.4s cubic-bezier(0.16,1,0.3,1);
      filter: saturate(1.15) brightness(0.9);
      will-change: opacity, transform;
    }
    .bg-photo-layer.active { opacity: 0.34; transform: scale(1.0); }
    .bg-overlay-gradient {
      position: absolute; inset: 0;
      background: linear-gradient(180deg,
        rgba(5,7,12,0.88) 0%, rgba(7,10,18,0.70) 40%,
        rgba(6,8,14,0.85) 75%, rgba(4,5,8,0.98) 100%);
    }
    .bg-overlay-vignette {
      position: absolute; inset: 0;
      background: radial-gradient(circle at 50% 30%, transparent 20%, rgba(4,5,8,0.85) 90%);
    }

    /* ── Typography ── */
    .brand-title { font-family: \'Cormorant Garamond\', serif; letter-spacing: 0.04em; }
    .gold-gradient-text {
      background: linear-gradient(135deg, #F9EED2 0%, #E8C97A 50%, #B5882A 100%);
      -webkit-background-clip: text; -webkit-text-fill-color: transparent;
    }

    /* ── Glass Card ── */
    .glass-card {
      background: rgba(10,14,22,0.78);
      backdrop-filter: blur(24px); -webkit-backdrop-filter: blur(24px);
      border: 1px solid rgba(201,168,76,0.14); border-radius: 20px;
      box-shadow:
        0 12px 40px rgba(0,0,0,0.55), 0 2px 8px rgba(0,0,0,0.35),
        inset 0 1px 0 rgba(255,255,255,0.06), inset 0 -1px 0 rgba(0,0,0,0.3);
      transition: transform 0.25s cubic-bezier(0.16,1,0.3,1), box-shadow 0.25s cubic-bezier(0.16,1,0.3,1);
      position: relative; overflow: hidden;
    }
    .glass-card::before {
      content: \'\'; position: absolute; top: 0; left: 0; right: 0; height: 1px;
      background: linear-gradient(90deg, transparent 0%, rgba(201,168,76,0.3) 50%, transparent 100%);
      pointer-events: none;
    }
    .glass-card:hover {
      transform: translateY(-2px);
      box-shadow:
        0 18px 50px rgba(0,0,0,0.65), 0 4px 12px rgba(0,0,0,0.45),
        inset 0 1px 0 rgba(201,168,76,0.12);
    }

    .service-accent-bar { position: absolute; top: 0; left: 0; right: 0; height: 2px; opacity: 0.8; }

    /* ── Gold Button ── */
    .btn-gold {
      background: linear-gradient(135deg, #FFF3D4 0%, #E8C97A 35%, #C9A84C 65%, #A07830 100%);
      color: #07090E; font-weight: 800; letter-spacing: 0.02em;
      box-shadow: 0 4px 20px rgba(201,168,76,0.35), 0 1px 4px rgba(0,0,0,0.5),
        inset 0 1px 1px rgba(255,255,255,0.5), inset 0 -1px 1px rgba(0,0,0,0.2);
      transition: all 0.2s cubic-bezier(0.16,1,0.3,1);
      border: none; outline: none; cursor: pointer; position: relative; overflow: hidden;
    }
    .btn-gold::after {
      content: \'\'; position: absolute; inset: 0;
      background: linear-gradient(135deg, rgba(255,255,255,0.15) 0%, transparent 60%);
      pointer-events: none;
    }
    .btn-gold:hover {
      filter: brightness(1.07); transform: translateY(-1px);
      box-shadow: 0 6px 28px rgba(201,168,76,0.5), 0 2px 8px rgba(0,0,0,0.5),
        inset 0 1px 1px rgba(255,255,255,0.55);
    }
    .btn-gold:active { transform: scale(0.97) translateY(0); filter: brightness(0.94); }

    /* ── Inputs ── */
    .glass-field {
      background: rgba(6,9,16,0.9); border: 1px solid rgba(255,255,255,0.08);
      color: #FFFFFF; border-radius: 12px; padding: 12px 14px; width: 100%;
      outline: none; font-size: 13.5px;
      transition: border-color 0.22s, box-shadow 0.22s, background 0.22s;
      box-shadow: inset 0 2px 6px rgba(0,0,0,0.35);
    }
    .glass-field:focus {
      border-color: rgba(201,168,76,0.55);
      box-shadow: 0 0 0 3px rgba(201,168,76,0.12), inset 0 2px 6px rgba(0,0,0,0.35);
      background: rgba(8,12,22,0.95);
    }
    .glass-field::placeholder { color: rgba(148,163,184,0.45); }
    select.glass-field option { background: #0D111A; color: #E6E9F0; }

    /* ── Branch Switcher ── */
    .global-branch-toggle-wrap { display: flex; justify-content: center; width: 100%; }
    .global-branch-toggle {
      position: relative; display: grid; grid-template-columns: 1fr 1fr;
      align-items: center; background: rgba(6,9,16,0.92);
      backdrop-filter: blur(28px); -webkit-backdrop-filter: blur(28px);
      border: 1.5px solid rgba(201,168,76,0.28); border-radius: 9999px; padding: 4px;
      box-shadow: 0 8px 32px rgba(0,0,0,0.7), 0 2px 8px rgba(0,0,0,0.5),
        inset 0 1px 1px rgba(255,255,255,0.06), inset 0 -1px 1px rgba(0,0,0,0.4);
      width: 100%; user-select: none;
    }
    .branch-slider-thumb {
      position: absolute; top: 4px; bottom: 4px; left: 4px; width: calc(50% - 4px);
      border-radius: 9999px;
      background: linear-gradient(135deg, #FFF3D4 0%, #F0D780 25%, #D4A84C 60%, #A07830 100%);
      box-shadow: 0 4px 20px rgba(201,168,76,0.55), 0 2px 6px rgba(0,0,0,0.7),
        inset 0 1px 2px rgba(255,255,255,0.7), inset 0 -1px 2px rgba(0,0,0,0.3);
      transition: transform 0.4s cubic-bezier(0.175,0.885,0.32,1.275);
      z-index: 1; pointer-events: none;
    }
    .branch-slider-thumb::after {
      content: \'\'; position: absolute; inset: 0; border-radius: 9999px;
      background: linear-gradient(135deg, rgba(255,255,255,0.2) 0%, transparent 60%);
      pointer-events: none;
    }
    .branch-slider-thumb.right { transform: translateX(100%); }
    .branch-toggle-btn {
      position: relative; z-index: 2; display: flex; align-items: center;
      justify-content: center; gap: 6px; padding: 9px 10px;
      font-size: 11px; font-weight: 700; letter-spacing: 0.04em;
      border: none; background: transparent; color: rgba(148,163,184,0.75);
      cursor: pointer; border-radius: 9999px; transition: all 0.28s ease;
      white-space: nowrap; outline: none;
    }
    .branch-toggle-btn:hover { color: rgba(241,245,249,0.9); }
    .branch-toggle-btn.active { color: #06090E !important; font-weight: 900; }
    .branch-toggle-btn.active i { color: #07090E !important; }
    .branch-btn-name { text-transform: uppercase; font-size: 11px; font-weight: 800; letter-spacing: 0.06em; }

    /* ── Seat Matrix ── */
    .single-hall-box { background: rgba(6,9,16,0.75); border: 1px solid rgba(255,255,255,0.08); border-radius: 16px; padding: 14px; }
    .hall-header { display: flex; align-items: center; justify-content: space-between; padding-bottom: 8px; border-bottom: 1px solid rgba(255,255,255,0.08); margin-bottom: 10px; }
    .hall-title { font-size: 11.5px; font-weight: 800; color: #E8C97A; letter-spacing: 0.04em; text-transform: uppercase; }
    .hall-capacity-tag { font-size: 10px; font-weight: 700; color: #34D399; background: rgba(16,185,129,0.12); border: 1px solid rgba(16,185,129,0.3); padding: 2px 8px; border-radius: 9999px; }
    .hall-promenade-bar { font-size: 9px; font-weight: 800; letter-spacing: 0.08em; text-transform: uppercase; color: rgba(255,255,255,0.3); text-align: center; padding: 4px 0; background: rgba(255,255,255,0.02); border-radius: 6px; margin-bottom: 10px; border: 1px dashed rgba(255,255,255,0.06); }
    .seat-desk-grid { display: grid; grid-template-columns: repeat(6, minmax(0, 1fr)); gap: 7px; }
    @media (max-width: 440px) { .seat-desk-grid { grid-template-columns: repeat(5, minmax(0, 1fr)); gap: 5.5px; } }
    @media (max-width: 360px) { .seat-desk-grid { grid-template-columns: repeat(4, minmax(0, 1fr)); gap: 5px; } }
    .seat-desk-card { position: relative; border-radius: 10px; padding: 6px 3px; display: flex; flex-direction: column; align-items: center; justify-content: center; min-height: 48px; cursor: pointer; user-select: none; transition: all 0.18s cubic-bezier(0.16,1,0.3,1); }
    .seat-desk-avail { background: rgba(16,185,129,0.08); border: 1px solid rgba(16,185,129,0.32); color: #34D399; }
    .seat-desk-avail:hover { background: rgba(16,185,129,0.22); border-color: rgba(16,185,129,0.6); transform: translateY(-2px); box-shadow: 0 4px 14px rgba(16,185,129,0.25); }
    .seat-desk-occupied { background: rgba(255,255,255,0.02); border: 1px solid rgba(255,255,255,0.05); color: rgba(255,255,255,0.2); cursor: not-allowed; pointer-events: none; }
    .seat-desk-selected { background: linear-gradient(135deg, #F9EED2 0%, #D6B65E 50%, #A98634 100%) !important; border: 1.5px solid #FFF5D0 !important; color: #080B12 !important; font-weight: 900 !important; box-shadow: 0 0 16px rgba(201,168,76,0.6), 0 4px 12px rgba(0,0,0,0.4) !important; transform: scale(1.06) translateY(-2px) !important; }
    .seat-desk-top-bar { width: 60%; height: 2px; border-radius: 2px; background: currentColor; opacity: 0.45; margin-bottom: 3px; }
    .seat-desk-number { font-size: 10.5px; font-weight: 800; letter-spacing: 0.02em; line-height: 1; }
    .seat-desk-status-dot { width: 4px; height: 4px; border-radius: 50%; background: currentColor; margin-top: 3px; }

    /* ── Page View Transition ── */
    .page-view { animation: viewIn 0.28s cubic-bezier(0.16,1,0.3,1) forwards; }
    @keyframes viewIn { from { opacity: 0; transform: translateY(8px); } to { opacity: 1; transform: translateY(0); } }

    /* ── Service Cards ── */
    .svc-card {
      transition: transform 0.28s cubic-bezier(0.16,1,0.3,1), box-shadow 0.28s cubic-bezier(0.16,1,0.3,1), border-color 0.28s ease;
    }
    .svc-card:hover {
      transform: translateY(-5px) scale(1.015);
      box-shadow: 0 20px 50px rgba(0,0,0,0.75), 0 8px 20px rgba(0,0,0,0.5), inset 0 1px 0 rgba(255,255,255,0.08) !important;
    }
    .svc-card:active { transform: scale(0.97) translateY(1px); box-shadow: 0 4px 16px rgba(0,0,0,0.6) !important; }
    .card-img-wrap { position: absolute; inset: 0; z-index: 0; overflow: hidden; border-radius: inherit; }
    .card-img { width: 100%; height: 100%; object-fit: cover; opacity: 0.14; transition: opacity 0.4s ease, transform 0.5s cubic-bezier(0.16,1,0.3,1); }
    .svc-card:hover .card-img { opacity: 0.22; transform: scale(1.08); }
    .card-img-vignette { position: absolute; inset: 0; z-index: 1; border-radius: inherit; }

    /* ── Logo Glow ── */
    .logo-glow-wrap { position: relative; display: flex; align-items: center; justify-content: center; }
    .logo-glow-ring {
      position: absolute; inset: -4px; border-radius: 50%;
      background: radial-gradient(circle, rgba(201,168,76,0.35) 0%, transparent 70%);
      animation: logoGlowPulse 3s ease-in-out infinite; pointer-events: none;
    }
    @keyframes logoGlowPulse {
      0%, 100% { opacity: 0.5; transform: scale(1); }
      50% { opacity: 1; transform: scale(1.12); }
    }
    .logo-glow-wrap:hover .logo-glow-ring { animation-duration: 1.2s; }

    /* ── Float Slow ── */
    .float-slow { animation: floatSlow 4.5s ease-in-out infinite alternate; }
    @keyframes floatSlow { 0% { transform: translateY(0px); } 100% { transform: translateY(-4px); } }

    /* ── Live Dot ── */
    .live-dot {
      display: inline-block; width: 6px; height: 6px; border-radius: 50%;
      background: #34D399; box-shadow: 0 0 6px rgba(52,211,153,0.8);
      animation: livePulse 2s ease-in-out infinite;
    }
    @keyframes livePulse {
      0%, 100% { box-shadow: 0 0 6px rgba(52,211,153,0.8); transform: scale(1); }
      50% { box-shadow: 0 0 12px rgba(52,211,153,0.6); transform: scale(1.2); }
    }

    /* ── Back Button ── */
    .btn-back {
      display: flex; align-items: center; gap: 6px; padding: 7px 12px;
      border-radius: 10px; background: rgba(255,255,255,0.05);
      border: 1px solid rgba(255,255,255,0.08);
      color: rgba(148,163,184,0.8); font-size: 11.5px; font-weight: 600;
      cursor: pointer; transition: all 0.2s ease;
    }
    .btn-back:hover { background: rgba(255,255,255,0.09); color: #F1F5F9; border-color: rgba(255,255,255,0.14); }

    /* ── Responsive ── */
    @media (min-width: 640px) { .glass-card { border-radius: 22px; } }
  </style>'''

# Find and replace style block
style_start = content.find('  <style>')
style_end = content.find('  </style>') + len('  </style>')

if style_start == -1 or style_end == -1:
    print("ERROR: Could not find style block!")
else:
    content = content[:style_start] + NEW_CSS + content[style_end:]
    print(f"Style block replaced: {style_start} -> {style_end}")

# ══════════════════════════════════════════════════════════════════════════════
# 2. REPLACE HEADER SECTION
# ══════════════════════════════════════════════════════════════════════════════

NEW_HEADER = '''  <!-- ================================================================= -->
  <!-- 1. STICKY TOP HEADER WITH ONE GLOBAL BRANCH SWITCHER               -->
  <!-- ================================================================= -->
  <header class="sticky top-0 z-40" style="background: rgba(6,8,16,0.92); backdrop-filter: blur(28px); -webkit-backdrop-filter: blur(28px); border-bottom: 1px solid rgba(201,168,76,0.16); box-shadow: 0 4px 24px rgba(0,0,0,0.55);">
    <div class="max-w-lg mx-auto px-4 py-2.5 space-y-2">

      <!-- Top Brand Row -->
      <div class="flex items-center justify-between cursor-pointer" onclick="showView(\'landing\')">
        <div class="flex items-center space-x-2.5">
          <!-- Logo with Glow -->
          <div class="logo-glow-wrap shrink-0">
            <div class="logo-glow-ring"></div>
            <div class="relative w-8 h-8 rounded-xl overflow-hidden bg-black/50 p-1 border border-gold-500/30 flex items-center justify-center shadow-lg" style="box-shadow: 0 4px 14px rgba(0,0,0,0.6), 0 0 12px rgba(201,168,76,0.25);">
              <img src="images/chintamani_logo.png" alt="Chintamani Logo" class="w-full h-full object-contain" onerror="this.src=\'images/logo.png\'">
            </div>
          </div>

          <div class="flex flex-col">
            <span class="brand-title text-base font-bold tracking-wide text-white leading-tight">Chintamani Library</span>
            <span class="text-[9.5px] font-semibold tracking-widest text-gold-400/80 uppercase">Universal Member Portal</span>
          </div>
        </div>

        <div class="flex items-center space-x-1.5 px-2.5 py-1 rounded-full text-[10px] font-bold" style="background: rgba(16,185,129,0.08); border: 1px solid rgba(16,185,129,0.22); color: #34D399;">
          <span class="live-dot"></span>
          <span>Verified 24×7</span>
        </div>
      </div>

      <!-- ONE GLOBAL LUXURY 3D SLIDING BRANCH SWITCHER -->
      <div class="global-branch-toggle-wrap">
        <div class="global-branch-toggle" role="tablist" aria-label="Select Active Global Branch">
          <div id="branch-slider-thumb" class="branch-slider-thumb"></div>
          <button id="global-btn-mehdawal" onclick="switchPortalBranch(\'mehdawal\')" class="branch-toggle-btn active" role="tab" aria-selected="true" title="Switch to Mehdawal Branch">
            <i data-lucide="building-2" class="w-3.5 h-3.5 shrink-0"></i>
            <span class="branch-btn-name">Mehdawal</span>
          </button>
          <button id="global-btn-khalilabad" onclick="switchPortalBranch(\'khalilabad\')" class="branch-toggle-btn" role="tab" aria-selected="false" title="Switch to Khalilabad Branch">
            <i data-lucide="landmark" class="w-3.5 h-3.5 shrink-0"></i>
            <span class="branch-btn-name">Khalilabad</span>
          </button>
        </div>
      </div>

    </div>
  </header>'''

# Find and replace header
header_start_marker = '  <!-- ================================================================= -->\n  <!-- 1. STICKY TOP HEADER'
header_end_marker = '  </header>'

h_start = content.find(header_start_marker)
h_end = content.find(header_end_marker)
if h_start != -1 and h_end != -1:
    h_end += len(header_end_marker)
    content = content[:h_start] + NEW_HEADER + content[h_end:]
    print(f"Header replaced: {h_start} -> {h_end}")
else:
    print(f"WARNING: Header not found. h_start={h_start}, h_end={h_end}")

# ══════════════════════════════════════════════════════════════════════════════
# 3. REPLACE LANDING VIEW (HERO BADGE + SERVICE CARDS + FOOTER)
# ══════════════════════════════════════════════════════════════════════════════

NEW_LANDING = '''    <!-- ─────────────────────────────────────────────────────────────── -->
    <!-- VIEW: LANDING / HOME (Premium Identity Badge + 6 Service Cards) -->
    <!-- ─────────────────────────────────────────────────────────────── -->
    <section id="view-landing" class="page-view space-y-3.5">

      <!-- ── Premium Identity Hero Badge ── -->
      <div class="relative overflow-hidden rounded-[22px] p-4 flex items-center justify-between gap-3"
        style="background: rgba(9,13,22,0.85); border: 1px solid rgba(201,168,76,0.22); backdrop-filter: blur(32px); -webkit-backdrop-filter: blur(32px); box-shadow: 0 16px 48px rgba(0,0,0,0.65), 0 4px 16px rgba(0,0,0,0.45), inset 0 1px 0 rgba(255,255,255,0.07);">

        <!-- Gold Hairline Top -->
        <div class="absolute top-0 left-0 right-0 h-[1.5px]" style="background: linear-gradient(90deg, transparent 0%, rgba(232,201,122,0.8) 30%, rgba(249,238,210,1) 50%, rgba(232,201,122,0.8) 70%, transparent 100%);"></div>

        <!-- Subtle ambient inner glow -->
        <div class="absolute top-0 left-0 right-0 h-28 pointer-events-none" style="background: radial-gradient(ellipse at 30% 0%, rgba(201,168,76,0.06) 0%, transparent 70%);"></div>

        <div class="flex items-center space-x-3.5 min-w-0 relative z-10">
          <!-- Floating Glow Logo -->
          <div class="logo-glow-wrap shrink-0 float-slow">
            <div class="logo-glow-ring"></div>
            <div class="relative w-12 h-12 rounded-2xl p-1.5 flex items-center justify-center"
              style="background: rgba(0,0,0,0.65); border: 1px solid rgba(201,168,76,0.4); box-shadow: 0 8px 24px rgba(0,0,0,0.6), 0 0 20px rgba(201,168,76,0.2);">
              <img src="images/chintamani_logo.png" alt="Chintamani Logo" class="w-full h-full object-contain" onerror="this.src=\'images/logo.png\'">
            </div>
          </div>

          <!-- Typography: Luxury Serif Brand -->
          <div class="min-w-0">
            <div class="flex items-center space-x-1.5 mb-1">
              <span class="live-dot"></span>
              <span id="hero-branch-badge-text" class="text-[10.5px] font-bold tracking-wider uppercase text-gold-300">Mehdawal Campus</span>
            </div>
            <h2 class="brand-title text-xl sm:text-2xl font-extrabold tracking-wide leading-none gold-gradient-text" style="text-shadow: 0 2px 12px rgba(201,168,76,0.25);">
              CHINTAMANI LIBRARY
            </h2>
            <p class="text-[11px] font-medium tracking-wide mt-1.5 truncate" style="color: rgba(166,180,201,0.85);">
              Self-Service Student &amp; Member Access
            </p>
          </div>
        </div>

        <!-- Right: Status Badge -->
        <div class="shrink-0 flex items-center relative z-10">
          <div class="px-2.5 py-1.5 rounded-full text-[10px] font-extrabold flex items-center space-x-1.5 shadow-sm"
            style="background: rgba(16,185,129,0.1); border: 1px solid rgba(16,185,129,0.28); color: #6EE7B7;">
            <i data-lucide="shield-check" class="w-3.5 h-3.5 text-emerald-400"></i>
            <span>Open 24×7</span>
          </div>
        </div>
      </div>

      <!-- ── Services Section Label ── -->
      <div class="flex items-center gap-3 px-1">
        <div class="h-px flex-1" style="background: linear-gradient(90deg, transparent, rgba(201,168,76,0.2));"></div>
        <span class="text-[10px] font-bold uppercase tracking-widest" style="color: rgba(201,168,76,0.6);">Services</span>
        <div class="h-px flex-1" style="background: linear-gradient(90deg, rgba(201,168,76,0.2), transparent);"></div>
      </div>

      <!-- ── 6 Premium Glassmorphism Service Cards ── -->
      <div class="grid grid-cols-2 sm:grid-cols-3 gap-3">

        <!-- 1. Attendance (Emerald) -->
        <div onclick="showView(\'attendance\')" class="svc-card cursor-pointer relative overflow-hidden rounded-[20px] min-h-[156px] flex flex-col justify-between p-4"
          style="background:rgba(10,15,25,0.78);border:1px solid rgba(16,185,129,0.28);box-shadow:0 10px 32px rgba(0,0,0,0.55),inset 0 1px 0 rgba(255,255,255,0.06);backdrop-filter:blur(22px);-webkit-backdrop-filter:blur(22px);">
          <div class="service-accent-bar bg-[#10B981]"></div>
          <div class="card-img-wrap">
            <img src="images/attendance_biometric.jpg" alt="" class="card-img">
            <div class="card-img-vignette" style="background:radial-gradient(circle at 50% 20%, transparent 10%, rgba(6,10,18,0.94) 80%),linear-gradient(to bottom,rgba(6,10,18,0.15),rgba(6,10,18,0.98));"></div>
          </div>
          <!-- Top Row: Icon + Badge -->
          <div class="relative z-10 flex items-start justify-between">
            <div class="w-10 h-10 rounded-xl flex items-center justify-center" style="background:rgba(16,185,129,0.14);border:1px solid rgba(16,185,129,0.32);box-shadow:0 0 18px rgba(16,185,129,0.12);">
              <i data-lucide="user-check" class="w-5 h-5" style="color:#34D399;"></i>
            </div>
            <span class="px-1.5 py-0.5 rounded-full text-[8.5px] font-extrabold tracking-wider" style="background:rgba(16,185,129,0.18);color:#6EE7B7;border:1px solid rgba(16,185,129,0.4);">LIVE</span>
          </div>
          <!-- Bottom Text -->
          <div class="relative z-10 pt-3">
            <h4 class="text-[13.5px] font-bold text-white leading-tight mb-1">Attendance</h4>
            <p class="text-[10.5px] leading-snug" style="color:rgba(226,232,240,0.62);">Daily check-in &amp; out</p>
          </div>
        </div>

        <!-- 2. Fee Payment (Gold) -->
        <div onclick="showView(\'payment\')" class="svc-card cursor-pointer relative overflow-hidden rounded-[20px] min-h-[156px] flex flex-col justify-between p-4"
          style="background:rgba(10,15,25,0.78);border:1px solid rgba(201,168,76,0.28);box-shadow:0 10px 32px rgba(0,0,0,0.55),inset 0 1px 0 rgba(255,255,255,0.06);backdrop-filter:blur(22px);-webkit-backdrop-filter:blur(22px);">
          <div class="service-accent-bar bg-[#C9A84C]"></div>
          <div class="card-img-wrap">
            <img src="images/gold_coins.jpg" alt="" class="card-img">
            <div class="card-img-vignette" style="background:radial-gradient(circle at 50% 20%, transparent 10%, rgba(6,10,18,0.94) 80%),linear-gradient(to bottom,rgba(6,10,18,0.15),rgba(6,10,18,0.98));"></div>
          </div>
          <div class="relative z-10 flex items-start justify-between">
            <div class="w-10 h-10 rounded-xl flex items-center justify-center" style="background:rgba(201,168,76,0.14);border:1px solid rgba(201,168,76,0.32);box-shadow:0 0 18px rgba(201,168,76,0.12);">
              <i data-lucide="credit-card" class="w-5 h-5" style="color:#E8C97A;"></i>
            </div>
            <span class="px-1.5 py-0.5 rounded-full text-[8.5px] font-extrabold tracking-wider" style="background:rgba(201,168,76,0.16);color:#FDE68A;border:1px solid rgba(201,168,76,0.38);">UPI</span>
          </div>
          <div class="relative z-10 pt-3">
            <h4 class="text-[13.5px] font-bold text-white leading-tight mb-1">Fee Payment</h4>
            <p class="text-[10.5px] leading-snug" style="color:rgba(226,232,240,0.62);">Transfer &amp; verification</p>
          </div>
        </div>

        <!-- 3. New Admission (Amber) -->
        <div onclick="showView(\'register\')" class="svc-card cursor-pointer relative overflow-hidden rounded-[20px] min-h-[156px] flex flex-col justify-between p-4"
          style="background:rgba(10,15,25,0.78);border:1px solid rgba(234,170,80,0.28);box-shadow:0 10px 32px rgba(0,0,0,0.55),inset 0 1px 0 rgba(255,255,255,0.06);backdrop-filter:blur(22px);-webkit-backdrop-filter:blur(22px);">
          <div class="service-accent-bar bg-[#EAA050]"></div>
          <div class="card-img-wrap">
            <img src="images/luxury_reception.jpg" alt="" class="card-img">
            <div class="card-img-vignette" style="background:radial-gradient(circle at 50% 20%, transparent 10%, rgba(6,10,18,0.94) 80%),linear-gradient(to bottom,rgba(6,10,18,0.15),rgba(6,10,18,0.98));"></div>
          </div>
          <div class="relative z-10 flex items-start justify-between">
            <div class="w-10 h-10 rounded-xl flex items-center justify-center" style="background:rgba(234,170,80,0.14);border:1px solid rgba(234,170,80,0.32);box-shadow:0 0 18px rgba(234,170,80,0.12);">
              <i data-lucide="user-plus" class="w-5 h-5" style="color:#FBBF24;"></i>
            </div>
            <span class="px-1.5 py-0.5 rounded-full text-[8.5px] font-extrabold tracking-wider" style="background:rgba(234,170,80,0.16);color:#FBBF24;border:1px solid rgba(234,170,80,0.38);">NEW</span>
          </div>
          <div class="relative z-10 pt-3">
            <h4 class="text-[13.5px] font-bold text-white leading-tight mb-1">New Admission</h4>
            <p class="text-[10.5px] leading-snug" style="color:rgba(226,232,240,0.62);">Seat &amp; plan registration</p>
          </div>
        </div>

        <!-- 4. Feedback (Rose) -->
        <div onclick="showView(\'feedback\')" class="svc-card cursor-pointer relative overflow-hidden rounded-[20px] min-h-[156px] flex flex-col justify-between p-4"
          style="background:rgba(10,15,25,0.78);border:1px solid rgba(232,121,160,0.28);box-shadow:0 10px 32px rgba(0,0,0,0.55),inset 0 1px 0 rgba(255,255,255,0.06);backdrop-filter:blur(22px);-webkit-backdrop-filter:blur(22px);">
          <div class="service-accent-bar bg-[#E879A0]"></div>
          <div class="card-img-wrap">
            <img src="images/luxury_books.jpg" alt="" class="card-img">
            <div class="card-img-vignette" style="background:radial-gradient(circle at 50% 20%, transparent 10%, rgba(6,10,18,0.94) 80%),linear-gradient(to bottom,rgba(6,10,18,0.15),rgba(6,10,18,0.98));"></div>
          </div>
          <div class="relative z-10 flex items-start justify-between">
            <div class="w-10 h-10 rounded-xl flex items-center justify-center" style="background:rgba(232,121,160,0.14);border:1px solid rgba(232,121,160,0.32);box-shadow:0 0 18px rgba(232,121,160,0.12);">
              <i data-lucide="star" class="w-5 h-5" style="color:#F472B6;"></i>
            </div>
          </div>
          <div class="relative z-10 pt-3">
            <h4 class="text-[13.5px] font-bold text-white leading-tight mb-1">Feedback</h4>
            <p class="text-[10.5px] leading-snug" style="color:rgba(226,232,240,0.62);">Rate your experience</p>
          </div>
        </div>

        <!-- 5. Support (Ruby Red) -->
        <div onclick="showView(\'complaint\')" class="svc-card cursor-pointer relative overflow-hidden rounded-[20px] min-h-[156px] flex flex-col justify-between p-4"
          style="background:rgba(10,15,25,0.78);border:1px solid rgba(239,68,68,0.28);box-shadow:0 10px 32px rgba(0,0,0,0.55),inset 0 1px 0 rgba(255,255,255,0.06);backdrop-filter:blur(22px);-webkit-backdrop-filter:blur(22px);">
          <div class="service-accent-bar bg-[#EF4444]"></div>
          <div class="card-img-wrap">
            <img src="images/luxury_wifi.jpg" alt="" class="card-img">
            <div class="card-img-vignette" style="background:radial-gradient(circle at 50% 20%, transparent 10%, rgba(6,10,18,0.94) 80%),linear-gradient(to bottom,rgba(6,10,18,0.15),rgba(6,10,18,0.98));"></div>
          </div>
          <div class="relative z-10 flex items-start justify-between">
            <div class="w-10 h-10 rounded-xl flex items-center justify-center" style="background:rgba(239,68,68,0.14);border:1px solid rgba(239,68,68,0.32);box-shadow:0 0 18px rgba(239,68,68,0.12);">
              <i data-lucide="alert-triangle" class="w-5 h-5" style="color:#FCA5A5;"></i>
            </div>
          </div>
          <div class="relative z-10 pt-3">
            <h4 class="text-[13.5px] font-bold text-white leading-tight mb-1">Support Help</h4>
            <p class="text-[10.5px] leading-snug" style="color:rgba(226,232,240,0.62);">Facility complaints</p>
          </div>
        </div>

        <!-- 6. Director Helpline (Royal Blue) -->
        <div onclick="showView(\'contact\')" class="svc-card cursor-pointer relative overflow-hidden rounded-[20px] min-h-[156px] flex flex-col justify-between p-4"
          style="background:rgba(10,15,25,0.78);border:1px solid rgba(59,130,246,0.28);box-shadow:0 10px 32px rgba(0,0,0,0.55),inset 0 1px 0 rgba(255,255,255,0.06);backdrop-filter:blur(22px);-webkit-backdrop-filter:blur(22px);">
          <div class="service-accent-bar bg-[#3B82F6]"></div>
          <div class="card-img-wrap">
            <img src="images/luxury_building.jpg" alt="" class="card-img">
            <div class="card-img-vignette" style="background:radial-gradient(circle at 50% 20%, transparent 10%, rgba(6,10,18,0.94) 80%),linear-gradient(to bottom,rgba(6,10,18,0.15),rgba(6,10,18,0.98));"></div>
          </div>
          <div class="relative z-10 flex items-start justify-between">
            <div class="w-10 h-10 rounded-xl flex items-center justify-center" style="background:rgba(59,130,246,0.14);border:1px solid rgba(59,130,246,0.32);box-shadow:0 0 18px rgba(59,130,246,0.12);">
              <i data-lucide="phone-call" class="w-5 h-5" style="color:#93C5FD;"></i>
            </div>
          </div>
          <div class="relative z-10 pt-3">
            <h4 class="text-[13.5px] font-bold text-white leading-tight mb-1">Director Desk</h4>
            <p class="text-[10.5px] leading-snug" style="color:rgba(226,232,240,0.62);">Helpline &amp; inquiries</p>
          </div>
        </div>

      </div>

      <!-- ── Director & Location Footer Card ── -->
      <div class="glass-card p-3.5 text-xs text-gray-300 space-y-1.5">
        <div class="flex items-center justify-between">
          <span class="font-bold text-gold-400">Director: Manglesh Mani Tripathi</span>
          <a href="tel:+919415919277" class="text-emerald-400 font-semibold flex items-center space-x-1">
            <i data-lucide="phone-call" class="w-3.5 h-3.5"></i>
            <span>9415919277</span>
          </a>
        </div>
        <div class="pt-1.5 flex items-center justify-between text-[11px] text-gray-400" style="border-top: 1px solid rgba(255,255,255,0.05);">
          <span>📍 Khalilabad &amp; Mehdawal, Sant Kabir Nagar</span>
          <span class="text-gold-400 font-medium">Open 24x7</span>
        </div>
      </div>

      <!-- ── Luxury Developer Signature Footer ── -->
      <div class="py-3 text-center space-y-0.5 select-none" style="border-top: 1px solid rgba(255,255,255,0.04);">
        <p class="text-xs font-medium tracking-wide">
          <span class="text-gray-400">Developed by </span>
          <span class="font-extrabold gold-gradient-text tracking-wider">Prashant Mani Tripathi</span>
        </p>
        <p class="text-[9px] text-gray-500 uppercase tracking-widest font-semibold">Chintamani Library Digital Ecosystem</p>
      </div>

    </section>'''

# Find and replace landing view
landing_start = content.find('    <!-- ─────────────────────────────────────────────────────────────── -->\n    <!-- VIEW: LANDING / HOME')
landing_end = content.find('    </section>\n\n    <!-- ─────────────────────────────────────────────────────────────── -->\n    <!-- VIEW: REGISTRATION')
if landing_start != -1 and landing_end != -1:
    landing_end += len('    </section>')
    content = content[:landing_start] + NEW_LANDING + content[landing_end:]
    print(f"Landing view replaced: {landing_start}")
else:
    print(f"WARNING: Landing view not found. start={landing_start}, end={landing_end}")

# ══════════════════════════════════════════════════════════════════════════════
# 4. SAVE
# ══════════════════════════════════════════════════════════════════════════════
with open(OUTPUT, 'w', encoding='utf-8', newline='') as f:
    f.write(content)

print(f"Done! Final file size: {len(content)} chars")
