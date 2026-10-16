import base64
import os

def img_to_base64(path):
    if not os.path.exists(path):
        return ""
    with open(path, "rb") as f:
        b64 = base64.b64encode(f.read()).decode('utf-8')
    ext = os.path.splitext(path)[1].replace('.', '')
    return f"data:image/{ext};base64,{b64}"

client_stamp_b64 = img_to_base64("client_stamp_trans.png")
dev_sig_b64 = img_to_base64("dev_sig_trans.png")
estamp_qr_b64 = img_to_base64("estamp_qr.png")
estamp_barcode_b64 = img_to_base64("estamp_barcode.png")
up_emblem_b64 = img_to_base64("up_govt_emblem.png")

html_content = f"""<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Master Software Development, IP & Ongoing Maintenance Agreement — Chinta Mani Library</title>
<script src="https://cdn.tailwindcss.com"></script>
<style>
    @import url('https://fonts.googleapis.com/css2?family=Cinzel:wght@600;700;800&family=Merriweather:ital,wght@0,300;0,400;0,700;1,300;1,400&family=Montserrat:wght@400;500;600;700&display=swap');
    
    body {{
        font-family: 'Merriweather', serif;
        background-color: #0b1310;
        color: #1a1a1a;
        margin: 0;
        padding: 20px;
    }}
    
    .page-container {{
        width: 210mm;
        min-height: 297mm;
        margin: 20px auto;
        background: #ffffff;
        box-shadow: 0 15px 35px rgba(0,0,0,0.4);
        padding: 16mm 14mm;
        box-sizing: border-box;
        position: relative;
        border: 2px solid #1E5136;
        outline: 1px solid #8B9E92;
        outline-offset: -5px;
    }}

    @media print {{
        body {{
            background: none;
            padding: 0;
        }}
        .page-container {{
            margin: 0;
            box-shadow: none;
            page-break-after: always;
            border: 2px solid #1E5136;
            outline: 1px solid #8B9E92;
            outline-offset: -5px;
        }}
        .no-print {{
            display: none !important;
        }}
    }}

    .legal-header {{
        font-family: 'Montserrat', sans-serif;
        font-size: 8.5px;
        font-weight: 700;
        color: #333;
        border-bottom: 1px solid #ccc;
        padding-bottom: 4px;
        margin-bottom: 12px;
        display: flex;
        justify-content: space-between;
    }}

    .legal-footer {{
        position: absolute;
        bottom: 8mm;
        left: 14mm;
        right: 14mm;
        font-family: 'Montserrat', sans-serif;
        font-size: 8px;
        color: #555;
        border-top: 1px solid #ccc;
        padding-top: 5px;
        display: flex;
        justify-content: space-between;
    }}

    h1, h2, h3, .cinzel {{
        font-family: 'Cinzel', serif;
    }}

    .sans {{
        font-family: 'Montserrat', sans-serif;
    }}

    p, li {{
        font-size: 10.5px;
        line-height: 1.55;
        text-align: justify;
        color: #222;
    }}

    .clause-title {{
        font-family: 'Montserrat', sans-serif;
        font-weight: 700;
        font-size: 11.5px;
        color: #113824;
        margin-top: 11px;
        margin-bottom: 3px;
        border-bottom: 1px solid #e2ebe5;
        padding-bottom: 2px;
    }}

    .estamp-table {{
        border-collapse: collapse;
        width: 100%;
        font-family: 'Montserrat', sans-serif;
        font-size: 9px;
    }}
    .estamp-table td, .estamp-table th {{
        border: 1px solid #B2C9BC;
        padding: 3.5px 5px;
    }}

    .spec-table {{
        border-collapse: collapse;
        width: 100%;
        font-family: 'Montserrat', sans-serif;
        font-size: 9.5px;
    }}
    .spec-table td, .spec-table th {{
        border: 1px solid #B2C9BC;
        padding: 5px 7px;
    }}
</style>
</head>
<body>

<div class="no-print max-w-4xl mx-auto mb-6 p-4 bg-emerald-950 text-emerald-100 rounded-xl flex items-center justify-between border border-emerald-700 shadow-2xl">
    <div>
        <h2 class="text-lg font-bold text-emerald-300">Official Master Software e-Agreement (Duly Executed & Witnessed)</h2>
        <p class="text-xs text-emerald-300/80">Govt. of Uttar Pradesh e-Stamp Certificate No: IN-UP84920481029482X | Issued: 06-Oct-2026 12:36 AM</p>
    </div>
    <div class="flex gap-3">
        <button onclick="window.print()" class="px-5 py-2 bg-emerald-600 hover:bg-emerald-500 text-white font-semibold rounded-lg shadow transition flex items-center gap-2 text-sm">
            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 17h2a2 2 0 002-2v-4a2 2 0 00-2-2H5a2 2 0 00-2 2v4a2 2 0 002 2h2m2 4h6a2 2 0 002-2v-4a2 2 0 00-2-2H9a2 2 0 00-2 2v4a2 2 0 002 2zm8-12V5a2 2 0 00-2-2H9a2 2 0 00-2 2v4h10z"></path></svg>
            Print / Save as PDF
        </button>
    </div>
</div>

<!-- ==========================================
     PAGE 1: e-STAMP & PREAMBLE
     ========================================== -->
<div class="page-container">
    <div class="border-[1.5px] border-[#1E5136] bg-[#FCFDFB] p-2 rounded mb-3">
        <div class="flex items-center justify-between border-b border-[#B2C9BC] pb-2 mb-2">
            <div class="text-center w-1/4">
                <img src="{estamp_barcode_b64}" class="h-9 mx-auto" alt="Barcode">
                <span class="text-[7.5px] font-mono tracking-widest text-gray-700">* IN-UP84920481029482X *</span>
            </div>
            <div class="text-center w-1/2">
                <img src="{up_emblem_b64}" class="h-7 mx-auto mb-0.5" alt="Emblem">
                <h3 class="font-bold text-xs uppercase text-[#0D3D22] tracking-wide sans">Government of Uttar Pradesh</h3>
                <h4 class="font-extrabold text-[12px] text-[#A62B2B] uppercase tracking-wider sans">e-Stamp Certificate</h4>
                <p class="text-[7px] text-gray-600 sans">Certificate Issued under Stock Holding Corporation of India Ltd. (SHCIL)</p>
            </div>
            <div class="text-center w-1/4">
                <img src="{estamp_qr_b64}" class="h-11 w-11 mx-auto" alt="QR">
            </div>
        </div>

        <table class="estamp-table bg-white">
            <tr>
                <td class="bg-gray-50 font-bold w-1/4">Certificate No.</td>
                <td class="font-bold text-[#113824] w-1/4">IN-UP84920481029482X</td>
                <td class="bg-gray-50 font-bold w-1/4">Certificate Issued Date</td>
                <td class="font-bold w-1/4">06-Oct-2026 12:36 AM</td>
            </tr>
            <tr>
                <td class="bg-gray-50 font-bold">Account Reference</td>
                <td class="text-[8px]">NEWIMPACC (SV)/ up1402804/ KHALILABAD/ UP-SKN</td>
                <td class="bg-gray-50 font-bold">Unique Doc. Reference</td>
                <td class="text-[8px] font-mono">SUBIN-UPUP140280439182740192837X</td>
            </tr>
            <tr>
                <td class="bg-gray-50 font-bold">Purchased by</td>
                <td class="font-semibold">MANGLESH MANI TRIPATHI</td>
                <td class="bg-gray-50 font-bold">Sub-Registrar Office</td>
                <td>Khalilabad, Sant Kabir Nagar</td>
            </tr>
            <tr>
                <td class="bg-gray-50 font-bold">Description of Document</td>
                <td class="text-[8px]">Article 5 Agreement (General) / IT Software Development & Licensing</td>
                <td class="bg-gray-50 font-bold">First Party</td>
                <td class="font-bold">MANGLESH MANI TRIPATHI</td>
            </tr>
            <tr>
                <td class="bg-gray-50 font-bold">Property Description</td>
                <td class="text-[8px]">MASTER SOFTWARE DEV, IP & MAINTENANCE AGREEMENT FOR CHINTA MANI LIBRARY</td>
                <td class="bg-gray-50 font-bold">Second Party</td>
                <td class="font-bold">PRASHANT MANI TRIPATHI</td>
            </tr>
            <tr>
                <td class="bg-gray-50 font-bold">Consideration Price</td>
                <td class="font-bold text-[#A62B2B]">Rs. 50,000/- (Rupees Fifty Thousand only)</td>
                <td class="bg-gray-50 font-bold">Stamp Duty Paid By</td>
                <td>MANGLESH MANI TRIPATHI</td>
            </tr>
            <tr>
                <td class="bg-gray-50 font-bold">Stamp Duty Amount</td>
                <td class="font-bold">Rs. 100/- (Rupees One Hundred only)</td>
                <td class="bg-gray-50 font-bold">e-Stamp Status</td>
                <td class="font-extrabold text-[#006622]">VERIFIED & ACTIVE (SHCIL)</td>
            </tr>
        </table>
        
        <p class="text-[7.5px] text-gray-500 mt-1 sans leading-tight">
            <b>Statutory Alert:</b> 1. The authenticity of this Stamp Certificate should be verified at <b>'www.shcilestamp.com'</b> or using e-Stamp Mobile App of Stock Holding. Any discrepancy renders it invalid. 2. The onus of checking legitimacy is on users. 3. In case of discrepancy please inform Competent Authority.
        </p>
    </div>

    <div class="text-center text-[7.5px] text-gray-400 font-mono tracking-widest my-2 sans">
        ---------------------------------- Please write or type below this line ----------------------------------
    </div>

    <div class="text-center mb-3">
        <h1 class="text-[12.5px] font-bold text-[#0F2A1D] tracking-wide">MASTER SOFTWARE DEVELOPMENT, INTELLECTUAL PROPERTY & ONGOING MAINTENANCE AGREEMENT</h1>
        <p class="text-[8.5px] italic text-gray-600 mt-0.5">Executed under the Indian Contract Act, 1872 & Information Technology Act, 2000</p>
    </div>

    <p class="mb-2">
        This Master Software Development, Intellectual Property & Ongoing Maintenance Agreement (the <b>"Agreement"</b>) is made and executed at Khalilabad, District Sant Kabir Nagar, Uttar Pradesh, India, on this <b>06th day of October, 2026</b> at <b>12:36 AM</b> (the <b>"Effective Date"</b>), by and between:
    </p>
    <p class="mb-2 pl-3 border-l-2 border-emerald-700">
        <b>(1) MANGLESH MANI TRIPATHI</b>, acting in his capacity as Proprietor / Director of <b>"CHINTA MANI LIBRARY"</b>, operating its Khalilabad Branch (72 Seats) and Mehdawal Branch (65 Seats) at Sant Kabir Nagar, Uttar Pradesh, India, Phone: +91 9415919277 (hereinafter referred to as the <b>"Client"</b> or the <b>"Owner"</b>, which expression shall, unless repugnant to the context, include his legal heirs, successors, legal representatives and permitted assigns); <b>AND</b>
    </p>
    <p class="mb-2 pl-3 border-l-2 border-emerald-700">
        <b>(2) PRASHANT MANI TRIPATHI</b> (also known as Prashant Tripathi), an Independent Software Architect and Full-Stack Developer residing at District Sant Kabir Nagar, Uttar Pradesh, India (hereinafter referred to as the <b>"Developer"</b> or the <b>"Consultant"</b>, which expression shall, unless repugnant to the context, include his legal heirs, successors, legal representatives and permitted assigns).
    </p>
    <p class="mb-2 text-xs">
        The Client and the Developer are individually referred to as a <b>"Party"</b> and collectively as the <b>"Parties"</b>.
    </p>

    <h3 class="font-bold text-[10px] text-[#113824] sans uppercase tracking-wider mt-2.5 mb-1">Recitals:</h3>
    <p class="mb-1 text-[10px]"><b>A.</b> The Client owns and operates <b>Chinta Mani Library</b>, a multi-branch self-study library enterprise with operational branches at Khalilabad (72 Seats) and Mehdawal (65 Seats) in District Sant Kabir Nagar, Uttar Pradesh, and intends to expand to further branches.</p>
    <p class="mb-1 text-[10px]"><b>B.</b> The Developer has independently engineered and developed a proprietary multi-branch library management software ecosystem comprising: (i) a cross-platform mobile application built with Flutter/Dart (Android build) featuring an in-app Over-the-Air (OTA) updater engine, 4D claymorphic UI, biometric and PIN authentication, and offline caching; (ii) a universal QR self-admission, student photo upload and attendance web portal built with HTML5 and Tailwind CSS, utilizing a Cloudinary zero-copy multi-part photo pipeline; (iii) a cloud backend and database architecture built with NestJS / Node.js, Neon PostgreSQL, Render.com microservices, and Cloudinary CDN; and (iv) a dual-branch isolation architecture providing strict data segregation between the Khalilabad and Mehdawal branches, with scalable support for future branches (together, the <b>"Software"</b>).</p>
    <p class="mb-1 text-[10px]"><b>C.</b> The Client wishes to obtain, and the Developer is willing to grant, a licence to deploy, run and operate the Software for the Client's library business, and the Client wishes to engage the Developer to maintain, support and service the Software on an ongoing basis.</p>
    <p class="mb-1 text-[10px]"><b>D.</b> The Parties wish to formally record, in a single binding instrument, their respective rights in the intellectual property, the Developer's non-negotiable right of attribution, the commercial terms, the allocation of responsibility for third-party cloud services, data privacy, and the terms of maintenance, confidentiality, termination, and dispute resolution.</p>
    <p class="mt-2 text-[10px]"><b>NOW, THEREFORE</b>, in consideration of the mutual covenants contained herein, and for other good and valuable consideration, the receipt and sufficiency of which are hereby acknowledged, the Parties agree as follows:</p>

    <div class="legal-footer">
        <span>Govt. of Uttar Pradesh e-Stamp: IN-UP84920481029482X • Issued: 06-Oct-2026 12:36 AM</span>
        <span>Page 1 of 7 &nbsp;|&nbsp; Executant Initials: [ MMT ] _____ &nbsp; [ PMT ] _____</span>
    </div>
</div>

<!-- ==========================================
     PAGE 2: CLAUSES 1, 2, 3
     ========================================== -->
<div class="page-container">
    <div class="legal-header">
        <span>Master Software Development, IP & Ongoing Maintenance Agreement — Chinta Mani Library</span>
        <span>Deed Ref: CML/DEV/UP-SKN/2026/01</span>
    </div>

    <div class="clause-title">1. DEFINITIONS AND INTERPRETATION</div>
    <ul class="list-none space-y-1 text-[10px] pl-1">
        <li><b>(a) "Background Technology"</b> means all software, code, algorithms, frameworks, modules, libraries, tools, designs, know-how, methodologies and architectural patterns that were conceived, authored or acquired by the Developer before the Effective Date or independently of this Agreement, including the Reusable Components, together with all improvements to them.</li>
        <li><b>(b) "Client Data"</b> means all data entered into, collected through or generated by the Software in the course of the Client's operations, including student and member records, admission details, student photographs, attendance logs, fee and payment records, seat allocations, branch operating records and financial information, but excluding the Software itself.</li>
        <li><b>(c) "Client Materials"</b> means the Client's name, the "Chinta Mani Library" trade name, official logos, branding, trademarks, taglines, marketing content and branch operating information.</li>
        <li><b>(d) "Cloud Infrastructure"</b> means the third-party hosting, database, and vendor services on which the Software runs, including Render.com, Neon PostgreSQL, Cloudinary CDN, the Google Play Console developer account, and SMS/WhatsApp API gateways.</li>
        <li><b>(e) "Confidential Information"</b> means all non-public information disclosed by or on behalf of a Party to the other, in any form, including library business financials, student credentials and personal data, API keys, access tokens, environment variables, Source Code, database schemas, architectural designs and trade secrets.</li>
        <li><b>(f) "Custom Deliverables"</b> means the specific configurations, screens, workflows, reports, integrations and branch-specific customisations developed specifically for the Client under this Agreement and listed in Schedule A, excluding all Background Technology.</li>
        <li><b>(g) "Derivative Works"</b> means any modification, adaptation, translation, enhancement, port, or other work based upon or derived from the Software or any part of it.</li>
        <li><b>(h) "Reusable Components"</b> means the reusable modules, architectural scaffolding, in-app OTA updater engine, authentication layer, branch-isolation framework, photo pipeline, background code libraries and utilities forming part of the Software.</li>
        <li><b>(i) "Source Code"</b> means the human-readable form of the Software, including comments, build scripts, configuration and technical documentation, in any programming language.</li>
    </ul>
    <p class="text-[10px] mt-1"><b>1.2 Interpretation.</b> Headings are for convenience only. References to statutes include all statutory amendments, rules and re-enactments. The Schedules form an integral part of this Agreement. In case of conflict, the body of this Agreement prevails over the Schedules.</p>

    <div class="clause-title">2. SCOPE OF ENGAGEMENT & PROJECT DELIVERY TIMELINE</div>
    <p class="text-[10px] mb-1"><b>2.1 Software Provision.</b> The Developer shall make the Software available to the Client, configured and deployed for the Khalilabad and Mehdawal branches, and shall deliver the Custom Deliverables in accordance with Schedule A.</p>
    <p class="text-[10px] mb-1"><b>2.2 Independent Contractor.</b> The Developer shall perform the services as an independent software architect and contractor, using his own tools, development environments, and working hours. Nothing in this Agreement creates an employment, partnership, joint venture, or agency relationship between the Parties.</p>
    <p class="text-[10px] mb-1"><b>2.3 Project Delivery Schedule & Estimated Timeline.</b> The Parties agree that the total estimated timeframe for the end-to-end execution, branch configuration, cloud deployment, dual-branch verification, and operational handover of the Software is <b>Sixty (60) Days (Two Calendar Months)</b> from the Effective Date, subject to the milestone schedule set forth in Clause 5.3.</p>

    <div class="clause-title">3. INTELLECTUAL PROPERTY AND OWNERSHIP</div>
    <p class="text-[10px] mb-1"><b>3.1 Client Ownership.</b> As between the Parties, the Client is and shall remain the sole and exclusive owner of all Client Data and all Client Materials, including student databases, member records, library branding, logos, and branch operating information. Nothing in this Agreement transfers any ownership right in the Client Data or Client Materials to the Developer, save the limited right to process the Client Data to perform the services and the limited right to display Client Materials within the Software.</p>
    <p class="text-[10px] mb-1"><b>3.2 Developer Ownership.</b> The Developer is and shall remain the sole and exclusive author and owner of the copyright and all other intellectual property rights in the Software, the Source Code, the Background Technology, and the Reusable Components (including the OTA updater engine, architectural scaffolding, and background code libraries), and in all Derivative Works of them, whether created before or after the Effective Date. Any rights in the Software not expressly granted to the Client are strictly reserved to the Developer.</p>
    <p class="text-[10px] mb-1"><b>3.3 Licence to the Client.</b> The Developer hereby grants to the Client an exclusive (as regards the self-study library management field described in Clause 3.4), irrevocable (save as provided in Clause 11.3(c)), perpetual, royalty-free licence to deploy, run, operate, and use the Software and Custom Deliverables for all present and future branches of Chinta Mani Library, owned or operated by the Client or by an entity wholly controlled by him, without any additional licence fee, subject to the Client's continued compliance with Clauses 3.4, 4, and 5.</p>
    <p class="text-[10px] mb-1"><b>3.4 Restrictions; No Transfer to Third Parties.</b> The Client covenants that it shall not, without the prior written consent of the Developer: (a) assign, sub-license, sell, lease, transfer, or otherwise make available the Software, the licence granted under Clause 3.3, or any right under this Agreement to any third-party commercial library, coaching institute, library franchise or other business; (b) copy, decompile, reverse engineer, disassemble, or attempt to derive the Source Code, or create Derivative Works of the Software, except as expressly permitted by law; (c) remove, alter, obscure, or tamper with any proprietary notice or attribution (including that required by Clause 4); or (d) permit any person other than its authorised staff and students to administer the Software.</p>
    <p class="text-[10px] mb-1"><b>3.5 Source Code Custody and Continuity.</b> The Source Code remains in the Developer's exclusive custody. If the Developer, for a continuous period of ninety (90) days, is unable or unwilling to provide the maintenance services under Clause 7 although all fees are fully paid, the Developer shall, on the Client's written request, release to the Client (or an escrow engineer bound by confidentiality) a copy of the Source Code solely for the purpose of maintaining the Software for the Client's own branches, and not for any other use, sale, or disclosure.</p>

    <div class="legal-footer">
        <span>Govt. of Uttar Pradesh e-Stamp: IN-UP84920481029482X • Issued: 06-Oct-2026 12:36 AM</span>
        <span>Page 2 of 7 &nbsp;|&nbsp; Executant Initials: [ MMT ] _____ &nbsp; [ PMT ] _____</span>
    </div>
</div>

<!-- ==========================================
     PAGE 3: CLAUSES 4, 5 & MILESTONES
     ========================================== -->
<div class="page-container">
    <div class="legal-header">
        <span>Master Software Development, IP & Ongoing Maintenance Agreement — Chinta Mani Library</span>
        <span>Deed Ref: CML/DEV/UP-SKN/2026/01</span>
    </div>

    <div class="clause-title">4. MANDATORY DEVELOPER ATTRIBUTION AND MORAL RIGHTS</div>
    <p class="text-[10px] mb-1"><b>4.1 Statutory Moral Rights.</b> The Parties expressly acknowledge the Developer's special rights as author under Section 57 of the Copyright Act, 1957, to claim authorship of the Software and to restrain or claim damages in respect of any distortion, mutilation, modification or other act in relation to it that would be prejudicial to his honour or professional reputation. The Client shall not do, or permit, any such act.</p>
    <p class="text-[10px] mb-1"><b>4.2 Attribution Covenant.</b> The Client covenants that the Developer's credit, in the form <b>"Developed by Prashant Mani Tripathi"</b> accompanied by the official gold sparkle emblem supplied with the Software (the <b>"Attribution"</b>), shall remain permanently visible, legible, and untampered in each of the following locations: (a) the Mobile Application Splash Screen; (b) the Main Navigation Drawer / Side Menu of the Mobile Application; (c) the Settings / "About Software" section of the Mobile Application; and (d) the footers of the Web Portal (including the QR self-admission, student photo upload, and attendance pages) and all accompanying documentation.</p>
    <p class="text-[10px] mb-1"><b>4.3 Material Breach.</b> Any removal of, or tampering with, the Attribution constitutes a material breach of this Agreement. Without prejudice to any other legal remedy, the Developer may: (i) call upon the Client to restore the Attribution within seven (7) days of written notice; (ii) failing which, suspend OTA updates and support, and/or terminate this Agreement for cause under Clause 11.3; and (iii) seek injunctive relief and damages in court, the Parties acknowledging that damages alone would be an inadequate remedy.</p>

    <div class="clause-title">5. COMMERCIAL CONSIDERATION AND PAYMENT TERMS</div>
    <p class="text-[10px] mb-1"><b>5.1 Setup & Software Engineering Fee.</b> In full consideration of the custom development, configuration, dual-branch deployment, and exclusive perpetual licence of the Software, the Client shall pay to the Developer a fixed, one-time Software Engineering / Setup Fee of <b>Rs. 50,000/- (Rupees Fifty Thousand only)</b>, exclusive of applicable government taxes.</p>
    <p class="text-[10px] mb-2"><b>5.2 Maintenance and SLA Retainer.</b> In consideration of the ongoing technical support, cloud health monitoring, and maintenance services described in Clause 7, the Client shall pay to the Developer a recurring Maintenance and SLA Retainer of <b>Rs. 1,000/- (Rupees One Thousand only) per month</b>, payable in advance on or before the <b>5th (fifth) day</b> of each English calendar month.</p>

    <h4 class="font-bold text-[10px] text-[#113824] sans uppercase mb-1">5.3 Project Delivery Milestones (2-Month Schedule):</h4>
    <table class="spec-table mb-2">
        <thead class="bg-[#E8EFEA] text-[#113824] font-bold">
            <tr>
                <th class="w-12 text-center">Milestone</th>
                <th>Trigger & Deliverable</th>
                <th class="w-28 text-center">Timeline</th>
                <th class="w-16 text-center">% of Fee</th>
                <th class="w-24 text-right">Amount (Rs.)</th>
            </tr>
        </thead>
        <tbody>
            <tr>
                <td class="text-center font-bold">M1</td>
                <td>Project Inception, Architectural Blueprints & Contract Execution</td>
                <td class="text-center">Upon Signing</td>
                <td class="text-center">30 %</td>
                <td class="text-right font-bold">Rs. 15,000/-</td>
            </tr>
            <tr>
                <td class="text-center font-bold">M2</td>
                <td>Dual-Branch Beta Deployment & Cloud API Configuration (Khalilabad & Mehdawal)</td>
                <td class="text-center">Within 30 Days (Month 1)</td>
                <td class="text-center">40 %</td>
                <td class="text-right font-bold">Rs. 20,000/-</td>
            </tr>
            <tr>
                <td class="text-center font-bold">M3</td>
                <td>Final Acceptance, Production Go-Live, Staff Training & Handover</td>
                <td class="text-center">Within 60 Days (Month 2)</td>
                <td class="text-center">30 %</td>
                <td class="text-right font-bold">Rs. 15,000/-</td>
            </tr>
            <tr class="bg-[#F2F5F3] font-bold">
                <td class="text-center text-[#113824]">TOTAL</td>
                <td class="text-[#113824]">Complete 2-Month Turnkey Development & Deployment</td>
                <td class="text-center">60 Days Total</td>
                <td class="text-center">100 %</td>
                <td class="text-right text-[#A62B2B]">Rs. 50,000/-</td>
            </tr>
        </tbody>
    </table>

    <p class="text-[10px] mb-1"><b>5.4 Mode of Payment.</b> Payments shall be made by Direct Bank Transfer (NEFT/RTGS/IMPS), Unified Payments Interface (UPI), or Account Payee Cheque to the bank account designated in writing by the Developer. Time of payment is of the essence of this Agreement.</p>
    <p class="text-[10px] mb-1"><b>5.5 Default and Delay.</b> If any undisputed amount is not paid within seven (7) days of its due date: (a) interest shall accrue at the rate of one and a half percent (1.5%) per month on the outstanding amount, calculated daily; (b) the Developer may, after written notice of seven (7) days, suspend maintenance, OTA updates and support until full payment is cleared (without liability for resulting operational disruption); and (c) if default continues for thirty (30) days, the Developer may terminate this Agreement under Clause 11.3.</p>
    <p class="text-[10px] mb-1"><b>5.6 Future Branch Expansion.</b> If the Client establishes new branches (e.g., in Basti, Gorakhpur, etc.), onboarding each additional branch will incur a one-time setup fee of Rs. 15,000/- and an additional Rs. 500/- per month added to the monthly maintenance retainer.</p>

    <div class="legal-footer">
        <span>Govt. of Uttar Pradesh e-Stamp: IN-UP84920481029482X • Issued: 06-Oct-2026 12:36 AM</span>
        <span>Page 3 of 7 &nbsp;|&nbsp; Executant Initials: [ MMT ] _____ &nbsp; [ PMT ] _____</span>
    </div>
</div>

<!-- ==========================================
     PAGE 4: CLAUSES 6, 7, 8, 9
     ========================================== -->
<div class="page-container">
    <div class="legal-header">
        <span>Master Software Development, IP & Ongoing Maintenance Agreement — Chinta Mani Library</span>
        <span>Deed Ref: CML/DEV/UP-SKN/2026/01</span>
    </div>

    <div class="clause-title">6. CLOUD INFRASTRUCTURE AND THIRD-PARTY EXPENSES</div>
    <p class="text-[10px] mb-1"><b>6.1 Direct Client Expenses.</b> The Client is solely responsible for, and shall pay directly and on time, all recurring third-party costs required to run the Software, including: (a) Render.com hosting fees; (b) Neon PostgreSQL cloud database usage charges; (c) Cloudinary media storage and CDN bandwidth fees; (d) Google Play Console developer account fees; (e) SMS and WhatsApp gateway charges; and (f) custom domains, SSL certificates, and third-party vendor charges (together, <b>"Third-Party Charges"</b>).</p>
    <p class="text-[10px] mb-1"><b>6.2 Account Ownership.</b> Accounts with Cloud Infrastructure vendors shall be registered in the Client's legal name, with the Developer being granted administrative API and deployment access needed to perform the services. The Developer shall keep all credentials secure.</p>
    <p class="text-[10px] mb-1"><b>6.3 No Developer Liability for Cloud Outages.</b> The Developer is not financially or operationally liable for any outage, data loss, degraded performance, or suspension of the Software caused by: (a) the Client's failure to renew or pay for any Cloud Infrastructure service; (b) the act or omission of a third-party cloud vendor; or (c) usage exceeding the subscription tier limits that the Client has paid for.</p>

    <div class="clause-title">7. SERVICE LEVEL AGREEMENT, BUG FIXES AND ENHANCEMENTS</div>
    <p class="text-[10px] mb-1"><b>7.1 Standard Maintenance Scope.</b> In return for the monthly retainer of Rs. 1,000/-, the Developer shall provide: (a) software bug identification and resolution; (b) build release and distribution of version updates through the OTA in-app updater engine; (c) security patches and dependency updates; and (d) automated scheduled database backup monitoring with periodic restoration verifications.</p>
    <p class="text-[10px] mb-1"><b>7.2 Support Hours & Response Targets.</b> Standard support hours are 10:00 a.m. to 7:00 p.m. IST, Monday to Saturday (excluding gazetted public holidays in Uttar Pradesh). Critical (P1) issues (software down at a branch) shall receive initial response within 4 hours and target resolution within 24 hours. Normal defects (P2/P3) shall be addressed in the next scheduled release.</p>
    <p class="text-[10px] mb-1"><b>7.3 Major Architectural Changes.</b> Any work beyond standard maintenance, including new business modules, complete UI overhauls, or multi-state franchising architectures, shall require a separate written Statement of Work (SOW) and additional compensation agreed upon before work commences.</p>

    <div class="clause-title">8. DATA PRIVACY AND COMPLIANCE (DPDP ACT 2023 & IT ACT 2000)</div>
    <p class="text-[10px] mb-1"><b>8.1 Legal Roles.</b> For the purposes of the Digital Personal Data Protection Act, 2023 (the <b>"DPDP Act"</b>), the Client is the <b>Data Fiduciary</b> in respect of all personal data of students and library members, and the Developer acts strictly as a <b>Data Processor</b> processing such data solely on the Client's behalf and documented instructions.</p>
    <p class="text-[10px] mb-1"><b>8.2 Client Compliance.</b> The Client is solely responsible for: (a) obtaining free, specific, informed and unambiguous consent from each student (and verifiable parental/guardian consent for students under eighteen years of age); (b) accuracy of data entered; (c) physical device security at its premises; and (d) legal notifications to the Data Protection Board of India in case of client-side breaches.</p>
    <p class="text-[10px] mb-1"><b>8.3 Developer Safeguards.</b> The Developer shall: (a) design and maintain reasonable technical safeguards, including zero-copy image streaming in the photo pipeline (eliminating local storage leaks), HTTPS encryption in transit, branch-level database query isolation, and role-based access control; and (b) notify the Client without undue delay within 72 hours upon becoming aware of any confirmed server-side data breach.</p>
    <p class="text-[10px] mb-1"><b>8.4 Branch Isolation.</b> The Software shall keep all records of the Khalilabad branch and Mehdawal branch logically segregated. There shall be zero accidental cross-branch data bleeding.</p>

    <div class="clause-title">9. CONFIDENTIALITY, NON-COMPETE AND NON-SOLICITATION</div>
    <p class="text-[10px] mb-1"><b>9.1 Reciprocal Confidentiality.</b> Each Party shall keep the other's Confidential Information in strict confidence. The Developer shall protect the Client's business financials, student records, and operational data. The Client shall protect the Developer's Source Code, API keys, database schemas, architectural designs, and technical secrets.</p>
    <p class="text-[10px] mb-1"><b>9.2 Non-Compete During Term.</b> During the subsistence of this Agreement: (a) the Client shall not engage any third party to build, or itself build, a competing library management system by utilizing the Developer's Confidential Information or Source Code; and (b) the Developer shall not license or deploy this bespoke Software to any other commercial study library within a geographical radius of ten (10) kilometres of the Client's active branches in Sant Kabir Nagar without the Client's prior written consent (reasonable protection under Section 27 of the Indian Contract Act, 1872).</p>

    <div class="legal-footer">
        <span>Govt. of Uttar Pradesh e-Stamp: IN-UP84920481029482X • Issued: 06-Oct-2026 12:36 AM</span>
        <span>Page 4 of 7 &nbsp;|&nbsp; Executant Initials: [ MMT ] _____ &nbsp; [ PMT ] _____</span>
    </div>
</div>

<!-- ==========================================
     PAGE 5: CLAUSES 10, 11, 12, 13, 14
     ========================================== -->
<div class="page-container">
    <div class="legal-header">
        <span>Master Software Development, IP & Ongoing Maintenance Agreement — Chinta Mani Library</span>
        <span>Deed Ref: CML/DEV/UP-SKN/2026/01</span>
    </div>

    <div class="clause-title">10. WARRANTIES, INDEMNITY AND LIMITATION OF LIABILITY</div>
    <p class="text-[10px] mb-1"><b>10.1 Warranties.</b> The Developer warrants that he has the full right to grant the licence in Clause 3.3, and that the Software as delivered materially conforms to Schedule A. The Client warrants that all branding and content provided to the Developer are lawfully owned.</p>
    <p class="text-[10px] mb-1"><b>10.2 Limitation of Liability.</b> To the maximum extent permitted by Indian law, neither Party is liable for indirect, special, or consequential damages. The Developer's total aggregate liability arising out of this Agreement shall not exceed the total fees actually received by him from the Client in the twelve (12) months preceding the claim.</p>

    <div class="clause-title">11. TERM, TERMINATION AND EXIT MANAGEMENT</div>
    <p class="text-[10px] mb-1"><b>11.1 Term.</b> This Agreement commences on the Effective Date and continues for an initial term of one (1) year, automatically renewing for successive one (1) year terms. The software licence under Clause 3.3 is perpetual, subject to Clauses 3.4 and 4.</p>
    <p class="text-[10px] mb-1"><b>11.2 Termination for Convenience.</b> Either Party may terminate the ongoing maintenance services for convenience by providing the other Party not less than sixty (60) days' prior written notice.</p>
    <p class="text-[10px] mb-1"><b>11.3 Exit Protocol.</b> Upon termination or expiry, and subject to full settlement of all pending invoices, the Developer shall within fifteen (15) days hand over to the Client complete database dumps of the Client Data in standard JSON/SQL format, along with administrative access credentials for the Client's cloud vendor accounts.</p>

    <div class="clause-title">12. FORCE MAJEURE</div>
    <p class="text-[10px] mb-1">Neither Party is liable for delay or failure caused by events beyond reasonable control, including natural disaster, epidemic, governmental act, major telecommunications/cloud vendor outages, or grid failures, provided prompt written notice is given.</p>

    <div class="clause-title">13. GOVERNING LAW AND DISPUTE RESOLUTION</div>
    <p class="text-[10px] mb-1"><b>13.1 Governing Law.</b> This Agreement shall be governed by, and construed exclusively in accordance with, the laws of the Republic of India.</p>
    <p class="text-[10px] mb-1"><b>13.2 Arbitration.</b> Any dispute arising out of or in connection with this Agreement shall be referred to and finally resolved by arbitration administered by a Sole Arbitrator appointed by mutual consent of the Parties under the Arbitration and Conciliation Act, 1996. The seat and venue of arbitration shall be <b>Khalilabad, District Sant Kabir Nagar, Uttar Pradesh</b>. Proceedings shall be conducted in English or Hindi, and the arbitrator's award shall be final and binding.</p>
    <p class="text-[10px] mb-1"><b>13.3 Court Jurisdiction.</b> Subject to Clause 13.2, the civil courts in District Sant Kabir Nagar, Uttar Pradesh shall have exclusive jurisdiction.</p>

    <div class="clause-title">14. GENERAL PROVISIONS & ELECTRONIC EXECUTION</div>
    <p class="text-[10px] mb-1"><b>14.1 Entire Agreement.</b> This Agreement, together with Schedule A, constitutes the entire understanding between the Parties and supersedes all prior oral or written discussions.</p>
    <p class="text-[10px] mb-1"><b>14.2 Electronic Signatures & Enforceability.</b> In accordance with Sections 3A, 10A, and 65B of the Information Technology Act, 2000, the Parties agree that digital or electronic signatures affixed to this Agreement constitute valid, binding, and legally enforceable execution, and that this document shall not be denied validity solely because it is in electronic format.</p>
    <p class="text-[10px] mb-1"><b>14.3 Stamp Duty.</b> The applicable stamp duty under the Indian Stamp Act, 1899, as applicable in Uttar Pradesh, has been paid via Government of Uttar Pradesh e-Stamp Certificate No. <b>IN-UP84920481029482X</b>, issued on <b>06-Oct-2026 at 12:36 AM</b>, affixed hereto.</p>

    <div class="legal-footer">
        <span>Govt. of Uttar Pradesh e-Stamp: IN-UP84920481029482X • Issued: 06-Oct-2026 12:36 AM</span>
        <span>Page 5 of 7 &nbsp;|&nbsp; Executant Initials: [ MMT ] _____ &nbsp; [ PMT ] _____</span>
    </div>
</div>

<!-- ==========================================
     PAGE 6: EXECUTION & INDEPENDENT WITNESSES DEED (NO NOTARY)
     ========================================== -->
<div class="page-container">
    <div class="legal-header">
        <span>Master Software Development, IP & Ongoing Maintenance Agreement — Chinta Mani Library</span>
        <span>Deed Ref: CML/DEV/UP-SKN/2026/01</span>
    </div>

    <div class="text-center mb-2">
        <h2 class="text-[13px] font-bold text-[#0F2A1D] tracking-wide">EXECUTION & ATTESTATION CLAUSE</h2>
        <p class="text-[8px] italic text-gray-600">Executed in accordance with Section 10 of the Indian Contract Act, 1872 & Information Technology Act, 2000</p>
    </div>

    <p class="text-[10px] mb-2.5">
        <b>IN WITNESS WHEREOF</b>, the Parties hereto have set their hands, official seal, and electronic signatures to this Master Software Development, Intellectual Property & Ongoing Maintenance Agreement on this <b>06th day of October, 2026</b> at <b>12:36 AM</b> at Khalilabad, District Sant Kabir Nagar, Uttar Pradesh, having read, understood, and agreed to all covenants, terms, consideration, and schedules herein, in the presence of the independent attesting witnesses subscribed below:
    </p>

    <!-- Party Execution Table -->
    <div class="border border-[#2C4736] rounded bg-[#FCFDFB] p-2.5 mb-3 shadow-sm">
        <div class="grid grid-cols-2 gap-4">
            <!-- Client Box -->
            <div class="border-r border-gray-300 pr-3 flex flex-col justify-between">
                <div>
                    <span class="text-[9.5px] font-bold uppercase text-gray-500 sans">First Party (The Client / Owner):</span>
                    <h3 class="text-xs font-bold text-[#113824]">MANGLESH MANI TRIPATHI</h3>
                    <p class="text-[9px] text-gray-700">Proprietor / Director, Chinta Mani Library</p>
                    <p class="text-[9px] text-gray-700">Khalilabad (72 Seats) & Mehdawal (65 Seats)</p>
                    <p class="text-[9px] text-gray-700">Phone: +91 9415919277</p>
                </div>
                <div class="my-1.5 py-1 text-center bg-white border border-dashed border-gray-300 rounded">
                    <img src="{client_stamp_b64}" class="h-20 mx-auto object-contain" alt="Client Stamp & Sig">
                </div>
                <div class="text-center">
                    <p class="text-[9.5px] font-bold text-gray-800">Manglesh Mani Tripathi</p>
                    <p class="text-[8px] text-gray-500 italic">(Signed with Official Rubber Seal)</p>
                    <p class="text-[7.5px] text-gray-500 font-mono mt-0.5">Executed at Khalilabad • Date: 06/10/2026 • Time: 12:36 AM</p>
                </div>
            </div>

            <!-- Developer Box -->
            <div class="pl-2 flex flex-col justify-between">
                <div>
                    <span class="text-[9.5px] font-bold uppercase text-gray-500 sans">Second Party (The Developer / Architect):</span>
                    <h3 class="text-xs font-bold text-[#113824]">PRASHANT MANI TRIPATHI</h3>
                    <p class="text-[9px] text-gray-700">Independent Software Architect & Full-Stack Developer</p>
                    <p class="text-[9px] text-gray-700">Sant Kabir Nagar, Uttar Pradesh</p>
                    <p class="text-[9px] text-gray-700">Author, Lead System Architect & Engineer</p>
                </div>
                <div class="my-1.5 py-1 text-center bg-white border border-dashed border-gray-300 rounded">
                    <img src="{dev_sig_b64}" class="h-20 mx-auto object-contain" alt="Developer Sig">
                </div>
                <div class="text-center">
                    <p class="text-[9.5px] font-bold text-gray-800">Prashant Mani Tripathi</p>
                    <p class="text-[8px] text-gray-500 italic">(Digitally & Hand-Signed)</p>
                    <p class="text-[7.5px] text-gray-500 font-mono mt-0.5">Executed at Khalilabad • Date: 06/10/2026 • Time: 12:36 AM</p>
                </div>
            </div>
        </div>
    </div>

    <!-- Independent Witnesses Section (Full Width 2 Balanced Columns) -->
    <div class="border border-[#2C4736] rounded bg-[#F8FAF9] p-3 mb-2.5 shadow-sm">
        <h4 class="font-bold text-[10px] text-[#113824] uppercase sans mb-2 border-b border-[#B2C9BC] pb-1">Independent Attesting Witnesses:</h4>
        <div class="grid grid-cols-2 gap-4 text-[9.5px]">
            <!-- Left: Witness 1 -->
            <div class="border-r border-[#B2C9BC] pr-3">
                <p class="font-bold text-[#113824] text-[10px] mb-1">1. First Attesting Witness (Khalilabad):</p>
                <p class="italic text-gray-700 font-serif text-[10px]">Signature: Rakesh C. Verma</p>
                <p>Full Name: <b>Shri Rakesh Chandra Verma</b></p>
                <p>Father's Name: Late Sh. Ram Prasad Verma</p>
                <p>Occupation: Business / Civic Administration</p>
                <p>Residential Address: Bank Colony, Near Tehsil Road, Khalilabad, Dist. Sant Kabir Nagar, U.P. - 272175</p>
                <p class="font-mono text-[9px] text-gray-700">Aadhaar Number: <b>XXXX-XXXX-4819</b></p>
                <p class="font-semibold text-emerald-800 text-[8.5px] mt-1">Attestation Date & Time: 06/10/2026 at 12:36 AM</p>
            </div>

            <!-- Right: Witness 2 -->
            <div class="pl-2">
                <p class="font-bold text-[#113824] text-[10px] mb-1">2. Second Attesting Witness (Mehdawal):</p>
                <p class="italic text-gray-700 font-serif text-[10px]">Signature: Alok Kr. Srivastava</p>
                <p>Full Name: <b>Shri Alok Kumar Srivastava</b></p>
                <p>Father's Name: Sh. Dinesh Chandra Srivastava</p>
                <p>Occupation: Academician / Educationist</p>
                <p>Residential Address: Main Market Road, Near Post Office, Mehdawal, Dist. Sant Kabir Nagar, U.P. - 272271</p>
                <p class="font-mono text-[9px] text-gray-700">Aadhaar Number: <b>XXXX-XXXX-7231</b></p>
                <p class="font-semibold text-emerald-800 text-[8.5px] mt-1">Attestation Date & Time: 06/10/2026 at 12:36 AM</p>
            </div>
        </div>
    </div>

    <!-- Attestation & Identification Memorandum -->
    <div class="border border-[#8B9E92] bg-[#F4F7F5] p-2 rounded text-[8px] leading-tight text-gray-700">
        <p class="font-bold text-[#113824] mb-0.5 sans">ATTESTATION & IDENTIFICATION MEMORANDUM:</p>
        <p>
            We, the above-named attesting witnesses, do hereby solemnly declare, certify, and attest that the executants of this Deed, namely <b>Shri Manglesh Mani Tripathi</b> (First Party / Owner) and <b>Shri Prashant Mani Tripathi</b> (Second Party / Developer), are well known to us personally. They have executed, signed, and affixed their official seal to this Agreement in our simultaneous presence, sight, and hearing, having fully read and understood the commercial, technical, and intellectual property covenants herein contained. We have subscribed our names as attesting witnesses in their presence and at their express request at Khalilabad, District Sant Kabir Nagar, Uttar Pradesh, on this <b>06th day of October, 2026</b> at <b>12:36 AM</b>.
        </p>
    </div>

    <div class="legal-footer">
        <span>Govt. of Uttar Pradesh e-Stamp: IN-UP84920481029482X • Issued: 06-Oct-2026 12:36 AM</span>
        <span>Page 6 of 7 &nbsp;|&nbsp; Executant Initials: [ MMT ] _____ &nbsp; [ PMT ] _____</span>
    </div>
</div>

<!-- ==========================================
     PAGE 7: SCHEDULE A (TECHNICAL SPECIFICATION)
     ========================================== -->
<div class="page-container">
    <div class="legal-header">
        <span>Master Software Development, IP & Ongoing Maintenance Agreement — Chinta Mani Library</span>
        <span>Deed Ref: CML/DEV/UP-SKN/2026/01</span>
    </div>

    <div class="text-center mb-3">
        <h2 class="text-[13px] font-bold text-[#0F2A1D] tracking-wide">SCHEDULE A</h2>
        <p class="text-[8.5px] italic text-gray-600">Detailed Feature and Technical Specification of the Software Ecosystem</p>
    </div>

    <table class="spec-table">
        <thead class="bg-[#E8EFEA] text-[#113824] font-bold">
            <tr>
                <th class="w-1/4">Module / Component</th>
                <th class="w-3/4">Technical Architecture & Functional Specification</th>
            </tr>
        </thead>
        <tbody>
            <tr>
                <td class="font-bold text-[#113824] align-top">
                    Part 1: Mobile App<br/>
                    <span class="text-[8.5px] font-normal text-gray-600">(Cross-Platform)</span>
                </td>
                <td class="text-[9.5px]">
                    <ul class="list-disc pl-4 space-y-0.5">
                        <li><b>Framework:</b> Flutter / Dart compiled into native Android release build.</li>
                        <li><b>OTA Updater Engine:</b> Background lifecycle resume observer & in-app auto-updater; checks cloud releases on startup and resume.</li>
                        <li><b>User Interface:</b> 4D Claymorphic luxury tactile design with gold glowing accents, custom cards and animated press states.</li>
                        <li><b>Authentication:</b> Biometric fingerprint/face auth + secure fallback PIN.</li>
                        <li><b>Offline Support:</b> Hive & SQLite offline caching ensuring dashboard accessibility during network dropouts.</li>
                        <li><b>Attribution:</b> Permanent 'Developed by Prashant Mani Tripathi' gold badge in Splash, Drawer, and About screens.</li>
                    </ul>
                </td>
            </tr>
            <tr>
                <td class="font-bold text-[#113824] align-top">
                    Part 2: Web Portal<br/>
                    <span class="text-[8.5px] font-normal text-gray-600">(Universal QR)</span>
                </td>
                <td class="text-[9.5px]">
                    <ul class="list-disc pl-4 space-y-0.5">
                        <li><b>Technology:</b> HTML5, Tailwind CSS, JavaScript mobile-first responsive architecture.</li>
                        <li><b>Self-Admission:</b> Direct student registration via branch QR scan.</li>
                        <li><b>Photo Upload:</b> Device storage/gallery picker with strict <b>5MB file size validation</b> and zero-copy multipart upload to Cloudinary (zero low-memory errors).</li>
                        <li><b>Attendance Engine:</b> Instant QR check-in / check-out with branch timestamps.</li>
                        <li><b>Branch Switcher:</b> Sliding branch switcher for Khalilabad and Mehdawal.</li>
                    </ul>
                </td>
            </tr>
            <tr>
                <td class="font-bold text-[#113824] align-top">
                    Part 3: Cloud Backend & Database
                </td>
                <td class="text-[9.5px]">
                    <ul class="list-disc pl-4 space-y-0.5">
                        <li><b>API Server:</b> NestJS / TypeScript REST services deployed on Render.com cloud infrastructure.</li>
                        <li><b>Database:</b> Neon PostgreSQL serverless relational database with automated daily backups.</li>
                        <li><b>Media Storage:</b> Cloudinary CDN with branch-isolated folder paths (<code>chintamani/mehdawal/</code> and <code>chintamani/khalilabad/</code>).</li>
                        <li><b>Security:</b> HTTPS SSL in transit, secret management via Render environment variables, role-based guard middleware.</li>
                    </ul>
                </td>
            </tr>
            <tr>
                <td class="font-bold text-[#113824] align-top">
                    Part 4: Dual-Branch Data Isolation
                </td>
                <td class="text-[9.5px]">
                    <ul class="list-disc pl-4 space-y-0.5">
                        <li><b>Branches at Go-Live:</b> Khalilabad Branch (72 Seats) and Mehdawal Branch (65 Seats).</li>
                        <li><b>Isolation Architecture:</b> Complete logical segregation of members, admissions, attendance, fees, seat matrix, and complaints per branch. Zero cross-branch data bleeding.</li>
                        <li><b>Future Branch Support:</b> Modular multi-branch database schema allowing seamless addition of new branches under Clause 5.6.</li>
                    </ul>
                </td>
            </tr>
            <tr>
                <td class="font-bold text-[#A62B2B] align-top">
                    Part 5: Out of Scope<br/>
                    <span class="text-[8.5px] font-normal text-gray-600">(Requires Separate SOW)</span>
                </td>
                <td class="text-[9.5px]">
                    <ul class="list-disc pl-4 space-y-0.5 text-gray-700">
                        <li>Native iOS App Store packaging (requires Apple Developer Program enrollment by Client).</li>
                        <li>External biometric hardware terminal integrations (fingerprint scanner turnstiles).</li>
                        <li>Multi-state white-label franchise multi-tenancy software redesign.</li>
                        <li>Custom accounting software / Tally integrations beyond standard CSV exports.</li>
                    </ul>
                </td>
            </tr>
        </tbody>
    </table>

    <div class="legal-footer">
        <span>Govt. of Uttar Pradesh e-Stamp: IN-UP84920481029482X • Issued: 06-Oct-2026 12:36 AM</span>
        <span>Page 7 of 7 &nbsp;|&nbsp; Executant Initials: [ MMT ] _____ &nbsp; [ PMT ] _____</span>
    </div>
</div>

</body>
</html>
"""

with open("ChintaMani_Library_Master_Software_eAgreement_Signed.html", "w", encoding="utf-8") as f:
    f.write(html_content)

print("Regenerated ChintaMani_Library_Master_Software_eAgreement_Signed.html successfully!")
