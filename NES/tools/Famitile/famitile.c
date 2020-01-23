/*
  Famitile
  version 0.1
  Licensed under GNU GPL v3 or later version.
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "famitile.h"

#include "bit_hack.h"
#include "cp437.h"

#ifdef USE_GUI
extern void error(char*x,char*y);
extern void select_chr(int x);
#else
#define error(x,y) fprintf(stderr,x " %s\n",y)
#define select_chr(x) printf(":  $%03X\n",x)
#endif

// ---- Tile manipulation codes

#define check_addr_range(x) if(x<0 || x>0x1000) {error("Out of range","(using zero)");x=0;}

void load_chr(char*filename,int page,char conv) {
  int b=(page&0xF)<<8;
  int x,y;
  byte c0,c1,c2,c3;
  FILE*fp=fopen(filename,"rb");
  if(conv>='0' && conv<='9') conv-='0'; // monochrome
  if(conv>='A' && conv<='F') conv+=10-'A'; // monochrome
  if(!fp) {
    error("Cannot load file:",filename);
    return;
  }
  c0=0xFF*( (!(conv&1)) ^ (!(conv&4)) );
  c1=0xFF*!!(conv&4);
  c2=0xFF*( (!(conv&2)) ^ (!(conv&8)) );
  c3=0xFF*!!(conv&8);
  while(!feof(fp) && !(b&0x10000)) {
    switch(conv) {

      case Conv_Famicom:
        for(x=0;x<16;x++) tiles[b].data[x]=fgetc(fp);
        break;

      case Conv_Gameboy:
        for(x=0;x<8;x++) {
          tiles[b].data[x]=fgetc(fp);
          tiles[b].data[x|8]=fgetc(fp);
        }
        break;

      case Conv_Virtualboy:
        for(x=0;x<8;x++) {
          y=reverse[fgetc(fp)];
          tiles[b].data[x]=unmingle[y&0xAA];
          tiles[b].data[x|8]=unmingle[y&0x55];
          y=reverse[fgetc(fp)];
          tiles[b].data[x]|=unmingle[y&0xAA]<<4;
          tiles[b].data[x|8]|=unmingle[y&0x55]<<4;
        }
        break;

      case Conv_NeoGeo:
        for(x=0;x<8;x++) {
          y=fgetc(fp);
          tiles[b].data[x]=unmingle[y&0x55]<<4;
          tiles[b].data[x|8]=unmingle[y&0xAA]<<4;
          y=fgetc(fp);
          tiles[b].data[x]|=unmingle[y&0x55];
          tiles[b].data[x|8]|=unmingle[y&0xAA];
        }
        break;

      default:
        for(x=0;x<8;x++) {
          y=fgetc(fp);
          tiles[b].data[x]=(y&c0)^c1;
          tiles[b].data[x|8]=(y&c2)^c3;
        }

    }
    ++b;
  }
  fclose(fp);
}

void mirror_chr(int addr) {
  int x;
  check_addr_range(addr);
  for(x=0;x<16;x++) tiles[addr].data[x]=reverse[tiles[addr].data[x]];
}

void flip_chr(int addr) {
  byte x,y;
  check_addr_range(addr);
  for(x=0;x<16;x+=2) {
    y=tiles[addr].data[x];
    tiles[addr].data[x]=tiles[addr].data[x^7];
    tiles[addr].data[x^7]=y;
  }
}

void recolor_chr(int addr,byte re) {
  int x,y,z;
  check_addr_range(addr);
  re^=0xE4;
  for(y=0;y<8;y++) {
    for(x=0;x<8;x++) {
      z=((tiles[addr].data[y]&(1<<x))>>x)|((tiles[addr].data[y|8]&(1<<x))>>(x-1)); // color at pixel
      z=(re>>(1<<(z<<1)))&3;
      if(z&1) tiles[addr].data[y]^=1<<x;
      if(z&2) tiles[addr].data[y|8]^=1<<x;
    }
  }
}

void rotate_chr(int addr) {
  error("Not implemented.","");
}

void and_chr(int dst,int src) {
  int x;
  check_addr_range(dst); check_addr_range(src);
  for(x=0;x<16;x++) tiles[dst].data[x]&=tiles[src].data[x];
}

void or_chr(int dst,int src) {
  int x;
  check_addr_range(dst); check_addr_range(src);
  for(x=0;x<16;x++) tiles[dst].data[x]|=tiles[src].data[x];
}

void xor_chr(int dst,int src) {
  int x;
  check_addr_range(dst); check_addr_range(src);
  for(x=0;x<16;x++) tiles[dst].data[x]^=tiles[src].data[x];
}

void copy_chr(int dst,int src) {
  int x;
  check_addr_range(dst); check_addr_range(src);
  for(x=0;x<16;x++) tiles[dst].data[x]=tiles[src].data[x];
}

int compare_chr(int chr1,int chr2) {
  int x;
  check_addr_range(chr1); check_addr_range(chr2);
  for(x=0;x<16;x++) if(tiles[chr1].data[x]!=tiles[chr2].data[x]) return 1;
  return 0;
}

void fillrect_chr(int addr,int x1,int y1,int x2,int y2,byte val) {
  int y;
  byte z=(0xFF>>x1)^(0x7F>>x2);
  byte v0=z*(val&1);
  byte v1=z*((val>>1)&1);
  check_addr_range(addr);
  z^=0xFF;
  for(y=y1;y<=y2;y++) {
    tiles[addr].data[y]&=z;
    tiles[addr].data[y]|=v0;
    tiles[addr].data[y|8]&=z;
    tiles[addr].data[y|8]|=v1;
  }
}

void xorrect_chr(int addr,int x1,int y1,int x2,int y2,byte val) {
  int y;
  byte z=(0xFF>>x1)^(0x7F>>x2);
  byte v0=z*(val&1);
  byte v1=z*((val>>1)&1);
  check_addr_range(addr);
  for(y=y1;y<=y2;y++) {
    tiles[addr].data[y]^=v0;
    tiles[addr].data[y|8]^=v1;
  }
}

void loadcp437_chr(int addr,byte ascii,byte val) {
  int y;
  byte v0=0xFF*(val&1);
  byte v1=0xFF*((val&2)>>1);
  int o=ascii<<3;
  check_addr_range(addr);
  for(y=0;y<8;y++) {
    tiles[addr].data[y]=cp437[o]&v0;
    tiles[addr].data[y|8]=cp437[o++]&v1;
  }
}

void transpage_chr(int page) {
  int x,y,z;
  graphic g;
  page=(page&15)<<8;
  for(x=0;x<16;x++) {
    for(y=0;y<x;y++) {
      g=tiles[page|(x<<4)|y];
      tiles[page|(x<<4)|y]=tiles[page|x|(y<<4)];
      tiles[page|x|(y<<4)]=g;
    }
  }
}

void vshift_chr(int addr) {
  int y;
  byte g0,g1,g;
  check_addr_range(addr);
  g0=tiles[addr].data[7]; g1=tiles[addr].data[15];
  for(y=0;y<8;y++) {
    g=tiles[addr].data[y]; tiles[addr].data[y]=g0; g0=g;
    g=tiles[addr].data[y|8]; tiles[addr].data[y|8]=g1; g1=g;
  }
}

void hshift_chr(int addr) {
  int y;
  check_addr_range(addr);
  for(y=0;y<16;y++) tiles[addr].data[y]=(tiles[addr].data[y]>>7)|(tiles[addr].data[y]<<1);
}

void save_chr(char*filename,int page,int count) {
  int b=(page&0xF)<<8;
  int x;
  FILE*fp=fopen(filename,"wb");
  if(!fp) {
    error("Cannot save file:",filename);
    return;
  }
  count<<=8;
  while(count--) {
    fwrite(tiles[b].data,1,16,fp);
    if(++b>0x1000) break;
  }
  fclose(fp);
}

// ---- Nametable manipulation codes

#define check_attrib(z,y) nametable[z]==nametable[z|y]
#define check_attribs(z) (check_attrib(z,1)&&check_attrib(z,32)&&check_attrib(z,33))

void load_nam(char*filename) {
  FILE*fp=fopen(filename,"rb");
  int x,z;
  if(!fp) {
    error("Cannot load nametable:",filename);
    return;
  }
  fread(nametable,1,0x400,fp);
  for(x=0x3C0;x<0x400;x++) {
    z=((x&0x07)<<2)|((x&0x38)<<4);
    nametable[z|0x400]=nametable[z|0x401]=nametable[z|0x420]=nametable[z|0x421]=nametable[x]<<6;
    nametable[z|0x402]=nametable[z|0x403]=nametable[z|0x422]=nametable[z|0x423]=(nametable[x]<<4)&0xC0;
    nametable[z|0x440]=nametable[z|0x441]=nametable[z|0x460]=nametable[z|0x461]=(nametable[x]<<2)&0xC0;
    nametable[z|0x442]=nametable[z|0x443]=nametable[z|0x462]=nametable[z|0x463]=nametable[x]&0xC0;
  }
  fclose(fp);
}

void loadmmc5_nam(char*filename) {
  FILE*fp=fopen(filename,"rb");
  if(!fp) {
    error("Cannot load MMC5 nametable:",filename);
    return;
  }
  fread(nametable,1,0x800,fp);
  fclose(fp);
}

void save_nam(char*filename) {
  FILE*fp=fopen(filename,"wb");
  char buf[41];
  int x,z;
  if(!fp) {
    error("Cannot save nametable:",filename);
    return;
  }
  for(x=0x7C0;x<0x800;x++) nametable[x]=0;
  for(x=0x3C0;x<0x400;x++) {
    z=0x400|((x&0x07)<<2)|((x&0x38)<<4);
    //if(!check_attribs(z|0x00) || !check_attribs(z|0x02) || !check_attribs(z|0x40) || !check_attribs(z|0x42)) {
    //  sprintf(buf,"Wrong attributes at block %d:",z&0x3FF);
    //  error("Nametable error:",buf);
    //}
    nametable[x]=nametable[z|0x42]&0xC0;
    nametable[x]|=(nametable[z|0x40]&0xC0)>>2;
    nametable[x]|=(nametable[z|0x02]&0xC0)>>4;
    nametable[x]|=(nametable[z|0x00]&0xC0)>>6;
  }
  //for(x=0x400;x<0x7C0;x++) {
  //  if(nametable[x]&0x3F) {
  //    sprintf(buf,"Wrong CHR bank at (%d,%d):",x&31,(x>>5)&31);
  //    error("Nametable error:",buf);
  //  }
  //}
  fwrite(nametable,1,0x400,fp);
  fclose(fp);
}

void savemmc5_nam(char*filename) {
  FILE*fp=fopen(filename,"wb");
  if(!fp) {
    error("Cannot save MMC5 nametable:",filename);
    return;
  }
  fwrite(nametable,1,0x800,fp);
  fclose(fp);
}

void fillrect_nam(int x1,int y1,int x2,int y2,int val) {
  int x,y;
  x1&=31; y1&=31; x2&=31; y2&=31;
  for(x=x1;x<=x2;x++) {
    for(y=y1;y<=y2;y++) {
      nametable[x|(y<<5)]=val;
      nametable[x|(y<<5)|0x400]=val>>8;
    }
  }
}

void put_nam(int x,int y,int val) {
  x&=31; y&=31;
  nametable[x|(y<<5)]=val;
  nametable[x|(y<<5)|0x400]=val>>8;
}

void bankset_nam(int x1,int y1,int x2,int y2,int val) {
  int x,y;
  x1&=31; y1&=31; x2&=31; y2&=31; val&=0x3F;
  for(x=x1;x<=x2;x++) {
    for(y=y1;y<=y2;y++) {
      nametable[x|(y<<5)|0x400]&=0xC0;
      nametable[x|(y<<5)|0x400]|=val;
    }
  }
}

void recolor_nam(int x1,int y1,int x2,int y2,int val) {
  int x,y;
  byte o[4];
  byte z;
  x1&=31; y1&=31; x2&=31; y2&=31;
  o[0]=(val<<6)&0xC0; o[1]=(val<<4)&0xC0; o[2]=(val<<2)&0xC0; o[3]=val&0xC0;
  for(x=x1;x<=x2;x++) {
    for(y=y1;y<=y2;y++) {
      z=nametable[x|(y<<5)|0x400];
      nametable[x|(y<<5)|0x400]=(z&0x3F)|o[z>>6];
    }
  }
}

// ---- Command execution codes

int read_number(char**cmd) {
  int b=10;
  int s=1;
  int o=0;
  if(**cmd==',') (*cmd)++;
  if(**cmd=='+') {
    (*cmd)++;
  } else if(**cmd=='-') {
    s=-1;
    (*cmd)++;
  } else if(**cmd>='a' && **cmd<='z') {
    return numeric_var[*((*cmd)++)-'a'];
  }
  if(**cmd=='$') {
    b=16;
    (*cmd)++;
  }
  for(;;) {
    if(**cmd>='0' && **cmd<='9') {
      o*=b;
      o+=*((*cmd)++)-'0';
    } else if(**cmd>='A' && **cmd<='F') {
      o*=b;
      o+=*((*cmd)++)+10-'A';
    } else if(**cmd=='.') {
      o<<=8;
      (*cmd)++;
    } else if(**cmd=='/') {
      o>>=8;
      (*cmd)++;
    } else {
      break;
    }
  }
  if(**cmd=='-') {
    o=tiles[o&0xFFF].data[(*++*cmd)&7];
    (*cmd)++;
  } else if(**cmd=='+') {
    o=tiles[o&0xFFF].data[((*++*cmd)&7)|8];
    (*cmd)++;
  } else if(**cmd=='=') {
    o=nametable[o&0x7FF];
    (*cmd)++;
  }
  if(**cmd==',') (*cmd)++;
  return o*s;
}

void run_command(char*cmd) {
  char c;
  int p,q,r,x,y;
  switch(*cmd++) {
    case 0: return;

    case '=': // set variable
      c=*cmd++;
      if(c>='a' && c<='z') numeric_var[c-'a']=read_number(&cmd);
      if(c=='_') {
        char buf[64];
        char*z=cmd++;
        x=read_number(&cmd);
        sprintf(buf,"= $%X (%d)",z-1,x,x);
        error("result",buf);
      }
      break;

    case '+': // increase variable
      c=*cmd++;
      if(c>='a' && c<='z') numeric_var[c-'a']+=read_number(&cmd);
      if(c=='_') select_chr(read_number(&cmd)&0xFFF);
      break;

    case '-': // decrease variable
      c=*cmd++;
      if(c>='a' && c<='z') numeric_var[c-'a']-=read_number(&cmd);
      break;

    case 'A': // load CP437
      p=read_number(&cmd);
      q=read_number(&cmd);
      r=read_number(&cmd);
      loadcp437_chr(p,q,r);
      break;

    case 'B': // set bank of rectangle in nametable
      p=read_number(&cmd);
      q=read_number(&cmd);
      r=read_number(&cmd);
      x=read_number(&cmd);
      y=read_number(&cmd);
      bankset_nam(p,q,r,x,y);
      break;

    case 'C': // recolor rectangle in nametable
      p=read_number(&cmd);
      q=read_number(&cmd);
      r=read_number(&cmd);
      x=read_number(&cmd);
      y=read_number(&cmd);
      recolor_nam(p,q,r,x,y);
      break;

    case 'D': // detect duplicates
      p=read_number(&cmd);
      q=read_number(&cmd);
      r=((q+1)<<8)&15;
      for(x=(q<<8)&15;x<r;x++) if(x!=p && compare_chr(p,x)) select_chr(x);
      break;

    case 'F': // fill rectangle
      p=read_number(&cmd);
      q=read_number(&cmd);
      r=read_number(&cmd);
      x=read_number(&cmd);
      y=read_number(&cmd);
      c=read_number(&cmd);
      fillrect_chr(p,q,r,x,y,c);
      break;

    case 'L': // loading
      c=*cmd++;
      p=read_number(&cmd);
      if(*cmd=='=') cmd++;
      load_chr(cmd,p,c);
      break;

    case 'R': // fill rectangle in nametable
      p=read_number(&cmd);
      q=read_number(&cmd);
      r=read_number(&cmd);
      x=read_number(&cmd);
      y=read_number(&cmd);
      fillrect_nam(p,q,r,x,y);
      break;

    case 'S': // save MMC5 nametable
      if(*cmd=='=') cmd++;
      savemmc5_nam(cmd);
      break;

    case 'T': // transpose page
      transpage_chr(read_number(&cmd));
      break;

    case 'W': // saving
      p=read_number(&cmd);
      q=read_number(&cmd);
      if(*cmd=='=') cmd++;
      save_chr(cmd,p,q);
      break;

    case 'X': // XOR rectangle
      p=read_number(&cmd);
      q=read_number(&cmd);
      r=read_number(&cmd);
      x=read_number(&cmd);
      y=read_number(&cmd);
      c=read_number(&cmd);
      xorrect_chr(p,q,r,x,y,c);
      break;

    case 'Y': // load MMC5 nametable
      if(*cmd=='=') cmd++;
      loadmmc5_nam(cmd);
      break;

    case 'a': // AND character
      p=read_number(&cmd);
      q=read_number(&cmd);
      and_chr(p,q);
      break;

    case 'c': // recolor character
      p=read_number(&cmd);
      q=read_number(&cmd);
      recolor_chr(p,q);
      break;

    case 'f': // flip character
      flip_chr(read_number(&cmd));
      break;

    case 'h': // horizontal shift character
      hshift_chr(read_number(&cmd));
      break;

    case 'm': // mirror character
      mirror_chr(read_number(&cmd));
      break;

    case 'o': // OR character
      p=read_number(&cmd);
      q=read_number(&cmd);
      or_chr(p,q);
      break;

    case 'p': // put data in nametable
      x=read_number(&cmd);
      y=read_number(&cmd);
      p=read_number(&cmd);
      put_nam(x,y,p);
      break;

    case 'r': // rotate character
      rotate_chr(read_number(&cmd));
      break;

    case 's': // save nametable
      if(*cmd=='=') cmd++;
      save_nam(cmd);
      break;

    case 'v': // vertical shift character
      vshift_chr(read_number(&cmd));
      break;

    case 'x': // XOR character
      p=read_number(&cmd);
      q=read_number(&cmd);
      xor_chr(p,q);
      break;

    case 'y': // load nametable
      if(*cmd=='=') cmd++;
      load_nam(cmd);
      break;

    case 'z': // copy character
      p=read_number(&cmd);
      q=read_number(&cmd);
      copy_chr(p,q);
      break;

    default:
      error("Bad command:",cmd-1);
  }
}

void run_script(int argc,char**argv) {
  int i,j;
  for(i=0;i<argc;i++) {
    if(argv[i][0]=='(') {
      j=argv[i][1];
      if(j>='a' && j<='z') {
        j-='a';
        i++;
        while(numeric_var[j]) run_script(argc-i,argv+i);
        // skip this loop
        j=1;
        while(j && i++<argc) {
          if(argv[i][0]=='(') j++;
          if(argv[i][0]==')') j--;
        }
      } else {
        error("Bad command:",argv[i]);
      }
    } else if(argv[i][0]==')') {
      return;
    } else if(argv[i][0]) {
      run_command(argv[i]);
    }
  }
}

// ---- Main

#ifndef USE_GUI
int main(int argc,char**argv) {
  if(argc>1) {
    run_script(argc-1,argv+1);
  } else {
    fprintf(stderr,"Famitile v" Famitile_Version ".\nLicensed under GNU GPLv3 or later version.\n\nNothing to do.\n");
  }
  return 0;
}
#endif
