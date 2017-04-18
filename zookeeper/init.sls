{%- from 'zookeeper/settings.sls' import zk with context -%}

zookeeper:
  group.present:
    - gid: {{ zk.uid }}
  user.present:
    - uid: {{ zk.uid }}
    - gid: {{ zk.uid }}

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
    - user: root
    - group: root
    
zookeeper-home-link:
  alternatives.install:
    - link: {{ zk.alt_home }}
    - path: {{ zk.real_home }}
    - onlyif: test -d {{ zk.real_home }} && test ! -L {{ zk.alt_home }}
    - priority: 30
    - require:
      - archive: install-zookeeper
  file.symlink:
    - name: {{ zk.alt_home }}
    - target: {{ zk.real_home }}
    - require:
      - alternatives: zookeeper-home-link
