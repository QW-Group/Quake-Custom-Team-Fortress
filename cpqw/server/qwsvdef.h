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
// quakedef.h -- primary header for server

#define	QUAKE_GAME			// as opposed to utilities

//define	PARANOID			// speed sapping error checking

#ifdef _WIN32
//ragma warning( disable : 4244 4127 4201 4214 4514 4305 4115 4018 )
#endif

#include <assert.h>
#include <stddef.h>
#include <time.h>
#include <math.h>
#include <string.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <setjmp.h>
#include <ctype.h>

#include "bothdefs.h"

#include "common.h"
#include "bspfile.h"
#include "sys.h"
#include "zone.h"
#include "mathlib.h"

#include "cvar.h"
#include "net.h"
#include "protocol.h"
#include "cmd.h"
#include "model.h"
#include "crc.h"
#include "progs.h"

#include "server.h"
#include "world.h"
#include "pmove.h"

//=============================================================================

// the host system specifies the base of the directory tree, the
// command line parms passed to the program, and the amount of memory
// available for the program to use

typedef struct
{
	char	*basedir;
	char	*cachedir;		// for development over ISDN lines
	int		argc;
	char	**argv;
	void	*membase;
	int		memsize;
} quakeparms_t;


//=============================================================================

//
// host
//
extern	quakeparms_t host_parms;

extern	cvar_t		sys_nostdout;
extern	cvar_t		developer;

extern	qboolean	host_initialized;		// true if into command execution
extern	double		host_frametime;
extern	double		realtime;			// not bounded in any way, changed at
										// start of every frame, never reset

void SV_Error (char *error, ...);
void SV_Init (quakeparms_t *parms);

void Con_Printf (char *fmt, ...);
void Con_DPrintf (char *fmt, ...);

// OfN
void SV_SoundBroadcast(char* soundfile, float level);
extern int restart_state;
extern cvar_t sv_updating;
extern cvar_t sv_warnmodels;
extern cvar_t con_cleanout;
extern cvar_t con_cleanin;
extern cvar_t con_prompt;
extern cvar_t con_cleanlog;

void SV_RetrieveClientVersion(client_t* theclient);

// OfN - Crash log stuff
extern qboolean crashlog_running;
extern FILE* crashlog_file;
void CrashLog_Start();
void CrashLog_Append(char* text);
void CrashLog_End();

// OfN - Client types
#define CLTYPE_DEFAULT    1
#define CLTYPE_PROZACQW   2
#define CLTYPE_FUHQUAKE   3
#define CLTYPE_AMFQUAKE   4
#define CLTYPE_ZQUAKE     5
#define CLTYPE_QUAKEFORGE 6
#define CLTYPE_FTEQUAKE   7
#define CLTYPE_EZQUAKE    8
void SetConsoleToUserColor(client_t* theclient);

#define QWSVVERSION  2.42
#define CPSVVERSION  1.03
