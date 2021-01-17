# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import zookeeper with context %}
{%- if zookeeper.pkg.javajdk %}
zookeeper-package-install-dependency-javajdk:
  pkg.installed:
    - name: {{ zookeeper.pkg.javajdk }}
{%- endif %}