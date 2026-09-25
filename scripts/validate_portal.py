with open('docs/index.html', 'r', encoding='utf-8') as f:
    content = f.read()

checks = [
    ('style block', '  <style>' in content and '  </style>' in content),
    ('ambient bg', 'portal-ambient-bg' in content),
    ('logo glow ring', 'logo-glow-ring' in content),
    ('live-dot class', 'live-dot' in content),
    ('branch slider thumb', 'branch-slider-thumb' in content),
    ('view-landing section', 'id="view-landing"' in content),
    ('service cards 6', content.count('svc-card') >= 6),
    ('view-register', 'id="view-register"' in content),
    ('view-payment', 'id="view-payment"' in content),
    ('view-feedback', 'id="view-feedback"' in content),
    ('view-complaint', 'id="view-complaint"' in content),
    ('view-contact', 'id="view-contact"' in content),
    ('view-attendance', 'id="view-attendance"' in content),
    ('switchPortalBranch fn', 'function switchPortalBranch' in content),
    ('submitRegistration fn', 'function submitRegistration' in content),
    ('submitPortalAttendance fn', 'function submitPortalAttendance' in content),
    ('BRANCH_CONFIG', 'BRANCH_CONFIG' in content),
    ('DOMContentLoaded', 'DOMContentLoaded' in content),
    ('bg-photo-mehdawal', 'bg-photo-mehdawal' in content),
    ('bg-photo-khalilabad', 'bg-photo-khalilabad' in content),
    ('seat-desk-selected', 'seat-desk-selected' in content),
    ('glass-field class', '.glass-field' in content),
    ('btn-gold class', '.btn-gold' in content),
]

all_ok = True
for label, result in checks:
    status = 'OK' if result else 'FAIL'
    if not result:
        all_ok = False
    print(f'  [{status}] {label}')

print()
print('Total file size:', len(content), 'chars')
print('All checks passed:', all_ok)
