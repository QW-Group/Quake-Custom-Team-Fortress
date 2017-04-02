/*
Copyright (C) 1996-1997 Id Software, Inc.

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  

See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

*/
// sys.h -- non-portable functions

int	Sys_FileTime (char *path);

void Sys_mkdir (char *path);

void Sys_Error (char *error, ...);
// an error will cause the entire program to exit

void Sys_Printf (char *fmt, ...);
// send text to the console

void Sys_ConsoleColor(int forecolor, int backcolor); // OfN
void Sys_BeginColor(void);
void Sys_EndColor(void);

// OfN - Color values
#define COLOR_BLACK    0x00
#ifdef _WIN32 // Windows oriented values (Win32 API friendly)
	#define COLOR_RED      0x04
	#define COLOR_GREEN    0x02
	#define COLOR_BLUE     0x01
#else // Unix oriented values (ANSI friendly)
	#define COLOR_RED      0x01
	#define COLOR_GREEN    0x02
	#define COLOR_BLUE     0x04
#endif 
#define COLOR_BROWN    COLOR_RED | COLOR_GREEN
#define COLOR_ORANGE   COLOR_BROWN
#define COLOR_MAGENTA  COLOR_BLUE | COLOR_RED
#define COLOR_CYAN     COLOR_GREEN | COLOR_BLUE
#define COLOR_GRAY     COLOR_RED | COLOR_GREEN | COLOR_BLUE
#define COLOR_INTENSE  0x08
#define COLOR_PINK     COLOR_MAGENTA | COLOR_INTENSE
#define COLOR_YELLOW   COLOR_BROWN | COLOR_INTENSE
#define COLOR_TEAL     COLOR_CYAN | COLOR_INTENSE
#define COLOR_LRED     COLOR_RED | COLOR_INTENSE
#define COLOR_LGREEN   COLOR_GREEN | COLOR_INTENSE
#define COLOR_LBLUE    COLOR_BLUE | COLOR_INTENSE
#define COLOR_WHITE    COLOR_GRAY | COLOR_INTENSE

#define COLOR_DEFAULT  -1
#define COLOR_CURRENT  -2
#define COLOR_NOCHANGE COLOR_CURRENT
#define COLOR_RESET    COLOR_DEFAULT

// Custom color states
#define CCSTATE_NORMAL 0
#define CCSTATE_CUSTOM 1
#define CCSTATE_BEBACK 2

// Color Settings

//- Connection messages 
#define COLOR_FORE_CONNECTION COLOR_GREEN
#define COLOR_BACK_CONNECTION COLOR_DEFAULT
//- Drop messages
#define COLOR_FORE_DROP COLOR_RED
#define COLOR_BACK_DROP COLOR_DEFAULT
//- Command Prompt
#define COLOR_FORE_PROMPT COLOR_WHITE
#define COLOR_BACK_PROMPT COLOR_DEFAULT
//- Input Command
#define COLOR_FORE_COMMANDLINE COLOR_TEAL
#define COLOR_BACK_COMMANDLINE COLOR_DEFAULT
//- Chat text
#define COLOR_FORE_CHAT COLOR_WHITE
#define COLOR_BACK_CHAT COLOR_DEFAULT
//- Admin (Rcon's)
#define COLOR_FORE_ADMIN COLOR_CYAN
#define COLOR_BACK_ADMIN COLOR_DEFAULT
//- Console say's
#define COLOR_FORE_CONSAY COLOR_BROWN
#define COLOR_BACK_CONSAY COLOR_DEFAULT

extern int CustomColor_state;
// OfN - End

void Sys_Quit (void);
double Sys_DoubleTime (void);
char *Sys_ConsoleInput (void);
void Sys_Init (void);
