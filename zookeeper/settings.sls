{% set p  = salt['pillar.get']('zookeeper', {}) %}
{% set pc = p.get('config', {}) %}
{% set g  = salt['grains.get']('zookeeper', {}) %}
{% set gc = g.get('config', {}) %}

{%- set default_uid = '6030' %}
# these are global - hence pillar-only
{%- set uid          = p.get('uid', '6030') %}
{%- set userhome     = p.get('userhome', '/home/zookeeper') %}
{%- set prefix       = p.get('prefix', '/usr/lib') %}
{%- set java_home    = salt['grains.get']('java_home', salt['pillar.get']('java_home', '/usr/lib/java')) %}


{%- set log_level         = gc.get('log_level', pc.get('log_level', 'INFO')) %}
{%- set version           = g.get('version', p.get('version', '3.4.6')) %}
{%- set version_name      = 'zookeeper-' + version %}
{%- set default_url       = 'http://apache.osuosl.org/zookeeper/' + version_name + '/' + version_name + '.tar.gz' %}
{%- set source_url        = g.get('source_url', p.get('source_url', default_url)) %}
# bind_address is only supported as a grain, because it has to be host-specific
{%- set bind_address      = gc.get('bind_address', '0.0.0.0') %}
{%- set data_dir          = gc.get('data_dir', pc.get('data_dir', '/var/lib/zookeeper/data')) %}
{%- set port              = gc.get('port', pc.get('port', '2181')) %}
{%- set jmx_port          = gc.get('jmx_port', pc.get('jmx_port', '2183')) %}
{%- set snap_count        = gc.get('snap_count', pc.get('snap_count', None)) %}
{%- set snap_retain_count = gc.get('snap_retain_count', pc.get('snap_retain_count', 3)) %}
{%- set purge_interval    = gc.get('purge_interval', pc.get('purge_interval', None)) %}
{%- set max_client_cnxns  = gc.get('max_client_cnxns', pc.get('max_client_cnxns', None)) %}


#
# JVM options - just follow grains/pillar settings for now
#
# set in - zookeeper:
#          - config:
#            - max_perm_size:
#            - max_heap_size:
#            - initial_heap_size:
#            - jvm_opts:
#
{%- set max_perm_size     = gc.get('max_perm_size', pc.get('max_perm_size', 128)) %}
{%- set max_heap_size     = gc.get('max_heap_size', pc.get('max_heap_size', 1024)) %}
{%- set initial_heap_size = gc.get('initial_heap_size', pc.get('initial_heap_size', 256)) %}
{%- set jvm_opts          = gc.get('jvm_opts', pc.get('jvm_opts', None)) %}  

{%- set alt_config   = salt['grains.get']('zookeeper:config:directory', '/etc/zookeeper/conf') %}
{%- set real_config  = alt_config + '-' + version %}
{%- set alt_home     = prefix + '/zookeeper' %}
{%- set real_home    = alt_home + '-' + version %}
{%- set real_config_src  = real_home + '/conf' %}
{%- set real_config_dist = alt_config + '.dist' %}

{%- set force_mine_update = salt['mine.send']('network.get_hostname') %}
{%- set zookeepers_host_dict = salt['mine.get']('roles:zookeeper', 'network.get_hostname', 'grain') %}
{%- set zookeepers_ids = zookeepers_host_dict.keys() %}
{%- set zookeepers_hosts = zookeepers_host_dict.values() %}
{%- set zookeeper_host_num = zookeepers_ids | length() %}

{%- if zookeeper_host_num == 0 %}
# this will fail to even render but provide a hint as to what's wrong
{{ 'No zookeeper nodes are defined (you need to set roles:zookeeper at least for one node in your cluster' }}
{%- elif zookeeper_host_num is odd %}
# for 1, 3, 5 ... nodes just return the list
{%- set node_count = zookeeper_host_num %}
{%- elif zookeeper_host_num is even %}
# for 2, 4, 6 ... nodes return (n -1)
{%- set node_count = zookeeper_host_num - 1 %}
{%- endif %}

# yes, this is not pretty, but produces sth like:
# {'node1': '0+node1', 'node2': '1+node2', 'node3': '2+node2'}
{%- set zookeepers_with_ids = {} %}
{%- for i in range(node_count) %}
{%- do zookeepers_with_ids.update({zookeepers_ids[i] : '{0:d}'.format(i) + '+' + zookeepers_hosts[i] })  %}
{%- endfor %}

# a plain list of hostnames
{%- set zookeepers = zookeepers_with_ids.values() | sort() %}
# this is the 'safe bet' to use for just connection settings (backwards compatible)
{%- set zookeeper_host = (zookeepers | first()).split('+') | last() %}
# produce the connection string, sth. like: 'host1:2181,host2:2181,host3:2181'
{%- set connection_string = [] %}
{%- for n in zookeepers %}
{%- do connection_string.append( n.split('+') | last() + ':' + port | string ) %}
{% endfor %}

# return either the id of the host or an empty string
{%- set myid = zookeepers_with_ids.get(grains.id, '').split('+')|first() %}

{%- set zk = {} %}
{%- do zk.update( { 'uid': uid,
                           'version' : version,
                           'version_name': version_name,
                           'userhome' : userhome,
                           'source_url': source_url,
                           'myid': myid,
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
                           'snap_count': snap_count,
                           'snap_retain_count': snap_retain_count,
                           'purge_interval': purge_interval,
                           'max_client_cnxns': max_client_cnxns,
                           'myid_path': data_dir + '/myid',
                           'zookeeper_host' : zookeeper_host,
                           'zookeepers' : zookeepers,
                           'zookeepers_with_ids' : zookeepers_with_ids.values(),
                           'connection_string' : ','.join(connection_string),
                           'initial_heap_size': initial_heap_size,
                           'max_heap_size': max_heap_size,
                           'max_perm_size': max_perm_size,
                           'jvm_opts': jvm_opts,
                           'log_level': log_level,
                        }) %}
