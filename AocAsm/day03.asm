; day03.asm - Advent of Code 2025 Day 03
default rel
bits 64

section .data
    real_file db '../inputs/day03.txt', 0
    msg_part1_header db '=== Part 1 ===', 13, 10, 0
    msg_part1 db 'Result: ', 0
    msg_part2_header db '=== Part 2 ===', 13, 10, 0
    msg_part2 db 'Result: ', 0

section .bss
    buffer resb 1048576     ; 1MB input buffer
    bank_buf resb 1024      ; Buffer for a single bank (line)

section .text
    global day03_run
    extern read_file, print_string, print_number, print_newline
    extern GetTickCount64, print_elapsed

day03_run:
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

    mov r14, rax            ; r14 = total bytes read

    lea rsi, [buffer]       ; rsi = current position in buffer
    lea r15, [buffer + r14] ; r15 = end of buffer
    
    xor r12, r12            ; r12 = Part 1 total
    xor r13, r13            ; r13 = Part 2 total

.line_loop:
    cmp rsi, r15
    jae .print_results

    ; Extract one line into bank_buf
    lea rdi, [bank_buf]
    xor rcx, rcx            ; rcx = line length
.extract_line:
    cmp rsi, r15
    jae .line_extracted
    mov al, [rsi]
    cmp al, 10              ; LF
    je .skip_lf
    cmp al, 13              ; CR
    je .skip_cr
    
    ; It's a digit (hopefully)
    mov [rdi + rcx], al
    inc rcx
    inc rsi
    cmp rcx, 1023
    jl .extract_line
    jmp .line_extracted

.skip_lf:
    inc rsi
    jmp .line_extracted
.skip_cr:
    inc rsi
    cmp rsi, r15
    jae .line_extracted
    cmp byte [rsi], 10      ; CR+LF
    jne .line_extracted
    inc rsi

.line_extracted:
    test rcx, rcx
    jz .line_loop           ; Skip empty lines
    
    ; Process bank in bank_buf, length in rcx
    push rsi
    push rcx
    
    ; Part 1: N = 2
    mov rdx, 2
    call find_largest_number
    add r12, rax
    
    ; Part 2: N = 12
    pop rcx                 ; Restore length
    push rcx
    mov rdx, 12
    call find_largest_number
    add r13, rax
    
    pop rcx
    pop rsi
    jmp .line_loop

.print_results:
    ; End timing
    call GetTickCount64
    mov [rbp-64], rax       ; Save end time

    call print_newline
    lea rcx, [msg_part1_header]
    call print_string
    lea rcx, [msg_part1]
    call print_string
    mov rcx, r12
    call print_number
    mov rcx, [rbp-56]       ; Start time
    mov rdx, [rbp-64]       ; End time
    call print_elapsed
    call print_newline

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
; find_largest_number
; Input: RDI = pointer to bank string
;        RCX = length of bank
;        RDX = N (number of digits to pick)
; Output: RAX = result number
; -----------------------------------------------------------------------------
find_largest_number:
    push rbx
    push rsi
    push rdi
    push r12
    push r13
    push r14
    push r15
    
    mov r12, rdi            ; bank pointer
    mov r13, rcx            ; bank length
    mov r14, rdx            ; N to pick
    
    xor r15, r15            ; r15 = result accumulator
    xor rbx, rbx            ; rbx = last picked index + 1
    xor rsi, rsi            ; rsi = current digit position (0 to N-1)

.digit_loop:
    cmp rsi, r14
    jae .done_calc
    
    ; Pick max digit in range [rbx, length - (N - rsi - 1) - 1]
    ; Example: len=5, N=2, rsi=0. Range [0, 5-(2-0-1)-1] = [0, 5-1-1] = [0, 3].
    
    mov rax, r14
    sub rax, rsi
    dec rax                 ; rax = N - rsi - 1
    mov r8, r13
    sub r8, rax
    dec r8                  ; r8 = upper bound (inclusive)
    
    xor r9, r9              ; r9 = max digit found
    mov r10, rbx            ; r10 = index in range
    mov r11, rbx            ; r11 = index of max digit

.search_max:
    cmp r10, r8
    ja .found_max
    
    movzx rax, byte [r12 + r10]
    sub al, '0'
    cmp al, r9b
    jbe .not_larger
    mov r9b, al
    mov r11, r10
.not_larger:
    inc r10
    jmp .search_max

.found_max:
    ; Digit in r9b, index in r11
    ; Accumulate: res = res * 10 + digit
    imul r15, 10
    movzx rax, r9b
    add r15, rax
    
    lea rbx, [r11 + 1]      ; Start next search from r11 + 1
    inc rsi
    jmp .digit_loop

.done_calc:
    mov rax, r15
    
    pop r15
    pop r14
    pop r13
    pop r12
    pop rdi
    pop rsi
    pop rbx
    ret
