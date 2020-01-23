/*
  Famitile
  version 0.1
  Licensed under GNU GPL v3 or later version.
*/

#ifndef Variable
#define Variable
#endif

#ifndef INCLUDED_famitile_h
#define INCLUDED_famitile_h


// ## Constants ##

#define Famitile_Version "0.1"

#define Conv_Famicom 'f' // Two 1bpp planes
#define Conv_Gameboy 'g' // Two 1bpp planes interleaved by row
#define Conv_Virtualboy 'v' // 2 bits per pixel, right to left, little endian
#define Conv_NeoGeo 'n' // 2 bits per pixel, left to right, little endian
// monochrome (1bpp) = 1 bit per pixel, left to right, big-endian



// ## Types ##

typedef unsigned char byte;

typedef int boolean;

typedef struct {
  byte data[16];
} graphic;



// ## Variables ##

Variable graphic tiles[0x1001]; // sixteen pages of 256 characters each + clipboard
Variable int numeric_var[26]; // 'a' to 'z'
Variable byte nametable[0x800]; // +0x3C0 for attributes, +0x400 for MMC5 expansion



// ## Functions ##

void load_chr(char*filename,int page,char conv);
void mirror_chr(int addr);
void flip_chr(int addr);
void recolor_chr(int addr,byte re);
void rotate_chr(int addr);
void and_chr(int dst,int src);
void or_chr(int dst,int src);
void xor_chr(int dst,int src);
void copy_chr(int dst,int src);
int compare_chr(int chr1,int chr2);
void fillrect_chr(int addr,int x1,int y1,int x2,int y2,byte val);
void xorrect_chr(int addr,int x1,int y1,int x2,int y2,byte val);
void loadcp437_chr(int addr,byte ascii,byte val);
void transpage_chr(int page);
void vshift_chr(int addr);
void hshift_chr(int addr);
void save_chr(char*filename,int page,int count);

void load_nam(char*filename);
void loadmmc5_nam(char*filename);
void save_nam(char*filename);
void savemmc5_nam(char*filename);
void fillrect_nam(int x1,int y1,int x2,int y2,int val);
void put_nam(int x,int y,int val);
void bankset_nam(int x1,int y1,int x2,int y2,int val);
void recolor_nam(int x1,int y1,int x2,int y2,int val);

int read_number(char**cmd);
void run_command(char*cmd);
void run_script(int argc,char**argv);



#endif
