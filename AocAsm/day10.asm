; day10.asm - AoC 2025 Day 10
default rel
bits 64

section .data
    real_f db '../inputs/day10.txt', 0
    m_p1_h db '=== Part 1 ===', 13, 10, 0
    m_p1_r db 'Result: ', 0
    m_p2_h db '=== Part 2 ===', 13, 10, 0
    m_p2_r db 'Result: ', 0
    eps    dq 1e-9
    align 16
    abs_m  dq 0x7FFFFFFFFFFFFFFF, 0x7FFFFFFFFFFFFFFF

section .bss
    buf     resb 1048576
    m_gf2   resq 128
    m_p2    resq 16384
    t_p2    resq 128
    pivs    resq 128
    f_vs    resq 128
    tv      resq 128
    n_btn   resq 1
    n_lgt   resq 1
    n_cnt   resq 1
    b_sum   resq 1
    f_cnt_m resq 1
    f_mks   resq 128

section .text
    global day10_run
    extern read_file, print_string, print_number, print_newline, atoi64
    extern GetTickCount64, print_elapsed

day10_run:
    push rbp
    mov rbp, rsp
    push rbx
    push rsi
    push rdi
    push r12
    push r13
    push r14
    push r15
    sub rsp, 128

    lea rcx, [real_f]
    lea rdx, [buf]
    mov r8, 1048575
    call read_file
    test rax, rax
    jle .dn_f

    mov r14, rax
    lea r15, [buf + r14]
    lea rsi, [buf]
    xor r12, r12
    xor r13, r13

.loop:
    cmp rsi, r15
    jae .fin
    
    lea rdi, [m_gf2]
    xor rax, rax
    mov rcx, 128
    rep stosq
    lea rdi, [m_p2]
    mov rcx, 16384
    rep stosq
    lea rdi, [t_p2]
    mov rcx, 128
    rep stosq

.find:
    cmp rsi, r15
    jae .fin
    lodsb
    cmp al, '['
    jne .find
    
    xor rbx, rbx
    xor r8, r8
.p_lg:
    cmp rsi, r15
    jae .lg_d
    lodsb
    cmp al, ']'
    je .lg_d
    cmp al, '#'
    jne .lg_s
    cmp r8, 63
    jae .lg_s
    bts rbx, r8
.lg_s:
    inc r8
    jmp .p_lg
.lg_d:
    mov [n_lgt], r8
    mov [rbp-72], rbx

    xor r11, r11
.f_sc:
    cmp rsi, r15
    jae .solv
    lodsb
    cmp al, '('
    je .p_b
    cmp al, '{'
    je .p_r
    cmp al, 10
    je .solv
    jmp .f_sc

.p_b:
    mov rcx, rsi
    call atoi64
    push rdx
    cmp rax, 127
    ja .b_sk
    bts [m_gf2 + rax*8], r11
    mov r9, rax
    shl r9, 7
    add r9, r11
    mov rax, 0x3FF0000000000000
    mov [m_p2 + r9*8], rax
.b_sk:
    pop rdx
    add rsi, rdx
    lodsb
    cmp al, ')'
    je .b_d
    jmp .p_b
.b_d:
    inc r11
    jmp .f_sc

.p_r:
    mov [n_btn], r11
    xor r11, r11
.rq_l:
    mov rcx, rsi
    call atoi64
    cvtsi2sd xmm0, rax
    movsd [t_p2 + r11*8], xmm0
    inc r11
    add rsi, rdx
    lodsb
    cmp al, '}'
    je .rq_d
    jmp .rq_l
.rq_d:
    mov [n_cnt], r11

.solv:
    ; Start timer for Day 10
    call GetTickCount64
    mov [rbp-80], rax       ; Start time

    ; P1
    lea rdi, [pivs]
    mov rax, -1
    mov rcx, 128
    rep stosq
    xor rcx, rcx
.au_gf:
    cmp rcx, [n_lgt]
    jae .el_gf
    mov rax, [rbp-72]
    bt rax, rcx
    jnc .au_s
    bts qword [m_gf2+rcx*8], 63
.au_s:
    inc rcx
    jmp .au_gf
.el_gf:
    xor r8, r8
    xor r9, r9
.gf_lp:
    cmp r8, [n_lgt]
    jae .gf_op
    cmp r9, [n_btn]
    jae .gf_op
    mov r10, r8
.gf_fp:
    cmp r10, [n_lgt]
    jae .gf_nx
    bt [m_gf2+r10*8], r9
    jc .gf_sw
    inc r10
    jmp .gf_fp
.gf_sw:
    mov rax, [m_gf2+r8*8]
    mov rcx, [m_gf2+r10*8]
    mov [m_gf2+r8*8], rcx
    mov [m_gf2+r10*8], rax
    xor r10, r10
.gf_rw:
    cmp r10, [n_lgt]
    jae .gf_pd
    cmp r10, r8
    je .gf_rs
    bt [m_gf2+r10*8], r9
    jnc .gf_rs
    mov rax, [m_gf2+r8*8]
    xor [m_gf2+r10*8], rax
.gf_rs:
    inc r10
    jmp .gf_rw
.gf_pd:
    mov [pivs+r8*8], r9
    inc r8
.gf_nx:
    inc r9
    jmp .gf_lp

.gf_op:
    xor r11, r11
    xor r9, r9
.gf_fe:
    cmp r9, [n_btn]
    jae .gf_be
    xor r8, r8
.gf_ck:
    cmp r8, [n_lgt]
    jae .gf_if
    cmp [pivs+r8*8], r9
    je .gf_nf
    inc r8
    jmp .gf_ck
.gf_if:
    mov [f_vs+r11*8], r9
    inc r11
.gf_nf:
    inc r9
    jmp .gf_fe
.gf_be:
    mov r14, 1000
    ; Precompute free variable masks for each row
    xor r8, r8
.gf_pm:
    cmp r8, [n_lgt]
    jae .p_pre_bf
    mov rdx, [m_gf2+r8*8]
    xor rax, rax
    xor rdi, rdi
.gf_pml:
    cmp rdi, r11
    jae .gf_pm_s
    mov r10, [f_vs+rdi*8]
    bt rdx, r10
    jnc .gf_pmn
    bts rax, rdi
.gf_pmn:
    inc rdi
    jmp .gf_pml
.gf_pm_s:
    mov [f_mks+r8*8], rax
    inc r8
    jmp .gf_pm

.p_pre_bf:
    xor rbx, rbx
.gf_bf:
    xor rax, rax
    xor r8, r8
.gf_br:
    cmp r8, [n_lgt]
    jae .gf_bv
    mov r9, [f_mks+r8*8]
    mov rdx, [m_gf2+r8*8]
    
    ; Fast parity check using popcnt
    mov rcx, r9
    and rcx, rbx
    popcnt rcx, rcx
    
    bt rdx, 63
    setc dl
    movzx rdx, dl
    
    xor rcx, rdx
    and rcx, 1
    
    ; rcx = 1 if (popcnt(mask&rbx) XOR target) != 0
    ; For pivot rows, additive rax part.
    ; For zero rows, if rcx != 0, this whole configuration rbx is invalid!
    cmp qword [pivs+r8*8], -1
    jne .gf_bpiv
    
    ; Zero row: must be consistent
    test rcx, rcx
    jnz .gf_binv
    jmp .gf_bs
    
.gf_bpiv:
    add rax, rcx
.gf_bs:
    inc r8
    jmp .gf_br
.gf_bv:
    push rax
    mov rax, rbx
    popcnt rax, rax
    pop rdx
    add rax, rdx
    cmp rax, r14
    jae .gf_nm
    mov r14, rax
    jmp .gf_nm
.gf_binv:
    ; Consistency check failed for this rbx
    jmp .gf_nm
.gf_nm:
    inc rbx
    cmp r11, 15
    ja .gf_fc
    mov rax, 1
    mov rcx, r11
    shl rax, cl
    cmp rbx, rax
    jb .gf_bf
.gf_fc:
    add r12, r14
    
    ; P2
    lea rdi, [pivs]
    mov rax, -1
    mov rcx, 128
    rep stosq
    xor r8, r8
    xor r9, r9
.p2_lp:
    cmp r8, [n_cnt]
    jae .p2_op
    cmp r9, [n_btn]
    jae .p2_op
    mov r10, r8
    mov r11, r8
    pxor xmm0, xmm0
.p2_fp:
    cmp r10, [n_cnt]
    jae .p2_vf
    mov rdx, r10
    shl rdx, 7
    add rdx, r9
    movsd xmm1, [m_p2+rdx*8]
    andpd xmm1, [rel abs_m]
    ucomisd xmm1, xmm0
    jbe .p2_vn
    movsd xmm0, xmm1
    mov r11, r10
.p2_vn:
    inc r10
    jmp .p2_fp
.p2_vf:
    movsd xmm1, [eps]
    ucomisd xmm0, xmm1
    jb .p2_sk
    xor rcx, rcx
.p2_sw:
    cmp rcx, [n_btn]
    jae .p2_st
    mov rdx, r8
    shl rdx, 7
    add rdx, rcx
    mov rdi, r11
    shl rdi, 7
    add rdi, rcx
    mov rax, [m_p2+rdx*8]
    mov rbx, [m_p2+rdi*8]
    mov [m_p2+rdx*8], rbx
    mov [m_p2+rdi*8], rax
    inc rcx
    jmp .p2_sw
.p2_st:
    movsd xmm0, [t_p2+r8*8]
    movsd xmm1, [t_p2+r11*8]
    movsd [t_p2+r8*8], xmm1
    movsd [t_p2+r11*8], xmm0
    mov rdx, r8
    shl rdx, 7
    add rdx, r9
    movsd xmm0, [m_p2+rdx*8]
    xor rcx, rcx
.p2_nr:
    cmp rcx, [n_btn]
    jae .p2_nt
    mov rdi, r8
    shl rdi, 7
    add rdi, rcx
    movsd xmm1, [m_p2+rdi*8]
    divsd xmm1, xmm0
    movsd [m_p2+rdi*8], xmm1
    inc rcx
    jmp .p2_nr
.p2_nt:
    movsd xmm1, [t_p2+r8*8]
    divsd xmm1, xmm0
    movsd [t_p2+r8*8], xmm1
    xor r10, r10
.p2_rd:
    cmp r10, [n_cnt]
    jae .p2_po
    cmp r10, r8
    je .p2_rs
    mov rdx, r10
    shl rdx, 7
    add rdx, r9
    movsd xmm1, [m_p2+rdx*8]
    xor rcx, rcx
.p2_sb:
    cmp rcx, [n_btn]
    jae .p2_sbt
    mov rdi, r8
    shl rdi, 7
    add rdi, rcx
    movsd xmm2, [m_p2+rdi*8]
    mulsd xmm2, xmm1
    mov rdi, r10
    shl rdi, 7
    add rdi, rcx
    movsd xmm3, [m_p2+rdi*8]
    subsd xmm3, xmm2
    movsd [m_p2+rdi*8], xmm3
    inc rcx
    jmp .p2_sb
.p2_sbt:
    movsd xmm2, [t_p2+r8*8]
    mulsd xmm2, xmm1
    movsd xmm3, [t_p2+r10*8]
    subsd xmm3, xmm2
    movsd [t_p2+r10*8], xmm3
.p2_rs:
    inc r10
    jmp .p2_rd
.p2_po:
    mov [pivs+r8*8], r9
    inc r8
.p2_sk:
    inc r9
    jmp .p2_lp

.p2_op:
    xor r11, r11
    xor r9, r9
.p2_fe:
    cmp r9, [n_btn]
    jae .p2_be
    xor r8, r8
.p2_ck:
    cmp r8, [n_cnt]
    jae .p2_if
    cmp [pivs+r8*8], r9
    je .p2_nf
    inc r8
    jmp .p2_ck
.p2_if:
    mov [f_vs+r11*8], r9
    inc r11
.p2_nf:
    inc r9
    jmp .p2_fe
.p2_be:
    mov [f_cnt_m], r11
    mov qword [b_sum], 0x10000000
    xor rcx, rcx
    xor rdx, rdx
    call p2_src
    add r13, [b_sum]

.sk_n:
    cmp rsi, r15
    jae .fin
    lodsb
    cmp al, 10
    jne .sk_n
    jmp .loop

.fin:
    call GetTickCount64
    mov r14, rax            ; End total time

    lea rcx, [m_p1_h]
    call print_string
    lea rcx, [m_p1_r]
    call print_string
    mov rcx, r12
    call print_number
    mov rcx, [rbp-80]       ; Start time
    mov rdx, r14            ; End time (Part 1 finish is usually fine as total)
    call print_elapsed
    call print_newline

    lea rcx, [m_p2_h]
    call print_string
    lea rcx, [m_p2_r]
    call print_string
    mov rcx, r13
    call print_number
    mov rcx, [rbp-80]
    mov rdx, r14
    call print_elapsed
    call print_newline
    call print_newline

.dn:
    add rsp, 128
    pop r15
    pop r14
    pop r13
    pop r12
    pop rdi
    pop rsi
    pop rbx
    pop rbp
    ret

.dn_f:
    xor r12, r12
    xor r13, r13
    jmp .fin

p2_src:
    cmp rcx, [f_cnt_m]
    jne .r
    xor r10, r10
    add r10, rdx
    xor r8, r8
.e:
    cmp r8, [n_cnt]
    jae .ok
    mov r9, [pivs+r8*8]
    cmp r9, -1
    je .e_n
    movsd xmm0, [t_p2+r8*8]
    xor rax, rax
.e_f:
    cmp rax, [f_cnt_m]
    jae .e_v
    mov r11, r8
    shl r11, 7
    mov r9, [f_vs+rax*8]
    add r11, r9
    movsd xmm1, [m_p2+r11*8]
    cvtsi2sd xmm2, [tv+rax*8]
    mulsd xmm1, xmm2
    subsd xmm0, xmm1
    inc rax
    jmp .e_f
.e_v:
    cvtsd2si rax, xmm0
    cvtsi2sd xmm1, rax
    subsd xmm1, xmm0
    andpd xmm1, [rel abs_m]
    ucomisd xmm1, [rel eps]
    ja .bad
    test rax, rax
    js .bad
    add r10, rax
    inc r8
    jmp .e
.e_n:
    movsd xmm0, [t_p2+r8*8]
    xor rax, rax
.e_fn:
    cmp rax, [f_cnt_m]
    jae .e_vn
    mov r11, r8
    shl r11, 7
    mov r9, [f_vs+rax*8]
    add r11, r9
    movsd xmm1, [m_p2+r11*8]
    cvtsi2sd xmm2, [tv+rax*8]
    mulsd xmm1, xmm2
    subsd xmm0, xmm1
    inc rax
    jmp .e_fn
.e_vn:
    andpd xmm0, [rel abs_m]
    ucomisd xmm0, [rel eps]
    ja .bad
    inc r8
    jmp .e
.ok:
    cmp r10, [b_sum]
    jae .bad
    mov [b_sum], r10
.bad:
    ret

.r:
    push rcx
    push rdx
    push r10
    push r11
    sub rsp, 32
    xor r10, r10
.rl:
    cmp r10, 1000
    ja .rd
    mov r11, [rsp + 48]      ; caller rdx (sum)
    add r11, r10
    cmp r11, [b_sum]
    jae .rd
    mov rcx, [rsp + 56]      ; caller rcx (idx)
    mov [tv+rcx*8], r10
    mov [rsp+16], r10        ; Current local r10
    inc rcx
    mov rdx, r11
    call p2_src
    mov r10, [rsp+16]
    inc r10
    jmp .rl
.rd:
    add rsp, 32
    pop r11
    pop r10
    pop rdx
    pop rcx
    ret
