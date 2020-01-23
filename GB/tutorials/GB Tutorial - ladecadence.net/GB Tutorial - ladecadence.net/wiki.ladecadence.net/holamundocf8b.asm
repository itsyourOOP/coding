; Hola mundo
; David Pello 2010
; ladecadence.net
; Para el tutorial en: 
; http://wiki.ladecadence.net/doku.php?id=tutorial_de_ensamblador

INCLUDE "gbhw.inc"          ; importamos el archivo de definiciones


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
    ld      a, %11100100    ; Colores de paleta desde el mas oscuro al
                            ; más claro, 11 10 01 00
    ld      [rBGP], a       ; escribimos esto en el registro de paleta

    ld      a, 0            ; escribimos 0 en los registros de scroll X e Y
    ld      [rSCX], a       ; con lo que posicionamos la pantalla visible
    ld      [rSCY], a       ; al inicio (arriba a la izq) del fondo.

    call    apaga_LCD       ; llamamos a la rutina que apaga el LCD

    ; cargamos el tile en la memoria de tiles

    ld      hl, TileCara    ; cargamos en HL la dirección de nuestro tile
    ld      de, _VRAM       ; en DE dirección de la memoria de video
    ld      b, 16           ; b = 16, numero de bytes a copiar

.bucle_carga:
    ld      a,[hl]          ; cargamos en A el dato apuntado por HL
    ld      [de], a         ; y lo metemos en la dirección apuntada en DE
    dec     b               ; decrementamos b, b=b-1
    jr      z, .fin_bucle_carga ; si b = 0, terminamos, no queda nada por copiar
    inc     hl              ; incrementamos la dirección a leer de
    inc     de              ; incrementamos la dirección a escribir en
    jr      .bucle_carga    ; seguimos
.fin_bucle_carga:

    ; escribimos nuestro tile, en el mapa de tiles

    ld      hl, _SCRN0      ; en HL la dirección del mapa de fondo
    ld      [hl], $00       ; $00 = el tile 0, nuestro tile.

    ; configuramos y activamos el display
    ld      a, LCDCF_ON|LCDCF_BG8000|LCDCF_BG9800|LCDCF_BGON|LCDCF_OBJ8|LCDCF_OBJOFF
    ld      [rLCDC], a

    ; bucle infinito
bucle:
    halt
    nop
    jr      bucle

; Rutina de apagado del LCD
apaga_LCD:
    ld      a,[rLCDC]
    rlca                    ; Pone el bit alto de LCDC en el flag de acarreo
    ret     nc              ; La pantalla ya está apagada, volver.

    ; esperamos al VBlank, ya que no podemos apagar la pantalla
    ; en otro momento

.espera_VBlank
    ld      a, [rLY]
    cp      145
    jr      nz, .espera_VBlank

    ; estamos en VBlank, apagamos el LCD
    ld      a,[rLCDC]       ; en A, el contenido del LCDC
    res     7,a             ; ponemos a cero el bit 7 (activado del LCD)
    ld      [rLCDC],a       ; escribimos en el registro LCDC el contenido de A

    ret                     ; volvemos

; Datos de nuestro tile
TileCara:
    DB  $7C, $7C, $82, $FE, $82, $D6, $82, $D6
    DB  $82, $FE, $82, $BA, $82, $C6, $7C, $7C
EndTileCara: