# User defines variable values
# DRIVERS contain the list of public database drivers to install
DRIVERS=amazon_athena,amazon_emr_hadoop_hive,amazon_redshift,cloudera_hive,cloudera_impala,datorama,dremio,esri,exasol,firebolt,google_bigquery,ibm_db2,jaybird,mapr_drill,mariadb,microsoft_sharepoint_lists,microsoft_sql_server,mysql,odps,oracle,oracle_essbase,oracle_netsuite,postgresql,qubole,salesforce_cdp,salesforce_marketing_cloud,sap_success_factors,simba_spark,singlestore,snowflake,trino,vertica
# OS_TYPE selects the correct scripts to run depending on the linux platform of the base image
OS_TYPE=rhel8
# SOURCE_REPO is the location of the base image
SOURCE_REPO=redhat/ubi8
# IMAGE_TAG is the base image tag, it is usually a version number
IMAGE_TAG=8.6
# TARGET_REPO is the output location of the new image
TARGET_REPO=user/redhat/ubi8
# USER is the identity to use when running ENTRYPOINT or CMD from the base image
USER=root
