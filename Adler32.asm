
.data
	stringa:	.asciiz "Wikipedia"	#grazie a .asciiz la stringa termina automaticamente con 'null'
	
.text
Main:
	la $t0, stringa		#salva l'indirizzo di stringa in $t0
	addi $t2, $zero, 1 	#inizializza SommaA in $t2 con il valore 1
	lb $t1, $t0		#carica la lettera alla posizione $t1
	
	j Loop
Loop: 
	beqz $t1, CalcoloSomma	#se l'indirizzo in $a0 corrisponde a 'null' ascii (ovvero 0) salta a CalcoloSomma
	add $t3, $t3, $t1	#SommaA = SommaA + carattere ascii
	add $t2, $t2, $t3	#SommaB = SommaB + SommaA  
	
	addi $t1, $t1, 1		#incrementa di 1 byte (un carattere ascii) l'indirizzo contenuto in $a0
	j Loop
	
CalcoloSomma:
	
