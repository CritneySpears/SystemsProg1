; Get the sign of the value
;   1st input - value
;   2nd input - size
%macro sign 2
    sar     %1, %2 - 1
    or      %1, 1
%endmacro

; Get the absolute value
;
%macro abs 2
    mov     %2, %1          ; Save value
    neg     %1              ; Negate
    cmovl   %1, %2          ; If originally +ve; move back
%endmacro

; Draws a line from two points
; Input format: line y1, x1, y0, x0, Colour
;
%macro line 5
    push    %4
    push    %3
    push    %2
    push    %1
    push    %5
    call    Draw_Line
%endmacro