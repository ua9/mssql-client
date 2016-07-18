FROM ubuntu:xenial
MAINTAINER Anton Marianov <anovmari@gmail.com>
ARG MSODBC_URL=https://download.microsoft.com/download/2/E/5/2E58F097-805C-4AB8-9FC6-71288AB4409D/msodbcsql-13.0.0.0.tar.gz
ADD ${MSODBC_URL} /tmp/msodbcsql.tar.gz
ADD ${MSODBC_URL}.sha256 /tmp/msodbcsql.tar.gz.sha256
RUN cd /tmp && \
  apt-get -y update && \
  locale-gen "en_US.UTF-8" && \
  apt-get install -y wget libgss3 libc6 libkrb5-3 && \
  cat msodbcsql.tar.gz | sha256sum --check msodbcsql.tar.gz.sha256 && \
  msodbc_dir=${PWD}/$(tar -tzf msodbcsql.tar.gz | head -1) && \
  tar -xzf msodbcsql.tar.gz && \
  cd $msodbc_dir && \
  dm_dir=$(./build_dm.sh --accept-warning --libdir=/usr/lib/x86_64-linux-gnu | grep 'cd /tmp' | sed 's/^.*cd //' | sed 's/; make.*$//') && \
  cd $dm_dir && \
  make install && \
  cd $msodbc_dir && \
  ./install.sh install --accept-license && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/* /tmp/*
ENTRYPOINT ["/usr/bin/sqlcmd"]

