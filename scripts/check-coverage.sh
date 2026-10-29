#!/usr/bin/env bash
set -euo pipefail
python3 - <<'PY'
lf = lh = 0
for l in open('coverage/lcov.info'):
    if l.startswith('LF:'): lf += int(l[3:])
    if l.startswith('LH:'): lh += int(l[3:])
assert lf > 0 and lh == lf, f'coverage {lh}/{lf} < 100%'
print(f'coverage {lh}/{lf}')
PY
