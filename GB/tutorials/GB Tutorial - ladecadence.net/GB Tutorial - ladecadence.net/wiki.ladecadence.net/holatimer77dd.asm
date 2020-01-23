; Hola Timer
; David Pello 2010
; ladecadence.net
; Para el tutorial en: 
; http://wiki.ladecadence.net/doku.php?id=tutorial_de_ensamblador

INCLUDE "gbhw.inc"          ; importamos el archivo de definiciones

; Variables
_CONTROL_TIEMPO     EQU     _RAM    ; controla los milisegundos
_ACTIVADO           EQU     _RAM+1  ; cronómetro activado o no
_SEGUNDOS           EQU     _RAM+2
_MINUTOS            EQU     _RAM+3
_HORAS              EQU     _RAM+4
_PAD                EQU     _RAM+5

; Constantes
_POS_CRONOM         EQU     _SCRN0+32*4+6   ; posición en pantalla

; interrupción de vBlank
SECTION "Vblank",ROM0[$0040]
    call DibujaCronometro
    reti

; interrupción de desbordamiento del timer
SECTION "Timer_Overflow",ROM0[$0050]
    ; cuando hay una interrupción del timer, llamamos a esta subrutina
    call    ControlTimer
    reti

; El programa comienza aqui:
SECTION "start",ROM0[$0100]
    nop
    jp      inicio

; Cabecera de la ROM (Macro definido en gbhw.inc)
; define una rom sin mapper, de 32K y sin RAM, lo más básico
; (como por ejemplo la del tetris)
    ROM_HEADER  ROM_NOMBC, ROM_SIZE_32KBYTE, RAM_SIZE_0KBYTE

; aqui empieza nuestro programa
inicio:
    nop
    di                      ; deshabilita las interrupciones
    ld      sp, $ffff       ; apuntamos la pila al tope de la ram

inicializacion:

    ; iniciamos el timer
    ld      a, 0
    ld      [rTAC], a       ; timer apagado, divider a 00 (4096 Hz)

    ld      a, 51
    ld      [rTMA], a       ; cuando TIMA se desborde, este es 
                            ; su valor de reinicio, (1/4096)*(255-51) = 0.049 s
    ld      [rTIMA], a      ; valor inicial del timer.

    ; iniciamos las variables
    ld      a, 0
    ld      [_CONTROL_TIEMPO], a
    ld      [_ACTIVADO], a
    ld      [_SEGUNDOS], a
    ld      [_MINUTOS], a
    ld      [_HORAS], a

    ; paletas
    ld      a, %11100100    ; Colores de paleta desde el mas oscuro al
                            ; más claro, 11 10 01 00
    ld      [rBGP], a       ; escribimos esto en el registro de paleta de fondo
    ld      [rOBP0], a      ; y en la paleta 0 de sprites

    ; scroll
    ld      a, 0            ; escribimos 0 en los registros de scroll X e Y
    ld      [rSCX], a       ; con lo que posicionamos la pantalla visible
    ld      [rSCY], a       ; al inicio (arriba a la izq) del fondo.

    ; video
    call    apaga_LCD       ; llamamos a la rutina que apaga el LCD

    ; cargamos los tiles en la memoria de tiles

    ld      hl, Tiles       ; cargamos en HL la dirección de nuestro tile
    ld      de, _VRAM       ; en DE dirección de la memoria de video
    ld      bc, FinTiles-Tiles  ; número de bytes a copiar

    call    CopiaMemoria

    ; limpiamos el mapa
    ld      de, _SCRN0      ; mapa 0
    ld      bc, 32*32
    ld      l, 11           ; tile vacio
    call    RellenaMemoria

    ; bien, tenemos todo el mapa de tiles cargado
    ; ahora limpiamos la memoria de sprites
    ld      de, _OAMRAM     ; memoria de atributos de sprites
    ld      bc, 40*4        ; 40 sprites x 4 bytes cada uno
    ld      l, 0            ; lo vamos a poner todo a cero, asi los sprites
    call    RellenaMemoria  ; no usados quedan fuera de pantalla

    ; dibujamos el cronómetro
    call    DibujaCronometro

    ; configuramos y activamos el display
    ld      a, LCDCF_ON|LCDCF_BG8000|LCDCF_BG9800|LCDCF_BGON|LCDCF_OBJ8
    ld      [rLCDC], a

; bucle principal
control:
    ; leemos el pad
    call    lee_pad

    ; Ahora activamos o desactivamos el cronometro
    ld      a, [_PAD]
    and     %00000001       ; Boton A
    call    nz, Activa

    ; Resetear
    ld      a, [_PAD]
    and     %00000010       ; Boton B
    call    nz, Resetea

    ld      bc, 15000
    call    retardo
    ; volvemos a empezar
    jr      control


; Rutina de control del cronometro
Activa:

    ld      a, [_ACTIVADO]
    cp      1
    jp      z, .desactiva       ; si esta activado, desactivamos
    ; si no, activamos
    ld      a, 1
    ld      [_ACTIVADO], a

    ld      a, %00000100    ; timer activado
    ld      [rTAC], a

    ld      a,  %00000101   ; interrupciones del timer y vBlank
    ld      [rIE], a
    ei                      ; activamos las interrupciones
    ret                     ; volvemos
.desactiva
    ld      a, 0
    ld      [_ACTIVADO], a

    ld      a, %00000000    ; timer desactivado
    ld      [rTAC], a

    ld      a,  %00000101   ; interrupciones del timer y vBlank
    ld      [rIE], a
    di                      ; desactivamos las interrupciones

    ret

; Resetea el cronometro
Resetea:
    ld      a, 0
    ld      [_SEGUNDOS], a
    ld      [_MINUTOS], a
    ld      [_HORAS], a

    ld      a, 51           ; valor inicial del timer
    ld      [rTIMA], a

    ; miramos si está activado
    ld      a, [_ACTIVADO]
    ret     z
    ; si no lo está, redibujamos
    call EsperaVBlank
    call DibujaCronometro

    ret

DibujaCronometro:
    ; decenas de horas
    ld      a, [_HORAS]
    and     $F0
    swap    a
    ld      [_POS_CRONOM], a
    ; horas
    ld      a, [_HORAS]
    and     $0F
    ld      [_POS_CRONOM+1], a
    ; :
    ld      a, 10
    ld      [_POS_CRONOM+2], a
    ; decenas de minutos
    ld      a, [_MINUTOS]
    and     $F0
    swap    a
    ld      [_POS_CRONOM+3], a
    ; minutos
    ld      a, [_MINUTOS]
    and     $0F
    ld      [_POS_CRONOM+4], a
    ; :
    ld      a, 10
    ld      [_POS_CRONOM+5], a
    ; decenas de segundos
    ld      a, [_SEGUNDOS]
    and     $F0
    swap    a
    ld      [_POS_CRONOM+6], a
    ; segundos
    ld      a, [_SEGUNDOS]
    and     $0F
    ld      [_POS_CRONOM+7], a

    ret

; Controla el tiempo
ControlTimer:
    ld      a, [_CONTROL_TIEMPO]
    cp      20                      ; cada 20 interrupciones, pasa 1 seg
    jr      z, .incrementa
    inc     a                       ; si no, incrementamos y volvemos
    ld      [_CONTROL_TIEMPO], a
    ret
.incrementa
    ; reseteamos el contador
    ld      a, 0
    ld      [_CONTROL_TIEMPO], a
    ; incrementamos los segundos
    ld      a, [_SEGUNDOS]
    inc     a
    daa
    cp      96              ; han pasado 60 segundos? (96 porque usamos BCD)
    jr      z, .minutos     ; si, a controlar los minutos

    ld      [_SEGUNDOS], a  ; no, guardamos y volvemos
    ret
.minutos
    ld      a, 0
    ld      [_SEGUNDOS], a  ; incrementar el minuto, segundos a 0

    ld      a, [_MINUTOS]
    inc     a
    daa
    cp      96              ; han pasado 60 minutos?
    jr      z, .horas       ; si, a controlar las horas

    ld      [_MINUTOS], a   ; no, guardamos y volvemos
    ret
.horas
    ld      a, 0
    ld      [_MINUTOS], a  ; incrementar el minuto, segundos a 0

    ld      a, [_HORAS]
    inc     a
    daa
    cp      36              ; han pasado 24 horas? (36 equivale a 24 en BCD)
    jr      z, .reset       ; si, a volver a empezar

    ld      [_HORAS], a   ; no, guardamos y volvemos
    ret
.reset
    call    Resetea

    ret

; Rutina de lectura del pad
lee_pad:
    ; a cero
    ld      a, 0
    ld      [_PAD], a

    ; vamos a leer la cruzeta:
    ld      a, %00100000    ; bit 4 a 0, bit 5 a 1 (cruzeta activada, botones no)
    ld      [rP1], a

    ; ahora leemos el estado de la cruzeta, para evitar el bouncing
    ; hacemos varias lecturas
    ld      a, [rP1]
    ld      a, [rP1]
    ld      a, [rP1]
    ld      a, [rP1]

    and     $0F             ; solo nos importan los 4 bits de abajo.
    swap    a               ; intercambiamos parte baja y alta.
    ld      b, a            ; guardamos el estado de la cruzeta en b
    ; vamos a por los botones
    ld      a, %00010000    ; bit 4 a 1, bit 5 a 0 (botones activados, cruzeta no)
    ld      [rP1], a

    ; leemos varias veces para evitar el bouncing
    ld      a, [rP1]
    ld      a, [rP1]
    ld      a, [rP1]
    ld      a, [rP1]
    ld      a, [rP1]
    ld      a, [rP1]

    ; tenemos en A, el estado de los botones
    and     $0F             ; solo nos importan los 4 bits de abajo.
    or      b               ; hacemos un or con b, para "meter" en la parte
                            ; superior de A, el estado de la cruzeta.

    ; ahora tenemos en A, el estado de todo, hacemos el complemento y
    ; lo guardamos en la variable
    cpl
    ld      [_PAD], a

    ; reseteamos el pad
    ld      a,$30
    ld      [rP1], a

    ; volvemos
    ret

; Rutina de apagado del LCD
apaga_LCD:
    ld      a,[rLCDC]
    rlca                    ; Pone el bit alto de LCDC en el flag de acarreo
    ret     nc              ; La pantalla ya está apagada, volver.

    ; esperamos al VBlank, ya que no podemos apagar la pantalla
    ; en otro momento
    call    EsperaVBlank

    ; estamos en VBlank, apagamos el LCD
    ld      a,[rLCDC]       ; en A, el contenido del LCDC
    res     7,a             ; ponemos a cero el bit 7 (activado del LCD)
    ld      [rLCDC],a       ; escribimos en el registro LCDC el contenido de A

    ret                     ; volvemos
EsperaVBlank:
    ld      a, [rLY]
    cp      145
    jr      nz, EsperaVBlank
    ret


; rutina de retardo
; parámetros
; bc - numero de iteraciones
retardo:
.delay:
    dec     bc              ; decrementamos
    ld      a, b            ; vemos si es cero
    or      c
    jr      z, .fin_delay
    nop
    jr      .delay
.fin_delay:
    ret

; rutina de copia a memoria
; copia un numero de bytes de una direccion a otra
; espera los parámetros:
; hl - dirección de datos a copiar
; de - dirección de destino
; bc - numero de datos a copiar
; destruye el contenido de A
CopiaMemoria:
    ld      a, [hl]     ; cargamos el dato en A
    ld      [de], a     ; copiamos el dato al destino
    dec     bc          ; uno menos por copiar
    ; comprobamos si bc es cero
    ld      a, c
    or      b
    ret     z           ; si es cero, volvemos
    ; si no, seguimos
    inc     hl
    inc     de
    jr      CopiaMemoria


; rutina de relleno de memoria
; rellena un numero de bytes de memoria con un dato
; espera los parámetros:
; de - direccion de destino
; bc - número de datos a rellenar
; l - dato a rellenar
RellenaMemoria:
    ld      a, l
    ld      [de], a     ; mete el dato en el destino
    dec     bc          ; uno menos a rellenar

    ld      a, c
    or      b           ; comprobamos si bc es cero
    ret     z           ; si es cero volvemos
    inc     de          ; si no, seguimos
    jr      RellenaMemoria


Tiles:
; números de 0 al 9, formato de tiles del RGBDS
; 0
DW  `00000000
DW  `00333300
DW  `03000330
DW  `03003030
DW  `03030030
DW  `03300030
DW  `00333300
DW  `00000000
; 1
DW  `00000000
DW  `00003000
DW  `00033000
DW  `00003000
DW  `00003000
DW  `00003000
DW  `00333300
DW  `00000000
; 2
DW  `00000000
DW  `00333300
DW  `03000030
DW  `00003300
DW  `00030000
DW  `00300000
DW  `03333330
DW  `00000000
; 3
DW  `00000000
DW  `00333300
DW  `03000030
DW  `00003300
DW  `00000030
DW  `03000030
DW  `00333300
DW  `00000000
; 4
DW  `00000000
DW  `00000300
DW  `00003300
DW  `00030300
DW  `00333300
DW  `00000300
DW  `00000300
DW  `00000000
; 5
DW  `00000000
DW  `03333330
DW  `03000000
DW  `00333300
DW  `00000030
DW  `03000030
DW  `00333300
DW  `00000000
; 6
DW  `00000000
DW  `00003000
DW  `00030000
DW  `00300000
DW  `03333300
DW  `03000030
DW  `00333300
DW  `00000000
; 7
DW  `00000000
DW  `03333330
DW  `00000300
DW  `00003000
DW  `00030000
DW  `00300000
DW  `00300000
DW  `00000000
; 8
DW  `00000000
DW  `00333300
DW  `03000030
DW  `00333300
DW  `03000030
DW  `03000030
DW  `00333300
DW  `00000000

; 9
DW  `00000000
DW  `00333300
DW  `03000030
DW  `03000030
DW  `00333300
DW  `00003000
DW  `00330000
DW  `00000000

; :
DW  `00000000
DW  `00033000
DW  `00033000
DW  `00000000
DW  `00033000
DW  `00033000
DW  `00000000
DW  `00000000

; tile vacio
DW  `00000000
DW  `00000000
DW  `00000000
DW  `00000000
DW  `00000000
DW  `00000000
DW  `00000000
DW  `00000000

FinTiles: