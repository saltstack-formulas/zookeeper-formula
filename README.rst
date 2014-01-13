=========
zookeeper
=========

Formula to set up and configure a single-node zookeeper server.

.. note::

    See the full `Salt Formulas installation and usage instructions
    <http://docs.saltstack.com/topics/conventions/formulas.html>`_.

Available states
================

.. contents::
    :local:

Formula Dependencies
--------------------

* sun-java

``zookeeper``
-------------

Downloads the zookeeper tarball from zookeeper:source_url (either pillar or grain), installs the package.

``zookeeper.server``
--------------------

Installs the server configuration and enables and starts the zookeeper service.
Only works if 'zookeeper' is one of the roles (grains) of the node. This separation
allows for nodes to have the zookeeper libs and environment available without running the service.

Tested on RedHat/CentOS 5.X and 6.X, AmazonOS and Ubuntu.
