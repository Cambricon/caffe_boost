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

A simple C++ code is proposed in`examples/ssd/ssd_offline_multicore.cpp`. 
For the sake of simplicity, this example does not support oversampling of a single sample nor batching of multiple independent samples. This example is not trying to reach the maximum possible detection throughput on
a system, but special care was given to avoid unnecessary pessimization while keeping the code readable.

## Compiling

The C++ example is built automatically when compiling Caffe. To compile Caffe you should follow the documented instructions. The detection example will be built as `examples/ssd/ssd_offline_multicore.bin` ,`examples/ssd/ssd_offline_singlecore.bin` and `examples/ssd/ssd_online_singlecore.bin`in your build directory.

## Usage

This example is tested by running a script. There are two different scripts in this directory.

### Offline mode
Offline mode script is runned in `offline mode`. Basically, the running of it involes two steps:generating
offline model(`.cambricon` file) and running offline model.

To test the demo,you need to run the script  `run_all_offline_sc.sh`.
The command to execute the script is as follows:
```
./run_all_offline_mc.sh args
```
where `args` has two options: 0 or 1, 0 represents that detection networks run with float16 data format and 1 represents that all detection networks run with int8 data format. 

The output for one of the networks should look like this:
```
running ssd offline - float16,dense...
----------------------
single core
using prototxt: some.prototxt
using model:    some.caffemodel
generating offline model...
running offline test...
Total execution time: 1.1135e+08 us
Hardware fps: 10.9058
End2end throughput fps: 8.9807
mAP: 0.838660                
```

### Online mode
The rest script is runned in `online mode`. To test the demo,you need to run the script  `run_all_online_sc.sh`. 
The command to execute the script is as follows:
```
./run_all_online_mc.sh args1 args2
```
where `args1` has two options: 0 or 1, 0 represents that detection networks run with float16 data format and 1 represents that all detection networks run with int8 data format. 

where `args2` has two options: 1 or 2, which resepectively represent layer by layer mode and fusion mode.

The output for one of the networks should look like this:
```
====================================================
running ssd online - float16,dense...
----------------------
single core
using prototxt: some.prototxt
using model:    some.caffemodel
running online test...

Total execution time: 1.40174e+08 us
End2end throughput fps: 7.13399
mAP: 0.838660
```