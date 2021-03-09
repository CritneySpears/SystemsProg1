; Real-Mode Part of the Boot Loader
;
; When the PC starts, the processor is essentially emulating an 8086 processor, i.e. 
; a 16-bit processor.  So our initial boot loader code is 16-bit code that will 
; eventually switch the processor into 32-bit mode.

BITS 16

; Tell the assembler that we will be loaded at 9000h (That's where stage 1 jumps to to begin stage 2).
ORG 9000h

start:
    jmp     Stage2

%include "console.asm"
%include "graphics.asm"

Stage2:

    ; Switch video mode to VGA
    xor     ah, ah
    mov     al, 13h
    int     10h

; Here be Rendering Procedure
    ; Clear the back buffer (to a set colour)
    mov     ax, 0
    call    Clear_Buffer_To_Colour

    ; Draw Things
    mov     ax, 15
    call    Draw_Lines_Demo
 
    ; Copy the back buffer to the front buffer
    call    Buffer_Swap

    ; Infinite Loop
endloop:
    jmp     endloop

; Current frame we're writing to
Back_Buffer: equ 1000h

; Pad out the boot loader stage 2 so that it will be exactly 7 sectors
            times 512 * 7 - ($ - $$) db 0