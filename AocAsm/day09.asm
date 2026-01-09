; day09.asm - Advent of Code 2025 Day 09
default rel
bits 64

section .data
    real_file db '../inputs/day09.txt', 0
    msg_part1_header db '=== Part 1 ===', 13, 10, 0
    msg_part1 db 'Result: ', 0
    msg_part2_header db '=== Part 2 ===', 13, 10, 0
    msg_part2 db 'Result: ', 0

section .bss
    buffer resb 1048576
    ; Max 1000 points, each x, y is qword
    vx resq 1000
    vy resq 1000
    p_count resq 1

section .text
    global day09_run
    extern read_file, print_string, print_number, print_newline, atoi64

day09_run:
    push rbp
    mov rbp, rsp
    push rbx
    push rsi
    push rdi
    push r12
    push r13
    push r14
    push r15
    sub rsp, 80             ; Local variables

    ; 1. Read file
    lea rcx, [real_file]
    lea rdx, [buffer]
    mov r8, 1048575
    call read_file
    cmp rax, -1
    je .done
    test rax, rax
    jz .done

    mov r14, rax
    lea r15, [buffer + r14]
    
    ; 2. Parse coordinates
    lea rsi, [buffer]
    xor r13, r13            ; point_idx
.parse_loop:
    cmp rsi, r15
    jae .parsed
    
    mov rcx, rsi
    call atoi64
    mov [vx + r13*8], rax
    add rsi, rdx
    call skip_to_digit
    
    mov rcx, rsi
    call atoi64
    mov [vy + r13*8], rax
    add rsi, rdx
    call skip_to_digit
    
    inc r13
    cmp r13, 1000
    jl .parse_loop
.parsed:
    mov [p_count], r13

    ; 3. Part 1: All pairs
    xor r12, r12            ; i
    xor r14, r14            ; max_area
.p1_i:
    cmp r12, [p_count]
    jae .p1_done
    mov r13, r12
    inc r13                 ; j = i + 1
.p1_j:
    cmp r13, [p_count]
    jae .p1_i_next
    
    ; delta X = abs(x[i] - x[j])
    mov rax, [vx + r12*8]
    sub rax, [vx + r13*8]
    jns .dx_pos
    neg rax
.dx_pos:
    inc rax                 ; dx + 1
    
    mov rbx, [vy + r12*8]
    sub rbx, [vy + r13*8]
    jns .dy_pos
    neg rbx
.dy_pos:
    inc rbx                 ; dy + 1
    
    mul rbx
    cmp rax, r14
    jbe .p1_next_j
    mov r14, rax
.p1_next_j:
    inc r13
    jmp .p1_j
.p1_i_next:
    inc r12
    jmp .p1_i

.p1_done:
    push r14
    call print_newline
    lea rcx, [msg_part1_header]
    call print_string
    lea rcx, [msg_part1]
    call print_string
    pop rcx
    call print_number
    call print_newline

    ; 4. Part 2: Containment check
    xor r12, r12            ; i
    xor r14, r14            ; max_area_p2
.p2_i:
    cmp r12, [p_count]
    jae .p2_done
    mov r13, r12
    inc r13
.p2_j:
    cmp r13, [p_count]
    jae .p2_i_next
    
    ; Define rect: x1, x2, y1, y2
    mov rax, [vx + r12*8]
    mov rbx, [vx + r13*8]
    cmp rax, rbx
    jbe .x_ok
    xchg rax, rbx
.x_ok:
    mov [rbp-8], rax        ; rx1
    mov [rbp-16], rbx       ; rx2
    
    mov rax, [vy + r12*8]
    mov rbx, [vy + r13*8]
    cmp rax, rbx
    jbe .y_ok
    xchg rax, rbx
.y_ok:
    mov [rbp-24], rax       ; ry1
    mov [rbp-32], rbx       ; ry2
    
    ; Area calculation
    mov rax, [rbp-16]
    sub rax, [rbp-8]
    inc rax
    mov rbx, [rbp-32]
    sub rbx, [rbp-24]
    inc rbx
    mul rbx                 ; Area in rax
    cmp rax, r14
    jbe .p2_next_j          ; Optimistically skip if area small
    mov [rbp-40], rax       ; Current area
    
    ; --- Check Containment ---
    ; a) No edge intersects strictly interior
    xor rdi, rdi            ; edge_idx
.edge_loop:
    cmp rdi, [p_count]
    jae .edge_ok
    
    mov rbx, rdi
    inc rbx
    cmp rbx, [p_count]
    jne .not_last
    xor rbx, rbx
.not_last:
    
    ; Edge k: (vx[rdi], vy[rdi]) to (vx[rbx], vy[rbx])
    mov r8, [vx + rdi*8]
    mov r9, [vy + rdi*8]
    mov r10, [vx + rbx*8]
    mov r11, [vy + rbx*8]
    
    ; If horizontal: y = const
    cmp r9, r11
    jne .is_vertical
    
    ; Horizontal edge at y=r9
    ; Intersects if ry1 < r9 < ry2 AND [x_min, x_max] overlaps (rx1, rx2)
    cmp r9, [rbp-24]
    jbe .next_edge
    cmp r9, [rbp-32]
    jae .next_edge
    
    ; Overlap check: max(r8, r10) > rx1 AND min(r8, r10) < rx2
    mov rax, r8
    cmp r10, rax
    cmovg rax, r10          ; rax = max_x
    cmp rax, [rbp-8]
    jbe .next_edge
    
    mov rax, r8
    cmp r10, rax
    cmovl rax, r10          ; rax = min_x
    cmp rax, [rbp-16]
    jae .next_edge
    
    jmp .fail_rect           ; Found intersection!

.is_vertical:
    ; Vertical edge at x=r8
    ; Intersects if rx1 < r8 < rx2 AND [y_min, y_max] overlaps (ry1, ry2)
    cmp r8, [rbp-8]
    jbe .next_edge
    cmp r8, [rbp-16]
    jae .next_edge
    
    mov rax, r9
    cmp r11, rax
    cmovg rax, r11          ; rax = max_y
    cmp rax, [rbp-24]
    jbe .next_edge
    
    mov rax, r9
    cmp r11, rax
    cmovl rax, r11          ; rax = min_y
    cmp rax, [rbp-32]
    jae .next_edge
    
    jmp .fail_rect

.next_edge:
    inc rdi
    jmp .edge_loop

.edge_ok:
    ; b) Midpoint is inside
    ; x_mid = (rx1 + rx2) / 2, y_mid = (ry1 + ry2) / 2
    ; Ray casting from (rx1+rx2, ry1+ry2) with coords doubled
    mov rbx, [rbp-8]
    add rbx, [rbp-16]       ; rbx = 2*x_mid
    mov rcx, [rbp-24]
    add rcx, [rbp-32]       ; rcx = 2*y_mid
    
    xor rdi, rdi            ; intersections
    xor rsi, rsi            ; edge_idx
.mid_ray_loop:
    cmp rsi, [p_count]
    jae .mid_check
    
    mov rax, rsi
    inc rax
    cmp rax, [p_count]
    jne .not_last_mid
    xor rax, rax
.not_last_mid:
    
    ; Edge k: (vx[rsi], vy[rsi]) to (vx[rax], vy[rax])
    ; Only vertical edges
    mov r8, [vx + rsi*8]
    mov r9, [vx + rax*8]
    cmp r8, r9
    jne .next_mid_edge      ; Skip horizontal
    
    ; Double r8 for comparison
    mov r10, r8
    shl r10, 1
    cmp r10, rbx
    jle .next_mid_edge      ; Ray goes right
    
    ; Y check: min(vy[rsi], vy[rax]) < y_mid < max(vy[rsi], vy[rax])
    mov r10, [vy + rsi*8]
    mov r11, [vy + rax*8]
    shl r10, 1
    shl r11, 1
    
    mov rax, r10
    cmp r11, rax
    cmovl rax, r11          ; rax = min_y*2
    cmp rax, rcx
    jae .next_mid_edge
    
    mov rax, r10
    cmp r11, rax
    cmovg rax, r11          ; rax = max_y*2
    cmp rax, rcx
    jbe .next_mid_edge
    
    inc rdi                 ; Intersection!

.next_mid_edge:
    inc rsi
    jmp .mid_ray_loop

.mid_check:
    test rdi, 1
    jz .fail_rect           ; Odd = inside
    
    ; Success!
    mov rax, [rbp-40]
    mov r14, rax

.fail_rect:
.p2_next_j:
    inc r13
    jmp .p2_j
.p2_i_next:
    inc r12
    jmp .p2_i

.p2_done:
    lea rcx, [msg_part2_header]
    call print_string
    lea rcx, [msg_part2]
    call print_string
    mov rcx, r14
    call print_number
    call print_newline

.done:
    add rsp, 80
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
