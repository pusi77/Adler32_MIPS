# Adler32 MIPS
Implementazione dell'algoritmo Adler-32 in Assembly MIPS

# Adler-32
## Introduzione
L'Adler-32 è un algoritmo per il calcolo del *checksum* (o somma di controllo) sviluppato da Mark Adler nel 1995. [Qui](https://en.wikipedia.org/wiki/Adler-32) si possono trovare maggiori informazioni.
## Algoritmo
Data una stringa di byte D con lunghezza n, data A la somma del valore Ascii di ogni byte più 1 e B la somma dei valori di A per ogni passaggio:
```
A = 1 + D1 + D2 + ... + Dn (mod 65521)

B = (1 + D1) + (1 + D1 + D2) + ... + (1 + D1 + D2 + ... + Dn) (mod 65521)
  = n×D1 + (n−1)×D2 + (n−2)×D3 + ... + Dn + n (mod 65521)

Adler-32(D) = B × 65536 + A
```
### Esempio:
| Character | ASCII Code | A | B |
| ------ | ------ | ------ | ------ |
| W | 87 | A1 = 1 + 87 = 88 | B1 = A1 = 88|
| i | 105 | A2 = A1 + 105 = 193 | B2 = B1 + A2 = 281 | 
| k | 107 | A3 = A2 + 107 = 300 | B3 = B2 + A3 = 581 |
| i | 105 | A4 = A3 + 105 = 405 | B4 = B3 + A4 = 986 | 
| p | 112 | A5 = A4 + 112 = 517 | B5 = B4 + A5 = 1503 |
| e | 101 | A6 = A5 + 101 = 618 | B6 = B5 + A6 = 2121 |
| d | 100 | A7 = A6 + 100 = 718 | B7 = B6 + A7 = 2839 |
| i | 105 | A8 = A7 + 105 = 823 | B8 = B7 + A8 = 3662 |
| a | 97 | A9 = A8 + 97 = 920 | B9 = B8 + A9 = 4582 |
```
A =  920 =  0x398  (base 16)
B = 4582 = 0x11E6
Output = 0x11E6 << 16 + 0x398 = 0x11E60398
```


