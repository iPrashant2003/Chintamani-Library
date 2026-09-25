import re
with open('docs/index.html', 'r', encoding='utf-8') as f:
    content = f.read()
reg_start = content.find('id="view-register"')
reg_end = content.find('id="view-payment"')
reg_section = content[reg_start:reg_end]
ids = re.findall(r'id="(reg-[^"]+)"', reg_section)
print('Registration form IDs:')
for i in sorted(set(ids)):
    print(' ', i)
