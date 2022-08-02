; file:          vspr32fp256.asm
;
; Assembly function that computes the dot product of two 32 bit floating point
; vectors according to:
;
;                       N
;                     ----,
;                     \
;     w = (u^T, v) =  /      u_n * v_n
;                     ----
;                    n = 1
;
; The AVX2 registers and AVX2 instruction set is used. The function
; processes four looped stages, each processing
;     1. 8 ymm registers * 8 components = 64 components/loop 
;     2. 1 ymm register  * 8 components =  8 components/loop
;     3. 1 xmm register  * 4 components =  4 components/loop
;     4. 1 xmm register  * 1 component  =  1 component/loop.
; The first stage is looped while
;     N_f = (n_1 + 1) * 64 components <= N
; where n_1 is the number of already processed loops of stage 1, and n_1 + 1 
; is called forecast increment of the next stage 1 loop. The second
; stage is looped while
;     N_f = (n_1 * 64 + (n_2 + 1) * 8) components <= N
; where n_2 is the number of already processed loops of stage 2. The assembly
; function returns as soon as N vector components are processed, i.e.
;     N_f = (n_1 * 64 + n_2 * 8 + n_3 * 4 + n_4) components == N.
; The number N_f(n_1, n_2, n_3, n_4) of components being processed in the
; next loop is tracked in rbx.
;
; The address offset dA(n_1, n_2, n_3, n_4) of the components processed in
; the most recent loop is tracked in rax. It is computed with
;     dA = 4 * N_f [B] <= 4N [B]
; in the case of single precision vectors, where N_f is the number of already
; processed components without forecast increment.
;
; synopsis of the caller D source code:
; extern(C) float * vspr32fp256(<arg_list>);
;
; where <arg_list> is:
; ulong N  = number of components of vector arguments --> rdi
; float *u = address to first vector operand          --> rsi
; float *v = address to second vector operand         --> rdx
; float *w = address to resulting sum vector          --> rcx
; ____________________________________________________________________________
; 
; todo:         
; 
; author:       Stefan Wittwer, info@wittwer-datatools.ch
; ____________________________________________________________________________


; data segment
;section .data


; code segment
section .text
    global vspr32fp256
vspr32fp256:
    enter           32,0
; start looped stage 1
    xor             rax,rax                     ; dA = 0
    mov             rbx,64                      ; N_f = 64 comps
    cmp             rdi,rbx                     ; N < N_f ?
    jl              stage2                      ; true => go to stage 2
loop1:
    vmovaps         ymm1,[rsi+rax]              ; load first operands
    vmovaps         ymm2,[rsi+rax+32]
    vmovaps         ymm3,[rsi+rax+64]
    vmovaps         ymm4,[rsi+rax+96]
    vmovaps         ymm5,[rsi+rax+128]
    vmovaps         ymm6,[rsi+rax+160]
    vmovaps         ymm7,[rsi+rax+192]
    vmovaps         ymm8,[rsi+rax+224]
    vfmadd231ps     ymm0,ymm1,[rdx+rax]         ; process looped stage 1
    vfmadd231ps     ymm0,ymm2,[rdx+rax+32]
    vfmadd231ps     ymm0,ymm3,[rdx+rax+64]
    vfmadd231ps     ymm0,ymm4,[rdx+rax+96]
    vfmadd231ps     ymm0,ymm5,[rdx+rax+128]
    vfmadd231ps     ymm0,ymm6,[rdx+rax+160]
    vfmadd231ps     ymm0,ymm7,[rdx+rax+192]
    vfmadd231ps     ymm0,ymm8,[rdx+rax+224]
    add             rax,256                     ; dA == 4N_f
    add             rbx,64                      ; N_f += 64 components
    cmp             rdi,rbx                     ; N >= N_f ?
    jge             loop1                       ; true => loop stage 1
; start looped stage 2
stage2:
    sub             rbx,64                      ; 4N_f == dA
    add             rbx,8                       ; N_f += 8 components
    cmp             rdi,rbx                     ; N < N_f ?
    jl              stage3                      ; true => go to stage 3
loop2:
    vmovaps         ymm1,[rsi+rax]              ; load first operands
    vfmadd231ps     ymm0,ymm1,[rdx+rax]         ; process looped stage 2
    add             rax,32                      ; dA == 4N_f
    add             rbx,8                       ; N_f += 8 components
    cmp             rdi,rbx                     ; N >= N_f ?
    jge             loop2                       ; true => loop stage 2
; start looped stage 3
stage3:
    vextractf128    xmm2,ymm0,1                 ; sum to xmm0 register
    vextractf128    xmm0,ymm0,0
    addps           xmm0,xmm2
    sub             rbx,8                       ; 4N_f == dA
    add             rbx,4                       ; N_f += 4 components
    cmp             rdi,rbx                     ; N < N_f ?
    jl              stage4                      ; true => go to stage 4
loop3:
    vmovaps         xmm2,[rsi+rax]              ; load first operands
    vfmadd231ps     xmm0,xmm2,[rdx+rax]         ; process looped stage 3
    add             rax,16                      ; dA == 4N_f
    add             rbx,4                       ; N_f += 4 components
    cmp             rdi,rbx                     ; N >= N_f ?
    jge             loop3                       ; true => loop stage 3
; start looped stage 4
stage4:
    sub             rbx,4                       ; 4N_f == dA
    inc             rbx                         ; N_f += 1
    cmp             rdi,rbx                     ; N < N_f ?
    jl              return                      ; true => go to return
loop4:
    movss           xmm2,[rsi+rax]              ; load first operand
    mulss           xmm2,[rdx+rax]              ; process looped stage 4
    addss           xmm0,xmm2                   ; write result
    add             rax,4                       ; dA == 4N_f
    inc             rbx                         ; N_f += 1
    cmp             rdi,rbx                     ; N >= N_f ?
    jge             loop4                       ; true => loop stage 4
return:
    haddpd          xmm0,xmm0                   ; return result
    leave
    ret


; end of vspr32fp256.asm
