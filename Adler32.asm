#TODO:
#1) Modificare il README, il numero di caratteri è 196563 in quanto partiamo dall'indirizzo 0x1001002c
#   e abbiamo a disposizione fino a 0x1003ffff
#2) Non mi piace il fatto che rest_calc utilizzi registri temporanei t6 e t7 per non rovinare il loop
#3) Studiare come la somma B aumenta ed eventualmente inserire unsigned 
#) Inserire macro per evitare magic numbers? (Three....is the magic numba!)


.data
	str1: .asciiz "Il valore di Checksum di questa stringa è: "
	str0: .asciiz "*****Calcolatore di Checksum (Codifica Adler32)*****\nInserisci una stringa di testo:\n"
	
	
.text
__start:
##Inizio del programma

	li $v0, 4		#il codice chiamata 4 corrisponde alla scrittura a schermo di una stringa
	la $a0, str0		#sposta l'indirizzo di str0 in $a0 per utilizzare la syscall
	syscall
	
	li $v0, 8		#il codice chiamata 8 corrisponde alla lettura di una stringa
	la $a0, 0x1001002c	#$a0 = indirizzo base della stringa letta, verrà sovrascritto str0 ma non str1 che serve dopo
	li $a1, 0x1003ffff	#$a1 = lunghezza massima stringa nel .data meno 1 byte (in caso di riempimento viene riservato uno spazio per lo 0 ('null'))
	syscall
	
	la $t0, ($a0)		#carica l'indirizzo della stringa letta in $t0
	li $t2, 1 		#inizializza SommaA in $t2 con il valore 1
	li $t3, 0 		#inizializza SommaB in $t3 con il valore 0
	
	lui $s7, 0x0fff		#carica un numero alto per il successivo confronto con SommaB, evita overflow
	li $s6, 65521		#65521 è il maggiore numero primo contenuto in 16 bit, serve per resto 
	
loop: 
###Carica un carattere della stringa letta alla volta, calcola le somme, valuta se la stringa è conclusa

	lbu $t1, 0($t0)		#carica un carattere della stringa letta alla posizione $t1
	beq $t1, 0xa, finish	#se il valore di $t1 corrisponde a 'Invio' in ascii salta a finish
	beq $t1, $zero, finish	#se il valore di $t1 corrisponde a 'null' in ascii salta a finish
	add $t2, $t2, $t1	#SommaA = SommaA + carattere ascii
	add $t3, $t3, $t2	#SommaB = SommaB + SommaA
	
	slt $t4, $t3, $s7	#controlla se $t3 raggiunge $s7 (0x0fff0000)
	bne $t4, $zero, skip	#se SLT ha restituito 1 non calcola il resto

	move $a0, $t3 		#copia SommaB in $a0
	jal rest_calc
	move $t3, $v0		#sovrascrive SommaB col resto dato da rest_calc
	
	skip:
	addi $t0, $t0, 1	#incrementa di 1 byte l'indirizzo contenuto in $t0, passando al carattere successivo
	j loop
	
finish:
###Esegue le operazioni finali di calcolo resto, shift e stampa del risultato

	move $s0, $t2		#salva le somme finali in registri non riscrivibili
	move $s1, $t3
	
	move $a0, $s0		#sposta la prima somma in un registro parametro per funzione
	jal rest_calc
	move $s2, $v0		#salva il resto ottenuto in un registro non riscrivibile
	
	move $a0, $s1		#sposta la seconda somma in un registro parametro per funzione
	jal rest_calc
	sll $s3, $v0, 16	#salva il resto ottenuto, con shift logico di 16, in un registro non riscrivibile 
	
	add $s4, $s3, $s2	#somma i resti ottenuti, ottenendo le cifre di codifica Adler finali
	
	li $v0, 4
	la $a0, str1
	syscall
	
	li $v0, 34		#il codice chiamata 34 corrisponde alla scrittura a schermo di un numero binario in esadecimale
	move $a0, $s4
	syscall	
exit:	
	addi $v0, $zero, 10	#il codice chiamata 10 corrisponde all'uscita dal programma, che termina
	syscall
	
rest_calc:
###Calcola il resto della divisione tra un numero passato come argomento e 65521

	div $t7, $a0, $s6	#mette il risultato della divisione (intero) in $t1
	mul $t8, $s6, $t7	#mette il prodotto tra il divisore e il risultato in $t2
	sub $v0, $a0, $t8	#mette il resto in $v0
	jr $ra
