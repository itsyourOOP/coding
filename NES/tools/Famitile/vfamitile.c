/*
  Famitile
  version 0.1
  Licensed under GNU GPL v3 or later version.
*/

#define White 0x20
#define Gray 0x10
#define Black 0x1D
#define Blue 0x11
#define Green 0x2A
#define Orange 0x16
#define DimBlue 0x51
#define DimGreen 0x6A

#define CP437_hdline16 "\xCD\xCD\xCD\xCD\xCD\xCD\xCD\xCD\xCD\xCD\xCD\xCD\xCD\xCD\xCD\xCD"
#define CP437_bdrow16 "\xBA                \xBA"
#define CP437_4row16 CP437_bdrow16 "\n" CP437_bdrow16 "\n" CP437_bdrow16 "\n" CP437_bdrow16 "\n"
#define CP437_16row16 CP437_4row16 CP437_4row16 CP437_4row16 CP437_4row16

#define Variable extern

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <SDL/SDL.h>
#include <sys/stat.h>
#include "famitile.h"

#include "palette.h"

typedef struct {
  byte cont; // number of pages (0 to 16)
  char name[255];
} filename_struct;

typedef struct {
  byte tile[4];
  byte attr[4];
} nametable_clip;

extern const byte cp437[0x7FF];
SDL_Surface*screen;
#define screenpix ((byte*)(screen->pixels))
byte chrpalette[16];
filename_struct files[16];
boolean selected[0x1000];
int nametable_type=0; // 0=not a nametable, 1=normal, 2=MMC5 extension
char nametable_name[256];
nametable_clip ntclipboard[8];
int no_errors=0;

#define Var(x) (numeric_var[x-'a'])
#define curpal Var('p')
#define curaddr Var('a')
#define actaddr Var('c')
#define clip_addr 0x1000
#define clipboard (tiles[clip_addr])

#define clear_screen() SDL_FillRect(screen,0,Black)
#define fatal_error(x,y) do { error(x,y); SDL_Quit(); exit(1); } while(0)

static int Eventloop(SDL_Event*event) {
  int x=SDL_WaitEvent(event);
  if(!x) return 0;
  if(event->type==SDL_VIDEOEXPOSE) SDL_Flip(screen);
  if(event->type==SDL_QUIT) {
    SDL_Quit();
    exit(0);
  }
  return x;
}

static int translate_key(SDL_Event*event) {
  switch(event->key.keysym.sym) {
    case SDLK_BACKSPACE: return event->key.keysym.mod&KMOD_SHIFT?8:127;
    case SDLK_RETURN: return event->key.keysym.mod&KMOD_SHIFT?13:10;
    case SDLK_ESCAPE: return 27;
    case SDLK_UP: return event->key.keysym.mod&KMOD_SHIFT?'K':'k';
    case SDLK_DOWN: return event->key.keysym.mod&KMOD_SHIFT?'J':'j';
    case SDLK_RIGHT: return event->key.keysym.mod&KMOD_SHIFT?'L':'l';
    case SDLK_LEFT: return event->key.keysym.mod&KMOD_SHIFT?'H':'h';
    case SDLK_HOME: return event->key.keysym.mod&KMOD_SHIFT?'{':'<';
    case SDLK_END: return event->key.keysym.mod&KMOD_SHIFT?'}':'>';
    case SDLK_PAGEUP: return event->key.keysym.mod&KMOD_SHIFT?'N':'n';
    case SDLK_PAGEDOWN: return event->key.keysym.mod&KMOD_SHIFT?'P':'p';
    case SDLK_DELETE: return event->key.keysym.mod&KMOD_SHIFT?8:127;
    case SDLK_KP_ENTER: return event->key.keysym.mod&KMOD_SHIFT?13:10;
    case SDLK_BREAK: return 0;
    default: return event->key.keysym.unicode;
  }
}

static void draw_string(int x,int y,byte bg,byte fg,char*text) {
  int a=(y<<3)*screen->pitch+(x<<3);
  SDL_LockSurface(screen);
  while(*text) {
    if(*text=='\n') {
      a=((++y)<<3)*screen->pitch+(x<<3);
    } else {
      int q,v,z;
      byte*b=screenpix+a;
      byte*c=cp437+(((byte)*text)<<3);
      for(z=0;z<8;z++) {
        v=*c++;
        for(q=8;q;q--) *b++=(v<<=1)&256?fg:bg;
        b+=screen->pitch-8;
      }
      a+=8;
    }
    text++;
  }
  SDL_UnlockSurface(screen);
}

static void draw_rect(int x,int y,int w,int h,byte fg) {
  SDL_Rect rect;
  rect.x=x<<3;
  rect.y=y<<3;
  rect.w=w<<3;
  rect.h=h<<3;
  SDL_FillRect(screen,&rect,fg);
}

static void draw_sel_rect(int x,int y,int w,int h) {
  SDL_Rect rect;
  rect.x=x<<3; rect.y=y<<3;
  rect.w=w<<3; rect.h=1;
  SDL_FillRect(screen,&rect,0xFE);
  rect.w=1; rect.h=h<<3;
  SDL_FillRect(screen,&rect,0xFE);
  rect.x+=(w<<3)-1;
  SDL_FillRect(screen,&rect,0xC1);
  rect.x=x<<3; rect.y+=(h<<3)-1;
  rect.w=w<<3; rect.h=1;
  SDL_FillRect(screen,&rect,0xC1);
}

void error(char*x,char*y) {
  SDL_Event event;
  if(no_errors) return;
  draw_rect(0,0,40,2,Orange);
  draw_string(0,0,Orange,Black,x);
  draw_string(0,1,Orange,Black,y);
  SDL_Flip(screen);
  while(Eventloop(&event)) {
    if((event.type==SDL_KEYDOWN && translate_key(&event)) || event.type==SDL_MOUSEBUTTONDOWN) return;
  }
}

void help(char*x) {
  SDL_Event event;
  draw_string(0,0,DimBlue,White,x);
  SDL_Flip(screen);
  while(Eventloop(&event)) {
    if((event.type==SDL_KEYDOWN && translate_key(&event)) || event.type==SDL_MOUSEBUTTONDOWN) return;
  }
}

void select_chr(int x) {
  selected[x&0xFFF]=1;
}

static void draw_tile(int x,int y,int pal,int addr) {
  byte*b=screenpix+(y<<3)*screen->pitch+(x<<3);
  byte*c0=tiles[addr].data;
  byte*c1=tiles[addr].data+8;
  int q,v0,v1,z;
  pal<<=2;
  SDL_LockSurface(screen);
  for(z=0;z<8;z++) {
    v0=*c0++; v1=*c1++;
    for(q=8;q;q--) {
      v0<<=1; v1<<=1;
      *b++=chrpalette[pal|((v0&256)>>8)|((v1&256)>>7)];
    }
    b+=screen->pitch-8;
  }
  SDL_UnlockSurface(screen);
}

static void reload_files(void) {
  int x;
  no_errors++;
  if(*nametable_name) {
    if(nametable_type==1) load_nam(nametable_name);
    if(nametable_type==2) loadmmc5_nam(nametable_name);
  }
  for(x=0;x<16;x++) if(files[x].cont) load_chr(files[x].name,x,Conv_Famicom);
  no_errors--;
}

static void save_files(void) {
  int x;
  if(*nametable_name) {
    if(nametable_type==1) save_nam(nametable_name);
    if(nametable_type==2) savemmc5_nam(nametable_name);
  }
  for(x=0;x<16;x++) if(files[x].cont) save_chr(files[x].name,x,files[x].cont);
}

static void do_lastline(char ll) {
  SDL_Event event;
  char buf[39];
  int cursor=0;
  char llbuf[2];
  int k;
  char*scr[39];
  memset(buf,0,39);
  llbuf[0]=ll; llbuf[1]=0;

redraw_lastline:
  draw_rect(0,29,40,1,Black);
  draw_string(0,29,Black,Orange,llbuf);
  draw_string(1,29,Black,Gray,buf);
  draw_string(cursor+1,29,Black,Orange,"\x07");

  SDL_Flip(screen);
  while(Eventloop(&event)) {
    if(event.type==SDL_KEYDOWN) {
      k=translate_key(&event);
      if(k==10) {
        cursor=0; k=1;
        scr[0]=buf;
        while(buf[cursor]) {
          if(buf[cursor]==' ') {
            buf[cursor++]=0;
            scr[k++]=buf+cursor;
          } else {
            cursor++;
          }
        }
        if(ll==':') run_script(k,scr);
        if(ll=='!') {
          for(actaddr=0;actaddr<0x1000;actaddr++) if(selected[actaddr]) run_script(k,scr);
        }
        return;
      } else if(k==27 || k==3) {
        return;
      } else if(k==8 || k==127) {
        if(cursor) buf[--cursor]=0;
      } else if(k>=32 && k<127 && cursor<39) {
        buf[cursor++]=k;
      }
      if(k) goto redraw_lastline;
    }
  }
}

static void mode_Chara(void) {
  SDL_Event event;
  char buf[32];
  int x,y,z,cx,cy,cp,k,px,py;
  cx=0; cy=0; cp=(curpal<<2)|3;
  px=7; py=7;

redraw_mode_Chara:
  curaddr&=0xFFF; curpal&=3; cp&=15; cx&=7; cy&=7; px&=7; py&=7;
  clear_screen();
  sprintf(buf,"Character $%03X *",curaddr);
  draw_string(0,0,Black,White,buf);
  draw_string(2,3,Black,Gray,"\xC9" CP437_hdline16 "\xBB\n" CP437_16row16 "\xC8" CP437_hdline16 "\xBC");
  draw_string((curaddr&15)+3,2,Black,DimGreen,"\x1F\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\x1E");
  draw_string(1,((curaddr>>4)&15)+4,Black,DimGreen,"\x10");
  draw_string(20,((curaddr>>4)&15)+4,Black,DimGreen,"\x11");
  draw_string(0,4,Black,DimBlue,"0\n1\n2\n3\n4\n5\n6\n7\n8\n9\nA\nB\nC\nD\nE\nF\n\n\n\\  0123456789ABCDEF");
  for(x=0;x<256;x++) draw_tile((x&15)+3,(x>>4)+4,curpal,(curaddr&0xF00)|x);
  draw_tile(30,0,cp>>2,clip_addr);
  for(x=0;x<16;x++) draw_rect((x&3)*2+25,(x>>2)*2+3,2,2,chrpalette[x]);
  draw_sel_rect((cp&3)*2+25,(cp>>2)*2+3,2,2);
  draw_string((cp&3)*2+25,2,Black,Gray,"\xDA\xBF");
  draw_string(22,12,Black,Gray,"\xC9" CP437_hdline16 "\xBB\n" CP437_16row16 "\xC8" CP437_hdline16 "\xBC");
  for(y=0;y<8;y++) {
    k=tiles[curaddr].data[y]; z=tiles[curaddr].data[y|8];
    for(x=0;x<8;x++,k<<=1,z<<=1) draw_rect(x*2+23,y*2+13,2,2,chrpalette[(cp&12)|((k>>7)&1)|((z>>6)&2)]);
  }
  draw_sel_rect(cx*2+23,cy*2+13,2,2);
  draw_string(22,cy*2+13,Black,White,"\xDA\n\xC0");
  draw_string(39,cy*2+13,Black,White,"\xBF\n\xD9");
  draw_string(cx*2+23,12,Black,White,"\xDA\xBF");
  draw_string(cx*2+23,29,Black,White,"\xC0\xD9");

  SDL_Flip(screen);
  while(Eventloop(&event)) {
    if(event.type==SDL_KEYDOWN) {
      switch(k=translate_key(&event)) {
        case 10:
        case 13:
        case 27:
        case 'q':
          return;
        case ' ':
          if(cp&1) tiles[curaddr].data[cy]^=128>>cx;
          if(cp&2) tiles[curaddr].data[cy|8]^=128>>cx;
          break;
        case ':':
          do_lastline(':');
          break;
        case '<':
          cp+=4;
          break;
        case '>':
          cp=((cp+1)&3)|(cp&12);
          break;
        case '?':
          // 0123456789012345678901234567890123456789
          help(
            "hjkl=move  q=quit  SP=plot  zxcv=set    \n"
            "<=palette  m=mirror  f=flip  r=fillrect \n"
            "X=xorrect  HJKL=shift  :=lastline  g=get\n"
            "[=prevchar  ]=nextchar  >=color  a=point\n"
          );
          break;
        case 'H':
          hshift_chr(curaddr);
          break;
        case 'J':
          vshift_chr(curaddr);
          break;
        case 'K':
          x=7; while(x--) vshift_chr(curaddr);
          break;
        case 'L':
          x=7; while(x--) hshift_chr(curaddr);
          break;
        case 'X':
          if(px>cx) { x=px; px=cx; cx=x; }
          if(py>cy) { y=py; py=cy; cy=y; }
          xorrect_chr(curaddr,px,py,cx,cy,cp);
          break;
        case 'a':
          px=cx; py=cy;
          break;
        case 'c':
          tiles[curaddr].data[cy]&=~(128>>cx);
          tiles[curaddr].data[cy|8]|=(128>>cx);
          break;
        case 'f':
          flip_chr(curaddr);
          break;
        case 'g':
          cp&=12;
          if(tiles[curaddr].data[cy]&(128>>cx)) cp|=1;
          if(tiles[curaddr].data[cy|8]&(128>>cx)) cp|=2;
          break;
        case 'h':
          cx--;
          break;
        case 'j':
          cy++;
          break;
        case 'k':
          cy--;
          break;
        case 'l':
          cx++;
          break;
        case 'm':
          mirror_chr(curaddr);
          break;
        case 'n':
        case ']':
          curaddr++;
          break;
        case 'p':
        case '[':
          curaddr--;
          break;
        case 'r':
          if(px>cx) { x=px; px=cx; cx=x; }
          if(py>cy) { y=py; py=cy; cy=y; }
          fillrect_chr(curaddr,px,py,cx,cy,cp);
          break;
        case 'v':
          tiles[curaddr].data[cy]|=(128>>cx);
          tiles[curaddr].data[cy|8]|=(128>>cx);
          break;
        case 'x':
          tiles[curaddr].data[cy]|=(128>>cx);
          tiles[curaddr].data[cy|8]&=~(128>>cx);
          break;
        case 'z':
          tiles[curaddr].data[cy]&=~(128>>cx);
          tiles[curaddr].data[cy|8]&=~(128>>cx);
          break;
      }
      if(k) goto redraw_mode_Chara;
    } else if(event.type==SDL_MOUSEBUTTONDOWN) {
      k=event.button.button; x=event.button.x>>3; y=event.button.y>>3;
      if(x>=25 && x<33 && y>=3 && y<11) {
        // clicked palette grid
        x=((x-25)>>1)+((y-3)>>1)*4;
        if(k==SDL_BUTTON_LEFT) cp=x;
      } else if(x>=3 && x<20 && y>=4 && y<21) {
        // clicked character grid
        x+=(curaddr&0xF00)+(y<<4)-67;
        if(k==SDL_BUTTON_LEFT) curaddr=x;
        if(k==SDL_BUTTON_MIDDLE) copy_chr(x,curaddr);
      } else if(x>=23 && x<39 && y>=13 && y<29) {
        // clicked editing grid
        x=(x-23)>>1; y=(y-13)>>1;
        if(k==SDL_BUTTON_LEFT) {
          px=cx; py=cy;
          cx=x; cy=y;
        }
        if(k==SDL_BUTTON_MIDDLE) {
          cp&=12;
          if(tiles[curaddr].data[y]&(128>>x)) cp|=1;
          if(tiles[curaddr].data[y|8]&(128>>x)) cp|=2;
        }
        if(k==SDL_BUTTON_RIGHT) {
          if(cp&1) tiles[curaddr].data[y]|=(128>>x); else tiles[curaddr].data[y]&=~(128>>x);
          if(cp&2) tiles[curaddr].data[y|8]|=(128>>x); else tiles[curaddr].data[y|8]&=~(128>>x);
        }
      }
      goto redraw_mode_Chara;
    }
  }
}

static void mode_Palette(void) {
  SDL_Event event;
  char buf[32];
  int x,y,c,k;
  c=(curpal<<2)|1;

redraw_mode_Palette:
  c&=15; chrpalette[c]&=63;
  clear_screen();
  sprintf(buf,"Palette $%X = Color $%02X",c,chrpalette[c]);
  draw_string(0,0,Black,Gray,buf);
  draw_string(2,3,Black,Gray,"\xC9" CP437_hdline16 "\xBB\n" CP437_16row16 "\xC8" CP437_hdline16 "\xBC");
  for(x=0;x<256;x++) draw_tile((x&15)+3,(x>>4)+4,c>>2,(curaddr&0xF00)|x);
  draw_tile(30,0,curpal,clip_addr);
  for(x=0;x<16;x++) draw_rect((x&3)*2+25,(x>>2)*2+6,2,2,chrpalette[x]);
  draw_string(24,(c>>2)*2+6,Black,Gray,"\xDA\n\xC0");
  draw_string(33,(c>>2)*2+6,Black,Gray,"\xBF\n\xD9");
  draw_string((c&3)*2+25,5,Black,Gray,"\xDA\xBF");
  draw_string((c&3)*2+25,14,Black,Gray,"\xC0\xD9");
  draw_sel_rect((c&3)*2+25,(c>>2)*2+6,2,2);
  for(x=0;x<64;x++) draw_rect((x&15)+23,(x>>4)+18,1,1,x);
  draw_sel_rect((chrpalette[c]&15)+23,(chrpalette[c]>>4)+18,1,1);

  SDL_Flip(screen);
  while(Eventloop(&event)) {
    if(event.type==SDL_KEYDOWN) {
      switch(k=translate_key(&event)) {
        case 27:
        case 'q':
        case 'Z':
          return;
        case '?':
          // 0123456789012345678901234567890123456789
          help(
            "hjkl=move  q=quit  HJKL=set  <>pn=set   \n"
          );
          break;
        case 'H':
        case '<':
          chrpalette[c]--;
          break;
        case 'J':
        case 'p':
          chrpalette[c]+=16;
          break;
        case 'K':
        case 'n':
          chrpalette[c]-=16;
          break;
        case 'L':
        case '>':
          chrpalette[c]++;
          break;
        case 'h':
          c--;
          break;
        case 'j':
          c+=4;
          break;
        case 'k':
          c-=4;
          break;
        case 'l':
          c++;
          break;
      }
      if(k) goto redraw_mode_Palette;
    } else if(event.type==SDL_MOUSEBUTTONDOWN) {
      k=event.button.button; x=event.button.x>>3; y=event.button.y>>3;
      if(x>=25 && x<33 && y>=6 && y<14) {
        // clicked palette grid
        x=((x-25)>>1)+((y-6)>>1)*4;
        if(k==SDL_BUTTON_LEFT) c=x;
        if(k==SDL_BUTTON_MIDDLE) chrpalette[x]=chrpalette[c];
      } else if(x>=23 && x<39 && y>=18 && y<22) {
        // clicked colors
        x+=((y-18)<<4)-23;
        if(k==SDL_BUTTON_LEFT) chrpalette[c]=x;
      }
      goto redraw_mode_Palette;
    }
  }
}

static void mode_Selector(void) {
  SDL_Event event;
  char buf[32];
  int x,y,k;

redraw_mode_Selector:
  curaddr&=0xFFF; curpal&=3;
  clear_screen();
  sprintf(buf,"Character $%03X",curaddr);
  draw_string(0,0,Black,selected[curaddr]?White:Gray,buf);
  draw_string(3,25,Black,Gray,files[curaddr>>8].name);
  sprintf(buf,"%02d",files[curaddr>>8].cont);
  draw_string(0,25,Gray,Black,buf);
  draw_string(2,3,Black,Gray,"\xC9" CP437_hdline16 "\xBB\n" CP437_16row16 "\xC8" CP437_hdline16 "\xBC");
  draw_string((curaddr&15)+3,2,Black,Green,"\x1F\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\x1E");
  draw_string(1,((curaddr>>4)&15)+4,Black,Green,"\x10");
  draw_string(20,((curaddr>>4)&15)+4,Black,Green,"\x11");
  draw_string(0,4,Black,Blue,"0\n1\n2\n3\n4\n5\n6\n7\n8\n9\nA\nB\nC\nD\nE\nF\n\n\n\\  0123456789ABCDEF");
  for(x=0;x<256;x++) draw_tile((x&15)+3,(x>>4)+4,curpal^selected[(curaddr&0xF00)|x],(curaddr&0xF00)|x);
  draw_tile(30,0,curpal,clip_addr);
  for(x=0;x<16;x++) draw_rect((x&3)*2+25,(x>>2)*2+6,2,2,chrpalette[x]);
  draw_string(24,curpal*2+6,Black,Gray,"\xDA\n\xC0");
  draw_sel_rect(25,curpal*2+6,8,2);

  SDL_Flip(screen);
  while(Eventloop(&event)) {
    if(event.type==SDL_KEYDOWN) {
      switch(k=translate_key(&event)) {
        case 10:
          mode_Chara();
          break;
        case 27:
        case 'q':
          return;
        case ' ':
          selected[curaddr]^=1;
          break;
        case '!':
        case ':':
          do_lastline(k);
          break;
        case '&':
          reload_files();
          break;
        case '<':
          curaddr&=0xF00;
          break;
        case '>':
          curaddr|=0x0FF;
          break;
        case '?':
          // 0123456789012345678901234567890123456789
          help(
            "hjkl=move  pn=page  q=quit  w=write     \n"
            ":=lastline  SP=select  iI=invert  yY=all\n"
            "uU=unselect  c=copy  v=paste  DEL=clear \n"
            "RET=edit  a=and  o=or  x=xor  m=mirror  \n"
            "f=flip  z=pal  Z=editpal  !=lastlinesel \n"
            "S=selchar  &=reload                     \n"
          );
          break;
        case 'I':
          for(x=0;x<0x1000;x++) selected[x]^=1;
          break;
        case 'S':
          for(x=0;x<0x1000;x+=0x100) selected[curaddr^x]^=1;
          break;
        case 'U':
          for(x=0;x<0x1000;x++) selected[x]=0;
          break;
        case 'Y':
          for(x=0;x<0x1000;x++) selected[x]=1;
          break;
        case 'Z':
          mode_Palette();
          break;
        case 'a':
          and_chr(curaddr,clip_addr);
          break;
        case 'c':
          copy_chr(clip_addr,curaddr);
          break;
        case 'f':
          flip_chr(curaddr);
          break;
        case 'h':
          curaddr-=1;
          break;
        case 'i':
          for(x=0;x<256;x++) selected[(curaddr&0xF00)|x]^=1;
          break;
        case 'j':
          curaddr+=16;
          break;
        case 'k':
          curaddr-=16;
          break;
        case 'l':
          curaddr+=1;
          break;
        case 'm':
          mirror_chr(curaddr);
          break;
        case 'n':
          curaddr+=256;
          break;
        case 'o':
          or_chr(curaddr,clip_addr);
          break;
        case 'p':
          curaddr-=256;
          break;
        case 'u':
          for(x=0;x<256;x++) selected[(curaddr&0xF00)|x]=0;
          break;
        case 'v':
          copy_chr(curaddr,clip_addr);
          break;
        case 'w':
          save_files();
          break;
        case 'x':
          xor_chr(curaddr,clip_addr);
          break;
        case 'y':
          for(x=0;x<256;x++) selected[(curaddr&0xF00)|x]=1;
          break;
        case 'z':
          curpal++;
          break;
        case 127:
          for(x=0;x<16;x++) tiles[curaddr].data[x]=0;
          break;
      }
      if(k) goto redraw_mode_Selector;
    } else if(event.type==SDL_MOUSEBUTTONDOWN) {
      k=event.button.button; x=event.button.x>>3; y=event.button.y>>3;
      if(x>=3 && x<20 && y>=4 && y<21) {
        // clicked character grid
        x+=(curaddr&0xF00)+(y<<4)-67;
        if(k==SDL_BUTTON_LEFT) curaddr=x;
        if(k==SDL_BUTTON_MIDDLE) copy_chr(x,curaddr);
        if(k==SDL_BUTTON_RIGHT) selected[x]^=1;
      } else if(x>=25 && x<33 && y>=6 && y<14) {
        // clicked palette grid
        if(k==SDL_BUTTON_LEFT) curpal=(y>>1)-3;
      }
      goto redraw_mode_Selector;
    }
  }
}

static void mode_Nametable(void) {
  SDL_Event event;
  char buf[128];
  int x,y,k,cx,cy,cm,sto;
  cx=cy=cm=sto=0;

redraw_mode_Nametable:
  if(cy>29) cy=0; if(cy<0) cy=29;
  curaddr&=0xFFF; curpal&=3; cm&=1; cx&=31-cm; cy&=31-cm;
  clear_screen();
  for(x=0;x<32;x++) {
    for(y=0;y<30;y++) {
      k=(y<<5)|x;
      draw_tile(x,y,nametable[k|0x400]>>6,(((int)nametable[k|0x400]&15)<<8)|nametable[k]);
    }
  }
  draw_sel_rect(cx,cy,cm+1,cm+1);
  buf[1]=0;
  for(k=0;k<7;k++) {
    x=((k&3)<<1)|32; y=(k>>2)*3;
    buf[0]=k+'1';
    draw_string(x,y+2,sto?Blue:Black,White,buf);
    draw_tile(x,y,ntclipboard[k].attr[0]>>6,(((int)ntclipboard[k].attr[0]&15)<<8)|ntclipboard[k].tile[0]);
    draw_tile(x+1,y,ntclipboard[k].attr[1]>>6,(((int)ntclipboard[k].attr[1]&15)<<8)|ntclipboard[k].tile[1]);
    draw_tile(x,y+1,ntclipboard[k].attr[2]>>6,(((int)ntclipboard[k].attr[2]&15)<<8)|ntclipboard[k].tile[2]);
    draw_tile(x+1,y+1,ntclipboard[k].attr[3]>>6,(((int)ntclipboard[k].attr[3]&15)<<8)|ntclipboard[k].tile[3]);
  }
  k=(cy<<5)|cx;
  sprintf(buf,"(%d,%d)\n%d/$%04X\n\n%d/$%03X",cx,cy,nametable[k|0x400]>>6,(((int)nametable[k|0x400]&0x3F)<<8)|nametable[k],curpal,curaddr);
  draw_string(33,7,Black,Gray,buf);
  if(nametable_type==2) draw_string(32,13,Black,Green,"MMC5");
  if(cm) draw_string(34,13,Black,Green,"2x2");
  strncpy(buf,nametable_name,8);
  buf[8]=0;
  draw_string(32,29,Black,White,buf);
  draw_string(34,24,Black,Gray,"\xC9\xCD\xBB\n\xBA \xBA\n\xC8\xCD\xBC");
  draw_tile(35,25,curpal,curaddr);

  SDL_Flip(screen);
  while(Eventloop(&event)) {
    if(event.type==SDL_KEYDOWN) {
      switch(k=translate_key(&event)) {
        case 27:
        case 'q':
          return;
        case ' ':
          sto=0;
          nametable[(cy<<5)|cx]=curaddr;
          nametable[(cy<<5)|cx|0x400]=(curpal<<6)|(curaddr>>8);
          if(cm) {
            nametable[(cy<<5)|cx|0x001]=curaddr;
            nametable[(cy<<5)|cx|0x401]=(curpal<<6)|(curaddr>>8);
            nametable[(cy<<5)|cx|0x020]=curaddr;
            nametable[(cy<<5)|cx|0x420]=(curpal<<6)|(curaddr>>8);
            nametable[(cy<<5)|cx|0x021]=curaddr;
            nametable[(cy<<5)|cx|0x421]=(curpal<<6)|(curaddr>>8);
          }
          break;
        case '&':
          reload_files();
          break;
        case '1' ... '8':
          if(sto) {
            ntclipboard[k-'1'].tile[0]=nametable[(cy<<5)|cx];
            ntclipboard[k-'1'].attr[0]=nametable[(cy<<5)|cx|0x400];
            ntclipboard[k-'1'].tile[1]=nametable[(cy<<5)|cx|(0x001*cm)];
            ntclipboard[k-'1'].attr[1]=nametable[(cy<<5)|cx|0x400|(0x001*cm)];
            ntclipboard[k-'1'].tile[2]=nametable[(cy<<5)|cx|(0x020*cm)];
            ntclipboard[k-'1'].attr[2]=nametable[(cy<<5)|cx|0x400|(0x020*cm)];
            ntclipboard[k-'1'].tile[3]=nametable[(cy<<5)|cx|(0x021*cm)];
            ntclipboard[k-'1'].attr[3]=nametable[(cy<<5)|cx|0x400|(0x021*cm)];
            sto=0;
          } else {
            again1to8keys:
            nametable[(cy<<5)|cx]=ntclipboard[k-'1'].tile[((cy&1)<<1)|(cx&1)]; // "'.2$.1'~#3"
            nametable[(cy<<5)|cx|0x400]=ntclipboard[k-'1'].attr[((cy&1)<<1)|(cx&1)];
            if(cm && !(cx&cy&1)) {
              cy^=cx&1;
              cx^=1;
              goto again1to8keys;
            }
          }
          break;
        case ':':
          do_lastline(':');
          break;
        case '=':
          sto^=1;
          break;
        case '?':
          // 0123456789012345678901234567890123456789
          help(
            "hjkl=move  &=reload  q=quit  w=write    \n"
            "SP=plot  1-8=set  ==store  e=characters \n"
            "M=metatile  :=lastline  z=pal  Z=editpal\n"
            "b=block  []=tile                        \n"
          );
          break;
        case 'M':
          cm^=1;
          break;
        case 'Z':
          mode_Palette();
          break;
        case '[':
          curaddr--;
          break;
        case ']':
          curaddr++;
          break;
        case 'e':
          sto=0; mode_Selector();
          break;
        case 'h':
          sto=0; cx-=cm+1;
          break;
        case 'j':
          sto=0; cy+=cm+1;
          break;
        case 'k':
          sto=0; cy-=cm+1;
          break;
        case 'l':
          sto=0; cx+=cm+1;
          break;
        case 'w':
          save_files();
          reload_files();
          break;
        case 'z':
          curpal++;
          break;
      }
      if(k) goto redraw_mode_Nametable;
    } else if(event.type==SDL_MOUSEBUTTONDOWN) {
      k=event.button.button; x=event.button.x>>3; y=event.button.y>>3;
      if(x<32) {
        // clicked nametable
        if(k==SDL_BUTTON_LEFT) { cx=x; cy=y; }
      }
      goto redraw_mode_Nametable;
    }
  }
}

static inline void init_palette(void) {
  SDL_Color colors[256];
  int i;
  memset(colors,0,sizeof(SDL_Color)*256);
  for(i=0;i<64;i++) {
    colors[i].r=palette[3*i];
    colors[i].g=palette[3*i+1];
    colors[i].b=palette[3*i+2];
    colors[i|64].r=palette[3*i]>>1;
    colors[i|64].g=palette[3*i+1]>>1;
    colors[i|64].b=palette[3*i+2]>>1;
    colors[i|128].r=palette[3*i]>>2;
    colors[i|128].g=palette[3*i+1]>>2;
    colors[i|128].b=palette[3*i+2]>>2;
    colors[i|192].r=i<<2;
    colors[i|192].g=i<<2;
    colors[i|192].b=i<<2;
  }
  SDL_SetColors(screen,colors,0,256);
}

static inline void load_palette(char*filename) {
  FILE*fp;
  int x;
  fp=fopen(filename,"rb");
  if(!fp) {
    error("Cannot load palette:",filename);
    return;
  }
  if(fread(chrpalette,1,16,fp)!=16) error("Palette is too short",filename);
  fclose(fp);
}

static inline void init_chr_load(int*page,char*filename,int n) {
  FILE*fp;
  struct stat st;
  boolean p=1;
  if(*page>=16) fatal_error("Too many pages to load!",filename);
  if(!stat(filename,&st)) n=(st.st_size+0xFFF)>>12;
  // fprintf(stderr,"%d %s\n",st.st_size,filename); fflush(stderr);
  if(n+*page>16) fatal_error("Too many pages to load!",filename);
  while(n) {
    strncpy(files[*page].name,filename,255);
    files[(*page)++].cont=p*n;
    p=0;
    n--;
  }
}

int main(int argc,char**argv) {
  int sz=1; // size of empty character sets (pages)
  boolean sw=1; // set 0 if no more switches
  int pn=0; // page number
  char*q;

  // Initialize SDL
  if(SDL_Init(SDL_INIT_VIDEO)<0) return 1;
  screen=SDL_SetVideoMode(320,240,8,SDL_SWSURFACE);
  if(!screen) return 1;
  SDL_WM_SetCaption("Famitile v" Famitile_Version,"Famitile");
  init_palette();
  SDL_EnableKeyRepeat(SDL_DEFAULT_REPEAT_DELAY,SDL_DEFAULT_REPEAT_INTERVAL);
  SDL_EnableUNICODE(1);

  // Initialize chrpalette data
  chrpalette[0]=0x1D; chrpalette[1]=0x00; chrpalette[2]=0x10; chrpalette[3]=0x20;
  chrpalette[4]=0x1D; chrpalette[5]=0x01; chrpalette[6]=0x11; chrpalette[7]=0x21;
  chrpalette[8]=0x1D; chrpalette[9]=0x05; chrpalette[10]=0x15; chrpalette[11]=0x25;
  chrpalette[12]=0x1D; chrpalette[13]=0x0A; chrpalette[14]=0x1A; chrpalette[15]=0x2A;

  // Read command line
  argc-=!!argc; argv++;
  while(argc--) {
    if(sw && **argv=='-') {
      switch((*argv)[1]) {
        case '-': // Stop reading switches
          sw=0;
          break;
        case 'm': // MMC5 extension nametables
          nametable_type++;
          // fallthrough
        case 'n': // Normal nametables
          nametable_type++;
          if(!argc) fatal_error("Too few arguments for -m or -n","");
          argc--;
          if(strlen(*++argv)>255) fatal_error("Too long filename","");
          strcpy(nametable_name,*argv);
          break;
        case 'p': // Load palette
          if(!argc) fatal_error("Too few arguments for -p","");
          argc--;
          load_palette(*++argv);
          break;
        case 's': // Size of empty character sets
          if(!argc) fatal_error("Too few arguments for -s","");
          argc--;
          q=*++argv;
          sz=read_number(&q);
          if(sz<1 || sz>16) fatal_error("Number out of range for -s","");
          break;
        default:
          fatal_error("Unrecognized command-line switch:",*argv);
      }
    } else if(**argv) {
      sw=0;
      init_chr_load(&pn,*argv,sz);
    }
    argv++;
  }

  // Run program
  reload_files();
  if(nametable_type) mode_Nametable(); else mode_Selector();

  // Finished
  SDL_Quit();
  return 0;
}
