#include<string.h>
#include<stdlib.h>
#include<config.h>


static struct option loption[]=
        {
                {"smac", 1, NULL, 'S'},
                {"dmac", 1, NULL, 'D'},
                {"sip",  1, NULL, 'I'},
                {"dip",  1, NULL, 'J'},
                {"sport",1, NULL, 'P'},
                {"dport",1, NULL, 'R'}, 
        };

	
struct inputOpt *parseOptions(int argc, char **argv)
{
	int cl_opts;
	char *options = "S:D:I:J:P:R:H:";	
	memset(&iopt, 0, sizeof(struct inputOpt) );
	for(;;)
	{        	
		if ((cl_opts = getopt_long(argc, argv, options, loption, NULL)) == -1)
		break;

		switch(cl_opts){
			case 'S':
				iopt.sourceMac = optarg;
				break;
			case 'D':
				iopt.destMac = optarg;
				break;
			case 'I':
				iopt.sourceIp = optarg;
				break;
			case 'J':
				iopt.destIp = optarg;
				break;
			case 'P':
				iopt.sourcePort = atoi(optarg);
				break;
			case 'R':
				iopt.destPort = atoi(optarg);
				break;

			default:
				return NULL;
		}
	}
 return &iopt;
}
