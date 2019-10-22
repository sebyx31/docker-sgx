FROM ubuntu:bionic

WORKDIR /usr/src/app

RUN apt-get update && apt-get install -yq --no-install-recommends ca-certificates build-essential ocaml ocamlbuild automake autoconf libtool wget python libssl-dev libssl-dev libcurl4-openssl-dev protobuf-compiler git libprotobuf-dev alien cmake debhelper uuid-dev libxml2-dev lsb-release

COPY install-psw.patch ./

RUN git clone -b sgx_2.6 --depth 1 https://github.com/intel/linux-sgx

RUN cd linux-sgx && \
    patch -p1 -i ../install-psw.patch && \
    ./download_prebuilt.sh 2> /dev/null && \
    make -s -j$(nproc) && make -s -j$(nproc) sdk_install_pkg deb_pkg && \
    ./linux/installer/bin/sgx_linux_x64_sdk_2.6.100.51363.bin --prefix=/opt/intel && \
    cd linux/installer/deb/ && \
    dpkg -i libsgx-urts_2.6.100.51363-bionic1_amd64.deb libsgx-enclave-common_2.6.100.51363-bionic1_amd64.deb && \
    cd ../../../.. && rm -rf linux-sgx/

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

