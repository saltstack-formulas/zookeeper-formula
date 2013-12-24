export ZOO_LOG_DIR=/var/log/zookeeper
export ZOOPIDFILE=/var/run/zookeeper/zookeeper-server.pid
export JAVA_HOME={{ java_home }}
export SERVER_JVMFLAGS="-Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false -Djava.rmi.server.hostname=127.0.0.1 -Dcom.sun.management.jmxremote.port={{ jmx_port }}"
