{%- set default_uid = '6030' %}
{%- set userhome = '/home/zookeeper' %}
{%- set uid = salt['pillar.get']('zookeeper:uid', default_uid) %}
# the version and source can either come out of a grain, the pillar or end up the default (currently 1.5.0 and the apache backup mirror)
{%- set pillar_version = salt['pillar.get']('zookeeper:version', '3.4.5') %}
{%- set version        = salt['grains.get']('zookeeper:version', pillar_version) %}
{%- set version_name   = 'zookeeper-' + version %}
{%- set default_url  = 'http://www.us.apache.org/dist/zookeeper/' + version_name + '/' + version_name + '.tar.gz' %}
{%- set pillar_source_url = salt['pillar.get']('zookeeper:source_url', default_url) %}
{%- set source_url   = salt['grains.get']('zookeeper:source_url', pillar_source_url) %}
{%- set prefix = salt['pillar.get']('zookeeper:prefix', '/usr/lib/zookeeper') %}
{%- set alt_config = salt['pillar.get']('zookeeper:config:directory', '/etc/zookeeper/conf') %}
{%- set real_config = alt_config + '-' + version %}
{%- set alt_home  = salt['pillar.get']('zookeeper:prefix', '/usr/lib/zookeeper') %}
{%- set real_home = alt_home + '-' + version %}
{%- set real_config_src = real_home + '/conf' %}
{%- set real_config_dist = alt_config + '.dist' %}
{%- set java_home = salt['pillar.get']('java_home', '/usr/lib/java') %}
{%- set port = salt['pillar.get']('zookeeper:port', '2181') %}
{%- set jmx_port = salt['pillar.get']('zookeeper:jmx_port', '2183') %}
{%- set pillar_bind_address = salt['pillar.get']('zookeeper:bind_address', '0.0.0.0') %}
{%- set pillar_data_dir  = salt['pillar.get']('zookeeper:data_dir', '/var/lib/zookeeper/data') %}
{%- set bind_address = salt['grains.get']('zookeeper:bind_address', pillar_bind_address) %}
{%- set data_dir  = salt['grains.get']('zookeeper:data_dir', pillar_data_dir) %}

{%- set zookeeper_host = salt['mine.get']('roles:zookeeper', 'network.interfaces', 'grain').keys()|first() %}

{%- set zk = {} %}
{%- do zk.update( { 'uid': uid,
                           'version' : version,
                           'version_name': version_name,
                           'userhome' : userhome,
                           'source_url': source_url,
                           'prefix' : prefix,
                           'alt_config' : alt_config,
                           'real_config' : real_config,
                           'alt_home' : alt_home,
                           'real_home' : real_home,
                           'real_config_src' : real_config_src,
                           'real_config_dist' : real_config_dist,
                           'java_home' : java_home,
                           'port': port,
                           'jmx_port': jmx_port,
                           'bind_address': bind_address,
                           'data_dir': data_dir,
                           'zookeeper_host' : zookeeper_host
                        }) %}
