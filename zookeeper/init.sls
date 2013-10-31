{% set zookeeper_version   = salt['pillar.get']('zookeeper:version', '3.4.5') %}
{% set zookeeper_alt_home  = salt['pillar.get']('zookeeper:prefix', '/usr/lib/zookeeper') %}
{% set zookeeper_real_home = zookeeper_alt_home + '-' + zookeeper_version %}
{% set zookeeper_alt_conf  = salt['pillar.get']('zookeeper:config', '/etc/zookeeper') %}
{% set zookeeper_real_conf = zookeeper_alt_conf + '-' + zookeeper_version %}

{% set zookeeper_tgz = "zookeeper-" + zookeeper_version + ".tar.gz" %}
{% set zookeeper_tgz_path = '/tmp/' + zookeeper_tgz %}

zookeeper:
  group.present:
    - gid: {{ pillar.get('zookeeper_uid') }}
  user.present:
    - uid: {{ pillar.get('zookeeper_uid') }}
    - gid: {{ pillar.get('zookeeper_uid') }}

zk-directories:
  file.directory:
    - user: zookeeper
    - group: zookeeper
    - mode: 755
    - makedirs: True
    - names:
      - /var/run/zookeeper
      - /var/lib/zookeeper
      - /var/log/zookeeper

zookeeper-config-link:
  alternatives.install:
    - link: /etc/zookeeper/conf
    - path: {{ zookeeper_conf }}
    - priority: 30

# hopefully the tarball is on the master
{{ zookeeper_tgz_path }}:
  file.managed:
    - source: salt://zookeeper/files/{{ zookeeper_tgz }}

install-zookeeper-dist:
  cmd.run:
    - name: tar xzf {{ zookeeper_tgz_path }}
    - cwd: /usr/lib
    - unless: test -d {{ zookeeper_real_home }}/lib
    - require:
      - file.managed: {{ zookeeper_tgz_path }}
  alternatives.install:
    - name: zookeeper-home-link
    - link: {{ zookeeper_alt_home }}
    - path: {{ zookeeper_real_home }}
    - priority: 30
    - require:
      - cmd.run: install-zookeeper-dist

# /usr/lib/zookeeper-<version> needs to belong to root.root
{{ zookeeper_real_home }}:
  file.directory:
    - user: root
    - group: root
    - recurse:
      - user
      - group

