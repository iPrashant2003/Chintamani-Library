"""
Portal selfie + registration data integrity fix.
1. Replace previewImage() to compress images via canvas
2. Store compressed base64 in a global variable (not localStorage)
3. Include photoUrl/aadhaarFrontUrl/aadhaarBackUrl in submitRegistration POST body
4. Remove large base64 data from localStorage.setItem to prevent "storage is low" error
"""

with open('docs/index.html', 'r', encoding='utf-8') as f:
    content = f.read()

# ── Fix 1: Replace previewImage to compress + store globally ──
OLD_PREVIEW = '''function previewImage(input, boxId) {
      if (input.files && input.files[0]) {
        const reader = new FileReader();
        reader.onload = function(e) {
          const box = document.getElementById(boxId);
          box.innerHTML = `<img src="${e.target.result}" class="w-full h-28 object-cover rounded-lg border border-gold-500/40">`;
        };
        reader.readAsDataURL(input.files[0]);
      }
    }'''

NEW_PREVIEW = '''// Compressed image store (keyed by boxId)
    const _imgStore = {};

    function previewImage(input, boxId) {
      if (!input.files || !input.files[0]) return;
      const file = input.files[0];
      const reader = new FileReader();
      reader.onload = function(e) {
        const orig = e.target.result;
        // Compress via canvas: max 800px wide, JPEG quality 0.72
        const img = new Image();
        img.onload = function() {
          try {
            const MAX_W = 800;
            const scale = img.width > MAX_W ? MAX_W / img.width : 1;
            const w = Math.round(img.width * scale);
            const h = Math.round(img.height * scale);
            const canvas = document.createElement('canvas');
            canvas.width = w; canvas.height = h;
            const ctx = canvas.getContext('2d');
            ctx.drawImage(img, 0, 0, w, h);
            const compressed = canvas.toDataURL('image/jpeg', 0.72);
            _imgStore[boxId] = compressed;
            const box = document.getElementById(boxId);
            if (box) box.innerHTML = `<img src="${compressed}" class="w-full h-28 object-cover rounded-lg border border-gold-500/40">`;
          } catch (_) {
            // canvas fallback: use original but only for preview, not upload
            _imgStore[boxId] = orig.length < 500000 ? orig : null;
            const box = document.getElementById(boxId);
            if (box) box.innerHTML = `<img src="${orig}" class="w-full h-28 object-cover rounded-lg border border-gold-500/40">`;
          }
        };
        img.src = orig;
      };
      reader.readAsDataURL(file);
    }'''

if OLD_PREVIEW in content:
    content = content.replace(OLD_PREVIEW, NEW_PREVIEW)
    print("previewImage fixed ✓")
else:
    print("WARNING: previewImage not found — may have different whitespace")

# ── Fix 2: Replace submitRegistration to include photo fields and fix localStorage ──
OLD_REG_BODY = '''      // Persist local registration context
      localStorage.setItem('cml_student_record', JSON.stringify({
        name,
        phone,
        branch: currentViewingBranch,
        branchName: branchConfig.name,
        seatNumber: selectedSeatNumber,
        applicationId: appId,
        timestamp: Date.now()
      }));

      try {
        await fetch('/portal/register', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            name,
            phone,
            email: document.getElementById('reg-email').value.trim(),
            parentName: document.getElementById('reg-parent').value.trim(),
            dob: document.getElementById('reg-dob').value,
            address: document.getElementById('reg-address').value.trim(),
            gender: document.getElementById('reg-gender').value,
            planId: selectedPlanCode,
            batch: timing,
            branch: currentViewingBranch,
            branchId: currentViewingBranch,
            seatNumber: selectedSeatNumber,
          })
        });
      } catch (_) {}'''

NEW_REG_BODY = '''      // Persist local registration context (without large image blobs to avoid storage quota errors)
      try {
        localStorage.setItem('cml_student_record', JSON.stringify({
          name,
          phone,
          branch: currentViewingBranch,
          branchName: branchConfig.name,
          seatNumber: selectedSeatNumber,
          applicationId: appId,
          timestamp: Date.now()
        }));
      } catch (_) { /* localStorage quota exceeded — non-critical, skip */ }

      // Gather compressed image data (stored by previewImage())
      const photoData = _imgStore['preview-selfie-box'] || null;
      const aadhaarFrontData = _imgStore['preview-aadhaar-front-box'] || null;
      const aadhaarBackData = _imgStore['preview-aadhaar-back-box'] || null;

      try {
        const regPayload = {
          name,
          phone,
          email: (document.getElementById('reg-email')?.value || '').trim(),
          dob: document.getElementById('reg-dob')?.value || '',
          address: (document.getElementById('reg-address')?.value || '').trim(),
          gender: document.getElementById('reg-gender')?.value || '',
          aadhaarNumber: (document.getElementById('reg-aadhaar')?.value || '').replace(/\\s/g, ''),
          emergencyContact: (document.getElementById('reg-emergency')?.value || '').trim(),
          batch: timing,
          course: (document.getElementById('reg-course')?.value || '').trim(),
          institute: (document.getElementById('reg-institute')?.value || '').trim(),
          occupation: (document.getElementById('reg-occupation')?.value || '').trim(),
          planId: selectedPlanCode,
          branch: currentViewingBranch,
          branchId: currentViewingBranch,
          seatNumber: selectedSeatNumber,
          // Image data (compressed JPEG base64 or null)
          photoUrl: photoData,
          aadhaarFrontUrl: aadhaarFrontData,
          aadhaarBackUrl: aadhaarBackData,
        };
        await fetch('/portal/register', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(regPayload)
        });
      } catch (_) {}'''

if OLD_REG_BODY in content:
    content = content.replace(OLD_REG_BODY, NEW_REG_BODY)
    print("submitRegistration body fixed ✓")
else:
    print("WARNING: OLD_REG_BODY not found in content")
    # Try to find what's there
    idx = content.find('cml_student_record')
    if idx > -1:
        print("Found cml_student_record at:", idx)
        print(content[idx-50:idx+400])

# ── Fix 3: Check aadhaar input IDs exist in the form ──
# The form has reg-aadhaar but verify
has_aadhaar = 'reg-aadhaar' in content
has_emergency = 'reg-emergency' in content
print(f"reg-aadhaar exists: {has_aadhaar}")
print(f"reg-emergency exists: {has_emergency}")

# ── Save ──
with open('docs/index.html', 'w', encoding='utf-8', newline='') as f:
    f.write(content)
print("Saved ✓")
