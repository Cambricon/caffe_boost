network_list=(
    googlenet
    mobilenet_v1
    mobilenet_v2
    resnet101
    resnet152
    resnet18
    resnet34
    resnet50
    vgg16
    vgg19
    squeezenet_v1.0
    squeezenet_v1.1
    inception-v3
    alexnet
    rfcn
    yolov3
    yolov2
    ssd
)

do_run()
{
    echo "----------------------"
    echo "single core"
    echo "using prototxt: $proto_file"
    echo "using model:    $model_file"

    log_file=$(echo $proto_file | sed 's/prototxt$/log/' | sed 's/^.*\///')
    echo > $CURRENT_DIR/$log_file
    run_cmd="./../../build/tools/generate_quantized_pt -ini_file ${network}_quantized.ini -mode common -model $proto_file -weights $weight_file -outputmodel ./${network}_int8_scale_dense_1batch.prototxt"

    echo "run_cmd: $run_cmd" &>> $CURRENT_DIR/$log_file
    eval "$run_cmd"
}

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

#remove all the logs of previous run
/bin/rm *.log &> /dev/null
ds_name="float16"
for network in "${network_list[@]}"; do
    weight_file=$CAFFE_MODELS_DIR/${network}/${network}_int8_dense.caffemodel
    for proto_file in $CAFFE_MODELS_DIR/${network}/${network}_float16_dense_1batch.prototxt; do
        checkFile $proto_file
        if [ $? -eq 1 ]; then
            continue
        fi
        do_run
    done
done
