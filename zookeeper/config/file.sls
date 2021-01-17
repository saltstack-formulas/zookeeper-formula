# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- set sls_package_install = tplroot ~ '.package.install' %}
{%- from tplroot ~ "/map.jinja" import zookeeper with context %}
{%- from tplroot ~ "/libtofs.jinja" import files_switch with context %}

include:
  - {{ sls_package_install }}

zookeeper-config-file-file-managed:
  file.managed:
    - name: {{ zookeeper.pkg.installdir }}/zookeeper-{{ zookeeper.pkg.version }}/conf/zoo.cfg
    - source: {{ files_switch(['zoo.tmpl.jinja'],
                              lookup='zookeeper-config-file-file-managed'
                 )
              }}
    - mode: 644
    - user: root
    - group: {{ zookeeper.rootgroup }}
    - makedirs: True
    - template: jinja
    - require:
      - sls: {{ sls_package_install }}
    - context:
        zookeeper: {{ zookeeper | json }}

{% if zookeeper.zookeeperproperties['customservers'] %}
zookeeper-zookeepermyid-file-file-managed:
  file.managed:
    - name: {{ zookeeper.pkg.installdir }}/zookeeper-{{ zookeeper.pkg.version }}/{{ zookeeper.zookeeperproperties.dataDir | regex_replace('[(.*?)]','') }}/myid
    - source: {{ files_switch(['zookeepermyid.tmpl.jinja'],
                              lookup='zookeeper-zookeepermyid-file-file-managed'
                 )
              }}
    - mode: 644
    - user: {{ zookeeper.systemdconfig.user }}
    - group: {{ zookeeper.systemdconfig.group }}
    - makedirs: True
    - template: jinja
    - require:
      - sls: {{ sls_package_install }}
    - context:
        zookeeper: {{ zookeeper | json }}

{% endif %}