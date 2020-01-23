Player_Initialize       equ     $4000
Player_MusicStart       equ     $4003
Player_MusicStop        equ     $4006
Player_SongSelect       equ     $400c
Player_MusicUpdate      equ     $4100

MusicBank               equ     1

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
        ld      c,$10                   ; Waiting
        call    WaitLCDLine

        ld      a,MusicBank             ; Switch to MusicBank
        ld      [rROMB0],a
        call    Player_MusicUpdate      ; Call this once a frame

        ;call   YourProgram

        ld      c,$90                   ; Wait for VBlank
        call    WaitLCDLine

        ; VBlank routines here

        jr      FrameLoop



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



        SECTION "Reserved",BSS[$c7c0]

        ds      $30                     ; $c7c0 - $c7ef for player variables
