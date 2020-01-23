Player_Initialize       equ     $4000
Player_MusicStart       equ     $4003
Player_MusicStop        equ     $4006
Player_SongSelect       equ     $400c
Player_MusicUpdate      equ     $4100
Player_SampleUpdate     equ     $4000

MusicBank               equ     2
SampleBank              equ     3

SongNumber              equ     0       ; 0 - 7



        SECTION "Example",HOME[$150]

FirstTime:
        ld      a,MusicBank             ; Switch to MusicBank
        ld      [rROMB0],a

        call    Player_Initialize       ; Initialize sound registers and
                                        ; player variables on startup

NewSong:
        ld      a,MusicBank             ; Switch to MusicBank
        ld      [rROMB0],a

        call    Player_MusicStart       ; Start music playing

        ld      a,SongNumber            ; Call SongSelect AFTER MusicStart!
        call    Player_SongSelect       ; (Not needed if SongNumber = 0)


FrameLoop:
        ld      c,$08                   ; Waiting
        call    WaitLCDLine

        ld      a,MusicBank             ; Switch to MusicBank
        ld      [rROMB0],a
        call    Player_MusicUpdate      ; Call this once a frame


; ---- Example of sample player timing (needed only if samples used) ---->
        ld      c,$10                   ; Waiting
        call    WaitLCDLine

        ld      a,SampleBank            ; Switch to SampleBank
        ld      [rROMB0],a
        call    Player_SampleUpdate     ; 1st call right after music update

        ; at least $24 LCD lines available for any routines here

        ld      c,$10 + $26
        call    WaitLCDLine
        ld      a,SampleBank            ; Switch to SampleBank
        ld      [rROMB0],a
        call    Player_SampleUpdate     ; 2nd call after $26 LCD lines

        ; at least $24 LCD lines available for any routines here

        ld      c,$10 + $4d
        call    WaitLCDLine
        ld      a,SampleBank            ; Switch to SampleBank
        ld      [rROMB0],a
        call    Player_SampleUpdate     ; 3rd call after $4d LCD lines

        ; at least $24 LCD lines available for any routines here

        ld      c,$10 + $73             ; < $90, don't waste VBlank time
        call    WaitLCDLine
        ld      a,SampleBank            ; Switch to SampleBank
        ld      [rROMB0],a
        call    Player_SampleUpdate     ; 4th call after $73 LCD lines

        ; a few more lines available for any routines here before VBlank

; <---- Example of sample player timing (needed only if samples used) ----


        ld      c,$90                   ; Wait for VBlank
        call    WaitLCDLine

        ; VBlank routines here

        jr      FrameLoop



; If you don't want to worry about the player calls, set up a series of
; rLY=rLYC interrupts, so that every interrupt sets the rLYC register to
; wait for the next player call, and the last interrupt sets rLYC back to
; the first line for looping.
;
; # rLY  CALL                   CPU usage (LCD lines)
; 1 $08  Player_MusicUpdate     1-3
; 2 $10  Player_SampleUpdate    0-1
; 3 $36  Player_SampleUpdate    0-1
; 4 $5d  Player_SampleUpdate    0-1
; 5 $83  Player_SampleUpdate    0-1

;(6 $90  Normal VBlank interrupt routines here if needed)


StopExample:
        ld      a,MusicBank             ; Switch to MusicBank
        ld      [rROMB0],a
        call    Player_MusicStop        ; Stops reading note data and cuts
                                        ; all music notes currently playing
        ret



WaitLCDLine:
        ld      a,[rLY]
        cp      c
        jr      nz,WaitLCDLine
        ret



        SECTION "Music",DATA[$4000],BANK[MusicBank]

        INCBIN "music.bin"              ; player code and music data



        SECTION "Samples",DATA[$4000],BANK[SampleBank]

        INCBIN "music.sam"              ; needed only if samples used



        SECTION "Reserved",BSS[$c7c0]

        ds      $30                     ; $c7c0 - $c7ef for player variables
