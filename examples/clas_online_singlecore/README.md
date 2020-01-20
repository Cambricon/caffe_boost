---
title: Online SingleCore Classification example
description: A simple example performing image classification using the low-level C++ API.
category: example
include_in_docs: true
priority: 10
---

# Classifying ImageNet: using the C++ API

Caffe, at its core, is written in C++. It is possible to use the C++ API of Caffe to implement an image classification application similar to the Python code presented in one of the Notebook examples. To look at a more general-purpose example of the Caffe C++ API, you should study the source code of the command line tool `caffe` in `tools/caffe.cpp`.

## Presentation

A simple C++ code is proposed in`examples/clas_online_singlecore/clas_online_singlecore.cpp`.
For the sake of simplicity, this example does not support oversampling of a single sample nor batching of multiple independent samples. This example is not trying to reach the maximum possible classification throughput on
a system, but special care was given to avoid unnecessary pessimization while keeping the code readable.

## Compiling

The C++ example is built automatically when compiling Caffe. To compile Caffe you should follow the documented instructions. The classification example will be built as `examples/clas_online_singlecore/classification.bin` in your build directory.

## Usage

You need to prepare the requisites as described in the README.md file at caffe_boost directory before running the example. To run the example, we have created a script to simplify the process, i.e. `run_all_online_sc.sh`. The command to execute the script is as follows:
```
./run_all_online_sc.sh args1 args2
```
where `args1` has two options: 0 or 1, 0 represents that detection networks run with int16 data format and 1 represents that all detection networks run with int8 data format.

where `args2` has two options: MLU270 or MLU220, MLU270 represents that detection networks run on MLU270 device and MLU220 represents that all detection networks run on MLU220 device.

The output for one of the networks should look like this:

```
====================================================
running resnet50 online - int8,...
----------------------
single core
using prototxt: resnet50.prototxt
using model:    resnet50.caffemodel
core_version: MLU270, preprocess_option: 1
running online test...
Global accuracy :
top1: 0.7477 (37385/50000)
top5: 0.92074 (46037/50000)
End2end throughput fps: 25.0309
```
