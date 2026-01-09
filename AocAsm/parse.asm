; parse.asm - String parsing utilities
default rel
bits 64

section .text
    global atoi64

; -----------------------------------------------------------------------------
; atoi64
; Input:  RCX = pointer to string
; Output: RAX = 64-bit integer, RDX = characters consumed
; -----------------------------------------------------------------------------
atoi64:
    xor rax, rax
    xor rdx, rdx
    xor r8, r8              ; Counter

.loop:
    movzx r9, byte [rcx + r8]
    cmp r9b, '0'
    jb .done
    cmp r9b, '9'
    ja .done

    sub r9b, '0'
    imul rax, 10
    add rax, r9
    inc r8
    jmp .loop

.done:
    mov rdx, r8
    ret
