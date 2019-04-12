{%- from 'zookeeper/settings.sls' import zk with context -%}

zk-user-group:
  group.present:
    - name: {{ zk.group }}
    - gid: {{ zk.gid }}
  user.present:
    - name: {{ zk.user }}
    - home: {{ zk.userhome }}
    - uid: {{ zk.uid }}
    - gid: {{ zk.gid }}
    - require:
      - group: {{ zk.group }}

zk-directories:
  file.directory:
    - user: {{ zk.user }}
    - group: {{ zk.group }}
    - mode: 755
    - makedirs: True
    - names:
      - /var/run/zookeeper
      - /var/lib/zookeeper
      - /var/log/zookeeper

install-zookeeper:
  archive.extracted:
    - name: {{ zk.prefix }}
    - source: {{ zk.source_url }}
{%- if zk.source_md5 != "" %}
    - source_hash: md5={{ zk.source_md5 }}
{%- else %}
    - skip_verify: True
{%- endif %}
    - archive_format: tar
    - if_missing: {{ zk.real_home }}/lib
    - user: {{ zk.user }}
    - group: {{ zk.group }}
    
zookeeper-home-link:
  file.symlink:
    - name: {{ zk.alt_home }}
    - target: {{ zk.real_home }}
    - require:
      - archive: install-zookeeper
