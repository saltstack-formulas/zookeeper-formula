{%- set all_roles    = salt['grains.get']('roles', []) %}
{%- if 'monitor' in all_roles %}

include:
  - jmxtrans

{%- if 'zookeeper' in all_roles %}
/etc/jmxtrans/json/zookeeper.json:
  file.managed:
    - mode: 644
    - source: salt://zookeeper/jmxtrans/zookeeper.json
    - template: jinja
{%- endif %}

{%- endif %}
