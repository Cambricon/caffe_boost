#!/bin/bash
#Parameter int8_mode: 1-int8; 0-float16
# usage:
# 1) ./run_all_offline_sc.sh 0
# run all classification networks tests with float16
# 2) ./run_all_offline_sc.sh 1
# run all classification networks tests with int8

usage()
{
    echo "Usage:"
    echo "  $0 [0|1] [MLU220|MLU270]"
    echo ""
    echo "  Parameter description:"
    echo "    parameter1: int8 mode or int16 mode. 0:int16, 1:int8"
}

checkFile()
{
    if [ -f $1 ]; then
        return 0
    else
        return 1
    fi
}

if [[ "$#" -ne 2 ]]; then
  echo "[ERROR] Unknown parameter."
  usage
  exit 1
fi

# config
core_version=$2

network_list=(
    googlenet
    mobilenet_v1
    mobilenet_v2
    resnet101
    resnet152
    resnet18
    resnet50
    vgg16
    vgg19
    squeezenet_v1.0
    squeezenet_v1.1
    inception-v3
    alexnet
)

do_run()
{
    echo "----------------------"
    echo "single core"
    echo "using prototxt: $proto_file"
    echo "using model:    $model_file"
    echo "core_version: $core_version,  preprocess_option: $preprocess_option"

    #first remove any offline model
    /bin/rm offline.cambricon* &> /dev/null

    log_file=$(echo $proto_file | sed 's/prototxt$/log/' | sed 's/^.*\///')
    echo > $CURRENT_DIR/$log_file

    genoff_cmd="$CAFFE_DIR/build/tools/caffe${SUFFIX} genoff -model $proto_file -weights $model_file -mcore ${core_version} &>> $CURRENT_DIR/$log_file"

    run_cmd="$CAFFE_DIR/build/examples/clas_offline_singlecore/clas_offline_singlecore$SUFFIX -offlinemodel $CURRENT_DIR/offline.cambricon -images $CURRENT_DIR/$file_list -labels $CURRENT_DIR/$synset -preprocess_option $preprocess_option &>> $CURRENT_DIR/$log_file"

    echo "genoff_cmd: $genoff_cmd" &>> $CURRENT_DIR/$log_file
    echo "run_cmd: $run_cmd" &>> $CURRENT_DIR/$log_file

    echo "generating offline model..."
    eval "$genoff_cmd"

    if [[ "$?" -eq 0 ]]; then
        echo "running offline test..."
        eval "$run_cmd"
        # tail -n 3 $CURRENT_DIR/$log_file
        grep "Global accuracy : $" -A 4 $CURRENT_DIR/$log_file
    else
        echo "generating offline model failed!"
    fi
}

CURRENT_DIR=$(dirname $(readlink -f $0))

# check caffe directory
if [ -z "$CAFFE_DIR" ]; then
    CAFFE_DIR=$CAFFE_DIR
else
    if [ ! -d "$CAFFE_DIR" ]; then
        echo "[ERROR] Please check CAFFE_DIR."
        exit 1
    fi
fi

. $CAFFE_DIR/scripts/set_caffe_module_env.sh

int8_mode=$1
ds_name=""
if [[ $int8_mode -eq 1 ]]; then
    ds_name="int8"
elif [[ $int8_mode -eq 0 ]]; then
    ds_name="int16"
else
    echo "[ERROR] Unknown parameter."
    usage
    exit 1
fi

/bin/rm *.log &> /dev/null

for network in "${network_list[@]}"; do
    model_file=$CAFFE_MODELS_DIR/${network}/${network}_int8_dense.caffemodel
    checkFile $model_file
    if [ $? -eq 1 ]; then
        continue
    fi
    file_list=$FILE_LIST
    synset=synset_words.txt
    if [ ${network} == 'alexnet' ]||[ ${network} == 'googlenet' ]||[ ${network} == 'squeezenet_v1.0' ]||[ ${network} == 'squeezenet_v1.1' ]; then
      preprocess_option=2
    elif [ ${network} == 'inception-v3' ]; then
      preprocess_option=3
      file_list=$FILE_LIST_2015
      synset=synset_words_2015.txt
    else
      preprocess_option=1
    fi

    echo "===================================================="
    echo "running ${network} offline - ${ds_name},${desp}..."

    for proto_file in $CAFFE_MODELS_DIR/${network}/${network}_${ds_name}*dense_1batch.prototxt; do
        checkFile $proto_file
        if [ $? -eq 1 ]; then
            continue
        fi

        do_run
    done
done
