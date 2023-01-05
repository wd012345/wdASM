;file:          sadd64fp256.asm
;
; Assembly function that adds a 64bit floating point scalar to the
; 64bit floating point components of a tensor according to:
;     w_{111...} = u_{111...} + s
;     w_{211...} = u_{211...} + s
;           .
;           .
;           .
;     w_{kmn...} = u_{kmn...} + s
;
; The AVX2 registers and AVX2 instruction set is used. The function
; processes four looped stages, each processing
;     1. 7 ymm registers * 4 components = 28 components/loop 
;     2. 1 ymm register  * 4 components =  4 components/loop
;     3. 1 xmm register  * 2 components =  2 components/loop
;     4. 1 xmm register  * 1 component  =  1 component/loop.
; The first stage is looped while
;     N_f = (n_1 + 1) * 28 components <= N
; where n_1 is the number of already processed loops of stage 1, and n_1 + 1 
; is called forecast increment of the next stage 1 loop. The second
; stage is looped while
;     N_f = (n_1 * 28 + (n_2 + 1) * 4) components <= N
; where n_2 is the number of already processed loops of stage 2. The assembly
; function returns as soon as N vector components are processed, i.e.
;     N_f = (n_1 * 28 + n_2 * 4 + n_3 * 2 + n_4) components == N.
; The number N_f(n_1, n_2, n_3, n_4) of components being processed in the
; next loop is tracked in rbx.
;
; The address offset dA(n_1, n_2, n_3, n_4) of the components processed in
; the most recent loop is tracked in rax. It is computed with
;     dA = 8 * N_f [B] <= 8N [B]
; in the case of double precision vectors, where N_f is the number of already
; processed components without forecast increment.
;
; synopsis of the caller D source code:
; extern(C) 
; double * sadd64fp256(ulong N, double *u, double *s, double *w);
; N = number of components of tensor u          --> rdi
; u = address to first tensor operand           --> rsi
; s = address to double precision scalar        --> rdx
; w = address to resulting difference tensor    --> rcx
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
    global sadd64fp256
sadd64fp256:
    enter           32,0
    vbroadcastsd    ymm15,[rdx]                 ; broadcast scalar argument
; start looped stage 1
    xor             rax,rax                     ; dA = 0
    mov             rbx,28                      ; N_f = 28 components
    cmp             rdi,rbx                     ; rdi < N_b ?
    jl              stage2                      ; true => go to stage2
loop1:
    vmovapd     ymm1,[rsi+rax*8]                ; load first operands
    vmovapd     ymm3,[rsi+rax*8+32]
    vmovapd     ymm5,[rsi+rax*8+64]
    vmovapd     ymm7,[rsi+rax*8+96]
    vmovapd     ymm9,[rsi+rax*8+128]
    vmovapd     ymm11,[rsi+rax*8+160]
    vmovapd     ymm13,[rsi+rax*8+192]
    vaddpd      ymm0,ymm1,ymm15                 ; process looped stage 1
    vaddpd      ymm2,ymm3,ymm15
    vaddpd      ymm4,ymm5,ymm15
    vaddpd      ymm6,ymm7,ymm15
    vaddpd      ymm8,ymm9,ymm15
    vaddpd      ymm10,ymm11,ymm15
    vaddpd      ymm12,ymm13,ymm15
    vmovapd     [rcx+rax*8],ymm0                ; write results
    vmovapd     [rcx+rax*8+32],ymm2
    vmovapd     [rcx+rax*8+64],ymm4
    vmovapd     [rcx+rax*8+96],ymm6
    vmovapd     [rcx+rax*8+128],ymm8
    vmovapd     [rcx+rax*8+160],ymm10
    vmovapd     [rcx+rax*8+192],ymm12
    add         rax,224                         ; dA == 8N_f
    mov         rbx,28                          ; N_f += 28 components
    cmp         rdi,rbx                         ; N >= N_f ?
    jge         loop1                           ; true => loop stage 1
; start looped stage 2
stage2:
    sub         rbx,28                          ; 8N_f == dA
    add         rbx,4                           ; N_f += 4 components
    cmp         rdi,rbx                         ; N < N_f ?
    jl          stage3                          ; true => go to stage 3
loop2:
    vmovapd     ymm1,[rsi+rax*8]                ; load first operands
    vaddpd      ymm0,ymm1,ymm15                 ; process looped stage 2
    vmovapd     [rcx+rax*8],ymm0                ; write results
    add         rax,32                          ; dA == 8N_f
    add         rbx,4                           ; N_f += 4 components
    cmp         rdi,rbx                         ; N >= N_f ?
    jge         loop2                           ; true => loop stage 2
; start looped stage 3
stage3:
    sub         rbx,4                           ; 8N_f == dA
    add         rbx,2                           ; N_f += 2 components
    cmp         rdi,rbx                         ; N < N_f ?
    jl          stage4                          ; true => go to stage 4
loop3:
    vmovapd     xmm1,[rsi+rax]                  ; load first operand
    vaddpd      xmm0,xmm1,xmm15                 ; process looped stage 3
    vmovapd     [rcx+rax],xmm0                  ; write results
    add         rax,16                          ; dA == 8N_f
    add         rbx,2                           ; N_f += 2 components
    cmp         rdi,rbx                         ; N >= N_f ?
    jge         loop3                           ; true => loop stage 3
; start looped stage 4
stage4:
    sub         rbx,2                           ; 8N_f == dA
    inc         rbx                             ; N_f += 1
    cmp         rdi,rbx                         ; N < N_f ?
    jl          return                          ; true => go to return
loop4:
    movsd       xmm0,[rsi+rax]                  ; load first operand
    addsd       xmm0,[rdx]                      ; process looped stage 4
    movsd       [rcx+rax],xmm0                  ; write result
    add         rax,8                           ; dA == 8N_f
    inc         rbx                             ; N_f += 1
    cmp         rdi,rbx                         ; N >= N_f ?
    jge         loop4                           ; true => loop stage 4
return:
    mov         rax,rcx                         ; return address to result
    leave
    ret


; end of sadd64fp256.asm
