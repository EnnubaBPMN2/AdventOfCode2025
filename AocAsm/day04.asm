; day04.asm - Advent of Code 2025 Day 04
default rel
bits 64

section .data
    real_file db '../inputs/day04.txt', 0
    msg_part1_header db '=== Part 1 ===', 13, 10, 0
    msg_part1 db 'Result: ', 0
    msg_part2_header db '=== Part 2 ===', 13, 10, 0
    msg_part2 db 'Result: ', 0
    msg_debug_read db '[DEBUG] Read bytes: ', 0

    ; Offsets for 8 neighbors
    dr dd -1, -1, -1,  0, 0,  1, 1, 1
    dc dd -1,  0,  1, -1, 1, -1, 0, 1

section .bss
    buffer resb 1048576     ; Input file buffer
    grid1  resb 65536       ; 256x256 max grid (138x138 is actual)
    grid2  resb 65536
    
    grid_w resq 1
    grid_h resq 1
    range_count resq 1
    id_count resq 1
    queue  resd 65536       ; Queue of (r << 8 | c)

section .text
    global day04_run
    extern read_file, print_string, print_number, print_newline

day04_run:
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
    lea r15, [buffer + r14] ; r15 = buffer end
    
    ; Parse into grid1
    lea rsi, [buffer]
    lea rdi, [grid1]
    xor rcx, rcx            ; cur_r
    xor rdx, rdx            ; cur_c
    xor rbx, rbx            ; max_c
    
.parse_loop:
    cmp rsi, r15
    jae .parse_done
    
    lodsb
    cmp al, 10
    je .next_line
    cmp al, 13
    je .parse_loop
    
    ; Store in grid1[rcx][rdx]
    ; index = rcx * 256 + rdx
    mov r8, rcx
    shl r8, 8
    add r8, rdx
    mov [grid1 + r8], al
    inc rdx
    jmp .parse_loop

.next_line:
    cmp rdx, rbx
    jbe .no_new_max
    mov rbx, rdx
.no_new_max:
    test rdx, rdx
    jz .parse_loop          ; empty line
    inc rcx
    xor rdx, rdx
    jmp .parse_loop

.parse_done:
    test rdx, rdx
    jz .set_dim
    inc rcx
    cmp rdx, rbx
    jbe .set_dim
    mov rbx, rdx
.set_dim:
    mov [grid_w], rbx
    mov [grid_h], rcx
    
    ; Part 1: count rolls '@' with < 4 neighbors
    xor r13, r13            ; total count
    xor r12, r12            ; r
.p1_row:
    cmp r12, [grid_h]
    jae .p1_done
    xor rbx, rbx            ; c
.p1_col:
    cmp rbx, [grid_w]
    jae .p1_next_row
    
    ; Check grid1[r][c]
    mov rdx, r12
    shl rdx, 8
    add rdx, rbx
    movzx rax, byte [grid1 + rdx]
    cmp al, '@'
    jne .p1_next_col
    
    mov rcx, r12
    mov rdx, rbx
    call count_neighbors
    cmp rax, 4
    jae .p1_next_col
    inc r13
    
.p1_next_col:
    inc rbx
    jmp .p1_col
.p1_next_row:
    inc r12
    jmp .p1_row

.p1_done:
    ; Print Part 1
    call print_newline
    lea rcx, [msg_part1_header]
    call print_string
    lea rcx, [msg_part1]
    call print_string
    mov rcx, r13
    call print_number
    call print_newline

    ; Part 2: iterative removal
    ; Copy grid1 to grid2
    lea rsi, [grid1]
    lea rdi, [grid2]
    mov rcx, 65536
    rep movsb
    
    xor r13, r13            ; removed count
    lea r12, [queue]        ; q_head
    mov r14, r12            ; q_tail
    
    ; Initialize queue with all initially accessible rolls
    xor rcx, rcx            ; r
.init_q_r:
    cmp rcx, [grid_h]
    jae .process_q
    xor rdx, rdx            ; c
.init_q_c:
    cmp rdx, [grid_w]
    jae .init_q_next_r
    
    mov r8, rcx
    shl r8, 8
    add r8, rdx
    cmp byte [grid2 + r8], '@'
    jne .init_q_next_c
    
    push rcx
    push rdx
    call count_neighbors_g2
    pop rdx
    pop rcx
    cmp rax, 4
    jae .init_q_next_c
    
    ; Add to queue (pack r, c into 32-bit: r << 8 | c)
    mov rax, rcx
    shl rax, 8
    or rax, rdx
    mov [r14], eax
    add r14, 4
    
    ; Mark as pending removal
    mov r8, rcx
    shl r8, 8
    add r8, rdx
    mov byte [grid2 + r8], 'X' 

.init_q_next_c:
    inc rdx
    jmp .init_q_c
.init_q_next_r:
    inc rcx
    jmp .init_q_r

.process_q:
    cmp r12, r14
    jae .p2_done
    
    ; Pop (r, c)
    mov eax, [r12]
    add r12, 4
    
    mov rdx, rax
    and rdx, 0xFF           ; c
    shr rax, 8              ; r
    mov rcx, rax            ; r
    
    ; Remove it
    mov r8, rcx
    shl r8, 8
    add r8, rdx
    mov byte [grid2 + r8], '.'
    inc r13
    
    ; Check neighbors
    xor r15, r15            ; neighbor index
.p2_neigh_loop:
    cmp r15, 8
    jae .process_q
    
    lea rax, [dr]
    movsxd rax, dword [rax + r15*4]
    add rax, rcx            ; nr
    
    test rax, rax
    js .p2_next_neigh
    cmp rax, [grid_h]
    jae .p2_next_neigh
    
    lea r8, [dc]
    movsxd r8, dword [r8 + r15*4]
    add r8, rdx            ; nc
    
    test r8, r8
    js .p2_next_neigh
    cmp r8, [grid_w]
    jae .p2_next_neigh
    
    ; Check if neighbor is '@' and now has < 4 neighbors
    mov r9, rax
    shl r9, 8
    add r9, r8
    cmp byte [grid2 + r9], '@'
    jne .p2_next_neigh
    
    push rcx
    push rdx
    mov rcx, rax
    mov rdx, r8
    call count_neighbors_g2
    mov r9, rax
    pop rdx
    pop rcx
    
    cmp r9, 4
    jae .p2_next_neigh
    
    ; Add neighbor to queue
    mov r9, [rsp+8] ; wait, use rax/r8 from before we lost them
    ; Let's re-calculate nr, nc
    lea r9, [dr]
    movsxd r9, dword [r9 + r15*4]
    add r9, rcx             ; nr
    lea r10, [dc]
    movsxd r10, dword [r10 + r15*4]
    add r10, rdx            ; nc
    
    mov rax, r9
    shl rax, 8
    or rax, r10
    mov [r14], eax
    add r14, 4
    
    ; Mark as pending removal
    mov r11, r9
    shl r11, 8
    add r11, r10
    mov byte [grid2 + r11], 'X'

.p2_next_neigh:
    inc r15
    jmp .p2_neigh_loop

.p2_done:
    lea rcx, [msg_part2_header]
    call print_string
    lea rcx, [msg_part2]
    call print_string
    mov rcx, r13
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

; -----------------------------------------------------------------------------
; count_neighbors
; Input: RCX = r, RDX = c
; Output: RAX = count
; -----------------------------------------------------------------------------
count_neighbors:
    xor rax, rax            ; count
    xor r8, r8              ; i
.loop:
    cmp r8, 8
    jae .done
    
    lea r9, [dr]
    movsxd r9, dword [r9 + r8*4]
    add r9, rcx             ; nr
    
    test r9, r9
    js .next
    cmp r9, [grid_h]
    jae .next
    
    lea r10, [dc]
    movsxd r10, dword [r10 + r8*4]
    add r10, rdx            ; nc
    
    test r10, r10
    js .next
    cmp r10, [grid_w]
    jae .next
    
    ; index = nr * 256 + nc
    shl r9, 8
    add r9, r10
    cmp byte [grid1 + r9], '@'
    jne .next
    inc rax
.next:
    inc r8
    jmp .loop
.done:
    ret

; -----------------------------------------------------------------------------
; count_neighbors_g2
; Input: RCX = r, RDX = c
; Output: RAX = count (in grid2, counts '@' and 'X')
; -----------------------------------------------------------------------------
count_neighbors_g2:
    xor rax, rax
    xor r8, r8
.loop:
    cmp r8, 8
    jae .done
    
    lea r9, [dr]
    movsxd r9, dword [r9 + r8*4]
    add r9, rcx
    
    test r9, r9
    js .next
    cmp r9, [grid_h]
    jae .next
    
    lea r10, [dc]
    movsxd r10, dword [r10 + r8*4]
    add r10, rdx
    
    test r10, r10
    js .next
    cmp r10, [grid_w]
    jae .next
    
    shl r9, 8
    add r9, r10
    movzx r11, byte [grid2 + r9]
    cmp r11b, '@'
    je .found
    cmp r11b, 'X'
    jne .next
.found:
    inc rax
.next:
    inc r8
    jmp .loop
.done:
    ret
