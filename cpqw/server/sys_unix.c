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
#include "qwsvdef.h"

#ifdef NeXT
#include <libc.h>
#endif

#if defined(__linux__) || defined(sun)
#include <sys/stat.h>
#include <unistd.h>
#include <sys/time.h>
#include <errno.h>
#include <signal.h>
#else
#include <sys/dir.h>
#endif

cvar_t	sys_nostdout = {"sys_nostdout","0"};
cvar_t	sys_extrasleep = {"sys_extrasleep","0"};

extern cvar_t con_color; // OfN
extern cvar_t con_talk; // OfN

qboolean	stdin_ready;

// OfN
int DefaultColorANSIfore;
int DefaultColorANSIback;
int CustomColor_state;

/*
===============================================================================

				REQUIRED SYS FUNCTIONS

===============================================================================
*/

/*
============
Sys_FileTime

returns -1 if not present
============
*/
int	Sys_FileTime (char *path)
{
	struct	stat	buf;
	
	if (stat (path,&buf) == -1)
		return -1;
	
	return buf.st_mtime;
}


/*
============
Sys_mkdir

============
*/
void Sys_mkdir (char *path)
{
	if (mkdir (path, 0777) != -1)
		return;
	if (errno != EEXIST)
		Sys_Error ("mkdir %s: %s",path, strerror(errno)); 
}


/*
================
Sys_DoubleTime
================
*/
double Sys_DoubleTime (void)
{
	struct timeval tp;
	struct timezone tzp;
	static int		secbase;

	gettimeofday(&tp, &tzp);
	
	if (!secbase)
	{
		secbase = tp.tv_sec;
		return tp.tv_usec/1000000.0;
	}
	
	return (tp.tv_sec - secbase) + tp.tv_usec/1000000.0;
}

/*
================
Sys_Error
================
*/
void Sys_Error (char *error, ...)
{
	va_list		argptr;
	char		string[1024];
	
	va_start (argptr,error);
	vsprintf (string,error,argptr);
	va_end (argptr);
	printf ("Fatal error: %s\n",string);

	CrashLog_End();
	
	exit (1);
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
	
	if (!con_color.value) return;

	if (forecolor == -1 && backcolor == -1) // Reset default
	{
		// Build the ANSI color code
		sprintf(ansi_code,"%c[%s;3%u;4%um",(unsigned char)27,(DefaultColorANSIfore & COLOR_INTENSE)? "01" : "00",(unsigned int)(DefaultColorANSIfore - (DefaultColorANSIfore & COLOR_INTENSE)),(unsigned int)(DefaultColorANSIback - (DefaultColorANSIback & COLOR_INTENSE)));
		
		// Output color ANSI color code change
		printf(ansi_code);
		
		return;// Job done
	}
	else if (forecolor == -1 || backcolor == -1)
	{
		if (forecolor == -1)
		{			
			// Build the ANSI color code
			sprintf(ansi_code,"%c[%s;3%u;4%um",(unsigned char)27,(DefaultColorANSIfore & COLOR_INTENSE)? "01" : "00",(unsigned int)(DefaultColorANSIfore - (DefaultColorANSIfore & COLOR_INTENSE)),(unsigned int)(backcolor));
			
			// Output color ANSI color code change
			printf(ansi_code);
		}
		else
		{
	
			// Build the ANSI color code
			sprintf(ansi_code,"%c[%s;3%u;4%um",(unsigned char)27,(forecolor & COLOR_INTENSE)? "01" : "00",(unsigned int)(forecolor - (forecolor & COLOR_INTENSE)),(unsigned int)(DefaultColorANSIback - (DefaultColorANSIback & COLOR_INTENSE)));
			
			// Output color ANSI color code change
			printf(ansi_code);
		}
			
		return; // Job done
	}
		
	// Build the ANSI color code
	sprintf(ansi_code,"%c[%s;3%u;4%um",(unsigned char)27,(forecolor & COLOR_INTENSE)? "01" : "00",(unsigned int)(forecolor - (forecolor & COLOR_INTENSE)),(unsigned int)(backcolor));

	// Output color ANSI color code change
	printf(ansi_code);	
}

/*
================
Sys_Printf
================
*/
void Sys_Printf (char *fmt, ...)
{
	va_list		argptr;
	static char		text[8192];
	unsigned char		*p;

	va_start (argptr,fmt);
	vsprintf (text,fmt,argptr);
	va_end (argptr);

	// OfN

	if (!con_cleanlog.value && sv_logfile)
		fprintf (sv_logfile, "%s", text);

	if (con_cleanout.value)
		ConvertConsoleStringChars(text);

	if (con_cleanlog.value && sv_logfile)
		fprintf (sv_logfile, "%s", text);
	// OfN - End

	if (strlen(text) > sizeof(text))
		Sys_Error("memory overwrite in Sys_Printf");

    if (sys_nostdout.value)
        return;

    	/*if ( *text != 27 ) { // use default color (if doesnt start with code)
		for (p = color[COLOR_TEXT]; *p; p++)
			putc(*p, stdout);
	}*/
	if (CustomColor_state == CCSTATE_BEBACK)	
	{
		Sys_ConsoleColor(COLOR_RESET,COLOR_RESET);
		CustomColor_state = CCSTATE_NORMAL;
	}
		
	
	
	for (p = (unsigned char *)text; *p; p++) {
		*p &= 0x7f;
		if ((*p>128 || *p<32) && *p!=10 && *p!=13 && *p!=9 && *p!=27)
			printf("[%02x]", *p);
		else
			putc(*p, stdout);
	}
	fflush(stdout);
}


/*
================
Sys_Quit
================
*/
void Sys_Quit (void)
{
	exit (0);		// appkit isn't running
}

static int do_stdin = 1;

/*
================
Sys_ConsoleInput

Checks for a complete line of text typed in at the console, then forwards
it to the host command processor
================
*/
char *Sys_ConsoleInput (void)
{
	static char	text[256];
	int		len;

	if (!stdin_ready || !do_stdin)
		return NULL;		// the select didn't say it was ready
	stdin_ready = false;

	len = read (0, text, sizeof(text));
	if (len == 0) {
		// end of file
		do_stdin = 0;
		return NULL;
	}
	if (len < 1)
		return NULL;
	text[len-1] = 0;	// rip off the /n and terminate
	
	return text;
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
	Cvar_RegisterVariable (&sys_nostdout);
	Cvar_RegisterVariable (&sys_extrasleep);

	DefaultColorANSIfore = COLOR_GRAY;
	DefaultColorANSIback = COLOR_BLACK;
}

void PR_RunError (char *error, ...);

void seg_fault_handler(int whatever)
{
    Sys_Printf("Segfault %d\n",whatever);
	PR_RunError("Segfault\n");
}

/*
=============
main
=============
*/
void main(int argc, char *argv[])
{
	double			time, oldtime, newtime;
	quakeparms_t	parms;
	fd_set	fdset;
	extern	int		net_socket;
    struct timeval timeout;
	int j;

	memset (&parms, 0, sizeof(parms));

	COM_InitArgv (argc, argv);	
	parms.argc = com_argc;
	parms.argv = com_argv;

	parms.memsize = 16*1024*1024;

	j = COM_CheckParm("-mem");
	if (j)
		parms.memsize = (int) (Q_atof(com_argv[j+1]) * 1024 * 1024);
	if ((parms.membase = malloc (parms.memsize)) == NULL)
		Sys_Error("Can't allocate %ld\n", parms.memsize);

	parms.basedir = ".";

/*
	if (Sys_FileTime ("id1/pak0.pak") != -1)
	else
		parms.basedir = "/raid/quake/v2";
*/

	SV_Init (&parms);

        signal(SIGSEGV, seg_fault_handler);

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
		FD_ZERO(&fdset);
		if (do_stdin)
			FD_SET(0, &fdset);
		FD_SET(net_socket, &fdset);
		timeout.tv_sec = 1;
		timeout.tv_usec = 0;
		if (select (net_socket+1, &fdset, NULL, NULL, &timeout) == -1)
			continue;
		stdin_ready = FD_ISSET(0, &fdset);

	// find time passed since last cycle
		newtime = Sys_DoubleTime ();
		time = newtime - oldtime;
		oldtime = newtime;
		
		SV_Frame (time);		
		
	// extrasleep is just a way to generate a fucked up connection on purpose
		if (sys_extrasleep.value)
			usleep (sys_extrasleep.value);
	}	
}

