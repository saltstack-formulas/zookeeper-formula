{% set version   = salt['pillar.get']('zookeeper:version', '3.4.5') %}
{% set java_home           = salt['pillar.get']('java_home', '/usr/lib/java') %}
{% set alt_home  = salt['pillar.get']('zookeeper:prefix', '/usr/lib/zookeeper') %}
{% set real_home = alt_home + '-' + version %}
{% set alt_conf  = '/etc/zookeeper/conf' %}
{% set real_conf = alt_conf + '-' + version %}
{% set port = salt['pillar.get']('zookeeper:uid', '2181') %}
{% set bind_address = salt['pillar.get']('zookeeper:bind_address', '0.0.0.0') %}
{% set data_dir  = salt['pillar.get']('zookeeper:data_dir', '/var/lib/zookeeper/data') %}

{% from "zookeeper/map.jinja" import zookeeper_map with context %}

include:
  - zookeeper

/etc/zookeeper:
  file.directory:
    - user: root
    - group: root

{{ data_dir }}:
  file.directory:
    - user: zookeeper
    - group: zookeeper
    - makedirs: True

move-zookeeper-dist-conf:
  cmd.run:
    - name: mv {{ real_home }}/conf {{ real_conf }}
    - unless: test -L {{ real_home }}/conf
    - require:
      - file.directory: {{ real_home }}
      - file.directory: /etc/zookeeper

zookeeper-config-link:
  alternatives.install:
    - link: {{ alt_conf }}
    - path: {{ real_conf }}
    - priority: 30

{{ real_home }}/conf:
  file.symlink:
    - target: {{ real_conf }}
    - require:
      - cmd: move-zookeeper-dist-conf

{{ real_conf }}/zoo.cfg:
  file.managed:
    - source: salt://zookeeper/zoo.cfg.jinja
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - context:
      port: {{ port }}
      bind_address: {{ bind_address }}
      data_dir: {{ data_dir }}

{{ real_conf }}/zookeeper-env.sh:
  file.managed:
    - source: salt://zookeeper/zookeeper-env.sh.jinja
    - user: root
    - group: root
    - mode: 755
    - template: jinja
    - context:
      java_home: {{ java_home }}

{% if zookeeper_map.service_script %}

{{ zookeeper_map.service_script }}:
  file.managed:
    - source: salt://zookeeper/{{ zookeeper_map.service_script_source }}
    - user: root
    - group: root
    - mode: {{ zookeeper_map.service_script_mode }}
    - template: jinja
    - context:
      alt_home: {{ alt_home }}

zookeeper-service:
  service.running:
    - name: zookeeper
    - enable: true
    - require:
      - file.directory: {{ data_dir }}

{% endif %}


