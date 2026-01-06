; kernel.asm - Kernel entry point
[BITS 16]

global _start
_start:
    ; Clear screen
    mov ah, 0x00
    mov al, 0x03
    int 0x10

    ; Print welcome message
    mov si, msg_welcome
    call print_string

    ; Enable A20 line
    call enable_a20

    ; Enter protected mode
    cli
    lgdt [gdt_descriptor]
    
    mov eax, cr0
    or eax, 1
    mov cr0, eax
    
    jmp 0x08:protected_mode

print_string:
    lodsb
    or al, al
    jz .done
    mov ah, 0x0E
    int 0x10
    jmp print_string
.done:
    ret

enable_a20:
    in al, 0x92
    or al, 2
    out 0x92, al
    ret

[BITS 32]
global protected_mode
protected_mode:
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov esp, 0x90000

    ; Call C kernel
    extern kernel_main
    call kernel_main

    ; Hang if kernel returns
    hlt

; GDT
gdt_start:
    dq 0x0000000000000000  ; Null descriptor

gdt_code:
    dw 0xFFFF    ; Limit
    dw 0x0000    ; Base (low)
    db 0x00      ; Base (middle)
    db 10011010b ; Access
    db 11001111b ; Flags + Limit
    db 0x00      ; Base (high)

gdt_data:
    dw 0xFFFF
    dw 0x0000
    db 0x00
    db 10010010b
    db 11001111b
    db 0x00

gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dd gdt_start

msg_welcome db 'SimpleOS v1.0', 13, 10, 'Entering protected mode...', 13, 10, 0