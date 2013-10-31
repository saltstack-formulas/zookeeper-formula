===
zookeeper
===

Formula to set up and configure a single-node zookeeper server.

.. note::

    See the full `Salt Formulas installation and usage instructions
    <http://docs.saltstack.com/topics/conventions/formulas.html>`_.

Available states
================

.. contents::
    :local:

``zookeeper``
-------

Downloads the zookeeper tarball from the master (must exist as zookeeper/files/zookeeper-<version>.tar.gz), installs the package.

``zookeeper.server``
--------------

Installs the server configuration and starts the zookeeper server.

Requires RedHat/CentOS 5.X or RedHat/CentOS 6.X.
