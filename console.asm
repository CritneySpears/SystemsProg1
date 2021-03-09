; Write to the console using BIOS.
; 
; Input: SI points to a null-terminated string
Console_Write_16:
	mov 	ah, 0Eh						; 0Eh is the INT 10h BIOS call to output the value contained in AL to screen

Console_Write_16_Repeat:
    mov		al, [si]					; Load the byte at the location contained in the SI register into AL
	inc     si							; Add 1 to SI
    test 	al, al						; If the byte is 0, we are done
	je 		Console_Write_16_Done
	int 	10h							; Output character contained in AL to screen
	jmp 	Console_Write_16_Repeat		; and get the next byte

Console_Write_16_Done:
    ret