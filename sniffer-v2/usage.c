#include <stdio.h>
#include <usage.h>


void usage()
{
	printf("\nPacket Sniffer \n" );
	printf("\nUsage: ./packetsniffer [OPTIONS]\n");
	printf("\nOPTIONS:\n"
		" -S, --smac MAC       Filter by the source mac-address\n"
		" -D, --dmac MAC       FIlter by the destination mac-address\n"
		" -I, --sip  IP	      Filter by the source IP\n"
		" -J, --dip IP	      FIlter by the destination IP\n"
		" -P, --sport PORT     FIlter by the source port\n"
		" -R, --dport PORT     FIlter by the destination port\n"
		" -H, --help	      Display this help\n"
	);
}
