#!/bin/sh
cd /root/kaldi/src && find -not -name '*.so*' -type f | xargs rm
cd /root/kaldi/tools/openfst && find -not -name '*.so*' -type f | xargs rm
rm -rf /root/kaldi/tools/openfst/src/
cd /root/ && find -name '.git' -type d | xargs rm -rf
rm /root/silvius-backend/models/silvius-tedlium-v1.0.tar.gz
rm /root/jansson-2.7.tar.bz2
