#!/bin/bash
#Parameter int8_mode: 1-int8; 0-float16
# usage:
# 1) ./run_all_mc.sh 0
# run all classification networks tests with float16
# 2) ./run_all_sc.sh 1
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
    echo "multiple core"
    echo "using prototxt: $proto_file"
    echo "using model:    $model_file"
    echo "data_parallel:  $dp,  model_parallel:  $mp  thread_num:  ${thread_num}"

    log_file=$(echo $proto_file | sed 's/prototxt$/log/' | sed 's/^.*\///')
    echo > $CURRENT_DIR/$log_file

    run_cmd="$CAFFE_DIR/build/examples/clas_online_multicore/clas_online_multicore$SUFFIX -model $proto_file -weights $model_file -labels $CURRENT_DIR/synset_words.txt -images $CURRENT_DIR/$FILE_LIST -threads ${thread_num} -dataparallel $dp -modelparallel $mp -fifosize 4 &>> $CURRENT_DIR/$log_file"

    echo "run_cmd: $run_cmd" &>> $CURRENT_DIR/$log_file

    echo "running online test..."
    eval "$run_cmd"
    #tail -n 4 $CURRENT_DIR/$log_file
    grep "Global accuracy : $" -A 4 $CURRENT_DIR/$log_file
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

dpmp_list=(
    '8 1'
    # '1 2'
    # '2 4'
    # '4 8'
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
scale=""
if [[ $int8_mode -eq 1 ]]; then
    ds_name="int8"
elif [[ $int8_mode -eq 0 ]]; then
    ds_name="float16"
else
    echo "[ERROR] Unknown parameter."
    usage
    exit 1
fi
thread_num="4"

#remove all the logs of previous run
/bin/rm *.log &> /dev/null

for network in "${network_list[@]}"; do
    for desp in "${desp_list[@]}"; do
        model_file=$CAFFE_MODELS_DIR/${network}/${network}_float16_${desp}.caffemodel
        checkFile $model_file
        if [ $? -eq 1 ]; then
            continue
        fi

        echo "===================================================="
        echo "running ${network} online - ${ds_name},${desp}..."

        for batch in "${batch_list[@]}"; do
            for proto_file in $CAFFE_MODELS_DIR/${network}/${network}_${ds_name}*${desp}_${batch}.prototxt; do
                checkFile $proto_file
                if [ $? -eq 1 ]; then
                    continue
                fi

                for dpmp in "${dpmp_list[@]}"; do
                    dp=${dpmp:0:1}
                    mp=${dpmp:2:1}
                    do_run
                done
            done
        done
    done
done
