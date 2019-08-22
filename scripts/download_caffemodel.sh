#!/bin/bash

read -p "Please input user name:" username
read -s -p "Please input password:" password

tar_name=caffe_mp.tar.bz2
url=ftp://58.246.138.230:21/ftp/$tar_name

echo "downloading caffe model..."
wget -c -t 0 $url --ftp-user=$username --ftp-password=$password -O $tar_name
echo "done."

