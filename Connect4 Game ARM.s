	.equ SWI_Exit, 0x11
	.equ SWI_DISPLAY, 0x204
	.equ SWI_DISPLAY_CHAR, 0x207
	.equ SWI_CheckBlue, 0x203
	.equ SWI_SETLED, 0x201
	.equ SWI_CLEAR_LINE, 0x208

	.equ BLUE_KEY_00, 0x01 @button(0)
	.equ BLUE_KEY_01, 0x02 @button(1)
	.equ BLUE_KEY_02, 0x04 @button(2)
	.equ BLUE_KEY_03, 0x08 @button(3)
	.equ BLUE_KEY_04, 0x10 @button(4)
	.equ BLUE_KEY_05, 0x20 @button(5)
	.equ BLUE_KEY_06, 0x40 @button(6)
	.equ BLUE_KEY_07, 0x80 @button(7)
	.equ BLUE_KEY_08, 1<<8 @button(8) 
	.equ BLUE_KEY_09, 1<<9 @button(9)
	.equ BLUE_KEY_10, 1<<10 @button(10)
	.equ BLUE_KEY_11, 1<<11 @button(11)
	.equ BLUE_KEY_12, 1<<12 @button(12)
	.equ BLUE_KEY_13, 1<<13 @button(13)
	.equ BLUE_KEY_14, 1<<14 @button(14)
	.equ BLUE_KEY_15, 1<<15 @button(15)
	.text

_Start:
	mov r0,#8
	swi SWI_CLEAR_LINE
	mov r10,#0
	mov r7,#7
	mov r3,#0 @i
	mov r5, #0
	ldr r12, =BOARD
	fori:
		mov r4,#0 @j
		forj:
			@mul r5,r7,r3
			@add r5, r5, r4
			str r10,[r12,r5]

			mov r0, r4
			mov r1, r3
			add r2, r10, #'0
			swi SWI_DISPLAY_CHAR

			add r4,r4,#1
			add r5, r5, #4
			cmp r4, r7
			blt forj
		add r3, r3, #1
		cmp r3, #6
		blt fori

	mov r10,#0   @r10 is turn
	@printBoard()
	mov r7,#7   @NCOLUMN
	

for1:
	for2: @while
		@taketurn argument: r11
		mov r11,#1
		and r11,r10,r11 @ and of turn and 1
		add r11,r11,#1
		bl takeTurn    @output in r6

		cmp r6,#1
		beq noLoop

		cmp r6,#0
		bne cmp2
	    mov r0,#0
		mov r1,#8
		ldr r2,=ColumnFull
		swi SWI_DISPLAY
		b for2

  cmp2: cmp r6,#-1
		mov r0,#0
		mov r1,#8
		ldr r2,=ColumnInvalid
		swi SWI_DISPLAY
		b for2

noLoop:	mov r8,#0   @r8 is win
		bl checkwin  
		@checkwin()   output in r8

		cmp r8,#1
		beq breakLoop   @break statement

		add r10,r10,#1    @incrementing turn by 1
		cmp r10,#42       @ comparing with NROW*NCOLUMN
		blt for1        @outer for loop

breakLoop: cmp r8,#1
		   bne boardFull
		   mov r0,#0
		   mov r1,#8
		   ldr r2, =GAMEOVER
		   swi SWI_DISPLAY

			mov r11,#1
			and r11,r10,r11 @ and of turn and 1
			add r11,r11,#1
		   cmp r11,#1
		   bne rightled
		   mov r0, #22
		   mov r1, #8
		   add r2, r11, #'0
		   swi SWI_DISPLAY_CHAR
           mov r0, #0x02    @left LED for player 1 win
		   swi SWI_SETLED
		   b exit1

rightled:  mov r0, #0x01    @right LED for player 2 win
		   swi SWI_SETLED
		   mov r0, #22
		   mov r1, #8
		   add r2, r11, #'0
		   swi SWI_DISPLAY_CHAR
		   b exit1
		   

boardFull: mov r0,#0
		   mov r1,#8
		   ldr r2,=FULLBOARD
		   swi SWI_DISPLAY
		   b exit1		   

exit1:	
		swi SWI_CheckBlue @get button press into R0
		cmp r0,#0
		beq BB1 @ if zero, no button pressed

		cmp r0,#BLUE_KEY_15
		beq _Start
		@swi SWI_Exit

takeTurn: 
	@printf("Player %d, enter column: ", player);

	BB1:
		swi SWI_CheckBlue @get button press into R0
	cmp r0,#0
	beq BB1 @ if zero, no button pressed

	cmp r0,#BLUE_KEY_15
	beq _Start
	cmp r0,#BLUE_KEY_06
	beq SIX
	cmp r0,#BLUE_KEY_05
	beq FIVE
	cmp r0,#BLUE_KEY_04
	beq FOUR
	cmp r0,#BLUE_KEY_03
	beq THREE
	cmp r0,#BLUE_KEY_02
	beq TWO
	cmp r0,#BLUE_KEY_01
	beq ONE
	cmp r0,#BLUE_KEY_00
	beq ZERO
	b invalid_column

ZERO:
mov r4,#0
b check_board
ONE:
mov r4,#1
b check_board
TWO:
mov r4,#2
b check_board
THREE:
mov r4,#3
b check_board
FOUR:
mov r4,#4
b check_board
FIVE:
mov r4,#5
b check_board
SIX:
mov r4,#6

check_board: 
	mov r0,#8
	swi SWI_CLEAR_LINE

	ldr r12, =BOARD
	mov r3,#5 @row
	@r4 is column
	for_row: 
		mul r8, r7, r3
		add r8, r8, r4
		ldr r9,[r12,r8,LSL #2]
		cmp r9,#0
		beq set_board
		sub r3, r3, #1
		cmp r3,#0
		bge for_row
		mov r6,#0 @return 0
		mov pc,lr	

set_board: 
	@mov r11,#2
	str r11,[r12,r8,LSL #2]
	mov r6,#1 @return 0
	mov r0, r4
	mov r1, r3
	add r2, r11, #'0
	swi SWI_DISPLAY_CHAR
	mov pc,lr

invalid_column:
	mov r6, #-1
	mov pc,lr



checkwin: @returns r8

	mov r3,#0 @row
	mov r12,#0 @idx
	@horizontal_check:
			forcw1:
				mov r4,#0 @col
				mov r7,#7
				forcw2:
					mla r12,r7,r3,r4
					ldr r6, =BOARD
					ldr r9,[r6,r12,LSL #2]    @Board[idx]
					cmp r9,#0
					beq increment1
					add r12,r12,#1
					ldr r7,[r6,r12,LSL #2]    @Board[idx+1]
					cmp r9,r7                 
					bne increment1
					add r12,r12,#1
					ldr r9,[r6,r12,LSL #2]    @Board[idx+2]
					cmp r9,r7
					bne increment1
					add r12,r12,#1
					ldr r7,[r6,r12,LSL #2]    @Board[idx+3]
					cmp r9,r7
					bne increment1
					mov r8,#1
					b outwin

					@checkFour condition
increment1:			mov r7,#7
					add r4,r4,#1
					cmp r4,#4
					blt forcw2

				add r3,r3,#1
				cmp r3,#6
				blt forcw1

	mov r3,#0 @row
	mov r12,#0 @idx

	@vertical_check:
		forcw3:
			mov r4,#0  @col
			mov r7,#7
			forcw4:
					mla r12,r7,r3,r4
					ldr r6, =BOARD
					ldr r9,[r6,r12,LSL #2]    @Board[idx]
					cmp r9,#0
					beq increment2
					add r12,r12,#7
					ldr r7,[r6,r12,LSL #2]    @Board[idx+7]
					cmp r9,r7                 
					bne increment2
					add r12,r12,#7
					ldr r9,[r6,r12,LSL #2]    @Board[idx+7*2]
					cmp r9,r7
					bne increment2
					add r12,r12,#7
					ldr r7,[r6,r12,LSL #2]    @Board[idx+7*3]
					cmp r9,r7
					bne increment2
					mov r8,#1
					b outwin
					
increment2:			
					mov r7,#7
					add r4,r4,#1
					cmp r4,#7
					blt forcw4

				add r3,r3,#1
				cmp r3,#3
				blt forcw3

	mov r3,#0 @row
	mov r12,#0 @idx

	@diagonal_check:
		forcw5:
			mov r4,#0  @col
			mov r7,#7
			forcw6:
					mla r12,r7,r3,r4
					cmp r4,#3
					bgt check2
					ldr r6, =BOARD
					ldr r9,[r6,r12,LSL #2]    @Board[idx]
					cmp r9,#0
					beq check2
					add r12,r12,#8
					ldr r7,[r6,r12,LSL #2]    @Board[idx+8]
					cmp r9,r7                 
					bne check2
					add r12,r12,#8
					ldr r9,[r6,r12,LSL #2]    @Board[idx+8*2]
					cmp r9,r7
					bne check2
					add r12,r12,#8
					ldr r7,[r6,r12,LSL #2]    @Board[idx+8*3]
					cmp r9,r7
					bne check2
					mov r8,#1
					b outwin

					@checkFour condition
check2:				cmp r4,#3
					blt checkEnd
					mov r7,#7
					mla r12,r7,r3,r4					
					ldr r6, =BOARD
					ldr r9,[r6,r12,LSL #2]    @Board[idx]
					cmp r9,#0
					beq checkEnd
					add r12,r12,#6
					ldr r7,[r6,r12,LSL #2]    @Board[idx+6]
					cmp r9,r7                 
					bne checkEnd
					add r12,r12,#6
					ldr r9,[r6,r12,LSL #2]    @Board[idx+6*2]
					cmp r9,r7
					bne checkEnd
					add r12,r12,#6
					ldr r7,[r6,r12,LSL #2]    @Board[idx+6*3]
					cmp r9,r7
					bne checkEnd
					mov r8,#1
					b outwin


checkEnd: 			mov r7,#7
					add r4,r4,#1
					cmp r4,#7
					blt forcw6

				add r3,r3,#1
				cmp r3,#3
				blt forcw5

outwin: mov pc,lr

	.data
BOARD:  .space 400
ColumnFull: .asciz "Column is Full\n"
ColumnInvalid: .asciz "Invalid Column\n"
FULLBOARD: .asciz "Board is full\n"
GAMEOVER: .asciz "Game Over!! Winner is "
	.end

