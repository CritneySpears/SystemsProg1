%include "macros.asm"

; Clears the back buffer.
; Colour of screen set with ax prior to call
;
Clear_Buffer_To_Colour:
    push    es
    push    cx
    push    di

    push    ax

    mov     ax, Back_Buffer
    mov     es, ax
    
    pop     ax

    xor     di, di
    mov     cx, 320 * 200 / 2
    rep     stosw

    pop     di
    pop     cx
    pop     es
    ret

; 10 calls to the line drawing function
; Draws the lines horizontally in parallel 
;
Draw_Lines_Demo:
    line    0, 10, 319, 10, 0100b
    line    0, 30, 319, 30, 0110b
    line    0, 50, 319, 50, 1110b
    line    0, 70, 319, 70, 1010b
    line    0, 90, 319, 90, 1001b
    line    0, 110, 319, 110, 1011b
    line    0, 130, 319, 130, 1101b
    line    0, 150, 319, 150, 1000b
    line    0, 170, 319, 170, 0111b
    line    0, 190, 319, 190, 1111b

    ret

; Copies the back buffer into the front buffer.
;
Buffer_Swap:
    push    ds
    push    es
    push    si
    push    di
    push    cx

    mov     cx, 0xA000
    mov     es, cx

    mov     cx, Back_Buffer
    mov     ds, cx

    mov     cx, 320 * 200 / 2

    xor     si, si
    xor     di, di

    rep     movsw

    pop     cx
    pop     di
    pop     si
    pop     es
    pop     ds

    ret

; Draws a line between any two points using a specified colour.
; Inputs: y1, x1, y0, x0, Colour
;
Draw_Line:
    ; Stack Frame:
    ; 
    ; BP + 12 - y1
    ; BP + 10 - x1
    ; BP + 8  - y0
    ; BP + 6  - x0
    ; BP + 4  - Colour
    ; BP + 2  - Ret
    ; BP      - BP
    ; BP - 2  - AX
    ; BP - 4  - BX
    ; BP - 6  - CX
    ; BP - 8  - DX
    ; BP - 10 - DS
    ; BP - 12 - SI
    ; BP - 14 - SX
    ; BP - 16 - SY
    ; BP - 18 - ERR

    push    bp
    mov     bp, sp

    push    ax
    push    bx
    push    cx
    push    dx
    push    ds
    push    si
    sub     sp, 6

    mov     bx, Back_Buffer
    mov     ds, bx

    ; dx := abs(x1 - x0)
    mov     si, [bp + 10]
    sub     si, [bp + 6]
    abs     si, ax                  ; DX

    ; dy := abs(y1 - y0)
    mov     di, [bp + 12]
    sub     di, [bp + 8]
    abs     di, ax                  ; DY

    ; if x0 < x1 then sx := 1 else sx := -1
    mov     ax, [bp + 10]           ; x1
    sub     ax, [bp + 6]            ; x0
    sign    ax, 16
    mov     [bp - 14], ax           ; SX

    ; if y0 < y1 then sy := 1 else sy := -1
    mov     ax, [bp + 12]           ; y1
    sub     ax, [bp + 8]            ; y0
    sign    ax, 16
    mov     [bp - 16], ax           ; SY

    ; err := dx - dy
    mov     [bp - 18], si
    sub     [bp - 18], di
    mov     cx, [bp + 6]
    mov     dx, [bp + 8]

Draw_Line_loop:

    imul    bx, dx, 320
    add     bx, cx
    
    ; Clamping values so that x coords greater than the horizontal are added to the next y coord.
    mov     ax, 320 * 200
    cmp     bx, ax
    cmova   bx, ax
    mov     ax, [bp + 4]
    mov     byte[ds:bx], al ; Plot the point

    ; if x0 = x1 and y0 = y1 then break
    push    ax
    cmp     cx, [bp + 10]
    lahf
    mov     al, ah
    cmp     dx, [bp + 12]
    lahf
    and     ah, al
    sahf
    pop     ax
    jnz     Draw_Line_Continued
    add     sp, 6 ; Clear the local vars

    pop     si
    pop     ds
    pop     dx
    pop     cx
    pop     bx
    pop     ax
    pop     bp
    ret     10

Draw_Line_Continued:
    xor     ax, ax

    ; e2 := 2 * err
    mov     bx, [bp - 18]
    shl     bx, 1

    ; if e2 > -dy
    ;   err := err - dy
    ;   x0 := x0 + sx
    neg     di
    cmp     bx, di
    cmovg   ax, di
    add     [bp - 18], ax
    mov     ax, 0
    cmp     bx, di
    cmovg   ax, [bp - 14]
    neg     di
    add     cx, ax

    ; if e2 < dx
    ;   err := err + dx
    ;   y0 := y0 + sy
    cmp     bx, si
    mov     ax, 0
    cmovl   ax, si
    add     [bp - 18], ax
    mov     ax, 0
    cmp     bx, si
    cmovl   ax, [bp - 16]
    add     dx, ax
    jmp     Draw_Line_loop