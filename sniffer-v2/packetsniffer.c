#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include<sys/socket.h>
#include <arpa/inet.h>

#include <packetdump.h>
#include  <usage.h>


int main(int argc, char **argv)
{
	int sockfd, sockaddr_size, recvd_data;
	struct sockaddr sourceAddr;
	unsigned char *packet = (unsigned char *) malloc(65535);
        struct inputOpt *opt;
	
 	
	 opt = parseOptions(argc, argv);
	if (opt == NULL){
		usage();
		exit(1);
	}
	
	memset(packet, 0, sizeof packet);	
	sockfd = socket( AF_PACKET, SOCK_RAW, htons(ETH_P_ALL) );
	if (sockfd == -1){
		printf("Error - cant start socket\n");
		exit(1);
		}
		
	sockaddr_size = sizeof( struct sockaddr );

	while( (recvd_data = recvfrom(sockfd , packet , 65536 , 0 , &sourceAddr , (socklen_t*)&sockaddr_size) ))	
	packetDump(packet, opt);
	exit(0);
}
