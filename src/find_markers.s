        section .text
        global  find_markers

find_markers:
        ; bmp           rdi
        ; xArrayPtr     rsi
        ; YArrayPtr     rdx
        ; found         rax
        ; xx            rcx
        ; yy            rbx
        ; width         r8
        ; height        r9
        ; amount        r10
        ; checkLength   r11
        ; counter       r12
        ; cx            r13
        ; cy            r14
        ; myflags       r15
        
        push rbp                        
        push rbx                        
        push r12                        
        push r13                        
        push r14                        
        push r15    

        mov r8d, dword [rdi + 18]       ; load the width of the picture into the bottom 32 bits
        mov r9d, dword [rdi + 22]       ; same with the width
        mov eax, dword [rdi + 10]       ; offset
        add rdi, rax                    ; offset + picture address

        xor rax, rax                    ; counter "How many markers have we found = 0
        xor rcx, rcx                    ; Prepare width loop (xx = 0), который мы проверяем на маркер

width_loop:
        xor rbx, rbx                    ; Prepare height loop (yy = 0) который мы проверяем на маркер

height_loop:
        mov r13, rcx                    ; Set cx = xx, от него будем бегать что б посчитать длину маркера
        mov r14, rbx                    ; Set cy = yy 
        xor r10, r10                    ; Set length to zero (so we count down the cells)(он будет уходить в минус, типо на каждый блок длины)
        
        call walk_left_black            ; find length

        neg r10                         ; The length is negative. So invert
        lea r11, [r10 + 1]              ; length++
        lea r13, [rcx + 1]              ; cx = xx + 1
        lea r14, [rbx + 1]              ; cy = yy + 1

        mov r10, r11                    ; Set the initial length to the one we want to check (the function will stop automatically at -1)
        call walt_left_white            ; Note that setting it to -1 means the function will traverse one more cell than specified. This is intentional to verify the corner

        cmp r10, 0                      ; >= 0 -> not_marker (find next marker)
        jge not_marker                  

        lea r13, [rcx + 1]              ; cx = xx + 1
        mov r14, rbx                    ; cy = yy

        dec r11                         
        mov r10, r11                    

        call walk_down_white            

        cmp r10, 0                      
        jge not_marker                  

        xor r12, r12                    ; Offset counter inside the marker to check its insides  = 0

inmarker_loop:
        inc r12                         ; Offset counter++

        lea r13, [rcx + 1]              ; cx = xx - counter - 1:
        sub r13, r12   

        mov r14, rbx                    
        sub r14, r12                    ; cy = yy - counter

        dec r11                         
        mov r10, r11                    
        call walk_down_black            

        test r10, r10                   ; if != 0 -> not_marker
        jnz not_marker                  

        mov r13, rcx                    
        sub r13, r12                    ; cx = xx - counter

        mov r14, rbx                    
        sub r14, r12                    ; cy = yy - counter

        mov r10, r11                    ; copy length

        call walk_left_black         

        test r10, r10                   ; Check f right size -> inmarker_loop (Continue checking further.)
        jz inmarker_loop      

        mov r13, rcx                    ; Otherwise, check that the end of the marker is properly closed with non-black pixels.
        sub r13, r12                    

        mov r14, rbx                    
        sub r14, r12                    

        mov r10, r11                    
        call walt_left_white            ; Вот сама проверка

        cmp r10, 0                      
        jge not_marker                  

        mov r13, rcx                    ; cx = xx - counter
        sub r13, r12                    

        lea r14, [rbx - 1]              ; cy = yy - counter - 1
        sub r14, r12                    ;

        lea r10, [r11 - 1]              ; length--
        call walk_down_white            

        cmp r10, 0                      
        jge not_marker                  
        
        mov dword [rsi + rax * 4 ], ecx ; Store xx
        lea rbp, [r9 - 1]               
        sub rbp, rbx                    
        mov dword [rdx + rax * 4 ], ebp ; Store yy

        inc rax                         ; marker counter++
        cmp rax, 50                     ; If there are too many markers, then stop.
        jge fin                         

not_marker:                             
        inc rbx                         ; yy++
        cmp rbx, r9                     ; Check yy against height
        jl height_loop                  ; if yy != height

        inc rcx                         ; xx++
        cmp rcx, r8                    
        jl width_loop                   
fin:
        pop r15                         
        pop r14                         
        pop r13                         
        pop r12                         
        pop rbx
        pop rbp
        ret

; Flags. The left bit represents "Go left", and the right bit represents "Go on black".
walk_down_white:
        mov r15, 0b00                   ; Go down on white      
        jmp walk_strip          

walt_left_white:
        mov r15, 0b10                   ; Go left on white
        jmp walk_strip

walk_down_black:
        mov r15, 0b01                   ; Go down on black
        jmp walk_strip
        
walk_left_black:
        mov r15, 0b11                   ; Go left on black

walk_strip:
        call is_black                   ; Check the color. This function will set the third bit of our flags to 1 if the color is black.

        cmp r15, 0b100                  
        je walk_strip_return            
        cmp r15, 0b110                 
        je walk_strip_return            
        cmp r15, 0b001                  
        je walk_strip_return            
        cmp r15, 0b011                  
        je walk_strip_return

        dec r10                         ; lenght--
        xor rbp, rbp                    
        test r15, 0b010                 

        setnz bpl                       ; Set a one (setnz) if we are moving left in rbp (bpl - нижние 8 бита)
        sub r13, rbp                    ; x - 0/1
        xor rbp, 1                      
        sub r14, rbp                    ; y - 1/0

        test r15, 0b101                 
        jnz walk_strip                  
        cmp r10, -1                     
        jne walk_strip                  

walk_strip_return:                      
        ret

is_black:        
        and r15, ~0b100                 ; Set the flag bit indicating "Color is not black" to 0.
        
        cmp r13, 0                      ; cx < 0 -> is_black_return
        jl is_black_return              
        cmp r13, r8                     ; Now compare the X against the width.
        jge is_black_return             ; >=

        cmp r14, 0                      
        jl is_black_return              
        cmp r14, r9                    
        jge is_black_return             

        lea rbp, [r8 * 2 + r8 + 3]      ; Calculate the pixel address]
        and rbp, ~3                     ; Zero the last two bits. -> :4
        imul rbp, r14                   ; Multiply the width by the y
        lea rbp, [rbp + r13 * 2]        ; +x*3
        add rbp, r13                    

        mov ebp, dword [rdi + rbp]      ; Load color 4 bytes
        and ebp, 0x00FFFFFF             
        jnz is_black_return             
        or r15, 0b100                   ; Otherwise, set the flag to "black".
is_black_return:
        ret                             ; And return the flag.
