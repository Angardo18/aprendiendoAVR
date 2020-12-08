/*
 * TM1637.asm
 *
 *  Created: 7/12/2020 11:18:25
 *   Author: Angel Orellana
 * esta libreria es creada para el envio de datos para el controlador TM1637 
 ;COMO NOTA ADICIONAL PARA EVITAR CONFLICTOS, SE DEBE DE COLOCAR ESTA LINEA DE CODIGO
 ;JUSTO DESPUES DE LA INICIALIZACION DE LOS VECTORES DE INTERRUPCION, ESTA TABLA SON LAS
 ;CONSTANTES QUE SE GUARDAN EN LA MEMORIA DE PROGRAMA COMO LOOK UP TABLE

 ;IMPORTANTE, PARA QUE LA LIBRERIA FUNCIONE CORRECTAMENTE DEBE COLOCAR LA SIGUIENTE LINEA EN 
 ;LA POSICION DE MEMORIA QUE DESEE, SE RECOMIENDA COLOCARLA INMEDIATAMENTE DESPUES DEL VECTOR DE INTERRUPCION
 ;
 ;TABLE:.DB  0x3f,0x06,0x5b,0x4f,0x66,0x6d,0x7d,0x07,0x7f,0x6f 
 
 ADICIONALMENTE SE DEBE DE DECLARAR LAS CONSTANTES DE PUERTOS Y PINES EN EL PROGRAMA PRINICIPAL DE LA FORMA QUE SIGUE:
 .EQU TM1637PORT = PORTX
 .EQU TM1637DDR = DDRX
 .EQU TM1637PIN = PINX 
 
 .EQU TM1637DATA = "PIN USADO PARA ENVIAR DATOS"
 .EQU TM1637CLK = "PIN DEL PUERTO USADO COMO RELOJ" 
 
 ES IMPORTANTE ESTAS DECLARACIONES DE LO CONTRARIO LA LIBRERIA NO COMPILARA ADECUADAMENTE

 PARA EVIRTAR INCONVENIENTES MIENTRAS SUCEDE ALGUNA INTERRUPCION SE RECOMIENDA QUE SI, DENTRO
 DE LA INTERRUPCION SE MODIFICAN LOS REGRISTROS R0, R16, Y  Z, REALIZAR UN GUARDADO DE SU VALOR ANTERIOR
 ANTES DE MODIFICARLOS REGISTROS Y REALIZAR SU POSTERIOR RESTAURACION.

 ;-------VARIABLES-------------------
 .DSEG
	
	;--- VALOR DEL DIGITO (BCD), EN ESTAS VARIABLES SE ESPECIFICA EL VALOR EN BINARIO DEL DIGITO QUE SE QUIERE COLOCAR
	;PARA SU POSTERIOR TRADUCCION A 7 SEGMENTOS ------------------
	DIG1: .BYTE 1
	DIG2: .BYTE 1
	DIG3: .BYTE 1
	DIG4: .BYTE 1
;CONSTANTES:
	.EQU ADR_AUTO = 0x40 ;COMANDO PARA DIRECCION AUTOMATICA
	.EQU DIR_INI = 0xC0 ;VALOR PARA APUNTAR A LA DIRECCION C0

.CSEG
INITIALICE:
	CLR	R16
	LDS	SEG1, R16
	LDS	SEG2, R16
	LDS	SEG3, R16
	LDS	SEG4, R16 ;SE COLOCAN EN 0 LOS REGISTROS
	SBI	TM1637DDR, TM1637DATA
	SBI	TM1637DDR, TM1637CLK ;SE COLOCAN COMO SALIDAS LOS PINES


CODE_DIGITS:
 ESTA FUNCION CODIFICA EL VALOR EN DIGX A SU REPRESENTACION EN 7 SEGEMNTOS  
   PARA ELLO USA LA TABLA DE CONSTANTES ALOJADAS EN LA ETIQUETA TABLE, SE USA
   EL REGISTRO Z, R16 Y R0 EN ESTA RUTINA, SI EN ALGUNA INTERRUPCION SE UTILIZAN ESTOS
	REGISTROS ASEGURECE DE GUARDARLOS ANTES DE MODIFICAR DENTRO DE LA INTERRUPCION
	O BIEN DESACTIVAR LAS INTERRUPCIONES ANTES DE HACER UNA LLAMADA A ESTA FUNCION
	LDI	ZH, HIGH(TABLE*2)
	LDI ZL, LOW(TABLE*2) ;SE CARGAN LOS BYTES LOW Y HIGH DE TABLE
	LDS	R16, DIG1
	ADD	ZL, R16
	LPM ;SE CARGA A R0 EL VALOR  PARA EL DISPLAY
	STS SEG1, R0
	;SE CONFIGURA EL APUNTADOR PARA LA TABLA
	LDI	ZH, HIGH(TABLE*2)
	LDI ZL, LOW(TABLE*2) ;SE CARGAN LOS BYTES LOW Y HIGH DE TABLE
	LDS	R16, DIG2
	ADD	ZL, R16
	LPM ;SE CARGA A R0 EL VALOR  PARA EL DISPLAY
	STS	SEG2, R0
	;SE CONFIGURA EL APUNTADOR PARA LA TABLA
	LDI	ZH, HIGH(TABLE*2)
	LDI ZL, LOW(TABLE*2) ;SE CARGAN LOS BYTES LOW Y HIGH DE TABLE
	LDS	R16, DIG3
	ADD	ZL, R16
	LPM ;SE CARGA A R0 EL VALOR  PARA EL DISPLAY
	STS SEG3, R0
	;SE CONFIGURA EL APUNTADOR PARA LA TABLA
	LDI	ZH, HIGH(TABLE*2)
	LDI ZL, LOW(TABLE*2) ;SE CARGAN LOS BYTES LOW Y HIGH DE TABLE
	LDS	R16, DIG4
	ADD	ZL, R16
	LPM ;SE CARGA A R0 EL VALOR  PARA EL DISPLAY
	STS SEG4, R0
	RET ;FIN*/



	

	