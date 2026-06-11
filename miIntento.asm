#make_com#

org 100h

mov ax, cs
mov ds, ax

mov ah, 00h
mov al, 03h
int 10h

mov ax, 0B800h
mov es, ax

mov bx, 0000h
mov dx, es:[bx]
mov fondo_negro, dx

  
mov si, 10
mov cx, 6
;09B2h es una casilla casi marcada XD
;09CEh es la cruz xd
;09BAh es la rama de la cruz
;09DBh es el bloque pintado
;090Fh puede servir com estrella xd                   
;097F es el triangulo
dibujar_fluidonn:
    mov bx, fluidonn[si]
    mov word ptr es:[bx], 09DBh
    add si, -2
    loop dibujar_fluidonn
    
    ;mov bx, 0AEEh;direccion de memoria
    ;mov word ptr es:[bx], 0CDBh;color y caracteres
                      
avanza:
    mov ah, 01h
    int 16h
    jz mover_mapa
    ;al llegar aqui es que se presiono algo xd
    mov ah, 00h
    int 16h
    
    cmp ah, 48h
    je subir
    cmp ah, 50h
    je bajar
    jmp mover_mapa
    
    subir:
        mov si, 8; aqui empieza a borrar el rastro
        mov bx, fluidonn[si]
        mov word ptr es:[bx], 0000h
        add bx, -160
        mov fluidonn[si], bx 
        mov si, 4
        mov bx, fluidonn[si]
        mov word ptr es:[bx], 0000h
        add bx, -160
        mov fluidonn[si], bx
        mov si, 0
        mov bx, fluidonn[si]
        mov word ptr es:[bx], 0000h
        add bx, -160
        mov fluidonn[si], bx
        
        mov si, 10;aqui empieza a moverse para arriba
        mov bx, fluidonn[si]
        add bx, -160
        mov fluidonn[si], bx
        mov word ptr es:[bx], 09DBh 
        mov si, 6
        mov bx, fluidonn[si]
        add bx, -160
        mov fluidonn[si], bx
        mov word ptr es:[bx], 09DBh
        mov si, 2
        mov bx, fluidonn[si]
        add bx, -160
        mov fluidonn[si], bx
        mov word ptr es:[bx], 09DBh
        jmp mover_mapa    
                
    bajar:
        mov si, 10
        mov bx, fluidonn[si]
        mov word ptr es:[bx], 0000h
        add bx, 160
        mov fluidonn[si], bx 
        mov si, 6
        mov bx, fluidonn[si]
        mov word ptr es:[bx], 0000h
        add bx, 160
        mov fluidonn[si], bx
        mov si, 2
        mov bx, fluidonn[si]
        mov word ptr es:[bx], 0000h
        add bx, 160
        mov fluidonn[si], bx
        
        mov si, 8                 
        mov bx, fluidonn[si]
        add bx, 160
        mov fluidonn[si], bx
        mov word ptr es:[bx], 09DBh 
        mov si, 4
        mov bx, fluidonn[si]
        add bx, 160
        mov fluidonn[si], bx
        mov word ptr es:[bx], 09DBh
        mov si, 0
        mov bx, fluidonn[si]
        add bx, 160
        mov fluidonn[si], bx
        mov word ptr es:[bx], 09DBh
        jmp mover_mapa
    
    ;=====================SISTEMA DE GENERACION=====================
               
    mover_mapa:
        add [vari], 2               ; Saltos de 3 filas para mayor dispersion
        cmp [vari], 22
        jl seguir_contador
        mov [vari], 4               ; Mantener entre filas 4 y 21
    
    seguir_contador:
        inc [spawner_time]
        mov ax, [spawner_delay]
        cmp [spawner_time], ax
        jne mover_cajas             
        mov [spawner_time], 0
        
        mov si, 0
        mov cx, 20
    buscar_vacio:
        cmp caja_sovietica[si], 0000h
        je poner_caja
        add si, 2
        loop buscar_vacio
        jmp mover_cajas
    poner_caja:
        ;aqui ya imptimimos la caja
        mov ax, [vari]
        mov dx, 160
        mul dx        
        add ax, 158
        mov word ptr caja_sovietica[si], ax;en la fila 10, al extremo 
    
    ;=====================SISTEMA DE DEZPLAZAMIENTO=====================
                
    mover_cajas:
        mov si, 0
        mov cx, 20
     
    mover_cajas2:;no se me ocurrio un mejor nombre
        mov bx, caja_sovietica[si]
        cmp bx, 0000h
        je siguiente_caja
         
        mov word ptr es:[bx], 0000h;borramos la caja al moverse
        add bx, -2
        
        mov ax, bx
        mov dx, 0
        mov di, 160
        div di
        
        cmp dx, 156
        ja destroy_box
        
        mov caja_sovietica[si], bx ;aqui actualizamos la posicion de la caja ya movida
        cmp bx, 0640h
        jl destroy_box;aqui me pashe de ingles, C1 que pasa
        mov dx, [caja]
        mov es:[bx], dx
        jmp siguiente_caja
    destroy_box:
        mov word ptr caja_sovietica[si], 0000h
            
    siguiente_caja:
        add si, 2
        loop mover_cajas2
            
    ;=====================SISTEMA DE COLISIONES=====================
    verificar_colision:
        mov si, 0
        mov cx, 20
    
    bucle_colision:
        mov ax, caja_sovietica[si]       
        cmp ax, 0000h
        je prox_caja
        
        cmp ax, [fluidonn[0]]
        je perdiste
        cmp ax, [fluidonn[2]]
        je perdiste
    
    prox_caja:         
        add si, 2
        loop bucle_colision
        "
        mov cx, 00h
        mov dx, 1000h
        mov ah, 86h
        int 15h   
        "        
        jmp avanza
    perdiste:
        ret

fluidonn          dw 07CEh, 072Eh, 07CCh, 072Ch, 07CAh, 072Ah
caja              dw 0CCEh  
cajas_actuales    db 0
caja_sovietica    dw 20 dup(0000h);direccion de memoria

spawner_time      dw 0
spawner_delay     dw 5

fondo_negro dw 0000h
direccion dw 0
vari dw 4
vart dw 09CFh


