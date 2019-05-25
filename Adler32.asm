#to do:
#controllare che B non vada in overflow
#controllare che le stringhe non intasino la memoria
#scoprire limite massimo lunghezza stringa letta

.data
	str0: .asciiz "*****Calcolatore di Checksum (Codifica Adler32)*****\n"
	str1: .asciiz "Inserisci una stringa di testo:\n"
	str2: .asciiz "Il valore di Checksum di questa stringa è: "
	
.text
#__start:
main:
	li $v0, 4		#il codice chiamata 4 corrisponde alla scrittura a schermo di una stringa
	la $a0, str0		#sposta l'indirizzo di str0 in $a0 per utilizzare la syscall
	syscall
	
	li $v0, 4
	la $a0, str1
	syscall
	
	li $v0, 8		#il codice chiamata 8 corrisponde alla lettura di una stringa
	li $a0, 0x100100f0	#$a0 = indirizzo base della stringa letta, parte dalla prima locazione libera dopo gli str
	li $a1, 50		#$a1 = lunghezza massima stringa meno 1 (in caso di riempimento viene riservato uno spazio per lo 0 ('null'))
	syscall
	
	la $t0, ($a0)		#carica l'indirizzo della stringa letta in $t0
	li $t2, 1 		#inizializza SommaA in $t2 con il valore 1
	li $t3, 0 		#inizializza SommaB in $t3 con il valore 0
	j loop
	
loop: 
###Carica un carattere alla volta della stringa letta e valuta se la stringa è conclusa

	lb $t1, 0($t0)		#carica un carattere della stringa letta alla posizione $t1
	beq $t1, 0xa, modulo	#se il valore di $t1 corrisponde a 'Invio' in ascii salta a modulo
	beq $t1, $zero, modulo	#se il valore di $t1 corrisponde a 'null' in ascii salta a modulo
	add $t2, $t2, $t1	#SommaA = SommaA + carattere ascii
	add $t3, $t3, $t2	#SommaB = SommaB + SommaA  
	
	addi $t0, $t0, 1	#incrementa di 1 byte l'indirizzo contenuto in $t0, passando al carattere successivo
	j loop
	
modulo:
###Esegue le operazioni finali di calcolo resto, shift e stampa del risultato

	move $s0, $t2		#salva le somme finali in registri non riscrivibili
	move $s1, $t3
	
	move $a0, $s0		#sposta la prima somma in un registro parametro per funzione
	jal calcolo_resto
	move $s2, $v0		#salva il resto ottenuto in un registro non riscrivibile
	
	move $a0, $s1		#sposta la seconda somma in un registro parametro per funzione
	jal calcolo_resto
	sll $s3, $v0, 16	#salva il resto, con shift logico di 16, in un registro non riscrivibile 
	
	add $s4, $s3, $s2	#somma i resti ottenuti
	
	li $v0, 4
	la $a0, str2
	syscall
	
	li $v0, 34		#il codice chiamata 34 corrisponde alla scrittura a schermo di un numero esadecimale
	move $a0, $s4
	syscall
	j exit
	
calcolo_resto:
###Calcola il resto della divisione tra un numero passato come argomento e 65521

	li $t0, 65521		#65521 è il maggiore numero primo contenuto in 32 bit 
	div $t1, $a0, $t0	#mette il risultato della divisione (intero) in $t1
	mul $t2, $t0, $t1	#mette il prodotto tra il divisore e il risultato in $t2
	sub $v0, $a0, $t2	#mette il resto in $v0
	jr $ra
	
exit:
###Esce dal programma