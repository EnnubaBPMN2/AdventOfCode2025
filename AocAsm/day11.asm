; day11.asm - Advent of Code 2025 Day 11
; Graph path counting with memoization
default rel
bits 64

section .data
    real_file db '../inputs/day11.txt', 0
    msg_part1_header db '=== Part 1 ===', 13, 10, 0
    msg_part1 db 'Result: ', 0
    msg_part2_header db '=== Part 2 ===', 13, 10, 0
    msg_part2 db 'Result: ', 0
    msg_part2_auto db 13, 10, 'Part 2 automatically completed! Both stars earned!', 13, 10, 0

    ; Target node names
    name_you db 'you', 0
    name_out db 'out', 0
    name_svr db 'svr', 0
    name_dac db 'dac', 0
    name_fft db 'fft', 0

section .bss
    buffer resb 1048576         ; 1MB input buffer

    ; Graph storage: up to 1000 nodes
    ; Each node: 32-byte name + 100 edges (dwords) + edge_count (dword)
    ; Simplified: store names separately, edges in adjacency list
    node_names resb 32000       ; 1000 nodes * 32 bytes each
    node_edges resd 100000      ; 1000 nodes * 100 edges each
    node_edge_counts resd 1000  ; edge count per node
    node_count resq 1

    ; Memoization for Part 1
    memo1 resq 1000
    memo1_valid resb 1000

    ; Memoization for Part 2 (node * 4 states)
    memo2 resq 4000             ; 1000 nodes * 4 mask states
    memo2_valid resb 4000

section .text
    global day11_run
    extern read_file, print_string, print_number, print_newline
    extern GetTickCount64, print_elapsed

day11_run:
    push rbp
    mov rbp, rsp
    push rbx
    push rsi
    push rdi
    push r12
    push r13
    push r14
    push r15
    sub rsp, 96

    ; Start timing
    call GetTickCount64
    mov [rbp-88], rax

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

    ; Initialize
    mov qword [node_count], 0

    ; Clear memoization
    lea rdi, [memo1_valid]
    xor eax, eax
    mov ecx, 1000
    rep stosb

    lea rdi, [memo2_valid]
    xor eax, eax
    mov ecx, 4000
    rep stosb

    ; Parse graph
    lea rsi, [buffer]
    lea r15, [buffer + r14]

.parse_loop:
    cmp rsi, r15
    jae .parse_done

    ; Skip whitespace/newlines
    movzx eax, byte [rsi]
    cmp al, ' '
    je .skip_ws
    cmp al, 9
    je .skip_ws
    cmp al, 10
    je .skip_ws
    cmp al, 13
    je .skip_ws

    ; Check if this is a valid node name start
    cmp al, 'a'
    jb .skip_ws
    cmp al, 'z'
    ja .skip_ws

    ; Extract source node name until ':'
    lea rdi, [rbp-64]       ; temp buffer for name
    xor ecx, ecx
.extract_src:
    cmp rsi, r15
    jae .parse_done
    movzx eax, byte [rsi]
    cmp al, ':'
    je .found_colon
    cmp al, ' '
    je .found_colon
    cmp al, 10
    je .skip_line
    cmp al, 13
    je .skip_line
    mov [rdi + rcx], al
    inc rcx
    inc rsi
    cmp rcx, 31
    jl .extract_src
    jmp .found_colon

.found_colon:
    mov byte [rdi + rcx], 0     ; null terminate

    ; Find or add source node
    lea rcx, [rbp-64]
    call find_or_add_node
    mov r12, rax                ; r12 = source node index

    ; Skip to after ':'
.find_colon:
    cmp rsi, r15
    jae .parse_done
    movzx eax, byte [rsi]
    inc rsi
    cmp al, ':'
    jne .find_colon

    ; Parse target nodes
.parse_targets:
    ; Skip whitespace
.skip_target_ws:
    cmp rsi, r15
    jae .parse_done
    movzx eax, byte [rsi]
    cmp al, ' '
    je .inc_skip_target
    cmp al, 9
    je .inc_skip_target
    cmp al, 10
    je .next_line
    cmp al, 13
    je .next_line
    jmp .extract_target
.inc_skip_target:
    inc rsi
    jmp .skip_target_ws

.extract_target:
    lea rdi, [rbp-64]
    xor ecx, ecx
.extract_target_loop:
    cmp rsi, r15
    jae .add_target
    movzx eax, byte [rsi]
    cmp al, ' '
    je .add_target
    cmp al, 9
    je .add_target
    cmp al, 10
    je .add_target
    cmp al, 13
    je .add_target
    mov [rdi + rcx], al
    inc rcx
    inc rsi
    cmp rcx, 31
    jl .extract_target_loop

.add_target:
    test ecx, ecx
    jz .skip_target_ws
    mov byte [rdi + rcx], 0

    ; Find or add target node
    push r12
    lea rcx, [rbp-64]
    call find_or_add_node
    mov r13, rax                ; r13 = target node index
    pop r12

    ; Add edge from r12 to r13
    mov eax, [node_edge_counts + r12*4]
    cmp eax, 100
    jae .skip_target_ws

    ; edges[src][count] = target
    imul rbx, r12, 100
    add ebx, eax
    mov [node_edges + rbx*4], r13d
    inc dword [node_edge_counts + r12*4]
    jmp .skip_target_ws

.next_line:
    inc rsi
    jmp .parse_loop

.skip_line:
    inc rsi
    jmp .parse_loop

.skip_ws:
    inc rsi
    jmp .parse_loop

.parse_done:
    ; Find special node indices
    lea rcx, [name_you]
    call find_node_index
    mov [rbp-72], rax           ; you_idx

    lea rcx, [name_out]
    call find_node_index
    mov [rbp-80], rax           ; out_idx

    ; Part 1: Count paths from "you" to "out"
    mov rcx, [rbp-72]           ; start = you
    mov rdx, [rbp-80]           ; end = out
    call count_paths_dag
    mov r12, rax                ; r12 = Part 1 result

    ; End timing for Part 1
    call GetTickCount64
    mov [rbp-96], rax

    call print_newline
    lea rcx, [msg_part1_header]
    call print_string
    lea rcx, [msg_part1]
    call print_string
    mov rcx, r12
    call print_number
    mov rcx, [rbp-88]
    mov rdx, [rbp-96]
    call print_elapsed
    call print_newline

    ; Part 2: Count paths from "svr" to "out" through "dac" and "fft"
    lea rcx, [name_svr]
    call find_node_index
    mov [rbp-72], rax           ; svr_idx

    lea rcx, [name_dac]
    call find_node_index
    mov r13, rax                ; dac_idx

    lea rcx, [name_fft]
    call find_node_index
    mov r14, rax                ; fft_idx

    ; Clear memo2
    lea rdi, [memo2_valid]
    xor eax, eax
    mov ecx, 4000
    rep stosb

    mov rcx, [rbp-72]           ; start = svr
    mov rdx, [rbp-80]           ; end = out
    mov r8, r13                 ; dac_idx
    mov r9, r14                 ; fft_idx
    xor eax, eax                ; mask = 0
    mov [rsp+32], rax
    call count_paths_required
    mov r12, rax                ; r12 = Part 2 result

    ; End timing for Part 2
    call GetTickCount64
    mov [rbp-96], rax

    call print_newline
    lea rcx, [msg_part2_header]
    call print_string
    lea rcx, [msg_part2]
    call print_string
    mov rcx, r12
    call print_number
    mov rcx, [rbp-88]
    mov rdx, [rbp-96]
    call print_elapsed
    call print_newline

.done:
    add rsp, 96
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
; find_or_add_node
; Input: RCX = pointer to node name (null-terminated)
; Output: RAX = node index
; -----------------------------------------------------------------------------
find_or_add_node:
    push rbx
    push rsi
    push rdi
    push r12

    mov r12, rcx                ; save name pointer

    ; Search existing nodes
    xor rbx, rbx
.search_loop:
    cmp rbx, [node_count]
    jae .add_new

    ; Compare names
    mov rsi, r12
    imul rdi, rbx, 32
    lea rdi, [node_names + rdi]
.compare:
    movzx eax, byte [rsi]
    movzx ecx, byte [rdi]
    cmp al, cl
    jne .next_node
    test al, al
    jz .found
    inc rsi
    inc rdi
    jmp .compare

.next_node:
    inc rbx
    jmp .search_loop

.found:
    mov rax, rbx
    jmp .done

.add_new:
    mov rax, [node_count]
    cmp rax, 1000
    jae .fail

    ; Copy name
    mov rsi, r12
    imul rdi, rax, 32
    lea rdi, [node_names + rdi]
.copy_name:
    movzx ecx, byte [rsi]
    mov [rdi], cl
    test cl, cl
    jz .copy_done
    inc rsi
    inc rdi
    jmp .copy_name

.copy_done:
    mov dword [node_edge_counts + rax*4], 0
    inc qword [node_count]
    jmp .done

.fail:
    mov rax, -1

.done:
    pop r12
    pop rdi
    pop rsi
    pop rbx
    ret

; -----------------------------------------------------------------------------
; find_node_index
; Input: RCX = pointer to node name
; Output: RAX = node index, or -1 if not found
; -----------------------------------------------------------------------------
find_node_index:
    push rbx
    push rsi
    push rdi
    push r12

    mov r12, rcx
    xor rbx, rbx
.search:
    cmp rbx, [node_count]
    jae .not_found

    mov rsi, r12
    imul rdi, rbx, 32
    lea rdi, [node_names + rdi]
.cmp_loop:
    movzx eax, byte [rsi]
    movzx ecx, byte [rdi]
    cmp al, cl
    jne .next
    test al, al
    jz .found
    inc rsi
    inc rdi
    jmp .cmp_loop

.next:
    inc rbx
    jmp .search

.found:
    mov rax, rbx
    jmp .done

.not_found:
    mov rax, -1

.done:
    pop r12
    pop rdi
    pop rsi
    pop rbx
    ret

; -----------------------------------------------------------------------------
; count_paths_dag
; Input: RCX = current node, RDX = end node
; Output: RAX = path count
; -----------------------------------------------------------------------------
count_paths_dag:
    push rbp
    mov rbp, rsp
    push rbx
    push rsi
    push rdi
    push r12
    push r13
    push r14
    sub rsp, 32

    mov r12, rcx                ; current
    mov r13, rdx                ; end

    ; Base case: reached end
    cmp r12, r13
    jne .not_end
    mov rax, 1
    jmp .return

.not_end:
    ; Check memo
    cmp byte [memo1_valid + r12], 0
    je .compute
    mov rax, [memo1 + r12*8]
    jmp .return

.compute:
    xor r14, r14                ; count = 0

    ; Iterate over edges
    mov ebx, [node_edge_counts + r12*4]
    test ebx, ebx
    jz .store_result

    xor esi, esi                ; edge index
.edge_loop:
    cmp esi, ebx
    jae .store_result

    imul edi, r12d, 100
    add edi, esi
    mov ecx, [node_edges + rdi*4]
    mov rdx, r13

    push rbx
    push rsi
    push r14
    call count_paths_dag
    pop r14
    pop rsi
    pop rbx

    add r14, rax
    inc esi
    jmp .edge_loop

.store_result:
    mov [memo1 + r12*8], r14
    mov byte [memo1_valid + r12], 1
    mov rax, r14

.return:
    add rsp, 32
    pop r14
    pop r13
    pop r12
    pop rdi
    pop rsi
    pop rbx
    pop rbp
    ret

; -----------------------------------------------------------------------------
; count_paths_required
; Input: RCX = current, RDX = end, R8 = dac_idx, R9 = fft_idx, [rsp+32] = mask
; Output: RAX = path count
; Uses stack frame for all local variables to avoid register corruption issues
; -----------------------------------------------------------------------------
count_paths_required:
    push rbp
    mov rbp, rsp
    push rbx
    push rsi
    push rdi
    push r12
    push r13
    push r14
    push r15
    sub rsp, 96                 ; More stack space for safety

    ; Save all parameters to stack immediately
    mov [rbp-48], rcx           ; current
    mov [rbp-56], rdx           ; end
    mov [rbp-64], r8            ; dac_idx
    mov [rbp-72], r9            ; fft_idx
    mov rax, [rbp+48]           ; mask from 5th param
    mov [rbp-80], rax           ; original mask

    ; Update mask based on current node
    mov rbx, rax                ; new_mask = mask
    cmp rcx, r8                 ; current == dac_idx?
    jne .not_dac
    or rbx, 1
.not_dac:
    cmp rcx, r9                 ; current == fft_idx?
    jne .not_fft
    or rbx, 2
.not_fft:
    mov [rbp-88], rbx           ; save new_mask

    ; Base case: reached end?
    mov rax, [rbp-48]           ; current
    cmp rax, [rbp-56]           ; compare to end
    jne .not_end

    ; At end node - check if required nodes were visited
    mov rax, [rbp-64]           ; dac_idx
    cmp rax, -1
    je .check_fft
    test rbx, 1                 ; dac visited?
    jz .return_zero
.check_fft:
    mov rax, [rbp-72]           ; fft_idx
    cmp rax, -1
    je .return_one
    test rbx, 2                 ; fft visited?
    jz .return_zero
.return_one:
    mov rax, 1
    jmp .return_direct
.return_zero:
    xor eax, eax
    jmp .return_direct

.not_end:
    ; Check memo (index = current * 4 + original_mask)
    mov rax, [rbp-48]           ; current
    shl rax, 2                  ; current * 4
    add rax, [rbp-80]           ; + original_mask
    mov [rbp-96], rax           ; save memo index

    cmp byte [memo2_valid + rax], 0
    je .compute
    mov rax, [memo2 + rax*8]
    jmp .return_direct

.compute:
    ; Initialize count to 0
    mov qword [rbp-40], 0       ; count = 0
    mov qword [rbp-32], 0       ; edge_idx = 0

    ; Get edge count for current node
    mov rax, [rbp-48]           ; current
    mov eax, [node_edge_counts + rax*4]
    mov [rbp-24], rax           ; edge_count

.edge_loop:
    mov rax, [rbp-32]           ; edge_idx
    cmp rax, [rbp-24]           ; edge_count
    jae .store_result

    ; Get target node: node_edges[current * 100 + edge_idx]
    mov rcx, [rbp-48]           ; current
    imul rcx, 100
    add rcx, [rbp-32]           ; + edge_idx
    mov ecx, [node_edges + rcx*4]   ; target node

    ; Recursive call with: target, end, dac, fft, new_mask
    mov rdx, [rbp-56]           ; end
    mov r8, [rbp-64]            ; dac_idx
    mov r9, [rbp-72]            ; fft_idx
    mov rax, [rbp-88]           ; new_mask
    mov [rsp+32], rax
    call count_paths_required

    ; Add result to count
    add [rbp-40], rax

    ; Increment edge index
    inc qword [rbp-32]
    jmp .edge_loop

.store_result:
    ; Store in memo and return
    mov rcx, [rbp-96]           ; memo index
    mov rax, [rbp-40]           ; count
    mov [memo2 + rcx*8], rax
    mov byte [memo2_valid + rcx], 1
    ; rax already has the count to return

.return_direct:
    ; rax has the return value
    add rsp, 96
    pop r15
    pop r14
    pop r13
    pop r12
    pop rdi
    pop rsi
    pop rbx
    pop rbp
    ret
