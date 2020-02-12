#!/bin/bash
# Parameter1 quantize_type: 1-int8; 0-int16
# Parameter2 core_version: MLU270; MLU220

usage()
{
    echo "Usage:"
    echo "  $0 [0|1] [MLU220|MLU270]"
    echo ""
    echo "  Parameter description:"
    echo "    parameter1: int8 mode or int16 mode. 0:int16, 1:int8"
    echo "    parameter2: core version: MLU270 or MLU220"
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

# used to enable Bangop or not,default is disabled
bang_option=1
core_version=$2

do_run()
{
    echo "----------------------"
    echo "multiple core"
    echo "using prototxt: $proto_file"
    echo "using model:    $model_file"
    echo "batchsize:  $batchsize,  core_number:  $core_number"

    #first remove any offline model
    /bin/rm offline.cambricon* &> /dev/null

    log_file=$(echo $proto_file | sed 's/prototxt$/log/' | sed 's/^.*\///')
    echo > $CURRENT_DIR/$log_file

    genoff_cmd="$CAFFE_DIR/build/tools/caffe${SUFFIX} genoff -model $proto_file -weights $model_file -mcore $core_version -Bangop $bang_option"
    concurrent_genoff=" -batchsize $batchsize -core_number $core_number -simple_compile 1 &>> $CURRENT_DIR/$log_file"
    genoff_cmd="$genoff_cmd $concurrent_genoff"

    run_cmd="$CAFFE_DIR/build/examples/rfcn/rfcn_offline_multicore$SUFFIX \
                   -offlinemodel $CURRENT_DIR/offline.cambricon \
                   -images $CURRENT_DIR/$FILE_LIST \
                   -Bangop $bang_option \
                   -dump 1"
    concurrent_run="-simple_compile 1 &>> $CURRENT_DIR/$log_file"
    run_cmd="$run_cmd $concurrent_run"

    check_cmd="python $CAFFE_DIR/scripts/meanAP_VOC.py $CURRENT_DIR/$FILE_LIST $CURRENT_DIR/ $VOC_PATH &>> $CURRENT_DIR/$log_file"

    echo "genoff_cmd: $genoff_cmd" &>> $CURRENT_DIR/$log_file
    echo "run_cmd: $run_cmd" &>> $CURRENT_DIR/$log_file
    echo "check_cmd: $check_cmd" &>> $CURRENT_DIR/$log_file

    echo "generating offline model..."
    eval "$genoff_cmd"

    if [[ "$?" -eq 0 ]]; then
        echo "running offline test..."
        eval "$run_cmd"
        #tail -n 3 $CURRENT_DIR/$log_file
        grep "^Total execution time:" -A 2 $CURRENT_DIR/$log_file
        eval "$check_cmd"
        tail -n 1 $CURRENT_DIR/$log_file
    else
        echo "generating offline model failed!"
    fi
}

# rfcn: batchsize must be equal to core_number
bscn_list=(
   # '1  1 '
   # '1  4 '
   # '1  16'
   # '4  16'
   # '8  16'
   '16 16'
   # '32 16'
)
if [[ 'MLU220' == $core_version ]]; then
  bscn_list=(
   #  '1  1'
   #  '1  4'
   #  '4  4'
     '16  4'
  )
fi

network_list=(
    rfcn
)

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
/bin/rm 200*.txt &> /dev/null
/bin/rm *.log &> /dev/null

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
		    for bscn in "${bscn_list[@]}"; do
		        batchsize=${bscn:0:2}
		        core_number=${bscn:3:2}
		        do_run
		    done
	  done
done
