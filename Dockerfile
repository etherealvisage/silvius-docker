FROM debian:jessie

# TODO: remove -j XX

# Install packages
RUN apt-get update && \
    apt-get install -y git build-essential zlib1g-dev automake autoconf wget \
    libtool subversion python libatlas3-base libgstreamer1.0-dev python-gi \
    python-yaml python-pip python-ws4py python-dev gstreamer1.0-plugins-good
# Set up shell to be bash instead of dash (kaldi needs this)
RUN ln -s -f /bin/bash /bin/sh
# Install Python packages
RUN pip install tornado
# Compile Kaldi
RUN cd /root/ && \
    git clone https://github.com/kaldi-asr/kaldi.git && \
    cd /root/kaldi/tools/ && \
    make && \
    ./install_portaudio.sh && \
    cd /root/kaldi/src/ && \
    ./configure --shared && \
    make -j 12

# Build online speech recognizer
RUN cd /root/kaldi/src/online && \
    make && \
    cd /root/kaldi/src/gst-plugin && \
    sed -i 's/(vector/(std::vector/' gst-online-gmm-decode-faster.cc && \
    sed -i 's/<vector/<std::vector/' gst-online-gmm-decode-faster.cc && \
    make depend && make && \
    cd /root && \
    wget http://www.digip.org/jansson/releases/jansson-2.7.tar.bz2 && \
    tar xf jansson-2.7.tar.bz2 && \
    cd jansson-2.7 && \
    ./configure && make && make install && \
    echo /usr/local/lib > /etc/ld.so.conf.d/localib.conf && ldconfig

# build gstreamer input
RUN cd /root && \
    git clone https://github.com/dwks/gst-kaldi-nnet2-online.git && \
    cd gst-kaldi-nnet2-online/src/ && \
    FSTROOT=/root/kaldi/tools/openfst KALDI_ROOT=/root/kaldi make depend && \
    FSTROOT=/root/kaldi/tools/openfst KALDI_ROOT=/root/kaldi make

# Set up speech model/WebSockets interface
RUN cd /root && \
    git clone https://github.com/dwks/silvius-backend.git && \
    cd /root/silvius-backend/models && \
    ./silvius-tedlium-v1.0.sh

# Copy in helper script
COPY worker.sh /root
RUN chmod +x /root/worker.sh

# Clean up a bit
#RUN cd /root/kaldi/src && find -not -name '*.so*' | xargs rmdir
RUN \
    cd /root/kaldi/src && find -not -name '*.so*' -type f | xargs rm && \
    cd /root/kaldi/tools/openfst && find -not -name '*.so*' -type f | xargs rm && \
    rm -rf /root/kaldi/tools/openfst/src/ && \
    cd /root/ && find -name '.git' -type d | xargs rm -rf && \
    rm /root/silvius-backend/models/silvius-tedlium-v1.0.tar.gz && \
    rm /root/jansson-2.7.tar.bz2
