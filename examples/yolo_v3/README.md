---
title: YOLOv3 example
description: A simple example performing image detection using YOLOv3 interface of Cambricon SDK
category: example
include_in_docs: true
priority: 10
---

# Detecting COCO: using Cambricon Neuware Runtime API

Cambricon Neuware Runtime (CNRT) provides the ability to run neural networks without deep learning frameworks. This is an example of running detection network with CNRT API.

## Presentation

A simple C++ code is proposed in `caffe/examples/yolo_v3/yolov3_offline_singlecore.cpp`, `caffe/examples/yolo_v3/yolov3_offline_multicore.cpp`,`caffe/examples/yolo_v3/yolov3_online_singlecore.cpp`. For the sake of simplicity, this example does not support oversampling of a single sample nor batching of multiple independent samples. This example is not trying to reach the maximum possible detection throughput on a system, but special care was given to avoid unnecessary pessimization while keeping the code readable.

## Compiling

The C++ example is built automatically when compiling Caffe. To compile Caffe you should follow the documented instructions. The detection example will be built as `build/examples/yolo_v3/yolov3_offline_singlecore.bin`, `build/examples/yolo_v3/yolov3_offline_multicore.bin`,`build/examples/yolo_v3/yolov3_online_singlecore.bin` in your build directory.

## Usage

YOLOv3 can run a network with multiple cores in offline mode and single core in online mode. You need to prepare the requisites as described in the README.md file at caffe_boost directory before running the example. To run the example, we have created a script to simplify the process, i.e. `./run_all_offline_mc.sh`,`./run_all_offline_sc.sh` and `./run_all_online_sc.sh`. The command to execute the script is as follows:

### multiple cores in offline mode

```
./run_all_offline_mc.sh args1 args2
```
Where the `args1` has two options: 0 or 1, 0 represents that YOLOv3 run with int16 data format and 1 represents that YOLOv3 run with int8 data format.

where the `args2` has two options: MLU270 or MLU220, MLU270 represents that detection networks run on MLU270 device and MLU220 represents that all detection networks run on MLU220 device.

The output should look like this:
```
====================================================
running yolov3 offline - int8...
----------------------
multiple core
using prototxt: yolov3_int8.prototxt
using model:    yolov3_int8.caffemodel
core version:   MLU270,  batchsize:  16,  core_number:  16
generating offline model...
running offline test...
yolov3_detection() execution time: 8.07997e+06 us
throughput: 168.387
Latency: 95019.45
 Average Precision  (AP) @[ IoU=0.50:0.95 | area=   all | maxDets=100 ] = 0.394
 Average Precision  (AP) @[ IoU=0.50      | area=   all | maxDets=100 ] = 0.711
 Average Precision  (AP) @[ IoU=0.75      | area=   all | maxDets=100 ] = 0.397
 Average Precision  (AP) @[ IoU=0.50:0.95 | area= small | maxDets=100 ] = 0.208
 Average Precision  (AP) @[ IoU=0.50:0.95 | area=medium | maxDets=100 ] = 0.445
 Average Precision  (AP) @[ IoU=0.50:0.95 | area= large | maxDets=100 ] = 0.555
 Average Recall     (AR) @[ IoU=0.50:0.95 | area=   all | maxDets=  1 ] = 0.308
 Average Recall     (AR) @[ IoU=0.50:0.95 | area=   all | maxDets= 10 ] = 0.473
 Average Recall     (AR) @[ IoU=0.50:0.95 | area=   all | maxDets=100 ] = 0.491
 Average Recall     (AR) @[ IoU=0.50:0.95 | area= small | maxDets=100 ] = 0.286
 Average Recall     (AR) @[ IoU=0.50:0.95 | area=medium | maxDets=100 ] = 0.537
 Average Recall     (AR) @[ IoU=0.50:0.95 | area= large | maxDets=100 ] = 0.642
```
### single core in offline mode

```
./run_all_offline_sc.sh args1 args2
```
Where the `args1` has two options: 0 or 1, 0 represents that YOLOv3 run with int16 data format and 1 represents that YOLOv3 run with int8 data format.

where the `args2` has two options: MLU270 or MLU220, MLU270 represents that detection networks run on MLU270 device and MLU220 represents that all detection networks run on MLU220 device.

The output should look like this:
```
====================================================
running yolov3 offline - int8,...
----------------------
single core
using prototxt: yolov3_int8.prototxt
using model:    yolov3_int8.caffemodel
core version:   MLU270
generating offline model...
running offline test...
Total execution time: 8.50237e+07 us
mluTime time: 2.97418e+07 us
throughput: 33.6227
 Average Precision  (AP) @[ IoU=0.50:0.95 | area=   all | maxDets=100 ] = 0.394
 Average Precision  (AP) @[ IoU=0.50      | area=   all | maxDets=100 ] = 0.712
 Average Precision  (AP) @[ IoU=0.75      | area=   all | maxDets=100 ] = 0.397
 Average Precision  (AP) @[ IoU=0.50:0.95 | area= small | maxDets=100 ] = 0.207
 Average Precision  (AP) @[ IoU=0.50:0.95 | area=medium | maxDets=100 ] = 0.445
 Average Precision  (AP) @[ IoU=0.50:0.95 | area= large | maxDets=100 ] = 0.556
 Average Recall     (AR) @[ IoU=0.50:0.95 | area=   all | maxDets=  1 ] = 0.308
 Average Recall     (AR) @[ IoU=0.50:0.95 | area=   all | maxDets= 10 ] = 0.472
 Average Recall     (AR) @[ IoU=0.50:0.95 | area=   all | maxDets=100 ] = 0.492
 Average Recall     (AR) @[ IoU=0.50:0.95 | area= small | maxDets=100 ] = 0.286
 Average Recall     (AR) @[ IoU=0.50:0.95 | area=medium | maxDets=100 ] = 0.538
 Average Recall     (AR) @[ IoU=0.50:0.95 | area= large | maxDets=100 ] = 0.642
```
### single core in online mode

```
./run_all_online_sc.sh args1 args2 args3
```
Where the `args1` has two options: 0 or 1, 0 represents that YOLOv3 run with int16 data format and 1 represents that YOLOv3 run with int8 data format.

Where the `args2` has two options: 1 or 2, 1 represents that YOLOv3 run layer by layer and 2 represents that YOLOv3 run fusion.

where the `args3` has two options: MLU270 or MLU220, MLU270 represents that detection networks run on MLU270 device and MLU220 represents that all detection networks run on MLU220 device.

The output should look like this:
```
====================================================
running yolov3 offline - int8,...
----------------------
single core
using prototxt: yolov3_int8.prototxt
using model:    yolov3_int8.caffemodel
core version:   MLU270
running online test...
yolov3_detection() execution time: 7.83434e+07 us
throughput: 33.6923
 Average Precision  (AP) @[ IoU=0.50:0.95 | area=   all | maxDets=100 ] = 0.394
 Average Precision  (AP) @[ IoU=0.50      | area=   all | maxDets=100 ] = 0.712
 Average Precision  (AP) @[ IoU=0.75      | area=   all | maxDets=100 ] = 0.397
 Average Precision  (AP) @[ IoU=0.50:0.95 | area= small | maxDets=100 ] = 0.207
 Average Precision  (AP) @[ IoU=0.50:0.95 | area=medium | maxDets=100 ] = 0.445
 Average Precision  (AP) @[ IoU=0.50:0.95 | area= large | maxDets=100 ] = 0.556
 Average Recall     (AR) @[ IoU=0.50:0.95 | area=   all | maxDets=  1 ] = 0.308
 Average Recall     (AR) @[ IoU=0.50:0.95 | area=   all | maxDets= 10 ] = 0.472
 Average Recall     (AR) @[ IoU=0.50:0.95 | area=   all | maxDets=100 ] = 0.492
 Average Recall     (AR) @[ IoU=0.50:0.95 | area= small | maxDets=100 ] = 0.286
 Average Recall     (AR) @[ IoU=0.50:0.95 | area=medium | maxDets=100 ] = 0.538
 Average Recall     (AR) @[ IoU=0.50:0.95 | area= large | maxDets=100 ] = 0.642
```
