function amazon_athena() {
  curl --location --remote-name https://s3.amazonaws.com/athena-downloads/drivers/JDBC/SimbaAthenaJDBC-2.0.32.1000/AthenaJDBC42.jar
}

function amazon_emr_hadoop_hive() {
  curl --location --output amazon_emr_hadoop_hive.zip http://awssupportdatasvcs.com/bootstrap-actions/Simba/AmazonHiveODBC-2.6.9.1009.zip
  unzip amazon_emr_hadoop_hive.zip -d ./tmp/amazon_emr_hadoop_hive
  cp ./tmp/amazon_emr_hadoop_hive/AmazonHiveODBC-2.6.9.1009/AmazonHiveODBC-2.6.9.1009-1.x86_64.rpm ./amazon_emr_hadoop_hive.rpm
  rm -rf ./tmp/amazon_emr_hadoop_hive
  rm amazon_emr_hadoop_hive.zip
}

function amazon_redshift() {
  curl --location --output amazon_redshift.rpm https://s3.amazonaws.com/redshift-downloads/drivers/odbc/1.4.56.1000/AmazonRedshiftODBC-64-bit-1.4.56.1000-1.x86_64.rpm
}

function cloudera_hive() {
  curl --location --output cloudera_hive.zip https://downloads.cloudera.com/connectors/ClouderaHive_ODBC_2.6.13.1013.zip
  unzip cloudera_hive.zip -d ./tmp/cloudera_hive
  cp ./tmp/cloudera_hive/ClouderaHive_ODBC_2.6.13.1013/Linux/ClouderaHiveODBC-2.6.13.1013-1.x86_64.rpm cloudera_hive.rpm
  rm -rf ./tmp/cloudera_hive
  rm cloudera_hive.zip
}

function cloudera_impala() {
  curl --location --output cloudera_impala.zip https://downloads.cloudera.com/connectors/impala_odbc_2.6.14.1016.zip
  unzip cloudera_impala.zip -d ./tmp/cloudera_impala
  cp ./tmp/cloudera_impala/impala_odbc_2.6.14.1016/Linux/ClouderaImpalaODBC-2.6.14.1016-1.x86_64.rpm cloudera_impala.rpm
  rm -rf ./tmp/cloudera_impala
  rm cloudera_impala.zip
}

function datorama() {
  curl --location --remote-name https://galleryapi.tableau.com/productfiles/181/datorama-jdbc-1.0.7-jar-with-dependencies.jar
}

function dremio() {
  curl --location --remote-name https://download.dremio.com/jdbc-driver/20.1.0-202202061055110045-36733c65/dremio-jdbc-driver-20.1.0-202202061055110045-36733c65.jar
}

function exasol() {
  curl --location --output exasol.tar.gz https://www.exasol.com/support/secure/attachment/225287/EXASOL_ODBC-7.1.14.tar.gz
}

function firebolt() {
  curl --location --remote-name https://github.com/firebolt-db/jdbc/releases/download/v2.2.3/firebolt-jdbc-2.2.3.jar
}

function google_bigquery() {
  curl --location --output google_bigquery.zip https://storage.googleapis.com/simba-bq-release/jdbc/SimbaJDBCDriverforGoogleBigQuery42_1.3.0.1001.zip
  unzip google_bigquery.zip -d ./tmp/google_bigquery
  cp ./tmp/google_bigquery/GoogleBigQueryJDBC42.jar .
  rm -rf ./tmp/google_bigquery
  rm google_bigquery.zip
}

function hortonworks_hive() {
  echo "not implemented: user action is required in https://www.cloudera.com/downloads/hdp.html"
  exit 1
}

function ibm_db2() {
  curl --location --output ibm_db2.tar.gz https://downloads.tableau.com/drivers/db2/v11.1.3fp3a_linuxx64_odbc_cli.tar.gz
}

function jaybird() {
  curl --location --output jaybird.zip https://github.com/FirebirdSQL/jaybird/releases/download/v3.0.12/Jaybird-3.0.12-JDK_1.8.zip
  unzip jaybird.zip -d ./tmp/jaybird
  cp ./tmp/jaybird/jaybird-full-3.0.12.jar .
  rm -rf ./tmp/jaybird
  rm jaybird.zip
}

function mapr_drill() {
  curl --location --output mapr_drill.rpm http://package.mapr.com/tools/MapR-ODBC/MapR_Drill/MapRDrill_odbc_v1.3.16.1049/maprdrill-1.3.16.1049-1.x86_64.rpm
}

function mariadb() {
  curl --location --output mariadb.tar.gz https://dlm.mariadb.com/997524/Connectors/odbc/connector-odbc-3.1.7/mariadb-connector-odbc-3.1.7-ga-rhel7-x86_64.tar.gz
}

function microsoft_sharepoint_lists() {
  curl --location --output microsoft_sharepoint_lists.rpm https://downloads.tableau.com/drivers/microsoft/sharepoint/Linux/SharePoint_Tableau_7613.x86_64.rpm
}

function microsoft_sql_server() {
  curl https://packages.microsoft.com/config/rhel/7/prod.repo >microsoft-rhel7.repo
}

function mysql() {
  curl --location --output mysql.rpm https://dev.mysql.com/get/mysql80-community-release-el7-7.noarch.rpm
}

function odps() {
  curl --location --remote-name https://github.com/aliyun/aliyun-odps-jdbc/releases/download/v3.3.3/odps-jdbc-3.3.3-jar-with-dependencies.jar
}

function oracle() {
  curl --location --remote-name https://download.oracle.com/otn-pub/otn_software/jdbc/217/ojdbc11.jar
}

function oracle_essbase() {
  curl --location --output oracle_essbase.rpm https://downloads.tableau.com/drivers/linux/yum/tableau-driver/tableau-essbase-19.3.0.2.001-1.x86_64.rpm
}

function oracle_netsuite() {
  curl --location --remote-name https://downloads.tableau.com/drivers/cdata/jdbc/cdata.tableau.netsuite.jar
}

function postgresql() {
  curl --location --remote-name https://jdbc.postgresql.org/download/postgresql-42.3.4.jar
}

function qubole() {
  curl --location --remote-name https://s3.amazonaws.com/paid-qubole/jdbc/qds-jdbc-3.0.3.jar
}

function salesforce_cdp() {
  curl --location --remote-name https://github.com/forcedotcom/Salesforce-CDP-jdbc/releases/download/release_2022.08a/Salesforce-CDP-jdbc-1.13.0.jar
}

function salesforce_marketing_cloud() {
  curl --location --remote-name https://downloads.tableau.com/drivers/Salesforce_MarketingCloud/cdata.tableau.sfmarketingcloud.jar
}

function sap_hana() {
  echo "not implemented: user action is required in https://tools.hana.ondemand.com/#hanatools"
  exit 1
}

function sap_success_factors() {
  curl --location --remote-name https://downloads.tableau.com/drivers/cdata/jdbc/cdata.tableau.sapsuccessfactors.jar
}

function simba_spark() {
  curl --location --output simba_spark.zip https://databricks-bi-artifacts.s3.us-east-2.amazonaws.com/simbaspark-drivers/odbc/2.6.26/SimbaSparkODBC-2.6.26.1045-LinuxRPM-64bit.zip
  unzip simba_spark.zip -d ./tmp/simba_spark
  cp ./tmp/simba_spark/simbaspark-2.6.26.1045-1.x86_64.rpm simba_spark.rpm
  rm -rf ./tmp/simba_spark
  rm simba_spark.zip
}

function singlestore() {
  curl --location --output singlestore.tar.gz https://github.com/memsql/singlestore-odbc-connector/releases/download/v1.0.7/singlestore-connector-odbc-1.0.7-centos7-amd64.tar.gz
}

function snowflake() {
  curl --location --output snowflake.rpm https://sfc-repo.snowflakecomputing.com/odbc/linux/2.25.4/snowflake-odbc-2.25.4.x86_64.rpm
}

function teradata() {
  echo "not implemented: user action is required in https://downloads.teradata.com/download/connectivity/odbc-driver/linux"
  exit 1
}

function trino() {
  curl --location --remote-name https://repo1.maven.org/maven2/io/trino/trino-jdbc/397/trino-jdbc-397.jar
}

function vertica() {
  curl --location --output vertica.rpm https://www.vertica.com/client_drivers/12.0.x/12.0.1-0/vertica-client-12.0.1-0.x86_64.rpm
}
