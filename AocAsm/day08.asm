; day08.asm - Advent of Code 2025 Day 08
default rel
bits 64

section .data
    real_file db '../inputs/day08.txt', 0
    msg_part1_header db '=== Part 1 ===', 13, 10, 0
    msg_part1 db 'Result: ', 0
    msg_part2_header db '=== Part 2 ===', 13, 10, 0
    msg_part2 db 'Result: ', 0

section .bss
    buffer resb 1048576
    coords resq 3000
    box_count resq 1
    edges resq 500000
    edge_count resq 1
    parent resd 1000
    sz resd 1000
    num_components resq 1
    comp_sizes resd 1000

section .text
    global day08_run
    extern read_file, print_string, print_number, print_newline, atoi64

day08_run:
    push rbp
    mov rbp, rsp
    push rbx
    push rsi
    push rdi
    push r12
    push r13
    push r14
    push r15
    sub rsp, 32

    ; 1. Read file
    lea rcx, [real_file]
    lea rdx, [buffer]
    mov r8, 1048575
    call read_file
    cmp rax, -1
    je .done
    test rax, rax
    jz .done

    mov r14, rax            ; bytes read
    lea r15, [buffer + r14] ; buffer end
    
    ; 2. Parse coordinates
    lea rsi, [buffer]
    xor r13, r13            ; box_idx
.parse_loop:
    cmp rsi, r15
    jae .parsed
    
    ; Parse X
    mov rcx, rsi
    call atoi64
    imul r9, r13, 24
    mov [coords + r9], rax
    add rsi, rdx
    call skip_to_digit
    
    ; Parse Y
    mov rcx, rsi
    call atoi64
    imul r9, r13, 24
    mov [coords + r9 + 8], rax
    add rsi, rdx
    call skip_to_digit
    
    ; Parse Z
    mov rcx, rsi
    call atoi64
    imul r9, r13, 24
    mov [coords + r9 + 16], rax
    add rsi, rdx
    call skip_to_digit
    
    inc r13
    cmp r13, 1000
    jl .parse_loop

.parsed:
    mov [box_count], r13

    ; 3. Generate all edges
    xor r12, r12            ; i1
    xor r14, r14            ; edge_count
.edge_i:
    mov r13, r12
    inc r13                 ; i2 = i1 + 1
.edge_j:
    cmp r13, [box_count]
    jae .edge_i_next
    
    imul r8, r12, 24
    imul r9, r13, 24
    
    ; dx^2 + dy^2 + dz^2
    mov rax, [coords + r8]
    sub rax, [coords + r9]
    imul rax, rax
    mov rbx, rax
    
    mov rax, [coords + r8 + 8]
    sub rax, [coords + r9 + 8]
    imul rax, rax
    add rbx, rax
    
    mov rax, [coords + r8 + 16]
    sub rax, [coords + r9 + 16]
    imul rax, rax
    add rbx, rax            ; rbx = dist_sq
    
    ; Pack edge: [dist:40][i1:12][i2:12]
    ; dist_sq is at most 3*10^10, which fits in 40 bits.
    mov rax, rbx
    shl rax, 24
    mov rdx, r12
    and rdx, 0xFFF
    shl rdx, 12
    or rax, rdx
    mov rdx, r13
    and rdx, 0xFFF
    or rax, rdx
    
    mov [edges + r14*8], rax
    inc r14
    inc r13
    jmp .edge_j

.edge_i_next:
    inc r12
    mov rax, [box_count]
    dec rax
    cmp r12, rax
    jl .edge_i
    
    mov [edge_count], r14
    
    ; 4. Sort edges (Comb Sort)
    mov rsi, [edge_count]
    mov r12, rsi            ; gap
.sort_gap:
    imul r12, 10
    mov rax, r12
    xor rdx, rdx
    mov rcx, 13
    div rcx
    mov r12, rax
    test r12, r12
    jnz .gap_ok
    mov r12, 1
.gap_ok:
    xor r13, r13            ; swapped = 0
    xor rbx, rbx            ; i = 0
.sort_loop:
    mov rdi, rbx
    add rdi, r12            ; i + gap
    cmp rdi, rsi
    jae .sort_next_gap
    
    mov rax, [edges + rbx*8]
    mov rdx, [edges + rdi*8]
    cmp rax, rdx
    jbe .sort_no_swap
    
    mov [edges + rbx*8], rdx
    mov [edges + rdi*8], rax
    mov r13, 1
.sort_no_swap:
    inc rbx
    jmp .sort_loop

.sort_next_gap:
    cmp r12, 1
    jne .sort_gap
    test r13, r13
    jnz .sort_gap

    ; 5. Part 1: Kruskal for first 1000 edges
    call dsu_init
    xor rbx, rbx            ; edge_idx
.p1_loop:
    cmp rbx, 1000
    jae .p1_done
    cmp rbx, [edge_count]
    jae .p1_done
    
    mov rax, [edges + rbx*8]
    mov rdx, rax
    and rdx, 0xFFF          ; i2
    shr rax, 12
    and rax, 0xFFF          ; i1
    mov rcx, rax
    ; rdx is i2, rcx is i1
    call dsu_union
    
    inc rbx
    jmp .p1_loop

.p1_done:
    call find_largest_3
    push rax
    call print_newline
    lea rcx, [msg_part1_header]
    call print_string
    lea rcx, [msg_part1]
    call print_string
    pop rcx
    call print_number
    call print_newline

    ; 6. Part 2: Continue Kruskal until components == 1
.p2_loop:
    cmp rbx, [edge_count]
    jae .p2_done
    
    mov rax, [edges + rbx*8]
    mov r14, rax
    and r14, 0xFFF          ; i2
    mov r15, rax
    shr r15, 12
    and r15, 0xFFF          ; i1
    
    mov rcx, r15
    mov rdx, r14
    call dsu_union_track    ; returns 1 if merged
    
    cmp qword [num_components], 1
    je .p2_success
    
    inc rbx
    jmp .p2_loop

.p2_success:
    ; Product of X coords of r15 and r14
    imul r8, r15, 24
    imul r9, r14, 24
    mov rax, [coords + r8]
    imul rax, [coords + r9]
    push rax
    jmp .p2_out

.p2_done:
    push 0                  ; Should not happen
.p2_out:
    lea rcx, [msg_part2_header]
    call print_string
    lea rcx, [msg_part2]
    call print_string
    pop rcx
    call print_number
    call print_newline

.done:
    add rsp, 32
    pop r15
    pop r14
    pop r13
    pop r12
    pop rdi
    pop rsi
    pop rbx
    pop rbp
    ret

; --- Helpers ---

skip_to_digit:
.loop:
    cmp rsi, r15
    jae .done
    movzx eax, byte [rsi]
    cmp al, '0'
    jb .next
    cmp al, '9'
    jbe .done
.next:
    inc rsi
    jmp .loop
.done:
    ret

dsu_init:
    mov rax, [box_count]
    mov [num_components], rax
    xor rcx, rcx
.loop:
    cmp rcx, [box_count]
    jae .done
    mov [parent + rcx*4], ecx
    mov dword [sz + rcx*4], 1
    inc rcx
    jmp .loop
.done:
    ret

dsu_find:
    mov eax, [parent + rcx*4]
    cmp eax, ecx
    je .exit
    push rcx
    mov ecx, eax
    call dsu_find
    pop rcx
    mov [parent + rcx*4], eax
.exit:
    ret

dsu_union:
    push rbx
    push rdx
    call dsu_find
    mov ebx, eax            ; root1
    pop rcx                 ; pop original rdx into rcx
    call dsu_find
    mov edx, eax            ; root2
    
    cmp ebx, edx
    je .done
    
    dec qword [num_components]
    mov eax, [sz + rdx*4]
    add [sz + rbx*4], eax
    mov [parent + rdx*4], ebx
.done:
    pop rbx
    ret

dsu_union_track:
    push rbx
    push rdx
    call dsu_find
    mov ebx, eax            ; root1
    pop rcx                 ; pop original rdx into rcx
    call dsu_find
    mov edx, eax            ; root2
    
    cmp ebx, edx
    je .no
    
    dec qword [num_components]
    mov eax, [sz + rdx*4]
    add [sz + rbx*4], eax
    mov [parent + rdx*4], ebx
    mov rax, 1
    pop rbx
    ret
.no:
    xor rax, rax
    pop rbx
    ret

find_largest_3:
    ; 1. Collect root sizes
    xor r8, r8
    xor rcx, rcx
.collect:
    cmp rcx, [box_count]
    jae .sort_sizes
    mov edx, [parent + rcx*4]
    cmp edx, ecx
    jne .next
    mov eax, [sz + rcx*4]
    mov [comp_sizes + r8*4], eax
    inc r8
.next:
    inc rcx
    jmp .collect

.sort_sizes:
    test r8, r8
    jz .failed
    mov r9, r8
    dec r9
.outer:
    test r9, r9
    js .sort_done
    xor r10, r10
.inner:
    cmp r10, r9
    jae .inner_done
    mov eax, [comp_sizes + r10*4]
    mov edx, [comp_sizes + r10*4 + 4]
    cmp eax, edx
    jae .no_swap
    mov [comp_sizes + r10*4], edx
    mov [comp_sizes + r10*4 + 4], eax
.no_swap:
    inc r10
    jmp .inner
.inner_done:
    dec r9
    jmp .outer

.sort_done:
    mov eax, [comp_sizes]
    mov edx, [comp_sizes + 4]
    imul rax, rdx
    mov edx, [comp_sizes + 8]
    imul rax, rdx
    ret
.failed:
    xor rax, rax
    ret
