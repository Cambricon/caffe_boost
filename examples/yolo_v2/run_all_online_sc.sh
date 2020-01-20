#!/bin/bash
# Parameter1 quantize_option: 0-int16; 1-int8
# Parameter2 core_version: MLU270; MLU220

usage()
{
    echo "Usage:"
    echo "  $0 [0|1] [1|2] [MLU270 | MLU220]"
    echo ""
    echo "  Parameter description:"
    echo "    parameter1: int8 mode or int16 mode. 0:int16, 1:int8"
    echo "    parameter2: layer by layer or fusion. 1:layer by layer; 2:fusion"
}

checkFile()
{
    if [ -f $1 ]; then
        return 0
    else
        return 1
    fi
}

#used to enable Bangop or not, default is disabled
bang_option=1
core_version=$3

do_run()
{
    echo "----------------------"
    echo "single core"
    echo "using prototxt: $proto_file"
    echo "using model:    $model_file"

    /bin/rm -r result &> /dev/null
    if [[ "$bang_option" == "0" ]]; then
      log_file=$(echo $proto_file | sed 's/prototxt$/log/' | sed 's/^.*\///')
    else
      log_file=$(echo $proto_file | sed 's/prototxt$/log_Bangop/' | sed 's/^.*\///')
    fi
    echo > $CURRENT_DIR/$log_file

    run_cmd="$CAFFE_DIR/build/examples/yolo_v2/yolov2_online_singlecore$SUFFIX \
                  -model $proto_file \
                  -weights $model_file \
                  -labels $CURRENT_DIR/label_map.txt \
                  -images $CURRENT_DIR/$FILE_LIST \
                  -mmode $mlu_option \
                  -mcore $core_version \
                  -Bangop ${bang_option} \
                  -outputdir ${CURRENT_DIR}/output \
                  -preprocess_option 4 &>> $CURRENT_DIR/$log_file "

    check_cmd="python $CAFFE_DIR/scripts/meanAP_VOC.py $CURRENT_DIR/$FILE_LIST $CURRENT_DIR/output $VOC_PATH &>> $CURRENT_DIR/$log_file &>> $CURRENT_DIR/$log_file"

    echo "run_cmd: $run_cmd" &>> $CURRENT_DIR/$log_file
    echo "check_cmd: $check_cmd" &>> $CURRENT_DIR/$log_file

    echo "running online test..."
    eval "$run_cmd"
    grep "^Total execution time: " -A 1 $CURRENT_DIR/$log_file
    eval "$convert_cmd"
    eval "$check_cmd"
    tail -n 1 $CURRENT_DIR/$log_file
}

network_list=(
    yolov2
)

if [[ "$#" -ne 3 ]]; then
  echo "[ERROR] Unknown parameter."
  usage
  exit 1
fi

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

mlu_option=""
if [[ $2 -eq 1 ]]; then
    mlu_option="MLU"
elif [[ $2 -eq 2 ]]; then
    mlu_option="MFUS"
else
    echo "[ERROR] Unknown parameter."
    usage
    exit 1
fi

quantize_type=$1
ds_name=""
if [[ $quantize_type -eq 1 ]]; then
    ds_name="int8"
elif [[ $quantize_type -eq 0 ]]; then
    ds_name="int16"
else
    echo "[ERROR] Unknown parameter."
    usage
    exit 1
fi

/bin/rm *.jpg &> /dev/null
/bin/rm *00*.txt &> /dev/null
/bin/rm *.log &> /dev/null
/bin/rm -rf ${CURRENT_DIR}/output &> /dev/null
mkdir -p ${CURRENT_DIR}/output &> /dev/null

for network in "${network_list[@]}"; do
    model_file=$CAFFE_MODELS_DIR/${network}/${network}_${ds_name}_dense.caffemodel
    checkFile $model_file
    if [ $? -eq 1 ]; then
        continue
    fi

    echo "===================================================="
    echo "running ${network} offline - ${ds_name}..."
    for proto_file in $CAFFE_MODELS_DIR/${network}/${network}_${ds_name}*dense_1batch.prototxt; do
        checkFile $proto_file
        if [ $? -eq 1 ]; then
            continue
        fi

        do_run
    done
done
