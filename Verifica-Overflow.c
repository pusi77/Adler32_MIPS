//Piccolo programma che calcola se B può raggiungere overflow prima del limite delle stringhe

#include <stdio.h>
#define Lim 196565					//È il numero massimo di caratteri della stringa memorizzabile
#define Overflow 2147483647			//È il numero massimo per cui B non va in overflow

int main() {
	int i, x = 127, A = 1, B = 0;	//x è il valore massimo di un carattere Ascii
	for (i = 0; i < Lim; i++) {
		A += x;
		B += B;
		if (B > Overflow) {break;}
	}
	printf("%i\n", i);
}

/*La risposta sarà che B non può andare in overflow perché non raggiunge mai il valore massimo
rappresentabile a 32 bit in complemento a 2, nemmeno con un input pari al massimo numero di 
caratteri di massimo valore in Ascii*/

	
	