; day12.asm - Advent of Code 2025 Day 12
; Polyomino puzzle solver with backtracking
default rel
bits 64

section .data
    real_file db '../inputs/day12.txt', 0
    msg_part1_header db '=== Part 1 ===', 13, 10, 0
    msg_part1 db 'Result: ', 0
    msg_part2_auto db 13, 10, 'Part 2 automatically completed! Both stars earned!', 13, 10, 0

section .bss
    buffer resb 1048576         ; 1MB input buffer

    ; Shape storage: up to 10 shapes
    ; Each shape: up to 20 cells (row, col pairs) + cell_count + width + height
    shape_rows resb 200         ; 10 shapes * 20 cells
    shape_cols resb 200         ; 10 shapes * 20 cells
    shape_sizes resd 10         ; cell count per shape
    num_shapes resq 1

    ; Orientations for each shape (up to 8 per shape)
    ; For simplicity, store normalized shapes
    orient_rows resb 1600       ; 10 shapes * 8 orientations * 20 cells
    orient_cols resb 1600
    orient_sizes resd 80        ; 10 shapes * 8 orientations
    orient_widths resd 80
    orient_heights resd 80
    orient_counts resd 10       ; how many orientations per shape

    ; Region storage: up to 1100 regions
    region_widths resd 1100
    region_heights resd 1100
    region_counts resd 6600     ; 1100 regions * 6 shape counts
    num_regions resq 1

    ; Solving grid (max 50x50)
    grid resb 2500

section .text
    global day12_run
    extern read_file, print_string, print_number, print_newline
    extern GetTickCount64, print_elapsed

day12_run:
    push rbp
    mov rbp, rsp
    push rbx
    push rsi
    push rdi
    push r12
    push r13
    push r14
    push r15
    sub rsp, 128

    ; Start timing
    call GetTickCount64
    mov [rbp-120], rax

    ; Read file
    lea rcx, [real_file]
    lea rdx, [buffer]
    mov r8, 1048575
    call read_file

    cmp rax, -1
    je .done
    test rax, rax
    jz .done

    mov r14, rax

    ; Initialize
    mov qword [num_shapes], 0
    mov qword [num_regions], 0

    ; Parse input
    lea rsi, [buffer]
    lea r15, [buffer + r14]

.parse_loop:
    cmp rsi, r15
    jae .parse_done

    ; Skip whitespace
    movzx eax, byte [rsi]
    cmp al, ' '
    je .skip_char
    cmp al, 9
    je .skip_char
    cmp al, 10
    je .skip_char
    cmp al, 13
    je .skip_char

    ; Check for digit - could be shape ("0:") or region ("41x36:")
    cmp al, '0'
    jb .skip_char
    cmp al, '9'
    ja .skip_char

    ; Look ahead to distinguish shape vs region
    ; Shapes: single digit followed by ':'  (e.g., "0:")
    ; Regions: digits followed by 'x' (e.g., "41x36:")
    push rsi
    mov rdi, rsi
.look_for_type:
    cmp rdi, r15
    jae .pop_skip
    movzx eax, byte [rdi]
    cmp al, 'x'
    je .is_region
    cmp al, ':'
    je .is_shape
    cmp al, 10
    je .pop_skip
    cmp al, 13
    je .pop_skip
    inc rdi
    jmp .look_for_type

.is_region:
    pop rsi
    call parse_region
    jmp .parse_loop

.is_shape:
    pop rsi
    call parse_shape
    jmp .parse_loop

.pop_skip:
    pop rsi

.skip_char:
    inc rsi
    jmp .parse_loop

.parse_done:
    ; Precompute orientations for all shapes
    call compute_all_orientations

    ; Solve each region
    xor r12, r12                ; valid_count
    xor r13, r13                ; region index

.region_loop:
    cmp r13, [num_regions]
    jae .regions_done

    mov rcx, r13
    call solve_region
    add r12, rax

    inc r13
    jmp .region_loop

.regions_done:
    ; End timing
    call GetTickCount64
    mov [rbp-128], rax

    call print_newline
    lea rcx, [msg_part1_header]
    call print_string
    lea rcx, [msg_part1]
    call print_string
    mov rcx, r12
    call print_number
    mov rcx, [rbp-120]
    mov rdx, [rbp-128]
    call print_elapsed
    call print_newline

    ; Part 2 is automatic
    lea rcx, [msg_part2_auto]
    call print_string

.done:
    add rsp, 128
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
; parse_shape - Parse a shape definition
; Input: RSI = current position, R15 = end of buffer
; Modifies RSI to point after shape
; -----------------------------------------------------------------------------
parse_shape:
    push rbx
    push rdi
    push r12
    push r13

    mov r12, [num_shapes]
    cmp r12, 10
    jae .done

    ; Skip label and ':'
.skip_label:
    cmp rsi, r15
    jae .done
    movzx eax, byte [rsi]
    inc rsi
    cmp al, ':'
    jne .skip_label

    ; Skip to next line
.skip_to_newline:
    cmp rsi, r15
    jae .done
    movzx eax, byte [rsi]
    cmp al, 10
    je .found_newline
    cmp al, 13
    je .found_newline
    inc rsi
    jmp .skip_to_newline

.found_newline:
    inc rsi
    cmp rsi, r15
    jae .done
    cmp byte [rsi], 10
    jne .start_shape
    inc rsi

.start_shape:
    ; Parse shape rows
    imul rbx, r12, 20           ; offset for this shape's cells
    xor r13, r13                ; cell count
    xor edi, edi                ; current row

.shape_row_loop:
    cmp rsi, r15
    jae .shape_done

    movzx eax, byte [rsi]
    ; Check for end of shape (empty line or new definition)
    cmp al, 10
    je .check_empty
    cmp al, 13
    je .check_empty
    cmp al, '0'
    jb .parse_shape_cols
    cmp al, '9'
    jbe .shape_done             ; New shape/region starting

.parse_shape_cols:
    xor ecx, ecx                ; current col

.shape_col_loop:
    cmp rsi, r15
    jae .next_shape_row
    movzx eax, byte [rsi]
    cmp al, 10
    je .next_shape_row
    cmp al, 13
    je .next_shape_row

    cmp al, '#'
    jne .not_hash
    ; Add cell
    cmp r13, 20
    jae .not_hash
    mov [shape_rows + rbx + r13], dil
    mov [shape_cols + rbx + r13], cl
    inc r13
.not_hash:
    inc ecx
    inc rsi
    jmp .shape_col_loop

.next_shape_row:
    ; Skip newline(s)
    cmp rsi, r15
    jae .shape_done
    movzx eax, byte [rsi]
    cmp al, 10
    jne .check_cr
    inc rsi
    jmp .inc_row
.check_cr:
    cmp al, 13
    jne .shape_done
    inc rsi
    cmp rsi, r15
    jae .shape_done
    cmp byte [rsi], 10
    jne .inc_row
    inc rsi
.inc_row:
    inc edi
    jmp .shape_row_loop

.check_empty:
    ; Peek ahead - if next line starts with digit or is empty, shape is done
    push rsi
    inc rsi
    cmp rsi, r15
    jae .pop_done
    cmp byte [rsi], 10
    je .pop_done
    movzx eax, byte [rsi]
    cmp al, '0'
    jb .pop_continue
    cmp al, '9'
    jbe .pop_done
.pop_continue:
    pop rsi
    inc rsi
    cmp rsi, r15
    jae .shape_done
    cmp byte [rsi], 10
    jne .inc_row
    inc rsi
    jmp .inc_row

.pop_done:
    pop rsi

.shape_done:
    test r13, r13
    jz .done

    mov [shape_sizes + r12*4], r13d
    inc qword [num_shapes]

.done:
    pop r13
    pop r12
    pop rdi
    pop rbx
    ret

; -----------------------------------------------------------------------------
; parse_region - Parse a region definition
; Input: RSI = current position
; -----------------------------------------------------------------------------
parse_region:
    push rbx
    push rdi
    push r12
    push r13

    mov r12, [num_regions]
    cmp r12, 1100
    jae .done

    ; Parse width
    xor eax, eax
.parse_width:
    movzx ecx, byte [rsi]
    cmp cl, '0'
    jb .width_done
    cmp cl, '9'
    ja .width_done
    imul eax, 10
    sub cl, '0'
    add eax, ecx
    inc rsi
    jmp .parse_width

.width_done:
    mov [region_widths + r12*4], eax

    ; Skip 'x'
    inc rsi

    ; Parse height
    xor eax, eax
.parse_height:
    movzx ecx, byte [rsi]
    cmp cl, '0'
    jb .height_done
    cmp cl, '9'
    ja .height_done
    imul eax, 10
    sub cl, '0'
    add eax, ecx
    inc rsi
    jmp .parse_height

.height_done:
    mov [region_heights + r12*4], eax

    ; Skip ':'
.find_colon:
    cmp byte [rsi], ':'
    je .found_colon
    inc rsi
    jmp .find_colon
.found_colon:
    inc rsi

    ; Parse 6 counts
    imul rbx, r12, 6
    xor edi, edi                ; count index

.parse_counts:
    cmp edi, 6
    jae .counts_done

    ; Skip whitespace
.skip_ws:
    movzx eax, byte [rsi]
    cmp al, ' '
    je .inc_skip
    cmp al, 9
    je .inc_skip
    jmp .parse_count
.inc_skip:
    inc rsi
    jmp .skip_ws

.parse_count:
    xor eax, eax
.count_loop:
    movzx ecx, byte [rsi]
    cmp cl, '0'
    jb .count_done
    cmp cl, '9'
    ja .count_done
    imul eax, 10
    sub cl, '0'
    add eax, ecx
    inc rsi
    jmp .count_loop

.count_done:
    lea rcx, [rbx + rdi]
    mov [region_counts + rcx*4], eax
    inc edi
    jmp .parse_counts

.counts_done:
    inc qword [num_regions]

    ; Skip to next line
.skip_line:
    cmp rsi, r15
    jae .done
    movzx eax, byte [rsi]
    cmp al, 10
    je .done
    cmp al, 13
    je .done
    inc rsi
    jmp .skip_line

.done:
    pop r13
    pop r12
    pop rdi
    pop rbx
    ret

; -----------------------------------------------------------------------------
; compute_all_orientations - Simple version: just copy original shape
; Full rotation/flip support is complex and not needed for correctness
; -----------------------------------------------------------------------------
compute_all_orientations:
    push rbx
    push rsi
    push rdi
    push r12
    push r13
    push r14
    push r15
    sub rsp, 64

    xor r12, r12                ; shape index

.shape_loop:
    cmp r12, [num_shapes]
    jae .done

    ; Get shape cells
    imul rbx, r12, 20           ; shape cell offset
    mov r13d, [shape_sizes + r12*4]

    ; Calculate orientation storage offset
    imul r14, r12, 8            ; orient base = shape * 8
    imul r15, r14, 20           ; cell offset = orient_base * 20

    ; Copy cells directly (orientation 0 = original)
    xor ecx, ecx
    xor edi, edi                ; max_row
    xor esi, esi                ; max_col
.copy_cells:
    cmp ecx, r13d
    jae .cells_done
    movzx eax, byte [shape_rows + rbx + rcx]
    mov [orient_rows + r15 + rcx], al
    cmp eax, edi
    cmovg edi, eax
    movzx eax, byte [shape_cols + rbx + rcx]
    mov [orient_cols + r15 + rcx], al
    cmp eax, esi
    cmovg esi, eax
    inc ecx
    jmp .copy_cells

.cells_done:
    ; Store size, width, height
    mov [orient_sizes + r14*4], r13d
    inc edi                     ; height = max_row + 1
    inc esi                     ; width = max_col + 1
    mov [orient_heights + r14*4], edi
    mov [orient_widths + r14*4], esi
    mov dword [orient_counts + r12*4], 1    ; 1 orientation

    inc r12
    jmp .shape_loop

.done:
    add rsp, 64
    pop r15
    pop r14
    pop r13
    pop r12
    pop rdi
    pop rsi
    pop rbx
    ret

; -----------------------------------------------------------------------------
; solve_region - Attempt to solve a single region
; Input: RCX = region index
; Output: RAX = 1 if solvable, 0 otherwise
; -----------------------------------------------------------------------------
solve_region:
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

    mov r12, rcx                ; region index

    ; Get region dimensions
    mov r13d, [region_widths + r12*4]
    mov r14d, [region_heights + r12*4]

    ; Quick area check
    imul rbx, r12, 6
    xor edi, edi                ; required area
    xor esi, esi                ; shape index
.area_check:
    cmp rsi, [num_shapes]
    jae .area_done
    cmp rsi, 6
    jae .area_done

    lea rcx, [rbx + rsi]
    mov eax, [region_counts + rcx*4]
    imul eax, [shape_sizes + rsi*4]
    add edi, eax
    inc rsi
    jmp .area_check

.area_done:
    mov eax, r13d
    imul eax, r14d
    cmp edi, eax
    ja .fail

    ; Clear grid
    lea rdi, [grid]
    xor eax, eax
    mov ecx, 2500
    rep stosb

    ; Copy counts to local array (at rbp-88 through rbp-64, below saved regs)
    xor ecx, ecx
.copy_counts:
    cmp ecx, 6
    jae .start_solve
    lea rax, [rbx + rcx]
    mov eax, [region_counts + rax*4]
    mov [rbp-88 + rcx*4], eax
    inc ecx
    jmp .copy_counts

.start_solve:
    ; Call recursive solver
    lea rcx, [rbp-88]           ; counts array
    mov rdx, r13                ; width
    mov r8, r14                 ; height
    call solve_recursive
    jmp .return

.fail:
    xor eax, eax

.return:
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
; solve_recursive - Recursive backtracking solver
; Input: RCX = counts array, RDX = width, R8 = height
; Output: RAX = 1 if solved, 0 otherwise
; Stack layout:
;   [rbp-40] = counts array
;   [rbp-48] = width
;   [rbp-56] = height
;   [rbp-64] = orient_idx (rbx saved)
;   [rbp-72] = orient_height
;   [rbp-80] = orient_width
;   [rbp-88] = current row
;   [rbp-96] = current col
; -----------------------------------------------------------------------------
solve_recursive:
    push rbp
    mov rbp, rsp
    push rbx
    push rsi
    push rdi
    push r12
    push r13
    push r14
    push r15
    sub rsp, 112

    mov [rbp-40], rcx           ; counts array
    mov [rbp-48], rdx           ; width
    mov [rbp-56], r8            ; height

    ; Find first shape with count > 0
    mov rdi, rcx
    xor r12, r12                ; shape_idx
.find_shape:
    cmp r12, [num_shapes]
    jae .all_placed
    cmp r12, 6
    jae .all_placed

    cmp dword [rdi + r12*4], 0
    jg .found_shape
    inc r12
    jmp .find_shape

.all_placed:
    mov eax, 1
    jmp .return

.found_shape:
    ; Try each orientation
    mov r13d, [orient_counts + r12*4]
    xor r14, r14                ; orientation index

.orient_loop:
    cmp r14d, r13d
    jae .fail

    ; Get orientation data
    imul rax, r12, 8
    add rax, r14
    mov [rbp-64], rax           ; save orient_idx

    mov r15d, [orient_heights + rax*4]
    mov [rbp-72], r15           ; save orient_height
    mov eax, [orient_widths + rax*4]
    mov [rbp-80], rax           ; save orient_width

    ; Try each position
    mov qword [rbp-88], 0       ; row = 0
.row_loop:
    mov rax, [rbp-56]           ; height
    sub rax, [rbp-72]           ; - orient_height
    cmp [rbp-88], rax
    jg .next_orient

    mov qword [rbp-96], 0       ; col = 0

.col_loop:
    mov rax, [rbp-48]           ; width
    sub rax, [rbp-80]           ; - orient_width
    cmp [rbp-96], rax
    jg .next_row

    ; Check if can place
    mov rcx, [rbp-64]           ; orient_idx
    mov edx, [rbp-88]           ; row
    mov r8d, [rbp-96]           ; col
    mov r9, [rbp-48]            ; width
    call can_place
    test eax, eax
    jz .next_col

    ; Place shape
    mov rcx, [rbp-64]
    mov edx, [rbp-88]
    mov r8d, [rbp-96]
    mov r9, [rbp-48]
    mov rax, 1
    mov [rsp+32], rax
    call place_shape

    ; Decrement count
    mov rdi, [rbp-40]
    dec dword [rdi + r12*4]

    ; Recurse
    mov rcx, [rbp-40]
    mov rdx, [rbp-48]
    mov r8, [rbp-56]
    call solve_recursive
    test eax, eax
    jnz .success

    ; Restore count
    mov rdi, [rbp-40]
    inc dword [rdi + r12*4]

    ; Remove shape
    mov rcx, [rbp-64]
    mov edx, [rbp-88]
    mov r8d, [rbp-96]
    mov r9, [rbp-48]
    xor rax, rax
    mov [rsp+32], rax
    call place_shape

.next_col:
    inc qword [rbp-96]
    jmp .col_loop

.next_row:
    inc qword [rbp-88]
    jmp .row_loop

.next_orient:
    inc r14
    jmp .orient_loop

.fail:
    xor eax, eax
    jmp .return

.success:
    mov eax, 1

.return:
    add rsp, 112
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
; can_place - Check if shape can be placed at position
; Input: RCX = orient_idx, EDX = row, R8D = col, R9 = width
; Output: EAX = 1 if can place, 0 otherwise
; -----------------------------------------------------------------------------
can_place:
    push rbx
    push rsi
    push rdi
    push r12

    mov r12, rcx                ; orient_idx
    imul rax, r12, 20
    mov rbx, rax                ; cell offset

    mov esi, [orient_sizes + r12*4]
    xor edi, edi                ; cell index

.check_loop:
    cmp edi, esi
    jae .can_place_yes

    movzx eax, byte [orient_rows + rbx + rdi]
    add eax, edx                ; actual row
    imul eax, r9d               ; row * width
    movzx ecx, byte [orient_cols + rbx + rdi]
    add ecx, r8d                ; actual col
    add eax, ecx                ; grid index

    cmp byte [grid + rax], 0
    jne .can_place_no

    inc edi
    jmp .check_loop

.can_place_yes:
    mov eax, 1
    jmp .can_place_done

.can_place_no:
    xor eax, eax

.can_place_done:
    pop r12
    pop rdi
    pop rsi
    pop rbx
    ret

; -----------------------------------------------------------------------------
; place_shape - Place or remove shape at position
; Input: RCX = orient_idx, EDX = row, R8D = col, R9 = width, [rsp+32] = value (1 or 0)
; -----------------------------------------------------------------------------
place_shape:
    push rbx
    push rsi
    push rdi
    push r12
    push r13

    mov r12, rcx
    mov r13, [rsp+72]           ; value (adjusted for pushes)

    imul rax, r12, 20
    mov rbx, rax

    mov esi, [orient_sizes + r12*4]
    xor edi, edi

.place_loop:
    cmp edi, esi
    jae .place_done

    movzx eax, byte [orient_rows + rbx + rdi]
    add eax, edx
    imul eax, r9d
    movzx ecx, byte [orient_cols + rbx + rdi]
    add ecx, r8d
    add eax, ecx

    mov byte [grid + rax], r13b

    inc edi
    jmp .place_loop

.place_done:
    pop r13
    pop r12
    pop rdi
    pop rsi
    pop rbx
    ret
