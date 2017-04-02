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
#include <sys/types.h>
#include <sys/timeb.h>
//#include <winsock.h>
#include <winsock2.h> // OfN
#include <conio.h>
#include "qwsvdef.h"
#include "winquake.h"
#include "mmsystem.h"


cvar_t	sys_nostdout = {"sys_nostdout","0"};
cvar_t  sys_sleep = {"sys_sleep","2"}; // OfN


// OfN
extern cvar_t con_color;
extern cvar_t con_prompt;
extern cvar_t con_talk; // OfN

#define PROMPT_STR "] "
#define PROMPT_LEN 2

#define IN_MAX   256

#define INLIST_STRLEN 70
#define INLIST_NUMITEMS 20
char in_list[INLIST_NUMITEMS][INLIST_STRLEN];
int in_listcur;
int in_listlast;

char in_text[IN_MAX];
int in_len;
qboolean in_prompt;
HANDLE hConsoleOut;
HANDLE hConsoleIn;
WORD DefaultColorWinAPI;
int DefaultColorANSIfore;
int DefaultColorANSIback;
int CurrentForeColor;
int CurrentBackColor;

int CustomColor_state;

/*
================
Sys_FileTime
================
*/
int	Sys_FileTime (char *path)
{
	FILE	*f;
	
	f = fopen(path, "rb");
	if (f)
	{
		fclose(f);
		return 1;
	}
	
	return -1;
}

/*
================
Sys_mkdir
================
*/
void Sys_mkdir (char *path)
{
	_mkdir(path);
}


/*
================
Sys_Error
================
*/
void Sys_Error (char *error, ...)
{
	va_list		argptr;
	char		text[1024];

	va_start (argptr,error);
	vsprintf (text, error,argptr);
	va_end (argptr);

//    MessageBox(NULL, text, "Error", 0 /* MB_OK */ );
	printf ("ERROR: %s\n", text);

	CrashLog_End();

	exit (1);
}


/*
================
Sys_DoubleTime
================
*/
double Sys_DoubleTime (void)
{
	double t;
    struct _timeb tstruct;
	static int	starttime;

	_ftime( &tstruct );
 
	if (!starttime)
		starttime = tstruct.time;
	t = (tstruct.time-starttime) + tstruct.millitm*0.001;
	
	return t;
}

void Sys_ClearCommandPrompt (qboolean prompt_too)
{
	//static char tempstr[IN_MAX+PROMPT_LEN];
	static DWORD retval;
	static COORD coord;
	static CONSOLE_SCREEN_BUFFER_INFO conInfo;

	if (in_len || prompt_too)
	{
		//memset(&tempstr,32,in_len + ((int)prompt_too*PROMPT_LEN));

		GetConsoleScreenBufferInfo(hConsoleOut,&conInfo);
		coord.X = (short int)!(prompt_too)*PROMPT_LEN;
		coord.Y = conInfo.dwCursorPosition.Y;
		
		FillConsoleOutputCharacter(hConsoleOut,' ',in_len + ((int)prompt_too*PROMPT_LEN),coord,&retval);
		SetConsoleCursorPosition(hConsoleOut,coord);
	}
}

/*
================
Sys_ConsoleInput
================
*/

char *Sys_ConsoleInput (void)
{
	// OfN - Stuff below made global
	//static char	text[256];
	//static int		len;
	int		c, i;
	char* p;
	static char clipb_c[IN_MAX];
	static HANDLE clipb_h;
	
	// OfN
	if (con_prompt.value)
	{
		if (!in_prompt)
		{
			Sys_ConsoleColor(COLOR_FORE_PROMPT,COLOR_BACK_PROMPT);
			CustomColor_state = CCSTATE_BEBACK;
						
			fputs(PROMPT_STR,stdout);			
			in_prompt = true;

			Sys_ConsoleColor(COLOR_FORE_COMMANDLINE,COLOR_BACK_COMMANDLINE);
			
			if (con_cleanin.value)
			{		
				if (in_len)
					fputs(in_text,stdout);
			}			
		}		
	}	
	else
	{
		if (CurrentForeColor != COLOR_FORE_COMMANDLINE || CurrentBackColor != COLOR_BACK_COMMANDLINE)
			Sys_ConsoleColor(COLOR_FORE_COMMANDLINE,COLOR_BACK_COMMANDLINE);
	}

	// OfN For typen items scroll working (remove in buffer)
	if (!in_len)
		in_text[0] = '\0';
	
	// read a line out
	while (_kbhit())
	{			
		c = _getch();

		// First handle any composed input (like arrow keys)
		if (!c || c == 224)
		if (_kbhit())
		{
			c = _getch();

			if (c == 72) // up arrow
			{				
				Sys_ClearCommandPrompt(false);				
				in_len = 0; // <-- reused
				
				// Scroll up command list items, skipping empty ones
				for (c = in_listcur; in_len != 2; c--)
				{
					if (c < 0)
						c = INLIST_NUMITEMS - 1;
					
					if (c == in_listcur)
						in_len++;						
					
					if (in_list[c][0])
					if (!in_text[0] || Q_strcmp(in_text,in_list[c]))
						break;					
				}

				if (in_len == 2)
				{
					in_len = 0;
					in_text[0] = 0;
					continue;
				}

				in_listcur = c;
				
				fputs(in_list[c],stdout);
				Q_strcpy(in_text,in_list[c]);
				in_len = Q_strlen(in_text);
				continue;
			}
			else if (c == 80) // down arrow
			{
				Sys_ClearCommandPrompt(false);				
				in_len = 0;

				in_listcur ++;
				
				// Scroll down command list items, skipping empty ones
				for (c = in_listcur; in_len != 2; c++)
				{
					if (c >= INLIST_NUMITEMS)
						c = 0;
					
					if (c == in_listcur)
						in_len++;						
					
					if (in_list[c][0])
					if (!in_text[0] || Q_strcmp(in_text,in_list[c]))
						break;					
				}

				if (in_len == 2)
				{
					in_len = 0;
					in_text[0] = 0;
					continue;
				}

				in_listcur = c;
				
				fputs(in_list[c],stdout);
				Q_strcpy(in_text,in_list[c]);
				in_len = Q_strlen(in_text);

				continue;
			}
			else if (c == 75) // left arrow
				c = 8; // Convert to backspace
			else if (c == 77) // right
				c = 32; // Convert to space
			else if (c == 71) // home
				c = 27; // Convert to ESC
		}

		if (c == 27) // Escape
		{			
			if (!in_len)
				continue;

			Sys_ClearCommandPrompt(false);

			in_text[0] = 0;
			in_len = 0;
			
			continue;
		}

		if (c == 22) // Ctrl-V, windows clipboard content paste
		{
			if (OpenClipboard(NULL))
			{
				if (clipb_h = GetClipboardData(CF_TEXT))
				{
					p = (char*)clipb_h;

					i = 0;
					for (c = 0; c < (IN_MAX - in_len) && p[c]; c++)
					{
						if (p[c] == '\r' || p[c] == '\n')
							i++;
						else
							in_text[(in_len + c) - i] = p[c];
					}

					in_text[((in_len + c) - i)] = '\0';

					fputs(&in_text[in_len],stdout);
										
					in_len += c - i;
				}
				else
					Sys_Printf("Win32 PASTE: Clipboard does not contain text!\n");
				
				CloseClipboard();
				continue;
			}
			else
			{
				Sys_Printf("Win32 PASTE: Unable to open clipboard!\n");
				continue;
			}
		}

		if (c == 8 && !in_len && in_prompt) // Do not allow prompt to be deleted
			continue;
		if (c == '\r' && !in_len) // Ignore carriage return with empty command
			continue;
		if (in_len > (IN_MAX - 2) && c != '\r' && c != 8) // Impide user to type beyond maximum
			continue;
		if (c == 9) // Tab
		{
			if (in_len) // Anything typen?
			{
				p = Cmd_CompleteCommand(in_text); // Check with commands

				if (p) // Partial command?
				if (Q_strlen(p)>in_len) // incomplete?
				{
					// Ok, complete it
					p += in_len;
					fputs(p,stdout);
					_fputchar(32);
					in_len += Q_strlen(p)+1;
					Q_strcat(in_text,p);
					Q_strcat(in_text," ");
					continue;
				}
				
				p = Cvar_CompleteVariable(in_text); // Check with cvars

				if (p) // Partial cvar?
				if (Q_strlen(p)>in_len) // incomplete?
				{
					// Ok, complete it
					p += in_len;
					fputs(p,stdout);
					_fputchar(32);
					in_len += Q_strlen(p)+1;
					Q_strcat(in_text,p);
					Q_strcat(in_text," ");
				}
			}

			continue;
		}

		//putch (c); // <-- ORiginal
		_fputchar(c);

		if (c == '\r')
		{
			in_text[in_len] = 0;
			putch ('\n');
			in_len = 0;
						
			in_prompt = false; // OfN

			// Add this to the list of used commands if different than last one
			if (Q_strcmp(in_text,in_list[in_listcur]))
			{
				in_listcur++;
				if (in_listcur >= INLIST_NUMITEMS)
					in_listcur = 0;

				memcpy(in_list[in_listcur],in_text,INLIST_STRLEN);
				in_list[in_listcur][INLIST_STRLEN - 1] = 0;				
			}
			
			return in_text;
		}
		if (c == 8)
		{
			if (in_len)
			{
				putch (' ');
				putch (c);
				in_len--;
				in_text[in_len] = 0;
			}
			continue;
		}
		in_text[in_len] = c;
		in_len++;
		in_text[in_len] = 0;
		if (in_len == sizeof(in_text))
			in_len = 0;
	}

	return NULL;
}

/* OfN
===============
Functions to set/remove color flags
===============
*/

void Sys_BeginColor(void)
{
	CustomColor_state = CCSTATE_CUSTOM;
}

void Sys_EndColor(void)
{
	CustomColor_state = CCSTATE_BEBACK;	
}

/* OfN
================
Sys_ConsoleColor
================
*/

void Sys_ConsoleColor(int forecolor, int backcolor)
{
	static char ansi_code[64];
	static int ansi_fore, ansi_back;
	
	if (!con_color.value) return;

	if (forecolor == COLOR_CURRENT)
		forecolor = CurrentForeColor;
	else
		CurrentForeColor = forecolor;

	if (backcolor == COLOR_CURRENT)
		backcolor = CurrentBackColor;
	else
		CurrentBackColor = backcolor;

	if (con_color.value == 1) // Mode1: Use Win32 console API for color change
	{
		if (forecolor == -1 && backcolor == -1) // Reset windows default
			SetConsoleTextAttribute(hConsoleOut,DefaultColorWinAPI);
		else if (forecolor == -1 || backcolor == -1)
		{
			if (forecolor == -1)
				SetConsoleTextAttribute(hConsoleOut,(unsigned short)((DefaultColorWinAPI & (unsigned short)0x000f)|(unsigned short)(backcolor<<4)));
			else
				SetConsoleTextAttribute(hConsoleOut,(unsigned short)((DefaultColorWinAPI & (unsigned short)0x00f0)|(unsigned short)forecolor));
		}
		else
			SetConsoleTextAttribute(hConsoleOut,(WORD)(forecolor|(backcolor<<4)));
	}
	else if (con_color.value == 2) // Mode2: Use ANSI color codes on standard output
	{
		if (forecolor == -1 && backcolor == -1) // Reset windows default
		{
			// Build the ANSI color code
			sprintf(ansi_code,"%c[%s;3%u;4%um",(char)27,(DefaultColorANSIfore & COLOR_INTENSE)? "01" : "00",(unsigned int)(DefaultColorANSIfore - (DefaultColorANSIfore & COLOR_INTENSE)),(unsigned int)(DefaultColorANSIback - (DefaultColorANSIback & COLOR_INTENSE)));
			
			// Output color ANSI color code change
			fputs(ansi_code,stdout);

			return;// Job done
		}
		else if (forecolor == -1 || backcolor == -1)
		{
			if (forecolor == -1)
			{			
				// Invert colors for ANSI (defined values are for Win32 api)
				ansi_back = 0;
				if (backcolor && (backcolor & COLOR_GRAY) == COLOR_GRAY)
				{
					if (backcolor & COLOR_RED)
						ansi_back = COLOR_BLUE;
					if (backcolor & COLOR_GREEN)
						ansi_back |= COLOR_GREEN;
					if (backcolor & COLOR_BLUE)
						ansi_back |= COLOR_RED;
				}
				else
					ansi_back = backcolor - (backcolor & COLOR_INTENSE);				
				
				// Build the ANSI color code
				sprintf(ansi_code,"%c[%s;3%u;4%um",(char)27,(DefaultColorANSIfore & COLOR_INTENSE)? "01" : "00",(unsigned int)(DefaultColorANSIfore - (DefaultColorANSIfore & COLOR_INTENSE)),(unsigned int)(ansi_back));
				
				// Output color ANSI color code change
				fputs(ansi_code,stdout);
			}
			else
			{
				// Invert colors for ANSI (defined values are for Win32 api)
				ansi_fore = 0;
				if (forecolor && (forecolor & COLOR_GRAY) == COLOR_GRAY)
				{
					if (forecolor & COLOR_RED)
						ansi_fore = COLOR_BLUE;
					if (forecolor & COLOR_GREEN)
						ansi_fore |= COLOR_GREEN;
					if (forecolor & COLOR_BLUE)
						ansi_fore |= COLOR_RED;
				}
				else
					ansi_fore = forecolor - (forecolor & COLOR_INTENSE);

				// Build the ANSI color code
				sprintf(ansi_code,"%c[%s;3%u;4%um",(char)27,(forecolor & COLOR_INTENSE)? "01" : "00",(unsigned int)(ansi_fore),(unsigned int)(DefaultColorANSIback - (DefaultColorANSIback & COLOR_INTENSE)));
				
				// Output color ANSI color code change
				fputs(ansi_code,stdout);
			}
				
			return; // Job done
		}
		
		// Invert colors for ANSI (defined values are for Win32 api)
		ansi_fore = 0;
		if (forecolor && (forecolor & COLOR_GRAY) == COLOR_GRAY)
		{
			if (forecolor & COLOR_RED)
				ansi_fore = COLOR_BLUE;
			if (forecolor & COLOR_GREEN)
				ansi_fore |= COLOR_GREEN;
			if (forecolor & COLOR_BLUE)
				ansi_fore |= COLOR_RED;
		}
		else
			ansi_fore = forecolor - (forecolor & COLOR_INTENSE);

		ansi_back = 0;
		if (backcolor && (backcolor & COLOR_GRAY) == COLOR_GRAY)
		{
			if (backcolor & COLOR_RED)
				ansi_back = COLOR_BLUE;
			if (backcolor & COLOR_GREEN)
				ansi_back |= COLOR_GREEN;
			if (backcolor & COLOR_BLUE)
				ansi_back |= COLOR_RED;
		}
		else
			ansi_back = backcolor - (backcolor & COLOR_INTENSE);
		
		// Build the ANSI color code
		sprintf(ansi_code,"%c[%s;3%u;4%um",(char)27,(forecolor & COLOR_INTENSE)? "01" : "00",(unsigned int)(ansi_fore),(unsigned int)(ansi_back));

		// Output color ANSI color code change
		fputs(ansi_code,stdout);
	}
}

/*
================
Sys_Printf
================
*/
void Sys_Printf (char *fmt, ...)
{
	va_list		argptr;

	static char clean_buff[8192]; // OfN

	if (sys_nostdout.value)
		return;

	//printf(color[COLOR_TEXT]);
	va_start (argptr,fmt);
	
	// OfN
/*	if (con_cleanout.value)
	{
		vsprintf (clean_buff,fmt,argptr);
		ConvertConsoleStringChars(clean_buff);
		
		// Remove command line and prompt if needed
		if (in_prompt)
		{
			// Remove "> " prefix, and any typen text
			Sys_ClearCommandPrompt(true);
			
			in_prompt = false;
		}

		// Output to console
		fputs(clean_buff,stdout);		
	}
	else // OfN - Original code follows..
		vprintf (fmt,argptr);*/
	
	vsprintf (clean_buff,fmt,argptr);
	
	if (!con_cleanlog.value && sv_logfile)
		fprintf (sv_logfile, "%s", clean_buff);

	if (con_cleanout.value)
		ConvertConsoleStringChars(clean_buff);

	if (con_cleanlog.value && sv_logfile)
		fprintf (sv_logfile, "%s", clean_buff);
		
	// Remove command line and prompt if needed
	if ((con_cleanin.value && in_len) || in_prompt)
		// Remove "> " prefix, and any typen text
		Sys_ClearCommandPrompt(true);		
	
	in_prompt = false;

	// Check if we need to reset color
	if (CustomColor_state == CCSTATE_BEBACK) // We did end on custom color
	{
		Sys_ConsoleColor(COLOR_RESET,COLOR_RESET); // Reset
		CustomColor_state = CCSTATE_NORMAL;
	}

	// Output to console
	fputs(clean_buff,stdout);	
		
	va_end (argptr);
}

/*
================
Sys_Quit
================
*/
void Sys_Quit (void)
{
	exit (0);
}


/*
=============
Sys_Init

Quake calls this so the system can register variables before host_hunklevel
is marked
=============
*/
void Sys_Init (void)
{
	int i;

	timeBeginPeriod( 1 );

	Cvar_RegisterVariable (&sys_nostdout);
	Cvar_RegisterVariable (&sys_sleep); // OfN

	// OfN
	in_prompt = false;
	
	for (i = 0; i < INLIST_NUMITEMS; i++)
		in_list[i][0] = '\0';

	in_listcur = 0;

	CustomColor_state = CCSTATE_NORMAL;
}

/*
==================
main

==================
*/
char	*newargv[256];

int main (int argc, char **argv)
{
	quakeparms_t	parms;
	double			newtime, time, oldtime;
	static	char	cwd[1024];
	//struct timeval	timeout; //- OfN -->NET_Sleep
	//fd_set			fdset; //- OfN -->NET_Sleep
	int				t;

	// OfN 
	CONSOLE_CURSOR_INFO cursorinfo;
	CONSOLE_SCREEN_BUFFER_INFO conInfo;

	// Get console out and in handles
	hConsoleOut = GetStdHandle(STD_OUTPUT_HANDLE);
	hConsoleIn = GetStdHandle(STD_INPUT_HANDLE);

	// Make cursor a square block
	cursorinfo.bVisible = TRUE;
	cursorinfo.dwSize = 99;	
	SetConsoleCursorInfo(hConsoleOut,&cursorinfo);

	// Set current console window title
	SetConsoleTitle("Prozac QuakeWorld server");

	// Get screen buffer data, that includes current text colors/attributes
	GetConsoleScreenBufferInfo(hConsoleOut,&conInfo);

	// Set default text fore/background colors for both API and ANSI
	DefaultColorWinAPI = conInfo.wAttributes;
	CurrentForeColor = CurrentBackColor = 0;
	
	DefaultColorANSIfore = 0;
	if (conInfo.wAttributes & FOREGROUND_BLUE)
		DefaultColorANSIfore = COLOR_RED;
	if (conInfo.wAttributes & FOREGROUND_GREEN)
		DefaultColorANSIfore |= COLOR_GREEN;
	if (conInfo.wAttributes & FOREGROUND_RED)
		DefaultColorANSIfore |= COLOR_BLUE;
	if (conInfo.wAttributes & FOREGROUND_INTENSITY)
		DefaultColorANSIfore |= COLOR_INTENSE;
	DefaultColorANSIback = 0;
	if (conInfo.wAttributes & BACKGROUND_BLUE)
		DefaultColorANSIback = COLOR_RED;
	if (conInfo.wAttributes & BACKGROUND_GREEN)
		DefaultColorANSIback |= COLOR_GREEN;
	if (conInfo.wAttributes & BACKGROUND_RED)
		DefaultColorANSIback |= COLOR_BLUE;
	if (conInfo.wAttributes & BACKGROUND_INTENSITY)
		DefaultColorANSIback |= COLOR_INTENSE;
	// OfN end

	COM_InitArgv (argc, argv);
	
	parms.argc = com_argc;
	parms.argv = com_argv;

	parms.memsize = 16*1024*1024;

	if ((t = COM_CheckParm ("-heapsize")) != 0 &&
		t + 1 < com_argc)
		parms.memsize = Q_atoi (com_argv[t + 1]) * 1024;

	if ((t = COM_CheckParm ("-mem")) != 0 &&
		t + 1 < com_argc)
		parms.memsize = Q_atoi (com_argv[t + 1]) * 1024 * 1024;

	parms.membase = malloc (parms.memsize);

	if (!parms.membase)
		Sys_Error("Insufficient memory.\n");

	parms.basedir = ".";
	parms.cachedir = NULL;

	SV_Init (&parms);

// run one frame immediately for first heartbeat
	SV_Frame (0.1);		

//
// main loop
//
	oldtime = Sys_DoubleTime () - 0.1;
	while (1)
	{
	// select on the net socket and stdin
	// the only reason we have a timeout at all is so that if the last
	// connected client times out, the message would not otherwise
	// be printed until the next event.
		/* //OfN Done in NET_Sleep()
		FD_ZERO(&fdset);
		FD_SET(net_socket, &fdset);
		timeout.tv_sec = 0;
		timeout.tv_usec = 100;
		if (select (net_socket+1, &fdset, NULL, NULL, &timeout) == -1)
			continue;/**/

		// OfN
		NET_Sleep(1);
		Sleep((unsigned long)sys_sleep.value);
		// OfN - end

	// find time passed since last cycle
		newtime = Sys_DoubleTime ();
		time = newtime - oldtime;
		oldtime = newtime;
		
		SV_Frame (time);				
	}	

	return true;
}

/*
================
OfN - I'm tired of the "Priority.exe" program so..
Also on windows xp/2000 with a priority raise the server runs smoother

Sys_Win32_RaisePriority
================
*/

void Sys_Win32_RaisePriority(void)
{
	if (COM_CheckParm ("-nopriority"))
	{
		Con_Printf("Priority raise not done. Running on a Win32 OS though.\n");
		return;
	}

	SetPriorityClass(GetCurrentProcess(),HIGH_PRIORITY_CLASS);
	Con_Printf("Running on a Win32 OS - Priority boost enabled.\n");
}

