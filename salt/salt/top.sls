base:
  'lb*':
  - nginx
  - upstreams
  'app*':
  - nginx
  - wordpress
  'db*':
  - database
