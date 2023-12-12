base:
  'lb*':
  - nginx
  - upstreams
  'app*':
  - nginx
  - wordpress
  'db*':
  - database
  master:
  - pull_formulas
