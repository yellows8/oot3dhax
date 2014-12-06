#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>

unsigned short const crc16_table[256] = { 
0x0000, 0xC0C1, 0xC181, 0x0140, 0xC301, 0x03C0, 0x0280, 0xC241, 0xC601, 0x06C0, 0x0780, 0xC741, 0x0500, 0xC5C1,
0xC481, 0x0440, 0xCC01, 0x0CC0, 0x0D80, 0xCD41, 0x0F00, 0xCFC1, 0xCE81, 0x0E40, 0x0A00, 0xCAC1, 0xCB81, 0x0B40, 0xC901,
0x09C0, 0x0880, 0xC841, 0xD801, 0x18C0, 0x1980, 0xD941, 0x1B00, 0xDBC1, 0xDA81, 0x1A40, 0x1E00, 0xDEC1, 0xDF81, 0x1F40, 
0xDD01, 0x1DC0, 0x1C80, 0xDC41, 0x1400, 0xD4C1, 0xD581, 0x1540, 0xD701, 0x17C0, 0x1680, 0xD641, 0xD201, 0x12C0, 0x1380, 
0xD341, 0x1100, 0xD1C1, 0xD081, 0x1040, 0xF001, 0x30C0, 0x3180, 0xF141, 0x3300, 0xF3C1, 0xF281, 0x3240, 0x3600, 0xF6C1, 
0xF781, 0x3740, 0xF501, 0x35C0, 0x3480, 0xF441, 0x3C00, 0xFCC1, 0xFD81, 0x3D40, 0xFF01, 0x3FC0, 0x3E80, 0xFE41, 0xFA01, 
0x3AC0, 0x3B80, 0xFB41, 0x3900, 0xF9C1, 0xF881, 0x3840, 0x2800, 0xE8C1, 0xE981, 0x2940, 0xEB01, 0x2BC0, 0x2A80, 0xEA41, 
0xEE01, 0x2EC0, 0x2F80, 0xEF41, 0x2D00, 0xEDC1, 0xEC81, 0x2C40, 0xE401, 0x24C0, 0x2580, 0xE541, 0x2700, 0xE7C1, 0xE681, 
0x2640, 0x2200, 0xE2C1, 0xE381, 0x2340, 0xE101, 0x21C0, 0x2080, 0xE041, 0xA001, 0x60C0, 0x6180, 0xA141, 0x6300, 0xA3C1, 
0xA281, 0x6240, 0x6600, 0xA6C1, 0xA781, 0x6740, 0xA501, 0x65C0, 0x6480, 0xA441, 0x6C00, 0xACC1, 0xAD81, 0x6D40, 0xAF01, 
0x6FC0, 0x6E80, 0xAE41, 0xAA01, 0x6AC0, 0x6B80, 0xAB41, 0x6900, 0xA9C1, 0xA881, 0x6840, 0x7800, 0xB8C1, 0xB981, 0x7940, 
0xBB01, 0x7BC0, 0x7A80, 0xBA41, 0xBE01, 0x7EC0, 0x7F80, 0xBF41, 0x7D00, 0xBDC1, 0xBC81, 0x7C40, 0xB401, 0x74C0, 0x7580, 
0xB541, 0x7700, 0xB7C1, 0xB681, 0x7640, 0x7200, 0xB2C1, 0xB381, 0x7340, 0xB101, 0x71C0, 0x7080, 0xB041, 0x5000, 0x90C1, 
0x9181, 0x5140, 0x9301, 0x53C0, 0x5280, 0x9241, 0x9601, 0x56C0, 0x5780, 0x9741, 0x5500, 0x95C1, 0x9481, 0x5440, 0x9C01, 
0x5CC0, 0x5D80, 0x9D41, 0x5F00, 0x9FC1, 0x9E81, 0x5E40, 0x5A00, 0x9AC1, 0x9B81, 0x5B40, 0x9901, 0x59C0, 0x5880, 0x9841, 
0x8801, 0x48C0, 0x4980, 0x8941, 0x4B00, 0x8BC1, 0x8A81, 0x4A40, 0x4E00, 0x8EC1, 0x8F81, 0x4F40, 0x8D01, 0x4DC0, 0x4C80, 
0x8C41, 0x4400, 0x84C1, 0x8581, 0x4540, 0x8701, 0x47C0, 0x4680, 0x8641, 0x8201, 0x42C0, 0x4380, 0x8341, 0x4100, 0x81C1, 
0x8081, 0x4040
};

unsigned short crc16(unsigned char *buf, unsigned int size, unsigned short seed)
{
	unsigned short crc = seed;
	unsigned char val;

	while(size>0)
	{
		size--;
		val = *buf++;
		crc = crc16_table[(val ^ crc) & 0xff] ^ (crc >> 8);
	}

	return crc;
}

unsigned short getle16(const void* ptr)
{
	unsigned char* p = (unsigned char*)ptr;
	
	return p[0] | (p[1]<<8);
}

unsigned int getle32(const void* ptr)
{
	unsigned char* p = (unsigned char*)ptr;
	
	return (p[0]<<0) | (p[1]<<8) | (p[2]<<16) | (p[3]<<24);
}

void putle16(unsigned char* p, unsigned short n)
{
	p[0] = n;
	p[1] = n>>8;
}

void process_save(unsigned char *savegame)
{
	unsigned int pos = 0;
	unsigned int len = savegame[0x2c];
	unsigned int year, month, day, hour, minute;
	unsigned int horserace_time, marathon_time;
	unsigned int total_hearts;

	printf("Player name length: %u\n", len);
	printf("Player name: ");

	while(pos<len)
	{
		printf("%c", (char)savegame[0x1c + pos*2]);//Doing this properly would require converting to UTF-8.

		pos++;
	}
	printf("\n");

	horserace_time = getle32(&savegame[0xedc]);//These times are in seconds.
	marathon_time = getle32(&savegame[0xee0]);
	total_hearts = getle16(&savegame[0x44]);

	printf("Adult Link: %s\n", getle32(&savegame[0x4])==0?"yes":"no");
	printf("Master quest: %s\n", savegame[0xe]!=0?"yes":"no");
	printf("Total hearts: %u ", total_hearts / 16);
	if(total_hearts % 16)printf("%u/16", total_hearts % 16);
	printf("\n");
	printf("Total rupees: %u\n", getle16(&savegame[0x48]));
	printf("Magic unlocked: %s\n", savegame[0x4e]!=0?"yes":"no");
	//printf("Double magic unlocked: %s\n", savegame[0x4f]!=0?"yes":"no");//this is wrong
	printf("Double-defense unlocked: %s\n", savegame[0x51]!=0?"yes":"no");
	printf("Total gold skulltula tokens: %u\n", getle16(&savegame[0xe8]));
	printf("Horseback archery: %u points\n", getle32(&savegame[0xed0]));
	printf("Horse race time: %u:%02u\n", horserace_time / 60, horserace_time % 60);
	printf("Marathon time: %u:%02u\n", marathon_time / 60, marathon_time % 60);

	year = getle32(&savegame[0x13bc]);
	month = getle32(&savegame[0x13c0]);
	day = getle32(&savegame[0x13c4]);
	hour = getle32(&savegame[0x13c8]);
	minute = getle32(&savegame[0x13cc]);

	printf("Datetime when this was last saved: %02u-%02u-%04u %02u:%02u\n", month, day, year, hour, minute);
}

void process_systemdat(unsigned char *buf)
{
	printf("Master quest unlocked: %s\n", buf[0]==0xbe?"yes":"no");
}

int main(int argc, char **argv)
{
	FILE *f;
	int i;
	unsigned short calc_crc=0, save_calc=0;
	unsigned int crc_off = 0x14d8;
	int updatesave = 0;
	int argi = 2;
	int printinfo = 0;

	struct stat filestat;
	unsigned char savegame[0x14dc];
	char outpath[256];

	if(argc==1)return 0;

	printf("oot3d_savetool by yellows8\n");

	memset(&savegame, 0, 0x14dc);
	memset(outpath, 0, 256);
	if(argc<3)strncpy(outpath, argv[1], 255);
	if(argc>=3 && argv[2][0]!='-')
	{
		argi++;
		strncpy(outpath, argv[2], 255);
	}

	while(argi<argc)
	{
		if(strncmp(argv[argi], "--printinfo", 11)==0)printinfo = 1;

		argi++;
	}

	if(stat(argv[1], &filestat)==-1)
	{
		printf("Failed to stat input save.\n");
		return 0;
	}
	if(filestat.st_size!=0x14dc && filestat.st_size!=0x22)
	{
		printf("Invalid filesize: %x\n", (unsigned int)filestat.st_size);
		return 0;
	}

	f = fopen(argv[1], "rb");
	if(f==NULL)return 0;
	if(fread(&savegame, 1, filestat.st_size, f) != filestat.st_size)
	{
		printf("Read failed.\n");
		fclose(f);
		return 0;
	}
	fclose(f);

	if(filestat.st_size==0x22)crc_off = 0x20;

	save_calc = getle16(&savegame[crc_off]);
	putle16(&savegame[crc_off], 0);

	printf("Calculating CRC16... ");
	calc_crc = crc16(savegame, filestat.st_size, 0);
	if(calc_crc == save_calc)
	{
		printf("GOOD!\n");
	}
	else
	{
		printf("INVALID!\n");
		printf("Calc CRC16 %x, savegame %x\n", calc_crc, save_calc);

		updatesave = 1;
		putle16(&savegame[crc_off], calc_crc);
	}

	if(printinfo)
	{
		printf("\n");
		if(filestat.st_size==0x14dc)process_save(savegame);
		if(filestat.st_size==0x22)process_systemdat(savegame);
	}

	if(updatesave==0)return 0;

	printf("\n");

	printf("Writing updated savegame...\n");
	f = fopen(outpath, "r+b");
	if(f==NULL)
	{
		printf("Failed to open savegame for writing.\n");
		return 0;
	}
	if(fwrite(&savegame, 1, filestat.st_size, f) != filestat.st_size)
	{
		printf("Write failed.\n");
		fclose(f);
		return 0;
	}
	fclose(f);

	return 0;
}

