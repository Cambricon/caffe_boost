#!/bin/bash

read -p "Please input user name:" username
read -s -p "Please input password:" password

tar_name=caffe_mp_c20.tar.gz
url=ftp://192.168.64.10:21/ftp/$tar_name

echo "downloading caffe model..."
wget -c -t 0 $url --ftp-user=$username --ftp-password=$password -O $tar_name
echo "done."

