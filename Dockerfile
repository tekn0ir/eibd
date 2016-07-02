FROM debian:jessie
MAINTAINER Anders Åslund <anders.aslund@teknoir.se>

# update apt and install dependencies
RUN apt-get -qq update
RUN apt-get install -y python python-dev python-pip python-virtualenv
RUN apt-get install -y build-essential gcc git rsync cmake make g++ binutils automake flex bison patch wget

ENV KNXDIR /usr
ENV INSTALLDIR $KNXDIR/local
ENV SOURCEDIR  $KNXDIR/src
ENV LD_LIBRARY_PATH $INSTALLDIR/lib

WORKDIR $SOURCEDIR

# build pthsem
COPY pthsem_2.0.8.tar.gz pthsem_2.0.8.tar.gz
RUN tar -xzf pthsem_2.0.8.tar.gz
RUN cd pthsem-2.0.8 && ./configure --prefix=$INSTALLDIR/ && make && make test && make install

# build linknx
COPY linknx-0.0.1.32.tar.gz linknx-0.0.1.32.tar.gz
RUN tar -xzf linknx-0.0.1.32.tar.gz
RUN cd linknx-0.0.1.32 && ./configure --without-log4cpp --without-lua --prefix=$INSTALLDIR/ --with-pth=$INSTALLDIR/ && make && make install

# build eibd
COPY bcusdk_0.0.5.tar.gz bcusdk_0.0.5.tar.gz
RUN tar -xzf bcusdk_0.0.5.tar.gz
RUN cd bcusdk-0.0.5 && ./configure --enable-onlyeibd --enable-eibnetiptunnel --enable-eibnetipserver --enable-ft12 --prefix=$INSTALLDIR/ --with-pth=$INSTALLDIR/ && make && make install

RUN useradd eibd -s /bin/false -U -M
ADD eibd.sh /etc/init.d/eibd
RUN chmod +x /etc/init.d/eibd
RUN update-rc.d eibd defaults 98 02

EXPOSE 6720
