; day05.asm - Advent of Code 2025 Day 05
default rel
bits 64

section .data
    real_file db '../inputs/day05.txt', 0
    msg_part1_header db '=== Part 1 ===', 13, 10, 0
    msg_part1 db 'Result: ', 0
    msg_part2_header db '=== Part 2 ===', 13, 10, 0
    msg_part2 db 'Result: ', 0
    msg_debug_read db '[DEBUG] Read bytes: ', 0

section .bss
    buffer resb 1048576     ; Input file buffer
    ; store up to 1000 ranges: {start: dq, end: dq} = 16 bytes each
    ranges resq 2000
    range_count resq 1
    ; store up to 2000 individual IDs
    individual_ids resq 2000
    id_count resq 1

section .text
    global day05_run
    extern read_file, print_string, print_number, print_newline, atoi64

day05_run:
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

    mov r14, rax            ; r14 = bytes read
    lea r15, [buffer + r14]
    
    lea rsi, [buffer]
    xor r12, r12            ; range_count
    
    ; Phase 1: Parse ranges until blank line
.parse_ranges:
    cmp rsi, r15
    jae .parsed
    
    ; Check for blank line (double newline)
    mov al, [rsi]
    cmp al, 10
    je .blank_found
    cmp al, 13
    jne .not_blank
    cmp byte [rsi+1], 10
    je .blank_found
    
.not_blank:
    ; Parse range: START-END
    mov rcx, rsi
    call atoi64
    mov rbx, rax            ; range start
    add rsi, rdx
    
    cmp byte [rsi], '-'
    jne .skip_line          ; safety
    inc rsi
    
    mov rcx, rsi
    call atoi64
    mov rdi, rax            ; range end
    add rsi, rdx
    
    ; Store range
    mov rax, r12
    shl rax, 4              ; index * 16
    mov [ranges + rax], rbx
    mov [ranges + rax + 8], rdi
    inc r12
    
.skip_line:
    ; skip to next line
.sl_loop:
    cmp rsi, r15
    jae .parsed
    lodsb
    cmp al, 10
    jne .sl_loop
    jmp .parse_ranges

.blank_found:
    ; skip \r\n\r\n or \n\n
    inc rsi
    cmp rsi, r15
    jae .parsed
    mov al, [rsi]
    cmp al, 10
    je .bf_skip
    cmp al, 13
    jne .parsed
    inc rsi
    cmp byte [rsi], 10
    jne .parsed
.bf_skip:
    inc rsi

    ; Phase 2: Parse individual IDs
    xor r13, r13            ; id_count
.parse_ids:
    cmp rsi, r15
    jae .parsed
    
    movzx eax, byte [rsi]
    cmp al, '0'
    jb .skip_id_char
    cmp al, '9'
    ja .skip_id_char
    
    mov rcx, rsi
    call atoi64
    mov [individual_ids + r13*8], rax
    inc r13
    add rsi, rdx
    jmp .parse_ids

.skip_id_char:
    inc rsi
    jmp .parse_ids

.parsed:
    mov [range_count], r12
    mov [id_count], r13
    
    ; Part 1: count how many IDs are in any range
    xor r14, r14            ; count
    xor rbx, rbx            ; id index
.p1_loop:
    cmp rbx, [id_count]
    jae .p1_done
    
    mov rdx, [individual_ids + rbx*8] ; current ID
    
    ; Check against all ranges
    xor rdi, rdi            ; range index
.p1_range_check:
    cmp rdi, [range_count]
    jae .p1_not_found
    
    mov rax, rdi
    shl rax, 4
    mov r8, [ranges + rax]     ; start
    mov r9, [ranges + rax + 8] ; end
    
    cmp rdx, r8
    jb .p1_next_range
    cmp rdx, r9
    ja .p1_next_range
    
    inc r14                 ; Found!
    jmp .p1_next_id

.p1_next_range:
    inc rdi
    jmp .p1_range_check

.p1_not_found:
.p1_next_id:
    inc rbx
    jmp .p1_loop

.p1_done:
    ; Print Part 1
    call print_newline
    lea rcx, [msg_part1_header]
    call print_string
    lea rcx, [msg_part1]
    call print_string
    mov rcx, r14
    call print_number
    call print_newline

    ; Part 2: Total unique IDs in union of ranges
    ; 1. Sort ranges by start value
    ; Simple Insertion Sort for ~172 entries
    mov r12, [range_count]
    test r12, r12
    jz .p2_done
    
    xor rbx, rbx            ; i = 0
.outer_sort:
    inc rbx
    cmp rbx, r12
    jae .sort_done
    
    mov rax, rbx
    shl rax, 4
    mov r8, [ranges + rax]     ; key_start
    mov r9, [ranges + rax + 8] ; key_end
    
    mov rdi, rbx            ; j = i
.inner_sort:
    test rdi, rdi
    jz .insert
    
    mov rax, rdi
    dec rax
    shl rax, 4
    mov rdx, [ranges + rax]    ; ranges[j-1].start
    
    cmp rdx, r8
    jbe .insert
    
    ; ranges[j] = ranges[j-1]
    mov r10, [ranges + rax + 8]
    mov rcx, rdi
    shl rcx, 4
    mov [ranges + rcx], rdx
    mov [ranges + rcx + 8], r10
    
    dec rdi
    jmp .inner_sort

.insert:
    mov rax, rdi
    shl rax, 4
    mov [ranges + rax], r8
    mov [ranges + rax + 8], r9
    jmp .outer_sort

.sort_done:
    ; 2. Merge ranges and sum
    xor r13, r13            ; total sum
    xor rax, rax            ; first range
    mov rbx, [ranges]       ; current_start
    mov rdi, [ranges + 8]   ; current_end
    
    mov r14, 1              ; range index = 1
.merge_loop:
    cmp r14, r12
    jae .last_merge
    
    mov rax, r14
    shl rax, 4
    mov r8, [ranges + rax]     ; next_start
    mov r9, [ranges + rax + 8] ; next_end
    
    cmp r8, rdi
    ja .gap
    
    ; Overlap or adjacent (3-5 and 6-10 ARE adjacent but 3-5 and 7-10 have a gap 6)
    ; wait, inclusive range means 3-5 and 6-10 cover 3,4,5,6,7,8,9,10.
    ; so if next_start <= current_end + 1, merge.
    mov r10, rdi
    inc r10
    cmp r8, r10
    ja .gap
    
    ; Merge: current_end = max(current_end, next_end)
    cmp r9, rdi
    jbe .no_end_update
    mov rdi, r9
.no_end_update:
    inc r14
    jmp .merge_loop

.gap:
    ; current range is finished
    mov rax, rdi
    sub rax, rbx
    inc rax
    add r13, rax
    
    mov rbx, r8
    mov rdi, r9
    inc r14
    jmp .merge_loop

.last_merge:
    mov rax, rdi
    sub rax, rbx
    inc rax
    add r13, rax

.p2_done:
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
