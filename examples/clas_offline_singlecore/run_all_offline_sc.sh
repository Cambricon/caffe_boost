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
    echo "  $0 [0|1]"
    echo ""
    echo "  Parameter description:"
    echo "    0: run all classification networks with float16"
    echo "    1: run all classification networks with int8"
}

checkFile()
{
    if [ -f $1 ]; then
        return 0
    else
        return 1
    fi
}

do_run()
{
    echo "----------------------"
    echo "single core"
    echo "using prototxt: $proto_file"
    echo "using model:    $model_file"

    #first remove any offline model
    /bin/rm offline.cambricon* &> /dev/null

    log_file=$(echo $proto_file | sed 's/prototxt$/log/' | sed 's/^.*\///')
    echo > $CURRENT_DIR/$log_file

    genoff_cmd="$CAFFE_DIR/build/tools/caffe${SUFFIX} genoff -model $proto_file -weights $model_file -mcore MLU100 &>> $CURRENT_DIR/$log_file"

    run_cmd="$CAFFE_DIR/build/examples/clas_offline_singlecore/clas_offline_singlecore$SUFFIX -offlinemodel $CURRENT_DIR/offline.cambricon -images $CURRENT_DIR/$FILE_LIST -labels $CURRENT_DIR/synset_words.txt  &>> $CURRENT_DIR/$log_file"

    echo "genoff_cmd: $genoff_cmd" &>> $CURRENT_DIR/$log_file
    echo "run_cmd: $run_cmd" &>> $CURRENT_DIR/$log_file

    echo "generating offline model..."
    eval "$genoff_cmd"

    if [[ "$?" -eq 0 ]]; then
        echo "running offline test..."
        eval "$run_cmd"
        grep "Global accuracy : $" -A 4 $CURRENT_DIR/$log_file
    else
        echo "generating offline model failed!"
    fi
}

desp_list=(
    dense
    sparse
)

batch_list=(
    1batch
    # 2batch
    # 4batch
)

network_list=(
    alexnet
    googlenet
    inception-v3
    mobilenet
    resnet101
    resnet152
    resnet18
    resnet34
    resnet50
    squeezenet
    vgg16
    vgg19
)

if [[ "$#" -ne 1 ]]; then
    echo "[ERROR] Unknown parameter."
    usage
    exit 1
fi

CURRENT_DIR=$(dirname $(readlink -f $0))

# check caffe directory
if [ -z "$CAFFE_DIR" ]; then
    CAFFE_DIR=$CURRENT_DIR/../..
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
    ds_name="float16"
else
    echo "[ERROR] Unknown parameter."
    usage
    exit 1
fi

/bin/rm *.log &> /dev/null

for network in "${network_list[@]}"; do
    for desp in "${desp_list[@]}"; do
        model_file=$CAFFE_MODELS_DIR/${network}/${network}_float16_${desp}.caffemodel
        checkFile $model_file
        if [ $? -eq 1 ]; then
            continue
        fi

        echo "===================================================="
        echo "running ${network} offline - ${ds_name},${desp}..."

        for batch in "${batch_list[@]}"; do
            for proto_file in $CAFFE_MODELS_DIR/${network}/${network}_${ds_name}*${desp}_${batch}.prototxt; do
                checkFile $proto_file
                if [ $? -eq 1 ]; then
                    continue
                fi

                do_run
            done
        done
    done
done
