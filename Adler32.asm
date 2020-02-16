.data 0x10010000
	str0: .asciiz "*****Calcolatore di Checksum (Adler32)*****\nInserisci una stringa di testo: "
	str1: .asciiz "\nIl valore di Checksum di questa stringa è: "
	str2: .asciiz "Nessun input"
	
.data 0x10010088
	base: .space 1024	#Alloca 1KB in memoria RAM per accogliere i caratteri
		
.text
start:
###Inizio del programma
	li $v0, 4		#il codice chiamata 4 corrisponde alla scrittura a schermo di una stringa
	la $a0, str0		#sposta l'indirizzo di str0 in $a0 per utilizzare la syscall
	syscall			#stampa a schermo la stringa di benvenuto
	
	li $v0, 8		#il codice chiamata 8 corrisponde alla lettura di una stringa
	la $a0, base		#indirizzo base della stringa letta, all'inizio della memoria dinamica
	li $a1, 1024		#lunghezza massima stringa
	syscall			#legge la stringa da tastiera
	
	la $s0, base		#carica l'indirizzo della stringa letta in $s0
	li $s1, 1 		#inizializza SommaA in $s1 con il valore 1
	li $s2, 0 		#inizializza SommaB in $s2 con il valore 0
	
	li $s6, 65521		#65521 è il maggiore numero primo contenuto in 16 bit, serve per il calcolo del resto 
	lui $s7, 0x7000		#evita che si verifichi il problema dell'overflow forzando il calcolo del resto per somme grandi	

loop: 
###Carica un carattere della stringa letta alla volta, valuta se la stringa è conclusa, calcola le somme, se SommaB supera $s7 ne calcola il resto 
	lbu $t0, 0($s0)		#carica un carattere della stringa letta alla posizione $s0
	
	beq $t0, 0xa, finish	#se il valore di $t0 corrisponde a 'Invio'(0xa) in ascii salta a finish
	beq $t0, $zero, finish	#se il valore di $t0 corrisponde a 'null'(0) in ascii salta a finish
	addu $s1, $s1, $t0	#SommaA = SommaA + carattere ascii
	addu $s2, $s2, $s1	#SommaB = SommaB + SommaA
	
	slt $t1, $s2, $s7	#controlla se SommaB raggiunge $s7
	bne $t1, $zero, skip	#se SLT ha restituito 1 non calcola il resto

	rem $s1, $s1, $s6	#calcola il resto della divisione tra $s1 e $s6
	rem $s2, $s2, $s6	#calcola il resto della divisione tra $s2 e $s6
	
skip:
###Salta la fase di calcolo dei resti	
	addi $s0, $s0, 1	#incrementa di 1 byte l'indirizzo contenuto in $s0, passando al carattere successivo
	j loop			#ritorna al ciclo
		
finish:
###Esegue le operazioni finali di calcolo resto, shift e stampa del risultato
	la $t0, base		#carica indirizzo base della stringa letta per confronto
	beq $s0, $t0, noinput	#verifica che sia stata inserita una stringa
	
	rem $s1, $s1, $s6 	#calcola il resto della divisione tra $s1 e $s6
	rem $s2, $s2, $s6	#calcola il resto della divisione tra $s2 e $s6
	
	sll $s2, $s2, 16	#sovrascrive SommaB con shift logico di 16
	
	add $s3, $s2, $s1	#somma i resti ottenuti, ottenendo le cifre di codifica Adler finali
	
	li $v0, 4		#il codice chiamata 4 corrisponde alla scrittura a schermo di una stringa
	la $a0, str1		#stampa a schermo la stringa di introduzione del risultato
	syscall
	
	li $v0, 34		#il codice chiamata 34 corrisponde alla scrittura a schermo di un numero binario in esadecimale
	move $a0, $s3		#sposta il risultato in $a0 per l'utilizzo della syscall
	syscall			#stampa a schermo il risultato
	j exit	
	
noinput:
###Non è stato inserico alcun input al programma
	li $v0, 4		#il codice chiamata 4 corrisponde alla scrittura a schermo di una stringa
	la $a0, str2		#sposta l'indirizzo di str2 in $a0 per utilizzare la syscall
	syscall			#stampa a schermo la stringa di noinput
	
exit:	addi $v0, $zero, 10	#il codice chiamata 10 corrisponde all'uscita dal programma, che termina
	syscall			#esce dal programma