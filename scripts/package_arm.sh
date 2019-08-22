#!/bin/bash

function usage
{
    echo "Usage:"
    echo "  $0 [1|2]"
    echo ""
    echo "  Parameter description:"
    echo "      1: arm32"
    echo "      2: arm64"
}

if [ $# -ne 1 ]; then
    echo "[Error] The number of parameter should be 1."
    usage
    exit 1
fi

SUFFIX=""
if [[ $1 -eq 1 ]]; then
    platform=arm32
elif [[ $1 == 2 ]]; then
    platform=arm64
    SUFFIX="64"
else
    echo "[Error] Invaild parameter."
    usage
    exit 1
fi
if [ -z $CAFFE_DIR ]; then
    echo "[Error] Please define CAFFE_DIR."
    exit 1
fi

cur_path=$(dirname $(readlink -f $0))
package_dir=$cur_path/$platform
caffe_dir=$package_dir/caffe
caffe_boost_dir=$package_dir/caffe_boost
echo "package_dir=$package_dir"

pushd $cur_path
if [ ! -d $caffe_dir/build/tools ]; then
    mkdir -p $caffe_dir/build/tools
fi

if [ ! -d $caffe_dir/build/lib ]; then
    mkdir -p $caffe_dir/build/lib
fi

if [ ! -d $caffe_dir/scripts ]; then
    mkdir -p $caffe_dir/scripts
fi

if [ ! -d $caffe_boost_dir/scripts ]; then
    mkdir -p $caffe_boost_dir/scripts
fi

if [ ! -d $caffe_boost_dir/examples ]; then
    mkdir -p $caffe_boost_dir/examples
fi

cp -fr $CAFFE_DIR/build/examples $caffe_dir/build
cp -fr $CAFFE_DIR/build/tools/caffe* $caffe_dir/build/tools
cp -fr $CAFFE_DIR/build/tools/test_forward_offline $caffe_dir/build/tools
cp -fr $CAFFE_DIR/build/lib/*.so* $caffe_dir/build/lib
cp -fr $CAFFE_DIR/scripts/set_caffe_module_env.sh $caffe_dir/scripts
cp -fr $CAFFE_DIR/mlu/$platform/lib${SUFFIX}/libcnml.so $caffe_dir/build/lib
cp -fr $CAFFE_DIR/mlu/$platform/lib${SUFFIX}/libcnrt.so $caffe_dir/build/lib

cp -fr $cur_path/../scripts/download_caffemodel.sh $caffe_boost_dir/scripts
cp -fr $cur_path/../scripts/download_dependency.sh $caffe_boost_dir/scripts
cp -fr $cur_path/../scripts/gen_val.sh $caffe_boost_dir/scripts

cp -fr $cur_path/../examples/clas_offline_singlecore $caffe_boost_dir/examples
cp -fr $cur_path/../examples/clas_online_singlecore $caffe_boost_dir/examples
cp -fr $cur_path/../examples/ssd $caffe_boost_dir/examples
cp -fr $cur_path/../examples/yolo_v2 $caffe_boost_dir/examples
cp -fr $cur_path/../examples/yolo_v3 $caffe_boost_dir/examples

# for arm, only test single core, so don't copy file_list to clas_offline_multicore and clas_online_multicore
sed -i '/clas_offline_multicore/d' $caffe_boost_dir/scripts/gen_val.sh
sed -i '/clas_online_multicore/d' $caffe_boost_dir/scripts/gen_val.sh

# filter redundant files
rm -fr $caffe_boost_dir/examples/ssd/run_all_offline_mc.sh
rm -fr $caffe_boost_dir/examples/yolo_v2/run_all_offline_mc.sh
rm -fr $caffe_boost_dir/examples/yolo_v3/run_all_offline_mc.sh
find $caffe_boost_dir/examples -name "*.cambricon" -exec rm -fr {} \;
find $caffe_boost_dir/examples -name "*.jpg" -exec rm -fr {} \;
find $caffe_boost_dir/examples -name "*.log" -exec rm -fr {} \;
find $caffe_boost_dir/examples -name "200*.txt" -exec rm -fr {} \;
find $caffe_boost_dir/examples -name "000*.txt" -exec rm -fr {} \;

# rm online demo for arm32
if [[ "$platform" == "arm32" ]]; then
    rm -fr $caffe_boost_dir/examples/clas_online_singlecore
    rm -fr $caffe_boost_dir/examples/ssd/run_all_online_sc.sh
    rm -fr $caffe_boost_dir/examples/yolo_v2/run_all_online_sc.sh
    rm -fr $caffe_boost_dir/examples/yolo_v3/run_all_online_sc.sh

    sed -i '/clas_online_singlecore/d' $caffe_boost_dir/scripts/gen_val.sh
    find $caffe_boost_dir/examples -type f -name "*.sh" |xargs -i sed -i 's/MLU100/1H8/g' {}
fi

# remove bash for android and change MLU100 to 1H16
if [[ "$platform" == "arm64" ]]; then
    find $caffe_boost_dir/scripts -type f -name "*.sh" |xargs -i sed -i '1d' {}
    find $caffe_boost_dir/examples -type f -name "*.sh" |xargs -i sed -i '1d' {}
    find $caffe_boost_dir/examples -type f -name "*.sh" |xargs -i sed -i 's/MLU100/1H16/g' {}
    # remove bash for set_caffe_module_env.sh
    find $caffe_dir/scripts -type f -name "*.sh" |xargs -i sed -i '1d' {}
fi

echo "Packaging $platform..."
tar -cjpf $platform.tar.bz2 $platform
rm -fr $package_dir

popd
echo "Done!"
