=========
zookeeper
=========

Formula to set up and configure a single-node zookeeper server.

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

Downloads the zookeeper tarball from zookeeper:source_url (either pillar or grain), installs the package.

``zookeeper.server``
--------------------

Installs the server configuration and enables and starts the zookeeper service.
Only works if 'zookeeper' is one of the roles (grains) of the node. This separation
allows for nodes to have the zookeeper libs and environment available without running the service.

Zookeeper role and Salt Minion Configuration
============================================

The implementation depends on the existence of the _roles_ grain in your minion configuration - at least
one minion in your network has to have the *zookeeper* role which means that it is a zookeeper server. 

For this to work it is necessary to setup salt mine like below in /etc/salt/minion.d/mine_functions.conf:

::

    mine_functions:
      network.get_hostname: []
      grains.items: []


This will allow you to use the zookeeper.settings state in other states to configure clients - the result of calling

::

    {%- from 'zookeeper/settings.sls' import zk with context %}

    /etc/somefile.conf:
      file.managed:
        - source: salt://some-formula/files/something.xml
        - user: root
        - group: root
        - mode: 644
        - template: jinja
        - context:
          zookeepers: {{ zk.connection_string }}

is a string that reflects the names and ports of the hosts with the zookeeper role in the cluster, like

::

    host1.mycluster.net:2181,host2.mycluster.net:2181,host3.mycluster.net:2181

and this will also work for single-node configurations. Whenever you have more than 2 hosts with the zookeeper role the formula will setup
a zookeeper cluster, whenever there is an even number it will be (number - 1).

