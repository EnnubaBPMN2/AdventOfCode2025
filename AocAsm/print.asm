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
    extern GetStdHandle, WriteConsoleA, lstrlenA

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
