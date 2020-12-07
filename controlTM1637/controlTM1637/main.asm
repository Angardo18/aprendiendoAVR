;
; controlTM1637.asm
;
; Created: 4/12/2020 11:11:35
; Author : Angel Orellana
; ESTE PROGRAMA ES UN EJERCICIO PARA IMPLEMENTAR UNA COMUNICACION VIA SOFTWARE CON 
; UN MODULO DE DISPLAY 7 SEGMENTOS 4 DIGITOS QUE USA EL INTEGRADO TM1637 COMO CONTROLADOR

;PINES QUE SERAN USADOS COMO RELOJ Y COMO DATOS
.EQU CLK = 0
.EQU DATA = 1
.EQU ADR_AUTO = 0x40 ;DIRECCIONAMIENTO AUTOMANTIOC ESCRITURA DE DATOS Y MODO NORMAL
.EQU DIR_INI = 0xC0 ;INICIA EN LA DIRECCION C0
.EQU VAL_TMR0 = 98;0x0B
.DSEG ;DATOS
;------------ USADOS EN LAS FUNCIONES DE ENVIO DE DATOS -----------------
SEG1: .BYTE 1 ;VARIABLE USADA PARA ASIGNAR EL DATO A ENVIAR
SEG2: .BYTE 1
SEG3: .BYTE	1
SEG4: .BYTE 1 ;VARIABLES QUE SE USAN PARA ENVIAR LOS DATOS
;------------- USADOS PARA DETERMINAR LOS VALORES DE LOS DIGITOS --------
CONT_L: .BYTE 1
CONT_LM: .BYTE 1
CONT_HM: .BYTE 1
CONT_H: .BYTE 1
;--------- VARIABLES PARA GUARDAR ENTORNO ---------
STATUS_RAM: .BYTE 1

.CSEG 
.ORG 0x0000
	RJMP CONFIGURACION
.ORG 0x0005
	RJMP ISR_TMR0
TABLE:.DB  0x3f,0x06,0x5b,0x4f,0x66,0x6d,0x7d,0x07,0x7f,0x6f
CONFIGURACION:
	;----- CONFIGURACION DEL TMR0 ----------------
	;IN R16, GTCCR
	;SBR	R16, 
	CLR R16
	OUT TCCR0A, R16 ;COMPARE MATCH A Y B DESCONECTADO MODO DE OPERACION NORMAL

	SBR	R16, 5; PRESCALER DE 1:1024
	OUT TCCR0B, R16; SE CARGA EL VALOR

	LDI	R16, VAL_TMR0 
	OUT TCNT0, R16; SE CARGA EL VALOR PARA QUE LA  INTERRUPCION SUCEDA A LOS 250 MS APROX

	;----- INTERRUPCIONES ---------------------
	CLR R16;0
	SBR	R16, 2; SE COLOCA EN 1 EL BIT 1
	OUT TIMSK, R16; SE CONFIGURA LA INTERRUPCION
	SEI ;SE ACTIVAN LAS INTRRUPCIONES
	;--------- INICIALIZACION DE CONTADORES -------------
	CLR R16
	STS	CONT_L, R16
	STS CONT_LM, R16
	STS CONT_HM, R16
	STS CONT_H, R16

LOOP:
	;SE CONFIGURA EL APUNTADOR PARA LA TABLA
	LDI	ZH, HIGH(TABLE*2)
	LDI ZL, LOW(TABLE*2) ;SE CARGAN LOS BYTES LOW Y HIGH DE TABLE
	LDS	R16, CONT_L
	ADD	ZL, R16
	LPM ;SE CARGA A R0 EL VALOR  PARA EL DISPLAY
	STS SEG1, R0
	;SE CONFIGURA EL APUNTADOR PARA LA TABLA
	LDI	ZH, HIGH(TABLE*2)
	LDI ZL, LOW(TABLE*2) ;SE CARGAN LOS BYTES LOW Y HIGH DE TABLE
	LDS	R16, CONT_LM
	ADD	ZL, R16
	LPM ;SE CARGA A R0 EL VALOR  PARA EL DISPLAY
	STS	SEG2, R0
	;SE CONFIGURA EL APUNTADOR PARA LA TABLA
	LDI	ZH, HIGH(TABLE*2)
	LDI ZL, LOW(TABLE*2) ;SE CARGAN LOS BYTES LOW Y HIGH DE TABLE
	LDS	R16, CONT_HM
	ADD	ZL, R16
	LPM ;SE CARGA A R0 EL VALOR  PARA EL DISPLAY
	STS SEG3, R0
	;SE CONFIGURA EL APUNTADOR PARA LA TABLA
	LDI	ZH, HIGH(TABLE*2)
	LDI ZL, LOW(TABLE*2) ;SE CARGAN LOS BYTES LOW Y HIGH DE TABLE
	LDS	R16, CONT_H
	ADD	ZL, R16
	LPM ;SE CARGA A R0 EL VALOR  PARA EL DISPLAY
	STS SEG4, R0
	CLI
	RCALL CONF_IO_DISPLAY
	RCALL DISPLAY
	SEI
	RCALL CORREGIR_BCD

	RJMP LOOP

;-------------- COMUNICACION SERIAL CON TM1637 -----------------------------
DISPLAY:
	;EN ESTA RUTINA SE ENVIA EL COMANDO, Y LOS DATOS NECESARIOS A MOSTRAR
	LDI R16, ADR_AUTO ;SE CARGA EL COMANDO PARA LA ESCRITURA
	RCALL START
	RCALL SEND
	RCALL STOP

	LDI	 R16, DIR_INI ;DIRECCION INICIAL DE DATOS EN EL TN1637
	RCALL START
	RCALL SEND
	LDS	R16, SEG4
	RCALL SEND
	LDS	R16, SEG3
	RCALL SEND
	LDS	R16, SEG2
	RCALL SEND
	LDS	R16, SEG1
	RCALL SEND
	RCALL	STOP ;FIN DE LOS DATOS

	;SE CONFIGURA EL BRILLO
	LDI	R16, 0x8A ;
	RCALL START
	RCALL SEND
	RCALL STOP
	RET ;SE DETIENE

CONF_IO_DISPLAY:
	;SE CONFIGURAN LAS LINEAS DE DATOS:
	SBI	DDRB, CLK
	SBI DDRB, DATA ;SE COLOCAN EN 1 LOS PINES DE DATOS Y CLOCK
	RET

START:
	SBI	PORTB, CLK
	SBI	PORTB, DATA
	CBI	PORTB, DATA
	CBI	PORTB, CLK
	RET

STOP:
	CBI	PORTB, CLK
	CBI	PORTB, DATA
	SBI	PORTB, CLK
	SBI	PORTB, DATA
	RET	

SEND:
	;SE USARA EL REGISTRO R16 PARA ENVIAR LOS DATOS Y R17 COMO VALOR DE CONTADOR
	CLR	R17 ;SE COLOCA EN 0 EL VALOR DE R17
	CICLE:
	CPI R17, 8
	BREQ WAIT_FOR_ACK ;SI R17 ES 8 SE VA A LA ETIQUETA INDICADA
	;------------- SIGUE AQUI SI NO HAN PASADO 8 BITS ------------
	CBI	PORTB, CLK ;SE COLOCA EN 0
	SBRC R16, 0 ; SE SALTA LA INSTRUCCION SI EL BIT ES 0
	RJMP ONE
	;-------- SI ES CERO SE EJECUTA AQUI -------------------------
	CBI	PORTB, DATA
	RJMP CONTINUE
	
	ONE: 
	SBI	PORTB, DATA

	CONTINUE:
	;-------- AQUI SE HACEN LOS PREPARATIVOS PARA EL SIGUIENTE BIT------
	SBI	PORTB, CLK ;SE COLOCA EN 1 EL RELOJ 
	LSR	R16 ;SHIFT LOGICO A LA DERECHA
	INC R17 ;SE INCREMENTA 
	NOP
	NOP
	RJMP CICLE ;CONTINUA CON EL SIGUIENTE BIT
	WAIT_FOR_ACK:
	CBI	PORTB, CLK
	CBI DDRB, DATA ;SE COLOCA COMO ENTRADA
	SBI	PORTB, CLK
	NOP
	NOP
	SBI	DDRB, DATA ;SE COLOCA COMO ENTRADA DE NUEVO
	CBI	PORTB, DATA ;SE COLOCA EN CERO
	RET ;FIN DEL ENVIO DE DATOS

;-------- CORRECCION EN BCD -------------------------------------------
CORREGIR_BCD:
	LDS	R16, CONT_L
	CPI R16, 10; SE COMPARA CON 10
	BREQ INCREMENTAR_LM ;SI ES 
	RET
	INCREMENTAR_LM:
	CLR	R16
	STS CONT_L, R16
	LDS	R16, CONT_LM
	INC R16
	CPI R16, 10
	BREQ INCREMENTAR_HM
	;- ELSE
	STS  CONT_LM,R16
	RET
	INCREMENTAR_HM:
	CLR R16
	STS CONT_LM, R16 ;SE COLOCA EN 0
	LDS	R16, CONT_HM
	INC	R16
	CPI R16, 10
	BREQ INCREMENTAR_H
	;-- SI NO -----
	STS CONT_HM, R16
	RET
	INCREMENTAR_H:
	CLR R16
	STS CONT_HM, R16
	LDS	R16, CONT_H
	INC R16
	CPI R16, 10
	BREQ FIN
	;-- SI NO ES IGUAL---
	STS	CONT_H, R16
	RET
	FIN:
	CLR R16
	STS CONT_H,R16
	RET ;FIN DE TODO



		
ISR_TMR0:
	IN	R18, SREG
	STS	STATUS_RAM, R18

	LDS	R18, CONT_L
	INC	R18
	STS	CONT_L, R18

	LDI	R18, VAL_TMR0
	OUT TCNT0, R18

	LDS R18, STATUS_RAM
	OUT SREG, R18
	RETI
