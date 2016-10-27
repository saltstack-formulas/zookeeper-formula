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

install-zookeeper-dist:
  file.managed:
    - name: /usr/local/src/{{ zk.version_name }}.tar.gz
    - source: {{ zk.source_url }}
{%- if zk.source_md5 != "" %}
    - source_hash: md5={{ zk.source_md5 }}
{%- else %}
    - skip_verify: True
{%- endif %}
  cmd.run:
    - name: tar xzf /usr/local/src/{{ zk.version_name }}.tar.gz --no-same-owner
    - cwd: {{ zk.prefix }}
    - unless: test -d {{ zk.real_home }}/lib
    - runas: root
    - require:
      - file: install-zookeeper-dist
  alternatives.install:
    - name: zookeeper-home-link
    - link: {{ zk.alt_home }}
    - path: {{ zk.real_home }}
    - priority: 30
    - require:
      - cmd: install-zookeeper-dist
