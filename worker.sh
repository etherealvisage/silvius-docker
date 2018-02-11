#!/bin/sh
export GST_PLUGIN_PATH=/root/gst-kaldi-nnet2-online/src/
cd /root/silvius-backend/
python kaldigstserver/worker.py -c ./silvius-tedlium.yaml "$@"
