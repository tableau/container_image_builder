# Container Image Builder
[![Community Supported](https://img.shields.io/badge/Support%20Level-Community%20Supported-457387.svg)](https://www.tableau.com/support-levels-it-and-developer-tools)

Use this tool to install database drivers and other artifacts needed in your Tableau containers.
It downloads database driver files from official websites managed by the database vendors. Therefore, the path or the availability of a database driver can change at any moment. It is recommended to backup the files in your internal network. 

## How to use it
* Set the configuration values in `./variables.sh`
* To implement custom user actions, make changes in download/user/build.sh, build/user/build.sh, and test/user/test.sh
* Run `./download.sh`. It will store the drivers under build/drivers/files
* Run `./build.sh`. When successful, it creates $TARGET_REPO:$IMAGE_TAG in your local computer
* Optionally, run `./test.sh`. You could extend it by writing connectivity tests to your internal databases. JDBC tests might require to install JRE in the container. ODBC tests can use UnixODBC isql command line tool.
* Login to your container registry and push the image

## How it works
There are 3 phases: 
* download: it runs in your local computer with the purpose of downloading files using curl, aws s3, or any other client.  
* build: it runs in the container image context, it contains the jobs to install the software in the container image.
* test: it starts an instance of the created container image and runs tests.

Every phase has jobs:
* download/drivers: it downloads drivers from public sites which can remove the driver eventually. It is recommended to replace this job to download files from a location managed by your company.
* download/user: it downloads any additional file you need in the container
* build/drivers: it installs drivers from download/drivers
* build/user: it installs drivers and other files from download/user
* test/drivers: it runs tests to check build/drivers
* test/user: it runs tests to check build/user
