/*
* Laboratorio.asm
*
* Creado: 011-Feb-25 
* Autor : Yelena Cotzojay
* Descripci n: 
*/
// Encabezado
.include "M328PDEF.inc"
.cseg
.org	0x0000

//DAESACTIVAS D0 Y D1
LDI R16, 0x00
STS	UCSR0B, R16

//Stack
LDI		R16, LOW(RAMEND)
OUT		SPL, R16
LDI		R16, HIGH(RAMEND)
OUT		SPH, R16

SETUP:
	//Configurar el Prescaler
	LDI R24, (1 << CLKPCE)
	STS CLKPR, R24 // Habilitar cambio de PRESCALER
	LDI R24, 0b00000100
	STS CLKPR, R24 //Prescaler con 1MHz*/

	; CONFIGURAR PINES DE ENTRADA Y SALIDA 
	; PORTC COMO ENTRADA CON PULL-UP HABILITADO
	LDI		R16, 0x00
	OUT		DDRC, R16  // Setear puerto D como entrada
	LDI		R16, 0xFF
	OUT		PORTC, R16 //Habilita el pull-up

	; PORTB COMO SALIDA INICIALMENTE APAGADO
	LDI		R16, 0xFF
	OUT		DDRB, R16 //Setear el puerto B como salida
	LDI		R16, 0x00
	OUT		PORTB, R16 //Valor inicial en 0

	; PORTD COMO SALIDA INICIALMENTE APAGADO
	LDI		R16, 0xFF
	OUT		DDRD, R16 //Setear el puerto D como salida
	LDI		R16, 0x00
	OUT		PORTD, R16 //Valor inicial en 0
	LDI		R17, 0x7F
	LDI		R19, 0x00 //variable para llevar el contador 1
	LDI		R21, 0x00 //Variable para llevar el contador 2 y carry
	LDI	R22, 0x00	//El registro 22 con valor inicial 0 
	

MAIN:
	IN		R16, PINC // Guardando el estado de PORTC en R16 0xFF
	CP		R17, R16 // Comparamos estado "viejo" con estado "nuevo"
	BREQ	MAIN
	CALL	DELAY
	IN		R25, PINC
	CP		R17, R25
	BREQ	MAIN
	// Volver a leer PIND
	MOV		R17, R25
	
	SBRS	R16, 0	//SI el bit 0 del PINC es 0 (No apachado)
	CALL	INC_CONT1 // Si está en 1 ejecuta esta línea
	SBRS	R16, 1	// si el bit 1 del pin es 0
	CALL	DEC_CONT1
	SBRS	R16, 2
	CALL	INC_CONT2
	SBRS	R16, 3
	CALL	DEC_CONT2
	SBRS	R16, 4
	CALL	SUMA
	RJMP	MAIN

//Subrutina para incrementar el contador 1
INC_CONT1:
	INC		R19	//Incrementa el registro
	CPI		R19, 0x10	//Compara si llega a 16
	BRNE	NO_RESETC0	//SI no es 16 continuar
	LDI		R19, 0x00	//SI es 16, reiniciarlo a 0
	
NO_RESETC0:
	OUT		PORTD, R19	
	RJMP	MAIN

DEC_CONT1:
	DEC	R19			//Decrementar contador 
	CPI	R19, 0x00	//Verifica si R19 es 0
	BRNE NO_RESETC1	
	LDI	R19, 0x0F	//Si llegó a 0, ponerlo en 15
NO_RESETC1:
	OUT		PORTD, R19
	RJMP	MAIN

INC_CONT2:
	INC		R21	//Incrementa el registro
	CPI		R21, 0x10	//Compara si llega a 16
	BRNE	NO_RESETC2	//SI no es 16 continuar
	LDI		R21, 0x01	//SI es 16, reiniciarlo a 0
NO_RESETC2:
	OUT		PORTB, R21
	RJMP	MAIN

DEC_CONT2:
	DEC	R21			//Decrementar contador 
	CPI	R21, 0x00	//Verifica si R21 es 0
	BRNE NO_RESETC3	
	LDI	R21, 0x0F	//Si llegó a 0, ponerlo en 15
NO_RESETC3:
	OUT		PORTB, R21
	RJMP	MAIN

SUMA:
	;LDI	R22, 0x00	//El registro 22 con valor inicial 0 
	MOV	R22, R19	//Suma el contador 1 y lo guarda en R22
	ADD	R22, R21	//Suma el contador 2

	SBRC	R22, 0
	SBR		R19, (1<<4)
	SBRC	R22, 1
	SBR		R19, (1<<5)
	SBRC	R22, 2
	SBR		R19, (1<<6)
	SBRC	R22, 3
	SBR		R19, (1<<7)
	SBRC	R22, 4
	SBR		R21, (1<<4)
	OUT		PORTD, R19
	OUT		PORTB, R21
	RET
	/*BRCS	ENCENDER_LED	//Si hubo carry (C=1), encender Led
	OUT	PORTD, R22	//Mostrar el resultado en el puerto B
	RJMP MAIN*/


/*ACTUALIZAR_PUERTO:
//El contador 1 usa los bit (0-3) del puerto D
//El contador 2 usa los bit (4-7) del puerto D
	MOV		R17, R21	//Copiar R21 a R17
	SWAP	R17			//Intercambiar nibbles
	OR		R17, R19	//Combina con R19
	OUT		PORTD, R17	//Actualizar salida
	RJMP	MAIN*/

// Sub-rutina (no de interrupci n) 
DELAY:
	LDI		 R18, 0xFF

	SUB_DELAY1:
	DEC		R18
	CPI		R18, 0
	BRNE	SUB_DELAY1
	LDI		R18, 0xFF

	SUB_DELAY2:
	DEC		R18
	CPI		R18, 0
	BRNE	SUB_DELAY2
	LDI		R18, 0xFF

	SUB_DELAY3:
	DEC		R18
	CPI		R18, 0
	BRNE	SUB_DELAY3
	RET