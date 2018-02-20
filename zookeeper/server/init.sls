{%- from 'zookeeper/map.jinja' import zookeeper_map with context -%}
{%- from 'zookeeper/settings.sls' import zk with context -%}

include:
  - zookeeper
  - zookeeper.config

move-zookeeper-dist-conf:
  cmd.run:
    - name: mv {{ zk.real_home }}/conf {{ zk.real_config }}
    - unless: test -L {{ zk.real_home }}/conf
    - require:
      - file: /etc/zookeeper

zookeeper-config-link:
  file.symlink:
    - name: {{ zk.alt_config }}
    - target: {{ zk.real_config }}
      
zookeeper-config-dir:
  file.symlink:
    - name: {{ zk.real_home }}/conf
    - target: {{ zk.real_config }}
    - require:
      - cmd: move-zookeeper-dist-conf

{%- if zk.process_control_system is defined %}

  {%- if zk.restart_on_change %}

zookeeper-in-supervisord:
  cmd.run:
    - name: "{{ zk.pcs_restart_command }}"
    - require:
      - pkg: {{ zk.process_control_system }}
    - onchanges:
       - file: {{ zk.real_config }}/zoo.cfg

  {%- endif %}

{%- else %}

zookeeper-env.sh:
  file.managed:
    - name: {{ zk.real_config }}/zookeeper-env.sh
    - source: salt://zookeeper/templates/zookeeper-env.sh.j2
    - user: root
    - group: root
    - mode: 755
    - template: jinja
    - context:
      initial_heap_size: {{ zk.initial_heap_size }}
      java_home: "{{ zk.java_home }}"
      jmx_port: {{ zk.jmx_port }}
      jvm_opts: "{{ zk.jvm_opts }}"
      log_level: {{ zk.log_level }}
      max_heap_size: {{ zk.max_heap_size }}
      max_perm_size: {{ zk.max_perm_size }}

zookeeper-service:
  {%- if not zk.distro_install %}
    {%- if grains.get('systemd') %}
  # provision systemd service unit
  file.managed:
    - name: {{ zk.systemd_unit }}
    - source: salt://zookeeper/templates/zookeeper.service.j2
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - context:
      alt_home: {{ zk.alt_home }}
  module.wait:
    - name: service.systemctl_reload
    - watch:
      - file: zookeeper-service
    - watch_in:
      - service: zookeeper-service
    {%- elif zookeeper_map.service_script %}
  # provision System V init script
  file.managed:
    - name: {{ zookeeper_map.service_script }}
    - source: salt://zookeeper/conf/{{ zookeeper_map.service_script_source }}
    - user: root
    - group: root
    - mode: {{ zookeeper_map.service_script_mode }}
    - template: jinja
    - context:
      alt_home: {{ zk.alt_home }}
    - watch_in:
      - service: zookeeper-service
    {%- endif %}
  {%- else %}
  service.running:
    - name: zookeeper
    - enable: True
    - require:
      - file: zookeeper-data-dir
    {%- if zk.restart_on_change %}
    - watch:
    {%- endif %}
      - file: zoo-cfg
      - file: zookeeper-env.sh

  {%- endif %}
{%- endif %}
