;	Author: Vivek Prakash
;	Year: 2011
;
;	Some part of code may be derived from other places that
;	I don't remember now!
;
; 	It ouptuts "Hello World!" when placed in the first sector
; 	of a hard disk primary partition. Or you can test it using
;	a virtual machine e.g. qemu/kvm.
;
;	Warning: May be still buggy, as I was just experimenting!
;
;	Compile: `nasm mbr.s -o mbr`
;	Run: `kvm mbr`

		xor ax, ax
		mov ds, ax
		mov es, ax
		cli
		mov ss, ax
		mov sp, 7C00h
		sti	
		mov bx, 000Fh   ;Page 0, colour attribute 15 (white) for the int 10 calls below
        mov cx, 1       ;We will want to write 1 character
		cld             ;Ensure direction flag is cleared (for LODSB)

		;org 7C00h

        jmp Start ;Jump over the data (the 'short' keyword makes the jmp instruction smaller)

Msg1:   db "Hello World! "
Newline:
		db "\r\n\0"
Msg2:	db "Hit any key to reboot. "
EndMsg:

Start: 	;xor dx, dx      ;Start at top left corner
		;xor ax, ax 
		;mov ds, ax     ;Ensure ds = 0 (to let us load the message)
       	call Greetings	

		mov si, Newline
		call Print

		call Reboot

Greetings:	
		mov si, Msg1
		call Print 

Reboot:	mov si, Msg2
		call Print	


;Print:  mov si, Msg1     ;Loads the address of the first byte of the message, 7C02h in this case

                        ;PC BIOS Interrupt 10 Subfunction 2 - Set cursor position
                        ;AH = 2
Print:
Char:   mov ah, 2       ;BH = page, DH = row, DL = column
        int 10h
        lodsb           ;Load a byte of the message into AL.
                        ;Remember that DS is 0 and SI holds the
                        ;offset of one of the bytes of the message.

                        ;PC BIOS Interrupt 10 Subfunction 9 - Write character and colour
                        ;AH = 9
        mov ah, 9       ;BH = page, AL = character, BL = attribute, CX = character count
        int 10h

        inc dl          ;Advance cursor

        cmp dl, 80      ;Wrap around edge of screen if necessary
        jne Skip
        xor dl, dl
        inc dh

        cmp dh, 25      ;Wrap around bottom of screen if necessary
        jne Skip
        xor dh, dh

Skip:   cmp si, EndMsg	;If we're not at end of message,
        jne Char        ;continue loading characters
        ;jmp Print       ;otherwise restart from the beginning of the message

;print_msg:
;prnext:	lodsb			; al = *si++ is char to be printed
;		test	al, al		; Null marks end
;		jz	prdone
;		mov	ah, 0x0E	; Print character in teletype mode
;		mov	bx, 0x0001	; Page 0, foreground color
;		int	0x10
;		jmp	prnext
;prdone:	jmp	(si)		; Continue after the string

times 0200h - 2 - ($ - $$)  db 0    ;Zerofill up to 510 bytes

        dw 0AA55h       ;Boot Sector signature
