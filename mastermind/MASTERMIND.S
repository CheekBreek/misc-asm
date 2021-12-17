;The program receives a text file named TEXT.txt
;which contains a set of codes to be used in the
;program. The program then simulates the game
;Mastermind.
;	
;Details:
;The program requires a text file named TEXT.txt
;which the program uses to format into a fully
;justified format.
;Assumptions:
; - There is at least 1 code
; - The codes are 4 digits long and seperated by a newline
;
;Program Status:
;The program has been tested and is working.
;One quirk is that the program terminates the current guess
;if any illegal colour is inputted instead of waiting for
;all 4 digits of the code before printing the message.
;Test Plan:
;Code	   Type			Input	Result
;rrrr	All the same		rrmm	 2  0
;				rrrr	Congrats
;rrmm	Different digits	rrrr	 2  0
;				mmrr	 0  4
;				rrmm	Congrats
;mmpp	Multiple Codes,		mpmp	 2  2
;mpmp	Play again		mmpp	Congrats
;					   y
;				mmpp	 2  2
;				mpmp	Congrats
;mmpp	Multiple Codes,		mpmp	 2  2
;mpmp	Don't play again	mmpp	Congrats
;					   n
;yyym	Out of guesses		mmmm	 1  0
;				yymm	 3  0
;				mmyy	 1  2
;				mymy	 1  2
;				ymym	 3  0
;				rbrb	 0  0
;				bbrr	 0  0
;				mmrr	 0  1
;				rbmm	 1  0
;				mrbm	 1  0		
;					Out of guesses, Correct code: yyym
;
;Register Table:
;d0 - Used of I/O of data
;d1 - Holds the amount of characters in the text document
;d2 - Used as a counter for counted loops
;d3 - Used for counting the amount of guesses
;d4 - Used for counting the guess's matching colours
;d5 - Holds the guess values for comparison
;d6 - Holds the answer values for comparison
;d7 - Used for counting the guess's exact matchs
;
;a0 - Used for writing out messages to the screen
;     Holds the guess values for comparison
;a1 - Holds the answer values for comparison
;a2 - Used for storing the amount of each colour for guess and answer
;

		xref	FileOpen
		xref	FileReset
		xref	FileClose
		xref	FileCharRead
		xref	Exit
		xref	KbdCharRead
		xref	ScrnCharWrite

start:		bsr	FileOpen	;Opens the file and checks
		move.w	#'0',d3		;if it was successfully opened.
		lea	StartMsg,a0
		cmpi.w	#0,d0
		beq	PrintStartMsg
		bsr	FileClose
		bsr	Exit

PrintStartMsg:	move.b	(a0)+,d0	;Prints out the intro message.
		beq	DoneWrite
		bsr	ScrnCharWrite
		bra	PrintStartMsg

Reset:		move.b	#CR,d0		;Prints of a newline and
		bsr	ScrnCharWrite	;the labels for the next round.
		move.b	#LF,d0
		bsr	ScrnCharWrite
		move.b	#CR,d0
		bsr	ScrnCharWrite
		move.b	#LF,d0
		bsr	ScrnCharWrite
		lea	Labels,a0
PrintLabels:	move.b	(a0)+,d0
		beq	DoneWrite
		bsr	ScrnCharWrite
		bra	PrintLabels

DoneWrite:	lea	Answer,a0
		move.w	#'0',d3
AnswerRead:	bsr	FileCharRead	;Reads in the answer from the
		sub.w	#1,d1		;text file.
		cmpi.w	#CR,d0		;Stops reading when a newline
		beq.s	AnswerRead	;is encountered.
		cmpi.w	#LF,d0
		beq.s	GuessStart
		lea	AnswerColour,a2
		bra	ColourStore
AnswerReturn:	move.w	d0,(a0)+
		cmpi.w	#0,d1
		beq.s	GuessStart
		bra	AnswerRead

GuessStart:	move.w	#0,d2		;Reads in the user's guess.
		addi.w	#1,d3		;Also counts the amount of digits.
		lea	Guess,a0
		jmp	PrintGuessNum
GuessRead:	bsr	KbdCharRead
		lea	GuessColour,a2
		bra	ColourStore
GuessReturn:	move.w	d0,(a0)+
		addi.w	#1,d2
		cmpi.w	#4,d2
		bne	GuessRead

		lea	GuessColour,a0	;Compares the answer and guess colour
		lea	AnswerColour,a1	;arrays and calculates the number of
		move.l	#0,d2		;matching colours.
		move.l	#0,d4
ColourMatch:	move.w	(a0),d5
		move.w	#0,(a0)+
		move.w	(a1)+,d6
		cmp.w	d5,d6
		blt	AddAnswerClr	;If the amount of guess colours is
		add.w	d5,d4		;greater than the amount of answer
		bra	CMAfter		;colours, add the amount of answer
AddAnswerClr:	add.w	d6,d4		;colours to counter. Otherwise
CMAfter:	addi.w	#1,d2		;do the opposite.
		cmpi.w	#6,d2
		bne	ColourMatch

		lea	Guess,a0	;Compares the answer and guess arrays
		lea	Answer,a1	;and calculates the number of exact
		move.l	#0,d2		;guess digits.
		move.l	#0,d7
ExactMatch:	move.w	(a0)+,d5
		move.w	(a1)+,d6
		cmp.w	d5,d6
		bne	EMAfter
		addi.w	#1,d7
		bra	EMAfter
EMAfter:	addi.w	#1,d2
		cmpi.w	#4,d2
		bne	ExactMatch

		sub.w	d7,d4		;Adjusts the colour count
		addi.w	#'0',d4		;and masks the exact and colour count
		addi.w	#'0',d7		;with 0x0F.
		cmpi.w	#'4',d7		;Also checks if the guess is correct.
		beq	Correct
		move.l	#' ',d0
		bsr	ScrnCharWrite	;Prints the exact and colour count
		bsr	ScrnCharWrite	;with spacing.
		bsr	ScrnCharWrite
		bsr	ScrnCharWrite
		move.w	d7,d0		
		bsr	ScrnCharWrite
		move.l	#' ',d0
		bsr	ScrnCharWrite
		bsr	ScrnCharWrite
		bsr	ScrnCharWrite
		bsr	ScrnCharWrite
		bsr	ScrnCharWrite
		bsr	ScrnCharWrite
		move.w	d4,d0
		bsr	ScrnCharWrite
		move.w	#CR,d0
		bsr	ScrnCharWrite
		move.w	#LF,d0
		bsr	ScrnCharWrite
		
GuessLimit:	cmpi.w	#':',d3		;Checks if 10 guesses has been
		bne	GuessStart	;reached.
		lea	OutOfGuessMsg,a0
GuessLimPrint:	move.b	(a0)+,d0
		beq	GuessLimPrinted
		bsr	ScrnCharWrite
		bra	GuessLimPrint
GuessLimPrinted:lea	Answer,a0
		move.w	#-1,d2
PrintAnswer:	move.w	(a0)+,d0
		addi.w	#1,d2
		cmpi	#4,d2
		beq	AnswerPrinted
		bsr	ScrnCharWrite
		bra	PrintAnswer
AnswerPrinted:	move.b	#CR,d0
		bsr 	ScrnCharWrite
		move.b	#LF,d0
		bsr	ScrnCharWrite
		jmp	PlayAgain

Correct:	move.w	#' ',d0		;Prints out the congratulations
		bsr	ScrnCharWrite	;message along with spacing.
		bsr	ScrnCharWrite
		bsr	ScrnCharWrite
		lea	CorrectMsg,a0
CorrectPrint:	move.b	(a0)+,d0
		beq	PlayAgain
		bsr	ScrnCharWrite
		bra	CorrectPrint

PlayAgain:	cmpi.w	#0,d1		;Checks if there is more codes.
		beq	End		;If so, asks if the user wishes to
		lea	PlayAgainMsg,a0	;play again.
PlayAgainPrint:	move.b	(a0)+,d0
		beq	PlayAgainCheck
		bsr	ScrnCharWrite
		bra	PlayAgainPrint
PlayAgainCheck:	bsr	KbdCharRead
		cmpi.w	#'y',d0
		beq	Reset

End:		bsr	KbdCharRead	;Closes the file and ends
		bsr	FileClose	;the program.
		bsr	Exit

PrintGuessNum:	move.l	#' ',d0		;Prints out the guess number
		bsr 	ScrnCharWrite	;and appropriate spacing.
		bsr	ScrnCharWrite	
		bsr	ScrnCharWrite
		cmpi.w	#':',d3
		beq	Print10
		move.l	d3,d0
		bsr	ScrnCharWrite
		move.l	#' ',d0
		bsr	ScrnCharWrite
		jmp	Print10After
Print10:	move.l	#'1',d0		;Changes the ascii value ':'
		bsr	ScrnCharWrite	;to 10 for printing.
		move.l	#'0',d0
		bsr	ScrnCharWrite
Print10After:	move.l	#' ',d0
		bsr	ScrnCharWrite
		bsr	ScrnCharWrite
		bsr	ScrnCharWrite
		jmp	GuessRead

InvalidColour:	lea	InvalidClrMsg,a0;Prints the invalid colour message
		subi.w	#1,d3		;to the screen.
		move.l	#' ',d0		;Also reduces the guess counter by 1.
		bsr	ScrnCharWrite
		bsr	ScrnCharWrite
InvalidPrint:	move.b	(a0)+,d0
		beq	GuessStart
		bsr	ScrnCharWrite
		bra	InvalidPrint

Return:		cmpi.w	#'0',d3		;Returns after the colour counter
		beq	AnswerReturn	;has been updated.
		bra	GuessReturn

ColourStore:	cmp	#'r',d0		;Checks for invalid characters
		beq.s	AddRed		;and updates the colour counter.
		cmp	#'b',d0
		beq.s	AddBlue
		cmp	#'g',d0
		beq.s	AddGreen
		cmp	#'y',d0
		beq.s	AddYellow
		cmp	#'m',d0
		beq.s	AddMagenta
		cmp	#'p',d0
		beq.s	AddPurple
		jmp	InvalidColour

AddRed:		adda.l	#RED,a2		;Updates the recieved colour digit's
		add.w	#1,(a2)		;count.
		jmp	Return
AddBlue:	adda.l	#BLUE,a2
		add.w	#1,(a2)
		jmp	Return
AddGreen:	adda.l	#GREEN,a2
		add.w	#1,(a2)
		jmp	Return
AddYellow:	adda.l	#YELLOW,a2
		add.w	#1,(a2)
		jmp	Return
AddMagenta:	adda.l	#MAGENTA,a2
		add.w	#1,(a2)
		jmp	Return
AddPurple:	adda.l	#PURPLE,a2
		add.w	#1,(a2)
		jmp	Return

COLOUR		equ	12
RED		equ	0
BLUE		equ	2
GREEN		equ	4
YELLOW		equ	6
MAGENTA		equ	8
PURPLE		equ	10
CR		equ	13
LF		equ	10
NULL		equ	0
Answer:		ds.w	4
Guess:		ds.w	4
AnswerColour:	ds.b	COLOUR
GuessColour:	ds.b	COLOUR
StartMsg:	dc.b	'         Welcome to my Mastermind game',CR,LF,CR,LF
		dc.b	'Mastermind is a game of code breaking. The computer'
		dc.b	CR,LF,'will generate a code for you to break.',CR,LF
		dc.b	CR,LF,'The code is composed of 4 characters being:'
		dc.b	CR,LF,'(r)ed, (b)lue, (g)reen, ' 
		dc.b	'(y)ellow, (m)agenta, & (p)urple',CR,LF
		dc.b	'with duplicate colours being allowed.',CR,LF,CR,LF
		dc.b	'You will enter guesses of exactly 4 lowercase '
		dc.b	'letters.',CR,LF,'Raw input is used so:',CR,LF
		dc.b	'do NOT press the ENTER key',CR,LF
		dc.b	'do NOT use backspace/delete keys',CR,LF
		dc.b	'Invalid colours are caught and will NOT count'
		dc.b	'as a guess.',CR,LF,CR,LF
		dc.b	'The computer will tell you how many exact matches'
		dc.b	CR,LF,'and colour matches are in your guess.',CR,LF
		dc.b	'A round terminates if you match all 4 colours or '
		dc.b	'exceed 10 guesses',CR,LF,CR,LF
Labels:		dc.b	'Attempt Guess Exact Colour',CR,LF,NULL
CorrectMsg:	dc.b	'Congratulations -- you have guessed correctly!'
		dc.b	CR,LF,NULL

InvalidClrMsg:	dc.b	'invalid colour selected - re-enter your guess'
		dc.b	CR,LF,NULL

OutOfGuessMsg:	dc.b	'You are out of guesses - the correct code was: ',NULL
PlayAgainMsg:	dc.b	CR,LF,'do you wish to play again? ',NULL