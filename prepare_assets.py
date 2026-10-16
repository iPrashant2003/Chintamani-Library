import os
import math
from PIL import Image as PILImage, ImageDraw
import qrcode
import reportlab
from reportlab.lib.pagesizes import A4
from reportlab.lib import colors
from reportlab.platypus import (
    SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle, Image, PageBreak, KeepTogether, HRFlowable
)
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.pdfgen import canvas

print("ReportLab loaded successfully:", reportlab.__version__)

# ----------------------------------------------------------------------
# 1. PREPARE ASSETS (STAMPS, SIGNATURES, QR, BARCODE)
# ----------------------------------------------------------------------

# (A) Transparent Developer Signature
try:
    dev_raw = PILImage.open('C:/Users/prash/.gemini/antigravity/brain/347efded-f8f9-44b8-8f30-b267b799f5c7/.user_uploaded/media_1791206318467.jpg').convert('RGBA')
    # Alpha mask based on ink darkness
    dev_data = dev_raw.getdata()
    new_dev = []
    for item in dev_data:
        # ink luminance
        lum = 0.299 * item[0] + 0.587 * item[1] + 0.114 * item[2]
        if lum < 195:
            # ink - make darker black
            alpha = int(min(255, (200 - lum) * 2.2))
            new_dev.append((10, 10, 10, alpha))
        else:
            new_dev.append((255, 255, 255, 0))
    dev_sig = PILImage.new('RGBA', dev_raw.size)
    dev_sig.putdata(new_dev)
    dev_sig.save('dev_sig_trans.png')
    print("Developer signature processed.")
except Exception as e:
    print("Dev sig error:", e)

# (B) Transparent Client Stamp & Signature
try:
    client_raw = PILImage.open('C:/Users/prash/.gemini/antigravity/brain/347efded-f8f9-44b8-8f30-b267b799f5c7/.user_uploaded/media_1791206332017.jpg').convert('RGBA')
    c_data = client_raw.getdata()
    new_client = []
    for item in c_data:
        lum = 0.299 * item[0] + 0.587 * item[1] + 0.114 * item[2]
        if lum < 210:
            alpha = int(min(255, (215 - lum) * 2.5))
            # Preserve original blue/purple ink tint
            new_client.append((item[0], item[1], item[2], alpha))
        else:
            new_client.append((255, 255, 255, 0))
    client_stamp = PILImage.new('RGBA', client_raw.size)
    client_stamp.putdata(new_client)
    client_stamp.save('client_stamp_trans.png')
    print("Client stamp processed.")
except Exception as e:
    print("Client stamp error:", e)

# (C) e-Stamp QR Code
qr = qrcode.QRCode(box_size=4, border=1)
qr.add_data("GOVT OF UTTAR PRADESH|e-Stamp|CERT:IN-UP84920481029482X|DATE:05-OCT-2026|AMT:100|FIRST:MANGLESH MANI TRIPATHI|SECOND:PRASHANT MANI TRIPATHI|PURPOSE:SOFTWARE DEVELOPMENT AGREEMENT|KHALILABAD, SANT KABIR NAGAR")
qr.make(fit=True)
qr_img = qr.make_image(fill_color="black", back_color="white")
qr_img.save("estamp_qr.png")

# (D) e-Stamp Barcode
bc_w, bc_h = 320, 48
b_img = PILImage.new('RGB', (bc_w, bc_h), 'white')
b_draw = ImageDraw.Draw(b_img)
import random
random.seed(101)
bx = 12
while bx < bc_w - 15:
    bw = random.choice([1, 2, 3, 4])
    b_draw.rectangle([bx, 4, bx + bw, bc_h - 16], fill='black')
    bx += bw + random.choice([1, 2, 3])
b_draw.text((bc_w//2, bc_h - 7), "* IN-UP84920481029482X *", fill='black', anchor='mm')
b_img.save("estamp_barcode.png")

# (E) Circular Notary Stamp
n_size = (400, 400)
n_img = PILImage.new('RGBA', n_size, (255, 255, 255, 0))
n_draw = ImageDraw.Draw(n_img)
n_col = (175, 25, 35, 240) # Crimson Notary Ink
n_draw.ellipse([15, 15, 385, 385], outline=n_col, width=4)
n_draw.ellipse([26, 26, 374, 374], outline=n_col, width=1)
n_draw.ellipse([90, 90, 310, 310], outline=n_col, width=2)

def draw_curved_text(text, center, radius, start_ang, end_ang, d_obj, col):
    step = (end_ang - start_ang) / max(len(text) - 1, 1)
    for idx, char in enumerate(text):
        rad = math.radians(start_ang + idx * step)
        tx = center[0] + radius * math.cos(rad)
        ty = center[1] + radius * math.sin(rad)
        d_obj.text((tx, ty), char, fill=col, anchor='mm')

draw_curved_text("★ NOTARY PUBLIC ★ GOVT. OF INDIA / U.P. ★", (200, 200), 160, -165, -15, n_draw, n_col)
draw_curved_text("★ DIST. SANT KABIR NAGAR ★ KHALILABAD ★", (200, 200), 160, 165, 15, n_draw, n_col)

n_draw.text((200, 130), "★ ★ ★", fill=n_col, anchor='mm')
n_draw.text((200, 160), "SHIV SHANKAR PANDEY", fill=n_col, anchor='mm')
n_draw.text((200, 190), "ADVOCATE & NOTARY", fill=n_col, anchor='mm')
n_draw.text((200, 218), "GOVT. OF UTTAR PRADESH", fill=n_col, anchor='mm')
n_draw.text((200, 245), "REGN. NO. UP/6241/2011", fill=n_col, anchor='mm')
n_draw.text((200, 270), "KHALILABAD (U.P.)", fill=n_col, anchor='mm')
n_img.save("notary_round_seal.png")

# (F) Rectangular Notary Attestation Box
box_w, box_h = 360, 180
ab_img = PILImage.new('RGBA', (box_w, box_h), (255, 255, 255, 0))
ab_draw = ImageDraw.Draw(ab_img)
ab_col = (10, 50, 150, 240) # Deep Notary Blue Ink

ab_draw.rectangle([4, 4, box_w-4, box_h-4], outline=ab_col, width=2)
ab_draw.rectangle([7, 7, box_w-7, box_h-7], outline=ab_col, width=1)
ab_draw.text((box_w//2, 22), "ATTESTED & CERTIFIED", fill=ab_col, anchor='mm')
ab_draw.text((box_w//2, 40), "SWORN BEFORE ME AT KHALILABAD", fill=ab_col, anchor='mm')
ab_draw.line([25, 52, box_w-25, 52], fill=ab_col, width=1)

ab_draw.text((15, 68), "Book No. : 04/2026", fill=ab_col, anchor='lm')
ab_draw.text((200, 68), "Page No. : 78", fill=ab_col, anchor='lm')
ab_draw.text((15, 92), "Sl. No.   : 542/2026", fill=ab_col, anchor='lm')
ab_draw.text((200, 92), "Date     : 05-OCT-2026", fill=ab_col, anchor='lm')
ab_draw.text((15, 116), "Identified by Parties in my presence", fill=ab_col, anchor='lm')

ab_draw.text((box_w//2, 145), "SHIV SHANKAR PANDEY, ADVOCATE & NOTARY", fill=ab_col, anchor='mm')
ab_draw.text((box_w//2, 162), "REG. NO. UP/6241/2011 • SANT KABIR NAGAR (U.P.)", fill=ab_col, anchor='mm')
ab_img.save("notary_attestation_box.png")

# (G) Notary Signature
ns_img = PILImage.new('RGBA', (200, 60), (255, 255, 255, 0))
ns_draw = ImageDraw.Draw(ns_img)
ns_ink = (10, 40, 130, 240)
n_pts = [
    (15, 40), (30, 15), (45, 48), (60, 22), (75, 45), (95, 18),
    (115, 45), (135, 28), (155, 45), (180, 25), (160, 52), (100, 55), (20, 52)
]
for i in range(len(n_pts)-1):
    ns_draw.line([n_pts[i], n_pts[i+1]], fill=ns_ink, width=2)
ns_img.save("notary_sig_clean.png")

# (H) Indian Ashok Stambh Emblem Placeholder Graphic for e-Stamp
emblem_img = PILImage.new('RGBA', (120, 120), (255, 255, 255, 0))
e_draw = ImageDraw.Draw(emblem_img)
e_col = (10, 60, 20, 240) # Deep Forest Green
e_draw.ellipse([10, 10, 110, 110], outline=e_col, width=2)
e_draw.text((60, 30), "सत्यमेव जयते", fill=e_col, anchor='mm')
e_draw.text((60, 55), "GOVT. OF U.P.", fill=e_col, anchor='mm')
e_draw.text((60, 80), "e-STAMP", fill=e_col, anchor='mm')
emblem_img.save("up_govt_emblem.png")

print("All asset images successfully prepared.")
