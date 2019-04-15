{%- set p  = salt['pillar.get']('zookeeper', {}) %}
{%- set pc = p.get('config', {}) %}
{%- set g  = salt['grains.get']('zookeeper', {}) %}
{%- set gc = g.get('config', {}) %}

{%- set java_home         = salt['grains.get']('java_home', salt['pillar.get']('java_home', '/usr/lib/java')) %}

# these are global - hence pillar-only
{%- set uid               = p.get('uid', '6030') %}
{%- set gid               = p.get('gid', '6030') %}
{%- set user              = p.get('user', 'zookeeper') %}
{%- set group             = p.get('group', 'zookeeper') %}
{%- set userhome          = p.get('userhome', '/home/' + user ) %}
{%- set prefix            = p.get('prefix', '/usr/lib') %}

{%- set version           = g.get('version', p.get('version', '3.4.6')) %}
{%- set version_name      = 'zookeeper-' + version %}
{%- set default_url       = 'https://archive.apache.org/dist/zookeeper/{0}/{0}.tar.gz'.format(version_name) %}
{%- set source_url        = g.get('source_url', p.get('source_url', default_url)) %}
{%- set default_md5s = {
  "3.4.6": "971c379ba65714fd25dc5fe8f14e9ad1",
  "3.4.7": "58b515d1c1352e135d17c9a9a9ffedd0",
  "3.4.8": "6bdddcd5179e9c259ef2bf4be2158d18",
  "3.4.9": "3e8506075212c2d41030d874fcc9dcd2",
  "3.4.10": "e4cf1b1593ca870bf1c7a75188f09678"
  }
%}

{%- set source_md5       = p.get('source_md5', default_md5s.get(version, '00000000000000000000000000000000')) %}

# This tells the state whether or not to restart the service on configuration change
{%- set restart_on_change = p.get('restart_on_config', 'True') %}

# This settings used if process_control_system set to true
{%- set process_control_system = p.get('process_control_system', False) %}
{%- set pcs_restart_command = p.get('pcs_restart_command', 'supervisorctl restart zookeeper') %}

# bind_address is only supported as a grain, because it has to be host-specific
{%- set bind_address      = gc.get('bind_address', '') %}

{%- set data_dir          = gc.get('data_dir', pc.get('data_dir', '/var/lib/zookeeper/data')) %}
{%- set port              = gc.get('port', pc.get('port', '2181')) %}
{%- set quorum_port       = gc.get('quorum_port', pc.get('quorum_port', '2888')) %}
{%- set election_port     = gc.get('election_port', pc.get('election_port', '3888')) %}
{%- set jmx_port          = gc.get('jmx_port', pc.get('jmx_port', '2183')) %}
{%- set snap_count        = gc.get('snap_count', pc.get('snap_count', None)) %}
{%- set snap_retain_count = gc.get('snap_retain_count', pc.get('snap_retain_count', 3)) %}
{%- set purge_interval    = gc.get('purge_interval', pc.get('purge_interval', None)) %}
{%- set max_client_cnxns  = gc.get('max_client_cnxns', pc.get('max_client_cnxns', None)) %}
{%- set log_level         = gc.get('log_level', pc.get('log_level', 'INFO')) %}
{%- set systemd_unit      = pc.get('systemd_unit', '/etc/systemd/system/zookeeper.service') %}
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
{%- set max_perm_size        = gc.get('max_perm_size', pc.get('max_perm_size', 128)) %}
{%- set max_heap_size        = gc.get('max_heap_size', pc.get('max_heap_size', 1024)) %}
{%- set initial_heap_size    = gc.get('initial_heap_size', pc.get('initial_heap_size', 256)) %}
{%- set jvm_opts             = gc.get('jvm_opts', pc.get('jvm_opts', '')) %}

{%- set alt_config           = gc.get('directory', pc.get('alt_config', '/etc/zookeeper/conf')) %}
{%- set real_config          = alt_config + '-' + version %}
{%- set alt_home             = prefix + '/zookeeper' %}
{%- set real_home            = alt_home + '-' + version %}
{%- set real_config_src      = real_home + '/conf' %}
{%- set real_config_dist     = alt_config + '.dist' %}

{%- set hosts_function       = g.get('hosts_function', p.get('hosts_function', 'network.get_hostname')) %}
{%- set hosts_target         = g.get('hosts_target', p.get('hosts_target', 'roles:zookeeper')) %}
{%- set targeting_method     = g.get('targeting_method', p.get('targeting_method', 'grain')) %}

{%- set cluster_id           = g.get('cluster_id', p.get('cluster_id', None)) %}
{%- set zookeepers_with_ids  = [] %}
{%- set zookeepers           = [] %}
{%- set myid_dist            = [] %}
{%- set connection_string    = [] %}
{%- set minion_ids           = [salt['network.get_hostname'](),
                                grains['id'],
                                grains['fqdn'],
                                grains['nodename']] + salt['network.ip_addrs']() %}

{%- if p.get('nodes') %}
  {%- set zookeeper_nodes = p.nodes %}
{%- elif p.get('clusters') and cluster_id != None %}
  {%- set zookeeper_nodes = p.clusters.get(cluster_id, []) %}
{%- elif p.get('clusters') %}
  {%- if p.clusters|length == 1 %}
    {%- set zookeeper_nodes = p.clusters.values()[0] %}
  {%- else %}
    {%- set zookeeper_nodes = [] %}
    {%- for cluster, nodes in p.clusters|dictsort %}
      {%- for node in nodes %}
        {%- if node in minion_ids %}
          {%- do zookeeper_nodes.extend(nodes) %}
          {%- break %}
        {%- endif %}
      {%- endfor %}
      {%- if zookeeper_nodes %} 
        {%- break %}
      {%- endif %}
    {%- endfor %}
  {%- endif %}
{%- else %}
  {%- set force_mine_update = salt['mine.send'](hosts_function) %}
  {%- set zookeepers_mined  = salt['mine.get'](hosts_target,
                                               hosts_function,
                                               targeting_method)|
                                               default({}, true) %}
  {%- set zookeeper_nodes   = zookeepers_mined.values()|sort %}
{%- endif %}

{%- for node in zookeeper_nodes %}
  {%- set node_id = loop.index %}
  {%- set zookeeper_with_id = {"id": node_id, "address": node.encode('ascii')} %}
  {%- do zookeepers_with_ids.append(zookeeper_with_id) %}
  {%- do connection_string.append( node.encode('ascii') + ':' + port | string() ) %}
  {%- do zookeepers.append( node.encode('ascii') ) %}
  {%- if not myid_dist and node in minion_ids %}
    {%- do myid_dist.append(node_id) %}
  {%- endif %}
{%- endfor %}

{%- if myid_dist|length > 0 %}
  {%- set myid = myid_dist[0] %}
{%- else %}
  {%- set myid = None %}
{%- endif %}

{%- set zk = {} %}
{%- do zk.update( { 'uid': uid,
                    'gid': gid,
                    'user': user,
                    'group': group,
                    'version' : version,
                    'version_name': version_name,
                    'userhome' : userhome,
                    'source_url': source_url,
                    'source_md5': source_md5,
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
                    'quorum_port': quorum_port,
                    'election_port': election_port,
                    'jmx_port': jmx_port,
                    'bind_address': bind_address,
                    'data_dir': data_dir,
                    'snap_count': snap_count,
                    'snap_retain_count': snap_retain_count,
                    'purge_interval': purge_interval,
                    'max_client_cnxns': max_client_cnxns,
                    'myid_path': data_dir + '/myid',
                    'zookeepers' : zookeepers,
                    'zookeepers_with_ids' : zookeepers_with_ids,
                    'connection_string' : ','.join(connection_string),
                    'initial_heap_size': initial_heap_size,
                    'max_heap_size': max_heap_size,
                    'max_perm_size': max_perm_size,
                    'jvm_opts': jvm_opts,
                    'log_level': log_level,
                    'systemd_unit': systemd_unit,
                    'process_control_system': process_control_system,
                    'pcs_restart_command': pcs_restart_command,
                    'restart_on_change': restart_on_change,
                  } ) %}
