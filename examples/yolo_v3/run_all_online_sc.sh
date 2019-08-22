#!/bin/bash
# Parameter1 int8_mode: 1-int8; 0-float16
# Parameter2 mlu_option: 1-mlu; 2-mfus

usage()
{
    echo "Usage:"
    echo "  $0 [0|1] [1|2]"
    echo ""
    echo "  Parameter description:"
    echo "    parameter1: int8 mode or float16 mode. 0:float16, 1:int8"
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

do_run()
{
    echo "----------------------"
    echo "single core"
    echo "using prototxt: $proto_file"
    echo "using model:    $model_file"
    log_file=$(echo $proto_file | sed 's/prototxt$/log/' | sed 's/^.*\///')
    echo > $CURRENT_DIR/$log_file

    run_cmd="$CAFFE_DIR/build/examples/yolo_v3/yolov3_online_singlecore$SUFFIX \
                  -model $proto_file \
                  -weights $model_file \
                  -labels $CURRENT_DIR/bbox_anchor/label_map_coco.txt \
                  -images $CURRENT_DIR/$FILE_LIST \
                  -mmode $mlu_option \
                  -mcore MLU100  \
                  -outputdir $CURRENT_DIR  \
                  -bboxanchordir $bbox_anchor_path \
                  -dump 1 \
                  -confidence $confidence &>> $CURRENT_DIR/$log_file"
    check_cmd="python $CAFFE_DIR/scripts/meanAP_COCO.py  --file_list $CURRENT_DIR/$FILE_LIST --result_dir $CURRENT_DIR/ --ann_dir  $COCO_PATH &>> $CURRENT_DIR/$log_file"

    echo "run_cmd: $run_cmd" &>> $CURRENT_DIR/$log_file
    echo "check_cmd: $check_cmd" &>> $CURRENT_DIR/$log_file

    echo "running online test..."
    eval "$run_cmd"
    grep "^yolov3_detection() execution time:" -A 1 $CURRENT_DIR/$log_file
    eval "$check_cmd"
    tail -n 12 $CURRENT_DIR/$log_file
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
    yolov3
)

if [[ "$#" -ne 2 ]]; then
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

int8_mode=$1
confidence=0.5
bbox_anchor_path=$CURRENT_DIR/bbox_anchor
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

/bin/rm *.jpg &> /dev/null
/bin/rm 000*.txt &> /dev/null
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
