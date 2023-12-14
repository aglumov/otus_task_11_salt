nginx:
  pkg.installed:
  - name: nginx
  - refresh: true
  service.running:
  - enable: True
  - require:
    - pkg: nginx
  - watch:
    - file: /etc/nginx/nginx.conf

/etc/nginx/nginx.conf:
  file.managed:
  - source: salt://nginx/nginx.conf
  - user: www-data
  - group: www-data
  - mode: 644
  - require:
    - pkg: nginx
