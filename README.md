# Caffe Boost
Caffe Boost includes scripts running demo programs, downloading library set, and generating image list. Demo programs for both classification and detection are provided.  

## Prerequisites
Please clone Cambricon Caffe and Caffe Boost repository, download ImageNet, COCO and VOC2012 datasets.

### Cambricon Caffe
Please download [Cambricon Caffe](https://github.com/Cambricon/caffe) from repository:

* **For serials of MLU100:**

You need to switch to the master branch.

```
git clone git@github.com:Cambricon/caffe.git
git checkout master
```

* **For serials of MLU270:**

You need to switch to the cambricon_caffe_mlu270 branch.

```
git clone git@github.com:Cambricon/caffe.git
git checkout cambricon_caffe_mlu270
```

Then build Cambricon Caffe. Please refer to instructions listed in Cambricon Caffe repository.

### Caffe Boost
Please download [Caffe Boost](https://github.com/Cambricon/caffe_boost) from repository:

* **For serials of MLU100:**

You need to switch to the master branch first, and see the README.md for how to use it.

```
git clone git@github.com:Cambricon/caffe_boost.git
git checkout master
```

* **For serials of MLU270:**

You need to switch to the cambricon_caffe_mlu270 branch first, and see the README.md for how to use it.

```
git clone git@github.com:Cambricon/caffe_boost.git
git checkout cambricon_caffe_mlu270
```

### Datasets
ImageNet, COCO and VOC2012 validation datasets are needed to run the demo programs.so you may need to download them before running demo programs.

#### ImageNet
Please download [ILSVRC 2012](http://image-net.org/challenges/LSVRC/2012/index) for validation data and [caffe_ilsvrc12](http://dl.caffe.berkeleyvision.org).

#### VOC2012
Please download [VOC 2012](http://host.robots.ox.ac.uk/pascal/VOC) for validation data.

#### COCO
Please download [COCO val2017 and annotations 2017](http://cocodataset.org) for validation data.

### Directory Layout
The structure of directory is shown as below:  
```
-caffe  
-caffe_boost   
　　-examples  
　　-scripts  
-datasets  
　　-IMAGENET  
　　　　-ILSVRC2012_img_val
　　　　-caffe_ilsvrc12
　　-VOC2012  
　　　　-Annotations  
　　　　-ImageSets  
　　　　-JPEGImages  
　　　　-SegmentationClass  
　　　　-SegmentationObject  
　　-COCO  
　　　　-val2017  
　　　　-annotations  
-caffe_mp
　　-alexnet
　　-googlenet
　　-inception-v3
　　-mobilenet
　　-resnet101
　　-resnet152
　　-resnet18
　　-resnet34
　　-resnet50
　　-squeezenet
　　-ssd
　　-vgg16
　　-vgg19
　　-yolov2
　　-yolov3
```
Demo program scripts assume above structure and respective prototxt and model file names.

## Generating File List
Please generate the file list before running the example. It can be done by running script **gen_val.sh**. It has 3 parameters, which are dataset_type, val_path and image_path.
> Usage:
>　　./gen_val.sh [dataset_type] [val_path] [image_path]
> 
>　　Parameter description:  
>　　dataset_type: the type of datasets, eg:imagenet, voc, coco  
>　　val_path: the path of val.txt, this parameter is only for imagenet and voc  
>　　image_path: the path of image.
> 
>　　example:
>    ```sh
>       <imagenet> ./gen_val.sh imagenet ../../datasets/IMAGENET/caffe_ilsvrc12/val.txt ../../datasets/IMAGENET/ILSVRC2012_img_val
>
>       <voc>      ./gen_val.sh voc ../../datasets/VOC2012/ImageSets/Main/val.txt ../../datasets/VOC2012/JPEGImages 
>
>       <coco>     ./gen_val.sh coco ../../datasets/COCO/val2017
>    ```
## Running
To run the example on platform x86, please go to **examples** folder.
Cambricon Caffe supports running a network with multiple cores in either offline or online mode.
- run_all_offline_mc.sh: running networks with multiple cores in offline mode.
- run_all_offline_sc.sh: running networks with single core in offline mode.
- run_all_online_sc.sh: running networks with single core in online mode.

### Environment Setup
You need to setup some environment variables so that scripts could find Cambricon Caffe binaries and datasets. There are 2 environment variables, please setup them according to below commands:
```
export CAFFE_EXTERNAL=Y
export CAFFE_DIR=your_cambriconcaffe_path  // please replace your_cambriconcaffe_path with your actual path
```

### x86
e.g. Please go to clas_offline_singlecore directory if you'd like to run networks with single core in offline mode. Argument 0 means that the network is run in float16 mode.
```
cd caffe_boost/examples/clas_offline_singlecore
./run_all_offline_sc.sh 0
```

### arm32 & arm64
For arm32 and arm64 platform, firstly, please compile Cambricon Caffe. You could refer to [Cambricon Caffe](https://github.com/Cambricon/caffe).  Secondly, copy the corresponding files to your running environment. You also could use script **package_arm.sh** to package all necessary files. In addition, you may need to copy datasets and other supporting files to your environment.
> Usage:
>　　./package_arm.sh [1|2]
> 
>　　Parameter description:  
>　　　　1:arm32  
>　　　　2:arm64  
```
./package_arm.sh 1
```
 You could run example using the following command:
```
cd caffe_boost/examples/clas_offline_singlecore
./run_all_offline_sc.sh 0
```
