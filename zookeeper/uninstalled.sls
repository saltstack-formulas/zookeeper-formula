{%- from 'zookeeper/settings.sls' import zk with context -%}
{%- from 'zookeeper/map.jinja' import zookeeper_map with context -%}

zookeeper-service-stopped:
  service.dead:
    - name: zookeeper
    - enable: False

zk-directories-removed:
  file.absent:
    - names:
      - /var/run/zookeeper
      - /var/lib/zookeeper
      - /var/log/zookeeper
      - {{ zk.real_home }}
      - {{ zk.alt_home }}
      - {{ zk.real_config }}
      - {{ zk.alt_config }}
      - {{ zk.systemd_unit }}
      - {{ zookeeper_map.service_script }}
    - require:
      - service: zookeeper-service-stopped
  
{%- if grains.get('systemd') %}
zookeeper-reload-systemctl:
  module.run:
    - name: service.systemctl_reload
    - onchanges:
      - file: {{ zk.systemd_unit }}
{%- endif %}
  
zookeeper-config-link-removed:
  alternatives.remove:
    - name: zookeeper-config-link
    - path: {{ zk.real_config }}

zookeeper-home-link-removed:
  alternatives.remove:
    - name: zookeeper-home-link
    - path: {{ zk.real_home }}
