# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import zookeeper with context %}

zookeeper-dependency-install-pkg-installed:
  pkg.installed:
    - name: tar

zookeeper-archive-install-pkg-installed:
  archive.extracted:
    - name: {{ zookeeper.pkg.installdir }}/zookeeper-{{ zookeeper.pkg.version }}
    - source: {{ zookeeper.pkg.downloadurl }}
    - user: {{ zookeeper.systemdconfig.user }}
    - group: {{ zookeeper.systemdconfig.group }}
    - if_missing: {{ zookeeper.pkg.installdir }}/zookeeper-{{ zookeeper.pkg.version }}
    - skip_verify: True
    - keep_source: False
    - options: "--strip-components=1"
    - enforce_toplevel: False
    - require:
      - pkg: zookeeper-dependency-install-pkg-installed
