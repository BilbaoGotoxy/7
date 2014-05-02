#ifndef PACKETDUMP_H
#define PACKETDUMP_H 

#include<netinet/if_ether.h>
#include<utils.h>
#include<config.h>

#define IP_ICMP 1
#define IP_TCP 6
#define IP_UDP 17


void packetDump( unsigned char *packet, struct inputOpt *opt);
void ethernetDump( unsigned char *packet);
void ipDump( unsigned char *packet);
void tcpDump( unsigned char *packet);
void udpDump( unsigned char *packet);

#endif
