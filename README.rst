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

``zookeeper.server``
--------------------

Installs the server configuration and enables and starts the zookeeper service.
Only works if 'zookeeper' is one of the roles (grains) of the node. This separation
allows for nodes to have the zookeeper libs and environment available without running the service.

Zookeeper Role and Client Connection String
===========================================

The implementation depends on the existence of the ``roles`` grain in your minion configuration -
at least one minion in your network has to have the **zookeeper** role which means that it is a
Zookeeper server.

You could assign the role with following command executed from your Master:

.. code:: console

  salt 'zk-node*' grains.append roles zookeeper

The formula gathers Zookeeper node addresses using `Salt Mine`_ by publishing the Minion host name
via ``network.get_hostname`` function to the Salt Master (this is a default behaviour).

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

.. note::

  Standalone Zookeeper server would be installed and configured by explicitly applying
  ``zookeeper.server`` state to the Minion without any roles assigned. But in this case the server
  will not appear in ``connection_string`` variable from ``zookeeper/settings.sls``.

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

``restart_on_config``
~~~~~~~~~~~~~~~~~~~~~

Restart the Zookeeper service on configuration change. It is recommended to set to True in a single server setup or when you initially deploy your emsemble. However, this is dangerous to allow to happen when deploying a configuration change to a running ensemble, as a rolling restart of each Zookeeper service is recommended.

.. code:: yaml

   zookeeper:
     restart_on_config: True

.. vim: fenc=utf-8 spell spl=en cc=100 tw=99 fo=want sts=2 sw=2 et
