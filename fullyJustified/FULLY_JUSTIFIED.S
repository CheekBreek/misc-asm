;The program receives a text file named TEXT.txt
;and it formats the text into a fully justified
;format at a given line length.
;	
;Details:
;The program requires a text file named TEXT.txt
;which the program uses to format into a fully
;justified format.
;Assumptions:
;The justification length will be less than or equal to 40
;Any word will not be longer than the justification length
;
;Program Status:
;The program has been tested but only produces an output
;in left justified format. It also does not print an error
;message when TEXT.txt is not found.
;The program is untested but assumed to be working.
;The program has been tested somewhat with the TEXT.txt
;provided in the assignment document and it looked successful.
;
;Register Table:
;d0 - Used of I/O of data
;d1 - Holds the amount of characters in the text document
;d2 - Holds the justification length
;d3 - Holds the second digit to calculate the justification length
;d4 - Holds the length of a word
;d5 - Holds the length of a line
;d6 - Holds the length of a word + the length of a line
;d7 - Holds the counter for creating the digit row

		xref	FileOpen
		xref	FileReset
		xref	FileClose
		xref	FileCharRead
		xref	Exit
		xref	KbdCharRead
		xref	ScrnCharWrite

start:		bsr	FileOpen		

		cmpi.w	#0,d0
		beq	FileFound	;Checks for TEXT.txt file
		bsr	FileClose
		bsr	Exit

FileFound:	bsr	FileCharRead	
		sub.w	#1,d1		;Subtracts 1 from the 
					;character counter.
		move.l	d0,d2
		divu.w	#16,d2		;Masking with 0x0F.
		clr.w	d2
		swap	d2		
		bsr	FileCharRead
		sub.w	#1,d1
		move.w	#'0',d3
		cmpi.w	#13,d0
		beq.s	DigitRow	;If the justification length is only
					;1 digit, skip getting next digit.
		move.l	d0,d3
		divu.w	#16,d3		
		clr.w	d3
		swap	d3
		mulu.w	#10,d2		;Shifting the first digit into the
					;10's position.
		add.l	d3,d2
		move.w	#'0',d3		;Clears d3 for use in DigitRow

DigitRow:	move.w 	d3,d0
		bsr	ScrnCharWrite
		add.w	#1,d3
		add.w	#1,d7
		cmp	d7,d2
		beq	AddNextLine
		cmpi.w	#':',d3
		beq	ResetDigit
		bra	DigitRow

ResetDigit:	move.w	#'0',d3
		bra	DigitRow

AddNextLine:	move.w	#13,d0		;Prints out a newline
		bsr	ScrnCharWrite	
		move.w	#10,d0		
		bsr	ScrnCharWrite

EOFCheck:	cmpi.w	#$0,d1		;Checks if all the characters
					;have been read.
		bgt.s	FindStartWord
		bsr	FileClose
		bsr	Exit		

FindStartWord:	bsr	FileCharRead	;Skips all whitespace.
		sub.w	#1,d1
		cmpi.w	#$0,d1
		ble.s	EOFCheck	;Check if EOF was encountered.
		cmpi.w	#' ',d0
		beq.s	FindStartWord	
		cmpi.w	#13,d0
		beq.s	FindStartWord
		cmpi.w	#10,d0
		beq.s	FindStartWord
		lea	WordArray,a0

ReadWord:	cmpi	#' ',d0		;Checks for whitespace.
		beq.s	EndOfWord
		cmpi.w	#13,d0
		beq.s	EndOfWord
		cmpi.w	#10,d0
		beq.s	EndOfWord
		move.w	d0,(a0)+	;Moves character into array.
		add.w	#1,d4		;Adds 1 to word counter.
		cmpi.w	#$0,d1
		ble.s	EOFCheck	;Check if EOF was encountered.
		bsr	FileCharRead
		sub.w	#1,d1		;Subtracts 1 from character counter.
		bra	ReadWord
		
EndOfWord:	clr.w	d6
		move.w	d5,d6
		add.w	d4,d6		
		lea	WordArray,a0	;Checks if the new word will exceed
		cmp.l	d2,d6		;the justification length.
		bgt.s	NewLine
		add.w	d4,d5		

PrintLoop:	move.w	(a0)+,d0
		bsr	ScrnCharWrite
		sub.w	#1,d4
		cmpi.w	#$0,d4		;Traverses through array,
		bne	PrintLoop	;printing out each character.
		move.w	#' ',d0
		add.w	#1,d5
		bsr	ScrnCharWrite
		bra	EOFCheck

NewLine:	move.w	#$0,d5
		add.w	d4,d5
		move.w	#13,d0		;Prints out a newline and
		bsr	ScrnCharWrite	;resets the line counter to 0
		move.w	#10,d0		;and adding current word length.
		bsr	ScrnCharWrite
		bra	PrintLoop

WordArray:	ds.w	40