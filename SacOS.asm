[bits 16]
[org 0x7c00]
;*****************************************************************
%macro SET_CURSOR 2
	pusha		
		mov ah,02;
		mov dh,%1
		mov dl,%2
		int 10h
	popa
%endmacro

%macro SHELL_OPTION 1
	pusha		
		cmp %1,'a'
		jne OP_1;
		mov si,CMD_A
		call print_string

	OP_1:cmp %1,'b'
		jne OP_2;
		mov si,CMD_B
		call print_string
		
	OP_2:
		cmp %1,'s'
		call shut_down

	popa
%endmacro


;*****************************************************************

;section .data		;; Declare Constants
;	msg: db "Welcome To Sac OS" , 0
;	s1: db "Enter A character :" , 0	

;*****************************************************************

section .bss		;; Declare variable

	CHAR: resb 0x01
	STR: resb 0x100
	
;*****************************************************************

section  .text

	

BOOT_SCREEN:

	mov al,00h
	mov ah,0
	int 0x10


	SET_CURSOR 7,10
	mov si,BOOT_MSG
	call print_string
	
	mov ax,0x0fff
ll1:call wait_now
	sub ax,1
	cmp ax,0
	jne ll1


SHELL:

	mov al,00h
	mov ah,0
	int 0x10


	SET_CURSOR 7,10

	mov si,CMD
	call print_string

	xor al,al
	call read
	SHELL_OPTION al
	
	xor al,al
	call read

	jmp SHELL
		
	


	;; Functions

	next_line:
		pusha		
		mov ah,02;
		mov dh,7
		mov dl,10
		int 10h
		popa
		ret
	read:
		mov ah,00h
		int 16h
		mov [CHAR],al
		ret

	read_string:
		pusha
		mov ah,00h
	lpr:int 16h
		mov cx,0x0d
		cmp [si],cx
		je ex
		mov [si],al
		mov cx,1
		add si,cx
		jmp lpr
		popa
		ex: ret
		
	print_char:
			mov ah,0x0e
			mov al,[CHAR]
			int 0x10
			ret

	print_string:
		mov ah,0x0e
		lp: mov al,[si]
			int 0x10
			add si,1
			mov cl,0
			cmp [si],cl
			jne lp
			ret

	shut_down:
			mov ah,42h
			mov al,00h
			int 15h
			ret

	wait_now:
		pusha
			mov ax,0xffff			
		 l1:sub ax,1
			cmp ax,0000
			jne l1
			mov ax,0xffff			
		 l2:sub ax,1
			cmp ax,0000
			jne l2
		popa
		ret

	read_disk:
		pusha
			mov ah,0ah
			mov al,01
			mov ch,00
			mov cl,00
			mov dh,00
			mov dl,80h
			int 13h


		popa
		ret

	;; Infinite Loop

HOLD:	jmp $

BOOT_MSG: db "Welcome To Sac OS " , 0
CMD_A: db 0x0d , " You pressed A", 0
CMD_B: db 0x0d , " You pressed B ", 0
CMD: db 0x0d , "Enter Command : ", 0




;;Bootloader Area

times 510-($-$$) db 0;
dw 0xaa55;

