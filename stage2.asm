; Real-Mode Part of the Boot Loader
;
; When the PC starts, the processor is essentially emulating an 8086 processor, i.e. 
; a 16-bit processor.  So our initial boot loader code is 16-bit code that will 
; eventually switch the processor into 32-bit mode.

; ctyme.com/intr/int.htm

BITS 16

; Tell the assembler that we will be loaded at 9000h (That's where stage 1 jumps to to begin stage 2).
ORG 9000h

start:
    jmp     Stage2                      ; Startup

%include "io.asm"
%include "video.asm"

Stage2:

    ; Switch video mode to VGA
    xor     ah, ah
    mov     al, 13h
    int     10h

    ; Rendering
    mov     ax, 0
    call    Clear_Color

    mov     ax, 15
    call    Demo_Lines
 
    ; Blit back buffer on front buffer
    call    Present

endloop:
    jmp     endloop

; Pad out the boot loader stage 2 so that it will be exactly 7 sectors
            times 512 * 7 - ($ - $$) db 0

; Segment that will be used for the back buffer
Back_Buff_Segment: equ 1000h