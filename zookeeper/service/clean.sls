# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import zookeeper with context %}

zookeeper-service-clean-service-dead:
  service.dead:
    - name: {{ zookeeper.service.name }}
    - enable: False
