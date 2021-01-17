# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- set sls_config_file = tplroot ~ '.config.file' %}
{%- from tplroot ~ "/map.jinja" import zookeeper with context %}
{%- from tplroot ~ "/libtofs.jinja" import files_switch with context %}

include:
  - {{ sls_config_file }}

zookeeper-systemd-file-file-managed:
  file.managed:
    - name: /etc/systemd/system/zookeeper.service
    - source: {{ files_switch(['systemd.tmpl.jinja'],
                              lookup='zookeeper-systemd-file-file-managed'
                 )
              }}
    - mode: 644
    - user: root
    - group: root
    - makedirs: True
    - template: jinja
    - require:
      - sls: {{ sls_config_file }}
    - context:
        zookeeper: {{ zookeeper | json }}

zookeeper-service-running-service-running:
  service.running:
    - name: {{ zookeeper.service.name }}
    - enable: True
    - watch:
      - sls: {{ sls_config_file }}


