#ifndef CONFIG_H
#define CONFIG_H 

#include <getopt.h>
#include <linux/types.h>
#include <asm/byteorder.h>


static struct inputOpt {
	char *sourceMac;
	char *destMac;
	char *sourceIp;
        char *destIp;
	__be16  sourcePort;
        __be16  destPort;
}iopt;


struct inputOpt *parseOptions(int argc, char **argv);
#endif
