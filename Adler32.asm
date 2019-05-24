#to do:
#tradurre risultato da decimale a esadecimale
#controllare che B non vada in overflow
#controllare che le stringhe non intasino la memoria


.data
	stringa:	.asciiz "Wikipedia"	#grazie a .asciiz la stringa termina automaticamente con 'null'
	str0: .asciiz "*****Calcolatore di Checksum (Codifica Adler32)*****\n"
	str1: .asciiz "Inserisci una stringa di testo:\n"
	str2: .asciiz "Il valore di Checksum di questa stringa �: 0x"
	
.text
#__start:
main:
	li $v0, 4	#il codice chiamata 4 corrisponde alla scrittura di str0
	la $a0, str0
	syscall
	
	li $v0, 4
	la $a0, str1
	syscall
	
	li $v0, 8
	li $a0, 0x100100f0	#$a0 = indirizzo base, parte dalla prima locazione libera dopo gli str
	li $a1, 50		#$a1 = lunghezza massima stringa meno 1 (in caso di riempimento viene riservato uno spazio per lo 0 ('null'))
	syscall
	
	la $t0, ($a0)
	li $t2, 1 	#inizializza SommaA in $t2 con il valore 1
	li $t3, 0 	#inizializza SommaB in $t3 con il valore 0
	j loop
loop: 
	lb $t1, 0($t0)		#carica la lettera alla posizione $t1
	beq $t1, 0xa, modulo	#se il valore di $t1 corrisponde a 'Invio' in ascii salta a modulo
	beq $t1, $zero, modulo	#se il valore di $t1 corrisponde a 'null' in ascii salta a modulo
	add $t2, $t2, $t1	#SommaA = SommaA + carattere ascii
	add $t3, $t3, $t2	#SommaB = SommaB + SommaA  
	
	addi $t0, $t0, 1	#incrementa di 1 byte (un carattere ascii) l'indirizzo contenuto in $t0
	j loop
	
modulo:
	move $s0, $t2		#spostiamo le somme finali in registri non riscrivibili
	move $s1, $t3
	
	move $a0, $s0		#mettiamo la prima somma in un registro parametro per funzione
	jal calcolo_resto
	move $s2, $v0		#salviamo il resto nel registro non riscrivibile
	
	move $a0, $s1		#mettiamo la seconda somma in un registro parametro per funzione
	jal calcolo_resto
	sll $s3, $v0, 16	#salviamo il resto, con shift logico di 16, nel registro non riscrivibile 
	
	add $s4, $s3, $s2
	
	li $v0, 4
	la $a0, str2
	syscall
	
	li $v0, 1
	move $a0, $s4
	syscall
	j exit
	
calcolo_resto:

	li $t0, 65521		#65521 � il maggiore numero primo contenuto in 32 bit 
	div $t1, $a0, $t0	#mette il risultato della divisione (intero) in $t1
	mul $t2, $t0, $t1	#mette il prodotto tra il divisore e il risultato in $t2
	sub $v0, $a0, $t2	#mette il resto in $v0
	jr $ra
	
exit:
