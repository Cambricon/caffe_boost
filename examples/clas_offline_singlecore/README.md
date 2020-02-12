---
title: Offline Single Core Classification Example
description: A simple example performing image classification using offline interface of Cambricon SDK
category: example
include_in_docs: true
priority: 10
---

# Classifying ImageNet: using Cambricon Neuware Runtime API

Cambricon Neuware Runtime (CNRT) provides the ability to run neural networks without deep learning frameworks. This is an example of running classification network with CNRT API.

## Presentation

A simple C++ code is proposed in `caffe/examples/clas_offline_singlecore/clas_offline_singlecore.cpp`. For the sake of simplicity, this example does not support oversampling of a single sample nor batching of multiple independent samples. This example is not trying to reach the maximum possible classification throughput on a system, but special care was given to avoid unnecessary pessimization while keeping the code readable.

## Compiling

The C++ example is built automatically when compiling Caffe. To compile Caffe you should follow the documented instructions. The offline single core classification example will be built as `examples/clas_offline_singlecore/clas_offline_singlecore.bin` in your build directory.

## Usage

You need to prepare the requisites as described in the README.md file at caffe_boost directory before running the example. To run the example, we have created a script to simplify the process, i.e. `run_all_offline_sc.sh`. The command to execute the script is as follows:
```
./run_all_offline_sc.sh args1 args2
```
where `args1` has two options: 0 or 1, 0 represents that detection networks run with int16 data format and 1 represents that all detection networks run with int8 data format.

where `args2` has two options: MLU270 or MLU220, MLU270 represents that detection networks run on MLU270 device and MLU220 represents that all detection networks run on MLU220 device.

The output for one of the networks should look like this:
```
====================================================
running resnet50 offline - int8,...
----------------------
single core
using prototxt: resnet50.prototxt
using model:    resnet50.caffemodel
core_version: MLU270,  preprocess_option: 1
generating offline model...
running offline test...
Global accuracy :
top1: 0.74894 (37447/50000)
top5: 0.92082 (46041/50000)
throughput: 210.757
Latency: 4744.80
```
This command also generates the offline model (`.cambricon` file), offline mode description (`.cambricon_twins` file) and `.log` files of all networks.
