#!/usr/bin/env bash
set -o errexit; set -o nounset; set -o pipefail; set -o xtrace

export DEBIAN_FRONTEND="noninteractive"
export PATH=$PATH:/usr/local/bin

# check operating system
OS_NAME_ID=$(cat /etc/os-release | grep ^ID=  | cut -d "=" -f 2 | cut -d "." -f 1 | tr -d '"')
OS_VERSION_ID=$(cat /etc/os-release | grep ^VERSION_ID=  | cut -d "=" -f 2 | cut -d "." -f 1 | tr -d '"')
value="$OS_NAME_ID-$OS_VERSION_ID"
if [[ ! ",rhel-8,ubuntu-20," =~ ",${value}," ]]; then
  echo "operating system is not supported: $value"
  exit
fi

# build tools
if [ -f /usr/bin/apt ]; then
apt install -y autoconf git
fi
if [ -f /bin/dnf ]; then
dnf group install -y "Development Tools"
dnf install -y autoconf gcc-toolset-9 git libtool pkg-config
fi

# cmake from https://github.com/aws/credentials-fetcher/blob/mainline/docker/Dockerfile-ubuntu-20.04
rm -rf CMake
git clone https://github.com/Kitware/CMake.git -b release
pushd CMake
./configure
make -j4
make install
popd
rm -rf CMake

# krb5 from https://github.com/aws/credentials-fetcher/blob/mainline/dependencies/CMakeLists.txt
rm -rf krb5
git clone -b krb5-1.21.2-final https://github.com/krb5/krb5.git
pushd krb5/src
autoconf
autoreconf
./configure
make -j4
make install
popd
rm -rf krb5

# grpc from https://grpc.io/docs/languages/cpp/quickstart/
if [ -f /usr/bin/apt ]; then
apt install -y libgflags-dev
fi
rm -rf grpc
git clone --recurse-submodules --shallow-submodules --depth 1 -b v1.58.0 https://github.com/grpc/grpc
mkdir -p grpc/build
pushd grpc/build
cmake -DgRPC_INSTALL=ON -DgRPC_BUILD_TESTS=OFF -DCMAKE_CXX_STANDARD=17 ..
make -j4
make install
popd

# grpc_cli from https://github.com/grpc/grpc/blob/master/doc/command_line_tool.md
pushd grpc/build
cmake -DgRPC_BUILD_TESTS=ON ..
make grpc_cli
cp grpc_cli /usr/bin
popd
rm -rf grpc

# aws-sdk from https://github.com/aws/aws-sdk-cpp
if [ -f /usr/bin/apt ]; then
apt install -y libcurl4-openssl-dev
fi
if [ -f /bin/dnf ]; then
dnf install -y libcurl-devel
fi
rm -rf aws-sdk-cpp
git clone --recurse-submodules -b 1.11.216 https://github.com/aws/aws-sdk-cpp
mkdir -p aws-sdk-cpp/build
pushd aws-sdk-cpp/build
cmake .. -DBUILD_ONLY="s3;secretsmanager"
make -j4
make install
popd
rm -rf aws-sdk-cpp

# dotnet-sdk from https://learn.microsoft.com/en-us/dotnet/core/install/linux-ubuntu-2004
if [ -f /usr/bin/apt ]; then
curl --location --remote-name https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb
dpkg -i packages-microsoft-prod.deb
rm packages-microsoft-prod.deb
apt update
apt install -y dotnet-sdk-6.0
fi
# dotnet-sdk from https://learn.microsoft.com/en-us/dotnet/core/install/linux-rhel
if [ -f /bin/dnf ]; then
dnf install -y dotnet-sdk-6.0
fi

# credentials-fetcher from https://github.com/aws/credentials-fetcher/blob/mainline/README.md#standalone-mode
if [ -f /usr/bin/apt ]; then
apt install -y byacc libboost-dev libboost-filesystem-dev libboost-program-options-dev libglib2.0-dev libjsoncpp-dev libkrb5-dev libssl-dev libsystemd-dev
fi
if [ -f /bin/dnf ]; then
dnf install -y boost-devel glib2-devel jsoncpp-devel systemd-devel
fi
rm -rf credentials-fetcher
git clone --depth 1 -b v.1.3.0 https://github.com/aws/credentials-fetcher.git
if [ -f /usr/bin/apt ]; then
  if [ ! -d /usr/include/json ]; then
    ln -s '/usr/include/jsoncpp/json/' '/usr/include/json'
  fi
sed -i 's|/usr/lib64/glib-2.0|/usr/lib/x86_64-linux-gnu/glib-2.0|g' credentials-fetcher/CMakeLists.txt
sed -i 's|/usr/lib64/glib-2.0|/usr/lib/x86_64-linux-gnu/glib-2.0|g' credentials-fetcher/api/CMakeLists.txt
sed -i 's|/usr/lib64/dotnet|/usr/share/dotnet|g' credentials-fetcher/auth/kerberos/src/utf16_decode/build-using-csc.sh
sed -i 's/ec2-user/ubuntu/g' credentials-fetcher/CMakeLists.txt
fi
if [ -f /bin/dnf ]; then
sed -i 's/ubuntu/rhel/g' credentials-fetcher/CMakeLists.txt
fi
sed -i 's/find_package(Protobuf REQUIRED)/find_package(Protobuf REQUIRED CONFIG)/g' credentials-fetcher/CMakeLists.txt
sed -i '/ExecStartPost=chgrp/i \    "ExecStartPost=sleep 1\\n"' credentials-fetcher/CMakeLists.txt
sed -i '/CREDENTIALS_FETCHERD_STARTED_BY_SYSTEMD/a \    "Environment=\\"CF_CRED_SPEC_FILE=/root/credspec.json\\"\\n"' credentials-fetcher/CMakeLists.txt
sed -i 's/std::regex pattern/std::regex old_pattern/g' credentials-fetcher/auth/kerberos/src/krb.cpp
sed -i '/std::regex old_pattern/a \    std::regex pattern("[ ]{2}([0-9]{2}\/.+:[0-9]{2})[ ]{2}");' credentials-fetcher/auth/kerberos/src/krb.cpp
sed -i 's|%m/%d/%Y %T|%m/%d/%y %T|g' credentials-fetcher/auth/kerberos/src/krb.cpp
if [ -n "$GMSA_OU" ]; then
  sed -i "s/CN=Managed Service Accounts/$GMSA_OU/g" credentials-fetcher/auth/kerberos/src/krb.cpp
fi
# uncomment line below to change renew check from 10 minutes to 1 minute. Useful for testing
# sed -i 's/uint64_t krb_ticket_handle_interval = 10;/uint64_t krb_ticket_handle_interval = 1;/g' credentials-fetcher/common/daemon.h
mkdir -p credentials-fetcher/build
pushd credentials-fetcher/build
if [ -f /bin/dnf ]; then
scl enable gcc-toolset-9 'cmake -DCMAKE_CXX_STANDARD=17 ..'
scl enable gcc-toolset-9 'make -j4'
scl enable gcc-toolset-9 'make install'
else
cmake -DCMAKE_CXX_STANDARD=17 ..
make -j4
make install
fi
systemctl daemon-reload
systemctl enable credentials-fetcher
systemctl stop credentials-fetcher ||:
systemctl start credentials-fetcher
#journalctl -u credentials-fetcher | tail -50
popd
rm -rf credentials-fetcher
