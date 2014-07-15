{%- from 'zookeeper/settings.sls' import zk with context %}

/tmp/zookeeper.debug:
  file.managed:
    - contents: |
    {%- for k,v in zk.items() %}
        {{ k }} => {{ v }}
    {%- endfor %}