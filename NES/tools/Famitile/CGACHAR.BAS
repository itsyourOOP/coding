' This program is public domain.
DEFLNG A-Z
DEF SEG = 0
o = PEEK(&H1F * 4 + 1) * 256& + PEEK(&H1F * 4)
s = PEEK(&H1F * 4 + 3) * 256& + PEEK(&H1F * 4 + 2)
DEF SEG = s
OPEN "cp437.h" FOR OUTPUT AS #1
PRINT #1, "const byte cp437[0x800] = {"
FOR x = -&H400 TO &H3FF
PRINT #1, PEEK(o + x);
IF x <> &H3FF THEN PRINT #1, ","
NEXT x
PRINT #1, "};"
CLOSE
SYSTEM
