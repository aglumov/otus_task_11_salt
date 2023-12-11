/etc/nginx/conf.d/lb.conf:
  file.managed:
    - source: salt://upstreams/upstreams.conf
    - user: www-data
    - group: www-data
    - mode: 644
    - template: jinja
    - require:
      - pkg: nginx
    - watch_in:
      - service: nginx
