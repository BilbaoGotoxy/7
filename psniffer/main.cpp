/*
RFC 768 User Datagram Protocol
RFC 791 Internet Protocol
RFC 792 Internet Control Message Protocol
RFC 793 Transmission Control Protocol
*/

#define MAX_PACKET_SIZE 65525
#define BIND2IP "192.168.0.182"  //Put you'r IP in her

#include <stdio.h>
#include <winsock2.h>
#include <mstcpip.h>
#include <ws2tcpip.h>

typedef struct iphdr
{
	unsigned char VerIHL; //Version and IP Header Length
	unsigned char Tos;
	unsigned short Total_len;
	unsigned short ID;
	unsigned short Flags_and_Frags; //Flags 3 bits and Fragment offset 13 bits
	unsigned char TTL;
	unsigned char Protocol;
	unsigned short Checksum;
	unsigned long SrcIP;
	unsigned long DstIP;
	//unsigned long Options_and_Padding;
} IpHeader;

typedef struct port
{
	unsigned short SrcPort;
	unsigned short DstPort;
} TcpUdpPort;

void ProcessPacket(char* Buffer, int Size)
{
	IpHeader *iphdr;
	TcpUdpPort *port;
	struct sockaddr_in SockAddr;
	unsigned short iphdrlen;
	char C;

	iphdr = (IpHeader *)Buffer;

	iphdrlen = (iphdr->VerIHL << 4);
	memcpy(&C, &iphdrlen, 1);
	iphdrlen = (C >> 4) * 4; //20


	memset(&SockAddr, 0, sizeof(SockAddr));
	SockAddr.sin_addr.s_addr = iphdr->SrcIP;
	printf("Packet From: %s ", inet_ntoa(SockAddr.sin_addr));
	memset(&SockAddr, 0, sizeof(SockAddr));
	SockAddr.sin_addr.s_addr = iphdr->DstIP;
	printf("To: %s ", inet_ntoa(SockAddr.sin_addr));

	switch (iphdr->Protocol)
	{
	case 1:
		printf("Protocol: ICMP ");
		break;
	case 2:
		printf("Protocol: IGMP ");
		break;
	case 6:
		printf("Protocol: TCP ");
		if (Size > iphdrlen)
		{
			port = (TcpUdpPort *)(Buffer + iphdrlen);
			printf("From Port: %i To Port: %i ", ntohs(port->SrcPort), ntohs(port->DstPort));
		}
		break;
	case 17:
		printf("Protocol: UDP ");
		if (Size > iphdrlen)
		{
			port = (TcpUdpPort *)(Buffer + iphdrlen);
			printf("From Port: %i To Port: %i ", ntohs(port->SrcPort), ntohs(port->DstPort));
		}
		break;
	default:
		printf("Protocol: %i ", iphdr->Protocol); 
	}

	printf("\n");
}

void StartSniffing(SOCKET Sock)
{
	char *RecvBuffer = (char *)malloc(MAX_PACKET_SIZE + 1);
	int BytesRecv, FromLen;
	struct sockaddr_in From;

	if (RecvBuffer == NULL)
	{
		printf("malloc() failed.\n");
		exit(-1);
	}

	FromLen = sizeof(From);

	do
	{
		memset(RecvBuffer, 0, MAX_PACKET_SIZE + 1);
		memset(&From, 0, sizeof(From));

		BytesRecv = recvfrom(Sock, RecvBuffer, MAX_PACKET_SIZE, 0, (sockaddr *)&From, &FromLen);
		
		if (BytesRecv > 0)
		{
			ProcessPacket(RecvBuffer, BytesRecv);
		}
		else
		{
			printf( "recvfrom() failed.\n");
		}

	} while (BytesRecv > 0);


	free(RecvBuffer);
}

int main()
{
	WSAData wsaData;
	SOCKET Sock;
	struct sockaddr_in SockAddr;
	DWORD BytesReturned;
	int I = 1;

	try
	{

		if (WSAStartup(MAKEWORD(2, 2), &wsaData) != 0)
		{
			printf("WSAStartup() failed.\n");
			exit(-1);
		}

		Sock = socket(AF_INET, SOCK_RAW, IPPROTO_IP);

		if (Sock == INVALID_SOCKET)
		{
			printf("socket() failed.\n");
			exit(-1);
		}

		memset(&SockAddr, 0, sizeof(SockAddr));
		SockAddr.sin_addr.s_addr = inet_addr(BIND2IP);
		SockAddr.sin_family = AF_INET;
		SockAddr.sin_port = 0;

		if (bind(Sock, (sockaddr *)&SockAddr, sizeof(SockAddr)) == SOCKET_ERROR)
		{
			printf("bind(%s) failed.\n", BIND2IP);
			exit(-1);
		}

		if (WSAIoctl(Sock, SIO_RCVALL, &I, sizeof(I), NULL, NULL, &BytesReturned, NULL, NULL) == SOCKET_ERROR)
		{
			printf("WSAIoctl() failed.\n");
			exit(-1);
		}

		StartSniffing(Sock);
	}
	catch (...)
	{
		printf("CRASH\n");
	}

	closesocket(Sock);
	WSACleanup();

	return 0;
}
