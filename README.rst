=========
zookeeper
=========

Formula to set up and configure a single-node Zookeeper server or multi-node Zookeeper cluster.

.. note::

    See the full `Salt Formulas installation and usage instructions
    <http://docs.saltstack.com/en/latest/topics/development/conventions/formulas.html>`_.

Formula Dependencies
====================

* sun-java

Available states
================

.. contents::
    :local:

``zookeeper``
-------------

Downloads the zookeeper tarball from ``zookeeper:source_url`` (either Pillar or Grain), installs
the package.

``zookeeper.config``
--------------------

Sets up zookeeper configuration. Composable with packaging not built into this formula. 

``zookeeper.server``
--------------------

Installs the server configuration and enables and starts the Zookeeper service. Only works if
either ``zookeeper`` is one of the roles (set via Grains) of the node or the node is listed in 
``zookeeper:nodes`` (in either Grains or Pillar). This separation allows for nodes to have the 
Zookeeper libs and environment available without running the service.

``zookeeper.uninstalled``
--------------------

Uninstalls the Zookeeper and disables and stops the Zookeeper service.

Zookeeper Role and Client Connection String
===========================================

Deploying a Cluster
-------------------

The implementation depends on the existence of the ``roles`` grain in your minion configuration -
at least one minion in your network has to have the **zookeeper** role which means that it is a
Zookeeper server.

You could assign the role with following command executed from your Salt Master:

.. code:: console

  salt 'zk-node*' grains.append roles zookeeper

The formula gathers Zookeeper node addresses using `Salt Mine`_ by publishing the Minion host name
via ``network.get_hostname`` function to the Salt Master (this is a default behaviour).
In case you want to provide the list on nodes in pillar or deploy several zookeeper clusters you 
can use ``zookeeper:nodes`` or ``zookeeper.clusters`` parameters (see below). In this case you 
don't need to use Zookeeper roles. 

This will allow you to use the ``zookeeper.settings`` state in other states to configure clients -
the result of calling:

.. code:: yaml

  {%- from 'zookeeper/settings.sls' import zk with context -%}

  /etc/somefile.conf:
   file.managed:
     - source: salt://some-formula/files/something.xml
     - user: root
     - group: root
     - mode: 644
     - template: jinja
     - context:
       zookeepers: {{ zk.connection_string }}

``zk.connection_string`` variable contains a string that reflects the names and ports of the hosts
with the ``zookeeper`` role in the cluster, like

::

  host1.mycluster.net:2181,host2.mycluster.net:2181,host3.mycluster.net:2181

And this will also work for single-node configurations. Whenever you have more than 2 hosts with
the ``zookeeper`` role the formula will setup a Zookeeper cluster, whenever there is an even number
it will be (number - 1).

In case when more than one Zookeeper cluster are deployed clients are required to specify 
``zookeeper:cluster_id`` parameter (via Grains or Pillar). Clients don't need to use 
``zookeeper:cluster_id`` parameter if they are presented on the same host with one of Zookeeper 
nodes. For example:

.. code:: yaml

  zookeeper:
    clusters:
      cluster1:
        - 192.168.0.101
        - 192.168.0.102
        - 192.168.0.103
      cluster2:
        - 192.168.1.101
        - 192.168.1.102
        - 192.168.1.103

If Zookeeper client is presented on the host ``192.168.1.104`` and they want to get a 
``connection_string`` to the second cluster, they must set up ``zookeeper:cluster_id`` parameter. 
For example, via grains:

::

  salt 'zk-cluster2-clients*' grains.set zookeeper:cluster_id cluster2

If clients (for example, NameNodes of HDFS) are presented on the same machines (i.e. 
``192.168.0.101``, ``192.168.0.102``, etc.) then they don't need to specify 
``zookeeper:cluster_id`` parameter.

Standalone Independent Server
-----------------------------

Standalone Zookeeper server would be installed and configured by explicitly applying
``zookeeper.server`` state to the Minion without any roles assigned. But in this case the server
will not appear in the ``connection_string`` variable from ``zookeeper/settings.sls``.

To be able to get a proper connection string like described above with only one Zookeeper server
running independently, set the following Pillar:

.. code:: yaml

  zookeeper:
    hosts_target: "{{ grains['id'] }}"
    targeting_method: 'glob'

This configures a single-node Zookeeper cluster on a machine which is able to read the Pillar from
above, and allows to get proper value from the ``connection_string`` to configure client apps.

Also, you may want to bind Zookeeper to the particular network address or localhost. Set the Grain
like this on your minion before applying ``zookeeper.server`` state:

.. code:: console

  salt zookeper.example.com grains.set zookeeper:config:bind_address 127.0.0.1

Customisations in Pillar or Grains
----------------------------------

``hosts_function``
~~~~~~~~~~~~~~~~~~

It is possible to extract other data than Minions hostname, such as IP addresses, to provision a
cluster and produce the connection string for configuring clients.

For example, to setup a cluster working on second network interface create following Pillar SLS
file:

.. code:: yaml

  # pillar/zookeeper/init.sls

  mine_functions:
   network.ip_addrs:
     interface: eth1

  # This also could be configured in the Grains for a Minion
  zookeeper:
    hosts_function: network.ip_addrs

And apply this SLS to your Zookeeper cluster in the Pillar ``top.sls`` file:

.. code:: yaml

  # pillar/top.sls

  base:
   'roles:zookeeper':
     - match: grain
     - zookeeper

After this, ``zoo.cfg`` file and client connection string will contain the *first* IP address
assigned to ``eth1`` network interface for each node in the cluster.

``hosts_target``
~~~~~~~~~~~~~~~~

This key used in conjunction with the one below, ``targeting_method``. It defines how Salt Master
recognize certain Minions as Zookeeper cluster members. By default, `Grain targeting`_ implied to
get all nodes with ``roles:zookeeper`` value set. Any other Grain or even pattern could be used
here. It is very useful if you have multiple independent clusters operating in your environment
provisioned by single Salt Master.

See examples in the next section for the details.

``targeting_method``
~~~~~~~~~~~~~~~~~~~~

Set matching type for ``hosts_target`` key. Supported values are: ``grain`` (default), ``glob``
and ``compound``.

**Examples**:

`Grain targeting`_ for *myapp* cluster by ``node_type``:

.. code:: yaml

  # pillar/zookeeper/init.sls
  zookeeper:
    hosts_target: node_type:myapp_zk

Simple `Glob targeting`_ by Minion ID:

.. code:: yaml

  zookeeper:
    hosts_target: zk-node*
    targeting_method: glob

Target only some of Minions with particular Grain using `Compound matcher`_:

.. code:: yaml

  zookeeper:
    hosts_target: mycluster-node* and G@zookeeper:*
    targeting_method: compound

.. _`Salt Mine`: https://docs.saltstack.com/en/latest/topics/mine/index.html
.. _`Grain targeting`: https://docs.saltstack.com/en/latest/topics/targeting/grains.html
.. _`Glob targeting`: https://docs.saltstack.com/en/latest/topics/targeting/globbing.html#globbing
.. _`Compound matcher`: https://docs.saltstack.com/en/latest/topics/targeting/compound.html

``nodes``
~~~~~~~~~~~~~~~~~~~~

If you want to provide your own list of zookeeper nodes you can use ``nodes`` parameter. In this 
case targeting method and ``clusters`` parameter will not be used.

As a node identifier you can use hostname, IP address, fqdn, minion id.
You cannot use an IP address of the proxy server which redirects requests to the zookeeper node.
You can use hostname of the proxy server which redirects requests to the zookeeper node only if
zookeeper node has the same hostname as the proxy does.

**Examples**:

IP addresses usage:

.. code:: yaml

  zookeeper:
    nodes:
      - 192.168.0.101
      - 192.168.0.102
      - 192.168.0.103

Minion id usage:

.. code:: yaml

  zookeeper:
    nodes:
      - minion1
      - minion2
      - minion3

Mixed usage (IP, minion id, fqdn):

.. code:: yaml

  zookeeper:
    nodes:
      - 192.168.0.101
      - minion2
      - zookeeper3.mysite.com

``clusters``
~~~~~~~~~~~~~~~~~~~~

In case you need several separate Zookeeper clusters you can use ``zookeeper:clusters`` parameter 
where you can specify a node list for each of your cluster. 
In this case targeting method will not be used.

As a node identifier you can use hostname, IP address, fqdn, minion id.
You cannot use an IP address of the proxy server which redirects requests to the zookeeper node.
You can use hostname of the proxy server which redirects requests to the zookeeper node only if
zookeeper node has the same hostname as the proxy does.
You cannot use the same minion for two different clusters.

**Examples**:

IP addresses usage:

.. code:: yaml

  zookeeper:
    clusters:
      cluster1:
        - 192.168.0.101
        - 192.168.0.102
        - 192.168.0.103
      cluster2:
        - 192.168.1.101
        - 192.168.1.102
        - 192.168.1.103
        
Fqdn usage:

.. code:: yaml

  zookeeper:
    clusters:
      cluster1:
        - zookeeper1.cluster1.mysite.com
        - zookeeper2.cluster1.mysite.com
        - zookeeper3.cluster1.mysite.com
      cluster2:
        - zookeeper1.cluster2.mysite.com
        - zookeeper2.cluster2.mysite.com
        - zookeeper3.cluster2.mysite.com

Mixed usage (IP, hostname, fqdn):

.. code:: yaml

  zookeeper:
    clusters:
      cluster1:
        - 192.168.0.101
        - minion2
        - zookeeper3.cluster1.mysite.com
      cluster2:
        - 192.168.1.101
        - minion-hostname5
        - zookeeper3.cluster2.mysite.com

``restart_on_config``
~~~~~~~~~~~~~~~~~~~~~

Restart the Zookeeper service on configuration change. It is recommended to set to True in a single server setup or when you initially deploy your emsemble. However, this is dangerous to allow to happen when deploying a configuration change to a running ensemble, as a rolling restart of each Zookeeper service is recommended.

.. code:: yaml

   zookeeper:
     restart_on_config: True

.. vim: fenc=utf-8 spell spl=en cc=100 tw=99 fo=want sts=2 sw=2 et


Testing
=======

Running the tests locally

```
bundle install
./tests/run.sh
```
