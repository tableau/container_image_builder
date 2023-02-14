# Container Image Builder
[![Community Supported](https://img.shields.io/badge/Support%20Level-Community%20Supported-457387.svg)](https://www.tableau.com/support-levels-it-and-developer-tools)

Use this tool to install database drivers and other artifacts needed in your Tableau containers.
It downloads database driver files from official websites managed by the database vendors. Therefore, the path or the availability of a database driver can change at any moment. It is recommended to backup the files in your internal network. 

## How it works
There are 3 phases: 
* download: it runs in your local computer with the purpose of downloading files using curl, aws s3, or any other client.  
* build: it runs in the container image context, it installs the software in the container image.
* test: it starts a long-running container from the created image, and it runs tests.

Every phase has jobs:
* download/drivers: it downloads drivers from public sites which can remove the driver eventually. It is recommended to replace this job to download files from a location managed by your company.
* download/user: it downloads any additional file you need in the container
* build/drivers: it installs drivers from download/drivers
* build/user: it installs drivers and other files from download/user
* test/drivers: it runs tests to check build/drivers
* test/user: it runs tests to check build/user

## How to use it
* Set the configuration values in `./variables.sh`
* Run `./download.sh`. It downloads the drivers under build/drivers/files. Note: delete the folder to download th files again.
* Run `./build.sh`. When successful, it creates $TARGET_REPO:$IMAGE_TAG in your local computer
* Optionally, run `./test.sh`. You could extend it by writing connectivity tests to your internal databases. JDBC tests might require to install JRE in the container. ODBC tests can use UnixODBC isql command line tool.
* Login to your container registry and push the image

### How to override downloads
* Create file `download/user/drivers/$OS_TYPE.sh`, add functions similar to code in `download/drivers/$OS_TYPE.sh`
* To add a new driver, you could add a function
```
function my_driver() {
  curl --location --output my_driver.rpm https://artifacts.local/my_driver-1.0.0.x86_64.rpm
}
```
* To override an existing driver, you could add a function. This sample downloads amazonredshift from a server located in your company private network
```
function amazon_redshift() {
  curl --location --output amazon_redshift.rpm https://artifacts.local/AmazonRedshiftODBC-64-bit-1.4.56.1000-1.x86_64.rpm
}
```

### How to override installations
* Create file `build/user/drivers/$OS_TYPE.sh`, add functions similar to code in `build/drivers/$OS_TYPE.sh`
* To add the new driver, you could add a function
```
function my_driver() {
  yum -y localinstall ./my_driver.rpm
}
```
* To override an existing driver, you could add a function. This sample installs amazon redshift with fictional flags ACCEPT_EULA and WORKERS
```
function amazon_redshift() {
  ACCEPT_EULA=Y WORKERS=2 yum -y --nogpgcheck localinstall ./amazon_redshift.rpm
  odbcinst -i -d -f /opt/amazon/redshiftodbc/Setup/odbcinst.ini
  grep -n -F '[Amazon Redshift (x64)]' /etc/odbcinst.ini
  [ -f /opt/amazon/redshiftodbc/lib/64/libamazonredshiftodbc64.so ]
}
```

### How to implement custom actions
* Make changes in `download/user/download.sh`, `build/user/build.sh`, and `test/user/test.sh`
