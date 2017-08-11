{%- from 'zookeeper/settings.sls' import zk with context -%}

zoo-cfg:
  file.managed:
    - name: {{ zk.real_config }}/zoo.cfg
    - source: salt://zookeeper/conf/zoo.cfg
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - context:
      port: {{ zk.port }}
      quorum_port: {{ zk.quorum_port }}
      election_port: {{ zk.election_port }}
      bind_address: {{ zk.bind_address }}
      data_dir: {{ zk.data_dir }}
      snap_count: {{ zk.snap_count }}
      snap_retain_count: {{ zk.snap_retain_count }}
      purge_interval: {{ zk.purge_interval }}
      max_client_cnxns: {{ zk.max_client_cnxns }}
      zookeepers: {{ zk.zookeepers_with_ids }}

id-file:
  file.managed:
    - name: {{ zk.myid_path }}
    - user: zookeeper
    - group: zookeeper
    - contents: |
        {{ zk.myid }}

