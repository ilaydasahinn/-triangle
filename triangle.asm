DSEG    SEGMENT PARA 'DATA'
CR      EQU 13
LF      EQU 10
N       DW  ?
a       DW  0
b       DW  0
c       DW  0
MIN     DW 3000 
DIZI    DW  100 DUP(0)
MSG1    DB ' Dizinin eleman sayisini giriniz: ',0
MSG2    DB ' Dizinin elemanini giriniz: ',0
MSG3    DB ' Verilen dizide ucgen olusturabilecek eleman yok.',0
MSG4    DB ' Minimum uc kenar degeri girebilirsiniz. Eleman sayisini tekrar giriniz.',0
MSG5    DB ' Maksimum yuz kenar degeri girebilirsiniz. Eleman sayisini tekrar giriniz.',0
PAR_A   DB ' (',0
VIR     DB ', ',0
PAR_K   DB ') ',0
HATA    DB CR, LF, ' Gecerli bir sayi vermediniz, tekrar giris yapiniz. ',0
HATA_0  DB CR, LF, ' Sifirdan buyuk degerler girmelisiniz. Tekrar giris yapiniz. ',0
HATA_N  DB CR, LF, ' Pozitif bir sayi vermediniz, tekrar giris yapiniz. ',0
HATA_B  DB CR, LF, ' Binden kucuk bir sayi vermelisiniz, tekrar giris yapiniz. ',0
DSEG    ENDS

SSEG    SEGMENT PARA STACK 'STACK'
        DW 32 DUP(?)
SSEG    ENDS

CSEG    SEGMENT PARA 'CODE'
        ASSUME CS:CSEG, DS:DSEG, SS:SSEG
ANA     PROC FAR
        PUSH DS
        XOR AX, AX
        PUSH AX
        MOV AX, DSEG
        MOV DS, AX

        ;Ekrana mesaj bastirma ve kullanicidan bilgi alma.
        MOV AX, OFFSET MSG1
        CALL PUT_STR ; MSG1'i ekrana bastir.
L9:     CALL GETN ; Kullanicidan sayi al ve AX uzerinden dondur.
        MOV N, AX
        CMP N, 3
        JB Less
        CMP N,100
        JA More
        JMP L10

Less:   PUSH AX
        MOV AX, OFFSET MSG4
        CALL PUT_STR
        POP AX 
        JMP L9

More:   PUSH AX
        MOV AX, OFFSET MSG5
        CALL PUT_STR
        POP AX
        JMP L9


L10:    MOV CX, AX ; Dizinin eleman sayisi kadar loop.
        LEA SI, DIZI ; Dizinin adresini SI'ya ata.

L1:     MOV AX, OFFSET MSG2 ; MSG'nin OFFSET'ini(goreceli adres) AX'e ata.
        CALL PUT_STR ; MSG2'yi ekrana bastir.
        CALL GETN ; Kullanicidan sayi al ve AX uzerinden dondur.
        MOV [SI], AX ; SI adresine AX'in degerini ata.
        ADD SI, 2 ; SI'yi 2 ile topla.(Dizinin tipi word oldugu icin.)
        LOOP L1 ; Loop'u basa dondur.

        
        ;Quick Sort
        LEA SI, DIZI ; [SI] pivot
        MOV AX, SI ; first element
        XOR DI, DI 
        ADD DI, SI ;i
        MOV BX, N 
        SHL BX, 1
        ADD BX, SI
        SUB BX, 2 ; j
        MOV DX, BX ;last
        CALL QUICKS

        
        ;Ucgen hesaplari
        CALL TRIANGLE
        CMP MIN, 3000
        JE L7

        MOV AX, OFFSET PAR_A
        CALL PUT_STR
        MOV AX, a
        CALL PUTN
        MOV AX, OFFSET VIR
        CALL PUT_STR
        MOV AX, b
        CALL PUTN
        MOV AX, OFFSET VIR
        CALL PUT_STR
        MOV AX, c
        CALL PUTN
        MOV AX, OFFSET PAR_K
        CALL PUT_STR
        JMP L8
L7:     MOV AX, OFFSET MSG3
        CALL PUT_STR   
L8:    
        RETF
ANA     ENDP


GETC    PROC NEAR ; KLAVYEDEN BASILAN KARAKTERİ AL YAZMACINA ALIR VE EKRANDA GOSTERIR.
        MOV AH, 1h
        INT 21H
        RET
GETC    ENDP


PUTC    PROC NEAR ; AL YAZMACINDAI DEGERI EKRANDA GOSTERIR.
        PUSH AX
        PUSH DX
        MOV DL, AL
        MOV AH,2
        INT 21H
        POP DX
        POP AX
        RET
PUTC    ENDP


GETN    PROC NEAR ; KLAVYEDEN BASILAN SAYIYI OKUR. SONUCU AX YAZMACI UZERINDEN DOLDURUR.
                  ; DX: SAYININ ISARETLI OLUP OLMADIGINI BELIRLER. 1 (+), -1(-) DEMEK.
                  ; BL: HANE BILGISINI TUTAR.
                  ; CX: OKUNAN SAYININ ISLENMESI SIRASINDAKI ARA DEGERI TUTAR.
                  ; AL: KLAVYEDEN OKUNAN KARAKTERI TUTAR. (ASCII)
                  ; AX: ZATEN DONUS DEGERI OLARAK DEGISMEK DURUMUNDADIR.
                  ; AX HARICI YAZMACLARIN ONCEKI DEGERLERI KORUNMALIDIR.
        PUSH BX
        PUSH CX
        PUSH DX
GETN_START:
        MOV DX, 1 ; SAYININ SIMDILIK (+) OLDUGUNU VARSAYALIM.
        XOR BX, BX; OKUMA YAPMADI, HANE 0 OLUR.
        XOR CX, CX; ARA TOPLAM DEGERI DE 0'DIR.
NEW:
        CALL GETC ;KLAVYEDEN ILK DEGERI AL'YE OKU.
        CMP AL, CR
        JE FIN_READ; ENTER TUSUNA BASILMIS ISE OKUMA BITER.
        CMP AL, '-'; AL '-' MI GELDI??
        JE ERROR2 ; GELEN 0-9 ARASINDA BIR SAYI MI?

CTRL_NUM:
        CMP AL, '0' ; SAYININ 0-9 ARASINDA OLDUGUNU KONTROL ET.
        JB ERROR
        CMP AL, '9'
        JA ERROR ; DEGIL ISE HATA MESAJI VERILECEK.
        SUB AL, '0' ; RAKAM ALINDI. HANEYI TOPLAMA DAHIL ET.
        MOV BL, AL; BL'YE OKUNAN HANEYI KOY.
        MOV AX, 10; HANEYI EKLERKEN *10 YAPILACAK.
        PUSH DX ; MUL KOMUTU DX'I BOZAR, ISARET ICIN SAKLANMALI.
        MUL CX ; DX:AX = AX*CX
        POP DX ; ISARETI GERI AL
        MOV CX, AX ; DX'DEKI ARA DEGER *10 YAPILDI.
        ADD CX, BX ; OKUNAN HANEYI ARA DEGERE EKLE.
        CMP CX, 999
        JA ERROR3
        CMP CX, 0
        JE ERROR4
        JMP NEW ; KLAVYEDEN YENI BASILAN DDEGERI AL.

ERROR:
        MOV AX, OFFSET HATA
        CALL PUT_STR ; HATA MESAJINI GOSTER.
        JMP GETN_START ; O ANA KADAR OKUNANLARI UNUT, YENIDEN SAYI ALMAYA BASLA.
ERROR2:
        MOV AX, OFFSET HATA_N
        CALL PUT_STR ; HATA MESAJINI GOSTER.
        JMP GETN_START ; O ANA KADAR OKUNANLARI UNUT, YENIDEN SAYI ALMAYA BASLA.
ERROR3:
        MOV AX, OFFSET HATA_B
        CALL PUT_STR ; HATA MESAJINI GOSTER.
        JMP GETN_START ; O ANA KADAR OKUNANLARI UNUT, YENIDEN SAYI ALMAYA BASLA.
ERROR4:
        MOV AX, OFFSET HATA_0
        CALL PUT_STR ; HATA MESAJINI GOSTER.
        JMP GETN_START ; O ANA KADAR OKUNANLARI UNUT, YENIDEN SAYI ALMAYA BASLA.

FIN_READ:
        MOV AX, CX ; SONUC AX UZERINDEN DONECEK.
        CMP DX, 1 ; ISARETE GORE SAYIYI AYARLAMAK LAZIM.
        JE FIN_GETN

FIN_GETN:
        POP DX
        POP CX
        POP DX
        RET
GETN    ENDP


PUTN    PROC NEAR ; AX'DE BULUNAN SAYIYI ONLUK TABANDA HANE HANE YAZDIRIR.
                ; CX: HANELERİ 10'A BOLEREK BULACAGIZ. CX = 10 OLACAK.
                ; DX: 32 BOLMEDE ISLEME DAHIL OLACAK. SONUCU ETKILEMESIN DIYE 0 OLMALI.
        PUSH CX
        PUSH DX
        XOR DX, DX; DX 32 VIT BOLMEDE SONUCU ETKILEMESIN DIYE 0 OLMALI.
        PUSH DX ; HANELERI ASCII KARAKTER OLARAK YIGINDA SAKLAYACAGIZ.
                ; KAC HANE ALDIGIMIZI BILMEDIGIMIZ ICIN YIGINA 0 DEGERI KOYUP ONU ALANA DEK DEVAM EDELIM.
                
        MOV CX, 10 ; CX = 10

CALC_DIGITS:
        DIV CX ; DX:AX = AX/CX, AX = BOLUM, DX = KALAN
        ADD DX, '0' ; KALAN DEGERINI ASCII OLARAK BUL.
        PUSH DX ; YIGINA SAKLA.
        XOR DX, DX ; DX = 0
        CMP AX, 0 ; BOLEN 0 KALDIYSA SAYININ ISLENMESI BITTI DEMEKTIR.
        JNE CALC_DIGITS ; ISLEMI TEKRARLA.
DISP_LOOP:
                ; YAZILACAK TUM HANELER YIGINDA. EN ANLAMLI HANE EN USTTE
                ; EN AZ ANLAMLI HANE EN ALTTA VE ONUN ALTINDA DA SONA VARDIGIMIZI
                ; ANLAMAK ICIN 0 DEGERI VAR.
        POP AX ; SIRAYLA DEGERLERI YIGINDAN ALALIM.
        CMP AX, 0 ; AX = 0 OLURSA SONA GELDIK DEMEKTIR.
        JE END_DISP_LOOP
        CALL PUTC ; AL'DEKI ASCII DEGERI YAZ.
        JMP DISP_LOOP ; ISLEME DEVAM.
END_DISP_LOOP:
        POP DX
        POP CX
        RET
PUTN    ENDP


PUT_STR PROC NEAR ; AX'DE ADRESI VERILEN SONUNDA 0 OLAN DIZGEYI
                  ; KARAKTER KARAKTER YAZDIRIR.
                  ; BX DIZGEYE INDIS OLARAK KULLANILIR.
                  ; ONCEKI DEGER SAKLANMALIDIR.
        PUSH BX
        MOV BX, AX ; ADRESI BX'E AL
        MOV AL, BYTE PTR[BX] ; AL'DE ILK KARAKTER VAR.
PUT_LOOP:
        CMP AL,0 ; 0 GELDI ISE DIZGE SONA ERDI DEMEKTIR.
        JE PUT_FIN
        CALL PUTC
        INC BX
        MOV AL, BYTE PTR[BX]
        JMP PUT_LOOP
PUT_FIN:
        POP BX
        RET
PUT_STR ENDP


QUICKS  PROC NEAR ; PİVOT - SI
                  ; I - DI
                  ; J - BX
                  ; FIRST - AX
                  ; LAST - DX

        CMP AX, DX ; IF(FIRST < LAST) AX=2, DX=16
        JNB L2
        MOV SI, AX ; PIVOT = FIRST
        MOV DI, AX ; I = FIRST
        MOV BX, DX ; J = LAST

W1:     CMP DI, BX ; WHILE(I < J)
        JNB L5

W2:     MOV CX, [DI] ; [DI]=5
        CMP CX, [SI] ; WHILE(ARR[I]<= ARR[PIVOT] &&.. [SI]=5
        JA W3
        CMP DI, DX ; ..&& I<LAST DI=2, DX=16
        JNB W3
        ADD DI, 2 ; I++ DI=4
        JMP W2

W3:     MOV CX, [BX] ;[BX]= 7
        CMP CX, [SI] ; WHILE(ARR[J]>ARR[PIVOT]) , [SI]=5 
        JNA L4
        SUB BX, 2 ; BX=14
        JMP W3

L4:     CMP DI, BX ; IF(I < J) DI=4, BX=14
        JNB L5
        MOV CX, [DI] ; CX=[DI]
        XCHG [BX], CX ; [BX] = [DI], CX=[BX]
        MOV [DI], CX ; [DI] = [BX]

        JMP W1

L5:     MOV CX, [SI] ; CX=[SI]
        XCHG [BX], CX ; CX=[BX], [BX]=[SI]
        MOV [SI], CX ; [SI] = [BX]

        PUSH DX
        MOV DX, BX
        SUB DX, 2
        CALL QUICKS

        POP DX
        MOV AX, BX
        ADD AX, 2
        CALL QUICKS


L2:     RET
QUICKS  ENDP


TRIANGLE PROC NEAR ; I = SI
                   ; J = DI
                   ; K = BX

        LEA SI, DIZI
        MOV AX, [SI]
        MOV a, AX 
        MOV AX, [SI +2]
        MOV b, AX 
        MOV AX, [SI +4]
        MOV c, AX 
        MOV CX, N
        SHL CX, 1
        ADD CX, SI
        SUB CX, 2

        MOV AX, CX
        SUB AX, 4

        MOV DX, CX
        SUB DX,2


LOOP1:  CMP SI, AX
        JA FINISH

        MOV DI, SI
        ADD DI, 2

LOOP2:  CMP DI, DX
        JA LOOP1_2

        MOV BX, DI
        ADD BX, 2

LOOP3:  CMP BX, CX
        JA LOOP2_2

        
        MOV BP, [SI]
        ADD BP, [DI]
        CMP BP, [BX]
        JNA LOOP3_2

        
        MOV BP, [SI]
        ADD BP, [DI]
        ADD BP, [BX]
        CMP BP, MIN
        JNB LOOP3_2

        
        MOV BP, [SI]
        ADD BP, [DI]
        ADD BP, [BX]
        MOV MIN, BP
        MOV BP, [SI]
        MOV a, BP
        MOV BP, [DI]
        MOV b, BP
        MOV BP, [BX]
        MOV c, BP
        JMP LOOP3_2

LOOP1_2: ADD SI, 2
         JMP LOOP1
LOOP2_2: ADD DI, 2
         JMP LOOP2
LOOP3_2: ADD BX, 2
         JMP LOOP3


FINISH:
         RET
TRIANGLE ENDP


CSEG    ENDS
        END ANA





