import os
from reportlab.lib.pagesizes import A4
from reportlab.lib import colors
from reportlab.platypus import (
    SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle, Image, PageBreak, KeepTogether, HRFlowable
)
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.pdfgen import canvas

# ----------------------------------------------------------------------
# NUMBERED CANVAS (2-PASS TO GET TOTAL PAGES, BORDERS, HEADERS & FOOTERS)
# ----------------------------------------------------------------------
class NumberedCanvas(canvas.Canvas):
    def __init__(self, *args, **kwargs):
        super(NumberedCanvas, self).__init__(*args, **kwargs)
        self._saved_page_states = []

    def showPage(self):
        self._saved_page_states.append(dict(self.__dict__))
        self._startPage()

    def save(self):
        num_pages = len(self._saved_page_states)
        for state in self._saved_page_states:
            self.__dict__.update(state)
            self.draw_page_decorations(num_pages)
            super(NumberedCanvas, self).showPage()
        super(NumberedCanvas, self).save()

    def draw_page_decorations(self, page_count):
        self.saveState()
        page_w, page_h = A4

        # 1. Elegant Legal Double Border (Inner & Outer)
        # Outer thin border
        self.setStrokeColor(colors.HexColor('#1E5136')) # Official Judicial Green
        self.setLineWidth(1.0)
        self.rect(26, 26, page_w - 52, page_h - 52)
        
        # Inner hairline border
        self.setStrokeColor(colors.HexColor('#8B9E92'))
        self.setLineWidth(0.4)
        self.rect(29, 29, page_w - 58, page_h - 58)

        # 2. Running Header (Pages 2+)
        if self._pageNumber > 1:
            self.setFont("Helvetica-Bold", 7.2)
            self.setFillColor(colors.HexColor('#222222'))
            self.drawString(36, page_h - 42, "Master Software Development, IP & Ongoing Maintenance Agreement — Chinta Mani Library")
            self.drawRightString(page_w - 36, page_h - 42, "Deed Ref: CML/DEV/UP-SKN/2026/01")
            self.setStrokeColor(colors.HexColor('#CCCCCC'))
            self.setLineWidth(0.5)
            self.line(36, page_h - 45, page_w - 36, page_h - 45)

        # 3. Running Footer (All Pages)
        self.setStrokeColor(colors.HexColor('#CCCCCC'))
        self.setLineWidth(0.5)
        self.line(36, 44, page_w - 36, 44)

        self.setFont("Helvetica", 7.2)
        self.setFillColor(colors.HexColor('#555555'))
        # Left
        self.drawString(36, 32, "Govt. of Uttar Pradesh e-Stamp: IN-UP84920481029482X • Issued: 06-Oct-2026 12:36 AM")
        # Right (Page Number & Initials Box)
        self.drawRightString(page_w - 36, 32, f"Page {self._pageNumber} of {page_count}   |   Executant Initials: [ MMT ] _____   [ PMT ] _____")

        self.restoreState()


# ----------------------------------------------------------------------
# PDF GENERATOR FUNCTION
# ----------------------------------------------------------------------
def generate_agreement_pdf(output_filename="ChintaMani_Library_Master_Software_eAgreement_Signed.pdf"):
    # Target 540 width printable area (A4 is 595.28 x 841.89 pt)
    # Margins: 36 pt left & right, 52 pt top & bottom
    doc = SimpleDocTemplate(
        output_filename,
        pagesize=A4,
        leftMargin=36,
        rightMargin=36,
        topMargin=52,
        bottomMargin=52
    )

    styles = getSampleStyleSheet()

    # Custom Typography Styles
    style_normal = ParagraphStyle(
        'LegalNormal',
        parent=styles['Normal'],
        fontName='Helvetica',
        fontSize=8.3,
        leading=11.0,
        textColor=colors.HexColor('#1A1A1A'),
        alignment=4 # Justified
    )

    style_bold = ParagraphStyle(
        'LegalBold',
        parent=style_normal,
        fontName='Helvetica-Bold'
    )

    style_title = ParagraphStyle(
        'DocTitle',
        parent=styles['Heading1'],
        fontName='Helvetica-Bold',
        fontSize=12.0,
        leading=14.5,
        alignment=1, # Centered
        textColor=colors.HexColor('#0F2A1D'),
        spaceAfter=3
    )

    style_subtitle = ParagraphStyle(
        'DocSubTitle',
        parent=styles['Normal'],
        fontName='Helvetica-Oblique',
        fontSize=8.3,
        leading=11,
        alignment=1,
        textColor=colors.HexColor('#444444'),
        spaceAfter=8
    )

    style_heading = ParagraphStyle(
        'SectionHeading',
        parent=styles['Heading2'],
        fontName='Helvetica-Bold',
        fontSize=9.3,
        leading=12.3,
        textColor=colors.HexColor('#113824'),
        spaceBefore=6.5,
        spaceAfter=2.5,
        keepWithNext=True
    )

    style_clause = ParagraphStyle(
        'ClauseText',
        parent=style_normal,
        spaceBefore=1.5,
        spaceAfter=1.5
    )

    style_subclause = ParagraphStyle(
        'SubClauseText',
        parent=style_normal,
        leftIndent=16,
        spaceBefore=1.0,
        spaceAfter=1.0
    )

    story = []

    # ------------------------------------------------------------------
    # PAGE 1: OFFICIAL GOVERNMENT OF UTTAR PRADESH e-STAMP CERTIFICATE
    # ------------------------------------------------------------------
    
    # e-Stamp Table Data
    stamp_cert_table_data = [
        [
            Paragraph("<b>Certificate No.</b>", style_normal),
            Paragraph("<b>IN-UP84920481029482X</b>", style_bold),
            Paragraph("<b>Certificate Issued Date</b>", style_normal),
            Paragraph("<b>06-Oct-2026 12:36 AM</b>", style_bold)
        ],
        [
            Paragraph("<b>Account Reference</b>", style_normal),
            Paragraph("NEWIMPACC (SV)/ up1402804/ KHALILABAD/ UP-SKN", style_normal),
            Paragraph("<b>Unique Doc. Reference</b>", style_normal),
            Paragraph("SUBIN-UPUP140280439182740192837X", style_normal)
        ],
        [
            Paragraph("<b>Purchased by</b>", style_normal),
            Paragraph("<b>MANGLESH MANI TRIPATHI</b>", style_bold),
            Paragraph("<b>Sub-Registrar Office</b>", style_normal),
            Paragraph("Khalilabad, Sant Kabir Nagar", style_normal)
        ],
        [
            Paragraph("<b>Description of Document</b>", style_normal),
            Paragraph("Article 5 Agreement (General) / IT Software Development & Licensing", style_normal),
            Paragraph("<b>First Party</b>", style_normal),
            Paragraph("<b>MANGLESH MANI TRIPATHI</b>", style_bold)
        ],
        [
            Paragraph("<b>Property Description</b>", style_normal),
            Paragraph("MASTER SOFTWARE DEV, IP & MAINTENANCE AGREEMENT FOR CHINTA MANI LIBRARY", style_normal),
            Paragraph("<b>Second Party</b>", style_normal),
            Paragraph("<b>PRASHANT MANI TRIPATHI</b>", style_bold)
        ],
        [
            Paragraph("<b>Consideration Price</b>", style_normal),
            Paragraph("<b>Rs. 50,000/- (Rupees Fifty Thousand only)</b>", style_bold),
            Paragraph("<b>Stamp Duty Paid By</b>", style_normal),
            Paragraph("MANGLESH MANI TRIPATHI", style_normal)
        ],
        [
            Paragraph("<b>Stamp Duty Amount</b>", style_normal),
            Paragraph("<b>Rs. 100/- (Rupees One Hundred only)</b>", style_bold),
            Paragraph("<b>e-Stamp Status</b>", style_normal),
            Paragraph("<font color='#006622'><b>VERIFIED & ACTIVE (SHCIL)</b></font>", style_bold)
        ]
    ]

    t_cert = Table(stamp_cert_table_data, colWidths=[110, 155, 110, 145])
    t_cert.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,-1), colors.HexColor('#F8FAF9')),
        ('GRID', (0,0), (-1,-1), 0.5, colors.HexColor('#B2C9BC')),
        ('VALIGN', (0,0), (-1,-1), 'MIDDLE'),
        ('TOPPADDING', (0,0), (-1,-1), 2.5),
        ('BOTTOMPADDING', (0,0), (-1,-1), 2.5),
        ('LEFTPADDING', (0,0), (-1,-1), 4),
        ('RIGHTPADDING', (0,0), (-1,-1), 4),
    ]))

    # Top Header Table for e-Stamp
    # Center: Emblem + Text
    center_hdr_data = [
        [Image('up_govt_emblem.png', width=22, height=22)],
        [Paragraph("<font size=10.5 color='#0D3D22'><b>GOVERNMENT OF UTTAR PRADESH</b></font>", ParagraphStyle('Hdr1', parent=style_normal, alignment=1, leading=11))],
        [Paragraph("<font size=9.5 color='#A62B2B'><b>e-Stamp Certificate</b></font>", ParagraphStyle('Hdr2', parent=style_normal, alignment=1, leading=10))],
        [Paragraph("<font size=6.5 color='#555555'>Certificate Issued under Stock Holding Corporation of India Ltd. (SHCIL)</font>", ParagraphStyle('Hdr3', parent=style_normal, alignment=1, leading=8))]
    ]
    t_center_hdr = Table(center_hdr_data, colWidths=[240])
    t_center_hdr.setStyle(TableStyle([
        ('ALIGN', (0,0), (-1,-1), 'CENTER'),
        ('VALIGN', (0,0), (-1,-1), 'MIDDLE'),
        ('TOPPADDING', (0,0), (-1,-1), 0),
        ('BOTTOMPADDING', (0,0), (-1,-1), 1),
    ]))

    header_table_data = [
        [
            Image('estamp_barcode.png', width=155, height=28),
            t_center_hdr,
            Image('estamp_qr.png', width=48, height=48)
        ]
    ]
    t_hdr = Table(header_table_data, colWidths=[160, 245, 115])
    t_hdr.setStyle(TableStyle([
        ('VALIGN', (0,0), (-1,-1), 'MIDDLE'),
        ('ALIGN', (0,0), (-1,-1), 'CENTER'),
        ('BOTTOMPADDING', (0,0), (-1,-1), 2),
        ('TOPPADDING', (0,0), (-1,-1), 0),
    ]))

    # Statutory alert
    statutory_text = Paragraph(
        "<b>Statutory Alert:</b> 1. The authenticity of this Stamp Certificate should be verified at <b>'www.shcilestamp.com'</b> or using e-Stamp Mobile App of Stock Holding. Any discrepancy in the details on this Certificate renders it invalid. 2. The onus of checking legitimacy is on users. 3. In case of discrepancy please inform Competent Authority.",
        ParagraphStyle('Stat', parent=style_normal, fontSize=6.5, leading=8.5, textColor=colors.HexColor('#333333'), alignment=4)
    )

    perforate_text = Paragraph(
        "<font color='#888888'>----------------------------------------------- <b>Please write or type below this line</b> -----------------------------------------------</font>",
        ParagraphStyle('Perf', parent=style_normal, fontSize=7, alignment=1, spaceBefore=3, spaceAfter=6)
    )

    # Wrap the e-Stamp in a distinctive ornamental container table
    estamp_box = Table([
        [t_hdr],
        [Spacer(1, 2)],
        [t_cert],
        [Spacer(1, 2)],
        [statutory_text],
        [perforate_text]
    ], colWidths=[520])

    estamp_box.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,-1), colors.HexColor('#FCFDFB')),
        ('BOX', (0,0), (-1,-2), 1.2, colors.HexColor('#1E5136')),
        ('INNERGRID', (0,0), (-1,-2), 0.4, colors.HexColor('#DCE6E0')),
        ('TOPPADDING', (0,0), (-1,-1), 3),
        ('BOTTOMPADDING', (0,0), (-1,-1), 2),
        ('LEFTPADDING', (0,0), (-1,-1), 5),
        ('RIGHTPADDING', (0,0), (-1,-1), 5),
    ]))

    story.append(estamp_box)
    story.append(Spacer(1, 4))

    # AGREEMENT TITLE & PREAMBLE
    story.append(Paragraph("MASTER SOFTWARE DEVELOPMENT, INTELLECTUAL PROPERTY & ONGOING MAINTENANCE AGREEMENT", style_title))
    story.append(Paragraph("Executed under the Indian Contract Act, 1872 & Information Technology Act, 2000", style_subtitle))

    preamble_text = (
        "This Master Software Development, Intellectual Property & Ongoing Maintenance Agreement (the <b>\"Agreement\"</b>) "
        "is made and executed at Khalilabad, District Sant Kabir Nagar, Uttar Pradesh, India, on this <b>06th day of October, 2026</b> at <b>12:36 AM</b> "
        "(the <b>\"Effective Date\"</b>), by and between:<br/>"
        "<b>(1) MANGLESH MANI TRIPATHI</b>, acting in his capacity as Proprietor / Director of <b>\"CHINTA MANI LIBRARY\"</b>, "
        "operating its Khalilabad Branch (72 Seats) and Mehdawal Branch (65 Seats) at Sant Kabir Nagar, Uttar Pradesh, India, "
        "Phone: +91 9415919277 (hereinafter referred to as the <b>\"Client\"</b> or the <b>\"Owner\"</b>, which expression shall, unless "
        "repugnant to the context, include his legal heirs, successors, legal representatives and permitted assigns); <b>AND</b><br/>"
        "<b>(2) PRASHANT MANI TRIPATHI</b> (also known as Prashant Tripathi), an Independent Software Architect and Full-Stack Developer "
        "residing at District Sant Kabir Nagar, Uttar Pradesh, India "
        "(hereinafter referred to as the <b>\"Developer\"</b> or the <b>\"Consultant\"</b>, which expression shall, unless repugnant to the "
        "context, include his legal heirs, successors, legal representatives and permitted assigns).<br/>"
        "The Client and the Developer are individually referred to as a <b>\"Party\"</b> and collectively as the <b>\"Parties\"</b>."
    )
    story.append(Paragraph(preamble_text, style_clause))
    story.append(Spacer(1, 3))

    story.append(Paragraph("<b>RECITALS:</b>", style_bold))
    recitals = [
        "<b>A.</b> The Client owns and operates <b>Chinta Mani Library</b>, a multi-branch self-study library enterprise with operational branches at Khalilabad (72 Seats) and Mehdawal (65 Seats) in District Sant Kabir Nagar, Uttar Pradesh, and intends to expand to further branches.",
        "<b>B.</b> The Developer has independently engineered and developed a proprietary multi-branch library management software ecosystem comprising: (i) a cross-platform mobile application built with Flutter/Dart (Android build) featuring an in-app Over-the-Air (OTA) updater engine, 4D claymorphic UI, biometric and PIN authentication, and offline caching; (ii) a universal QR self-admission, student photo upload and attendance web portal built with HTML5 and Tailwind CSS, utilizing a Cloudinary zero-copy multi-part photo pipeline; (iii) a cloud backend and database architecture built with NestJS / Node.js, Neon PostgreSQL, Render.com microservices, and Cloudinary CDN; and (iv) a dual-branch isolation architecture providing strict data segregation between the Khalilabad and Mehdawal branches, with scalable support for future branches (together, the <b>\"Software\"</b>).",
        "<b>C.</b> The Client wishes to obtain, and the Developer is willing to grant, a licence to deploy, run and operate the Software for the Client's library business, and the Client wishes to engage the Developer to maintain, support and service the Software on an ongoing basis.",
        "<b>D.</b> The Parties wish to formally record, in a single binding instrument, their respective rights in the intellectual property, the Developer's non-negotiable right of attribution, the commercial terms, the allocation of responsibility for third-party cloud services, data privacy, and the terms of maintenance, confidentiality, termination, and dispute resolution."
    ]
    for r in recitals:
        story.append(Paragraph(r, style_clause))

    story.append(Spacer(1, 3))
    story.append(Paragraph("<b>NOW, THEREFORE</b>, in consideration of the mutual covenants contained herein, and for other good and valuable consideration, the receipt and sufficiency of which are hereby acknowledged, the Parties agree as follows:", style_clause))

    # ------------------------------------------------------------------
    # CLAUSES 1 TO 14
    # ------------------------------------------------------------------

    # Clause 1
    story.append(PageBreak())
    story.append(Paragraph("1. DEFINITIONS AND INTERPRETATION", style_heading))
    c1_defs = [
        ("Background Technology", "all software, code, algorithms, frameworks, modules, libraries, tools, designs, know-how, methodologies and architectural patterns that were conceived, authored or acquired by the Developer before the Effective Date or independently of this Agreement, including the Reusable Components, together with all improvements to them."),
        ("Client Data", "all data entered into, collected through or generated by the Software in the course of the Client's operations, including student and member records, admission details, student photographs, attendance logs, fee and payment records, seat allocations, branch operating records and financial information, but excluding the Software itself."),
        ("Client Materials", "the Client's name, the \"Chinta Mani Library\" trade name, official logos, branding, trademarks, taglines, marketing content and branch operating information."),
        ("Cloud Infrastructure", "the third-party hosting, database, and vendor services on which the Software runs, including Render.com, Neon PostgreSQL, Cloudinary CDN, the Google Play Console developer account, and SMS/WhatsApp API gateways."),
        ("Confidential Information", "all non-public information disclosed by or on behalf of a Party to the other, in any form, including library business financials, student credentials and personal data, API keys, access tokens, environment variables, Source Code, database schemas, architectural designs and trade secrets."),
        ("Custom Deliverables", "the specific configurations, screens, workflows, reports, integrations and branch-specific customisations developed specifically for the Client under this Agreement and listed in Schedule A, excluding all Background Technology."),
        ("Derivative Works", "any modification, adaptation, translation, enhancement, port, or other work based upon or derived from the Software or any part of it."),
        ("Reusable Components", "the reusable modules, architectural scaffolding, in-app OTA updater engine, authentication layer, branch-isolation framework, photo pipeline, background code libraries and utilities forming part of the Software."),
        ("Source Code", "the human-readable form of the Software, including comments, build scripts, configuration and technical documentation, in any programming language.")
    ]
    letters = ['(a)', '(b)', '(c)', '(d)', '(e)', '(f)', '(g)', '(h)', '(i)']
    for (term, definition), letter in zip(c1_defs, letters):
        story.append(Paragraph(f"<b>{letter} \"{term}\"</b> means {definition}", style_subclause))

    story.append(Paragraph("<b>1.2 Interpretation.</b> Headings are for convenience only. References to statutes include all statutory amendments, rules and re-enactments. The Schedules form an integral part of this Agreement. In case of conflict, the body of this Agreement prevails over the Schedules.", style_clause))

    # Clause 2
    story.append(Paragraph("2. SCOPE OF ENGAGEMENT & PROJECT DELIVERY TIMELINE", style_heading))
    story.append(Paragraph("<b>2.1 Software Provision.</b> The Developer shall make the Software available to the Client, configured and deployed for the Khalilabad and Mehdawal branches, and shall deliver the Custom Deliverables in accordance with Schedule A.", style_clause))
    story.append(Paragraph("<b>2.2 Independent Contractor.</b> The Developer shall perform the services as an independent software architect and contractor, using his own tools, development environments, and working hours. Nothing in this Agreement creates an employment, partnership, joint venture, or agency relationship between the Parties.", style_clause))
    story.append(Paragraph("<b>2.3 Project Delivery Schedule & Estimated Timeline.</b> The Parties agree that the total estimated timeframe for the end-to-end execution, branch configuration, cloud deployment, dual-branch verification, and operational handover of the Software is <b>Sixty (60) Days (Two Calendar Months)</b> from the Effective Date, subject to the milestone schedule set forth in Clause 5.3.", style_clause))

    # Clause 3
    story.append(Paragraph("3. INTELLECTUAL PROPERTY AND OWNERSHIP", style_heading))
    story.append(Paragraph("<b>3.1 Client Ownership.</b> As between the Parties, the Client is and shall remain the sole and exclusive owner of all Client Data and all Client Materials, including student databases, member records, library branding, logos, and branch operating information. Nothing in this Agreement transfers any ownership right in the Client Data or Client Materials to the Developer, save the limited right to process the Client Data to perform the services and the limited right to display Client Materials within the Software.", style_clause))
    story.append(Paragraph("<b>3.2 Developer Ownership.</b> The Developer is and shall remain the sole and exclusive author and owner of the copyright and all other intellectual property rights in the Software, the Source Code, the Background Technology, and the Reusable Components (including the OTA updater engine, architectural scaffolding, and background code libraries), and in all Derivative Works of them, whether created before or after the Effective Date. Any rights in the Software not expressly granted to the Client are strictly reserved to the Developer.", style_clause))
    story.append(Paragraph("<b>3.3 Licence to the Client.</b> The Developer hereby grants to the Client an exclusive (as regards the self-study library management field described in Clause 3.4), irrevocable (save as provided in Clause 11.3(c)), perpetual, royalty-free licence to deploy, run, operate, and use the Software and Custom Deliverables for all present and future branches of Chinta Mani Library, owned or operated by the Client or by an entity wholly controlled by him, without any additional licence fee, subject to the Client's continued compliance with Clauses 3.4, 4, and 5.", style_clause))
    story.append(Paragraph("<b>3.4 Restrictions; No Transfer to Third Parties.</b> The Client covenants that it shall not, without the prior written consent of the Developer: (a) assign, sub-license, sell, lease, transfer, or otherwise make available the Software, the licence granted under Clause 3.3, or any right under this Agreement to any third-party commercial library, coaching institute, library franchise or other business; (b) copy, decompile, reverse engineer, disassemble, or attempt to derive the Source Code, or create Derivative Works of the Software, except as expressly permitted by law; (c) remove, alter, obscure, or tamper with any proprietary notice or attribution (including that required by Clause 4); or (d) permit any person other than its authorised staff and students to administer the Software.", style_clause))
    story.append(Paragraph("<b>3.5 Source Code Custody and Continuity.</b> The Source Code remains in the Developer's exclusive custody. If the Developer, for a continuous period of ninety (90) days, is unable or unwilling to provide the maintenance services under Clause 7 although all fees are fully paid, the Developer shall, on the Client's written request, release to the Client (or an escrow engineer bound by confidentiality) a copy of the Source Code solely for the purpose of maintaining the Software for the Client's own branches, and not for any other use, sale, or disclosure.", style_clause))

    # Clause 4
    story.append(PageBreak())
    story.append(Paragraph("4. MANDATORY DEVELOPER ATTRIBUTION AND MORAL RIGHTS", style_heading))
    story.append(Paragraph("<b>4.1 Statutory Moral Rights.</b> The Parties expressly acknowledge the Developer's special rights as author under Section 57 of the Copyright Act, 1957, to claim authorship of the Software and to restrain or claim damages in respect of any distortion, mutilation, modification or other act in relation to it that would be prejudicial to his honour or professional reputation. The Client shall not do, or permit, any such act.", style_clause))
    story.append(Paragraph("<b>4.2 Attribution Covenant.</b> The Client covenants that the Developer's credit, in the form <b>\"Developed by Prashant Mani Tripathi\"</b> accompanied by the official gold sparkle emblem supplied with the Software (the <b>\"Attribution\"</b>), shall remain permanently visible, legible, and untampered in each of the following locations: (a) the Mobile Application Splash Screen; (b) the Main Navigation Drawer / Side Menu of the Mobile Application; (c) the Settings / \"About Software\" section of the Mobile Application; and (d) the footers of the Web Portal (including the QR self-admission, student photo upload, and attendance pages) and all accompanying documentation.", style_clause))
    story.append(Paragraph("<b>4.3 Material Breach.</b> Any removal of, or tampering with, the Attribution constitutes a material breach of this Agreement. Without prejudice to any other legal remedy, the Developer may: (i) call upon the Client to restore the Attribution within seven (7) days of written notice; (ii) failing which, suspend OTA updates and support, and/or terminate this Agreement for cause under Clause 11.3; and (iii) seek injunctive relief and damages in court, the Parties acknowledging that damages alone would be an inadequate remedy.", style_clause))

    # Clause 5 - COMMERCIAL TERMS (HIGHLIGHTED & COMPLETE)
    story.append(Paragraph("5. COMMERCIAL CONSIDERATION AND PAYMENT TERMS", style_heading))
    story.append(Paragraph("<b>5.1 Setup & Software Engineering Fee.</b> In full consideration of the custom development, configuration, dual-branch deployment, and exclusive perpetual licence of the Software, the Client shall pay to the Developer a fixed, one-time Software Engineering / Setup Fee of <b>Rs. 50,000/- (Rupees Fifty Thousand only)</b>, exclusive of applicable government taxes.", style_clause))
    story.append(Paragraph("<b>5.2 Maintenance and SLA Retainer.</b> In consideration of the ongoing technical support, cloud health monitoring, and maintenance services described in Clause 7, the Client shall pay to the Developer a recurring Maintenance and SLA Retainer of <b>Rs. 1,000/- (Rupees One Thousand only) per month</b>, payable in advance on or before the <b>5th (fifth) day</b> of each English calendar month.", style_clause))
    
    # Milestone Table
    m_data = [
        [
            Paragraph("<b>Milestone</b>", style_bold),
            Paragraph("<b>Trigger & Deliverable</b>", style_bold),
            Paragraph("<b>Timeline</b>", style_bold),
            Paragraph("<b>% of Fee</b>", style_bold),
            Paragraph("<b>Amount (Rs.)</b>", style_bold)
        ],
        [
            Paragraph("<b>M1</b>", style_normal),
            Paragraph("Project Inception, Architectural Blueprints & Contract Execution", style_normal),
            Paragraph("Upon Signing", style_normal),
            Paragraph("30 %", style_normal),
            Paragraph("<b>Rs. 15,000/-</b>", style_bold)
        ],
        [
            Paragraph("<b>M2</b>", style_normal),
            Paragraph("Dual-Branch Beta Deployment & Cloud API Configuration (Khalilabad & Mehdawal)", style_normal),
            Paragraph("Within 30 Days (Month 1)", style_normal),
            Paragraph("40 %", style_normal),
            Paragraph("<b>Rs. 20,000/-</b>", style_bold)
        ],
        [
            Paragraph("<b>M3</b>", style_normal),
            Paragraph("Final Acceptance, Production Go-Live, Staff Training & Handover", style_normal),
            Paragraph("Within 60 Days (Month 2)", style_normal),
            Paragraph("30 %", style_normal),
            Paragraph("<b>Rs. 15,000/-</b>", style_bold)
        ],
        [
            Paragraph("<b>TOTAL</b>", style_bold),
            Paragraph("<b>Complete 2-Month Turnkey Development & Deployment</b>", style_bold),
            Paragraph("<b>60 Days Total</b>", style_bold),
            Paragraph("<b>100 %</b>", style_bold),
            Paragraph("<b>Rs. 50,000/-</b>", style_bold)
        ]
    ]
    t_milestones = Table(m_data, colWidths=[55, 230, 95, 55, 85])
    t_milestones.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,0), colors.HexColor('#E8EFEA')),
        ('BACKGROUND', (0,-1), (-1,-1), colors.HexColor('#F2F5F3')),
        ('GRID', (0,0), (-1,-1), 0.5, colors.HexColor('#B2C9BC')),
        ('VALIGN', (0,0), (-1,-1), 'MIDDLE'),
        ('TOPPADDING', (0,0), (-1,-1), 3),
        ('BOTTOMPADDING', (0,0), (-1,-1), 3),
    ]))
    story.append(t_milestones)
    story.append(Spacer(1, 3))

    story.append(Paragraph("<b>5.4 Mode of Payment.</b> Payments shall be made by Direct Bank Transfer (NEFT/RTGS/IMPS), Unified Payments Interface (UPI), or Account Payee Cheque to the bank account designated in writing by the Developer. Time of payment is of the essence of this Agreement.", style_clause))
    story.append(Paragraph("<b>5.5 Default and Delay.</b> If any undisputed amount is not paid within seven (7) days of its due date: (a) interest shall accrue at the rate of one and a half percent (1.5%) per month on the outstanding amount, calculated daily; (b) the Developer may, after written notice of seven (7) days, suspend maintenance, OTA updates and support until full payment is cleared (without liability for resulting operational disruption); and (c) if default continues for thirty (30) days, the Developer may terminate this Agreement under Clause 11.3.", style_clause))
    story.append(Paragraph("<b>5.6 Future Branch Expansion.</b> If the Client establishes new branches (e.g., in Basti, Gorakhpur, etc.), onboarding each additional branch will incur a one-time setup fee of Rs. 15,000/- and an additional Rs. 500/- per month added to the monthly maintenance retainer.", style_clause))

    # Clause 6
    story.append(PageBreak())
    story.append(Paragraph("6. CLOUD INFRASTRUCTURE AND THIRD-PARTY EXPENSES", style_heading))
    story.append(Paragraph("<b>6.1 Direct Client Expenses.</b> The Client is solely responsible for, and shall pay directly and on time, all recurring third-party costs required to run the Software, including: (a) Render.com hosting fees; (b) Neon PostgreSQL cloud database usage charges; (c) Cloudinary media storage and CDN bandwidth fees; (d) Google Play Console developer account fees; (e) SMS and WhatsApp gateway charges; and (f) custom domains, SSL certificates, and third-party vendor charges (together, <b>\"Third-Party Charges\"</b>).", style_clause))
    story.append(Paragraph("<b>6.2 Account Ownership.</b> Accounts with Cloud Infrastructure vendors shall be registered in the Client's legal name, with the Developer being granted administrative API and deployment access needed to perform the services. The Developer shall keep all credentials secure.", style_clause))
    story.append(Paragraph("<b>6.3 No Developer Liability for Cloud Outages.</b> The Developer is not financially or operationally liable for any outage, data loss, degraded performance, or suspension of the Software caused by: (a) the Client's failure to renew or pay for any Cloud Infrastructure service; (b) the act or omission of a third-party cloud vendor; or (c) usage exceeding the subscription tier limits that the Client has paid for.", style_clause))

    # Clause 7
    story.append(Paragraph("7. SERVICE LEVEL AGREEMENT, BUG FIXES AND ENHANCEMENTS", style_heading))
    story.append(Paragraph("<b>7.1 Standard Maintenance Scope.</b> In return for the monthly retainer of Rs. 1,000/-, the Developer shall provide: (a) software bug identification and resolution; (b) build release and distribution of version updates through the OTA in-app updater engine; (c) security patches and dependency updates; and (d) automated scheduled database backup monitoring with periodic restoration verifications.", style_clause))
    story.append(Paragraph("<b>7.2 Support Hours & Response Targets.</b> Standard support hours are 10:00 a.m. to 7:00 p.m. IST, Monday to Saturday (excluding gazetted public holidays in Uttar Pradesh). Critical (P1) issues (software down at a branch) shall receive initial response within 4 hours and target resolution within 24 hours. Normal defects (P2/P3) shall be addressed in the next scheduled release.", style_clause))
    story.append(Paragraph("<b>7.3 Major Architectural Changes.</b> Any work beyond standard maintenance, including new business modules, complete UI overhauls, or multi-state franchising architectures, shall require a separate written Statement of Work (SOW) and additional compensation agreed upon before work commences.", style_clause))

    # Clause 8
    story.append(Paragraph("8. DATA PRIVACY AND COMPLIANCE (DPDP ACT 2023 & IT ACT 2000)", style_heading))
    story.append(Paragraph("<b>8.1 Legal Roles.</b> For the purposes of the Digital Personal Data Protection Act, 2023 (the <b>\"DPDP Act\"</b>), the Client is the <b>Data Fiduciary</b> in respect of all personal data of students and library members, and the Developer acts strictly as a <b>Data Processor</b> processing such data solely on the Client's behalf and documented instructions.", style_clause))
    story.append(Paragraph("<b>8.2 Client Compliance.</b> The Client is solely responsible for: (a) obtaining free, specific, informed and unambiguous consent from each student (and verifiable parental/guardian consent for students under eighteen years of age); (b) accuracy of data entered; (c) physical device security at its premises; and (d) legal notifications to the Data Protection Board of India in case of client-side breaches.", style_clause))
    story.append(Paragraph("<b>8.3 Developer Safeguards.</b> The Developer shall: (a) design and maintain reasonable technical safeguards, including zero-copy image streaming in the photo pipeline (eliminating local storage leaks), HTTPS encryption in transit, branch-level database query isolation, and role-based access control; and (b) notify the Client without undue delay within 72 hours upon becoming aware of any confirmed server-side data breach.", style_clause))
    story.append(Paragraph("<b>8.4 Branch Isolation.</b> The Software shall keep all records of the Khalilabad branch and Mehdawal branch logically segregated. There shall be zero accidental cross-branch data bleeding.", style_clause))

    # Clause 9
    story.append(Paragraph("9. CONFIDENTIALITY, NON-COMPETE AND NON-SOLICITATION", style_heading))
    story.append(Paragraph("<b>9.1 Reciprocal Confidentiality.</b> Each Party shall keep the other's Confidential Information in strict confidence. The Developer shall protect the Client's business financials, student records, and operational data. The Client shall protect the Developer's Source Code, API keys, database schemas, architectural designs, and technical secrets.", style_clause))
    story.append(Paragraph("<b>9.2 Non-Compete During Term.</b> During the subsistence of this Agreement: (a) the Client shall not engage any third party to build, or itself build, a competing library management system by utilizing the Developer's Confidential Information or Source Code; and (b) the Developer shall not license or deploy this bespoke Software to any other commercial study library within a geographical radius of ten (10) kilometres of the Client's active branches in Sant Kabir Nagar without the Client's prior written consent (reasonable protection under Section 27 of the Indian Contract Act, 1872).", style_clause))

    # Clause 10
    story.append(PageBreak())
    story.append(Paragraph("10. WARRANTIES, INDEMNITY AND LIMITATION OF LIABILITY", style_heading))
    story.append(Paragraph("<b>10.1 Warranties.</b> The Developer warrants that he has the full right to grant the licence in Clause 3.3, and that the Software as delivered materially conforms to Schedule A. The Client warrants that all branding and content provided to the Developer are lawfully owned.", style_clause))
    story.append(Paragraph("<b>10.2 Limitation of Liability.</b> To the maximum extent permitted by Indian law, neither Party is liable for indirect, special, or consequential damages. The Developer's total aggregate liability arising out of this Agreement shall not exceed the total fees actually received by him from the Client in the twelve (12) months preceding the claim.", style_clause))

    # Clause 11
    story.append(Paragraph("11. TERM, TERMINATION AND EXIT MANAGEMENT", style_heading))
    story.append(Paragraph("<b>11.1 Term.</b> This Agreement commences on the Effective Date and continues for an initial term of one (1) year, automatically renewing for successive one (1) year terms. The software licence under Clause 3.3 is perpetual, subject to Clauses 3.4 and 4.", style_clause))
    story.append(Paragraph("<b>11.2 Termination for Convenience.</b> Either Party may terminate the ongoing maintenance services for convenience by providing the other Party not less than sixty (60) days' prior written notice.", style_clause))
    story.append(Paragraph("<b>11.3 Exit Protocol.</b> Upon termination or expiry, and subject to full settlement of all pending invoices, the Developer shall within fifteen (15) days hand over to the Client complete database dumps of the Client Data in standard JSON/SQL format, along with administrative access credentials for the Client's cloud vendor accounts.", style_clause))

    # Clause 12, 13, 14
    story.append(Paragraph("12. FORCE MAJEURE", style_heading))
    story.append(Paragraph("Neither Party is liable for delay or failure caused by events beyond reasonable control, including natural disaster, epidemic, governmental act, major telecommunications/cloud vendor outages, or grid failures, provided prompt written notice is given.", style_clause))

    story.append(Paragraph("13. GOVERNING LAW AND DISPUTE RESOLUTION", style_heading))
    story.append(Paragraph("<b>13.1 Governing Law.</b> This Agreement shall be governed by, and construed exclusively in accordance with, the laws of the Republic of India.", style_clause))
    story.append(Paragraph("<b>13.2 Arbitration.</b> Any dispute arising out of or in connection with this Agreement shall be referred to and finally resolved by arbitration administered by a Sole Arbitrator appointed by mutual consent of the Parties under the Arbitration and Conciliation Act, 1996. The seat and venue of arbitration shall be <b>Khalilabad, District Sant Kabir Nagar, Uttar Pradesh</b>. Proceedings shall be conducted in English or Hindi, and the arbitrator's award shall be final and binding.", style_clause))
    story.append(Paragraph("<b>13.3 Court Jurisdiction.</b> Subject to Clause 13.2, the civil courts in District Sant Kabir Nagar, Uttar Pradesh shall have exclusive jurisdiction.", style_clause))

    story.append(Paragraph("14. GENERAL PROVISIONS & ELECTRONIC EXECUTION", style_heading))
    story.append(Paragraph("<b>14.1 Entire Agreement.</b> This Agreement, together with Schedule A, constitutes the entire understanding between the Parties and supersedes all prior oral or written discussions.", style_clause))
    story.append(Paragraph("<b>14.2 Electronic Signatures & Enforceability.</b> In accordance with Sections 3A, 10A, and 65B of the Information Technology Act, 2000, the Parties agree that digital or electronic signatures affixed to this Agreement constitute valid, binding, and legally enforceable execution, and that this document shall not be denied validity solely because it is in electronic format.", style_clause))
    story.append(Paragraph("<b>14.3 Stamp Duty.</b> The applicable stamp duty under the Indian Stamp Act, 1899, as applicable in Uttar Pradesh, has been paid via Government of Uttar Pradesh e-Stamp Certificate No. <b>IN-UP84920481029482X</b>, issued on <b>06-Oct-2026 at 12:36 AM</b>, affixed hereto.", style_clause))

    # ------------------------------------------------------------------
    # PAGE 6: EXECUTION & INDEPENDENT ATTESTING WITNESSES DEED (NO NOTARY)
    # ------------------------------------------------------------------
    story.append(PageBreak())
    story.append(Paragraph("EXECUTION & ATTESTATION CLAUSE", style_title))
    story.append(Paragraph("Executed in accordance with Section 10 of the Indian Contract Act, 1872 & Information Technology Act, 2000", style_subtitle))
    story.append(Spacer(1, 2))

    story.append(Paragraph(
        "<b>IN WITNESS WHEREOF</b>, the Parties hereto have set their hands, official seal, and electronic signatures to this Master Software Development, Intellectual Property & Ongoing Maintenance Agreement on this <b>06th day of October, 2026</b> at <b>12:36 AM</b> at Khalilabad, District Sant Kabir Nagar, Uttar Pradesh, having read, understood, and agreed to all covenants, terms, consideration, and schedules herein, in the presence of the independent attesting witnesses subscribed below:",
        style_clause
    ))
    story.append(Spacer(1, 6))

    # Party Signatures Table
    exec_table_data = [
        [
            Paragraph("<b>FIRST PARTY (THE CLIENT / OWNER):</b><br/><b>MANGLESH MANI TRIPATHI</b><br/>Proprietor / Director, Chinta Mani Library<br/>Khalilabad (72 Seats) & Mehdawal (65 Seats)<br/>Phone: +91 9415919277", style_normal),
            Paragraph("<b>SECOND PARTY (THE DEVELOPER / ARCHITECT):</b><br/><b>PRASHANT MANI TRIPATHI</b><br/>Independent Software Architect & Full-Stack Developer<br/>Sant Kabir Nagar, Uttar Pradesh<br/>Author, Lead System Architect & Engineer", style_normal)
        ],
        [
            Image('client_stamp_trans.png', width=145, height=97),
            Image('dev_sig_trans.png', width=170, height=86)
        ],
        [
            Paragraph("<b>Manglesh Mani Tripathi</b><br/>(Signed with Official Rubber Seal)<br/><font size=6.5 color='#555555'>Executed at Khalilabad • Date: 06/10/2026 • Time: 12:36 AM</font>", ParagraphStyle('CS', parent=style_normal, alignment=1)),
            Paragraph("<b>Prashant Mani Tripathi</b><br/>(Digitally & Hand-Signed)<br/><font size=6.5 color='#555555'>Executed at Khalilabad • Date: 06/10/2026 • Time: 12:36 AM</font>", ParagraphStyle('DS', parent=style_normal, alignment=1))
        ]
    ]

    t_exec = Table(exec_table_data, colWidths=[260, 260])
    t_exec.setStyle(TableStyle([
        ('BOX', (0,0), (-1,-1), 1.0, colors.HexColor('#2C4736')),
        ('INNERGRID', (0,0), (-1,-1), 0.5, colors.HexColor('#B2C9BC')),
        ('BACKGROUND', (0,0), (-1,-1), colors.HexColor('#FCFDFB')),
        ('VALIGN', (0,0), (-1,-1), 'MIDDLE'),
        ('ALIGN', (0,1), (-1,1), 'CENTER'),
        ('TOPPADDING', (0,0), (-1,-1), 4),
        ('BOTTOMPADDING', (0,0), (-1,-1), 4),
        ('LEFTPADDING', (0,0), (-1,-1), 8),
        ('RIGHTPADDING', (0,0), (-1,-1), 8),
    ]))
    story.append(t_exec)
    story.append(Spacer(1, 8))

    # ATTESTING WITNESSES SECTION (FULL-WIDTH 2 BALANCED COLUMNS)
    story.append(Paragraph("<b>INDEPENDENT ATTESTING WITNESSES:</b>", style_bold))
    story.append(Spacer(1, 2))

    witness_box_data = [
        [
            Paragraph("<b>1. FIRST ATTESTING WITNESS (KHALILABAD):</b>", ParagraphStyle('W1H', parent=style_bold, textColor=colors.HexColor('#113824'))),
            Paragraph("<b>2. SECOND ATTESTING WITNESS (MEHDAWAL):</b>", ParagraphStyle('W2H', parent=style_bold, textColor=colors.HexColor('#113824')))
        ],
        [
            Paragraph(
                "Signature: <i>Rakesh C. Verma</i><br/>"
                "Full Name: <b>Shri Rakesh Chandra Verma</b><br/>"
                "Father's Name: Late Sh. Ram Prasad Verma<br/>"
                "Occupation: Business / Civic Administration<br/>"
                "Residential Address: Bank Colony, Near Tehsil Road,<br/>"
                "Khalilabad, Dist. Sant Kabir Nagar, U.P. - 272175<br/>"
                "Aadhaar Number: <b>XXXX-XXXX-4819</b><br/>"
                "Attestation Date & Time: <b>06/10/2026 at 12:36 AM</b>",
                style_normal
            ),
            Paragraph(
                "Signature: <i>Alok Kr. Srivastava</i><br/>"
                "Full Name: <b>Shri Alok Kumar Srivastava</b><br/>"
                "Father's Name: Sh. Dinesh Chandra Srivastava<br/>"
                "Occupation: Academician / Educationist<br/>"
                "Residential Address: Main Market Road, Near Post Office,<br/>"
                "Mehdawal, Dist. Sant Kabir Nagar, U.P. - 272271<br/>"
                "Aadhaar Number: <b>XXXX-XXXX-7231</b><br/>"
                "Attestation Date & Time: <b>06/10/2026 at 12:36 AM</b>",
                style_normal
            )
        ]
    ]

    t_wit = Table(witness_box_data, colWidths=[260, 260])
    t_wit.setStyle(TableStyle([
        ('BOX', (0,0), (-1,-1), 1.0, colors.HexColor('#2C4736')),
        ('INNERGRID', (0,0), (-1,-1), 0.5, colors.HexColor('#B2C9BC')),
        ('VALIGN', (0,0), (-1,-1), 'TOP'),
        ('BACKGROUND', (0,0), (-1,0), colors.HexColor('#E8EFEA')),
        ('BACKGROUND', (0,1), (-1,1), colors.HexColor('#F8FAF9')),
        ('TOPPADDING', (0,0), (-1,-1), 5),
        ('BOTTOMPADDING', (0,0), (-1,-1), 5),
        ('LEFTPADDING', (0,0), (-1,-1), 8),
        ('RIGHTPADDING', (0,0), (-1,-1), 8),
    ]))
    story.append(t_wit)
    story.append(Spacer(1, 8))

    # ATTESTATION & IDENTIFICATION MEMORANDUM
    memo_text = Paragraph(
        "<b>ATTESTATION & IDENTIFICATION MEMORANDUM:</b><br/>"
        "We, the above-named attesting witnesses, do hereby solemnly declare, certify, and attest that the executants of this Deed, namely "
        "<b>Shri Manglesh Mani Tripathi</b> (First Party / Owner) and <b>Shri Prashant Mani Tripathi</b> (Second Party / Developer), are well known to us personally. "
        "They have executed, signed, and affixed their official seal to this Agreement in our simultaneous presence, sight, and hearing, having fully read and understood "
        "the commercial, technical, and intellectual property covenants herein contained. We have subscribed our names as attesting witnesses in their presence and at their express "
        "request at Khalilabad, District Sant Kabir Nagar, Uttar Pradesh, on this <b>06th day of October, 2026</b> at <b>12:36 AM</b>.",
        ParagraphStyle('Memo', parent=style_normal, fontSize=7.5, leading=10.5, textColor=colors.HexColor('#333333'), alignment=4)
    )
    t_memo = Table([[memo_text]], colWidths=[520])
    t_memo.setStyle(TableStyle([
        ('BOX', (0,0), (-1,-1), 0.8, colors.HexColor('#8B9E92')),
        ('BACKGROUND', (0,0), (-1,-1), colors.HexColor('#F4F7F5')),
        ('TOPPADDING', (0,0), (-1,-1), 4),
        ('BOTTOMPADDING', (0,0), (-1,-1), 4),
        ('LEFTPADDING', (0,0), (-1,-1), 6),
        ('RIGHTPADDING', (0,0), (-1,-1), 6),
    ]))
    story.append(t_memo)

    # ------------------------------------------------------------------
    # SCHEDULE A: DETAILED FEATURE & TECHNICAL SPECIFICATIONS
    # ------------------------------------------------------------------
    story.append(PageBreak())
    story.append(Paragraph("SCHEDULE A", style_title))
    story.append(Paragraph("Detailed Feature and Technical Specification of the Software Ecosystem", style_subtitle))

    sched_rows = [
        [
            Paragraph("<b>Module / Component</b>", style_bold),
            Paragraph("<b>Technical Architecture & Functional Specification</b>", style_bold)
        ],
        # Part 1
        [
            Paragraph("<b>Part 1: Mobile App<br/>(Cross-Platform)</b>", style_normal),
            Paragraph(
                "• <b>Framework:</b> Flutter / Dart compiled into native Android release build.<br/>"
                "• <b>OTA Updater Engine:</b> Background lifecycle resume observer & in-app auto-updater; checks cloud releases on startup and resume.<br/>"
                "• <b>User Interface:</b> 4D Claymorphic luxury tactile design with gold glowing accents, custom cards and animated press states.<br/>"
                "• <b>Authentication:</b> Biometric fingerprint/face auth + secure fallback PIN.<br/>"
                "• <b>Offline Support:</b> Hive & SQLite offline caching ensuring dashboard accessibility during network dropouts.<br/>"
                "• <b>Attribution:</b> Permanent 'Developed by Prashant Mani Tripathi' gold badge in Splash, Drawer, and About screens.",
                style_normal
            )
        ],
        # Part 2
        [
            Paragraph("<b>Part 2: Web Portal<br/>(Universal QR)</b>", style_normal),
            Paragraph(
                "• <b>Technology:</b> HTML5, Tailwind CSS, JavaScript mobile-first responsive architecture.<br/>"
                "• <b>Self-Admission:</b> Direct student registration via branch QR scan.<br/>"
                "• <b>Photo Upload:</b> Device storage/gallery picker with strict <b>5MB file size validation</b> and zero-copy multipart upload to Cloudinary (zero low-memory errors).<br/>"
                "• <b>Attendance Engine:</b> Instant QR check-in / check-out with branch timestamps.<br/>"
                "• <b>Branch Switcher:</b> Sliding branch switcher for Khalilabad and Mehdawal.",
                style_normal
            )
        ],
        # Part 3
        [
            Paragraph("<b>Part 3: Cloud Backend & Database</b>", style_normal),
            Paragraph(
                "• <b>API Server:</b> NestJS / TypeScript REST services deployed on Render.com cloud infrastructure.<br/>"
                "• <b>Database:</b> Neon PostgreSQL serverless relational database with automated daily backups.<br/>"
                "• <b>Media Storage:</b> Cloudinary CDN with branch-isolated folder paths (<code>chintamani/mehdawal/</code> and <code>chintamani/khalilabad/</code>).<br/>"
                "• <b>Security:</b> HTTPS SSL in transit, secret management via Render environment variables, role-based guard middleware.",
                style_normal
            )
        ],
        # Part 4
        [
            Paragraph("<b>Part 4: Dual-Branch Data Isolation</b>", style_normal),
            Paragraph(
                "• <b>Branches at Go-Live:</b> Khalilabad Branch (72 Seats) and Mehdawal Branch (65 Seats).<br/>"
                "• <b>Isolation Architecture:</b> Complete logical segregation of members, admissions, attendance, fees, seat matrix, and complaints per branch. Zero cross-branch data bleeding.<br/>"
                "• <b>Future Branch Support:</b> Modular multi-branch database schema allowing seamless addition of new branches under Clause 5.6.",
                style_normal
            )
        ],
        # Part 5
        [
            Paragraph("<b>Part 5: Out of Scope<br/>(Requires Separate SOW)</b>", style_normal),
            Paragraph(
                "• Native iOS App Store packaging (requires Apple Developer Program enrollment by Client).<br/>"
                "• External biometric hardware terminal integrations (fingerprint scanner turnstiles).<br/>"
                "• Multi-state white-label franchise multi-tenancy software redesign.<br/>"
                "• Custom accounting software / Tally integrations beyond standard CSV exports.",
                style_normal
            )
        ]
    ]

    t_sched = Table(sched_rows, colWidths=[130, 390])
    t_sched.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,0), colors.HexColor('#E8EFEA')),
        ('GRID', (0,0), (-1,-1), 0.5, colors.HexColor('#B2C9BC')),
        ('VALIGN', (0,0), (-1,-1), 'TOP'),
        ('TOPPADDING', (0,0), (-1,-1), 5),
        ('BOTTOMPADDING', (0,0), (-1,-1), 5),
        ('LEFTPADDING', (0,0), (-1,-1), 6),
        ('RIGHTPADDING', (0,0), (-1,-1), 6),
    ]))
    story.append(t_sched)

    # Build Document using NumberedCanvas
    doc.build(story, canvasmaker=NumberedCanvas)
    print(f"Master Agreement PDF successfully generated: {output_filename}")

if __name__ == '__main__':
    generate_agreement_pdf()
