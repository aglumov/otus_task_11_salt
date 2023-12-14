wordpress:
  pkg.installed:
  - name: php-fpm
  - pkgs:
    - php-fpm
    - php-mysql
    - unzip
  - refresh: true

  service.running:
  - name: php8.1-fpm
  - enable: true
  - require:
    - pkg: php-fpm
  - watch:
    - file: /etc/php/8.1/fpm/php.ini

  file.replace:
  - name: "/etc/php/8.1/fpm/php.ini"
  - pattern: "^[;]*cgi.fix_pathinfo.*"
  - repl: "cgi.fix_pathinfo=0"

/etc/nginx/conf.d/wp.conf:
  file.managed:
  - source: salt://wordpress/wp.conf
  - user: www-data
  - group: www-data
  - mode: 644
  - require:
    - pkg: nginx
  - watch_in:
    - service: nginx

/var/www:
  archive.extracted:
  - source: https://wordpress.org/latest.zip
  - user: www-data
  - group: www-data
  - use_etag: true

/var/www/wordpress/wp-config.php:
  file.managed:
  - source: salt://wordpress/wp-config.php
  - user: www-data
  - group: www-data
  - mode: 644
  - template: jinja
  - require:
    - archive: /var/www
