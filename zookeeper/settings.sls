{% set p  = salt['pillar.get']('zookeeper', {}) %}
{% set pc = p.get('config', {}) %}
{% set g  = salt['grains.get']('zookeeper', {}) %}
{% set gc = g.get('config', {}) %}

{%- set default_uid = '6030' %}
# these are global - hence pillar-only
{%- set uid          = p.get('uid', '6030') %}
{%- set userhome     = p.get('userhome', '/home/zookeeper') %}
{%- set prefix       = p.get('prefix', '/usr/lib/zookeeper') %}
{%- set java_home    = salt['pillar.get']('java_home', '/usr/lib/java') %}

{%- set version      = g.get('version', p.get('version', '3.4.5')) %}
{%- set version_name = 'zookeeper-' + version %}
{%- set default_url  = 'http://apache.osuosl.org/zookeeper/' + version_name + '/' + version_name + '.tar.gz' %}
{%- set source_url   = g.get('source_url', p.get('source_url', default_url)) %}
{%- set bind_address = gc.get('bind_address', pc.get('bind_address', '0.0.0.0')) %}
{%- set data_dir     = gc.get('data_dir', pc.get('data_dir', '/var/lib/zookeeper/data')) %}
{%- set port         = gc.get('port', pc.get('port', '2181')) %}
{%- set jmx_port     = gc.get('jmx_port', pc.get('jmx_port', '2183')) %}

{%- set alt_config   = salt['grains.get']('zookeeper:config:directory', '/etc/zookeeper/conf') %}
{%- set real_config  = alt_config + '-' + version %}
{%- set alt_home     = prefix %}
{%- set real_home    = alt_home + '-' + version %}
{%- set real_config_src  = real_home + '/conf' %}
{%- set real_config_dist = alt_config + '.dist' %}

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
                           'zookeeper_host' : zookeeper_host,
                           'connection_string' : zookeeper_host + ':' + port,
                        }) %}
