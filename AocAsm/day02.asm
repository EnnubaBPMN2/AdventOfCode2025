; day02.asm - Advent of Code 2025 Day 02
default rel
bits 64

section .data
    real_file db '../inputs/day02.txt', 0
    msg_part1_header db '=== Part 1 ===', 13, 10, 0
    msg_part1 db 'Result: ', 0
    msg_part2_header db '=== Part 2 ===', 13, 10, 0
    msg_part2 db 'Result: ', 0
    msg_debug_read db '[DEBUG] Read bytes: ', 0

section .bss
    buffer resb 1048576     ; 1MB input buffer (day 2 input can be large)
    id_str resb 32          ; Buffer for integer to string conversion

section .text
    global day02_run
    extern read_file, print_string, print_number, print_newline, atoi64

day02_run:
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

    mov r14, rax            ; r14 = buffer length
    
    ; Debug: Print bytes read
    lea rcx, [msg_debug_read]
    call print_string
    mov rcx, r14
    call print_number
    call print_newline

    lea rsi, [buffer]       ; rsi = current position in buffer
    lea r15, [buffer + r14] ; r15 = end of buffer
    
    xor r12, r12            ; r12 = part 1 total
    xor r13, r13            ; r13 = part 2 total

.parse_loop:
    cmp rsi, r15
    jae .print_results

    movzx eax, byte [rsi]
    cmp al, '0'
    jb .skip_char
    cmp al, '9'
    ja .skip_char
    
    ; Found start of range
    mov rcx, rsi
    call atoi64
    mov rbx, rax            ; rbx = min_val (current ID in loop)
    add rsi, rdx            ; skip min_val
    
    cmp byte [rsi], '-'
    jne .parse_loop         ; Should not happen with valid input
    inc rsi                 ; skip '-'
    
    mov rcx, rsi
    call atoi64
    mov rdi, rax            ; rdi = max_val
    add rsi, rdx            ; skip max_val
    
.range_loop:
    cmp rbx, rdi
    ja .parse_loop
    
    ; Part 1
    mov rcx, rbx
    call is_invalid_id_part1
    test rax, rax
    jz .check_p2
    add r12, rbx

.check_p2:
    mov rcx, rbx
    call is_invalid_id_part2
    test rax, rax
    jz .next_id
    add r13, rbx

.next_id:
    inc rbx
    jmp .range_loop

.skip_char:
    inc rsi
    jmp .parse_loop

.print_results:
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

; -----------------------------------------------------------------------------
; is_invalid_id_part1
; Input: RCX = ID
; Output: RAX = 1 if invalid, 0 otherwise
; -----------------------------------------------------------------------------
is_invalid_id_part1:
    push rbp
    mov rbp, rsp
    push rbx
    push rsi
    push rdi
    sub rsp, 32

    mov rbx, rcx            ; Save ID
    call i64toa             ; RAX = length, RDI = pointer to string
    
    mov rcx, rax            ; RCX = length
    test rcx, 1             ; Must be even length
    jnz .fail
    
    shr rcx, 1              ; RCX = half length
    mov rsi, rdi            ; RSI = start of string
    lea rdi, [rsi + rcx]    ; RDI = start of second half
    
    repe cmpsb              ; Compare both halves
    jne .fail
    
    mov rax, 1
    jmp .done
.fail:
    xor rax, rax
.done:
    add rsp, 32
    pop rdi
    pop rsi
    pop rbx
    pop rbp
    ret

; -----------------------------------------------------------------------------
; is_invalid_id_part2
; Input: RCX = ID
; Output: RAX = 1 if invalid, 0 otherwise
; -----------------------------------------------------------------------------
is_invalid_id_part2:
    push rbp
    mov rbp, rsp
    push rbx
    push rsi
    push rdi
    push r12
    push r13
    sub rsp, 32

    mov rbx, rcx
    call i64toa
    mov r12, rax            ; r12 = length
    mov r13, rdi            ; r13 = string pointer
    
    ; for (L = 1; L <= len/2; L++)
    mov rbx, 1              ; rbx = L
.length_loop:
    mov rax, rbx
    shl rax, 1
    cmp rax, r12
    ja .fail                ; L > len/2
    
    ; if (len % L == 0)
    mov rax, r12
    xor rdx, rdx
    div rbx
    test rdx, rdx
    jnz .next_L
    
    ; check if s[i] == s[i % L]
    mov rsi, rbx            ; rsi = i
.match_loop:
    cmp rsi, r12
    jae .found_match
    
    ; s[i] vs s[i % L]
    mov rax, rsi
    xor rdx, rdx
    div rbx                 ; rdx = i % L
    
    mov al, [r13 + rsi]
    cmp al, [r13 + rdx]
    jne .next_L
    
    inc rsi
    jmp .match_loop

.found_match:
    mov rax, 1
    jmp .done

.next_L:
    inc rbx
    jmp .length_loop

.fail:
    xor rax, rax
.done:
    add rsp, 32
    pop r13
    pop r12
    pop rdi
    pop rsi
    pop rbx
    pop rbp
    ret

; -----------------------------------------------------------------------------
; i64toa
; Input: RCX = 64-bit integer
; Output: RAX = length, RDI = pointer to string (in id_str)
; -----------------------------------------------------------------------------
i64toa:
    push rdx
    push rbx
    
    mov rax, rcx
    lea rdi, [id_str + 31]
    mov byte [rdi], 0
    mov rbx, 10
    
    xor rcx, rcx            ; length counter
.loop:
    xor rdx, rdx
    div rbx                 ; rax = quot, rdx = rem
    add dl, '0'
    dec rdi
    mov [rdi], dl
    inc rcx
    test rax, rax
    jnz .loop
    
    mov rax, rcx            ; Length in RAX
    ; RDI is already pointing to start of string
    pop rbx
    pop rdx
    ret
