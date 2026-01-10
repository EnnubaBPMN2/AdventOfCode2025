; print.asm - Console output and string conversion
default rel
bits 64

section .data
    newline db 13, 10, 0

section .bss
    stdout resq 1
    num_buf resb 32

section .text
    global init_print
    global print_string
    global print_number
    global print_newline
    global print_elapsed
    extern GetStdHandle, WriteConsoleA, lstrlenA, GetTickCount64

    ; Constant
    STD_OUTPUT_HANDLE equ -11

init_print:
    sub rsp, 32
    mov rcx, STD_OUTPUT_HANDLE
    call GetStdHandle
    mov [stdout], rax
    add rsp, 32
    ret

; -----------------------------------------------------------------------------
; print_string
; Input: RCX = pointer to null-terminated string
; -----------------------------------------------------------------------------
print_string:
    push rbp
    mov rbp, rsp
    push rsi                ; Preserve RSI
    sub rsp, 48

    mov rsi, rcx            ; Save string pointer

    ; Get length
    call lstrlenA
    mov r8, rax             ; Length in R8

    ; WriteFile
    mov rcx, [stdout]       ; hFile
    mov rdx, rsi            ; lpBuffer
    ; R8: nNumberOfBytesToWrite (already set)
    lea r9, [rbp-16]        ; lpNumberOfBytesWritten
    mov qword [rsp+32], 0   ; lpOverlapped
    extern WriteFile
    call WriteFile

    add rsp, 48
    pop rsi
    pop rbp
    ret

; -----------------------------------------------------------------------------
; print_number
; Input: RCX = 64-bit unsigned integer
; -----------------------------------------------------------------------------
print_number:
    push rbp
    mov rbp, rsp
    push rdi                ; Preserve RDI
    push rbx                ; Preserve RBX
    sub rsp, 32

    mov rax, rcx            ; Number to convert
    lea rdi, [num_buf + 31]
    mov byte [rdi], 0       ; Null terminator
    mov rbx, 10             ; Divisor

.convert_loop:
    xor rdx, rdx
    div rbx                 ; RAX = Quotient, RDX = Remainder
    add dl, '0'
    dec rdi
    mov [rdi], dl
    test rax, rax
    jnz .convert_loop

    mov rcx, rdi
    call print_string

    add rsp, 32
    pop rbx
    pop rdi
    pop rbp
    ret

print_newline:
    sub rsp, 32
    lea rcx, [newline]
    call print_string
    add rsp, 32
    ret

; -----------------------------------------------------------------------------
; print_elapsed
; Input: RCX = start time (ms), RDX = end time (ms)
; Output: Prints [#.##0s]
; -----------------------------------------------------------------------------
print_elapsed:
    push rbp
    mov rbp, rsp
    push rbx
    push rdi
    sub rsp, 48

    mov rax, rdx
    sub rax, rcx            ; RAX = elapsed ms
    
    ; Save elapsed ms
    mov rbx, rax

    ; Print "["
    push rbx
    sub rsp, 32
    mov rcx, .msg_open
    call print_string
    add rsp, 32
    pop rbx

    ; Print Seconds (X.000)
    mov rax, rbx
    xor rdx, rdx
    mov rcx, 1000
    div rcx                 ; RAX = seconds, RDX = milliseconds
    
    push rdx
    mov rcx, rax
    call print_number
    pop rdx

    ; Print "."
    push rdx
    sub rsp, 32
    mov rcx, .msg_dot
    call print_string
    add rsp, 32
    pop rdx

    ; Print Milliseconds (three digits, zero-padded)
    ; RDX has 0-999
    mov rax, rdx
    mov rbx, 10
    lea rdi, [num_buf + 10]
    mov byte [rdi], 0       ; Null terminator

    ; Always write exactly 3 digits
    dec rdi
    xor rdx, rdx
    div rbx
    add dl, '0'
    mov [rdi], dl           ; digit 3 (ones)

    dec rdi
    xor rdx, rdx
    div rbx
    add dl, '0'
    mov [rdi], dl           ; digit 2 (tens)

    dec rdi
    xor rdx, rdx
    div rbx
    add dl, '0'
    mov [rdi], dl           ; digit 1 (hundreds)

    mov rcx, rdi
    call print_string

    ; Print "s]"
    sub rsp, 32
    mov rcx, .msg_close
    call print_string
    add rsp, 32

    add rsp, 48
    pop rdi
    pop rbx
    pop rbp
    ret

section .data
    .msg_open  db ' [', 0
    .msg_dot   db '.', 0
    .msg_close db 's]', 0
