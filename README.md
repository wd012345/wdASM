# wdASM - A Library for Fast Array Computing

## Description
The `wdASM` library package provides a set of functions for fast array computing on Intel(C) processors. The algorithms are written in assembler, and use the AVX vector extensions of Intel.

## Purposes
The functions of the `wdASM` library can be used for various computational applications, e.g.

* Linear Algebra / FEM
* Big Data
* Computer Vision
* DSP
* Machine Learning / AI
* Real Time Applications


## Download and Installation
The `wdASM.a` is part of the repository. It is the precompiled static 64 bit library for Linux. Download the library, and move it to a directory on your library path. The repository provides a debug version of the library called `wdASM.dbg.a` for developping purpose.


## Source Files and Build
The `*.asm` and `*.d` files in the repository contain the library source code. Download the source files together with the `Makefile` to a directory of your choice. Execute

`$ make`

at the command line of the directory to build the library. You will need current versions of the `nasm` and `dmd` compilers to successfully build the library.

The source files are:

* `sadd32fp256.asm` : adds given number to the array components (type: `float`)
* `sadd64fp256.asm` : adds given number to the array components (type `double`)
* `sdiv32fp256.asm` : divides the array components by given number (type: `float`)
* `sdiv64fp256.asm` : divides the array components by given number (type `double`)
* `smul32fp256.asm` : multiplies the array components with given number (type `float`)
* `smul64fp256.asm` : multiplies the array components with given number (type `double`)
* `ssub32fp256.asm` : subtracts given number from the array components (type: `float`)
* `ssub64fp256.asm` : subtracts given number from the array components of (type `double`)
* `vadd32fp256.asm` : adds the components of two arrays (type: `float`)
* `vadd64fp256.asm` : adds the components of two arrays (type `double`)
* `vdiv32fp256.asm` : divides the 1st array components by the 2nd array components (type: `float`)
* `vdiv64fp256.asm` : divides the 1st array components by the 2nd array components` (type `double`)
* `vmul32fp256.asm` : multiplies the components of two arrays (type `float`)
* `vmul64fp256.asm` : multiplies the components of two arrays (type `double`)
* `vsub32fp256.asm` : subtracts 2nd array components from 1st array components (type: `float`)
* `vsub64fp256.asm` : subtracts 2nd array components from 1st array components (type `double`)


## Usage
The following D code demonstrates the use of the functions from the `wdASM.a` library. The variable `N` is the length of the input and output arrays, and `s` is the double precision floating point number to be added to the array `u`

```
...
// declaration of the external function
extern(C) double* sadd64fp256.asm(ulong, double*, double, double*);
...
auto u = new double[N];  // input array
auto v = new double[N];  // output array
auto w = new double[N];  // output array
...
// call wdasm function to compute v = u + s
sadd64fp256(N, u.ptr, s, v.ptr);
...
// call wdasm function to compute w = u - v
assert((u.length == N) && (u.length == v.length));
vsub64fp256(N, u.ptr, v.ptr, w.ptr);
...
```

More samples are found in `wdASM.d` delivered within the repository.


## Bugs
The following bugs and to do items are known:

* Return error code
* Provide information on processor and performance
* Extend to AVX512

Send bug reports to [info@wittwer-datatools.ch](mailto:info@wittwer-datatools.ch).