#!/usr/bin/env bash
set -euo pipefail
python3 - <<'PY'
lf = lh = 0
cur = None
missing = []
for l in open('coverage/lcov.info'):
    if l.startswith('SF:'): cur = l[3:].strip()
    elif l.startswith('LF:'): lf += int(l[3:])
    elif l.startswith('LH:'): lh += int(l[3:])
    elif l.startswith('DA:'):
        n, c = l[3:].split(',')
        if int(c) == 0:
            missing.append(f'{cur}:{n}')
assert lf > 0 and lh == lf, f'coverage {lh}/{lf} < 100%: ' + ' '.join(missing)
print(f'coverage {lh}/{lf}')
PY
