; Real-Mode Part of the Boot Loader
;
; When the PC starts, the processor is essentially emulating an 8086 processor, i.e. 
; a 16-bit processor.  So our initial boot loader code is 16-bit code that will 
; eventually switch the processor into 32-bit mode.

BITS 16

; Tell the assembler that we will be loaded at 9000h (That's where stage 1 jumps to to begin stage 2).
ORG 9000h

start:
    jmp     Second_Stage

%include "console.asm"
%include "graphics.asm"
%include "a20.asm"
%include "messages.asm"

Second_Stage:

    mov     si, second_stage_msg
    call    Console_WriteLine_16

    call    Enable_A20

    push    dx
    mov     si, dx
    add     si, dx
    mov     si, [si + a20_message_list]
    call    Console_WriteLine_16
    pop     dx

    ; Keyboard input message
    mov     si, continue_msg
    call    Console_WriteLine_16

    ; await a keyboard input
    mov     ah, 0h
    int     0x16

    ; Switch video mode to VGA
    xor     ah, ah
    mov     al, 13h
    int     10h

; Here be Rendering Procedure
    ; Clear the back buffer (to a colour set by ax)
    mov     ax, 0
    call    Clear_Buffer_To_Colour

    ; Draw Things
    call    Draw_Lines_Demo
 
    ; Copy the back buffer to the front buffer
    call    Buffer_Swap

    ; Infinite Loop
endloop:
    jmp     endloop

; Current frame we're writing to
Back_Buffer: equ 1000h

; Pad out the boot loader stage 2 so that it will be exactly 7 sectors
            times 3584 - ($ - $$) db 0