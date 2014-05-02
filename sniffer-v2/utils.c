#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <utils.h>


int *strtohex( char *string, int size, bool doubleNotation)
{
        int *hex = (int *)malloc( size);
        char ch;
        int i=0;
	int j=0;
	int *doubleHex= sbrk( (size/2) +1 );

        for (i=0; i< size; i++)
        {
                ch = string[i];
                switch(string[i])
                {
                        case 'A':
			case 'a':
                                hex[i] = 0xa; break;

                        case 'B':
                        case 'b':
                                hex[i] = 0xb; break;

                        case 'C':
                        case 'c':
                                hex[i] = 0xc; break;

                        case 'D':
                        case 'd':
                                hex[i] = 0xd; break;

                        case 'E':
                        case 'e':
                                hex[i] = 0xe; break;

                        case 'F':
                        case 'f':
                                hex[i] = 0xf; break;

                        case '0': hex[i] = 0x0; break;
                        case '1': hex[i] = 0x1; break;
                        case '2': hex[i] = 0x2; break;
                        case '3': hex[i] = 0x3; break;
                        case '4': hex[i] = 0x4; break;
                        case '5': hex[i] = 0x5; break;
                        case '6': hex[i] = 0x6; break;
                        case '7': hex[i] = 0x7; break;
                        case '8': hex[i] = 0x8; break;
                        case '9': hex[i] = 0x9; break;

                        default: return NULL;
                }


		if (i!= 0 && ( (i+1) % 2)==0){			
			doubleHex[j] = (hex[i-1]<<4) + hex[i];
			j++;
		}
        }
       if ((size%2)!=0) 
       		doubleHex[j] = (hex[i-1]<<4);
if(doubleNotation == 0)
	return doubleHex;
else
	return hex;
}
