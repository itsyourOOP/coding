; Hola Bancos
; David Pello 2010
; ladecadence.net
; Para el tutorial en: 
; http://wiki.ladecadence.net/doku.php?id=tutorial_de_ensamblador

INCLUDE "gbhw.inc"          ; importamos el archivo de definiciones

; Constantes
_TILES_FUENTE       EQU     $9200       ; la segunda tabla de tiles va de $8800
                                        ; a $97FF y los tiles van numerados
                                        ; de -128 a 127, con lo que el tile 0
                                        ; está en $9000. Si le sumo 32 tiles
                                        ; (32*2bytes*8lineas) y coloco ahi
                                        ; el primer caracter (espacio), me
                                        ; coinciden con el codigo ASCII
                                        ; y puedo usar cadenas de texto tal cual
; Variables
_BANCO              EQU     _RAM        ; guardaremos el banco actual
_PAD                EQU     _RAM+1      ; estado del pad

; interrupción de vBlank
SECTION "Vblank",ROM0[$0040]
    reti     ; no hacemos nada, volvemos

; El programa comienza aqui:
SECTION "start",ROM0[$0100]
    nop
    jp      inicio

; Cabecera de la ROM (Macro definido en gbhw.inc)
; define una rom con mapper MBC1, de 64K y con RAM
    ROM_HEADER  ROM_MBC1_RAM_BAT, ROM_SIZE_64KBYTE, RAM_SIZE_8KBYTE

; aqui empieza nuestro programa
inicio:
    nop
    di                      ; deshabilita las interrupciones
    ld      sp, $ffff       ; apuntamos la pila al tope de la ram

inicializacion:

    ; iniciamos las variables
    ld      a, 1
    ld      [_BANCO], a

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

    ; cargamos los tiles en la segunda tabla de la memoria de tiles
    ld      hl, Fuente1     ; cargamos en HL la dirección de nuestro tile
    ld      de, _TILES_FUENTE       ; en DE dirección de la tabla
    ld      bc, EndFuente1-Fuente1  ; número de bytes a copiar

    call    CopiaMemoria

    ; limpiamos el mapa
    ld      de, _SCRN0      ; mapa 0
    ld      bc, 32*32
    ld      l, 0            ; tile vacio (espacio)
    call    RellenaMemoria

    ; bien, tenemos todo el mapa de tiles cargado
    ; ahora limpiamos la memoria de sprites
    ld      de, _OAMRAM     ; memoria de atributos de sprites
    ld      bc, 40*4        ; 40 sprites x 4 bytes cada uno
    ld      l, 0            ; lo vamos a poner todo a cero, asi los sprites
    call    RellenaMemoria  ; no usados quedan fuera de pantalla

    ld      b, 1
    ld      c, 1
    ld      hl, $4000
    call    ImprimeCadena

    ld      b, 1
    ld      c, 16
    ld      hl, Info
    call    ImprimeCadena

    ; vamos a leer el dato guardado
    ld      a, $0A
    ld      [$0000], a      ; activamos la RAM externa

    ld      a, [$A000]      ; cargamos en a el dato
    ld      b, a            ; lo guardamos

    ld      a, $00
    ld      [$0000], a      ; desactivamos la RAM externa

    ; lo imprimimos 
    ld      l, b
    ld      b, 18
    ld      c, 16
    call    ImprimeNumero

    ; configuramos y activamos el display
    ld      a, LCDCF_ON|LCDCF_BG8800|LCDCF_BG9800|LCDCF_BGON|LCDCF_OBJ8
    ld      [rLCDC], a

; bucle principal
control:
    ; leemos el pad
    call    lee_pad

    ; Ahora cambiamos al banco 1
    ld      a, [_PAD]
    and     %00000001       ; Boton A
    call    nz, Banco1

    ; O al banco 2
    ld      a, [_PAD]
    and     %00000010       ; Boton B
    call    nz, Banco2

    ; Guarda en la RAM externa
    ld      a, [_PAD]
    and     %000000100       ; Boton Select
    call    nz, Guarda


    ld      bc, 15000
    call    Retardo
    ; volvemos a empezar
    jr      control


; Cambia al banco 1 y muestra el mensaje
Banco1:
    ; escribimos el banco que queremos en la dirección de selección de bancos
    ld      hl, $2000
    ld      [hl], 01        ; banco 1

    ; guardamos en la variable
    ld      a, 01
    ld      [_BANCO], a

    ; mostramos el mensaje que reside al inicio del banco superior
    call    EsperaVBlank
    ld      b, 1
    ld      c, 1
    ld      hl, $4000
    call    ImprimeCadena

    ; hemos cambiado, borrar el mensaje de guardado si lo hay
    ld      b, 1
    ld      c, 12
    ld      hl, Limpia
    call    ImprimeCadena


    ret

; Cambia al banco 2 y muestra el mensaje
Banco2:
    ; lo mismo pero seleccionamos el banco 2
    ld      hl, $2000
    ld      [hl], 02

    ld      a, 02
    ld      [_BANCO], a

    call    EsperaVBlank
    ld      b, 1
    ld      c, 1
    ld      hl, $4000
    call    ImprimeCadena

    ; hemos cambiado, borrar el mensaje de guardado si lo hay
    ld      b, 1
    ld      c, 12
    ld      hl, Limpia
    call    ImprimeCadena

    ret

; Guarda el número de banco actual en la memoria del cartucho
Guarda:
    ; primero activamos la SRAM externa
    ld      a, $0A          ; $0A, activar
    ld      [$0000], a      ; 

    ;escribimos el dato en el primer byte de la ram externa
    ld      a, [_BANCO]
    ld      [$A000], a

    ; desactivamos la SRAM
    ld      a, $00          ; $00, desactivar
    ld      [$0000], a      ; 

    ; lo imprimimos
    ld      a, [_BANCO]
    ld      l,  a
    ld      b, 18
    ld      c, 16
    call    ImprimeNumero

    ; mostramos mensaje
    ld      b, 1
    ld      c, 12
    ld      hl, Guardado
    call    ImprimeCadena

    ret



; Imprime una cadena de texto en el fondo (cadena acabada en 0)
; Parámetros:
; b - coordenada x
; c - coordenada y
; hl - dirección de la cadena
ImprimeCadena:
    push    hl          ; guardamos hl pa luego
    ; vamos a usar hl ahora para los cálculos del destino
    ld      hl, _SCRN0
    ; vamos a la posición y
    ld      a, c
    cp      0
    jr      z, .fin_y   ; si es cero, vamos a por las x
.avz_y:
    ld      de, 32
    add     hl, de      ; avanzamos en las Y por lo tanto 32 tiles
    dec     a
    jr      nz, .avz_y
.fin_y:
; vamos a por las x
    ld      a, b
    cp      0
    jr      z, .fin_x   ; si es cero, terminamos
.avz_x:
    inc     hl
    dec     a
    jr      nz, .avz_x
.fin_x:
    push    hl
    pop     de          ; de = hl
; bien, tenemos en 'de' la posición de memoria donde escribir la cadena
; vamos a ello
    pop     hl          ; rescatamos hl de la pila
.imprime:
    ld      a, [hl]     ; cargamos un carácter
    cp      0
    ret     z           ; si es cero, volvemos
    ld      [de], a     ; si no, imprimimos
    inc     de          ; siguiente 
    inc     hl
    jr      .imprime
    ret

; Imprime un numero (unidad)
; Parámetros
; b - posicion x
; c - posición y
; l - numero a imprimir (0-9)
ImprimeNumero:
    push    hl          ; guardamos hl pa luego
    ; vamos a usar hl ahora para los cálculos del destino
    ld      hl, _SCRN0
    ; vamos a la posición y
    ld      a, c
    cp      0
    jr      z, .fin_y   ; si es cero, vamos a por las x
.avz_y:
    ld      de, 32
    add     hl, de      ; avanzamos en las Y por lo tanto 32 tiles
    dec     a
    jr      nz, .avz_y
.fin_y:
; vamos a por las x
    ld      a, b
    cp      0
    jr      z, .fin_x   ; si es cero, terminamos
.avz_x:
    inc     hl
    dec     a
    jr      nz, .avz_x
.fin_x:
    push    hl
    pop     de          ; de = hl
; bien, tenemos en 'de' la posición de memoria donde escribir el numero
; vamos a ello
    pop     hl          ; rescatamos el número
    ld      a, l
    and     $0F         ; solo nos interesa la parte baja

    add     a, 48       ; el primer caracter es 32 el espacio, el cero está a +16
    ld      [de], a
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
Retardo:
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


Limpia:
    DB "                     ",0
Info:
    DB "Banco guardado: ", 0
Guardado:
    DB "Guardado correcto", 0

; Fuente
; ========================================================================
INCLUDE "fuente1.agb"

; Datos del primer Banco
; ========================================================================
SECTION "Banco1",CODE[$4000],BANK[1]
    DB "Soy el banco 1",0

; Datos del segundo Banco
; ========================================================================
SECTION "Banco2",CODE[$4000],BANK[2]
    DB "Soy el banco 2",0