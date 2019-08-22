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
./run_all_offline_mc.sh args
```
Where `args` has two options: 0 or 1, 0 represents that YOLOv3 run with float16 data format and 1 represents that YOLOv3 run with int8 data format.

The output should look like this:
```
====================================================
running yolov3 offline - int8,dense...
----------------------
multiple core
using prototxt: some.prototxt
using model:    some.caffemodel
data_parallel:  8,  model_parallel:  1,  thread_num:  4
generating offline model...
running offline test...
yolov3_detection() execution time: 1.92755e+07 us
Hardware fps: 199.673
End2end throughput fps: 51.8794
 Average Precision  (AP) @[ IoU=0.50:0.95 | area=   all | maxDets=100 ] = 0.292
 Average Precision  (AP) @[ IoU=0.50      | area=   all | maxDets=100 ] = 0.483
 Average Precision  (AP) @[ IoU=0.75      | area=   all | maxDets=100 ] = 0.327
 Average Precision  (AP) @[ IoU=0.50:0.95 | area= small | maxDets=100 ] = 0.076
 Average Precision  (AP) @[ IoU=0.50:0.95 | area=medium | maxDets=100 ] = 0.323
 Average Precision  (AP) @[ IoU=0.50:0.95 | area= large | maxDets=100 ] = 0.497
 Average Recall     (AR) @[ IoU=0.50:0.95 | area=   all | maxDets=  1 ] = 0.243
 Average Recall     (AR) @[ IoU=0.50:0.95 | area=   all | maxDets= 10 ] = 0.322
 Average Recall     (AR) @[ IoU=0.50:0.95 | area=   all | maxDets=100 ] = 0.324
 Average Recall     (AR) @[ IoU=0.50:0.95 | area= small | maxDets=100 ] = 0.080
 Average Recall     (AR) @[ IoU=0.50:0.95 | area=medium | maxDets=100 ] = 0.348
 Average Recall     (AR) @[ IoU=0.50:0.95 | area= large | maxDets=100 ] = 0.540
```
### single core in offline mode

```
./run_all_offline_sc.sh args
```
Where `args` has two options: 0 or 1, 0 represents that YOLOv3 run with float16 data format and 1 represents that YOLOv3 run with int8 data format.

The output should look like this:
```
====================================================
running yolov3 offline - int8,dense...
----------------------
single core
using prototxt: some.prototxt
using model:    some.caffemodel
generating offline model...
running offline test...
Total execution time: 2.6009e+08 us
Hardware fps: 8.81572
End2end throughput fps: 3.84482
 Average Precision  (AP) @[ IoU=0.50:0.95 | area=   all | maxDets=100 ] = 0.292
 Average Precision  (AP) @[ IoU=0.50      | area=   all | maxDets=100 ] = 0.483
 Average Precision  (AP) @[ IoU=0.75      | area=   all | maxDets=100 ] = 0.327
 Average Precision  (AP) @[ IoU=0.50:0.95 | area= small | maxDets=100 ] = 0.076
 Average Precision  (AP) @[ IoU=0.50:0.95 | area=medium | maxDets=100 ] = 0.323
 Average Precision  (AP) @[ IoU=0.50:0.95 | area= large | maxDets=100 ] = 0.497
 Average Recall     (AR) @[ IoU=0.50:0.95 | area=   all | maxDets=  1 ] = 0.243
 Average Recall     (AR) @[ IoU=0.50:0.95 | area=   all | maxDets= 10 ] = 0.322
 Average Recall     (AR) @[ IoU=0.50:0.95 | area=   all | maxDets=100 ] = 0.324
 Average Recall     (AR) @[ IoU=0.50:0.95 | area= small | maxDets=100 ] = 0.080
 Average Recall     (AR) @[ IoU=0.50:0.95 | area=medium | maxDets=100 ] = 0.348
 Average Recall     (AR) @[ IoU=0.50:0.95 | area= large | maxDets=100 ] = 0.540
```
### single core in online mode

```
./run_all_online_sc.sh arg1 arg2
```
Where the  `arg1` has two options: 0 or 1, 0 represents that YOLOv3 run with float16 data format and 1 represents that YOLOv3 run with int8 data format.
Where the  `arg2` has two options: 1 or 2, 1 represents that YOLOv3 run layer by layer and 2 represents that YOLOv3 run fusion.

The output should look like this:
```
====================================================
running yolov3 offline - int8,dense...
----------------------
single core
using prototxt: some.prototxt
using model:    some.caffemodel
running online test...
yolov3_detection() execution time: 2.28554e+08 us
End2end throughput fps: 4.37533
 Average Precision  (AP) @[ IoU=0.50:0.95 | area=   all | maxDets=100 ] = 0.292
 Average Precision  (AP) @[ IoU=0.50      | area=   all | maxDets=100 ] = 0.483
 Average Precision  (AP) @[ IoU=0.75      | area=   all | maxDets=100 ] = 0.327
 Average Precision  (AP) @[ IoU=0.50:0.95 | area= small | maxDets=100 ] = 0.076
 Average Precision  (AP) @[ IoU=0.50:0.95 | area=medium | maxDets=100 ] = 0.323
 Average Precision  (AP) @[ IoU=0.50:0.95 | area= large | maxDets=100 ] = 0.497
 Average Recall     (AR) @[ IoU=0.50:0.95 | area=   all | maxDets=  1 ] = 0.243
 Average Recall     (AR) @[ IoU=0.50:0.95 | area=   all | maxDets= 10 ] = 0.322
 Average Recall     (AR) @[ IoU=0.50:0.95 | area=   all | maxDets=100 ] = 0.324
 Average Recall     (AR) @[ IoU=0.50:0.95 | area= small | maxDets=100 ] = 0.080
 Average Recall     (AR) @[ IoU=0.50:0.95 | area=medium | maxDets=100 ] = 0.348
 Average Recall     (AR) @[ IoU=0.50:0.95 | area= large | maxDets=100 ] = 0.540
```
