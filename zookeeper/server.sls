# Include :download:`map file <map.jinja>` of OS-specific package names and
# file paths. Values can be overridden using Pillar.
{% from "zookeeper/map.jinja" import zookeeper with context %}

include:
  - zookeeper

move-zookeeper-dist-conf:
  cmd.run:
    - name: mv {{ zookeeper_real_home }}/conf {{ zookeeper_real_conf }}
    - unless: test -L {{ zookeeper_real_home }}/conf
    - require:
      - file.directory: {{ zookeeper_real_home }}

{{ zookeeper_real_conf }}:
  file.directory:
    - user: root
    - group: root
    - mode: 755
    - makedirs: True

{{ zookeeper_real_home }}/conf:
  file.symlink:
    - target: {{ zookeeper_conf }}
    - require:
      - cmd: move-zookeeper-dist-conf

{{ zookeeper_real_conf }}/zoo.cfg:
  file.managed:
    - source: salt://zookeeper/zoo.cfg
    - user: root
    - group: root
    - mode: 644
    - template: jinja

{{ zookeeper_real_conf }}/zookeeper-env.sh:
  file.managed:
    - source: salt://zookeeper/zookeeper-env.sh
    - user: root
    - group: root
    - mode: 755


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


