; io.asm - Windows API File I/O wrappers
default rel
bits 64

section .text
    global read_file
    global close_file
    extern CreateFileA, ReadFile, CloseHandle

    ; Constants
    GENERIC_READ equ 0x80000000
    FILE_SHARE_READ equ 1
    OPEN_EXISTING equ 3

; -----------------------------------------------------------------------------
; read_file
; Input:  RCX = pointer to filename (string)
;         RDX = pointer to buffer
;         R8  = buffer size
; Output: RAX = number of bytes read, or -1 on error
; -----------------------------------------------------------------------------
read_file:
    push rbp
    mov rbp, rsp
    push rbx
    sub rsp, 64             ; 32 (shadow) + 16 (args 5/6) + 16 (locals)

    mov [rbp-16], rdx       ; Save buffer pointer (rbp-8 is rbx)
    mov [rbp-24], r8        ; Save buffer size

    ; CreateFileA
    mov rdx, GENERIC_READ
    mov r8, FILE_SHARE_READ
    xor r9, r9
    mov qword [rsp+32], OPEN_EXISTING
    mov qword [rsp+40], 0
    call CreateFileA

    cmp rax, -1
    je .error

    mov rbx, rax            ; File handle
    
    ; ReadFile
    mov rcx, rbx
    mov rdx, [rbp-16]       ; Restore buffer pointer
    mov r8, [rbp-24]        ; Restore buffer size
    lea r9, [rbp-32]        ; lpNumberOfBytesRead (next local)
    mov qword [rsp+32], 0
    extern ReadFile
    call ReadFile
    
    test rax, rax
    jz .error_close

    mov rcx, rbx
    call CloseHandle

    movzx rax, dword [rbp-32] ; Return bytes read
    jmp .done

.error_close:
    mov rcx, rbx
    call CloseHandle
.error:
    mov rax, -1
.done:
    add rsp, 64
    pop rbx
    pop rbp
    ret

; -----------------------------------------------------------------------------
; close_file
; Input: RCX = file handle
; -----------------------------------------------------------------------------
close_file:
    sub rsp, 32
    call CloseHandle
    add rsp, 32
    ret
