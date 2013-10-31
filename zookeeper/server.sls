{% set zookeeper_version   = salt['pillar.get']('zookeeper:version', '3.4.5') %}
{% set zookeeper_alt_home  = salt['pillar.get']('zookeeper:prefix', '/usr/lib/zookeeper') %}
{% set zookeeper_real_home = zookeeper_alt_home + '-' + zookeeper_version %}
{% set zookeeper_alt_conf  = '/etc/zookeeper/conf' %}
{% set zookeeper_real_conf = zookeeper_alt_conf + '-' + zookeeper_version %}

{% from "zookeeper/map.jinja" import zookeeper_map with context %}

include:
  - zookeeper

/etc/zookeeper:
  file.directory:
    - user: root
    - group: root

move-zookeeper-dist-conf:
  cmd.run:
    - name: mv {{ zookeeper_real_home }}/conf {{ zookeeper_real_conf }}
    - unless: test -L {{ zookeeper_real_home }}/conf
    - require:
      - file.directory: {{ zookeeper_real_home }}
      - file.directory: /etc/zookeeper

zookeeper-config-link:
  alternatives.install:
    - link: {{ zookeeper_alt_conf }}
    - path: {{ zookeeper_real_conf }}
    - priority: 30

{{ zookeeper_real_home }}/conf:
  file.symlink:
    - target: {{ zookeeper_real_conf }}
    - require:
      - cmd: move-zookeeper-dist-conf

{{ zookeeper_real_conf }}/zoo.cfg:
  file.managed:
    - source: salt://zookeeper/zoo.cfg.jinja
    - user: root
    - group: root
    - mode: 644
    - template: jinja

{{ zookeeper_real_conf }}/zookeeper-env.sh:
  file.managed:
    - source: salt://zookeeper/zookeeper-env.sh.jinja
    - user: root
    - group: root
    - mode: 755
    - template: jinja

{% if salt['pillar.get']('zookeeper:service_script') %}

{{ salt['pillar.get']('zookeeper:service_script') }}:
  file.managed:
    - source: salt://zookeeper/salt/(( ['pillar.get']('zookeeper:service_script_source') }}
    - user: root
    - group: root
    - mode: {{ salt['pillar.get']('zookeeper:service_script_mode') }}
    - template: jinja

zookeeper:
  service.running:
    - enable: true

{% endif %}


