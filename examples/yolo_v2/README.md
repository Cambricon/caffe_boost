---
title: YOLOv2 example
description: A simple example performing image detection using YOLOv2 interface of Cambricon SDK
category: example
include_in_docs: true
priority: 10
---

# Detecting VOC: using Cambricon Neuware Runtime API

Cambricon Neuware Runtime (CNRT) provides the ability to run neural networks without deep learning frameworks. This is an example of running detection network with CNRT API.

## Presentation

A simple C++ code is proposed in `caffe/examples/yolo_v2/yolov2_offline_singlecore.cpp`,`caffe/examples/yolo_v2/yolov2_offline_multicore.cpp`,`caffe/examples/yolo_v2/yolov2_online_singlecore.cpp` and `caffe/examples/yolo_v2/yolov2_online_multicore.cpp`. For the sake of simplicity, this example does not support oversampling of a single sample nor batching of multiple independent samples. This example is not trying to reach the maximum possible detection throughput on a system, but special care was given to avoid unnecessary pessimization while keeping the code readable.

## Compiling

The C++ example is built automatically when compiling Caffe. To compile Caffe you should follow the documented instructions. The detection example will be built as `build/examples/yolo_v2/yolov2_offline_singlecore.bin`,`build/examples/yolo_v2/yolov2_offline_multicore.bin`, `build/examples/yolo_v2/yolov2_online_singlecore.bin` and `build/examples/yolo_v2/yolov2_online_multicore.bin` in your build directory.

## Usage

YOLOv2 can run a network with multiple cores in offline mode and single core in online mode. You need to prepare the requisites as described in the README.md file at caffe_boost directory before running the example. To run the example, we have created a script to simplify the process, i.e. `./run_all_offline_mc.sh`,`./run_all_offline_sc.sh`, `./run_all_online_sc.sh` and `./run_all_online_mc.sh`. The command to execute the script is as follows:

### multiple cores in offline mode

```
./run_all_offline_mc.sh args1 args2 args3
```
where the `args1` has two options: 0 or 1, 0 represents that detection networks run with int16 data format and 1 represents that all detection networks run with int8 data format.

where the `args2` has two options: MLU270 or MLU220, MLU270 represents that detection networks run on MLU270 device and MLU220 represents that all detection networks run on MLU220 device.

The output should look like this:
```
====================================================
running yolov2 offline - int8, Bangop...
----------------------
multiple core
using prototxt: yolov2_int8.prototxt
using model:    yolov2_int8.caffemodel
batchsize:  16,  core_number:  16
generating offline model...
running offline test...
Total execution time: 2.29263e+07 us
throughput: 551.429
Latency: 29015.50
mAP: 0.775260
```
### single core in offline mode

```
./run_all_offline_sc.sh args1 args2
```
where the `args1` has two options: 0 or 1, 0 represents that detection networks run with int16 data format and 1 represents that all detection networks run with int8 data format.

where the `args2` has two options: MLU270 or MLU220, MLU270 represents that detection networks run on MLU270 device and MLU220 represents that all detection networks run on MLU220 device.

The output should look like this:
```
====================================================
running yolov2 offline - int8,...
----------------------
single core
using prototxt: yolov2_int8.prototxt
using model:    yolov2_int8.caffemodel
generating offline model...
running offline test...
Total execution time: 3.61047e+08 us
throughput: 78.4168
Latency: 12752.36
mAP: 0.775701
```
### single core in online mode

```
./run_all_online_sc.sh args1 args2 args3
```
where the `args1` has two options: 0 or 1, 0 represents that YOLOv2 run with int16 data format and 1 represents that YOLOv2 run with int8 data format.

Where the `args2` has two options: 1 or 2, 1 represents that YOLOv2 run layer by layer and 2 represents that YOLOv2 run fusion.

where the `args3` has two options: MLU270 or MLU220, MLU270 represents that detection networks run on MLU270 device and MLU220 represents that all detection networks run on MLU220 device.

The output should look like this:
```
====================================================
running yolov2 offline - int8, Bangop...
----------------------
single core
using prototxt: yolov2_int8.prototxt
using model:    yolov2_int8.caffemodel
running online test...
Total execution time: 7.155e+08 us
End2end throughput fps: 6.92104
mAP: 0.775701
```
### multiple core in online mode

```
./run_all_online_mc.sh args1 args2 args3
```
where the `args1` has two options: 0 or 1, 0 represents that YOLOv2 run with int16 data format and 1 represents that YOLOv2 run with int8 data format.

Where the `args2` has two options: 1 or 2, 1 represents that YOLOv2 run layer by layer and 2 represents that YOLOv2 run fusion.

where the `args3` has two options: MLU270 or MLU220, MLU270 represents that detection networks run on MLU270 device and MLU220 represents that all detection networks run on MLU220 device.

The output should look like this:
```
====================================================
running yolov2 online - int8,...
----------------------
multiple core
using prototxt: yolov2_int8.prototxt
using model:    yolov2_int8.caffemodel
core_version:   MLU270,  batchsize:  16,  core_number:  16
running online test...

Total execution time: 3.23494e+07 us
throughput: 550.452
Latency: 29067.04
mAP: 0.775701
```
