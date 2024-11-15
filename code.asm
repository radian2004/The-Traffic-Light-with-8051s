$NOMOD51
$INCLUDE (8051.MCU)
;====================================================================
BUFFER EQU 030H	
		;BUFFER co dia chi la 030H
;====================================================================
;                    RESET and INTERRUPT VECTORS
;====================================================================
      org   0000h
      jmp   Start
      
      ORG 0003h	
      LJMP PSRS	
            
      ORG 000Bh	
      LJMP T0_ISR
      
      ORG 0013h
      LJMP ST
            
      ORG 001BH
      LJMP T1_ISR
      
      
;====================================================================
;                           CODE SEGMENT
;====================================================================
      org   0100h           
;====================================================================
;                         CHUAN BI DU LIEU
;====================================================================
Start: 
                                            
      CLR P1.2			;clear P2.0, clear R1 co nghia la clear den do cua cum 12
      CLR P1.3  		;clear P2.3, clear G2 co nghia la clea den xanh cua cum 34   MOV R5,#15 => cho R5 = 15
      CLR P1.6
      CLR P2.4
      CLR P2.5
      CLR P2.6
      MOV R5, #015d
      MOV R7, #015d		;cho R7 = 15
      MOV R1, #010d		;cho R1 = 10
      MOV A, #0   		;cho A = 0
      MOV 41H, #2
      MOV 40H, #0
      MOV R0, #52   		;cho R0 = 52, cho dau tien la 53 vi dia chi cua so 1 tren keypad la 53

;====================================================================
;                  GAN SO VAO O NHO DE KEYPAB TRO VAO  
;====================================================================
BACK :
      MOV @R0,A			;@52 = 0, có nghia là o nho co dia chi 52 co gia tri bang 0,nhung toi dia chi 53 thi moi toi dia chi trong keypad
      INC R0			;tang r0 co nghia la tang dia chi @r0
      INC A			;tang A co nghia la tang gia tri se duoc gan vao thanh ghi co dia chi @R0
      DJNZ R1, BACK		;giam gia tri thanh ghi r1 di 1, neu r1 khac 1 nhay toi Back     
  
;====================================================================
;                            SETUP 2 TIMER (0,05s)
;====================================================================
      MOV TMOD, #011H		;bat timer 1 va timer 0 che do 1
      MOV TH0, #03CH		;03B0h 
      MOV TL0, #0B0H
      MOV TH1, #03CH		;3CB0h
      MOV TL1, #0B0H 
      MOV IE, #08FH 		;Turn on interrupt of timer
   
   
;====================================================================
;                   DAT GIA TRI MAC DINH CHO DEN DO
;====================================================================
      MOV R1, #00000001B	; r1 = 1
      MOV R2, #00000101B	; Red light = 15s
      LJMP SUL34		;nhay SUL34

;====================================================================      
SUL12: ; HAM SETUP LED
      DJNZ 41H,SUL1			
      MOV A,@R0 ; cai dat gia tri ung voi R0 cho vao A
      MOV R2,A  ; HANG DON VI
      MOV 41H, #2
      LJMP SUT
SUL1:
      MOV A,@R0
      MOV R1,A  ;HANG CHUC
      LJMP SUT
;======================================================================
; BUOC TINH TOAN CAC GIA TRI CUA CAC DEN KHAC TU DEN DO SAU DO LUU LAI 
;======================================================================
SUL34:
      MOV R0, #BUFFER		;R0 nhan gia tri cua buffer = 30H, R0 = 30h
      MOV A, R1			;A nhan gia tri cua R1 = 00000001B  = 1
      MOV @R0, A		;o nho co dia chi la R0 nhan gia tri cua A, dia chi 30h co gia tri la a
      INC R0			;Tang gia tri R0, 31h
      MOV A, R2			;A nhan gia tri cua R2
      MOV @R0, A		;o nho co dia chi la R0 nhan gia tri cua A
      INC R0			;tang gia tri cua r0 len 1 gia tri
      MOV A, R1  		;A nhan gia tri cua thanh ghi R1 (
      MOV B, #00001010B		;B = 00001010B = 10
      MUL AB			;thi phan bit thap se duoc gan cho A con phan bit cao se duoc gan cho thanh ghi b, A =10
      ADD A, R2			;cong them r2 thanh so co hai chu so voi r1 la chu so hang chuc, r2 la chu so hang don vi => lay A - 64 = 12
      SUBB A, #00000011B	;lay A - 3 = 9
      MOV B, #00001010B		;B = 10
      DIV AB			;lay A chia B la 10/10 thi A = 1 va B = 0
      MOV R3, A			;r3 = 10000001b
      MOV @R0, A		;dia chi tiep theo r3 = 10000001b
      INC R0			;tang them dia chi tiep thep
      MOV A,B			;A = 9
      MOV R4, A			; R4 = A = 11000010b
      MOV @R0, A		; dia chi tiep theo = 11000010b
   
   
;=====================================================================
;                         VONG LAP CT QUET LED
;=====================================================================
Loop:
      LCALL Display
      SETB TR0			;bat co tr0 de timer bat dau chay
      SETB TR1   
      
      MOV R0, 40H
      CJNE R0, #1, Loop 	;neu khong duoc nhan thi nhay toi ham loop nhu bth con neu duoc nhan thi xoa timer va cung quay lai ham loop
      CLR  TR0
      CLR TR1 
      JMP Loop
  
;======================================================================
;                              HAM DELAY
;====================================================================== 
DL:
      MOV R6, #100d
Lap:
      DJNZ R6, Lap
      RET     
      
;======================================================================
;                    KHI NGAT CUAT TIMER 0 XAY RA  
;======================================================================
T0_ISR:	
      CLR TR0  
      DJNZ R7, RT
      MOV R7, #15
      
      
;======================================================================
;    DEM THOI GIAN DEN DO VA SAU DO CAI DAT CHO DEN XANH KE TIEP
;======================================================================
DO: 
      JB P1.2, XANH
      CJNE R1, #00000000B, NEXT_11
      CJNE R2, #00000001B,X1      ;so voi 1
      MOV R2, #00001001B
      JMP NEXT_12
   NEXT_11:      
      CJNE R2, #00000000B,X1      ;so voi 0
      MOV R2, #00001001B
      CJNE R1, #00000000B,X2
   NEXT_12:
      SETB P1.6
      CLR P1.0			  ;bat den xanh
      SETB P1.2			  ;tat den do			
      MOV R0, #51		  ; 51 = 33H
      MOV A, @R0		  ;R1 co dia chi la 51
      MOV R2, A
      MOV R0, #50
      MOV A, @R0
      MOV R1, A
      LJMP RT
      
      
;======================================================================
;   DEM THOI GIAN DEN XANH VA SAU DO CAI DAT CHO DEN VANG KE TIEP
;======================================================================
XANH:
      JB P1.0, VANG
      CJNE R1, #00000000B, NEXT_21
      CJNE R2, #00000001B,X1      ;so voi 1
      MOV R2, #00001001B
      JMP NEXT_22
   NEXT_21:
      CJNE R2, #00000000B,X1
      MOV R2, #00001001B
      CJNE R1, #00000000B,X2
   NEXT_22:
      CLR P1.1
      SETB P1.6
      SETB P1.0
      MOV R2, #00000011B
      MOV R1, #00000000B
      LJMP RT
      
      
;=======================================================================
;             DEM THOI GIAN DEN VANG VA CAI DAT DEN DO
;=======================================================================
VANG:
      CJNE R2, #00000001B,X1
      MOV R0, #49
      MOV A, @R0
      MOV R2, A
      MOV R0, #48
      MOV A, @R0
      MOV R1, A
      CLR P1.2
      CLR P1.6
      SETB P1.1
      LJMP RT
      
      
;=======================================================================
;                 CAC BUOC DUNG DE GIAM GIA TRI GIAY
;=======================================================================
X1:
      DEC R2
      LJMP RT
X2:
      DEC R1
      
;=======================================================================
;                        LAP LAI THOI GIAN TIMER
;=======================================================================
RT: 
      SETB TR0
      RETI
      
;=======================================================================
;                     KHI NGAT CUAT TIMER 1 XAY RA 
;======================================================================= 
T1_ISR:
      CLR TR1 
      DJNZ R5, RT1
      MOV R5, #015d
          
;=======================================================================
;    DEM THOI GIAN DEN XANH VA SAU DO CAI DAT CHO DEN VANG KE TIEP
;=======================================================================
XANH1:
      JB P1.3, VANG1
      CJNE R3, #00000000B, NEXT_31
      CJNE R4, #00000001B,X3      ;so voi 1
      MOV R4, #00001001B
      JMP NEXT_32
   NEXT_31:
      CJNE R4, #00000000B,X3
      MOV R4, #00001001B
      CJNE R3, #00000000B,X4
   NEXT_32:
      CLR P1.4
      SETB P1.7
      SETB P1.3
      MOV R4, #00000011B
      MOV R3, #00000000B
      LJMP RT1
      
      
;=======================================================================
;               DEM THOI GIAN DEN VANG VA CAI DAT DEN DO
;=======================================================================
VANG1:
      JB P1.4, DO1
      CJNE R4, #00000001B,X3
      MOV R0, #49
      MOV A, @R0
      MOV R4, A
      MOV R0, #48
      MOV A, @R0
      MOV R3, A
      CLR P1.5
      CLR P1.7
      SETB P1.4
      LJMP RT1
      
      
;=======================================================================
;     DEM THOI GIAN DEN DO VA SAU DO CAI DAT CHO DEN XANH KE TIEP
;=======================================================================
DO1: 
      CJNE R3, #00000000B, NEXT_41
      CJNE R4, #00000001B,X3      ;so voi 1
      MOV R4, #00001001B
      JMP NEXT_42
   NEXT_41: 
      CJNE R4, #00000000B,X3
      MOV R4, #00001001B
      CJNE R3, #00000000B,X4
   NEXT_42:
      CLR P1.3
      SETB P1.7
      SETB P1.5
      MOV R0, #51
      MOV A, @R0
      MOV R4, A
      MOV R0, #50
      MOV A, @R0
      MOV R3, A
      LJMP RT1
           
;=======================================================================
;                  CAC BUOC DUNG DE TANG GIA TRI GIAY
;=======================================================================
X3:
     DEC R4
     LJMP RT1
X4:
      DEC R3    
      
;=======================================================================
;                        LAP LAI THOI GIA TIMER
;=======================================================================
RT1: 
      SETB TR1
      RETI
;=======================================================================
;                          PAUSE AND RESUME
;=======================================================================      
PSRS:
      LCALL Display
      JNB P3.2, PSRS
      MOV R0, 40H		;Nut pause va resume
      INC R0			;tang 1 don vi	
      MOV 40H, R0 
      CJNE R0, #2d, Exit	;neu so don vi la 1 thi thoat ra nhay lai toi ham loop
      MOV R0, #0d
      MOV 40H, R0		;neu R0 bang 2 thi cho no quay tro lai la 0
Exit:
      RETI  
;=======================================================================
;                                SETUP
;=======================================================================    
ST: 
      JNB P3.3, ST
      CLR TR0
      CLR TR1 
      CLR P1.2
      CLR P1.3      
      SETB P1.0
      SETB P1.1
      SETB P1.4
      SETB P1.5
      MOV R1,#00000000B
      MOV R2,#00000000B
      ;MOV  R6, 41H 
SUT: 
      CLR P3.4 ; seg 1
      CLR P3.6 ; seg 3
      CLR P3.7 ; seg 4
      SETB P3.5 ; set co seg2 len 1 
      MOV P0,R2 ; P0 hien so la 0
      CALL DL ; call quet led
      MOV P0,R2 ; 
      CALL DL
      CLR P3.5
      SETB P3.4
      MOV P0,R1
      CALL DL
      MOV P0,R1
      CALL DL
      MOV A,P2  ; eu luc nay P2 thay doi 
      Jnb P3.1,Set60s
      Jnb P3.0,Setup30s
      ANL A, #10001111b
      CJNE A,#10001111b,DuocNhan
      SJMP SUT

      ;THUC HIEN HAM KIEM TRA SET UP O DAY
Setup30s:
      MOV R1,#3d
      SJMP R4C3 
Set60s:
      Mov R1,#6d
      SJMP R4C3 
DuocNhan:
RO1:
      JB P2.0,RO2
      CALL CC 
R1C1:
      JB P2.4,R1C2
      MOV R0,#53
R1C2:
      JB P2.5,R1C3
      MOV R0,#54
R1C3:
      JB P2.6,RSK
      MOV R0,#55
      LJMP RSK
RO2:
      JB P2.1,RO3
      CALL CC
R2C1:
      JB P2.4,R2C2
      MOV R0,#56
R2C2:
      JB P2.5,R2C3
      MOV R0,#57
R2C3:
      JB P2.6,RSK
      MOV R0,#58
      LJMP RSK
RO3:
      JB P2.2,RO4
      CALL CC
R3C1:
      JB P2.4,R3C2
      MOV R0,#59
R3C2:
      JB P2.5,R3C3
      MOV R0,#60
R3C3:
      JB P2.6,RSK
      MOV R0,#61
      LJMP RSK
RO4:
      JB P2.3,SUT
      CALL CC
R4C2:
      JB P2.5,R4C3
      MOV R0, #52  
   
;======================================================================
;                        NUT # DE HOAN THANH SETUP
;======================================================================
R4C3:
      JB P2.6,RSK
CHONGDOI:
      CLR P2.4
      CLR P2.5
      CLR P2.6
      SETB P2.0
      SETB P2.1
      SETB P2.2
      SETB P2.3
      SETB P2.7
      MOV A, P2		;cho R1 bang P1
      CJNE A, #10001111b, CHONGDOI
;======================================================================
;			THUC HIEN TINH RA SO GIAY BEN NGANG
;======================================================================
      MOV R0, #BUFFER		;R0 nhan gia tri cua buffer = 30H, R0 = 30h
      MOV A, R1			;A nhan gia tri cua R1 = 00000001B  = 1
      MOV @R0, A		;o nho co dia chi la R0 nhan gia tri cua A, dia chi 30h co gia tri la a
      INC R0			;Tang gia tri R0, 31h
      MOV A, R2			;A nhan gia tri cua R2
      MOV @R0, A		;o nho co dia chi la R0 nhan gia tri cua A
      INC R0			;tang gia tri cua r0 len 1 gia tri
      MOV A, R1  		;A nhan gia tri cua thanh ghi R1 (
      MOV B, #00001010B		;B = 00001010B = 10
      MUL AB			;thi phan bit thap se duoc gan cho A con phan bit cao se duoc gan cho thanh ghi b, A =10
      ADD A, R2			;cong them r2 thanh so co hai chu so voi r1 la chu so hang chuc, r2 la chu so hang don vi => lay A - 64 = 12
      SUBB A, #00000011B	;lay A - 3 = 9
      MOV B, #00001010B		;B = 10
      DIV AB			;lay A chia B la 10/10 thi A = 1 va B = 0
      MOV R3, A			;r3 = 10000001b
      MOV @R0, A		;dia chi tiep theo r3 = 10000001b
      INC R0			;tang them dia chi tiep thep
      MOV A,B			;A = 0
      MOV R4, A			; R4 = A = 11000010b
      MOV @R0, A		; dia chi tiep theo = 11000010b
;========================================================================
;			THOAT NGAT
;========================================================================
      RETI ; ket thuc o day
;======================================================================
;          RESET KEY DE PHUC VU CHO VIEC NHAN DIEN SO DC BAM 
;======================================================================
RSK:
      MOV P2,#10001111b
      MOV A, P2		;cho R1 bang P1
      CJNE A, #10001111b, RSK
      LJMP SUL12
      
;=====================================================================
;       CHON KEY DE PHUC VU VIEC XAC DINH COT CUA SO DC BAM
;=====================================================================
CC:
   ; Cai dat nguoc lai la cot thanh 1 va dong thanh 0
      SETB P2.4 
      SETB P2.5
      SETB P2.6
      CLR P2.0
      CLR P2.1
      CLR P2.2
      CLR P2.3
      RET
      
;=====================================================================
Display:
      SETB P3.5
      MOV P0,R2
      CALL DL
      MOV P0,R2
      CALL DL
      CLR P3.5
      SETB P3.4
      MOV P0,R1
      CALL DL
      MOV P0,R1
      CALL DL
      CLR P3.4
      SETB P3.7
      MOV P0,R4
      CALL DL
      MOV P0,R4
      CALL DL
      CLR P3.7
      SETB p3.6
      MOV P0,R3
      CALL DL
      MOV P0,R3
      CALL DL
      CLR P3.6
      RET
      
;=======================================================================
      END