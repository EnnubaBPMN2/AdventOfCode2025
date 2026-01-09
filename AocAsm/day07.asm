; day07.asm - Advent of Code 2025 Day 07
default rel
bits 64

section .data
    real_file db '../inputs/day07.txt', 0
    msg_part1_header db '=== Part 1 ===', 13, 10, 0
    msg_part1 db 'Result: ', 0
    msg_part2_header db '=== Part 2 ===', 13, 10, 0
    msg_part2 db 'Result: ', 0

section .bss
    buffer resb 1048576
    ; Grid dimensions: max 256 width, 256 height
    grid resb 65536
    grid_w resq 1
    grid_h resq 1
    
    ; Part 1: active columns (byte boolean array)
    active1 resb 256
    active2 resb 256
    
    ; Part 2: DP path counts (64-bit integer array)
    dp1 resq 256
    dp2 resq 256

section .text
    global day07_run
    extern read_file, print_string, print_number, print_newline

day07_run:
    push rbp
    mov rbp, rsp
    push rbx
    push rsi
    push rdi
    push r12
    push r13
    push r14
    push r15
    sub rsp, 48

    ; Read file
    lea rcx, [real_file]
    lea rdx, [buffer]
    mov r8, 1048575
    call read_file
    
    cmp rax, -1
    je .done
    test rax, rax
    jz .done

    mov r14, rax            ; bytes read
    lea r15, [buffer + r14]
    
    ; Parse into grid and find dimensions
    lea rsi, [buffer]
    xor r12, r12            ; max_w
    xor r13, r13            ; cur_h
    xor rbx, rbx            ; cur_w
    
    mov qword [rbp-8], -1   ; start_col
    
.parse_grid:
    cmp rsi, r15
    jae .parsed
    
    lodsb
    cmp al, 10
    je .next_line
    cmp al, 13
    je .parse_grid
    
    cmp al, 'S'
    jne .not_s
    mov [rbp-8], rbx        ; Found S!
.not_s:
    ; store in grid[r13][rbx]
    mov rdx, r13
    shl rdx, 8              ; row * 256
    add rdx, rbx
    mov [grid + rdx], al
    
    inc rbx
    jmp .parse_grid

.next_line:
    cmp rbx, r12
    jbe .h_only
    mov r12, rbx
.h_only:
    test rbx, rbx
    jz .parse_grid
    inc r13
    xor rbx, rbx
    jmp .parse_grid

.parsed:
    ; if we ended without a newline
    test rbx, rbx
    jz .dim_set
    inc r13
    cmp rbx, r12
    jbe .dim_set
    mov r12, rbx
.dim_set:
    mov [grid_w], r12
    mov [grid_h], r13

    ; Clear buffers
    lea rdi, [active1]
    xor rax, rax
    mov rcx, 512            ; active1 + active2
    rep stosb
    
    lea rdi, [dp1]
    xor rax, rax
    mov rcx, 512            ; dp1 + dp2 (qwords => 512 * 8 = 4096)
    rep stosq
    
    ; Initial state
    mov rax, [rbp-8]        ; start_col
    cmp rax, -1
    je .finish              ; Safety
    
    mov byte [active1 + rax], 1
    mov qword [dp1 + rax*8], 1
    
    xor r14, r14            ; total_splits (Part 1)
    xor r12, r12            ; current row
    
.row_loop:
    cmp r12, [grid_h]
    jae .finish
    
    ; Pointers to current and next
    mov rax, r12
    test rax, 1
    jnz .odd_row
    
    lea r8, [active1]
    lea r9, [active2]
    lea r10, [dp1]
    lea r11, [dp2]
    jmp .row_start
    
.odd_row:
    lea r8, [active2]
    lea r9, [active1]
    lea r10, [dp2]
    lea r11, [dp1]

.row_start:
    ; Clear next buffers
    push r8
    push r9
    push r10
    push r11
    
    mov rdi, r9
    xor rax, rax
    mov rcx, 256
    rep stosb
    
    mov rdi, r11
    xor rax, rax
    mov rcx, 256
    rep stosq
    
    pop r11
    pop r10
    pop r9
    pop r8
    
    xor rbx, rbx            ; current col
.col_loop:
    cmp rbx, [grid_w]
    jae .next_row
    
    ; Check grid[r12][rbx]
    mov rdx, r12
    shl rdx, 8
    add rdx, rbx
    movzx rdx, byte [grid + rdx]
    
    ; Part 1 split count
    cmp rdx, '^'
    jne .no_split
    cmp byte [r8 + rbx], 1
    jne .no_split
    inc r14                 ; Beam reached splitter
.no_split:

    ; Propagation
    movzx rax, byte [r8 + rbx] ; Part 1 active
    mov rsi, [r10 + rbx*8]     ; Part 2 count
    
    test rax, rax
    jnz .active_in_p1
    test rsi, rsi
    jz .skip_col
    
.active_in_p1:
    cmp rdx, '^'
    je .is_splitter
    
    ; Continue down
    test rax, rax
    jz .p2_only_down
    mov byte [r9 + rbx], 1
.p2_only_down:
    add [r11 + rbx*8], rsi
    jmp .skip_col

.is_splitter:
    ; Split L/R
    test rbx, rbx
    jz .no_left
    ; Left
    test rax, rax
    jz .p2_only_l
    mov byte [r9 + rbx - 1], 1
.p2_only_l:
    add [r11 + (rbx-1)*8], rsi
.no_left:

    mov rdi, rbx
    inc rdi
    cmp rdi, [grid_w]
    jae .no_right
    ; Right
    test rax, rax
    jz .p2_only_r
    mov byte [r9 + rdi], 1
.p2_only_r:
    add [r11 + rdi*8], rsi
.no_right:

.skip_col:
    inc rbx
    jmp .col_loop

.next_row:
    inc r12
    jmp .row_loop

.finish:
    ; Print Part 1
    push r14
    call print_newline
    lea rcx, [msg_part1_header]
    call print_string
    lea rcx, [msg_part1]
    call print_string
    pop rcx
    call print_number
    call print_newline
    
    ; Part 2: Sum current DP buffer
    mov rax, [grid_h]
    test rax, 1
    jz .use_dp1
    lea r10, [dp2]
    jmp .calc_sum
.use_dp1:
    lea r10, [dp1]
    
.calc_sum:
    xor r13, r13            ; total Part 2
    xor rbx, rbx
.sum_loop:
    cmp rbx, [grid_w]
    jae .p2_done
    add r13, [r10 + rbx*8]
    inc rbx
    jmp .sum_loop

.p2_done:
    lea rcx, [msg_part2_header]
    call print_string
    lea rcx, [msg_part2]
    call print_string
    mov rcx, r13
    call print_number
    call print_newline

.done:
    add rsp, 48
    pop r15
    pop r14
    pop r13
    pop r12
    pop rdi
    pop rsi
    pop rbx
    pop rbp
    ret
