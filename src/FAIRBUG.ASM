;*FAIRBUG       +      EDUCATOR
;*R.VATERT             J.EFSTATHIOU
;*FOR 2K PSU
;*9/28/77
XX       ORG       H'8000'
A        EQU       (A1-1)
HIBY     EQU       H'82'     ; HI 8 BIT ADD
LOBY     EQU       H'B9'     ; LO 8 BIT ADD
BAUD     EQU       0
CHRS     EQU       1
BCNT     EQU       2
TEMP     EQU       3
HFLG     EQU       8
CCNT     EQU       5
XFLG     EQU       6
SAVE     EQU       XFLG
CKSM     EQU       7
FCNT     EQU       8
FLG      EQU       9
SIZE     EQU       CKSM
SA       EQU       3
EA       EQU       5
EALO     EQU       XFLG
EAHI     EQU       CCNT
MLO      EQU       H'3EB'    ; END RAM 0-1K
MHI      EQU       H'BEB'    ; END RAM 3-4K
OO       EQU       12        ; IO DISPLAY PORT
PP       EQU       13
RR       EQU       15        ; FLG+H'43'=REGIS
MM       EQU       10        ; FLG+H'43'=MEMOR
HI       EQU       H'F8'
CC       EQU       11
CHR1     EQU       11
CR       EQU       H'0D'
LF       EQU       H'0A'
NUSE     EQU       H'0B'     ; UNUSED PORT ADD
OPOR     EQU       8         ; SERIAL PORT,OUT
IPOR     EQU       8         ; SERIAL PORT,INP
PSTS     EQU       8         ; PARALLEL PORT,S
PPRT     EQU       9         ; PARALLEL PORT,D
;*LOOP TO SAVE R0-R15 IN MEMORY
BGL1     LIS       0
BGLP     LR        IS,A
         LR        A,S
         ST
         LR        A,IS
         INC
         CI        16
         BNZ       BGLP      ; NOT 16,NOT DONE
         LM                  ; BAUD
         LR        BAUD,A    ; SET TEMP AT LEA
         LI        -25
         ADC                 ; SET DC
         LR        K,P       ; PC TO R12-13
         LR        A,KU
         ST                  ; SAVE PC HI
         LR        A,KL
         ST                  ; SAVE PC LO
         LIS       1
         OUTS      OPOR      ; MARK BIT TO STA
         INS       IPOR
         NI        H'20'
         BNZ       EDUL
         LR        Q,DC      ; QU WILL NOW HAV
         INS       IPOR      ; GET BAUD OPTION
         COM
         NI        6
         SR        1
         BZ        BGND
         DCI       (TBX-1)
         ADC
         LM
         LR        BAUD,A    ; BAUD = TABLE VA
         PI        TTD       ; DELAY FOR KEY BD
BGND     JMP       STRT      ; TO CONVERSATIONA
         NOP
;*
TBX      DB        H'EA'     ; 1200 BAUD
         DB        H'A4'     ; 300 BAUD
         DB        6         ; 110 BAUD
EDUL     JMP       (EDUX+2)
;*BOOTSTRAP FORMAT PUNCH SUBROUTINE
;*   START ADDRESS IN DC ON ENTRY
;*   END ADDRESS IN R6-7 ON ENTRY
;*WRITE BLANK LEADER
FPUN     LR        A,EAHI
         COM
         LR        EAHI,A    ; NOW 1'S COMPLIM
         LR        A,EALO
         COM                 ; NEGATIVE
         INC                 ; 2'S COMPLIMENT
         LR        EALO,A
         LR        A,EAHI
         LNK
         LR        EAHI,A    ; NOW 2'S COMPLIM
         LI        H'92'     ; NUMBER OF NULLS
         LR        CKSM,A
         BR        (FPN1+1)
FPN1     LIS       0
         LR        CHRS,A
         PI        TTYO      ; WRITE BLANKS
         DS        CKSM
         BNZ       FPN1      ; CONTINUE BKANKI
         XS        HFLG
         BP        FCON      ; THIS WAS LEADER
;*TRAILER PUNCHED NOW FINISH
         LI        H'94'
         LR        CHRS,A
         PI        TTYO
         BR        BGSV
;*
;*WRITE STARTING ADDRESS
FCON     LI        H'FF'
         LR        CHRS,A
         PI        TTYO
         LI        H'3A'     ; COLON FORMULATO
         LR        CHRS,A
         PI        TTYO
         LI        24        ; LENGTH=24
         LR        HFLG,A
         LR        QL,A      ; OUTPUT BYTE
         PI        FOP2      ; WRITE LENGTH
         LR        A,10
         LR        QL,A
         PI        FOP2      ; OUTPUT HI ADDRE
         LR        A,11
         LR        QL,A
         PI        FOP2      ; OUTPUT LO ADDRE
         LIS       0
         LR        QL,A      ; RECORD TYPE=0
         PI        FOP2
         LR        DC,H
         LI        24
         LR        HFLG,A    ; SET TO 24
         BR        FLOP
;****************
         BR        BGSV      ; START FAIRBUG
;****************
FLOP     PI        FOP1      ; WRITE 2 CHR FR
         LR        H,DC
         DS        HFLG      ; COUNT-1
         BNZ       FLOP      ; NOT 24 YET
;*NOW CHECKSUM
         LR        A,CKSM
         COM
         INC
         LR        QL,A
         LIS       8
         LR        HFLG,A    ; FLAG PLUS FOR 2
         PI        FOP2      ; WRITE 2 CHAR CK
         PI        TTCR      ; TYPE CR/LF
;*NOW CHECK IF ALL MEMORY IS PUNCHED,HI MUST
         LR        A,11      ; LAST LOW ADDRES
         AS        EALO      ; ENDING LOW ADDR
         LR        A,10      ; LAST HI ADDRESS
         LNK
         AS        EAHI
         BNC       FCON      ; NOT DONE YET
         LR        QL,A      ; ZERO
;*
;*NOW WROTE ZERO RECORD PRIOR TO TRAILER
;*
         LI        H'3A'     ; COLON
         LR        CHRS,A
         PI        TTYO      ; PUNCH VCOLON
         LIS       8
         LR        HFLG,A
HERE     PI        FOP2      ; PUNCH 2 ZERO CHAR
         DS        HFLG
         BNZ       HERE      ; REPEAT IF NOT 0
         DS        HFLG      ; SET TO -1
         BR        (FPUN+2)  ; TRAILER
;*TABLE OF DEFAULT DELAY COUNTERS
;*SAVE ROUTINE   TO SAVE THE INITIAL STATE OF
;*     RESTORE SUBROUTINE WILL PUT IT BACK
BGSV     DI                  ; DISABLE INTERRU
         LR        8,A       ; A SAVED IN R8
         LR        A,IS      ; ISAR TO A
         LISU      7
         LISL      4
         LR        I,A       ; ISAR TO R74
         LR        A,9
         LR        I,A       ; R9 TO R75
         LR        J,W       ; STATUS TO R9
         LR        A,10
         LR        I,A       ; R10 TO R76
         LR        A,11
         LR        S,A       ; R11 TO R77
         LR        H,DC      ; DC TO R 10-11
;*CHECK ADDRESS OF SCRATCH RAM
         DCI       MHI
         LM
         COM
         DCI       MHI
         ST                  ; WRITE COMPLEMEN
         DCI       MHI
         XM                  ; XOR SHOULD BE Z
         DCI       MHI
         BZ        BG1       ; IF ZERO SCRATCH
         DCI       MLO       ; NOT 4K CRATCH M
BG1      LR        A,10
         ST
         LR        A,11
         ST                  ; DC NOW IN RAM
         XDC
         LR        H,DC      ; DC1
         XDC
         LR        A,10
         ST                  ; DC1 UPPER
         LR        A,11
         ST                  ; DC1 LOWER
         LR        A,D
         LR        11,A      ; RESTORE R11
         LR        A,S
         LR        10,A      ; RESTIRE 10
         LR        A,9
         LR        D,A       ; STATUS TO R76
         LR        A,S
         LR        9,A
         JMP       BGL1      ; TO FINISH SAVE
;* RESTIRE ROUTINE    RESET REGISTERS THEN RE
REST     LI        H'E7'
         LR        QL,A
         LR        DC,Q      ; SET DC TO RESTO
         LM
         LR        KU,A
         LM
         LR        KL,A
         LR        P,K       ; 12-13 TO PC1
         LM                  ; SKIP MEM
         LM                  ; SKIP AGAIN
         LM
         LR        QU,A      ; DC TO R14
         LM
         LR        QL,A      ; DC TO R15
         XDC
         LR        DC,Q      ; DC0 RESTORE
         XDC
         LM
         LR        QU,A
         LM
         LR        QL,A      ; DC1 NOW IN Q
         LIS       0
;*LOOP TO RESTORE R0-R13 FROM SCRATCH RAM
LOUP     LR        IS,A
         LM
         LR        S,A       ; R0-R13 RESTORE
         LR        A,IS
         INC
         CI        14
         BNZ       LOUP      ; NOT DONE YET
         LISU      7
         LR        A,9
         LR        I,A
         LM
         LR        9,A       ; R14 TO R9
         LM
         LR        DC,Q      ; RESTORE DC
         XDC                 ; DC1 FROM DC0 TO
         LR        QL,A
         LR        A,9       ; RESTORE R14-15
         LR        QU,A
;*NOW DO SR,ISAR,9,A
         LR        A,D       ; GET STATUS
         LR        9,A       ; SR TO J
         LR        W,J       ; STATUS RESTORED
         LR        A,D       ; GET R9
         LR        9,A       ; R9 RESTORED
         LR        A,D       ; GET ISAR
         LR        IS,A      ; ISAR RESTORED
         LR        A,8       ; RESTORE A
         POP                 ; TO USER
;*SUBROUTINE TO OUTBYTE 1 BYTE AS 2  4 BIT AS
;*CKSM IS ACCUMLATED
;*HFLG MUST BE POSITIVE NUMBER
FOP1     LM
         LR        QL,A
;*ENTRY WITH CHARACTER IN REG SAVE
FOP2     LR        K,P       ; SAVE
FLP1     LR        A,HFLG
         COM                 ; SET STATUS
         LR        HFLG,A
         LR        A,QL
         BM        FHI       ; DO HI 4 BITS IF
FLO      SL        4         ; LOSE HI BITS
FHI      SR        4         ; MOVE TO LO 4 BI
;*CONVERT TO ASC 0='30',9='39',A='41',F='46'
         AI        H'30'
         CI        H'39'
         BP        FINT      ; NOT A-F
         AI        7
FINT     LR        CHRS,A
         PI        TTYO      ; TYPE FRAME
         DS        HFLG
         BM        FLP1      ; DO LOW HALF WOR
;*DO CHECKSUM
         LR        A,QL      ; LAST BYTE OUTPU
         AS        CKSM      ; ADD TO PROIR CK
         LR        CKSM,A    ; SAVE UPDATED CK
         PK                  ; RETURN FROM K R
;*FETCH PARAMETERS AFTER LEGIT CODE IS IN
;*MAX FIELD 1 AND 2 IS 4 HEX DIGITS
;*MAX FIELD 3 IS 1 HEX DIGIT
FECH     LIS       3
         LR        FCNT,A    ; PARAMETER COUNT
         LR        IS,A      ; ISAR=3
FA       LIS       4
         LR        CC,A      ; CHAR CNT=4
;*READ CHARACTER
FB       PI        TTYI      ; GET CHAR
         NI        H'7F'
         LR        7,A
         CI        CR
         BZ        CORE      ; CORRECT FIELD B
         PI        TTYO      ; ECHO INPUT CHAR
         LR        A,7
         CI        '-'       ; FIELD SEPARATOR
         BZ        CORN
         CI        '+'
         BZ        CORN
         CI        '='
         BZ        CORT
         CI        H'5B'     ; KILL CHAR?
         BZ        STR1      ; KILL INPUT
;*MUST BE HEX 0-9, OR A-F
         CI        H'2F'     ; LESS THAN ZERO
         BP        FB        ; ERROR IGNORE
         CI        H'46'     ; F?
         BM        FB        ; ERROR IGNORE
         AI        H'D0'
         CI        H'9'
         BP        FOK
         CI        H'10'
         BP        FB        ; ERROT,IGNORE IT
         AI        H'F9'
FOK      DS        CC
         BM        FB        ; FULL FIELD IGNO
;*ZERO LO 4 BITS,THEN ADD THIS DIGIT
         LR        2,A
         LR        A,S
         SL        4
         AS        2
         LR        I,A       ; TO PARAMETER LO
         LIS       1
         NS        CC
         BZ        FB        ; EVEN CHAR,2 IG
         LR        A,D       ; SET ISAR BACK 1
         BR7       FB        ; GET NEXT DIGIT
         LIS       3
         BR        COR7      ; PARAMETERS FULL
CORN     LR        9,A
         BR        CORT
;*CORRECT HEX FIELD ,RIGHT JUSTIFY
;*   IF AB0C THEN 0ABC
;*IF ABCD THEN IT IS OK
;*   IF A00 THEN 000A
;*IF   AB00 THEN 00AB
CORE     LIS       H'D'
         LR        7,A
CORT     LIS       4
         XS       CC
         BZ       COR6       ; NO PARAMETERS
         DS       CC
         BM       COR5       ; FIELD ABCD,AOK
         BNZ      COR1
         LIS      15
         NS       S
         LR       D,A
         LR       A,I
         SL       4
         XS       S
         LR       D,A
         LR       A,S
         SR       4
         BR       COR4
COR1     DS       CC
         BZ       COR2
         LIS      15
         NS       I
         BR       COR3
COR2     LR       A,D
         LR       A,I
COR3     LR       D,A
         LIS      0
COR4     LR       I,A
         LR       A,I
COR5     DS       FCNT
COR6     LR       A,7
         CI       CR
         BZ       COR8
         CI       '='
         BNZ      FA         ; LAST CHAR NOT C
COR8     LR       A,FCNT
         COM
         AI       4
COR7     LR       FCNT,A
         BR       RTN
;*ROUTINE TO FETCH DIRECTIVE,THEN CALL PARAME
;*   THEN GO TO CORRECT PROCESS ROUTINE THRU
AL1      function addr, addr & H'FF'
TBLS     DB     AL1(A1-A)    ; ACCUMULATOR DIS
         DB     AL1(B-A)     ; BINARY DUMP
         DB     AL1(C-A)     ; CHANGE FIELD
         DB     AL1(D-A)     ; DC DISPLAY
         DB     AL1(E-A)     ; EXAMINE
         DB     AL1(F-A)     ; FORMATTED PUNCH
         DB     AL1(G-A)     ; GO TO
         DB     AL1(H-A)     ; HIGH SPEED LOAD
         DB     AL1(I-A)     ; ISAR DISPLAY
         DB     AL1(J-A)     ; 8 BIT PROM PUNC
         DB     AL1(-1)      ; K
         DB     AL1(L-A)     ; LOAD
         DB     AL1(M-A)     ; MEMORY DISPLAY
         DB     AL1(N-A)     ; NEXT DISPLAY
         DB     AL1(O-A)     ; PORT DISPLAY
         DB     AL1(P-A)     ; PC DISPLAY
         DB     AL1(-1)      ; Q
         DB     AL1(R-A)     ; REGISTER DISPLA
         DB     AL1(S-A)     ; STATUS DISPLAY
         DB     AL1(T-A)     ; CLEAR BREAK POI
         DB     AL1(U-A)     ; BREAKPOINT
         DB     AL1(V-A)     ; MOVE BLOCK
         DB     AL1(S-A)     ; W (STATUS) DISP
HXX      DB     AL1(X-A)     ; HEX ARITHMETIC
STRT     LR        A,11      ; FREE R11
         LR        QL,A
STR1     PI        TTCR      ; WRITE CR/LF
         LI        '?'       ; PROMPT CHARACTE
         LR        CHRS,A
         PI        TTYO
;*READ INPUT CHARACTER
READ     PI        TTYI
         LR        3,A       ; SAVE CHAR
         PI        TTYO      ; ECHO CHAR
         LR        A,3
         NI        H'7F'     ; 7 BITS ONLY
         CI        H'40'
         BP        STR1      ; LESS THAN 'A' I
         CI        'X'
         BM        STR1      ; GREATER THAN 'W
         NI        H'1F'     ; SAVE 5 BITS ONL
         DCI       (TBLS-1)
         ADC
         LM                  ; GET TABLE VALUE
RPTC     LR        KL,A      ; SAVE INDEX IN R
         INC                 ; GET STATUS
         BZ        STR1      ; INVALID CONTROL
;*NOW INPUT PARAMETERS IF ANY
         JMP       FECH
RTN      LR        A,QL
         LR        11,A      ; RESTORE R11
;*TEST FOR 2 OR 3 PARAMETERS
;*   MAKE LO ADDRESS START ON 8 BYTE BOUNDRY
;*  MAKE HI ADDRESS END ON 8 BYTE BOUNDRY
         LIS       2
         NS        FCNT
         BZ        RTN1      ; NOT 2 OR 3 PARA
         LR        A,KL
         CI        (X-A)
         BNZ       NHX
         JMP       HEX
NHX      CI        (V-A)
         BZ        MOVE
         LR        A,6
         OI        7
         LR        6,A
         LI        H'F8'
         NS        4
         LR        4,A
         LR        11,A
         LR        A,3
         LR        10,A
;*CALC ADDRESS TO GET TO PROCESS ROUTINE
RTN1     LR        A,KL
         AI        LOBY      ; LO 8 BIT ADDRES
         LR        KL,A
         LI        HIBY      ; HI 8 BIT ADDRES
         LNK
         LR        KU,A
         LR        P,K
         LR        A,QU      ; HI ADDRESS IF N
         POP
;*MOVE MEMORY BLOCK
;*  TO ACCOMPLISH,DO  MXXXX WHERE XXXX IS DE
;*                    VSSSS-EEEE WHERE SSSS I
;*              AND EEEE IS SOURCE ENDING ADD
;*INPUT
;*  R10-11  =DESTINATION START ADDRESS
;*  R3-4     =SOURCE START ADDDRESS
;*  R5-6    =SOURCE END ADDRESS
;*WORK REGISTERS
;*  R10-11   =CURRENT SOURCE BYTE ADDRESS
;*  R5-6     =SOURCE START IF MOVING FROM END
;*           =SOURCE END ADDRESS IF MOVE STAR
MOVE     LR        A,10      ; DESTINATION HI
         COM
         INC
         AS        3         ; SOURCE START HI
         BZ        MBY2      ; EQUAL,TEST LO B
         BM        MEND      ; MOVE BACKWARD
MBGN     LR        DC,H
         LR        A,3
         LR        10,A
         LR        A,4
         LR        11,A
         LIS       0
         BR        MCOM
MBY2     LR        A,11
         COM
         INC
         AS        4
         BP        MBGN
;*CALC LENGTH OF BLOCK
MEND     LR        A,3
         COM
         LR        1,A
         LR        A,4
         COM
         INC
         LR        J,W
         AS        6
         BNC       MXX
         LR        J,W
MXX      AS        11
         LR        11,A
         LR        A,1
         LNK
         LR        W,J
         LNK
         AS        5
         AS        10
         LR        10,A
;*MOVE TO DC THEN IMCREMENT TO ADD 1 TO LENG
         LR        DC,H
;*MOVE SOURCE START ADDRESS TO R10-11
         LR        A,5
         LR        10,A
         LR        A,6
         LR        11,A
;*NOW MOVE SOURCE START TO R5-6 FOR END COMPA
         LR        A,3
         LR        5,A
         LR        A,4
         LR        6,A
         LI        -2        ; MEMORY ADDRESS
MCOM     LR        7,A
         XDC
         LR        DC,H
MLOP     LR        H,DC      ; SAVE ADDRESS FO
         LM
         XDC
         ST
         LR        A,7
         ADC
         XDC
         ADC
;*COMPARE FOR ADDRESS END
         LR        A,10
         XS        5
         BNZ       MLOP
         LR        A,11
         XS        6
         BNZ       MLOP
BXX      JMP       STRT      ; ALL DONE
;*BREAKPOINT----STORE PK IN USER MEMORY +CHAN
;*              ADDTRSS IN FAIRBUG
;*GET BYTE FROM MEMORY AND SAVE ADDRESS AND
BRAK     LI        H'E0'     ; SCRATCH MEM LO
         LR        QL,A
         LR        DC,Q
         LR        A,3
         LR        10,A
         ST
         LR        A,4
         LR        11,A
         ST
;*NOW FETCH USER BYTE
         XDC
         LR        DC,H
         LM
         XDC
         ST
;*NOW STORE PK IN MEMORY
         LR        DC,H
         LIS       12
         ST
;*NOW CHANGE USER K TO RESTORE ADDRESS
         LI        H'FB'
         LR        QL,A
         LR        DC,Q
         LI        H'80'
         ST
         LI        H'AF'
         ST
         BR        BXX       ; TO START
;*RESTORE BYTE TO USER MEMORY
TT       LI        H'E0'
         LR        QL,A
         LR        DC,Q
         LM
         LR        10,A
         LM
         LR        11,A
         LM
         LR        DC,H      ; USER ADDRESS
         ST
         BR        BXX       ; TO START
;*HEX ARITHMETIC
HEX      LR        A,9
         CI        '+'
         BZ        PLUS
;*COMPLIMENT BEFORE ADD=SUBTRACT
         LR        A,6
         COM
         INC                 ; 2'S COMPLIMENT
         LR        J,W
         LR        6,A
         LR        A,5
         COM
         LR        W,J
         LNK
         LR        5,A
;*ADDITION
PLUS     LR        A,4
         AS        6
         LR        4,A
         LR        A,3
         LNK
         AS        5
;*NOW WRITE TO DISPLAY RESULTS
         LR        QL,A
         PI        FOP2
         LR        A,4
         LR        QL,A
V        PI        FOP2
         BR        BXX
;*PRINT ACCUMULATOR
A1       LIS       8
X        BR        I1
;*CLEAR BREAK POINT ENTRY
T        BR        TT
;*CHANGE LAST USED FIELD
C        DS        FCNT
         BM        (V+3)     ; NO PARAMETERS S
         LR        A,FLG
         LR        DC,H
         CI        OO        ; CK FOR PORT
         BNZ       C0        ; NOT PORT CHANGE
         JMP       PORT      ; GO CHANGE PORT
C0       CI        PP
         BM        C2        ; REGISTER CHANGE
         BNZ       C1        ; MEMORY CHANGE 1
         LR        A,3
         ST                  ; PC OR DC 1ST HA
C1       LR        A,4
         ST
         LR        H,DC
         LR        A,11
         BR        (C3+4)
C2       LR        A,11
         LR        IS,A
         AI        H'EF'
         LR        QL,A
         LR        DC,Q
         INC
         LR        A,4
         BP        C4
         ST
         BR        C3
C4       LR        S,A
C3       LR        A,11
         INC
         NI        H'3F'
         LR        QL,A
C5       LI        H'20'     ; BLANK
         LR        CHRS,A
         PI        TTYO
         LIS       (C-A)     ; TABLE VALUE OF
         LR        KL,A
         JMP       (RPTC+1)
C55      LR        A,6
         LR        QL,A
         BR        C5
;*DISPLAY DC
D        LR        10,A      ; HI STORE ADDRES
         LI        H'EB'
         BR        P1
;*EXAMINE THIS ADDRESS
E        LIS       PP
         XS        FLG
         BZ        P2        ; PC OR DC
         BR        N1
;*FORMATTED PUNCH,FOR BOOT LOAD INPUT
F        JMP       FPUN
;*GO TO
G        DS        FCNT
         BM        G1
;*GET NEW PC FROM PARAMETERS
         LR        10,A
         LI        H'E7'
         LR        11,A      ; SET PC MEMORY A
         LR        DC,H
         LR        A,3
         ST                  ; PC UPPER
         LR        A,4
         ST                  ; PC LOWER
G1       JMP       REST      ; RESTORE REGISTE
;*ISAR DISPLAY
I        LI        60        ; REGISTER OF ISA
I1       LR        4,A
         LR        6,A
         LIS       0
         LR        3,A       ; SET T;O REGISTER
         LR        5,A
         LIS       RR
         LR        FLG,A
         BR        R23
;*HIGH SPEED READER LOAD ROUTINE
H        JMP       HIGH
;*PORT PRINT
O        LIS       OO        ; CODE FOR PORT
         BR        R1        ; PRINT PORT DATA
;*BOOT LOAD
L        JMP       LOAD
;*MEMORY PRINT
M        LIS       MM
         BR        R1
;*NEXT--DISPLAY NEXT MEMORY OR REGISTER LOC
N        LR        DC,H
         LIS       1
         ADC
         LR        H,DC
N1       LR        A,10
         LR        3,A
         LR        5,A
         LR        A,11
         LR        4,A
         LR        6,A
         BR        R22
;*PC PRINTD
P        LR        10,A
         LI        H'E7'
P1       AS        4         ; ADD PC0 OR PC1
         AS        4         ; ADDRESS NOW +0
         LR        11,A
         LIS       PP
         LR        FLG,A     ; SET TO P FOR 2
P2       LR        DC,H
         LI        H'20'     ; BLANK
         LR        CHRS,A
         PI        TTYO
         PI        FOP1      ; OP HEX WD,2 CHA
POUT     PI        FOP1      ; OP HEX WD,2 CHA
P3       JMP       STRT
;*S-FETCH STATUS REGISTER
S        LI        62        ; LOC OF STATUS S
         BR        I1
;*PUNCH BINARY TAPE FOR PROM
B        LIS       1
         LR        QL,A
         BR        PPUN
;*8 BIT PROM ENTRY
J        LIS       0         ; CODE FOR 8 BIT=
         BR        (B+1)
;*BREAKPOINT ENTRY FROM TABLE
U        JMP       BRAK      ; TEMP NOP
;*R-ENTRY FOR REGISTER DISPLAY
R        LI        RR
R1       LR        FLG,A     ; SET TO R OR M
         DS        FCNT
         BM        P3        ; NO PARAMETERS G
         BNZ       R2
;*MAKE HI ADDR=LO ADDR
R3       LR        A,3
         LR        5,A
         LR        A,4
         LR        6,A
;*PRINT CR LF BLANK BLANK (R OR M) BLANK XXXX
R2       PI        TTCR      ; WRITE CR/LF
R22      LI        H'20'     ; BLANK
         LR        CHRS,A
         PI        TTYO
         LR        A,FLG
         AI        H'43'
         LR        CHRS,A
         PI        TTYO
         LR        A,3       ; START LO ADDRES
         LR        QL,A
         PI        FOP2
         LR        A,4
         LR        QL,A
         PI        FOP2
R23      LI        '='
         LR        CHRS,A
         PI        TTYO
;*NOW PRINT DATA
R4       LR        A,3
         LR        10,A
         LR        A,4
         LR        11,A
         LR        A,FLG
         CI        OO        ; PORT?
         BZ        PIO       ; GO TO PORT ROUT
         CI        RR        ; TEST FOR REGIST
         BNZ       R5        ; MEMORY LOC
;*
;*REGISRER FETCH IS IT IN SCRATCH OR TEMP MEM
         LR        A,4
         LR        IS,A
         LR        A,IS
         CI        15
         BP        R44       ; NOY REGISTER AD
;*LOAD ISAR AND FETCH
         LR        A,S
         LR        QL,A
R76      PI        FOP2
         BR        R77
;*UPDATE REG 0-15 ADDRESS TO MEM LOC
R44      AI        H'EF'     ; LO RAM-START OF
         LR        11,A
         LR        A,QU      ; HI ADDRESS
         LR        10,A      ; HI RAM ADDRESS
;*FETCH DATA FROM MEMORY
R5       LR        DC,H
;*DATA NOW IN NOW PRINT
R6       PI        FOP1      ; TYPE 2 CHAR FRO
R77      LI        H'20'     ; BLANK
         LR        CHRS,A
         PI        TTYO      ; BLANK
;*CHECK FOR END
         LR        A,4
         LR        11,A      ; SAVE FOR REENTR
         XS        6
         LR        A,3
         LR        10,A      ; SAVE FOR REENTR
         BNZ       R7
         XS        5
         BZ        P3
R7       LR        A,4
;*UPDATE FOR NEXT WORD,LINE HAS MAX OF 8
         INC
         LR        4,A       ; INCREMENT ADDRE
         LR        A,3
         LNK
         LR        3,A       ; INCR HI ADDRESS
         LIS       7
         NS        4
         BZ        R2        ; NEW LINE
         BR        R4        ; CONTINUE THIS L
;*PUNCH HEADER,THEN 256 X SIZE. HI 4 BITS,
;*  THEN HEADWE 256X SIZE LO BITS.
;*  CONTINUE ALTERNATING AS ABOVE UNTIL LAST
;*  HFLG INITIALLY=SIZE,WHEN=0 PUNCH LEADER,W
PPUN     LIS       0
         LR        11,A      ; LOW DC ADDRESS
         LI        H'92'
         LR        CHRS,A
         PI        TTYO
PPA      LIS       3
         LR        HFLG,A    ; NEG SIZE MINUS
         NS        SIZE      ; MASK HI BITS
         LR        SIZE,A
PPB      LR        A,SA
         LR        10,A
         LR        DC,H
         LR        A,SIZE    ; LENGTH OF BLOCK
         LR        4,A
PBLK     LI        H'30'     ; SCRATCH MEMORY
         LR        XFLG,A
PLP      LIS       0
         LR        CHRS,A
         PI        TTYO      ; WRITE BLANK
         DS        XFLG
         BNZ       PLP       ; CONTINUE BLANKS
;*CHECK FOR DONE
         DS        HFLG
         BP        PPC
;*****DONE******
         LI        H'94'
         LR        CHRS,A
PLXX     PI        TTYO      ; PUNCH OFF
         JMP       BGSV
;*POR T DISPLAY
PIO      LI        H'E0'     ; SCRATCH MEMORY
         LR        QL,A
         LR        DC,Q      ; SCRATCH MEMORY
         LR        A,4       ; PORT ADDRESS
         CI        15        ; SHORT PORT ADDR
         BC        INS       ; BUILD INS INSTR
         LI        H'26'     ; LONG INPUT
         ST
         LR        A,4       ; PORT ADDRESS
         ST
PXX      LIS       7
         ST
         LI        H'29'     ; JMP INST
         ST
         LI        H'83'     ; HI ADDRESS
         ST
         LI        H'A3'
         ST
         LR        P0,Q      ; GO EXECUTE
;*SHORT INS
INS      AI        H'A0'
         BR        (PXX-1)
;*OUTPUT 2 RUBOUTS,REGISTER CHRS HAS -1 AFTE
;*    RETURN FROM TTYO OF BLANKS
;* PUNCH BLOCK OF 256
PPC      LIS       0
         LR        XFLG,A
         LR        A,QL
         XS        XFLG
         BZ        EGHT      ; 8 BIT FORMAT
PUNL     LR        A,HFLG
         NS        HFLG
         LM
         BNZ       $+3
         SL        4         ; TO HI 4 BITS
         SR        4         ; TO LO 4 BITS
         XI        H'4F'
         LR        CHRS,A
         PI        TTYO
         DS        XFLG
         BNZ       PUNL
;*CHECK FOR LENGTH GREATER THAN 256
         DS        4         ; NO PAGES/BLOCK
         BP        PPC       ; NEXT 256
;*CHECK IF LOW BYTES ALREADY DONE
         DS        HFLG
         BP        PPB       ; GO DO LOW BYTES
;*UPDATE TO NEXT PAGE
PONT     LR        A,SA
         INC
         AS        SIZE
         LR        SA,A
         XS        EA        ; END PAGE
         BZ        PBLK      ; DO TRAILER
         BR        PPA       ; START NEXT HI B
;*8 BIT FORMAT
EGHT     LM
         LR        CHRS,A
         PI        TTYO      ; OUTPUT BYTE
         DS        XFLG
         BNZ       EGHT      ; NEXT BYTE
         DS        4         ; PAGES PER BLOCK
         BP        PPC       ; START NEXT BLOC
         LR        HFLG,A
         BR        PONT      ; NEXT PAGE
;*  START OF BOOT LOADER
LOAD     LI        H'91'     ; READER ON COMMA
         LR        CHRS,A    ; PASS IT
         PI        TTYO      ; AND TYPE IT
         DCI       TTYI      ; SERIAL INPUT PR
         BR        BOT1      ; SKIP OVER PARAL
HIGH     DCI       PINP
         LIS       0
SLF1     OUTS      PPRT      ; INITIALIZE PARA
         OUTS      PSTS      ; INIT CONTROL PO
         INS       PSTS
         SR        1
         SL        4
         BM        SLF1      ; LOCK IN LOOP TI
BOT1     LIS       0
         LR        XFLG,A    ; CLEAR FIRST X D
         LR        Q,DC      ; SET TO TTYI OR
         LR        CKSM,A
IDLE     PI        CHAR      ; GET HEADER CHAR
         SL        1         ; CLEAR PARITY BI
         SR        1
         CI        H'3A'     ; COLON
         BZ        FORM      ; FORMULATOR FORM
         CI        'S'       ; IS IT AN LOAD A
         BZ        SETA
         CI        '*'       ; IS IT THE END O
         BZ        ENDX
         XI        'X'       ; WELL, IF IT ISN
         BNZ       IDLE
;******   HAVE THE START OF A DATA LINE   ***
DATA     LR        CKSM,A    ; INITIUALIZE CHK
         LIS       H'08'
         LR        CCNT,A    ; INITIALIZE BYTE
         LR        XFLG,A    ; SHOW THAT X HAS
CONT     PI        BYTE
         ST                  ; STORE THE BYTE
         DS        CCNT
         BNZ       CONT
         PI        CHAR      ; GET CHK CHAR FR
         NI        H'3F'     ; MASK TO SIX BIT
         AI        H'D0'     ; ASCII CONVERT--
         BC        $+4       ; CARRY IF IT WAS
         AI        H'39'     ; FINISH CONVERSI
         XS        CKSM      ; MAKE THE COMPAR
         SL        4         ; LO 4 BITS TO HI
         BZ        IDLE      ; IF OK, LET'S GE
;**********     CHK SUM ERROR HALT   ********
SLF2     LI        'C'
         LR        CHRS,A
         PI        TTYO
         LI        'K'
         LR        CHRS,A
         PI        TTYO
         BR        STPP
SETA     PI        BYTE      ; GET NEW LOAD AD
         LR        10,A
         PI        BYTE
         LR        11,A
         LR        DC,H      ; SET THE ADDRESS
         BR        IDLE
ENDX     NS        XFLG      ; HAVE AN *, BUT
         BZ        IDLE      ; MUST BE ONLY AT
;*                            WAS 2A+0 OR 2A
;*********    HALT LOOP FOR WHEN FINISHED  **
STPP     LI        H'93'     ; READER OFF COMM
         LR        CHRS,A    ; PASS
SLF3     JMP       PLXX
         NOP
         NOP
         NOP
         NOP
         NOP
         NOP
FORM     LIS       0
         LR        CKSM,A    ; ZERO CKSM TO START
         COM
         LR        XFLG,A
         PI        BYTE      ; LENGTH OF BLOCK
         LR        CCNT,A
XS       NS        CCNT
         BZ        STPP      ; ZERO RECORD IS
         PI        BYTE      ; ADDRESS HI
         LR        10,A
         PI        BYTE      ; ADDRESS LO
         LR        11,A
         LR        DC,H
         PI        BYTE      ; CODE BYTE
         NS        CHR1
         BNZ       IDLE      ; NOT DATA RECORD
FMLP     PI        BYTE      ; DATA FETCH
         ST
         DS        CCNT      ; LENGTH
         BNZ       FMLP      ; LOOP FOR MORE D
         NOP
         NOP
         NOP
         NOP
         PI        BYTE      ; FETCH CKSM
         LR        A,CKSM
         NS        CKSM      ; SHOULD BE ZERO
         BNZ       SLF2      ; CKSM ERROR
         JMP       IDLE      ; GET NEXT BLOCK
;*PORT CHANGE ROUTINE
PORT     LI        H'DF'
         LR        QL,A
         LR        DC,Q
         LR        A,6
         LR        11,A
         CI        15
         BC        OUTS      ; DO SHORT OUTS
         LI        H'27'
         ST
         LR        A,6
         ST
         LI        H'44'
         ST
         LI        H'27'
         ST
         LR        A,6
JMP      ST
         LI        H'29'
         ST
         LI        H'82'
         ST
         LI        H'F7'     ; TO C55'
         ST
         LI        0
         LR        P0,Q      ; NOW EXECUTE
OUTS     AI        H'B0'
         ST
         LI        H'44'
         ST
         LI        H'B0'
         AS        6
         BR        JMP
         NOP
;***GET A BYTE****
;***       GETS THE BYTE,CONVERTS,AND ADDS TO
BYTE     LR        K,P       ; SAVE PC1
         LIS       2
         LR        HFLG,A    ; SET THE HALF FL
AGAN     LR        A,CHR1
         SL        4
         LR        CHR1,A
         PI        CHAR
         NI        H'3F'     ; MASK TO 6 BITS
         AI        H'D0'     ; ASCII CONVERT--
         BC        $+4
         AI        H'39'     ; NEXT CLEAN UP A
         AS        CHR1
         LR        CHR1,A    ; TEMP STORE
         LR        A,XFLG
         NS        XFLG      ; TEST FOR NEGATI
         BM        AEND      ; NEGATIVE=FORMUL
         LR        A,CHR1
         AS        CKSM      ; ADD NEW CHAR TO
         LR        CKSM,A
AEND     DS        HFLG      ; DECREMENT HALF
         BNZ       AGAN      ; GET 2ND HALF
         LR        A,XFLG
         NS        XFLG
         BP        ADON      ; IF FORMULATOR
         LR        A,CKSM
         AS        CHR1
         LR        CKSM,A
ADON     LR        A,CHR1    ; ONLY HAVE UPPER
         LR        P,K       ; RESTORE PC1
         POP
;********     PARALLEL AND SERIAL INPUT ROUTI
;**      COMMON CALL IS A PUSH TO CHAR
;**      CHAR USES Q TO JUMP TO APPROPRIATE R
CHAR     LR        P0,Q      ; JUMP TO INPUT R
;**   PINP:  GET A CHARACTER FROM PORT 4
;**    TYPICALLY USED WITH TAPE READER, BUT H
;**    DISCIPLINE THAT IS APPLICABLE TO OTHER
;**    LOOKS FOR A CHARACTER READY INPUT, AND
;**    CHARACTER. NEXT CPU GIVES AN ADVANCE P
;**    AFTER THE DEVICE READY INPUT GOES NOT
PINP     INS       PSTS      ; GET A CHAR FROM
         SL        1
         BM        PINP      ; LOOK FOR SPOCKE
         LIS       H'0F'     ; 100 US DELAY AF
         COM
PDLY     INC
         BNZ       PDLY
         INS       PPRT      ; AND NOW GET DAT
         COM
         LR        CHRS,A    ; TEMP STORE CNEW
         LIS       9         ; ADVANCE READER
         OUTS      PSTS
NOSP     INS       PSTS      ; GET READER STAT
         SL        1
         BP        NOSP      ; AND LOOK
         LIS       1
         OUTS      PSTS      ; REMOVE DRIVE PU
         LR        A,CHRS    ; PICK BACK UP TH
         POP
;***TTYI: SERIAL I/P           CHARACTER RETU
;**   REG BCNT HOLDS BIT COUNT   REG CHRS HOL
TTYI     INS       IPOR
         BM        TTYI      ; LOOK FOR START
         LR        A,BAUD    ; GET DELAY COUNT
DLY3     BR        $+2       ; SILLY BRANCH FO
         AI        H'01'
         BNZ       DLY3      ; THIS LOOP OS HA
         INS       IPOR      ; CHECK START BIT
         BM        TTYI
TTD      LIS       9
         LR        BCNT,A    ; SET BIT COUNT,9
LOOP     NI        H'80'     ; MASK TO GET INP
         AS        CHRS      ; (LD'G START BIT
         DS        BCNT
         BM        STOP      ; NEG IF LOOKING
         BZ        LOP2      ; IF LAST BIT, DO
LOP3     SR        1         ; SHIFT ASSEMBLED
LOP2     LR        CHRS,A    ; STORE ASSEMBLED
         LR        A,BAUD    ; START OF FULL B
DLY4     OUTS      NUSE      ; NOP FOR DELAY
         OUTS      NUSE
         OUTS      NUSE
         AI        H'01'     ; INCR WITH A 5US
         BNZ       DLY4
         INS       IPOR      ; GET NEW BIT
         BR        LOOP
STOP     POP
;******* SERIAL OUTPUT ROUTINE  ***********
;**  HAS 1 START, 8 DATA, 2 STOP. USES PORT 0
;**  BAUD RATE IS SET BY A DELAY COUNT IN REG
;**   CALL BY PUTTING CHAR IN REG CHRS, AND S
;**   ROUTINE RETURNS WITH ALL 1'S IN REG CHR
TTCR     LR        K,P
         LIS       CR
         LR        CHRS,A
         PI        TTYO
         LIS       LF
         LR        CHRS,A
         PI        TTYO
         PI        TTYO
         PI        TTYO
         PI        TTYO
         PI        TTYO
         PI        TTYO
         PK                  ; RETURN
TTYO     LIS       H'0B'
         LR        BCNT,A    ; SET BIT COUNT F
         LIS       0
         OUTS      OPOR      ; OUTPUT START BI
;***   DELAY ROUTINE-- 3.3MS FOR 300 BAUD, 9
DLY1     LR        A,BAUD    ; GET DELAY COUNT
DLY2     OUTS      NUSE      ; NOP FOR DELAY
         OUTS      NUSE
         OUTS      NUSE
         AI        H'01'     ; INCR WITH A 5 U
         BNZ       DLY2
         DS        BCNT
         BNZ       DLY5      ; NOW NEXT BI
         POP                 ; ALL FINI,BACK T
DLY5     LIS       1         ; GET CHARACTER
         NS        CHRS      ; MASK OFF ALL BU
         OUTS      OPOR      ; OUTPUT THE MEW
         LR        A,CHRS    ; NOW SHIFT THE C
         SR        1
         AI        H'80'     ; FILL,WITH 1'S F
         LR        CHRS,A
;*
EDUX     BR        DLY1      ; NOW DELAY,THEN
;*
;*
;* EDUCATOR INITIALIZATION
;*
EDUC     LIS       0         ; CLEAR INTERRUPT PORTS
         LR        2,A       ; CLEAR STORE MODE FLAG
         LI        H'7F'
         OUTS      0
         LISU      7
         LISL      0
         INC
         LR        I,A
         LR        A,QU      ; SAVE QU FOR RETURN TO FAIR-
         LR        D,A
;* LOAD ZEROES INTO ADDRESS DISPLAY AND DC
A9       LISU      6
         LISL      3
         LIS       0
A20      LR        D,A
         BR7       A20
         LIS       4
         LR        7,A
;* LOAD MEMORY TO DATA DISPLAY
         DCI       0
         LR        Q,DC
         PI        MTDD
;* SCAN KEYBOARD
A3       PI        SCAN
         LI        H'12'
         XS        0
         BZ        A38       ; BRANCH IF IA KEY
         AI        H'FE'     ; WAS IT H'10'
         BZ        A38       ; BRANCH IF DA KEY
         LIS       6
         LR        6,A       ; LOAD DELAY TIME FOR REPEAT
         LI        H'20'
         LR        5,A       ; LOAD FIRST DELAY TIME FOR R
         LR        A,0
         INC
         BNZ       A3        ; BRANCH IF KEY STILL DOWN
A5       PI        SCAN
         LR        A,0
         INC
         BZ        A5        ; BRANCH IF NO KEYS
         BR        A54
A38      XS        5
         BZ        A53       ; BRANCH IF FIRST DELAY IS OV
         DS        5
         BR        A3
A53      DS        6
         BNZ       A3        ; BRANCH IF DELAY TIME IS OVE
         LIS       6
         LR        6,A       ; RELOAD DELAY TIME FOR REPEA
         BR        A5
;* DETERMINE WHICH KEY WAS DETECTED
A54      LR        H,DC
         LI        H'10'
         NS        0
         BNZ       A6        ; BRANCH IF NOT HEX DIGIT KEY
         JMP       A27
A6       DCI       FUNC
         LIS       15
         NS        0
         LR        0,A
         BZ        A19
A4       LIS       3
         ADC
         DS        0
         BNZ       A4
A19      LR        Q,DC
         LR        DC,H
         LR        P0,Q
FUNC     JMP       DA
         JMP       ENT
         JMP       IA
         JMP       MOVU
         JMP       MOVD
         JMP       STM
         JMP       GO
         JMP       CLR
;* 'ENTER' KEY DETECTED
ENT      LIS       1
         NS        2
         BZ        LA        ; BRANCH IF NOT STORE MODE
         LIS       2
         XS        7
         BZ        A3        ; BRANCH IF NO DIGITS ENTERED
A14      LI        H'FF'     ; ADDRESS DISPLAY TO DC
         ADC
         LISL      4         ; DATA DISPLAY TO MEMORY
         LR        A,I
         SL        4
         XS        S
         ST
         PI        INAD
A25      PI        MTDD
A23      LIS       2         ; SET DIGIT COUNT TO 2
A16      LR        7,A
         BR        A3
LA       LIS       4         ; SET DIGIT COUNT TO 4
         BR        A16
;* 'GO' KEY DETECTED
GO       LI        H'FF'     ; DISPLAY OFF
         OUTS      1
         LI        H'C0'
         OUTS      0
         LIS       0
         OUTS      14        ; INTERRUPT OFF
         PI        ATDC
         LISU      7
         LISL      1
         LR        A,S
         LR        QU,A      ; RESTORE QU FOR FAIR-BUG
         PK
;* 'INCREMENT ADDRESS' KEY DETECTED
IA       PI        INAD      ; INCREMENT ADDRESS DISPLAY
A34      PI        MTDD      ; MEMORY TO DATA DISPLAY
         LIS       1
         NS        2
         BNZ       A23       ; BRANCH IF STORE MODE FLAG
         BR        LA
;* 'DECREMENT ADDESS' KEY DETECTED
DA       PI        DEAD
         PI        ATDC
         BR        A34
;* 'STORE MODE' KEY DETECTED
STM      LIS       1
         NS        2
         BNZ       A26       ; BRANCH IF STORE MODE FLAG
         LIS       1         ; SET STORE MODE FLAG
         XS        2
         LR        2,A
         LISU      7
         LISL      0
         LR        A,S
         OI        H'40'
         LR        S,A       ; SET STORE MODE LIGHT FLAG
         BR        A23
A26      XS        2
         LR        2,A       ; RESET STORE MODE FLAG
         LISU      7
         LISL      0
         LI        H'40'
         XS        S
         LR        S,A       ; RESET STORE MODE LIGHT FLAG
A18      PI        ATDC
         PI        MTDD
         BR        LA
;* 'CLEAR' KEY DETECTED
CLR      LIS       1
         NS        2
         BNZ       A13       ; BRANCH IF STORE MODE FLAG
         LIS       4
         XS        7
         BZ        A24       ; BRANCH IF DIGIT COUNT IS 4
         JMP       A9
A13      LIS       2
         NS        7
         BNZ       A24       ; BRANCH IF DIGIT COUNT IS 2
         LI        H'FF'
         ADC                 ; DECREMENT DATA COUNTER
         BR        A25
;* CHECK IF FUNCTION FLAG SET BEFORE ACCEPTIN
A27      LR        A,0
         LR        3,A
         LIS       0
         XS        7
         BZ        A24       ; BRANCH IF DIGIT COUNT IS 0
         LIS       1
         NS        2
         BNZ       A33       ; BRANCH IF STORE MODE FLAG
         LIS       4
         XS        7
         BNZ       A28       ; BRANCH IF DIGIT COUNT IS NO
         LISL      3
A30      LR        D,A
         BR7       A30
;* LOAD DIGIT TO ADDRESS DISPLAY
A28      LISL      1
         LR        A,D
         LR        I,A
         LR        I,A
         LR        A,D
         LR        I,A
         LR        I,A
         LR        A,D
         LR        I,A
         LR        A,3
         LR        S,A
         PI        ATDC      ; ADDRESS DISPLAY TO DC
         PI        MTDD      ; MEMORY TO DATA DISPLAY
A29      DS        7         ; DECREMENT DIGIT COUNT
A24      JMP       A3
;* LOAD DIGIT TO DATA DISPLAY
A33      LIS       2
         NS        7
         BZ        A35       ; BRANCH IF DIGIT COUNT NOT 2
         LISU      6
         LISL      4         ; CLEAR DATA DISPLAY
         LIS       0
         LR        I,A
         LR        S,A
A35      XS        7
         BZ        A24       ; BRANCH IF DIGIT COUNT IS ZE
         LISL      5         ; DIGIT TO DATA DISPLAY
         LR        A,D
         LR        I,A
         LR        A,3
         LR        S,A
         DS        7
         BR        A24
;* 'MOVE UP' KEY DETECTED
MOVU     LIS       1
         NS        2
         BZ        A24       ; BRANCH IF NOT IN STORE MODE
         LI        H'FF'
         LR        3,A
         ADC
         LR        Q,DC
         ADC
         LR        H,DC
         LR        QL,A
         LR        DC,Q
A12      LM
         ST
         LI        H'FD'
         ADC
         DS        3
         LR        A,3
         XS        11
         BNZ       A12
         LM
         LI        H'2B'
         ST
A17      BR        A18
;* 'MOVE DOWN" KEY DETECTED
MOVD     LIS       1
         NS        2
         BZ        A24       ; BRANCH IF NOT IN STORE MODE
         LM
         LR        0,A
         LI        H'FE'
         ADC
         LR        A,0
         ST
         LM
         LR        H,DC
         LIS       1
         XS        11
         BNZ       MOVD
         BR        A17
;*
;* ADDRESS DISPLAY TO DC SUBROUTINE
;*
ATDC     LISU      6
         LISL      3
A15      LR        A,D
         LR        4,A
         LR        A,D
         SL        4
         XS        4
         BR7       A36
         LR        QU,A
         LR        KU,A
         LR        DC,Q
         POP
A36      LR        QL,A
         LR        KL,A
         BR        A15
;*
;* MEMORY TO DATA DISPLAY SUBROUTINE
;*
MTDD     LISL      4
         LM
         LR        4,A
         SR        4
         LR        I,A
         LIS       15
         NS        4
         LR        S,A
         POP
;*
;* INCREMENT ADDRESS DISPLAY SUBROUTINE
;*
INAD     LISL      3
A21      LR        A,S
         INC
         SL        4
         SR        4
         LR        D,A
         BNZ       A22       ; BRANCH IF DIGIT WAS NOT 'F'
         BR7       A21       ; BRANCH IF NOT MSD
A22      POP
;*
;* DECREMENT ADDRESS DISPLAY SUBROUTINE
;*
DEAD     LISL      3
A31      DS        S
         LR        A,S
         SR        4
         BZ        A32       ; BRANCH IF DIGIT WAS NOT ZER
         LR        D,A       ; 15 TO DISPLAY REG.
         BR7       A31       ; BRANCH IF NOT MSD
A32      POP
;*
;* SCAN KEYBOARD SUBROUTINE
;*
SCAN     LR        K,P
         LR        A,IS
         LISU      5
         LISL      7
         LR        D,A
;* LOAD KEY CODE
A39      LI        H'17'
         LR        0,A
;* LOAD FIRST STROBE
         LI        H'FE'
         LR        S,A
;* OUTPUT STROBE
A40      LIS       15        ; BLANK DISPLAY
         OUTS      1
         LI        H'C0'
         OUTS      0
         LR        A,D
         OUTS      0
;* READ KEYS
         LIS       4
         LR        S,A
         INS       1
         SR        4
         BZ        A43       ; BRANCH IF NO KEY IN THIS CO
         SL        4
A41      BM        A42       ; BRANCH IF KEY IS IN THIS RO
;* GO TO NEXT ROW IF NOT LAST ROW
         DS        0
         DS        S
         BZ        A47       ; BRANCH IF LAST ROW IN THIS
         SL        1
         BR        A41
;* IS THIS FIRST SCAN
A42      LISL      4
         LIS       1
         XS        S
         BNZ       A48       ; BRANCH IF KBD FLAG NOT SET
;* RESET KBD FLAG
         LR        D,A
;* COMPARE TWO SCANS
         LR        A,S
         XS        0
         BZ        A46       ; BRANCH IF SCANS ARE THE SAM
         BR        A45
;* CHANGE KEY CODE FOR NEXT COLUMN
A43      LISL      6
         LI        H'FC'
         AS        0
         LR        0,A
;* SHIFT STROBVE ONE POSITION
A44      LR        A,S
         SL        1
         XI        1
         LR        S,A
;* HAS LAST COLUMN BEEN SCANNED ALREADY
         NI        H'40'
         BNZ       A40       ; BRANCH IF NOT LAST STROBE
;* STROBE 'FF' IN KEY CODE REGISTER
A45      LI        H'FF'
         LR        0,A
;* RESET KBD FLAG
         LISL      4
         LIS       0
         LR        S,A
         BR        A51
;* RESTORE ISAR
A46      LISL      7
         LR        A,S
         LR        IS,A
         LR        P,K
         POP
;* GO TO NEXT ROW
A47      LISL      6
         BR        A44
;* SET KBD FLAG
A48      LR        D,A
;* STORE KEY CODE OF FIRST SCAN
         LR        A,0
         LR        D,A
;* LOAD COUNTERS FOR BOUNCE TIME OF 28MS
A51      PI        DISP      ; RESTORE DISPLAY
         LISU      5
         LISL      2
         LIS       11
         LR        D,A
A49      LI        H'FF'
         LR        S,A
A50      DS        S
         BNZ       A50       ; BRANCH IF COUNTER 1 NOT ZER
         LISL      2
         DS        D
         BNZ       A49       ; BRANCH IF COUNTER 2 NOT ZER
         LISL      4
         LIS       1
         NS        S
         BZ        A46       ; BRANCH IF NOT KBD FLG
         LISL      6
         BR        A39
;*
;* DISPLAY SUBROUTINE
;*
DISP     LISU      6
         LISL      7
         LR        A,1
         LR        D,A       ; SAVE REG. 1
         LR        A,0
         LR        S,A       ; SAVE REG. 0
         LISU      7
         LISL      0
         LIS       1
         LR        0,A
         LR        A,S
         LR        1,A
         LISU      6
         LISL      5
A52      LR        A,1
         XI        H'FF'
         OUTS      0
         LR        A,D
         COM
         SL        4
         SR        4
         OUTS      1
         INS       0
         XS        0
         OUTS      0
         LR        A,0
         SL        1
         LR        0,A
         BR7       A52
         LISL      6
         LR        A,I
         LR        0,A       ; RESTORE REG. 0
         LR        A,S
         LR        1,A       ; RESTORE REG. 1
         POP
;*
;* SONG SUBROUTINE
;*     LOAD STARTING LOCATION OF SONG CONSTAN
;*     LOAD TEMPO INTO R7
;*
SONG     LI        H'40'
         LR        6,A       ; SET NOTE FLAG
         LR        A,7
         LR        5,A       ; STORE TEMPO CONSTANT IN WOR
         LM
         LR        4,A       ; STORE NOTE DURATION CONSTAN
         LR        1,A       ; RETAIN NOTE DURATION CONSTA
         NS        1
         BZ        FINS      ; END OF SONG IF NOTE DURATIO
         LM
         LR        3,A       ; RETAIN NOTE PITCH CONSTANT
         XI        H'7F'
         BNZ       A2        ; BRANCH IF NOT A REST
         LR        6,A       ; CLEAR NOTE FLAG
A2       LI        H'FF'
         LR        9,A       ; LOAD PITCH COUNTER A
         LIS       6
         LR        8,A       ; LOAD PITCH COUNTER B
A55      LR        A,3
         LR        2,A       ; STORE NOTE PITCH CONSTANT I
         INS       8
         XS        6
         OUTS      8         ; TOGGLE OUTPUT PORT
A11      DS        9
         BNZ       A8        ; BRANCH IF PITCH COUNTER A N
         DS        8
         BZ        A7        ; BRANCH IF PITCH COUNTER B I
A8       DS        2         ; DECREMENT NOTE PITCH CONSTA
         BP        A11       ; BRANCH IF NOTE PITCH CONSTA
         BR        A55       ; GO TO TOGGLE OF OUTPUT
A7       DS        2         ; DECR. NOTE PITCH CONSTANT T
         DS        2
         LIS       6
         LR        8,A       ; RELOAD PITCH COUNTER B
         DS        4         ; DECREMENT NOTE DURATION CON
         BNZ       A10       ; BRANCH IF NOTE DURATION CON
         LR        A,1
         LR        4,A       ; RELOAD NOTE DURATION CONSTA
         DS        5         ; DECREMENT REMPO CONSTANT
         BNZ       A11       ; BRANCH IF TEMPO CONSTANT NO
         BR        SONG      ; GO TO NEXT NOTE
A10      LIS       1
         XS        5
         BNZ       A11       ; BRANCH IF TEMPO CONSTANT NO
         DS        2         ; DECR. NOTE PITCH CONSTANT T
         LIS       1
         XS        4
         BNZ       A11       ; BRANCH IF NOTE DURATION CON
         LR        6,A       ; CLEAR NOTE FLAG TO PROVIDE
         BR        A11
FINS     POP
         END
