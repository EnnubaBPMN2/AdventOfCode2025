; main.asm - Entry point and menu
default rel
bits 64

section .data
    msg_welcome    db '==================================================', 13, 10
                   db '   Advent of Code 2025 - Assembly Solutions', 13, 10
                   db '==================================================', 13, 10, 0
    msg_prompt     db 13, 10, 'Select a day (1-12) or 0 to exit: ', 0
    msg_invalid    db 'Invalid choice.', 13, 10, 0
    msg_exit       db 13, 10, 'Happy Coding!', 13, 10, 0
    fmt_day_header db 13, 10, '--- Day ', 0

section .bss
    choice_buf resb 16

section .text
    global main
    extern ExitProcess, init_print, print_string, print_number, print_newline, atoi64
    extern day01_run
    extern GetStdHandle, ReadConsoleA

    ; Constant
    STD_INPUT_HANDLE equ -10

main:
    push rbp
    mov rbp, rsp
    push rbx
    push rsi                ; Preserve RSI for arg parsing
    sub rsp, 48

    call init_print

    ; Get command line
    extern GetCommandLineA
    call GetCommandLineA
    ; RAX = pointer to command line string
    mov rsi, rax

    ; Skip program name (simplified: skip to first space)
.skip_name:
    movzx eax, byte [rsi]
    test al, al
    jz .no_args
    cmp al, ' '
    je .found_space
    inc rsi
    jmp .skip_name

.found_space:
    inc rsi                 ; skip space
    ; Skip additional spaces
.skip_spaces:
    cmp byte [rsi], ' '
    jne .parse_arg
    inc rsi
    jmp .skip_spaces

.parse_arg:
    mov rcx, rsi
    call atoi64
    test rax, rax
    jz .no_args
    
    ; If arg provided, run that day and exit
    push rax
    lea rcx, [fmt_day_header]
    call print_string
    pop rax
    push rax
    mov rcx, rax
    call print_number
    call print_newline
    pop rax

    cmp rax, 1
    je .run_day01_once
    cmp rax, 2
    je .run_day02_once
    cmp rax, 3
    je .run_day03_once
    cmp rax, 4
    je .run_day04_once
    cmp rax, 5
    je .run_day05_once
    cmp rax, 6
    je .run_day06_once
    cmp rax, 7
    je .run_day07_once
    cmp rax, 8
    je .run_day08_once
    cmp rax, 9
    je .run_day09_once
    cmp rax, 10
    je .run_day10_once
    cmp rax, 11
    je .run_day11_once
    cmp rax, 12
    je .run_day12_once
    jmp .exit

.run_day01_once:
    call day01_run
    jmp .exit

.run_day02_once:
    extern day02_run
    call day02_run
    jmp .exit

.run_day03_once:
    extern day03_run
    call day03_run
    jmp .exit

.run_day04_once:
    extern day04_run
    call day04_run
    jmp .exit

.run_day05_once:
    extern day05_run
    call day05_run
    jmp .exit

.run_day06_once:
    extern day06_run
    call day06_run
    jmp .exit

.run_day07_once:
    extern day07_run
    call day07_run
    jmp .exit

.run_day08_once:
    extern day08_run
    call day08_run
    jmp .exit

.run_day09_once:
    extern day09_run
    call day09_run
    jmp .exit

.run_day10_once:
    extern day10_run
    call day10_run
    jmp .exit

.run_day11_once:
    extern day11_run
    call day11_run
    jmp .exit

.run_day12_once:
    extern day12_run
    call day12_run
    jmp .exit

.no_args:
    lea rcx, [msg_welcome]
    call print_string

.menu_loop:
    lea rcx, [msg_prompt]
    call print_string

    ; Read choice
    mov rcx, STD_INPUT_HANDLE
    call GetStdHandle
    mov rbx, rax

    mov rcx, rbx
    lea rdx, [choice_buf]
    mov r8, 15
    lea r9, [rbp-16]
    mov qword [rsp+32], 0
    extern ReadFile
    call ReadFile

    lea rcx, [choice_buf]
    call atoi64
    ; RAX = day number

    cmp rax, 0
    je .exit
    cmp rax, 1
    je .run_day01
    cmp rax, 2
    je .run_day02
    cmp rax, 3
    je .run_day03
    cmp rax, 4
    je .run_day04
    cmp rax, 5
    je .run_day05
    cmp rax, 6
    je .run_day06
    cmp rax, 7
    je .run_day07
    cmp rax, 8
    je .run_day08
    cmp rax, 9
    je .run_day09
    cmp rax, 10
    je .run_day10
    cmp rax, 11
    je .run_day11
    cmp rax, 12
    je .run_day12

    ; Day not implemented yet
    lea rcx, [msg_invalid]
    call print_string
    jmp .menu_loop

.run_day01:
    lea rcx, [fmt_day_header]
    call print_string
    mov rcx, 1
    call print_number
    call print_newline
    
    call day01_run
    jmp .menu_loop

.run_day02:
    lea rcx, [fmt_day_header]
    call print_string
    mov rcx, 2
    call print_number
    call print_newline

    extern day02_run
    call day02_run
    jmp .menu_loop

.run_day03:
    lea rcx, [fmt_day_header]
    call print_string
    mov rcx, 3
    call print_number
    call print_newline

    extern day03_run
    call day03_run
    jmp .menu_loop

.run_day04:
    lea rcx, [fmt_day_header]
    call print_string
    mov rcx, 4
    call print_number
    call print_newline

    extern day04_run
    call day04_run
    jmp .menu_loop

.run_day05:
    lea rcx, [fmt_day_header]
    call print_string
    mov rcx, 5
    call print_number
    call print_newline

    extern day05_run
    call day05_run
    jmp .menu_loop

.run_day06:
    lea rcx, [fmt_day_header]
    call print_string
    mov rcx, 6
    call print_number
    call print_newline

    extern day06_run
    call day06_run
    jmp .menu_loop

.run_day07:
    lea rcx, [fmt_day_header]
    call print_string
    mov rcx, 7
    call print_number
    call print_newline

    extern day07_run
    call day07_run
    jmp .menu_loop

.run_day08:
    lea rcx, [fmt_day_header]
    call print_string
    mov rcx, 8
    call print_number
    call print_newline

    extern day08_run
    call day08_run
    jmp .menu_loop

.run_day09:
    lea rcx, [fmt_day_header]
    call print_string
    mov rcx, 9
    call print_number
    call print_newline

    extern day09_run
    call day09_run
    jmp .menu_loop

.run_day10:
    lea rcx, [fmt_day_header]
    call print_string
    mov rcx, 10
    call print_number
    call print_newline

    extern day10_run
    call day10_run
    jmp .menu_loop

.run_day11:
    lea rcx, [fmt_day_header]
    call print_string
    mov rcx, 11
    call print_number
    call print_newline

    extern day11_run
    call day11_run
    jmp .menu_loop

.run_day12:
    lea rcx, [fmt_day_header]
    call print_string
    mov rcx, 12
    call print_number
    call print_newline

    extern day12_run
    call day12_run
    jmp .menu_loop

.exit:
    lea rcx, [msg_exit]
    call print_string
    xor ecx, ecx
    call ExitProcess

    add rsp, 48
    pop rsi
    pop rbx
    pop rbp
    ret
