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
./run_all_online_sc.sh args
```
where `args` has two options: 0 or 1, 0 represents that all classification networks run with float16 data format and 1 represents that all classification networks run with int8 data format. 

The output for one of the networks should look like this:

```
running alexnet online - float16,dense...
----------------------
multiple core
using prototxt: some.prototxt
using model:    some.caffemodel
data_parallel:  8,  model_parallel:  1  thread_num:  4
running online test...
Global accuracy : 
accuracy1: 0.558 (558/1000)
accuracy5: 0.788 (788/1000)
Hardware fps: 1339.75
End2end throughput fps: 227.9

```
