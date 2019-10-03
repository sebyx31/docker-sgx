FROM ubuntu:bionic

WORKDIR /usr/src/sdk

RUN apt-get update && apt-get install -yq --no-install-recommends ca-certificates build-essential ocaml ocamlbuild automake autoconf  \
    libtool wget python libssl-dev libssl-dev libcurl4-openssl-dev protobuf-compiler git libprotobuf-dev alien cmake debhelper uuid-dev \
    libxml2-dev xxd

# The download link is broken (404)
# RUN wget --progress=dot:mega -O iclsclient.rpm http://registrationcenter-download.intel.com/akdlm/irc_nas/11414/iclsClient-1.45.449.12-1.x86_64.rpm && \
#     alien --scripts -i iclsclient.rpm && \
#     rm iclsclient.rpm

RUN git clone https://github.com/01org/dynamic-application-loader-host-interface.git && \
    cd dynamic-application-loader-host-interface && \
    cmake . -DCMAKE_BUILD_TYPE=Release -DINIT_SYSTEM=SysVinit && \
    make && \
    make install && \
    cd .. && rm -rf dynamic-application-loader-host-interface

COPY install-psw.patch ./

RUN git clone -b sgx_2.6 --depth 1 https://github.com/intel/linux-sgx && \
    cd linux-sgx && \
    patch -p1 -i ../install-psw.patch && \
    ./download_prebuilt.sh 2> /dev/null && \
    make -s -j$(nproc) sdk_install_pkg psw_install_pkg && \
    ./linux/installer/bin/sgx_linux_x64_sdk_*.bin --prefix=/opt/intel && \
    ./linux/installer/bin/sgx_linux_x64_psw_*.bin && \
    cd .. && rm -rf linux-sgx/

WORKDIR /usr/src/app

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

# For debug purposes
# COPY jhi.conf /etc/jhi/jhi.conf
