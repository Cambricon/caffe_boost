#!/bin/bash
# usage: $0 [arm32|arm64]
function usage
{
    echo "Usage:"
    echo "  $0 [1|2]"
    echo ""
    echo "  Parameter description:"
    echo "      1:arm32"
    echo "      2:arm64"
}


if [[ $# -ne 1 ]]; then
    echo "[Error] Invaild parameter."
    usage
    exit 1
fi

if [[ $1 -eq 1 ]]; then
    tar_name=arm32_linux_lib.tar.bz2
elif [[ $1 -eq 2 ]]; then
    tar_name=arm64_android_lib.tar.bz2
else
    echo "[Error] Invaild parameter."
    usage
    exit 1
fi

read -p "Please input user name:" username
read -s -p "Please input password:" password

url=ftp://58.246.138.230:21/ftp/$tar_name

echo "downloading dependency lib..."
wget -c -t 0 $url --ftp-user=$username --ftp-password=$password -O $tar_name
echo "done."
