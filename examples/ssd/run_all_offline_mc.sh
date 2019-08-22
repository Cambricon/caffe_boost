#!/bin/bash
# Parameter1 int8_mode: 1-int8; 0-float16

usage()
{
    echo "Usage:"
    echo "  $0 [0|1]"
    echo ""
    echo "  Parameter description:"
    echo "    0: run all networks with float16"
    echo "    1: run all networks with int8"
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
    echo "data_parallel:  $dp,  model_parallel:  $mp,  thread_num:  ${thread_num}"

    #first remove any offline model
    /bin/rm offline.cambricon* &> /dev/null

    log_file=$(echo $proto_file | sed 's/prototxt$/log/' | sed 's/^.*\///')
    echo > $CURRENT_DIR/$log_file

    genoff_cmd="$CAFFE_DIR/build/tools/caffe${SUFFIX} genoff -model $proto_file -weights $model_file -mcore MLU100 -model_parallel $mp &>> $CURRENT_DIR/$log_file"

    run_cmd="$CAFFE_DIR/build/examples/ssd/ssd_offline_multicore$SUFFIX -offlinemodel $CURRENT_DIR/offline.cambricon -images $CURRENT_DIR/$FILE_LIST -labelmapfile $CURRENT_DIR/ssd/labelmap_voc.prototxt -confidencethreshold 0.6 -dataparallel $dp -threads ${thread_num}  -dump 1 &>> $CURRENT_DIR/$log_file"

    check_cmd="python $CAFFE_DIR/scripts/meanAP_VOC.py $CURRENT_DIR/$FILE_LIST $CURRENT_DIR/ $VOC_PATH &>> $CURRENT_DIR/$log_file"

    echo "genoff_cmd: $genoff_cmd" &>> $CURRENT_DIR/$log_file
    echo "run_cmd: $run_cmd" &>> $CURRENT_DIR/$log_file
    echo "check_cmd: $check_cmd" &>> $CURRENT_DIR/$log_file

    echo "generating offline model..."
    eval "$genoff_cmd"

    if [[ "$?" -eq 0 ]]; then
        echo -e "running offline test...\n"
        eval "$run_cmd"
        grep "^Total execution time: " -A 2 $CURRENT_DIR/$log_file
        eval "$check_cmd"
        tail -n 1 $CURRENT_DIR/$log_file
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

dpmp_list=(
    '8 1'
    # '1 2'
    # '2 4'
    # '4 8'
)

network_list=(
    ssd
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
thread_num="4"

/bin/rm *.jpg &> /dev/null
/bin/rm 200*.txt &> /dev/null
/bin/rm *.log &> /dev/null

for network in "${network_list[@]}"; do
    for desp in "${desp_list[@]}"; do
        model_file=$CAFFE_MODELS_DIR/${network}/${network}_float16_${desp}.caffemodel
		checkFile $model_file
        if [ $? -eq 1 ]; then
            continue
        fi

        echo -e "\n===================================================="
        echo "running ${network} offline - ${ds_name},${desp}..."

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
