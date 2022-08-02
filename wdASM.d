// file:        avx_test.d
// content:     test program for avx assembly functions
// author:      Stefan Wittwer, info@wittwer-datatools.ch


// imports
import std.stdio: writefln;


// declaration of AVX2 single precision tensor-scalar operations
extern(C) float * smul32fp256(ulong, float *, float, float *);


// declaration of AVX2 double precision tensor-scalar operations
extern(C) double * smul64fp256(ulong, double *, double, double *);


// declaration of AVX2 single precision tensor-tensor operations
extern(C) float * vadd32fp256(ulong, float *, float *, float *);
extern(C) float * vdiv32fp256(ulong, float *, float *, float *);
extern(C) float * vmul32fp256(ulong, float *, float *, float *);
extern(C) float   vspr32fp256(ulong, float *, float *);
extern(C) float * vsub32fp256(ulong, float *, float *, float *);


// declaration of AVX2 double precision tensor-tensor operations
extern(C) double * vadd64fp256(ulong, double *, double *, double *);
extern(C) double * vdiv64fp256(ulong, double *, double *, double *);
extern(C) double * vmul64fp256(ulong, double *, double *, double *);
extern(C) double   vspr64fp256(ulong, double *, double *);
extern(C) double * vsub64fp256(ulong, double *, double *, double *);


/*
 * Test single precision assembly routines on AVX2
 */
void test32fp256() {
    // prepare testing of each stage
    ulong N = 77; // 64 + 8 + 4 + 1
    float   s = 1.0f;
    float[] u = new float[](N);
    float[] v = new float[](N);
    float[] w = new float[](N);
    for (ulong n = 0; n < N; n++) {
        u[n] = n;
        v[n] = n;
    }
    assert((u.length == N) && (v.length == N) && (w.length == N));
    assert(*(u.ptr+1) == 1.0);
    assert(*(v.ptr+2) == 2.0);
    // compute component product of vector and scalar
    float * p = smul32fp256(N, u.ptr, s, w.ptr);
    writefln("p == w: %x ?= %x", p, w.ptr);
    for (ulong n = 0; n < N; n++) {
        writefln("w = %x; w[%d] = %f", w.ptr + n, n, w[n]);
    }
    // compute component sum of two vectors
    p = vadd32fp256(N, u.ptr, v.ptr, w.ptr);
    writefln("p == w: %x ?= %x", p, w.ptr);
    for (ulong n = 0; n < N; n++) {
        writefln("w = %x; w[%d] = %f", w.ptr + n, n, w[n]);
    }
    // compute component division of two vectors
    p = vdiv32fp256(N, u.ptr, v.ptr, w.ptr);
    writefln("p == w: %x ?= %x", p, w.ptr);
    for (ulong n = 0; n < N; n++) {
        writefln("w = %x; w[%d] = %f", w.ptr + n, n, w[n]);
    }
    // compute component product of two vectors
    p = vmul32fp256(N, u.ptr, v.ptr, w.ptr);
    writefln("p == w: %x ?= %x", p, w.ptr);
    for (ulong n = 0; n < N; n++) {
        writefln("w = %x; w[%d] = %f", w.ptr + n, n, w[n]);
    }
    // compute inner product of two vectors
    s = vspr32fp256(N, u.ptr, v.ptr);
    writefln("(u^T, v) = %f", s);    
    // compute component difference of two vectors
    p = vsub32fp256(N, u.ptr, v.ptr, w.ptr);
    writefln("p == w: %x ?= %x", p, w.ptr);
    for (ulong n = 0; n < N; n++) {
        writefln("w = %x; w[%d] = %f", w.ptr + n, n, w[n]);
    }
}

/*
 * Test double precision assembly routines on AVX2
 */
void test64fp256() {
    // prepare testing of each stage
    ulong N = 39;  // 32 + 4 + 2 + 1
    double   s = 1.0;
    double[] u = new double[](N);
    double[] v = new double[](N);
    double[] w = new double[](N);
    for (ulong n = 0; n < N; n++) {
        u[n] = n;
        v[n] = n;
    }
    assert((u.length == N) && (v.length == N) && (w.length == N));
    assert(*(u.ptr+1) == 1.0);
    assert(*(v.ptr+2) == 2.0);
    // compute component product of vector and scalar
    double * p = smul64fp256(N, u.ptr, s, w.ptr);
    writefln("p == w: %x ?= %x", p, w.ptr);
    for (ulong n = 0; n < N; n++) {
        writefln("w = %x; w[%d] = %f", w.ptr + n, n, w[n]);
    }
    // compute component sum of two vectors
    p = vadd64fp256(N, u.ptr, v.ptr, w.ptr);
    writefln("p == w: %x ?= %x", p, w.ptr);
    for (ulong n = 0; n < N; n++) {
        writefln("w = %x; w[%d] = %f", w.ptr + n, n, w[n]);
    }
    // compute component division of two vectors
    p = vdiv64fp256(N, u.ptr, v.ptr, w.ptr);
    writefln("p == w: %x ?= %x", p, w.ptr);
    for (ulong n = 0; n < N; n++) {
        writefln("w = %x; w[%d] = %f", w.ptr + n, n, w[n]);
    }
    // compute component product of two vectors
    p = vmul64fp256(N, u.ptr, v.ptr, w.ptr);
    writefln("p == w: %x ?= %x", p, w.ptr);
    for (ulong n = 0; n < N; n++) {
        writefln("w = %x; w[%d] = %f", w.ptr + n, n, w[n]);
    }
    // compute inner product of two vectors
    s = vspr64fp256(N, u.ptr, v.ptr);
    writefln("(u^T, v) = %f", s);    
    // compute component difference of two vectors
    p = vsub64fp256(N, u.ptr, v.ptr, w.ptr);
    writefln("p == w: %x ?= %x", p, w.ptr);
    for (ulong n = 0; n < N; n++) {
        writefln("w = %x; w[%d] = %f", w.ptr + n, n, w[n]);
    }
}


int main() {
    // test double precision assembly routines on AVX2
    test64fp256();
    // test single precision assembly routines on AVX2
    test32fp256();
    // return
    return 0;
}


// end of avx.d
