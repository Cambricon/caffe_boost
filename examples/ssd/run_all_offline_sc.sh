#!/bin/bash
# Parameter1 int8_mode: 1-int8; 0-float16

usage()
{
    echo "Usage:"
    echo "  $0 [0|1] [MLU270 | MLU220]"
    echo ""
    echo "  Parameter description:"
    echo "    0: run all networks with int16"
    echo "    1: run all networks with int8"
}

if [[ "$#" -ne 2 ]]; then
  echo "[ERROR] Unknown parameter."
  usage
  exit 1
fi


# config
core_version=$2
opt_level="1"
threshold=0.01

network_list=(
  ssd_vgg16
  ssd_mobilenetv1
  ssd_mobilenetv2
)

checkFile()
{
    if [ -f $1 ]; then
        return 0
    else
        echo $1
        return 1
    fi
}

do_run()
{

    echo "----------------------"
    echo "single core"
    echo "using prototxt: $proto_file"
    echo "using model:    $model_file"
    echo "core version:   $core_version"

    #first remove any offline model
    /bin/rm offline.cambricon* &> /dev/null

    log_file=$(echo $proto_file | sed 's/prototxt$/log/' | sed 's/^.*\///')
    echo > $CURRENT_DIR/$log_file

    genoff_cmd="$CAFFE_DIR/build/tools/caffe${SUFFIX} genoff \
        -model $proto_file \
        -weights $model_file \
        -mcore $core_version \
        -opt_level $opt_level &>> $CURRENT_DIR/$log_file"

    run_cmd="$CAFFE_DIR/build/examples/ssd/ssd_offline_singlecore$SUFFIX \
                  -offlinemodel $CURRENT_DIR/offline.cambricon \
                  -images $CURRENT_DIR/$FILE_LIST \
                  -outputdir $CURRENT_DIR/output \
                  -confidencethreshold $threshold \
                  -labelmapfile $CURRENT_DIR/labelmap_voc.prototxt &>> $CURRENT_DIR/$log_file"

    check_cmd="python $CAFFE_DIR/scripts/meanAP_VOC.py $CURRENT_DIR/$FILE_LIST $CURRENT_DIR/output $VOC_PATH &>> $CURRENT_DIR/$log_file"

    echo "genoff_cmd: $genoff_cmd" &>> $CURRENT_DIR/$log_file
    echo "run_cmd: $run_cmd" &>> $CURRENT_DIR/$log_file
    echo "check_cmd: $check_cmd" &>> $CURRENT_DIR/$log_file

    echo "generating offline model..."
    eval "$genoff_cmd"

    if [[ "$?" -eq 0 ]]; then
        echo "running offline test..."
        eval "$run_cmd"
        #tail -n 2 $CURRENT_DIR/$log_file
        grep "^Total execution time: " -A 2 $CURRENT_DIR/$log_file
        eval "$check_cmd"
        tail -n 1 $CURRENT_DIR/$log_file
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

/bin/rm *.jpg &> /dev/null
/bin/rm 200*.txt &> /dev/null
/bin/rm *.log &> /dev/null
/bin/rm -r output &> /dev/null
mkdir output &> /dev/null


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
