#!/bin/bash
# Parameter1 int8_mode: 1-int8; 0-float16

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
    yolov3
)

bscn_list=(
  # '1  1 '
  # '16  4 '
  # '1  16 '
   '16 16'
  # '32 16'
  # '64 16'
)
if [ 'MLU220' == $core_version ]; then
  bscn_list=(
   #  '1  1'
   #  '1  4'
   #  '4  4'
     '16  4'
  )
fi

do_run()
{
    echo "----------------------"
    echo "multiple core"
    echo "using prototxt: $proto_file"
    echo "using model:    $model_file"
    echo "core version:   $core_version,  batchsize:  $batchsize,  core_number:  $core_number"

    #first remove any offline model
    /bin/rm offline.cambricon* &> /dev/null

    log_file=$(echo $proto_file | sed 's/prototxt$/log/' | sed 's/^.*\///')

    genoff_cmd="$CAFFE_DIR/build/tools/caffe${SUFFIX} genoff -model $proto_file -weights $model_file -mcore $core_version"
    concurrent_genoff=" -batchsize $batchsize -core_number $core_number -simple_compile 1 &>> $CURRENT_DIR/$log_file"
    genoff_cmd="$genoff_cmd $concurrent_genoff"

    run_cmd="$CAFFE_DIR/build/examples/yolo_v3/yolov3_offline_multicore$SUFFIX \
                  -offlinemodel $CURRENT_DIR/offline.cambricon \
                  -images $CURRENT_DIR/$FILE_LIST \
                  -labels $CURRENT_DIR/bbox_anchor/label_map_coco.txt \
                  -dump 1"
    concurrent_run="-simple_compile 1 &>> $CURRENT_DIR/$log_file"
    run_cmd="$run_cmd $concurrent_run"

    check_cmd="python $CAFFE_DIR/scripts/meanAP_COCO.py  --file_list $CURRENT_DIR/$FILE_LIST --result_dir $CURRENT_DIR/ --ann_dir  $COCO_PATH &>> $CURRENT_DIR/$log_file"

    echo "genoff_cmd: $genoff_cmd" &>> $CURRENT_DIR/$log_file
    echo "run_cmd: $run_cmd" &>> $CURRENT_DIR/$log_file
    echo "check_cmd: $check_cmd" &>> $CURRENT_DIR/$log_file

    echo "generating offline model..."
    eval "$genoff_cmd"

    if [[ "$?" -eq 0 ]]; then
        echo "running offline test..."
        eval "$run_cmd"
        #tail -n 3  $CURRENT_DIR/$log_file
        grep "^yolov3_detection() execution time:" -A 2 $CURRENT_DIR/$log_file
        eval "$check_cmd"
        tail -n 12 $CURRENT_DIR/$log_file
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
confidence=0.5
bbox_anchor_path="$CURRENT_DIR/bbox_anchor"

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
