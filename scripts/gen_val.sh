#!/bin/bash

# example:
# <imagenet> ./gen_val.sh imagenet ../dataset/imagenet/val.txt ../dataset/imagenet
# <voc> ./gen_val.sh voc ../dataset/VOC2012/ImageSets/Main/val.txt ../dataset/VOC2012/JPEGImages
# <coco> ./gen_val.sh coco ../dataset/COCO/val2017

function usage
{
    echo "Usage:"
    echo "  $0 [dataset_type] [val_path] [image_path]"
    echo ""
    echo "  Parameter description:"
    echo "    dataset_type: the type of dataset, eg:imagenet, voc, coco"
    echo "    val_path: the path of val.txt, this parameter only for imagenet and voc"
    echo "    image_path: the path of image."
    echo ""
    echo "  Example:"
    echo "      <imagenet> $0 imagenet ../dataset/imagenet/val.txt ../dataset/imagenet"
    echo "      <imagenet_2015> $0 imagenet ../dataset/imagenet_2015/val.txt ../dataset/imagenet_2015"
    echo "      <voc> $0 voc ../dataset/VOC2012/ImageSets/Main/val.txt ../dataset/VOC2012/JPEGImages"
    echo "      <coco> $0 coco ../dataset/COCO/val2017"
}

# check the path of validation
function checkPath
{
    if [ ! -d $1 ] && [ ! -f $1 ]; then
        echo "[Error] $1 diesn't exist"
        exit 1
    fi

}

# check valid image path
function checkValidImage
{
    first_img=`sed -n '1p' $1`
    img_path=${first_img%\ *}
    checkPath $img_path
}

cur_path=$(dirname $(readlink -f $0))
checkPath $2
if [[ "$1" == "imagenet" || "$1" == "imagenet_2015" || "$1" == "voc" ]]; then
    if [ $# -ne 3 ]; then
        echo "[Error] The number of parameters should be 3 for imagenet and voc"
        usage
        exit 1
    fi

    checkPath $3
    image_path=$(cd $3;pwd)

    # imagenet
    if [ "$1" == "imagenet" ]; then
        # fill the full path for image
        sed -n "1,1000s!^!$image_path/!w $cur_path/imagenet_val" $2
        checkValidImage $cur_path/imagenet_val

        cp $cur_path/imagenet_val $cur_path/../examples/clas_offline_multicore/file_list
        cp $cur_path/imagenet_val $cur_path/../examples/clas_online_multicore/file_list
        cp $cur_path/imagenet_val $cur_path/../examples/clas_offline_singlecore/file_list 
        cp $cur_path/imagenet_val $cur_path/../examples/clas_online_singlecore/file_list
    fi

    # imagenet_2015
    if [ "$1" == "imagenet_2015" ]; then
        # fill the full path for image
        sed -n "1,1000s!^!$image_path/!w $cur_path/imagenet_2015_val" $2
        checkValidImage $cur_path/imagenet_2015_val

        cp $cur_path/imagenet_2015_val $cur_path/../examples/clas_offline_multicore/file_list_2015
        cp $cur_path/imagenet_2015_val $cur_path/../examples/clas_online_multicore/file_list_2015
        cp $cur_path/imagenet_2015_val $cur_path/../examples/clas_offline_singlecore/file_list_2015 
        cp $cur_path/imagenet_2015_val $cur_path/../examples/clas_online_singlecore/file_list_2015
    fi
    
    # voc
    if [ "$1" == "voc" ]; then
        sed -n "s!^!$image_path/!;1,1000s/$/.jpg/w $cur_path/voc_val" $2
        checkValidImage $cur_path/voc_val

        cp $cur_path/voc_val $cur_path/../examples/ssd/file_list
        cp $cur_path/voc_val $cur_path/../examples/rfcn/file_list
        cp $cur_path/voc_val $cur_path/../examples/yolo_v2/file_list
    fi
elif [ "$1" == "coco" ]; then
    if [ $# -ne 2 ]; then
        echo "[Error] The number of parameters should be 3 for imagenet"
        usage
        exit 1
    fi

    image_path=$(cd $2;pwd)
    # for coco, filter jpg to file because of no val file
    find $image_path -type f -iname "*.jpg" > $cur_path/coco_val
    sed -n -i '1,1000p' $cur_path/coco_val
    checkValidImage $cur_path/coco_val

    cp $cur_path/coco_val $cur_path/../examples/yolo_v3/file_list
else
    echo "[Error] Invalid parameter."
    usage
    exit 1
fi
