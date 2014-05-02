#include<netinet/in.h>
#include<netdb.h>
#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include<netinet/ip_icmp.h>
#include<netinet/udp.h>
#include<netinet/tcp.h>
#include<netinet/ip.h>
#include<net/ethernet.h>
#include<sys/socket.h>
#include<sys/time.h>
#include<sys/types.h>

#include<stdbool.h>
#include<arpa/inet.h>
#include<packetdump.h>
#include<utils.h>


int packetFilter( unsigned char *packet, struct inputOpt *opt)
{
	bool filter = 0;
	uint32_t sourceAddr;
        uint32_t destAddr;
	int *hex;
	int sizeHex;
	int i;
	
	if( opt->sourceMac == NULL && opt->destMac == NULL &&
	    opt->sourceIp == NULL && opt->destIp == NULL &&
	    opt->sourcePort == 0 && opt->destPort == 0
	  )
		 return filter;

	struct ethhdr *eth = (struct ethhdr *)packet;
	struct iphdr *ip =  (struct iphdr *)(packet + sizeof(struct ethhdr) );
        int iphdr_size = ip->ihl * 4;
        struct tcphdr *tcp = (struct tcphdr *)(packet + iphdr_size + sizeof(struct ethhdr) );


	if(opt->sourceMac != NULL){
		sizeHex = (int)strlen(opt->sourceMac );
        	hex = strtohex(opt->sourceMac, sizeHex,0);
		for(i=0; i< 6; i++)
		{
			if(eth->h_source[i] != hex[i]){
				filter = 1;
				break;
			}
		}
	}
	if(opt->destMac != NULL){
                sizeHex = (int)strlen(opt->destMac );
                hex = strtohex(opt->destMac, sizeHex,0);
                for(i=0; i< 6; i++)
                {
                        if(eth->h_dest[i] != hex[i]){
                                filter = 1;
                                break;
                        }
                }
        }

	
	if (opt->sourceIp != NULL){
		inet_pton(AF_INET, opt->sourceIp, &sourceAddr);
		if(ip->saddr != sourceAddr )
			filter = 1;
	}
	if( opt->destIp != NULL){
		inet_pton(AF_INET, opt->destIp, &destAddr);
		if(ip->daddr != destAddr )
			filter = 1;
	};

	
	if( opt->sourcePort != 0 && ntohs(tcp->source) != opt->sourcePort )
		filter = 1;
	if( opt->destPort != 0 && ntohs(tcp->dest) != opt->destPort )
                filter = 1;

	return filter;
}


void packetDump( unsigned char *packet, struct inputOpt *opt)
{
	bool filter;
	filter = packetFilter( packet, opt);	
	if (filter == 0)
	 	ethernetDump(packet);

}


void ethernetDump( unsigned char *packet)
{
        struct ethhdr *eth = (struct ethhdr *)packet;
        int i = 0;       	
        printf("->MAC-SOURCE:");
        for(i =0; i< 6; i++)
		if(i<5)
        		printf("%.2X-", eth->h_source[i]);
		else
			printf("%.2X", eth->h_source[i]);

        printf("\tMAC-DEST:");
       	for(i =0; i< 6; i++)
		if(i<5)
	               	printf("%.2X-", eth->h_dest[i]);
		else
			printf("%.2X", eth->h_source[i]);

       	switch( ntohs(eth->h_proto) ){
                	case ETH_P_IP:
                       	ipDump(packet);
                      	 break;

			default:
        	               printf(" \t Error, please update your network driver. \n");
  	}

}


void ipDump( unsigned char *packet)
{
        struct iphdr *ip =  (struct iphdr *)(packet + sizeof(struct ethhdr) );
        struct sockaddr_in source, dest;
        char sourceAddr[INET_ADDRSTRLEN];
        char destAddr[INET_ADDRSTRLEN];

	
        memset(&source, 0, sizeof(struct sockaddr_in) );
        memset(&dest, 0, sizeof(struct sockaddr_in) );
       
        source.sin_addr.s_addr = ip->saddr;
        dest.sin_addr.s_addr = ip->daddr;

        inet_ntop(AF_INET, &source.sin_addr.s_addr, sourceAddr, sizeof(sourceAddr) );
        inet_ntop(AF_INET, &dest.sin_addr.s_addr, destAddr, sizeof(sourceAddr) );

	printf("\tIP:%s\tIP%s", sourceAddr, destAddr);       
        switch(ip->protocol){
                case IP_TCP:
                        tcpDump(packet);
                        break;

		case IP_UDP:
			udpDump(packet);
			break;

                default:
                        printf(" \t Error, please update your network driver. \n");
        }

}



void tcpDump( unsigned char *packet)
{
        struct iphdr *ip =  (struct iphdr *)(packet + sizeof(struct ethhdr) );
        int iphdr_size = ip->ihl * 4;
        struct tcphdr *tcp = (struct tcphdr *)(packet + iphdr_size + sizeof(struct ethhdr) );
        printf("\tTCP:PORT:%u\tTCP:PORT:%u\n", ntohs(tcp->source), ntohs(tcp->dest) );
}


void udpDump( unsigned char *packet)
{
	struct iphdr *ip = (struct iphdr *)(packet + sizeof(struct ethhdr) );
	int iphdr_size = ip->ihl * 4;
	struct udphdr *udp = (struct udphdr *)(packet + iphdr_size + sizeof(struct ethhdr) );
	printf("\t UDP:PORT:%u\tUDP:PORT:%u\n",ntohs(udp->source), ntohs(udp->dest) );

}
