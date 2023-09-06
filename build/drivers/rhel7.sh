function pre_build() {
  yum -y update
  yum -y install e2fsprogs git libaio numactl-libs openssl unixODBC unzip
  mkdir -p /opt/tableau/tableau_driver/jdbc
}

function post_build() {
  find . -name '*.jar' -type f -exec cp {} /opt/tableau/tableau_driver/jdbc \;
  find /opt/tableau/tableau_driver/jdbc -name '*.jar' -type f -exec chmod 0755 {} \;
  ls -l /opt/tableau/tableau_driver/jdbc
  cat /etc/odbcinst.ini
  rm -rf /tmp/*
}

function amazon_athena() {
  :
}

function amazon_emr_hadoop_hive() {
  yum -y localinstall ./amazon_emr_hadoop_hive.rpm
  odbcinst -i -d -f /opt/amazon/hiveodbc/Setup/odbcinst.ini
  grep -n -F '[Amazon Hive ODBC Driver 64-bit]' /etc/odbcinst.ini
  [ -f /opt/amazon/hiveodbc/lib/64/libamazonhiveodbc64.so ]
}

function amazon_redshift() {
  yum -y --nogpgcheck localinstall ./amazon_redshift.rpm
  odbcinst -i -d -f /opt/amazon/redshiftodbc/Setup/odbcinst.ini
  grep -n -F '[Amazon Redshift (x64)]' /etc/odbcinst.ini
  [ -f /opt/amazon/redshiftodbc/lib/64/libamazonredshiftodbc64.so ]
}

function cloudera_hive() {
  yum -y localinstall ./cloudera_hive.rpm
  odbcinst -i -d -f /opt/cloudera/hiveodbc/Setup/odbcinst.ini
  grep -n -F '[Cloudera ODBC Driver for Apache Hive 64-bit]' /etc/odbcinst.ini
  [ -f /opt/cloudera/hiveodbc/lib/64/libclouderahiveodbc64.so ]
}

function cloudera_impala() {
  yum -y localinstall ./cloudera_impala.rpm
  odbcinst -i -d -f /opt/cloudera/impalaodbc/Setup/odbcinst.ini
  grep -n -F '[Cloudera ODBC Driver for Impala 64-bit]' /etc/odbcinst.ini
  cat /opt/cloudera/impalaodbc/Setup/odbcinst.ini
  [ -f /opt/cloudera/impalaodbc/lib/64/libclouderaimpalaodbc64.so ]
}

function datorama() {
  :
}

function dremio() {
  :
}

function esri() {
  :
}

function exasol() {
  mkdir -p /opt/exasol
  mkdir -p /tmp/exasol
  tar -xvzf ./exasol.tar.gz --directory /tmp/exasol --strip-components=1
  cp -R /tmp/exasol/lib/linux/x86_64/. /opt/exasol
  cat <<EOF >>/tmp/exasol/odbcinst.ini
[EXASolution Driver]
Driver=/opt/exasol/libexaodbc-uo2214lv2.so
EOF
  odbcinst -i -d -f /tmp/exasol/odbcinst.ini
  grep -n -F '[EXASolution Driver]' /etc/odbcinst.ini
  [ -f /opt/exasol/libexaodbc-uo2214lv2.so ]
}

function firebolt() {
  :
}

function google_bigquery() {
  :
}

function hortonworks_hive() {
  yum -y localinstall ./hortonworks_hive.rpm
  odbcinst -i -d -f /usr/lib/hive/lib/native/hiveodbc/Setup/odbcinst.ini
  grep -n -F '[Hortonworks Hive ODBC Driver 64-bit]' /etc/odbcinst.ini
  [ -f /usr/lib/hive/lib/native/Linux-amd64-64/libhortonworkshiveodbc64.so ]
}

function ibm_db2() {
  mkdir -p /opt/ibm_db2
  mkdir -p /tmp/ibm_db2
  tar -xvzf ./ibm_db2.tar.gz --directory /opt/ibm_db2 --strip-components=2
  cat <<EOF >>/tmp/ibm_db2/odbcinst.ini
[IBM DB2 ODBC DRIVER]
Description=DB2 Driver
Driver=/opt/ibm_db2/lib/libdb2.so
EOF
  odbcinst -i -d -f /tmp/ibm_db2/odbcinst.ini
  grep -n -F '[IBM DB2 ODBC DRIVER]' /etc/odbcinst.ini
  [ -f /opt/ibm_db2/lib/libdb2.so ]
}

function jaybird() {
  :
}

function mapr_drill() {
  yum -y localinstall ./mapr_drill.rpm
  odbcinst -i -d -f /opt/mapr/drill/Setup/odbcinst.ini
  sed -i 's/librdrillodbc_sb64.so/libdrillodbc_sb64.so/' /etc/odbcinst.ini
  grep -n -F '[MapR Drill ODBC Driver 64-bit]' /etc/odbcinst.ini
  [ -f /opt/mapr/drill/lib/64/libdrillodbc_sb64.so ]
}

function mariadb() {
  mkdir -p /opt/mariadb
  mkdir -p /tmp/mariadb
  tar -xvzf ./mariadb.tar.gz --directory /tmp/mariadb
  install /tmp/mariadb/lib64/libmaodbc.so /usr/lib64/
  install -d /usr/lib64/mariadb/
  install -d /usr/lib64/mariadb/plugin/
  install /tmp/mariadb/lib64/mariadb/plugin/* /usr/lib64/mariadb/plugin/
  cat <<EOF >>/tmp/mariadb/odbcinst.ini
[MariaDB ODBC 3.0 Driver]
Description=MariaDB Connector/ODBC v.3.0
Driver=/usr/lib64/libmaodbc.so
EOF
  odbcinst -i -d -f /tmp/mariadb/odbcinst.ini
  grep -n -F '[MariaDB ODBC 3.0 Driver]' /etc/odbcinst.ini
  [ -f /usr/lib64/libmaodbc.so ]
}

function microsoft_sharepoint_lists() {
  mkdir -p /tmp/microsoft_sharepoint_lists
  yum -y localinstall ./microsoft_sharepoint_lists.rpm
  cat <<EOF >>/tmp/microsoft_sharepoint_lists/odbcinst.ini
[CData ODBC Driver for SharePoint]
Description=CData ODBC Driver for SharePoint
Driver=/opt/cdata/cdata-odbc-driver-for-sharepoint/lib/libsharepointodbc.x64.so
EOF
  odbcinst -i -d -f /tmp/microsoft_sharepoint_lists/odbcinst.ini
  grep -n -F '[CData ODBC Driver for SharePoint]' /etc/odbcinst.ini
  [ -f /opt/cdata/cdata-odbc-driver-for-sharepoint/lib/libsharepointodbc.x64.so ]
}

function microsoft_sql_server() {
  cp ./microsoft-rhel7.repo /etc/yum.repos.d/microsoft-rhel7.repo
  ACCEPT_EULA=Y yum -y install msodbcsql17-17.10.2.1-1
  grep -n -F '[ODBC Driver 17 for SQL Server]' /etc/odbcinst.ini
  [ -f /opt/microsoft/msodbcsql17/lib64/libmsodbcsql-17.10.so.2.1 ]
}

function mysql() {
  yum -y localinstall ./mysql.rpm
  yum -y install mysql-connector-odbc-8.0.32-1.el7
  grep -n -F '[MySQL ODBC 8.0 ANSI Driver]' /etc/odbcinst.ini
  grep -n -F '[MySQL ODBC 8.0 Unicode Driver]' /etc/odbcinst.ini
  [ -f /usr/lib64/libmyodbc8a.so ]
  [ -f /usr/lib64/libmyodbc8w.so ]
}

function odps() {
  :
}

function oracle() {
  :
}

function oracle_essbase() {
  yum -y localinstall ./oracle_essbase.rpm
  [ -f /opt/tableau/tableau_driver/essbase/bin/libessapinu.so ]
}

function oracle_netsuite() {
  :
}

function postgresql() {
  :
}

function qubole() {
  :
}

function salesforce_cdp() {
  :
}

function salesforce_marketing_cloud() {
  :
}

function sap_hana() {
  :
}

function sap_success_factors() {
  :
}

function service_now() {
  :
}

function simba_spark() {
  yum -y localinstall ./simba_spark.rpm
  odbcinst -i -d -f /opt/simba/spark/Setup/odbcinst.ini
  grep -n -F '[Simba Spark ODBC Driver 64-bit]' /etc/odbcinst.ini
  cat /opt/simba/spark/Setup/odbcinst.ini
  [ -f /opt/simba/spark/lib/64/libsparkodbc_sb64.so ]
}

function singlestore() {
  mkdir -p /opt/singlestore
  mkdir -p /tmp/singlestore
  tar -xvzf ./singlestore.tar.gz --directory /opt/singlestore --strip-components=1
  cat <<EOF >>/tmp/singlestore/odbcinsta.ini
[SingleStore ODBC ANSI Driver]
Description=SingleStore ODBC ANSI Driver
Driver=/opt/singlestore/libssodbca.so
EOF
  cat <<EOF >>/tmp/singlestore/odbcinstw.ini
[SingleStore ODBC Unicode Driver]
Description=SingleStore ODBC Unicode Driver
Driver=/opt/singlestore/libssodbcw.so
EOF
  odbcinst -i -d -f /tmp/singlestore/odbcinsta.ini
  odbcinst -i -d -f /tmp/singlestore/odbcinstw.ini
  grep -n -F '[SingleStore ODBC ANSI Driver]' /etc/odbcinst.ini
  grep -n -F '[SingleStore ODBC Unicode Driver]' /etc/odbcinst.ini
  [ -f /opt/singlestore/libssodbca.so ]
  [ -f /opt/singlestore/libssodbcw.so ]
}

function snowflake() {
  yum -y localinstall ./snowflake.rpm
  grep -n -F '[SnowflakeDSIIDriver]' /etc/odbcinst.ini
  [ -f /usr/lib64/snowflake/odbc/lib/libSnowflake.so ]
}

function teradata() {
  mkdir -p /tmp/teradata
  tar -xvzf ./teradata.tar.gz --directory /tmp/teradata --strip-components=1
  pushd /tmp/teradata
  ./setup_wrapper.sh -s -i /opt -r tdodbc1620-16.20.00.127-1.noarch.rpm
  popd
  odbcinst -i -d -f /opt/teradata/client/ODBC_64/odbcinst.ini
  grep -n -F '[Teradata Database ODBC Driver 16.20]' /etc/odbcinst.ini
  [ -f /opt/teradata/client/ODBC_64/lib/tdataodbc_sb64.so ]
}

function trino() {
  :
}

function vertica() {
  mkdir -p /tmp/vertica
  yum -y localinstall ./vertica.rpm
  cat <<EOF >>/etc/vertica.ini
[Driver]
DriverManagerEncoding=UTF-16
ODBCInstLib=/usr/lib64/libodbcinst.so
ErrorMessagesPath=/opt/vertica
LogLevel=4
LogPath=/tmp
EOF
  cat <<EOF >>/tmp/vertica/odbcinst.ini
[Vertica]
Description=Vertica ODBC Driver
Driver=/opt/vertica/lib64/libverticaodbc.so
EOF
  odbcinst -i -d -f /tmp/vertica/odbcinst.ini
  grep -n -F '[Vertica]' /etc/odbcinst.ini
  [ -f /opt/vertica/lib64/libverticaodbc.so ]
}
