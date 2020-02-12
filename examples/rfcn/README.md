---
title: SSD example
description: A simple example performing image detection using offline interface of Cambricon SDK
category: example
include_in_docs: true
priority: 10
---

# Detecting VOC2012: using Cambricon Neuware Runtime API

Cambricon Neuware Runtime (CNRT) provides the ability to run neural networks without deep learning frameworks. This is an example of running detection network with CNRT API.

## Presentation

A simple C++ code is proposed in`examples/rfcn/rfcn_offline_multicore.cpp`.
For the sake of simplicity, this example does not support oversampling of a single sample nor batching of multiple independent samples. This example is not trying to reach the maximum possible detection throughput on a system, but special care was given to avoid unnecessary pessimization while keeping the code readable.

## Compiling

The C++ example is built automatically when compiling Caffe. To compile Caffe you should follow the documented instructions. The detection example will be built as `examples/rfcn/rfcn_offline_multicore.bin` ,`examples/rfcn/rfcn_offline_singlecore.bin` and `examples/rfcn/rfcn_online_singlecore.bin` in your build directory.

## Usage

This example is tested by running a script. There are two different scripts in this directory.

### Offline mode
Offline mode script is runned in `offline mode`. Basically, the running of it involes two steps:generating
offline model(`.cambricon` file) and running offline model.

#### multiple cores in Offline mode
To test the demo,you need to run the script  `run_all_offline_mc.sh`.
The command to execute the script is as follows:
```
./run_all_offline_mc.sh args1 args2
```
where `args1` has two options: 0 or 1, 0 represents that detection networks run with int16 data format and 1 represents that all detection networks run with int8 data format.

where `args2` has two options: MLU270 or MLU220, MLU270 represents that detection networks run on MLU270 device and MLU220 represents that all detection networks run on MLU220 device.

The output for one of the networks should look like this:
```
====================================================
running rfcn offline - int8, Bangop...
----------------------
multiple core
using prototxt: rfcn.prototxt
using model:    rfcn.caffemodel
batchsize:  16,  core_number:  16
generating offline model...
running offline test...
Total execution time: 2.15184e+08 us
throughput: 23.111
Latency: 692310.38
mAP: 0.769588
```

#### single core in offline mode
To test the demo,you need to run the script  `run_all_offline_sc.sh`.
The command to execute the script is as follows:
```
./run_all_offline_sc.sh args1 args2
```
where `args1` has two options: 0 or 1, 0 represents that detection networks run with int16 data format and 1 represents that all detection networks run with int8 data format.

where `args2` has two options: MLU270 or MLU220, MLU270 represents that detection networks run on MLU270 device and MLU220 represents that all detection networks run on MLU220 device.

The output for one of the networks should look like this:
```
====================================================
running rfcn offline - int8...
----------------------
single core
using prototxt: rfcn.prototxt
using model:    rfcn.caffemodel
core version:   MLU270
generating offline model...
running offline test...
Total execution time: 1.0377e+09 us
throughput: 7.55962
Latency: 132281.75
mAP: 0.770918
```
### single cores in Online mode
The rest script is runned in `online mode`. To test the demo,you need to run the script  `run_all_online_sc.sh`.
The command to execute the script is as follows:
```
./run_all_online_sc.sh args1 args2 args3
```
where `args1` has two options: 0 or 1, 0 represents that detection networks run with int16 data format and 1 represents that all detection networks run with int8 data format.

where `args2` has two options: 1 or 2, 1 represents that SSD run layer by layer and 2 represents that SSD run fusion.

where `args3` has two options: MLU270 or MLU220, MLU270 represents that detection networks run on MLU270 device and MLU220 represents that all detection networks run on MLU220 device.

The output for one of the networks should look like this:
```
====================================================
running rfcn online - int8, Bangop...
----------------------
single core
using prototxt: rfcn.prototxt
using model:    rfcn.caffemodel
running online test...
mAP: 0.770918
```
