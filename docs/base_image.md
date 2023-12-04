## Creating a base image for Tableau Bridge

### Selecting an image with the base operating system
If you are only interested in adding database drivers you can skip this section.

Tableau Bridge Team is building containers using base image "docker.io/redhat/ubi8:8.7". If you have a reason to use a different base image, you can edit the file `variables.sh`, and change the values of `OS_TYPE`, `SOURCE_REPO`, `IMAGE_TAG`. Tableau bridge installer only comes in rpm, deb is not supported. In theory, it should run ok in operating systems like Centos, Oracle Linux, and other similar to RedHat.

### Installing database drivers in a base image
The customer can select public database drivers from a managed list provided by the engineering team. Sometimes, the customer might need to install other database drivers or other versions to meet their database connection requirements. This document explains how to install the Teradata odbc driver and the same concept can be applied to other drivers. It uses a tool to generate the image, but you can use any tooling you want, the important part is to create an image and store it in the docker registry.

### Create the image
1. Login to any node in your kubernetes cluster. Install docker and git.
```
# redhat 8
sudo dnf module install -y container-tools
sudo dnf install -y git podman-docker

# ubuntu 20
sudo apt install -y containerd docker.io git
mkdir -p $HOME/.docker/cli-plugins
curl -Lo $HOME/.docker/cli-plugins/docker-buildx https://github.com/docker/buildx/releases/download/v0.11.2/buildx-v0.11.2.linux-amd64
chmod 0744 $HOME/.docker/cli-plugins/docker-buildx
sudo systemctl stop docker
sudo systemctl start docker
sudo systemctl status docker

# test
docker images
```
2. git clone https://github.com/tableau/container_image_builder
3. Find the download function related to the database driver in `download/drivers/rhel8.sh`
```
function teradata() {
  echo "not implemented: user action is required in https://downloads.teradata.com/download/connectivity/odbc-driver/linux"
  exit 1
}
```
4. Find the build function related to the database driver in `build/drivers/rhel8.sh`
```
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
```
5. Note the download function is not implemented and the build function is implemented for Teradata 16.20. At this point, you can choose to override only the download function or you can override both functions. 
6. Download the Teradata ODBC Driver for Linux x86-64 (64-bit) version 16.20 from https://downloads.teradata.com/download/connectivity/odbc-driver/linux and store it under $HOME/
7. We want to override the download function. 
* Create the directory `mkdir download/user/drivers`
* Create the file `download/user/drivers/rhel8.sh` with this content
```
function teradata() {
  cp $HOME/tdodbc1620__linux_indep.16.20.00.127-1.tar.gz ./teradata.tar.gz
}
```
8. Edit the file `variables.sh`. Remove all the drivers and add only teradata
```
DRIVERS=teradata
```
9. Run the tool to build the image
```
# redhat 8
./download.sh
sudo ./build.sh
sudo docker images

# ubuntu 20
./download.sh
./build.sh
docker images
```
10. You should see a generated image.
* In redhat 8, the image is "localhost/user/redhat/ubi8:8.7"
* In ubuntu 20, the image is "user/redhat/ubi8:8.7"

### Publish the image to the local docker registry
1. View the file /etc/hosts. It should have a line "127.0.0.1 container-registry.distributed-cloud.salesforce.com". If the line is not there you are probably not in a node of your cluster
2. Set variable POOL_ID with the value of your bridge pool id. In the tableau website, click in the bridge pool name, and it will show a dialog with the pool id value.
3. Add a tag to the image in the format "bridge-base-$POOL_ID:8.7"
```
REGISTRY_HOSTNAME=container-registry.distributed-cloud.salesforce.com
POOL_ID=
docker tag user/redhat/ubi8:8.7 $REGISTRY_HOSTNAME/bridge-base-$POOL_ID:8.7
docker images
REPOSITORY                                                                                             TAG       IMAGE ID       CREATED         SIZE
container-registry.distributed-cloud.salesforce.com/bridge-base-a028596f-8e62-4736-a429-3dd122532bf0   8.7       09eaa80ab7a4   3 minutes ago   556MB
user/redhat/ubi8                                                                                       8.7       09eaa80ab7a4   3 minutes ago   556MB
```
3. Find the credentials of the docker registry
```
sudo kubectl get secrets -n tableau -o jsonpath='{.data.\.dockerconfigjson}' dockerconfigjson | base64 -d
```
4. Login to the docker registry and push the image
```
docker login --username $REGISTRY_USERNAME $REGISTRY_HOSTNAME
docker push $REGISTRY_HOSTNAME/bridge-base-$POOL_ID:8.7
```
5. Share the full image name to the Tableau Bridge as a Service Team. For example "container-registry.distributed-cloud.salesforce.com/bridge-base-a028596f-8e62-4736-a429-3dd122532bf0:8.7"  
