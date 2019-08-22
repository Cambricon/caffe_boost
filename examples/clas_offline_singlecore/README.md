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
./run_all_offline_sc.sh args
```
where `args` has two options: 0 or 1, 0 represents that all classification networks run with float16 data format and 1 represents that all classification networks run with int8 data format. 

The output for one of the networks should look like this:
```
====================================================
running net offline - int8,dense...
----------------------
single core
using prototxt: some.prototxt
using model:    some.caffemodel
generating offline model...
running offline test...
Global accuracy : 
accuracy1: 0.553 (553/1000)
accuracy5: 0.787 (787/1000)
Hardware fps: 134.983
End2end throughput fps: 63.8844
```
This command also generates the offline model (`.cambricon` file), offline mode description (`.cambricon_twins` file) and `.log` files of all networks.

