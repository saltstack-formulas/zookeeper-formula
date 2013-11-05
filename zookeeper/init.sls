{%- set version     = salt['pillar.get']('zookeeper:version', '3.4.5') %}
{%- set alt_home    = salt['pillar.get']('zookeeper:prefix', '/usr/lib/zookeeper') %}
{%- set source      = salt['pillar.get']('zookeeper:source', None) %}
{%- set source_hash = salt['pillar.get']('zookeeper:source_hash', None) %}
{%- set real_home = alt_home + '-' + version %}
{%- set uid = salt['pillar.get']('zookeeper:uid', '6030') %}
{%- set tgz = "zookeeper-" + version + ".tar.gz" %}
{%- set tgz_path = '/tmp/' + tgz %}

zookeeper:
  group.present:
    - gid: {{ uid }}
  user.present:
    - uid: {{ uid }}
    - gid: {{ uid }}

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


{{ tgz_path }}:
  file.managed:
{%- if source %}
    - source: {{ source }}
    - source_hash: {{ source_hash }}
{%- else %}
    - source: salt://zookeeper/files/{{ tgz }}
{% endif %}

install-zookeeper-dist:
  cmd.run:
    - name: tar xzf {{ tgz_path }}
    - cwd: /usr/lib
    - unless: test -d {{ real_home }}/lib
    - require:
      - file.managed: {{ tgz_path }}
  alternatives.install:
    - name: zookeeper-home-link
    - link: {{ alt_home }}
    - path: {{ real_home }}
    - priority: 30
    - require:
      - cmd.run: install-zookeeper-dist

# fix permissions
{{ real_home }}:
  file.directory:
    - user: root
    - group: root
    - recurse:
      - user
      - group

