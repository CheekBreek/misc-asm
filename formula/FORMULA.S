;The program recives a 3 digit decimal number
;and uses it as x in the formula:
;y=((8*x^2 - 5*x + 1997) % 10000) / 10
;The answer is outputted to the user in the
;form of a 3 digit decimal number.
;
;Details:
;The program requires a 3 digit decimal number and
;outputs a 3 digit decimal number. A quirk caused
;by assembly language implementation would be
;splitting x^2 into two values and operating on
;them separately due to mulu only operating
;on the lower 4 bits. It is assumed that the input
;is always a 3 digit positive number.
;
;Program Status:
;The program has been tested as is working
;Test Plan:
;000	Zero input	Expected:	199
;			Actual:		199
;999	Max input	Expected:	101
;			Actual:		101
;123 	Regular case	Expected:	241
;			Actual:		241
;653	Zero output	Expected:	000
;			Actual:		000
;400	Max output	Expected:	999
;			Actual:		999
;Register Table:
;d0 - 	Used for I/O of data
;d1 - 	Holds the hundred's digit
;d2 - 	Holds the ten's digit
;d3 - 	Holds the one's digit
;d4 - 	Holds the 3 digit number
;d5 - 	Holds the squared 3 digit number, later holds the
;	last 4 bits of the 3 digit number
;d6 - 	Holds the first 4 bits of the squared 3 digit number;
;	later holds the ten's digit for	extracting the
;	hundred's digit
;

start:		jsr	read_char	;Reads in hundred's digit
		move.l	d0,d1		;Stores hundred's digit
		divu.w	#16,d1		;Masking with 0x0F
		clr.w	d1		;Clears the quotient
		swap	d1		;and stores the remainder

		jsr	read_char	;Reads in ten's digit
		move.l	d0,d2		;Stores ten's digit
		divu.w	#16,d2		;Masking with 0x0F
		clr.w	d2		;Clears the quotient
		swap	d2		;and stores the remainder

		jsr	read_char	;Reads in the one's digit
		move.l	d0,d3		;Stores one's digit
		divu.w	#16,d3		;Masking with 0x0F
		clr.w	d3		;Clears the quotient
		swap	d3		;and stores the remainder

		move.b	CR,d0
		jsr	write_char
		move.b	LF,d0
		jsr	write_char

		mulu.w	#100,d1		;Multiplying the digits by
		mulu.w	#10,d2		;the proper values to add together

		move.l	d1,d4		;Adding the 3 digits
		add.l	d2,d4		;to form the whole
		add.l	d3,d4		;number, x
		
		move.l	d4,d5		
		mulu.w	d5,d5		;Squaring x

		swap	d5		
		move.w	d5,d6		;Separates and stores
		clr.w	d5		;the 4 high bits of x^2
		swap	d5

		mulu.w	#8,d5		;Multipling the low bits of x^2 by 8
		mulu.w	#8,d6		;Multiplies the high bits of x^2 by 8
		mulu.w	#5,d4		;Multiplies x by 5

		sub.l	d4,d5		;Subtracts x*5 from x^2
		add.l	#1997,d5	;Adds 1997 to x^2-x*5
	
		swap	d5
		add.w	d6,d5		;Adds the 4 high bits back
		swap	d5		;and divides result by 10000
		divu.w	#10000,d5
		clr.w	d5		;Removes the quotient,
		swap	d5		;leaving the remainder

		divu.w	#10,d5
		swap	d5		;Divides (8*x^2-5*x+1997)%10000
		clr.w	d5		;by 10 and removes the remainder
		swap	d5		;leaving the quotient

		move.l	d5,d3		
		divu.w	#10,d3		;Extracting the one's digit
		clr.w	d3		;and storing it
		swap	d3

		move.l	d5,d2
		divu.w	#100,d2
		clr.w	d2
		swap	d2
		sub.w	d3,d2		;Extracting the ten's digit
		divu.w	#10,d2		;and storing it
		swap	d2		
		clr.w	d2
		swap	d2

		move.l	d5,d1
		sub.l	d3,d1
		move.l	d2,d6
		mulu.w	#10,d6		;Extracting the hundred's digit
		sub.l	d6,d1		;and storing it
		divu.w	#100,d1
		swap	d1
		clr.w	d1
		swap	d1

		add.l	#'0',d1
		add.l	#'0',d2		;Converting the decimal numbers
		add.l	#'0',d3		;to equivalent ASCII values

		move.l	d1,d0
		jsr	write_char
		move.l	d2,d0		;Outputting the individual
		jsr	write_char	;digits to the user
		move.l	d3,d0
		jsr	write_char

		move.b	CR,d0
		jsr	write_char
		move.b	LF,d0
		jsr	write_char

		jsr	exit

CR:		dc.b	$D
LF:		dc.b	$A

;----- SUBROUTINE: read_char -----
;
; PURPOSE: waits for and reads a single keystroke from the keyboard.
;
; CALLER OUTPUT: returns the ASCII value of the key in the low byte
;                of D0.
;
; IMPORTANT: NOTE THAT THE HIGHER_ORDER BYTES OF D0 ARE UNDEFINED.
;            DON'T ASSUME THEY ARE ZEROED OUT!
;
; E.G. CALL:	jsr	read_char
;		... now use D0.b ...

read_char:	movem.l	d1-d2/a0-a2,-(sp)
		move.w	#1,-(sp)
		trap	#1
		addq.l	#2,sp	
		movem.l	(sp)+,d1-d2/a0-a2
		rts


;----- SUBROUTINE: write_char -----
;
; PURPOSE: writes a single character to the screen.
;
; CALLER INPUT: takes the ASCII value of the character in the low byte
;               of D0.
;
; E.G. CALL:	move.b	#'a',d0
;		jsr	write_char

write_char:	movem.l	d0-d2/a0-a2,-(sp)
		and.w	#$00FF,d0
		move.w	d0,-(sp)
		move.w	#2,-(sp)
		trap	#1
		addq.l	#4,sp
		movem.l	(sp)+,d0-d2/a0-a2
		rts


;----- SUBROUTINE: exit -----
;
; PURPOSE: terminates the program.  This routine never returns.

exit:		clr.w	-(sp)
		trap	#1
