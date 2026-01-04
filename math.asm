section .data
    msg_fact db "Faktorial 5 = ", 0
    msg_fib  db "Fibonacci ke-10 = ", 0
    msg_pow  db "2 pangkat 8 = ", 0
    newline  db 10, 0

section .bss
    buffer resb 32

section .text
    global _start

; =========================
; ENTRY POINT
; =========================
_start:

    ; === Faktorial ===
    mov rdi, msg_fact
    call print_string

    mov rax, 5
    call factorial
    call print_number
    call print_newline

    ; === Fibonacci ===
    mov rdi, msg_fib
    call print_string

    mov rax, 10
    call fibonacci
    call print_number
    call print_newline

    mov rdi, msg_pow
    call print_string

    mov rax, 2      
    mov rbx, 8      
    call power
    call print_number
    call print_newline

    mov rax, 60
    xor rdi, rdi
    syscall

; =========================
; FAKTORIAL
; input : rax (n)
; output: rax (n!)
; =========================
factorial:
    mov rcx, rax
    mov rax, 1

.fact_loop:
    cmp rcx, 1
    jl .done
    imul rax, rcx
    dec rcx
    jmp .fact_loop

.done:
    ret

; =========================
; FIBONACCI
; input : rax (n)
; output: rax (fib n)
; =========================
fibonacci:
    cmp rax, 1
    jle .base

    mov rcx, rax
    mov rax, 0
    mov rbx, 1

.fib_loop:
    add rax, rbx
    xchg rax, rbx
    loop .fib_loop

    mov rax, rbx
    ret

.base:
    ret

; =========================
; POWER
; input : rax = base
;         rbx = exponent
; output: rax
; =========================
power:
    mov rcx, rbx
    mov rbx, rax
    mov rax, 1

.pow_loop:
    test rcx, rcx
    jz .pow_done
    imul rax, rbx
    dec rcx
    jmp .pow_loop

.pow_done:
    ret

; =========================
; PRINT STRING
; rdi = address
; =========================
print_string:
    mov rsi, rdi
    xor rdx, rdx

.count:
    cmp byte [rsi + rdx], 0
    je .send
    inc rdx
    jmp .count

.send:
    mov rax, 1
    mov rdi, 1
    syscall
    ret

; =========================
; PRINT NUMBER (rax)
; =========================
print_number:
    mov rcx, buffer + 31
    mov rbx, 10
    mov byte [rcx], 0

.conv:
    xor rdx, rdx
    div rbx
    add dl, '0'
    dec rcx
    mov [rcx], dl
    test rax, rax
    jnz .conv

    mov rsi, rcx
    mov rdx, buffer + 31
    sub rdx, rcx

    mov rax, 1
    mov rdi, 1
    syscall
    ret

print_newline:
    mov rax, 1
    mov rdi, 1
    mov rsi, newline
    mov rdx, 1
    syscall
    ret
