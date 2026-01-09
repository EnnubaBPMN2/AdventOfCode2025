; day01.asm - Day 1: Secret Entrance
default rel
bits 64

section .data
    test_file db '../inputs/day01_test.txt', 0
    real_file db '../inputs/day01.txt', 0
    msg_part1_header db '=== Part 1 ===', 13, 10, 0
    msg_part1 db 'Result: ', 0
    msg_part2_header db '=== Part 2 ===', 13, 10, 0
    msg_part2 db 'Result: ', 0
    msg_debug_read db '[DEBUG] Read bytes: ', 0

section .bss
    buffer resb 65536       ; 64KB input buffer

section .text
    global day01_run
    extern read_file, print_string, print_number, print_newline, atoi64

day01_run:
    push rbp
    mov rbp, rsp
    push rsi                ; Preserve RSI
    push rdi                ; Preserve RDI
    push rbx                ; Preserve RBX
    push r12
    push r13
    push r14
    push r15
    sub rsp, 48

    lea rcx, [real_file]
    lea rdx, [buffer]
    mov r8, 65535
    call read_file
    
    cmp rax, -1
    je .done_cleanup
    test rax, rax
    jz .done_cleanup

    mov r14, rax            ; r14 = buffer length
    
    ; Debug: Print bytes read
    lea rcx, [msg_debug_read]
    call print_string
    mov rcx, r14
    call print_number
    call print_newline

    lea rsi, [buffer]       ; rsi = current position in buffer
    lea r15, [buffer + r14] ; r15 = end of buffer

    mov rbx, 50              ; rbx = dial position (0-99) - preserved by calls
    xor r12, r12            ; r12 = part 1 answer
    xor r13, r13            ; r13 = part 2 answer

.parse_loop:
    cmp rsi, r15
    jae .print_results

    movzx rax, byte [rsi]
    
    ; Check if L or R
    cmp al, 'L'
    je .handle_rotation
    cmp al, 'R'
    je .handle_rotation
    
    inc rsi
    jmp .parse_loop

.handle_rotation:
    mov r11, rax            ; r11 = 'L' or 'R' (R9 is destroyed by atoi64)
    inc rsi                 ; skip L/R
    
    mov rcx, rsi
    call atoi64             ; rax = distance, rdx = chars consumed
    add rsi, rdx            ; skip distance digits
    
    mov rcx, rax            ; rcx = distance loop counter
.rotation_loop:
    test rcx, rcx
    jz .rotation_done
    
    cmp r11b, 'L'
    je .move_left
    
    ; Move Right
    inc rbx
    cmp rbx, 100
    jne .check_zero_part2
    xor rbx, rbx
    jmp .check_zero_part2

.move_left:
    dec rbx
    cmp rbx, -1
    jne .check_zero_part2
    mov rbx, 99

.check_zero_part2:
    test rbx, rbx
    jnz .next_click
    inc r13                 ; Count for Part 2
.next_click:
    dec rcx
    jmp .rotation_loop

.rotation_done:
    ; Check Part 1 (end of rotation)
    test rbx, rbx
    jnz .parse_loop
    inc r12
    jmp .parse_loop

.print_results:
    ; Match C version style
    call print_newline
    lea rcx, [msg_part1_header]
    call print_string
    lea rcx, [msg_part1]
    call print_string
    mov rcx, r12
    call print_number
    call print_newline

    call print_newline
    lea rcx, [msg_part2_header]
    call print_string
    lea rcx, [msg_part2]
    call print_string
    mov rcx, r13
    call print_number
    call print_newline

.done_cleanup:
    add rsp, 48
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rdi
    pop rsi
    pop rbp
    ret
