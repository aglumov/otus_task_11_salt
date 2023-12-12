db:
  pkg.installed:
  - name: mariadb
  - pkgs:
    - mariadb-server
    - python3-pip
  - refresh: true

  service.running:
  - name: mariadb
  - require:
    - pkg: mariadb

  pip.installed:
  - name: pymysql

  file.replace:
  - name: "/etc/mysql/mariadb.conf.d/50-server.cnf"
  - pattern: "bind-address.*"
  - repl: "bind-address = 0.0.0.0"
  - watch_in:
    - service: mariadb

  mysql_database.present:
  - name: "{{ pillar['wp_db_name'] }}"

  mysql_user.present:
  - name: "{{ pillar['wp_db_user'] }}"
  - host: "192.168.0.0/255.255.0.0"
  - password: "{{ pillar['wp_db_pass'] }}"

  mysql_grants.present:
  - grant: "all privileges"
  - database: "{{ pillar['wp_db_user'] }}.*"
  - user: "{{ pillar['wp_db_user'] }}"
  - host: "192.168.0.0/255.255.0.0"
