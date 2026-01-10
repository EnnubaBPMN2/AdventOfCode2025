; day06.asm - Advent of Code 2025 Day 06
default rel
bits 64

section .data
    real_file db '../inputs/day06.txt', 0
    msg_part1_header db '=== Part 1 ===', 13, 10, 0
    msg_part1 db 'Result: ', 0
    msg_part2_header db '=== Part 2 ===', 13, 10, 0
    msg_part2 db 'Result: ', 0

section .bss
    buffer resb 1048576     ; Input file buffer
    ; The worksheet has 5 rows. Max column width is ~4000.
    ; Store grid as linear buffer: grid[5 * 4096]
    grid resb 32768
    grid_width resq 1
    
    ; Temp buffer for building numbers
    num_str resb 64

section .text
    global day06_run
    extern read_file, print_string, print_number, print_newline, atoi64
    extern GetTickCount64, print_elapsed

day06_run:
    push rbp
    mov rbp, rsp
    push rbx
    push rsi
    push rdi
    push r12
    push r13
    push r14
    push r15
    sub rsp, 64

    ; Start timing
    call GetTickCount64
    mov [rbp-56], rax       ; Save start time

    ; Read file
    lea rcx, [real_file]
    lea rdx, [buffer]
    mov r8, 1048575
    call read_file
    
    cmp rax, -1
    je .done
    test rax, rax
    jz .done

    mov r14, rax            ; r14 = bytes read
    lea r15, [buffer + r14]
    
    ; Initialize grid with spaces
    lea rdi, [grid]
    mov rcx, 32768
    mov al, ' '
    rep stosb
    
    ; Parse buffer into 5 rows
    lea rsi, [buffer]
    xor rbx, rbx            ; current row
    xor rdi, rdi            ; pos in row
    xor r12, r12            ; max width
.copy_to_grid:
    cmp rsi, r15
    jae .copy_done
    
    lodsb
    cmp al, 10              ; LF
    je .new_row
    cmp al, 13              ; CR
    je .copy_to_grid
    
    ; store char at grid[rbx * 4096 + rdi]
    mov rdx, rbx
    shl rdx, 12             ; row * 4096
    add rdx, rdi
    mov [grid + rdx], al
    inc rdi
    jmp .copy_to_grid

.new_row:
    cmp rdi, r12
    jbe .not_wider
    mov r12, rdi
.not_wider:
    inc rbx
    xor rdi, rdi
    cmp rbx, 5
    jl .copy_to_grid

.copy_done:
    mov [grid_width], r12
    
    ; Part 1 Logic
    xor r13, r13            ; total Part 1
    xor rbx, rbx            ; current col
.p1_find_block:
    cmp rbx, [grid_width]
    jae .p1_done
    
    ; Is this column empty?
    call is_col_empty
    test al, al
    jnz .p1_skip_col
    
    ; Found start of block
    mov r14, rbx            ; block start
.p1_block_end:
    inc rbx
    cmp rbx, [grid_width]
    jae .p1_process_block
    call is_col_empty
    test al, al
    jz .p1_block_end
    
.p1_process_block:
    ; Block is [r14, rbx - 1]
    ; 1. Find operator at row 4
    push rbx
    
    xor rdi, rdi            ; operator char (using RDI now)
    mov r8, r14
.p1_find_op:
    cmp r8, rbx            ; search row 4 for operator
    jae .p1_op_found
    movzx eax, byte [grid + 4*4096 + r8]
    cmp al, ' '
    je .p1_next_op
    mov rdi, rax
    jmp .p1_op_found
.p1_next_op:
    inc r8
    jmp .p1_find_op

.p1_op_found:
    ; 2. Parse 4 rows
    xor r11, r11            ; number count
    xor r15, r15            ; current accumulator
    
    xor r12, r12            ; r = 0
.p1_row_loop:
    cmp r12, 4
    jae .p1_block_done
    
    ; Parse grid[r12][r14..rbx-1]
    mov rcx, r12
    mov rdx, r14
    mov r8, rbx
    call parse_row_num
    cmp rax, -1             ; no number in row
    je .p1_next_row
    
    ; Apply operator
    test r11, r11
    jnz .p1_apply
    mov r15, rax
    jmp .p1_inc_num
    
.p1_apply:
    cmp dil, '+'
    jne .p1_mul
    add r15, rax
    jmp .p1_inc_num
.p1_mul:
    imul r15, rax

.p1_inc_num:
    inc r11
.p1_next_row:
    inc r12
    jmp .p1_row_loop

.p1_block_done:
    add r13, r15
    pop rbx
    jmp .p1_find_block

.p1_skip_col:
    inc rbx
    jmp .p1_find_block

.p1_done:
    ; End timing for Part 1
    call GetTickCount64
    mov [rbp-64], rax       ; Save end time

    ; Print Part 1
    call print_newline
    lea rcx, [msg_part1_header]
    call print_string
    lea rcx, [msg_part1]
    call print_string
    mov rcx, r13
    call print_number
    mov rcx, [rbp-56]       ; Start time
    mov rdx, [rbp-64]       ; End time
    call print_elapsed
    call print_newline

    ; Part 2 Logic
    xor r13, r13            ; total Part 2
    xor rbx, rbx            ; current col
.p2_find_block:
    cmp rbx, [grid_width]
    jae .p2_done
    
    call is_col_empty
    test al, al
    jnz .p2_skip_col
    
    mov r14, rbx            ; block start
.p2_block_end:
    inc rbx
    cmp rbx, [grid_width]
    jae .p2_process_block
    call is_col_empty
    test al, al
    jz .p2_block_end
    
.p2_process_block:
    push rbx
    
    ; Find operator
    xor rdi, rdi            ; operator (using RDI now)
    mov r8, r14
.p2_find_op:
    cmp r8, rbx
    jae .p2_op_found
    movzx eax, byte [grid + 4*4096 + r8]
    cmp al, ' '
    je .p2_next_op
    mov rdi, rax
    jmp .p2_op_found
.p2_next_op:
    inc r8
    jmp .p2_find_op

.p2_op_found:
    ; Parse columns right-to-left
    xor r11, r11            ; num count
    xor r15, r15            ; accumulator
    
    mov r12, rbx
    dec r12                 ; c = block_end - 1
.p2_col_loop:
    cmp r12, r14
    jl .p2_block_done
    
    ; Parse column r12
    mov rcx, r12
    call parse_col_num
    cmp rax, -1
    je .p2_next_col
    
    test r11, r11
    jnz .p2_apply
    mov r15, rax
    jmp .p2_inc_num
.p2_apply:
    cmp dil, '+'
    jne .p2_mul
    add r15, rax
    jmp .p2_inc_num
.p2_mul:
    imul r15, rax
.p2_inc_num:
    inc r11
.p2_next_col:
    dec r12
    jmp .p2_col_loop

.p2_block_done:
    add r13, r15
    pop rbx
    jmp .p2_find_block

.p2_skip_col:
    inc rbx
    jmp .p2_find_block

.p2_done:
    ; End timing for Part 2
    call GetTickCount64
    mov [rbp-64], rax       ; Save end time

    call print_newline
    lea rcx, [msg_part2_header]
    call print_string
    lea rcx, [msg_part2]
    call print_string
    mov rcx, r13
    call print_number
    mov rcx, [rbp-56]       ; Start time
    mov rdx, [rbp-64]       ; End time
    call print_elapsed
    call print_newline

.done:
    add rsp, 64
    pop r15
    pop r14
    pop r13
    pop r12
    pop rdi
    pop rsi
    pop rbx
    pop rbp
    ret

; -----------------------------------------------------------------------------
; is_col_empty
; Input: RBX = col index
; Output: AL = 1 if empty (only spaces in all 5 rows), else 0
; -----------------------------------------------------------------------------
is_col_empty:
    xor rcx, rcx            ; row
.loop:
    cmp rcx, 5
    jae .empty
    mov rdx, rcx
    shl rdx, 12
    add rdx, rbx
    cmp byte [grid + rdx], ' '
    jne .not_empty
    inc rcx
    jmp .loop
.not_empty:
    xor al, al
    ret
.empty:
    mov al, 1
    ret

; -----------------------------------------------------------------------------
; parse_row_num
; Input: RCX = row index, RDX = start_c, R8 = end_c
; Output: RAX = number, or -1 if no digits
; -----------------------------------------------------------------------------
parse_row_num:
    push rbx
    push rsi
    push rdi
    
    lea rdi, [num_str]
    xor r10, r10            ; wrote chars
    
    mov rbx, rdx            ; cur_c
.loop:
    cmp rbx, r8
    jae .parse
    
    mov r9, rcx
    shl r9, 12
    add r9, rbx
    movzx eax, byte [grid + r9]
    cmp al, '0'
    jb .next
    cmp al, '9'
    ja .next
    
    mov [rdi], al
    inc rdi
    inc r10
.next:
    inc rbx
    jmp .loop

.parse:
    test r10, r10
    jz .fail
    mov byte [rdi], 0
    lea rcx, [num_str]
    call atoi64
    jmp .exit

.fail:
    mov rax, -1
.exit:
    pop rdi
    pop rsi
    pop rbx
    ret

; -----------------------------------------------------------------------------
; parse_col_num
; Input: RCX = column index
; Output: RAX = number, or -1 if no digits
; -----------------------------------------------------------------------------
parse_col_num:
    push rbx
    
    xor rax, rax            ; accumulator
    xor r10, r10            ; found digits
    
    xor rbx, rbx            ; row
.loop:
    cmp rbx, 4
    jae .done
    
    mov rdx, rbx
    shl rdx, 12
    add rdx, rcx
    movzx r8d, byte [grid + rdx]
    cmp r8b, '0'
    jb .next
    cmp r8b, '9'
    ja .next
    
    imul rax, 10
    sub r8b, '0'
    movzx rdx, r8b
    add rax, rdx
    inc r10
.next:
    inc rbx
    jmp .loop

.done:
    test r10, r10
    jnz .exit
    mov rax, -1
.exit:
    pop rbx
    ret
