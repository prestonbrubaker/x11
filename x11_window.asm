section .data
    window_title db "Shoutout Preston!", 0
    event_mask equ 0x8001  ; Exposure (0x8000) + KeyPress (0x1)
    red_color equ 0xFF0000  ; RGB color (0xRRGGBB) for red
    ts_sec     dq 0                ; tv_sec = 0
    ts_nsec    dq 10000000         ; tv_nsec = 100,000,000 (100ms)

section .bss
    buffer resq 1
    buffer2 resq 1

section .text
global main
extern XOpenDisplay, XDefaultRootWindow, XCreateSimpleWindow, XStoreName, XSelectInput, XMapWindow, XNextEvent
extern XCreateGC, XSetForeground, XFillRectangle, XFlush, XPending

main:
    push rbp
    mov rbp, rsp

    ; Open Display
    xor edi, edi
    call XOpenDisplay wrt ..plt
    test rax, rax
    jz .exit
    mov r12, rax  ; Store Display*

    ; Get Root Window
    mov rdi, r12
    call XDefaultRootWindow wrt ..plt
    mov r13, rax  ; Store valid root window

    ; Create Window
    mov rdi, r12
    mov rsi, r13
    xor edx, edx
    xor ecx, ecx
    mov r8d, 400
    mov r9d, 300
    push 0
    push 0
    push 0
    call XCreateSimpleWindow wrt ..plt
    add rsp, 24
    mov r14, rax  ; Store Window ID

    ; Set Window Title
    mov rdi, r12
    mov rsi, r14
    lea rdx, [rel window_title]
    call XStoreName wrt ..plt

    ; Select Events
    mov rdi, r12
    mov rsi, r14
    mov edx, event_mask
    call XSelectInput wrt ..plt

    ; Show Window
    mov rdi, r12
    mov rsi, r14
    call XMapWindow wrt ..plt

    ; Create Graphics Context (GC)
    mov rdi, r12
    mov rsi, r14
    xor rdx, rdx  ; No special values
    call XCreateGC wrt ..plt
    mov r15, rax  ; Store GC in r15

    ; Set Foreground Color to Red
    mov rdi, r12
    mov rsi, r15
    mov edx, red_color
    call XSetForeground wrt ..plt
    ;-------------------------------------------------------test

    xor r10d, r10d
    

.event_loop:
    ; Check if there are pending events (non-blocking)
    mov rdi, r12
    call XPending wrt ..plt  ; Check if event exists
    test rax, rax
    jz .skip_event           ; If no events, skip handling

    ; Handle event (only if pending)
    sub rsp, 0x180
    mov rdi, r12
    mov rsi, rsp
    call XNextEvent wrt ..plt
    add rsp, 0x180

.skip_event:

    mov rdi, r12
    mov rsi, r15
    mov edx, 0xFFFFFF
    call XSetForeground wrt ..plt

    ; Draw Rectangle (100+x, 50 at 50,50)
    mov rdi, r12  ; Display*
    mov rsi, r14  ; Window ID
    mov rdx, r15  ; GC
    mov ecx, 50   ; X position
    mov r8d, 50   ; Y position
    mov r9d, 100  ; Base width
    add r9d, 200
    push 50       ; Height (must be 8-byte aligned)

    call XFillRectangle wrt ..plt
    add rsp, 8    ; Cleanup stack


    mov r10, [buffer2]
    inc r10
    mov [buffer2], r10



    mov rdi, r12
    mov rsi, r15
    mov edx, red_color
    xor r10, r10
    mov r10d, [buffer2]
    mov rax, r10
    mov r13, 5000
    mul r13
    mov r10, rax
    add rdx, r10
    call XSetForeground wrt ..plt


    ; Draw Rectangle (100+x, 50 at 50,50)
    mov rdi, r12  ; Display*
    mov rsi, r14  ; Window ID
    mov rdx, r15  ; GC
    mov ecx, 50   ; X position
    mov r8d, 50   ; Y position
    mov r9d, 0  ; Base width

    add r9d, [buffer]
    push 50       ; Height (must be 8-byte aligned)

    call XFillRectangle wrt ..plt
    add rsp, 8    ; Cleanup stack

    ; Force refresh
    mov rdi, r12
    call XFlush wrt ..plt  ; <=== Forces X11 to refresh

    ; Increment rectangle width
    mov r10d, [buffer]
    inc r10d
    mov [buffer], r10d

    mov rax, 35         ; Syscall number for nanosleep
    lea rdi, [rel ts_sec] ; Address of timespec struct
    xor rsi, rsi        ; NULL second argument (ignore remaining time)
    syscall             ; Invoke nanosleep syscall

    cmp r10d, 300
    jl .event_loop
    xor r10d, r10d  ; Reset width
    mov [buffer], r10d



    jmp .event_loop

.exit:
    xor eax, eax
    pop rbp
    ret
