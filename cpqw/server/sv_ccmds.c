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

#include "qwsvdef.h"

#include <time.h> // OfN - For date stamp on pinned messages signature

#ifdef _WIN32
#include <sys\stat.h>// OfN - For getting file information
#else
#include <sys/stat.h>// OfN - For getting file information
#endif

qboolean	sv_allow_cheats;

int fp_messages=4, fp_persecond=4, fp_secondsdead=10;
char fp_msg[255] = { 0 };
extern cvar_t cl_warncmd;
	extern		redirect_t	sv_redirected;


/*
===============================================================================

OPERATOR CONSOLE ONLY COMMANDS

These commands can only be entered from stdin or by a remote operator datagram
===============================================================================
*/

/*
====================
SV_SetMaster_f

Make a master server current
====================
*/
void SV_SetMaster_f (void)
{
	char	data[2];
	int		i;

	memset (&master_adr, 0, sizeof(master_adr));

	for (i=1 ; i<Cmd_Argc() ; i++)
	{
		if (!strcmp(Cmd_Argv(i), "none") || !NET_StringToAdr (Cmd_Argv(i), &master_adr[i-1]))
		{
			Con_Printf ("Setting nomaster mode.\n");
			return;
		}
		if (master_adr[i-1].port == 0)
			master_adr[i-1].port = BigShort (27000);

		Con_Printf ("Master server at %s\n", NET_AdrToString (master_adr[i-1]));

		Con_Printf ("Sending a ping.\n");

		data[0] = A2A_PING;
		data[1] = 0;
		NET_SendPacket (2, data, master_adr[i-1]);
	}

	svs.last_heartbeat = -99999;
}


/*
==================
SV_Quit_f
==================
*/
void SV_Quit_f (void)
{
	SV_FinalMessage ("server shutdown\n");
	Con_Printf ("Shutting down.\n");
	SV_Shutdown ();
	Sys_Quit ();
}

/*
============
SV_Logfile_f
============
*/
void SV_Logfile_f (void)
{
	char	name[MAX_OSPATH];

	if (sv_logfile)
	{
		Con_Printf ("File logging off.\n");
		fclose (sv_logfile);
		sv_logfile = NULL;
		return;
	}

	sprintf (name, "%s/qconsole.log", com_gamedir);
	Con_Printf ("Logging text to %s.\n", name);
	sv_logfile = fopen (name, "a");
	if (!sv_logfile)
		Con_Printf ("failed.\n");
}


/*
============
SV_Fraglogfile_f
============
*/
void SV_Fraglogfile_f (void)
{
	char	name[MAX_OSPATH];
	int		i;

	if (sv_fraglogfile)
	{
		Con_Printf ("Frag file logging off.\n");
		fclose (sv_fraglogfile);
		sv_fraglogfile = NULL;
		return;
	}

	// find an unused name
	for (i=0 ; i<1000 ; i++)
	{
		sprintf (name, "%s/frag_%i.log", com_gamedir, i);
		sv_fraglogfile = fopen (name, "r");
		if (!sv_fraglogfile)
		{	// can't read it, so create this one
			sv_fraglogfile = fopen (name, "w");
			if (!sv_fraglogfile)
				i=1000;	// give error
			break;
		}
		fclose (sv_fraglogfile);
	}
	if (i==1000)
	{
		Con_Printf ("Can't open any logfiles.\n");
		sv_fraglogfile = NULL;
		return;
	}

	Con_Printf ("Logging frags to %s.\n", name);
}


/*
==================
SV_SetPlayer

Sets host_client and sv_player to the player with idnum Cmd_Argv(1)
==================
*/
qboolean SV_SetPlayer (void)
{
	client_t	*cl;
	int			i;
	int			idnum;

	idnum = atoi(Cmd_Argv(1));

	for (i=0,cl=svs.clients ; i<MAX_CLIENTS ; i++,cl++)
	{
		if (!cl->state)
			continue;
		if (cl->userid == idnum)
		{
			host_client = cl;
			sv_player = host_client->edict;
			return true;
		}
	}
	Con_Printf ("Userid %i is not on the server\n", idnum);
	return false;
}


/*
==================
SV_God_f

Sets client to godmode
==================
*/
void SV_God_f (void)
{
	if (!sv_allow_cheats)
	{
		Con_Printf ("You must run the server with -cheats to enable this command.\n");
		return;
	}

	if (!SV_SetPlayer ())
		return;

	sv_player->v.flags = (int)sv_player->v.flags ^ FL_GODMODE;
	if (!((int)sv_player->v.flags & FL_GODMODE) )
		SV_ClientPrintf (host_client, PRINT_HIGH, "godmode OFF\n");
	else
		SV_ClientPrintf (host_client, PRINT_HIGH, "godmode ON\n");
}


void SV_Noclip_f (void)
{
	if (!sv_allow_cheats)
	{
		Con_Printf ("You must run the server with -cheats to enable this command.\n");
		return;
	}

	if (!SV_SetPlayer ())
		return;

	if (sv_player->v.movetype != MOVETYPE_NOCLIP)
	{
		sv_player->v.movetype = MOVETYPE_NOCLIP;
		SV_ClientPrintf (host_client, PRINT_HIGH, "noclip ON\n");
	}
	else
	{
		sv_player->v.movetype = MOVETYPE_WALK;
		SV_ClientPrintf (host_client, PRINT_HIGH, "noclip OFF\n");
	}
}


/*
==================
SV_Give_f
==================
*/
void SV_Give_f (void)
{
	char	*t;
	int		v;
	
	if (!sv_allow_cheats)
	{
		Con_Printf ("You must run the server with -cheats to enable this command.\n");
		return;
	}
	
	if (!SV_SetPlayer ())
		return;

	t = Cmd_Argv(2);
	v = atoi (Cmd_Argv(3));
	
	switch (t[0])
	{
	case '2':
	case '3':
	case '4':
	case '5':
	case '6':
	case '7':
	case '8':
	case '9':
		sv_player->v.items = (int)sv_player->v.items | IT_SHOTGUN<< (t[0] - '2');
		break;
	
	case 's':
		sv_player->v.ammo_shells = v;
		break;		
	case 'n':
		sv_player->v.ammo_nails = v;
		break;		
	case 'r':
		sv_player->v.ammo_rockets = v;
		break;		
	case 'h':
		sv_player->v.health = v;
		break;		
	case 'c':
		sv_player->v.ammo_cells = v;
		break;		
	}
}

/*
==================
KK_qwchar  lowers alphas and accounts for fancy quake chars
==================
*/
char KK_qwchar (char c)
{
	c &= 0x7F;
	switch (c) {
	case 0x05:
	case 0x0E:
	case 0x0F:
		return '.';

	case 0x10:			return '[';
	
	case 0x11:			return ']';
	
	case 0x12:// ... 0x1B:
	case 0x13:
	case 0x14:
	case 0x15:
	case 0x16:
	case 0x17:
	case 0x18:
	case 0x19:
	case 0x1A:
	case 0x1B:
		return c - 0x12 + '0';
	
	case 0x1C:			return '.';
	
	case 0x20:
	case 0x21:
	case 0x22:
	case 0x23:
	case 0x24:
	case 0x25:
	case 0x26:
	case 0x27:
	case 0x28:
	case 0x29:
	case 0x2A:
	case 0x2B:
	case 0x2C:
	case 0x2D:
	case 0x2E:
	case 0x2F:
	
	case 0x30:
	case 0x31:
	case 0x32:
	case 0x33:
	case 0x34:
	case 0x35:
	case 0x36:
	case 0x37:
	case 0x38:
	case 0x39:
	case 0x3A:
	case 0x3B:
	case 0x3C:
	case 0x3D:
	case 0x3E:
	case 0x3F:

	case 0x40:
	case 0x41:
	case 0x42:
	case 0x43:
	case 0x44:
	case 0x45:
	case 0x46:
	case 0x47:
	case 0x48:
	case 0x49:
	case 0x4A:
	case 0x4B:
	case 0x4C:
	case 0x4D:
	case 0x4E:
	case 0x4F:

	case 0x50:
	case 0x51:
	case 0x52:
	case 0x53:
	case 0x54:
	case 0x55:
	case 0x56:
	case 0x57:
	case 0x58:
	case 0x59:
	case 0x5A:
	case 0x5B:
	case 0x5C:
	case 0x5D:
	case 0x5E:
	case 0x5F:

	case 0x60:
	case 0x61:
	case 0x62:
	case 0x63:
	case 0x64:
	case 0x65:
	case 0x66:
	case 0x67:
	case 0x68:
	case 0x69:
	case 0x6A:
	case 0x6B:
	case 0x6C:
	case 0x6D:
	case 0x6E:
	case 0x6F:

	case 0x70:
	case 0x71:
	case 0x72:
	case 0x73:
	case 0x74:
	case 0x75:
	case 0x76:
	case 0x77:
	case 0x78:
	case 0x79:
	case 0x7A:
	case 0x7B:
	case 0x7C:
	case 0x7D:
	case 0x7E:
	case 0x7F:
		return tolower(c);

	default:			return 'X';
	}
}

/*
==================
KK_Match_Str
==================
*/
qboolean KK_Match_Str (char *substr, int *uidp)
{
	int		i, j, count;
	char		lstr[128], lname[128];
	client_t	*cl;

	strncpy(lstr, substr, sizeof(lstr)-1);
	lstr[ sizeof(lstr)-1 ] = 0;
	for (j = 0; lstr[j]; j++)
		lstr[j] = KK_qwchar(lstr[j]);

	for (i = count = 0, cl = svs.clients; i < MAX_CLIENTS; i++, cl++) {
		if (!cl->state) continue;
		strncpy(lname, cl->name, sizeof(lname)-1);
		lname[ sizeof(lname)-1 ] = 0;
		for (j = 0; lname[j]; j++) 
			lname[j] = KK_qwchar(lname[j]);
		if (strstr(lname,lstr)) {
			*uidp = cl->userid;
			count++;
			Con_Printf ("User %04d matches with name: %s\n", *uidp, cl->name);
		}
	}
	if (count) {
		if (count > 1) {
			*uidp = 0;
			Con_Printf ("Too many matches, command not done!\n");
		}
		return true;
	}
	return false;
}

/*
==================
OfN - Used for progs built-in "getclient"
==================
*/

edict_t* KK_Match_Str2 (char *substr)
{
	int		i, j, count;
	char		lstr[128], lname[128];
	client_t	*cl;

	edict_t*    retedict;

	retedict = 0;

	strncpy(lstr, substr, sizeof(lstr)-1);
	lstr[ sizeof(lstr)-1 ] = 0;
	for (j = 0; lstr[j]; j++)
		lstr[j] = KK_qwchar(lstr[j]);

	for (i = count = 0, cl = svs.clients; i < MAX_CLIENTS; i++, cl++) {
		if (!cl->state) continue;
		strncpy(lname, cl->name, sizeof(lname)-1);
		lname[ sizeof(lname)-1 ] = 0;
		for (j = 0; lname[j]; j++) 
			lname[j] = KK_qwchar(lname[j]);
		if (strstr(lname,lstr)) {
			//*uidp = cl->userid;
			retedict = cl->edict;
			count++;
			//Con_Printf ("User %04d matches with name: %s\n", *uidp, cl->name);
		}
	}
	if (count) {
		if (count > 1) {
			//*uidp = 0;
			//Con_Printf ("Too many matches, command not done!\n");
			return 0;
		}
		return retedict;
	}
	return 0;
}

/*
==================
KK_Setup_Color
==================
*/

// WARN: following two arrays have #defines of indexes in server.h

char *color_key[] = {	"color_t1",	// localinfo keys for color codes
			"color_t2",
			"color_t3",
			"color_t4",
			"color_spec",
			"color_text",
			"color_chat",
			"color_conn",
			"color_rcon"
};
char *color_default[]={ "01;34",  // team 1 names, bold blue
			"01;31",  // team 2 names, bold red
			"00;33",  // team 3 names, norm yellow
			"01;32",  // team 4 names, bold green
			"01;37",  // spectators names, bold white
			"00;36",  // text, norm cyan
			"01;33",  // chat, bold yellow
			"00;37",  // (dis)connect info, norm white
			"01;36"   // rcon and admin cmds, bold cyan
};
#define COLOR_NUM	sizeof(color_default)/sizeof(color_default[0])

char color[COLOR_NUM][COLOR_LEN];

void KK_Setup_Color (void)
{
	int i;
	char *s;

	for (i=0; i<COLOR_NUM; i++)		// start with no codes
		strcpy(color[i],"");

	s = Info_ValueForKey(localinfo, "color_console");
	if (stricmp(s,"on")) return; 		// color not wanted, bye
	
	for (i=0; i<COLOR_NUM; i++) 		// start with defaults
		sprintf(color[i], "[%sm", color_default[i]);

	for (i=0; i<COLOR_NUM; i++) {		// use localinfo keys if set
		s = Info_ValueForKey(localinfo, color_key[i]);
		if (*s) sprintf(color[i], "[%.*sm", COLOR_LEN-4, s);
	}
}

/*
==================
KK_Team_Color
==================
*/
int KK_Team_No(client_t *cl);

char *KK_Team_Color (client_t *cl)
{
	int    t;

	if (cl->spectator)
		return color[COLOR_SPEC];
	else if ( (t = KK_Team_No(cl)) )
		return color[t-1];
	return "";
}
ddef_t  *ED_FindField(char *f);

/*
======================
SV_Map_f

handle a 
map <mapname>
command from the console or progs.
======================
*/
void SV_Map_f (void)
{
	char	level[MAX_QPATH];
	char	expanded[MAX_QPATH];
	FILE	*f;
	ddef_t  *def;

	// OfN - Disable map changes using rcon, stop abusive/childish admins on prozac!!
	/*if (rcon_from_user)
	{
		Con_Printf ("You are an admin, but you must vote to change map, as any other player.\n");
		return;
	}*/
	if (restart_state || sv_updating.value)
	{
		if (restart_state)
			Con_Printf("Server is going to restart, map change not allowed!\n");
		else
			Con_Printf("Server update in curse, map change not allowed!\n");
		return;	
	}

	if (Cmd_Argc() != 2)
	{
		Con_Printf ("map <levelname> : continue game on a new level\n");
		return;
	}
	strcpy (level, Cmd_Argv(1));

#if 0
	if (!strcmp (level, "e1m8"))
	{	// QuakeWorld can't go to e1m8
		SV_BroadcastPrintf (PRINT_HIGH, "can't go to low grav level in QuakeWorld...\n");
		strcpy (level, "e1m5");
	}
#endif

	// check to make sure the level exists
	sprintf (expanded, "maps/%s.bsp", level);
	COM_FOpenFile (expanded, &f);
	if (!f)
	{
		Con_Printf ("Can't find %s\n", expanded);
		return;
	}
	fclose (f);

	SV_BroadcastCommand ("changing\n");
	SV_SendMessagesToAll ();

	SV_SpawnServer (level);

	//WK WOWOW -- This is how you can access variables in the progs
	// KK code setup start
	team_no_offset = 0;			// setup team number code
	if ((def = ED_FindField("team_no")))
		team_no_offset = def->ofs * 4;
	real_owner_offset = 0;			// setup color console code
	if ((def = ED_FindField("real_owner")))
		real_owner_offset = def->ofs * 4;
	cltype_offset = 0;
	if ((def = ED_FindField("cltype")))
		cltype_offset = def->ofs * 4;
	clversion_offset = 0;
	if ((def = ED_FindField("clversion")))
		clversion_offset = def->ofs * 4;
	runes_owned_offset = 0;
	if ((def = ED_FindField("runes_owned")))
		runes_owned_offset = def->ofs * 4;
	job_offset = 0;
	if ((def = ED_FindField("job")))
		job_offset = def->ofs * 4;
	KK_Setup_Color();	

	
	//Sys_Printf("job_offset=0x%X\n",job_offset); //WK Print debug info for job
	Con_DPrintf("team_no_offset=0x%X\n", team_no_offset); //Goes to server console
    Con_DPrintf("real_owner_offset=0x%X\n", real_owner_offset);
	
	SV_PrecacheUsage_f();
	SV_EntUsage_f();
	
	// KK code setup end

	SV_BroadcastCommand ("reconnect\n");
}

/* OfN
==================
SV_SavePins

Saves pinned messages to file (file defined on the cvar "sv_pinsfile")
==================
*/

void SV_SavePins()
{
	char	name[MAX_OSPATH];
	FILE* pinsfile;
	int i;

	if (Q_strlen(Cvar_VariableString("sv_pinsfile"))==0)
	{
		Con_Printf("sv_pinsfile not set!\n");
		return;
	}

	sprintf (name, "%s/%s", com_gamedir,Cvar_VariableString("sv_pinsfile"));
	
	pinsfile = fopen(name,"wb");
	if (pinsfile==NULL)
	{
		Con_Printf ("Couldn't open \"%s\" for writing!\n", name);
		return;
	}

	for (i = 0; i < NUM_PINMSGS; i++)
	{
		fwrite(pinmsg[i].msg,MAX_PINMSGITEM_STRING,1,pinsfile);
		fwrite(pinmsg[i].sign,MAX_PINMSGSIGN_STRING,1,pinsfile);
		fwrite(&pinmsg[i].counter,4,1,pinsfile);
	}

	fclose(pinsfile);

	Con_Printf ("Pinned messages were saved to \"%s\" (on server)\n", name);
}

/* OfN
==================
SV_LoadPins

Loads pinned messages from file (file defined on the cvar "sv_pinsfile")
==================
*/

void SV_LoadPins()
{
	char	name[MAX_OSPATH];
	FILE* pinsfile;
	float numpins_onfile;
	int i, z;
	
	struct stat pinstat;
	
	//char tmpbuffer[MAX_PINMSGITEM_STRING];	

	if (Q_strlen(Cvar_VariableString("sv_pinsfile"))==0)
	{
		Con_Printf("sv_pinsfile not set!\n");
		return;
	}

	sprintf (name, "%s/%s", com_gamedir,Cvar_VariableString("sv_pinsfile"));
	
	pinsfile = fopen(name,"rb");
	if (pinsfile==NULL)
	{
		Con_Printf ("Couldn't open \"%s\" for reading!\n", name);
		return;
	}
	
	// Check for size of file as a safety measure	
	fstat(fileno(pinsfile),&pinstat);

	numpins_onfile = pinstat.st_size / (MAX_PINMSGITEM_STRING + MAX_PINMSGSIGN_STRING + 4);
	
	if (numpins_onfile != (int)numpins_onfile)
	{
		Con_Printf ("File \"%s\" isn't a pinned messages file!\n", name);
		fclose(pinsfile);
		return;
	}

	i = (int)numpins_onfile;

	for (z = 0; z < NUM_PINMSGS && z < i; z++)
	{
		fread(pinmsg[z].msg,MAX_PINMSGITEM_STRING,1,pinsfile);
		fread(pinmsg[z].sign,MAX_PINMSGSIGN_STRING,1,pinsfile);
		fread(&pinmsg[z].counter,4,1,pinsfile);
	}

	fclose(pinsfile);
		
	Con_Printf ("Pinned messages retrieved from \"%s\" (on server)\n", name);
}

/* OfN
==================
SV_Restart_f

Restarts server (Quits with error code 2 and shell is supposed to launch server again)
==================
*/

#define RESTART_CLSTUFF "wait;wait;wait;wait;wait;wait;wait;wait;wait;wait;wait;wait;wait;reconnect\n"

void SV_Restart_f (void)
{
	client_t *client;
	int j;
	
	// Save pinned messages and penalties
	SV_SavePins();
	SV_WriteIP_f();

	SZ_Clear (&net_message);

	MSG_WriteByte (&net_message, svc_print);
	MSG_WriteByte (&net_message, PRINT_HIGH);
	MSG_WriteString (&net_message, "\nùûûûûûûûûûûûûûûûûûûûûûûûûûü\n Server ÚÂÛÙ·ÚÙ engagedÆÆÆ \nùûûûûûûûûûûûûûûûûûûûûûûûûûü\n\n");
	
	MSG_WriteByte (&net_message, svc_stufftext);
	MSG_WriteString (&net_message, RESTART_CLSTUFF);
	MSG_WriteByte (&net_message, svc_disconnect);

	for (j = 0, client = svs.clients; j < MAX_CLIENTS; j++, client++)
	{
		if (client->state >= cs_spawned)
			Netchan_Transmit (&client->netchan, net_message.cursize, net_message.data);
	}
	
	Con_Printf ("Shutting down. (Server restart, shell must launch server again)\n");
	SV_Shutdown ();
	
	// Error code 2 on exit, shell must identify it and restart the server itself, not us
	exit(2);	
}

/* OfN
==================
SV_DelKey_f

Removes a serverinfo key, localinfo or both
==================
*/

void SV_SendServerInfoChange(char *key, char *value);

void SV_DelKey_f (void)
{
	int i, counter;
	char* v;
	
	if (Cmd_Argc() == 1)
	{
		Con_Printf("usage: delkey KEYNAME1 [KEYNAME2...]\n");
		return;
	}

	counter = 0;

	for (i = 0; i < Cmd_Argc() - 1; i++)
	{
		if (Cmd_Argv(i+1)[0] == '*')
		{
			Con_Printf ("Star variable \"%s\" cannot be changed.\n",Cmd_Argv(i+1));
		}
		else
		{
			// Check if in serverinfo's
			v = Info_ValueForKey(svs.info, Cmd_Argv(i+1));

			if (v != "")
			{
				Con_Printf("Serverinfo key \"%s\" with value \"%s\" has been deleted.\n",Cmd_Argv(i+1),v);
				Info_SetValueForKey (svs.info, Cmd_Argv(i+1), "", MAX_SERVERINFO_STRING);
				SV_SendServerInfoChange(Cmd_Argv(i+1), "");

				counter ++;
			}

			// Check if in localinfo's
			v = Info_ValueForKey(localinfo, Cmd_Argv(i+1));

			if (v != "")
			{
				Con_Printf("Localinfo key \"%s\" with value \"%s\" has been deleted.\n",Cmd_Argv(i+1),v);
				Info_SetValueForKey (localinfo, Cmd_Argv(i+1), "", MAX_LOCALINFO_STRING);

				counter ++;
			}
		}
	}

	if (counter == 0)
	{
		Con_Printf("No matching keys found!\n");
	}	
}

/* OfN
==================
SV_Version_f

Displays server version information
==================
*/

void SV_Version_f (void)
{
	Con_Printf ("Prozac Server Version %4.2f (QW %4.2f) (Build %04d)\n", CPSVVERSION,QWSVVERSION, build_number());
	Con_Printf ("Exe: "__TIME__" "__DATE__"\n");
}

/* OfN
==================
SV_EntUsage_f

Displays current server entity/edict usage
==================
*/

void SV_EntUsage_f (void)
{
	int i, nume;
	edict_t* ent;
	
	nume = 0;
	ent = NEXT_EDICT(sv.edicts);
	for (i=1 ; i<sv.num_edicts ; i++, ent = NEXT_EDICT(ent))
	{
		if (ent->free)
			continue;

		nume++;
	}
	
	Con_Printf("Edicts used (atm): %3d/%d [%.2d%% usage]\n",nume,MAX_EDICTS,(int)(((float)nume / MAX_EDICTS)*100));
}

/* OfN
==================
SV_PrecacheUsage_f

Displays current server precache sizes
==================
*/

void SV_PrecacheUsage_f (void)
{
	int i, j;
	
	for (i=j=0; i<MAX_MODELS ; i++) 
	{
		if (!sv.model_precache[i]) break;
		if (sv.model_precache[i][0] == '*') j++;
	}
	
	Con_Printf("Models precacheed: %3d/%d [%.2d%% usage] (map: %d others: %d)\n", i, MAX_MODELS,(int)(((float)i / MAX_MODELS)*100), j, i-j); // Sys_Printf
	
	for (i=0; i<MAX_SOUNDS ; i++) 
	{
		if (!sv.sound_precache[i]) break;		
	}

	Con_Printf("Sounds precacheed: %3d/%d [%.2d%% usage]\n", i, MAX_SOUNDS, (int)(((float)i / MAX_SOUNDS)*100));
}

void SV_Help_f (void)
{
	Con_Printf("Information commands avaliable:\n\"cvars\"     - Displays cvars of server\n\"commands\"  - Displays server commands\n\"status\"    - Prints state of server\n\"precaches\" - Reports precache usage\n\"ents\"      - Reports edicts usage\n\"version\"   - Prints server version\n");
}

void SV_DisplayCvars_f (void)
{
	cvar_t	*var;
	int i;
	
	Con_Printf("Avaliable server Cvars:\n");

	i = 1;

	for (var=cvar_vars ; var ; var=var->next)
	{
		Con_Printf("%22s",var->name);
		
		if (i % 3 == 0)
			Con_Printf("\n");

		i++;
	}

	if ((i-1) % 3 != 0)
		Con_Printf("\n");

	Con_Printf("Total: %d Cvars\n",i);
}

void SV_DisplayCommands_f (void)
{
	Cmd_ListCommands();
}

/* OfN
==================
SV_Pinmsg_f

Handles pinned messages on server
==================
*/

void SV_Pinmsg_f (void)
{
	char* name;
	char* timestamp;
	time_t timedata;
	int i;
	qboolean isbegin;
	
	name = (char*)Name_of_sender();
	if (name == NULL) // If no name assume its from server console
		name = "Console";

	timedata = time(NULL);
	timestamp = ctime(&timedata);	

	timestamp[24]='\0'; // Replace \n with NULL

	i = atoi(Cmd_Argv(1)) - 1;

	if (Q_strcasecmp(Cmd_Argv(1), "view") == 0)
	{
		if (Cmd_Argc() == 2)  //no argument
		{
			isbegin = true;

			for (i = 0; i < NUM_PINMSGS; i++)
			{
				if (pinmsg[i].msg[0])
				{
					Con_Printf("\nPinned message #%d is:\n\n%s\n\n%s\n",i+1,pinmsg[i].msg,pinmsg[i].sign);
					isbegin = false;
				}
			}

			if (isbegin)
				Con_Printf("No pinned messages!\n");
		}
		else
		{
			i = atoi(Cmd_Argv(2)) - 1;

			if (i < 0 || i >= NUM_PINMSGS)
				Con_Printf("Invalid number of pinned message '%s' to view!\n",Cmd_Argv(2));
			else
			{
				if (pinmsg[i].msg[0])
					Con_Printf("Pinned message #%d is:\n\n%s\n\n%s\n",i+1,pinmsg[i].msg,pinmsg[i].sign);
				else
					Con_Printf("Pinned message slot #%d is not used!\n",i+1);
			}
		}
		
	}                     //1     1s   2     2s    3     3s
	else if (Q_strcasecmp(Cmd_Argv(1), "clear") == 0)
	{		
		if (Q_strcasecmp(Cmd_Argv(2),"all") == 0)
		{
			isbegin = true;
			
			for (i = 0; i < NUM_PINMSGS; i++)
			{
				if (pinmsg[i].msg[0])
				{
					pinmsg[i].msg[0] = '\0';
					pinmsg[i].sign[0] = '\0';
					pinmsg[i].counter = 0;
					isbegin = false;
				}
			}

			if (isbegin)
				Con_Printf("No messages to clear!\n");
			else
				Con_Printf ("All pinned messages have been deleted.\n");	
		}
		else
		{
			i = atoi(Cmd_Argv(2)) - 1;

			if (i < 0 || i >= NUM_PINMSGS)
			{
				if (Cmd_Argv(2) == "")
					Con_Printf("You should specify a message number or 'all'!\n");
				else
					Con_Printf("Invalid number of pinned message '%s' to clear!\n",Cmd_Argv(2));
			}
			else
			{
				if (pinmsg[i].msg[0])
				{
					pinmsg[i].counter = 0;
					pinmsg[i].msg[0] = '\0';
					pinmsg[i].sign[0] = '\0';

					Con_Printf("Pinned message #%d has been deleted.\n",i+1);
				}
				else
					Con_Printf("Message slot #%d is not used!\n",i+1);
			}
		}
	}
	else if (Q_strcasecmp(Cmd_Argv(1), "save") == 0)
	{
		SV_SavePins();
	}
	else if (Q_strcasecmp(Cmd_Argv(1), "load") == 0)
	{
		SV_LoadPins();
	}
	else if (Q_strcasecmp(Cmd_Argv(1), "stats") == 0)
	{		
		isbegin = true;
		for (i = 0; i < NUM_PINMSGS; i++)
		{
			if (pinmsg[i].msg[0])
			{
				if (isbegin)
					Con_Printf ("Current statistics are:\n");
				
				isbegin = false;
					
				Con_Printf("Message #%d displayed %u times\n",i+1,pinmsg[i].counter);
			}
		}

		if (isbegin)
			Con_Printf("No pinned messages set!\n");
	}
	else if (i >= 0 && i < NUM_PINMSGS && Cmd_Argv(2) != "")
	{
		if (!rcon_from_user && sv_redirected)// You cant set pin messages remotelly without beeing connected on server, cause we need his/her name
		{
			Con_Printf ("Not allowed without beeing connected!\n");	
			return;
		}		
		
		if (Cmd_Argc() >= 4)
		{
			if (Q_strlen(pinmsg_cmdbuffer) >= MAX_PINMSGITEM_STRING - 2)
			{
				Con_Printf("Text message too long!\n");
				return;
			}
		}
		else
		{
			if (Q_strlen(Cmd_Argv(2)) >= MAX_PINMSGITEM_STRING - 2)
			{
				Con_Printf("Text message too long!\n");
				return;
			}
		}

		if (pinmsg[i].msg[0])
			Con_Printf ("Message #%d has been replaced.\n",i+1);	
		else
			Con_Printf ("Message #%d has been set.\n",i+1);	

		if (Cmd_Argc() >= 4)
			Q_strcpy(pinmsg[i].msg,pinmsg_cmdbuffer);
		else
			Q_strcpy(pinmsg[i].msg,Cmd_Argv(2)); 

		pinmsg[i].counter = 0;		

		if (Q_strlen(name)+Q_strlen(timestamp)+11 >= MAX_PINMSGSIGN_STRING - 2)
		{
			Q_strcpy(pinmsg[i].sign,"(Error on signature of message)");
			Con_Printf ("Error signing message!\n");	
		}
		else
		{
			Q_strcpy(pinmsg[i].sign,"Set on ");
			Q_strcat(pinmsg[i].sign,timestamp);
			Q_strcat(pinmsg[i].sign," by ");
			Q_strcat(pinmsg[i].sign,name);
		}
	}
	else
		Con_Printf ("usage: pinmsg n \"Message Text\"\nor  pinmsg view|clear|stats|load|save\n");
}

/*
==================
SV_Kick_f

Kick a user off of the server
==================
*/
void SV_Kick_f (void)
{
	int			i;
	client_t	*cl;
	int			uid;

	if (Cmd_Argc() != 2) {
		Con_Printf ("usage: kick <name/userid>\n");
		return;
	}
	if (KK_Match_Str(Cmd_Argv(1), &uid)) {	// name matched
		if (!uid) return;		// too many matches
	} else {
		uid = atoi(Cmd_Argv(1));	// assume userid
	}
	
	for (i = 0, cl = svs.clients; i < MAX_CLIENTS; i++, cl++) {
		if (!cl->state) continue;
		if (cl->userid == uid) {
			SV_BroadcastPrintf (PRINT_HIGH, "%s was kicked\n", cl->name);
			// print directly, because the dropped client won't get the
			// SV_BroadcastPrintf message
			SV_ClientPrintf (cl, PRINT_HIGH, "You were kicked from the game\n");
			SV_DropClient (cl); 
			return;
		}
	}

	Con_Printf ("Couldn't find user %s\n", Cmd_Argv(1));
}

#define MAXPENALTY 1440 //60.0
/*
==================
SV_Cuff_f

(hand)Cuff and Un-Cuff a user  (attack and any impulses ignored)
==================
*/
void SV_Cuff_f (void)
{
	int		i, uid;
	double		mins = 0.5;
	qboolean	all, done;
	client_t	*cl;
	char		text[1024];

	if (Cmd_Argc() != 2 && Cmd_Argc() != 3) {
		Con_Printf ("usage: cuff <name/userid/ALL> [minutes]\n"
		            "       (default = 0.5, 0 = cancel cuff).\n");
		return;
	}
	all = done = false;
	if (!strcmp(Cmd_Argv(1),"ALL"))
		all = true;
	else {
		if (KK_Match_Str(Cmd_Argv(1), &uid)) {	// name matched
			if (!uid) return;		// too many matches
		} else {
			uid = atoi(Cmd_Argv(1));	// assume userid
		}
	}
	if (Cmd_Argc() == 3) {
		mins = atof(Cmd_Argv(2));
		if (mins < 0.0 || mins > MAXPENALTY) mins = MAXPENALTY;
	}
	for (i = 0, cl = svs.clients; i < MAX_CLIENTS; i++, cl++) {
		if (!cl->state) continue;
		if (all || (cl->userid == uid)) {
			cl->cuff_time = realtime + mins*60.0;
			done = true;
			if (mins) {
				sprintf(text,
				"You are cuffed for %.1f minutes\n\n"
				"reconnecting won't help...\n", mins);
				ClientReliableWrite_Begin(cl,svc_centerprint,
					2+strlen(text));
				ClientReliableWrite_String (cl, text);
			}
			if (!all) break;
		}
	}
	if (done) {
		if (mins) 
			SV_BroadcastPrintf (PRINT_HIGH, "%s cuffed for %.1f minutes.\n", all? "All Users" : cl->name, mins);
		else
			SV_BroadcastPrintf (PRINT_HIGH, "%s un-cuffed.\n", all? "All Users" : cl->name);
	} else 
		Con_Printf (all? "No users\n" : "Couldn't find user %s\n", Cmd_Argv(1));
}

/*
==================
SV_Mute_f

Mute a user for x minutes
==================
*/

void SV_Mute_f (void)
{
	int		i, uid;
	double		mins = 0.5;
	qboolean	all, done;
	client_t	*cl;
	char		text[1024];

	if (Cmd_Argc() != 2 && Cmd_Argc() != 3) {
		Con_Printf ("usage: mute <name/userid/ALL> [minutes]\n"
		            "       (default = 0.5, 0 = cancel mute).\n");
		return;
	}
	all = done = false;
	if (!strcmp(Cmd_Argv(1),"ALL"))
		all = true;
	else {
		if (KK_Match_Str(Cmd_Argv(1), &uid)) {	// name matched
			if (!uid) return;		// too many matches
		} else {
			uid = atoi(Cmd_Argv(1));	// assume userid
		}
	}
	if (Cmd_Argc() == 3) {
		mins = atof(Cmd_Argv(2));
		if (mins < 0.0 || mins > MAXPENALTY) mins = MAXPENALTY;
	}
	for (i = 0, cl = svs.clients; i < MAX_CLIENTS; i++, cl++) {
		if (!cl->state) continue;
		if (all || (cl->userid == uid)) {
			cl->lockedtill = realtime + mins*60.0;
			done = true;
			if (mins) {
				sprintf(text,
				"You are muted for %.1f minutes\n\n"
				"reconnecting won't help...\n", mins);
				ClientReliableWrite_Begin(cl,svc_centerprint,
					2+strlen(text));
				ClientReliableWrite_String (cl, text);
			}
			if (!all) break;
		}
	}
	if (done) {
		if (mins) 
			SV_BroadcastPrintf (PRINT_HIGH, "%s muted for %.1f minutes.\n", all? "All Users" : cl->name, mins);
		else
			SV_BroadcastPrintf (PRINT_HIGH, "%s allowed to speak.\n", all? "All Users" : cl->name);
	} else 
		Con_Printf (all? "No users\n" : "Couldn't find user %s\n", Cmd_Argv(1));
}

/*
==================
SV_Tell

say text to a single user with given prefix
==================
*/
void SV_Tell (char *prefix)
{
	int		i, uid;
	client_t	*cl;
	char		*p, text[512];

	if (Cmd_Argc() < 3) {
		Con_Printf ("usage: tell <name/userid> <text...>\n");
		return;
	}
	if (KK_Match_Str(Cmd_Argv(1), &uid)) {	// name matched
		if (!uid) return;		// too many matches
	} else {
		uid = atoi(Cmd_Argv(1));	// assume userid
	}

	p = Cmd_Args2();
	if (*p == '"') {
		p++;
		p[Q_strlen(p)-1] = 0;
	}
	// construct  "[PRIVATE] Consoleç "  for their console
	sprintf(text, "[–“…÷¡‘≈] %sç ", prefix); // bold header
	i = strlen(text);
	strncat(text, p, sizeof(text)-1-i);
	text[sizeof(text)-1] = 0;
	for (; text[i];) text[i++] |= 0x80;	// non-bold text

	for (i = 0, cl = svs.clients; i < MAX_CLIENTS; i++, cl++) {
	    if (!cl->state) continue;
	    if (cl->userid == uid) {
		SV_ClientPrintf(cl, PRINT_CHAT, "\n"); // bell
		SV_ClientPrintf(cl, PRINT_HIGH, "%s\n", text);
		SV_ClientPrintf(cl, PRINT_CHAT, "\n"); // bell
		return;
	    }
	}
	Con_Printf ("Couldn't find user %s\n", Cmd_Argv(1));
}
/*
==================
SV_Ban_f

Ban a users IP and kick, via their name or UID 
==================
*/
void SV_Ban_f (void)
{
	int		i, uid;
	double		mins = 30.0;
	client_t	*cl;

	if (Cmd_Argc() != 2 && Cmd_Argc() != 3) {
                Con_Printf ("usage: ban <name/userid> [minutes]\n" 
		            "       (default = 30, 0 = permanent).\n");
		return;
	}
	if (KK_Match_Str(Cmd_Argv(1), &uid)) {	// name matched
		if (!uid) return;		// too many matches
	} else {
		uid = atoi(Cmd_Argv(1));	// assume userid
	}
	if (Cmd_Argc() == 3) {
		mins = atof(Cmd_Argv(2));
		if (mins<0.0 || mins>1000000.0) mins = 0.0;     // bout 2 yrs
	}
	for (i = 0, cl = svs.clients; i < MAX_CLIENTS; i++, cl++) {
		if (!cl->state) continue;
		if (cl->userid == uid) {
			SV_BroadcastPrintf (PRINT_HIGH, "Admin Banned user %s %s\n", cl->name, mins? va("for %.1f minutes",mins) : "permanently");
			SV_DropClient (cl); 
			Cmd_ExecuteString(va("addip %s %f",NET_BaseAdrToString(cl->netchan.remote_address),mins));
			return;
		}
	}
	Con_Printf ("Couldn't find user %s\n", Cmd_Argv(1));
}
/*
================
SV_Status_f
================
*/
void SV_Status_f (void)
{
	int			i, j, l;
	client_t	*cl;
	float		cpu, avg, pak;
	char		*s;


	cpu = (svs.stats.latched_active+svs.stats.latched_idle);
	if (cpu)
		cpu = 100*svs.stats.latched_active/cpu;
	avg = 1000*svs.stats.latched_active / STATFRAMES;
	pak = (float)svs.stats.latched_packets/ STATFRAMES;

	Con_Printf ("net address      : %s\n",NET_AdrToString (net_local_adr));
	Con_Printf ("cpu utilization  : %3i%%\n",(int)cpu);
	Con_Printf ("avg response time: %i ms\n",(int)avg);
	Con_Printf ("packets/frame    : %5.2f (%d)\n", pak, num_prstr);

	//SV_PrecacheUsage_f();
	//SV_EntUsage_f();
	
// min fps lat drp
	if (sv_redirected != RD_NONE) {
		// most remote clients are 40 columns
		//           0123456789012345678901234567890123456789
		Con_Printf ("name               userid frags\n");
        Con_Printf ("  address          rate ping drop\n");
		Con_Printf ("  ---------------- ---- ---- -----\n");
		for (i=0,cl=svs.clients ; i<MAX_CLIENTS ; i++,cl++)
		{
			if (!cl->state)
				continue;

			Con_Printf ("%-16.16s  ", cl->name);

			Con_Printf ("%6i %5i", cl->userid, (int)cl->edict->v.frags);
			if (cl->spectator)
				Con_Printf(" (s)\n");
			else			
				Con_Printf("\n");

			s = NET_BaseAdrToString ( cl->netchan.remote_address);
			Con_Printf ("  %-16.16s", s);
			if (cl->state == cs_connected)
			{
				Con_Printf ("CONNECTING\n");
				continue;
			}
			if (cl->state == cs_zombie)
			{
				Con_Printf ("ZOMBIE\n");
				continue;
			}
			Con_Printf ("%4i %4i %5.2f\n"
				, (int)(1000*cl->netchan.frame_rate)
				, (int)SV_CalcPing (cl)
				, 100.0*cl->netchan.drop_count / cl->netchan.incoming_sequence);
		}
	} else {
		Con_Printf ("frags userid address         name            rate ping drop  qport\n");
		Con_Printf ("----- ------ --------------- --------------- ---- ---- ----- -----\n");
		for (i=0,cl=svs.clients ; i<MAX_CLIENTS ; i++,cl++)
		{
			if (!cl->state)
				continue;
			Con_Printf ("%5i %6i ", (int)cl->edict->v.frags,  cl->userid);
			s = NET_BaseAdrToString ( cl->netchan.remote_address);
			Con_Printf ("%s", s);
			l = 16 - strlen(s);
			for (j=0 ; j<l ; j++)
				Con_Printf (" ");
			
			//Con_Printf ("%s%s", KK_Team_Color(cl), cl->name);
			SetConsoleToUserColor(cl); // OfN
			Con_Printf("%s",cl->name); // OfN
			Sys_EndColor();

			l = 16 - strlen(cl->name);
			for (j=0 ; j<l ; j++)
				Con_Printf (" ");
			if (cl->state == cs_connected)
			{
				Con_Printf ("CONNECTING\n");
				continue;
			}
			if (cl->state == cs_zombie)
			{
				Con_Printf ("ZOMBIE\n");
				continue;
			}
			Con_Printf ("%4i %4i %3.1f %4i"
				, (int)(1000*cl->netchan.frame_rate)
				, (int)SV_CalcPing (cl)
				, 100.0*cl->netchan.drop_count / cl->netchan.incoming_sequence
				, cl->netchan.qport);
			if (cl->spectator)
				Con_Printf(" (s)\n");
			else			
				Con_Printf("\n");

				
		}
	}
	Con_Printf ("\n");
}

/*
==================
SV_ConSay

broadcast a 'say' as:
"prefix"> ...........

"Info" gets no beep (used for regularly spammed info, beep annoys players :)
==================
*/
void SV_ConSay (char *prefix)
{
	client_t *client;
	int		j;
	char	*p;
	char	text[512];

	if (Cmd_Argc() < 2)
		return;

	p = Cmd_Args();
	if (*p == '"') {
		p++;
		p[Q_strlen(p)-1] = 0;
	}
	strcpy(text, prefix);			// bold header
	strcat(text, "ç ");			// and arrow
	j = strlen(text);
	strncat(text, p, sizeof(text)-1-j);
	text[sizeof(text)-1] = 0;
	for (; text[j];) text[j++] |= 0x80;	// non-bold text

	for (j = 0, client = svs.clients; j < MAX_CLIENTS; j++, client++) {
		if (!client->state) continue;
		SV_ClientPrintf(client, PRINT_HIGH, "%s\n", text);
		if (*prefix != 'I')	// beep, except for Info says
			SV_ClientPrintf(client, PRINT_CHAT, "");
	}

	Sys_BeginColor();
	Sys_ConsoleColor(COLOR_FORE_CONSAY,COLOR_BACK_CONSAY);
	Sys_Printf("%s\n",text);
	Sys_EndColor();
}

/*
==================
SV_Tell_f

message to single user with different prefixes
==================
*/
void SV_Tell_f(void)
{
	if (rcon_from_user)
		SV_Tell("Admin");
	else
		SV_Tell("Console");
}
/*
==================
SV_ConSay_Console_f, SV_ConSay_Info_f

'say's to console with different prefixes
==================
*/
void SV_ConSay_Console_f(void)
{
	if (rcon_from_user)
		SV_ConSay("Admin");
	else
		SV_ConSay("Console");
}
void SV_ConSay_Info_f(void)
{
	SV_ConSay("Info");
}

/*
==================
SV_Heartbeat_f
==================
*/
void SV_Heartbeat_f (void)
{
	svs.last_heartbeat = -9999;
}

void SV_SendServerInfoChange(char *key, char *value)
{
	if (!sv.state)
		return;

	MSG_WriteByte (&sv.reliable_datagram, svc_serverinfo);
	MSG_WriteString (&sv.reliable_datagram, key);
	MSG_WriteString (&sv.reliable_datagram, value);
}

/*
===========
SV_Serverinfo_f

  Examine or change the serverinfo string
===========
*/
char *CopyString(char *s);
void SV_Serverinfo_f (void)
{
	cvar_t	*var;

	if (Cmd_Argc() == 1)
	{
		Con_Printf ("Server info settings (%d/%d bytes used):\n",
				strlen(svs.info),sizeof(svs.info));
		Info_Print (svs.info);
		return;
	}

	if (Cmd_Argc() != 3)
	{
		Con_Printf ("usage: serverinfo [ <key> <value> ]\n");
		return;
	}

	if (Cmd_Argv(1)[0] == '*')
	{
		Con_Printf ("Star variables cannot be changed.\n");
		return;
	}
	Info_SetValueForKey (svs.info, Cmd_Argv(1), Cmd_Argv(2), MAX_SERVERINFO_STRING);

	// if this is a cvar, change it too	
	var = Cvar_FindVar (Cmd_Argv(1));
	if (var)
	{
		Z_Free (var->string);	// free the old value string	
		var->string = CopyString (Cmd_Argv(2));
		var->value = Q_atof (var->string);
	}

	SV_SendServerInfoChange(Cmd_Argv(1), Cmd_Argv(2));
}


/*
===========
SV_Serverinfo_f

  Examine or change the serverinfo string
===========
*/
char *CopyString(char *s);
void SV_Localinfo_f (void)
{
	if (Cmd_Argc() == 1)
	{
		Con_Printf ("Local info settings:\n");
		Info_Print (localinfo);
		return;
	}

	if (Cmd_Argc() > 3)
	{
		Con_Printf ("usage: localinfo [ <key> [ <value> ] ]\n");
		return;
	}

	if (Cmd_Argc() == 2)
	{
		char *v = Info_ValueForKey(localinfo, Cmd_Argv(1));
		Con_Printf ("Localinfo setting for '%s':\n%-20s%s\n",
			Cmd_Argv(1),Cmd_Argv(1),*v? v : "not in localinfo");
		return;
	}

	if (Cmd_Argv(1)[0] == '*')
	{
		Con_Printf ("Star variables cannot be changed.\n");
		return;
	}
	Info_SetValueForKey (localinfo, Cmd_Argv(1), Cmd_Argv(2), MAX_LOCALINFO_STRING);
}


/*
===========
SV_User_f

Examine a users info strings
===========
*/
void SV_User_f (void)
{
	if (Cmd_Argc() != 2)
	{
		Con_Printf ("Usage: info <userid>\n");
		return;
	}

	if (!SV_SetPlayer ())
		return;

	Info_Print (host_client->userinfo);
}

/*
================
SV_Gamedir

Sets the fake *gamedir to a different directory.
================
*/
void SV_Gamedir (void)
{
	char			*dir;

	if (Cmd_Argc() == 1)
	{
		Con_Printf ("Current *gamedir: %s\n", Info_ValueForKey (svs.info, "*gamedir"));
		return;
	}

	if (Cmd_Argc() != 2)
	{
		Con_Printf ("Usage: sv_gamedir <newgamedir>\n");
		return;
	}

	dir = Cmd_Argv(1);

	if (strstr(dir, "..") || strstr(dir, "/")
		|| strstr(dir, "\\") || strstr(dir, ":") )
	{
		Con_Printf ("*Gamedir should be a single filename, not a path\n");
		return;
	}

	Info_SetValueForStarKey (svs.info, "*gamedir", dir, MAX_SERVERINFO_STRING);
}

/*
================
SV_Floodport_f

Sets the gamedir and path to a different directory.
================
*/

void SV_Floodprot_f (void)
{
	int arg1, arg2, arg3;
	
	if (Cmd_Argc() == 1)
	{
		if (fp_messages) {
			Con_Printf ("Current floodprot settings: \nAfter %d msgs per %d seconds, silence for %d seconds\n", 
				fp_messages, fp_persecond, fp_secondsdead);
			return;
		} else
			Con_Printf ("No floodprots enabled.\n");
	}

	if (Cmd_Argc() != 4)
	{
		Con_Printf ("Usage: floodprot <# of messages> <per # of seconds> <seconds to silence>\n");
		Con_Printf ("Use floodprotmsg to set a custom message to say to the flooder.\n");
		return;
	}

	arg1 = atoi(Cmd_Argv(1));
	arg2 = atoi(Cmd_Argv(2));
	arg3 = atoi(Cmd_Argv(3));

	if (arg1<=0 || arg2 <= 0 || arg3<=0) {
		Con_Printf ("All values must be positive numbers\n");
		return;
	}
	
	if (arg1 > 10) {
		Con_Printf ("Can only track up to 10 messages.\n");
		return;
	}

	fp_messages	= arg1;
	fp_persecond = arg2;
	fp_secondsdead = arg3;
}

void SV_Floodprotmsg_f (void)
{
	if (Cmd_Argc() == 1) {
		Con_Printf("Current msg: %s\n", fp_msg);
		return;
	} else if (Cmd_Argc() != 2) {
		Con_Printf("Usage: floodprotmsg \"<message>\"\n");
		return;
	}
	sprintf(fp_msg, "%s", Cmd_Argv(1));
}
  
/*
================
SV_Gamedir_f

Sets the gamedir and path to a different directory.
================
*/
char	gamedirfile[MAX_OSPATH];
void SV_Gamedir_f (void)
{
	char			*dir;

	if (Cmd_Argc() == 1)
	{
		Con_Printf ("Current gamedir: %s\n", com_gamedir);
		return;
	}

	if (Cmd_Argc() != 2)
	{
		Con_Printf ("Usage: gamedir <newdir>\n");
		return;
	}

	dir = Cmd_Argv(1);

	if (strstr(dir, "..") || strstr(dir, "/")
		|| strstr(dir, "\\") || strstr(dir, ":") )
	{
		Con_Printf ("Gamedir should be a single filename, not a path\n");
		return;
	}

	COM_Gamedir (dir);
	Info_SetValueForStarKey (svs.info, "*gamedir", dir, MAX_SERVERINFO_STRING);
}

/*
================
SV_Snap
================
*/
void SV_Snap (int uid)
{
	client_t *cl;
	char		pcxname[80]; 
	char		checkname[MAX_OSPATH];
	int			i;

	for (i = 0, cl = svs.clients; i < MAX_CLIENTS; i++, cl++)
	{
		if (!cl->state)
			continue;
		if (cl->userid == uid)
			break;
	}
	if (i >= MAX_CLIENTS) {
		Con_Printf ("userid not found\n");
		return;
	}

	sprintf(pcxname, "%d-00.pcx", uid);

	sprintf(checkname, "%s/snap", gamedirfile);
	Sys_mkdir(gamedirfile);
	Sys_mkdir(checkname);
		
	for (i=0 ; i<=99 ; i++) 
	{ 
		pcxname[strlen(pcxname) - 6] = i/10 + '0'; 
		pcxname[strlen(pcxname) - 5] = i%10 + '0'; 
		sprintf (checkname, "%s/snap/%s", gamedirfile, pcxname);
		if (Sys_FileTime(checkname) == -1)
			break;	// file doesn't exist
	} 
	if (i==100) 
	{
		Con_Printf ("Snap: Couldn't create a file, clean some out.\n"); 
		return;
	}
	strcpy(cl->uploadfn, checkname);

	memcpy(&cl->snap_from, &net_from, sizeof(net_from));
	if (sv_redirected != RD_NONE)
		cl->remote_snap = true;
	else
		cl->remote_snap = false;

	ClientReliableWrite_Begin (cl, svc_stufftext, 24);
	ClientReliableWrite_String (cl, "cmd snap");
	Con_Printf ("Requesting snap from user %d...\n", uid);
}

/*
================
SV_Snap_f
================
*/
void SV_Snap_f (void)
{
	int			uid;

	if (Cmd_Argc() != 2)
	{
		Con_Printf ("Usage:  snap <userid>\n");
		return;
	}

	uid = atoi(Cmd_Argv(1));

	SV_Snap(uid);
}

/*
================
SV_Snap
================
*/
void SV_SnapAll_f (void)
{
	client_t *cl;
	int			i;

	for (i = 0, cl = svs.clients; i < MAX_CLIENTS; i++, cl++)
	{
		if (cl->state < cs_connected || cl->spectator)
			continue;
		SV_Snap(cl->userid);
	}
}

//#include "kk.1"
/*
==================
SV_InitOperatorCommands
==================
*/
void SV_InitOperatorCommands (void)
{
//#include "kk.2"
	if (COM_CheckParm ("-cheats"))
	{
		sv_allow_cheats = true;
		Info_SetValueForStarKey (svs.info, "*cheats", "ON", MAX_SERVERINFO_STRING);
	}

	Cmd_AddCommand ("logfile", SV_Logfile_f);
	Cmd_AddCommand ("fraglogfile", SV_Fraglogfile_f);

	Cmd_AddCommand ("snap", SV_Snap_f);
	Cmd_AddCommand ("snapall", SV_SnapAll_f);
	Cmd_AddCommand ("kick", SV_Kick_f);
	Cmd_AddCommand ("status", SV_Status_f);

	Cmd_AddCommand ("map", SV_Map_f);
	Cmd_AddCommand ("setmaster", SV_SetMaster_f);

	Cmd_AddCommand ("heartbeat", SV_Heartbeat_f);
	Cmd_AddCommand ("quit", SV_Quit_f);
	Cmd_AddCommand ("god", SV_God_f);
	Cmd_AddCommand ("give", SV_Give_f);
	Cmd_AddCommand ("noclip", SV_Noclip_f);
	Cmd_AddCommand ("serverinfo", SV_Serverinfo_f);
	Cmd_AddCommand ("localinfo", SV_Localinfo_f);
	Cmd_AddCommand ("user", SV_User_f);
	Cmd_AddCommand ("gamedir", SV_Gamedir_f);
	Cmd_AddCommand ("sv_gamedir", SV_Gamedir);
	Cmd_AddCommand ("floodprot", SV_Floodprot_f);
	Cmd_AddCommand ("floodprotmsg", SV_Floodprotmsg_f);
	Cmd_AddCommand ("say", SV_ConSay_Console_f); // kk hacks follow
	Cmd_AddCommand ("sayinfo", SV_ConSay_Info_f);
	Cmd_AddCommand ("cuff", SV_Cuff_f);
	Cmd_AddCommand ("mute", SV_Mute_f);
	Cmd_AddCommand ("tell", SV_Tell_f);
	Cmd_AddCommand ("ban", SV_Ban_f);

	// OfN
	Cmd_AddCommand("pinmsg",SV_Pinmsg_f);
	Cmd_AddCommand("restart",SV_Restart_f);
	Cmd_AddCommand("delkey",SV_DelKey_f);
	Cmd_AddCommand("version",SV_Version_f);
	Cmd_AddCommand("ents",SV_EntUsage_f);
	Cmd_AddCommand("precaches",SV_PrecacheUsage_f);

	Cmd_AddCommand("help",SV_Help_f);
	Cmd_AddCommand("cvars",SV_DisplayCvars_f);
	Cmd_AddCommand("commands",SV_DisplayCommands_f);	

	cl_warncmd.value = 1;
}
