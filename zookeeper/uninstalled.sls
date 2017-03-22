{%- from 'zookeeper/settings.sls' import zk with context -%}
{%- from 'zookeeper/map.jinja' import zookeeper_map with context -%}

zk-directories-removed:
  file.absent:
    - names:
      - /var/run/zookeeper
      - /var/lib/zookeeper
      - /var/log/zookeeper
      - {{ zk.real_home }}
      - {{ zk.alt_home }}
      - /etc/init.d/zookeeper
      - {{ zk.real_config }}
      - {{ zk.alt_config }}
      - {{ zk.systemd_unit }}
      - {{ zookeeper_map.service_script }}
      
zookeeper-config-link-remove:
  alternatives.remove:
    - path: {{ zk.real_config }}

zookeeper-home-link-remove:
  alternatives.remove:
    - name: zookeeper-home-link
    - path: {{ zk.real_home }}
