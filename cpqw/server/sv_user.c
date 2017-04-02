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
// sv_user.c -- server code for moving users

#include "qwsvdef.h"

edict_t	*sv_player;

usercmd_t	cmd;

cvar_t	cl_rollspeed = {"cl_rollspeed", "200"};
cvar_t	cl_rollangle = {"cl_rollangle", "2.0"};
cvar_t	sv_spectalk = {"sv_spectalk", "1"};

cvar_t	sv_mapcheck	= {"sv_mapcheck", "1"};

extern	vec3_t	player_mins;

extern int fp_messages, fp_persecond, fp_secondsdead;
extern char fp_msg[];
extern cvar_t pausable;

/*
============================================================

USER STRINGCMD EXECUTION

host_client and sv_player will be valid.
============================================================
*/

void KK_stuffcmd (client_t *cl, char *str)
{
	ClientReliableWrite_Begin (cl, svc_stufftext, 2+strlen(str));
	ClientReliableWrite_String (cl, str);
}
char *KK_infokey (char *key)
{
	char *value;

	if ((value = Info_ValueForKey(svs.info, key)) == NULL || !*value)
		value = Info_ValueForKey(localinfo, key);
	return value;
}

ddef_t *ED_FindGlobal (char *name);

float KK_Global_Float (char *str)
{
	ddef_t	*def = ED_FindGlobal (str);
	eval_t	*val;

	if ( def )  {
		//Sys_Printf ("ofs=%04X\n",(unsigned int)def->ofs);
		val = (eval_t *)&pr_globals[def->ofs];
		return val->_float;
	}
	return -1.0;
}

int KK_Team_No (client_t *cl)
{
	eval_t		*val;
	int		team;

	if (cl->state != cs_spawned) return 0;
	if (!team_no_offset || cl->spectator) return 0;

	val = (eval_t *)((char *)&cl->edict->v + team_no_offset);
	team = (int)val->_float;
	if ( team < 1 || team > 4 ) return 0;
	return team;
}

int KK_Pick_Team (void)	// return recommended team for *TF mods, or 0
{
	client_t        *cl;
	char		t[32], fts[32];
	int		teams	= (int) KK_Global_Float("number_of_teams"),
			i,j,rec,score[5],players[5],lowteams[5],tot,low,numlow;

	if ( teams < 2 || teams > 4 ) return 0; // not TF
	if (!team_no_offset) return 0;		// no "team_no" field

	strncpy(t, KK_infokey("t"), sizeof(t)-1);	// t or fts must be on
	if ( !t[0] ) strncpy(t, KK_infokey("teamfrags"), sizeof(t)-1);
	strncpy(fts, KK_infokey("fts"), sizeof(fts)-1);
	if ( !fts[0] ) strncpy(fts, KK_infokey("fullteamscore"), sizeof(fts)-1);
	if ( stricmp(t,"on") && stricmp(fts,"on") ) return 0;

	for (i=1; i <= teams; i++) { 
		players[i] = 0;
		score[i] = (int) KK_Global_Float(va("team%dscore",i));
	}
	for (i=tot=0, cl = svs.clients; i < MAX_CLIENTS; i++, cl++) {
		j = KK_Team_No(cl);
		if (!j) continue;
		++players[j];
		++tot;
	}
	Sys_Printf ("t=%d pt=%d ", teams, tot);
	for (i=1; i <= teams; i++) Sys_Printf ("p%d=%d ",i,players[i]);
	for (i=1; i <= teams; i++) Sys_Printf ("s%d=%d ",i,score[i]);

// This define is used to decide team for new player. Following code picks:
//   - the team with least players
//   - if more than one choice, then team with least score
//   - if still more than one choice, then random selection

#define TEAM_STRENGTH(x)	(( players[x] * 100000 ) + score[x]) 

	for (i=2, low=TEAM_STRENGTH(1); i <= teams; i++) { // find lowest
		j = TEAM_STRENGTH(i);
		if ( j < low ) low = j;
	}
	Sys_Printf ("lowt= ");
	for (i=1, numlow=0; i <= teams; i++ )	// find all teams with lowest
		if ( low == TEAM_STRENGTH(i)) {
			lowteams[numlow++] = i;
			Sys_Printf ("%d ", i);
		}
	rec = numlow? lowteams[rand() % numlow] : 0;
	Sys_Printf (" pick=%d\n", rec);
	return rec;
}

// Returns true if teammates in some mods (eg Custom)
// mask of team1's friends must have its team2 bit set
qboolean KK_Teammates (client_t *player1, client_t *player2)
{
	int	team1 = KK_Team_No(player1),
		team2 = KK_Team_No(player2), mask;

	if ( !team1 || !team2 )
		return false;
	if ( team1 == team2 )
		return true;
	if ( (int) KK_Global_Float("number_of_teams") < 3 )
		return false;
	mask = (int) KK_Global_Float(va("friends%i_mask",team1));
	if ( mask <= 0 )
		return false;
	if ( mask & (1<<(team2-1)) )
		return true;
	return false;
}

/*
================
SV_New_f

Sends the first message from the server to a connected client.
This will be sent on the initial connection and upon each server load.
================
*/
void SV_New_f (void)
{
	char		*gamedir;
	int			playernum;

	if (host_client->state == cs_spawned)
		return;

	host_client->state = cs_connected;
	host_client->connection_started = realtime;

	// send the info about the new client to all connected clients
//	SV_FullClientUpdate (host_client, &sv.reliable_datagram);
//	host_client->sendinfo = true;

	gamedir = Info_ValueForKey (svs.info, "*gamedir");
	if (!gamedir[0])
		gamedir = "qw";

//NOTE:  This doesn't go through ClientReliableWrite since it's before the user
//spawns.  These functions are written to not overflow
	if (host_client->num_backbuf) {
		Con_Printf("WARNING %s: [SV_New] Back buffered (%d0, clearing", host_client->name, host_client->netchan.message.cursize); 
		host_client->num_backbuf = 0;
		SZ_Clear(&host_client->netchan.message);
	}

	// send the serverdata
	MSG_WriteByte (&host_client->netchan.message, svc_serverdata);
	MSG_WriteLong (&host_client->netchan.message, PROTOCOL_VERSION);
	MSG_WriteLong (&host_client->netchan.message, svs.spawncount);
	MSG_WriteString (&host_client->netchan.message, gamedir);

	playernum = NUM_FOR_EDICT(host_client->edict)-1;
	if (host_client->spectator)
		playernum |= 128;
	MSG_WriteByte (&host_client->netchan.message, playernum);

	// send full levelname
	MSG_WriteString (&host_client->netchan.message, PR_GetString(sv.edicts->v.message));

	// send the movevars
	MSG_WriteFloat(&host_client->netchan.message, movevars.gravity);
	MSG_WriteFloat(&host_client->netchan.message, movevars.stopspeed);
	MSG_WriteFloat(&host_client->netchan.message, movevars.maxspeed);
	MSG_WriteFloat(&host_client->netchan.message, movevars.spectatormaxspeed);
	MSG_WriteFloat(&host_client->netchan.message, movevars.accelerate);
	MSG_WriteFloat(&host_client->netchan.message, movevars.airaccelerate);
	MSG_WriteFloat(&host_client->netchan.message, movevars.wateraccelerate);
	MSG_WriteFloat(&host_client->netchan.message, movevars.friction);
	MSG_WriteFloat(&host_client->netchan.message, movevars.waterfriction);
	MSG_WriteFloat(&host_client->netchan.message, movevars.entgravity);

	// send music
	MSG_WriteByte (&host_client->netchan.message, svc_cdtrack);
	MSG_WriteByte (&host_client->netchan.message, sv.edicts->v.sounds);

	// send server info string
	MSG_WriteByte (&host_client->netchan.message, svc_stufftext);
	MSG_WriteString (&host_client->netchan.message, va("fullserverinfo \"%s\"\n", svs.info) );
}

/*
==================
SV_Soundlist_f
==================
*/
void SV_Soundlist_f (void)
{
	char		**s;
	int			n;

	if (host_client->state != cs_connected)
	{
		Con_Printf ("soundlist not valid -- allready spawned\n");
		return;
	}

	// handle the case of a level changing while a client was connecting
	if ( atoi(Cmd_Argv(1)) != svs.spawncount )
	{
		Con_Printf ("SV_Soundlist_f from different level\n");
		SV_New_f ();
		return;
	}

	n = atoi(Cmd_Argv(2));
	
//NOTE:  This doesn't go through ClientReliableWrite since it's before the user
//spawns.  These functions are written to not overflow
	if (host_client->num_backbuf) {
		Con_Printf("WARNING %s: [SV_Soundlist] Back buffered (%d0, clearing", host_client->name, host_client->netchan.message.cursize); 
		host_client->num_backbuf = 0;
		SZ_Clear(&host_client->netchan.message);
	}

	MSG_WriteByte (&host_client->netchan.message, svc_soundlist);
	MSG_WriteByte (&host_client->netchan.message, n);
	for (s = sv.sound_precache+1 + n ; 
		*s && host_client->netchan.message.cursize < (MAX_MSGLEN/2); 
		s++, n++)
		MSG_WriteString (&host_client->netchan.message, *s);

	MSG_WriteByte (&host_client->netchan.message, 0);

	// next msg
	if (*s)
		MSG_WriteByte (&host_client->netchan.message, n);
	else
		MSG_WriteByte (&host_client->netchan.message, 0);
}

/*
==================
SV_Modellist_f
==================
*/
void SV_Modellist_f (void)
{
	char		**s;
	int			n;

	if (host_client->state != cs_connected)
	{
		Con_Printf ("modellist not valid -- allready spawned\n");
		return;
	}
	
	// handle the case of a level changing while a client was connecting
	if ( atoi(Cmd_Argv(1)) != svs.spawncount )
	{
		Con_Printf ("SV_Modellist_f from different level\n");
		SV_New_f ();
		return;
	}

	n = atoi(Cmd_Argv(2));

//NOTE:  This doesn't go through ClientReliableWrite since it's before the user
//spawns.  These functions are written to not overflow
	if (host_client->num_backbuf) {
		Con_Printf("WARNING %s: [SV_Modellist] Back buffered (%d0, clearing", host_client->name, host_client->netchan.message.cursize); 
		host_client->num_backbuf = 0;
		SZ_Clear(&host_client->netchan.message);
	}

	MSG_WriteByte (&host_client->netchan.message, svc_modellist);
	MSG_WriteByte (&host_client->netchan.message, n);
	for (s = sv.model_precache+1+n ; 
		*s && host_client->netchan.message.cursize < (MAX_MSGLEN/2); 
		s++, n++)
		MSG_WriteString (&host_client->netchan.message, *s);
	MSG_WriteByte (&host_client->netchan.message, 0);

	// next msg
	if (*s)
		MSG_WriteByte (&host_client->netchan.message, n);
	else
		MSG_WriteByte (&host_client->netchan.message, 0);
}

/*
==================
SV_PreSpawn_f
==================
*/
void SV_PreSpawn_f (void)
{
	unsigned	buf;
	unsigned	check;

	if (host_client->state != cs_connected)
	{
		Con_Printf ("prespawn not valid -- allready spawned\n");
		return;
	}
	
	// handle the case of a level changing while a client was connecting
	if ( atoi(Cmd_Argv(1)) != svs.spawncount )
	{
		Con_Printf ("SV_PreSpawn_f from different level\n");
		SV_New_f ();
		return;
	}
	
	buf = atoi(Cmd_Argv(2));
	if (buf >= sv.num_signon_buffers)
		buf = 0;

	if (!buf) {
		// should be three numbers following containing checksums
		check = atoi(Cmd_Argv(3));

//		Con_DPrintf("Client check = %d\n", check);

		if (sv_mapcheck.value && check != sv.worldmodel->checksum &&
			check != sv.worldmodel->checksum2) {
			SV_ClientPrintf (host_client, PRINT_HIGH, 
				"Map model file does not match (%s), %i != %i/%i.\n"
				"You may need a new version of the map, or the proper install files.\n",
				sv.modelname, check, sv.worldmodel->checksum, sv.worldmodel->checksum2);
			SV_DropClient (host_client); 
			return;
		}
		host_client->checksum = check;
	}

//NOTE:  This doesn't go through ClientReliableWrite since it's before the user
//spawns.  These functions are written to not overflow
	if (host_client->num_backbuf) {
		Con_Printf("WARNING %s: [SV_PreSpawn] Back buffered (%d0, clearing", host_client->name, host_client->netchan.message.cursize); 
		host_client->num_backbuf = 0;
		SZ_Clear(&host_client->netchan.message);
	}

	SZ_Write (&host_client->netchan.message, 
		sv.signon_buffers[buf],
		sv.signon_buffer_size[buf]);

	buf++;
	if (buf == sv.num_signon_buffers)
	{	// all done prespawning
		MSG_WriteByte (&host_client->netchan.message, svc_stufftext);
		MSG_WriteString (&host_client->netchan.message, va("cmd spawn %i 0\n",svs.spawncount) );
	}
	else
	{	// need to prespawn more
		MSG_WriteByte (&host_client->netchan.message, svc_stufftext);
		MSG_WriteString (&host_client->netchan.message, 
			va("cmd prespawn %i %i\n", svs.spawncount, buf) );
	}
}

void SV_FullClientUpdateToClient (client_t *client, client_t *cl);

/*
==================
SV_Spawn_f
==================
*/
void SV_Spawn_f (void)
{
	int		i;
	client_t	*client;
	edict_t	*ent;
	eval_t *val;
	int n;

	if (host_client->state != cs_connected)
	{
		Con_Printf ("Spawn not valid -- allready spawned\n");
		return;
	}

// handle the case of a level changing while a client was connecting
	if ( atoi(Cmd_Argv(1)) != svs.spawncount )
	{
		Con_Printf ("SV_Spawn_f from different level\n");
		SV_New_f ();
		return;
	}

	n = atoi(Cmd_Argv(2));

	// make sure n is valid
	if ( n < 0 || n > MAX_CLIENTS )
	{
		Con_Printf ("SV_Spawn_f invalid client start\n");
		SV_New_f ();
		return;
	}


	
// send all current names, colors, and frag counts
	// FIXME: is this a good thing?
	SZ_Clear (&host_client->netchan.message);

// send current status of all other players

	// normally this could overflow, but no need to check due to backbuf
	for (i=n, client = svs.clients + n ; i<MAX_CLIENTS ; i++, client++)
		SV_FullClientUpdateToClient (client, host_client);
	
// send all current light styles
	for (i=0 ; i<MAX_LIGHTSTYLES ; i++)
	{
		ClientReliableWrite_Begin (host_client, svc_lightstyle, 
			3 + (sv.lightstyles[i] ? strlen(sv.lightstyles[i]) : 1));
		ClientReliableWrite_Byte (host_client, (char)i);
		ClientReliableWrite_String (host_client, sv.lightstyles[i]);
	}

	// set up the edict
	ent = host_client->edict;

	memset (&ent->v, 0, progs->entityfields * 4);
	ent->v.colormap = NUM_FOR_EDICT(ent);
	ent->v.team = 0;	// FIXME
	ent->v.netname = PR_SetString(host_client->name);

	host_client->entgravity = 1.0;
	val = GetEdictFieldValue(ent, "gravity");
	if (val)
		val->_float = 1.0;
	host_client->maxspeed = sv_maxspeed.value;
	val = GetEdictFieldValue(ent, "maxspeed");
	if (val)
		val->_float = sv_maxspeed.value;

//
// force stats to be updated
//
	memset (host_client->stats, 0, sizeof(host_client->stats));

	ClientReliableWrite_Begin (host_client, svc_updatestatlong, 6);
	ClientReliableWrite_Byte (host_client, STAT_TOTALSECRETS);
	ClientReliableWrite_Long (host_client, pr_global_struct->total_secrets);

	ClientReliableWrite_Begin (host_client, svc_updatestatlong, 6);
	ClientReliableWrite_Byte (host_client, STAT_TOTALMONSTERS);
	ClientReliableWrite_Long (host_client, pr_global_struct->total_monsters);

	ClientReliableWrite_Begin (host_client, svc_updatestatlong, 6);
	ClientReliableWrite_Byte (host_client, STAT_SECRETS);
	ClientReliableWrite_Long (host_client, pr_global_struct->found_secrets);

	ClientReliableWrite_Begin (host_client, svc_updatestatlong, 6);
	ClientReliableWrite_Byte (host_client, STAT_MONSTERS);
	ClientReliableWrite_Long (host_client, pr_global_struct->killed_monsters);

	// get the client to check and download skins
	// when that is completed, a begin command will be issued
	ClientReliableWrite_Begin (host_client, svc_stufftext, 8);
	ClientReliableWrite_String (host_client, "skins\n" );

}

/*
==================
SV_SpawnSpectator
==================
*/
void SV_SpawnSpectator (void)
{
	int		i;
	edict_t	*e;

	VectorCopy (vec3_origin, sv_player->v.origin);
	VectorCopy (vec3_origin, sv_player->v.view_ofs);
	sv_player->v.view_ofs[2] = 22;

	// search for an info_playerstart to spawn the spectator at
	for (i=MAX_CLIENTS-1 ; i<sv.num_edicts ; i++)
	{
		e = EDICT_NUM(i);
		if (!strcmp(PR_GetString(e->v.classname), "info_player_start"))
		{
			VectorCopy (e->v.origin, sv_player->v.origin);
			return;
		}
	}

}

/*
==================
SV_Begin_f
==================
*/
void SV_Begin_f (void)
{
	unsigned pmodel = 0, emodel = 0;
	int		i;

	if (host_client->state == cs_spawned)
		return; // don't begin again

	host_client->state = cs_spawned;
	
	// handle the case of a level changing while a client was connecting
	if ( atoi(Cmd_Argv(1)) != svs.spawncount )
	{
		Con_Printf ("SV_Begin_f from different level\n");
		SV_New_f ();
		return;
	}

	// OfN - Get the client type/version and set them on corresponding c/quakec shared fields.
	SV_RetrieveClientVersion(host_client);
	
	if (host_client->spectator)
	{
		SV_SpawnSpectator ();

		if (SpectatorConnect) {
			// copy spawn parms out of the client_t
			for (i=0 ; i< NUM_SPAWN_PARMS ; i++)
				(&pr_global_struct->parm1)[i] = host_client->spawn_parms[i];
	
			// call the spawn function
			pr_global_struct->time = sv.time;
			pr_global_struct->self = EDICT_TO_PROG(sv_player);
			PR_ExecuteProgram (SpectatorConnect);
		}
	}
	else
	{
		// copy spawn parms out of the client_t
		for (i=0 ; i< NUM_SPAWN_PARMS ; i++)
			(&pr_global_struct->parm1)[i] = host_client->spawn_parms[i];
		
		// call the spawn function
		pr_global_struct->time = sv.time;
		pr_global_struct->self = EDICT_TO_PROG(sv_player);
		PR_ExecuteProgram (pr_global_struct->ClientConnect);

		// actually spawn the player
		pr_global_struct->time = sv.time;
		pr_global_struct->self = EDICT_TO_PROG(sv_player);
		PR_ExecuteProgram (pr_global_struct->PutClientInServer);	
	}

	// clear the net statistics, because connecting gives a bogus picture
	host_client->netchan.frame_latency = 0;
	host_client->netchan.frame_rate = 0;
	host_client->netchan.drop_count = 0;
	host_client->netchan.good_count = 0;

	//check he's not cheating
if (sv_warnmodels.value != 0) // OfN - Disabled by default, its annoying
{
	pmodel = atoi(Info_ValueForKey (host_client->userinfo, "pmodel"));
	emodel = atoi(Info_ValueForKey (host_client->userinfo, "emodel"));

	
	if (pmodel != sv.model_player_checksum ||
		emodel != sv.eyes_player_checksum)
		SV_BroadcastPrintf (PRINT_HIGH, "%s WARNING: non standard player/eyes model detected\n", host_client->name);
}

	// KK autoteam starts
	if (!host_client->spectator) {
	    	//KK_stuffcmd(host_client,"-d\n");
		if ( !stricmp(KK_infokey("fast_autoteam"),"on") ) {
			int rec = KK_Pick_Team(); // (0 if not teamplay TF)
			if ( rec ) {
				SV_ClientPrintf (host_client, PRINT_HIGH, 
				"Fast Autoteam by KK.\n");
				KK_stuffcmd(host_client,va("impulse %d\n",rec));
			}
		}
	}
	// KK autoteam ends
	// if we are paused, tell the client
	if (sv.paused) {
		ClientReliableWrite_Begin (host_client, svc_setpause, 2);
		ClientReliableWrite_Byte (host_client, sv.paused);
		SV_ClientPrintf(host_client, PRINT_HIGH, "Server is paused.\n");
	}

#if 0
//
// send a fixangle over the reliable channel to make sure it gets there
// Never send a roll angle, because savegames can catch the server
// in a state where it is expecting the client to correct the angle
// and it won't happen if the game was just loaded, so you wind up
// with a permanent head tilt
	ent = EDICT_NUM( 1 + (host_client - svs.clients) );
	MSG_WriteByte (&host_client->netchan.message, svc_setangle);
	for (i=0 ; i < 2 ; i++)
		MSG_WriteAngle (&host_client->netchan.message, ent->v.angles[i] );
	MSG_WriteAngle (&host_client->netchan.message, 0 );
#endif
}

//=============================================================================

/*
==================
SV_NextDownload_f
==================
*/
void SV_NextDownload_f (void)
{
	byte	buffer[1024];
	int		r;
	int		percent;
	int		size;

	if (!host_client->download)
		return;

	r = host_client->downloadsize - host_client->downloadcount;
	if (r > 768)
		r = 768;
	r = fread (buffer, 1, r, host_client->download);
	ClientReliableWrite_Begin (host_client, svc_download, 6+r);
	ClientReliableWrite_Short (host_client, r);

	host_client->downloadcount += r;
	size = host_client->downloadsize;
	if (!size)
		size = 1;
	percent = host_client->downloadcount*100/size;
	ClientReliableWrite_Byte (host_client, percent);
	ClientReliableWrite_SZ (host_client, buffer, r);

	if (host_client->downloadcount != host_client->downloadsize)
		return;

	fclose (host_client->download);
	host_client->download = NULL;

}

void OutofBandPrintf(netadr_t where, char *fmt, ...)
{
	va_list		argptr;
	char	send[1024];
	
	send[0] = 0xff;
	send[1] = 0xff;
	send[2] = 0xff;
	send[3] = 0xff;
	send[4] = A2C_PRINT;
	va_start (argptr, fmt);
	vsprintf (send+5, fmt, argptr);
	va_end (argptr);

	NET_SendPacket (strlen(send)+1, send, where);
}

/*
==================
SV_NextUpload
==================
*/
void SV_NextUpload (void)
{
	//byte	buffer[1024];
	//int		r;
	int		percent;
	int		size;
	//client_t *client;

	if (!*host_client->uploadfn) {
		SV_ClientPrintf(host_client, PRINT_HIGH, "Upload denied\n");
		ClientReliableWrite_Begin (host_client, svc_stufftext, 8);
		ClientReliableWrite_String (host_client, "stopul");

		// suck out rest of packet
		size = MSG_ReadShort ();	MSG_ReadByte ();
		msg_readcount += size;
		return;
	}

	size = MSG_ReadShort ();
	percent = MSG_ReadByte ();

	if (!host_client->upload)
	{
		host_client->upload = fopen(host_client->uploadfn, "wb");
		if (!host_client->upload) {
			Sys_Printf("Can't create %s\n", host_client->uploadfn);
			ClientReliableWrite_Begin (host_client, svc_stufftext, 8);
			ClientReliableWrite_String (host_client, "stopul");
			*host_client->uploadfn = 0;
			return;
		}
		Sys_Printf("Receiving %s from %d...\n", host_client->uploadfn, host_client->userid);
		if (host_client->remote_snap)
			OutofBandPrintf(host_client->snap_from, "Server receiving %s from %d...\n", host_client->uploadfn, host_client->userid);
	}

	fwrite (net_message.data + msg_readcount, 1, size, host_client->upload);
	msg_readcount += size;

Con_DPrintf ("UPLOAD: %d received\n", size);

	if (percent != 100) {
		ClientReliableWrite_Begin (host_client, svc_stufftext, 8);
		ClientReliableWrite_String (host_client, "nextul\n");
	} else {
		fclose (host_client->upload);
		host_client->upload = NULL;

		Sys_Printf("%s upload completed.\n", host_client->uploadfn);

		if (host_client->remote_snap) {
			char *p;

			if ((p = strchr(host_client->uploadfn, '/')) != NULL)
				p++;
			else
				p = host_client->uploadfn;
			OutofBandPrintf(host_client->snap_from, "%s upload completed.\nTo download, enter:\ndownload %s\n", 
				host_client->uploadfn, p);
		}
	}

}

/*
==================
SV_BeginDownload_f
==================
*/
void SV_BeginDownload_f(void)
{
	char	*name;
	extern	cvar_t	allow_download;
	extern	cvar_t	allow_download_skins;
	extern	cvar_t	allow_download_models;
	extern	cvar_t	allow_download_sounds;
	extern	cvar_t	allow_download_maps;
	extern	int		file_from_pak; // ZOID did file come from pak?

	name = Cmd_Argv(1);
// hacked by zoid to allow more conrol over download
		// first off, no .. or global allow check
	if (strstr (name, "..") || !allow_download.value
		// leading dot is no good
		|| *name == '.' 
		// leading slash bad as well, must be in subdir
		|| *name == '/'
		// next up, skin check
		|| (strncmp(name, "skins/", 6) == 0 && !allow_download_skins.value)
		// now models
		|| (strncmp(name, "progs/", 6) == 0 && !allow_download_models.value)
		// now sounds
		|| (strncmp(name, "sound/", 6) == 0 && !allow_download_sounds.value)
		// now maps (note special case for maps, must not be in pak)
		|| (strncmp(name, "maps/", 6) == 0 && !allow_download_maps.value)
		// MUST be in a subdirectory	
		|| !strstr (name, "/") )	
	{	// don't allow anything with .. path
		ClientReliableWrite_Begin (host_client, svc_download, 4);
		ClientReliableWrite_Short (host_client, -1);
		ClientReliableWrite_Byte (host_client, 0);
		return;
	}

	if (host_client->download) {
		fclose (host_client->download);
		host_client->download = NULL;
	}

	// lowercase name (needed for casesen file systems)
	{
		char *p;

		for (p = name; *p; p++)
			*p = (char)tolower(*p);
	}


	host_client->downloadsize = COM_FOpenFile (name, &host_client->download);
	host_client->downloadcount = 0;

	if (!host_client->download
		// special check for maps, if it came from a pak file, don't allow
		// download  ZOID
		|| (strncmp(name, "maps/", 5) == 0 && file_from_pak))
	{
		if (host_client->download) {
			fclose(host_client->download);
			host_client->download = NULL;
		}

		Sys_Printf ("Couldn't download %s to %s\n", name, host_client->name);
		ClientReliableWrite_Begin (host_client, svc_download, 4);
		ClientReliableWrite_Short (host_client, -1);
		ClientReliableWrite_Byte (host_client, 0);
		return;
	}

	// OfN - Dont like this..
	/*if ( strncmp(name, "maps/", 5) == 0 ) { 	// KK hack
		SV_ClientPrintf(host_client, PRINT_HIGH,
			"\n\n\n\n\n\n%s\n\n%s\n\n%s\n\n",
			Info_ValueForKey(localinfo,"map_download_msg1"),
			Info_ValueForKey(localinfo,"map_download_msg2"),
			Info_ValueForKey(localinfo,"map_download_msg3"));
	}*/						// KK hack

	SV_NextDownload_f ();
	Sys_Printf ("Downloading %s to %s\n", name, host_client->name);
}

//=============================================================================

char *KK_Team_Color (client_t *cl);

/* OfN
==================
SV_SoundBroadcast
==================
*/

void SV_SoundBroadcast(char* soundfile, float level)
{
	char stringsnd[128];
	int j; client_t* client;

	if (strlen(soundfile) + 16 > 126)
	{
		Con_Printf("WARNING: Sound filename too long on SV_SoundBroadcast()!\n");
		return;
	}

	stringsnd[0]='\0';
	sprintf(stringsnd,"playvol %s %f\n",soundfile,level);
	
	for (j = 0, client = svs.clients; j < MAX_CLIENTS; j++, client++)
	{
		if (client->state < cs_connected) 
			continue;
	
		ClientReliableWrite_Begin (client, svc_stufftext, 2+strlen(stringsnd));
		ClientReliableWrite_String (client, stringsnd);
	}
}

/* OfN
==================
SV_Me_Output
==================
*/

#define ME_SOUND_CMD "play misc/talk.wav\n"

void SV_Me_Output (client_t* client, char* text)
{
	SV_ClientPrintf(client, PRINT_HIGH, "%s\n", text);
	
	ClientReliableWrite_Begin (client, svc_stufftext, 2+strlen(ME_SOUND_CMD));
	ClientReliableWrite_String (client, ME_SOUND_CMD);
}

/*
==================
SV_Say
==================
*/
void SV_Say (qboolean team)
{
	client_t *client;
	int		j, tmp, i, k;
	char	*p;
	char	text[512];
	char	textsys[512];
	char	t1[32], *t2;

	qboolean isme; // OfN
	isme = false;
	
	p = Cmd_Args(); 

	if (Q_strcasecmp("/me",Cmd_Argv(1))==0||(p[1]=='/' && p[2]=='m' && p[3]=='e' && p[4]==' ')) {
		k=strlen(p);
		if(k>15) // For speed issues, we only want to look through the first 15 chars
			k=15;
		for(i=5; i<k; i++) {
			//WK 1/7/7 if(p[i] != NULL && p[i] != '"' && p[i] != ' ') { //is this a textual character?
			if(p[i] && p[i] != '"' && p[i] != ' ') { //is this a textual character?
				isme=true; //it is, so let's let it go
				break;
			}
		}
		if(isme == false) { //if it's still false at this point, fail due to no content
			return;
		}
	}

	//if (Q_strcasecmp("/me",Cmd_Argv(1))==0||(p[1]=='/' && p[2]=='m' && p[3]=='e' && p[4]==' '))
	//	isme = true;

	if (Cmd_Argc () < 2)
		return;

	//KK clc code
	p = Cmd_Argv(1);
	if (p[0] == 'K' && p[1] == 'k' && atoi(p+2) == host_client->clcnum) {
		if ( host_client->clcheck != clc_ok ) {
			host_client->clcheck = clc_ok;
			//Sys_Printf("KKCLC okay: u=%d ip=%s n=%s s=%.1f\n", host_client->userid, NET_BaseAdrToString(host_client->netchan.remote_address), host_client->name, realtime-host_client->connection_started);
			Con_DPrintf("KKCLC okay: u=%d ip=%s n=%s s=%.1f\n", host_client->userid, NET_BaseAdrToString(host_client->netchan.remote_address), host_client->name, realtime-host_client->connection_started);
		}
		return;
	}
	//KK clc code

	if (host_client->download && atoi(KK_infokey("no_download_talk"))) {
		SV_ClientPrintf(host_client, PRINT_HIGH,
			"Admin has disabled talk for downloaders.\n");
		return;
	}

	if (team)
	{
		strncpy (t1, Info_ValueForKey (host_client->userinfo, "team"), 31);
		t1[31] = 0;
	}

	if (host_client->spectator && (!sv_spectalk.value || team))
		sprintf (text, "[SPEC] %s", host_client->name);
	else if (team) {
		if (isme)
			sprintf (text, " (%s)", host_client->name);
		else
			sprintf (text, "(%s)", host_client->name);
	}
	else {
		if (isme)
			sprintf (text, " %s", host_client->name);
		else
			sprintf (text, "%s", host_client->name);
	}
	
	SetConsoleToUserColor(host_client);
	/*sprintf(textsys, "%s%s <%d>:%s ", KK_Team_Color(host_client),
		text, host_client->userid, color[COLOR_CHAT]);*/
				
	sprintf(textsys, "%s <%d>: ", text, host_client->userid);
	

	if (isme) // OfN
		strcat (text, " ");
	else 
		strcat (text, ": "); // original code

	if (fp_messages) {
		if (!sv.paused && realtime<host_client->lockedtill) {
			SV_ClientPrintf(host_client, PRINT_CHAT,
				"You can't talk for %d more seconds\n", 
					(int) (host_client->lockedtill - realtime));
			Sys_EndColor();
			return;
		}
		tmp = host_client->whensaidhead - fp_messages + 1;
		if (tmp < 0)
			tmp = 10+tmp;
		if (!sv.paused &&
			host_client->whensaid[tmp] && (realtime-host_client->whensaid[tmp] < fp_persecond)) {
			host_client->lockedtill = realtime + fp_secondsdead;
			if (fp_msg[0])
				SV_ClientPrintf(host_client, PRINT_CHAT,
					"FloodProt: %s\n", fp_msg);
			else
				SV_ClientPrintf(host_client, PRINT_CHAT,
					"FloodProt: You can't talk for %d seconds.\n", fp_secondsdead);
			Sys_EndColor();
			return;
		}
		host_client->whensaidhead++;
		if (host_client->whensaidhead > 9)
			host_client->whensaidhead = 0;
		host_client->whensaid[host_client->whensaidhead] = realtime;
	}

	p = Cmd_Args();

	if (*p == '"')
	{
		p++;
		p[Q_strlen(p)-1] = 0;
	}

	if (isme) // OfN
	{
		p+=4;
	}
		
	strncat(text, p, sizeof(text)-1-strlen(text));
    
	text[sizeof(text)-1] = 0;

    //strncat(textsys, p, sizeof(textsys)-1-strlen(textsys));
    textsys[sizeof(textsys)-1] = 0;

	{	
		char *l; int e=0;			// KK hack
		for (l=text; *l; l++) 
			if ( *l == '\r' || *l == '\n' ) { *l = ' '; e = 1; }
		for (l=textsys; *l; l++) 
			if ( *l == '\r' || *l == '\n' ) { *l = ' '; e = 1; }
		if (e) Sys_Printf ("KK edit on say...\n");
	}						// KK hack

	Sys_Printf ("%s%s", host_client->schiz? "[SCHIZ] " : "", textsys);
	Sys_ConsoleColor(COLOR_FORE_CHAT,COLOR_BACK_CHAT);
	Sys_Printf ("%s\n",p);
	Sys_EndColor();	

	for (j = 0, client = svs.clients; j < MAX_CLIENTS; j++, client++)
	{
		if (client->state < cs_connected) // let d-loaders get says KK
			continue;
		if (host_client->schiz && (host_client != client))// KK schiz
			continue;

		if (host_client->spectator && !sv_spectalk.value)
			if (!client->spectator)
				continue;
		if (team)
		{
			// the spectator team
			if (host_client->spectator) {
				if (!client->spectator)
					continue;
			} else {
				t2 = Info_ValueForKey (client->userinfo, "team");
				if ((strcmp(t1, t2) && !KK_Teammates(host_client,client)) || client->spectator)
					continue;	// on different teams
			}
		}

		if (isme)
			SV_Me_Output(client,text);
		else
			SV_ClientPrintf(client, PRINT_CHAT, "%s\n", text);
	}
}


/*
==================
SV_Say_f
==================
*/
void SV_Say_f(void)
{
	SV_Say (false);
}
/*
==================
SV_Say_Team_f
==================
*/
void SV_Say_Team_f(void)
{
	SV_Say (true);
}



//============================================================================

/*
=================
SV_Pings_f

The client is showing the scoreboard, so send new ping times for all
clients
=================
*/
void SV_Pings_f (void)
{
	client_t *client;
	int		j;

	for (j = 0, client = svs.clients; j < MAX_CLIENTS; j++, client++)
	{
		if (client->state != cs_spawned)
			continue;

		ClientReliableWrite_Begin (host_client, svc_updateping, 4);
		ClientReliableWrite_Byte (host_client, j);
		ClientReliableWrite_Short (host_client, SV_CalcPing(client));
		ClientReliableWrite_Begin (host_client, svc_updatepl, 4);
		ClientReliableWrite_Byte (host_client, j);
		ClientReliableWrite_Byte (host_client, client->lossage);
	}
}



/*
==================
SV_Kill_f
==================
*/
void SV_Kill_f (void)
{
	if (sv_player->v.health <= 0)
	{
		SV_ClientPrintf (host_client, PRINT_HIGH, "Can't suicide -- allready dead!\n");
		return;
	}
	
	pr_global_struct->time = sv.time;
	pr_global_struct->self = EDICT_TO_PROG(sv_player);
	PR_ExecuteProgram (pr_global_struct->ClientKill);
}

/*
==================
SV_TogglePause
==================
*/
void SV_TogglePause (const char *msg)
{
	int i;
	client_t *cl;

	sv.paused ^= 1;

	if (msg)
		SV_BroadcastPrintf (PRINT_HIGH, "%s", msg);

	// send notification to all clients
	for (i=0, cl = svs.clients ; i<MAX_CLIENTS ; i++, cl++)
	{
		if (!cl->state)
			continue;
		ClientReliableWrite_Begin (cl, svc_setpause, 2);
		ClientReliableWrite_Byte (cl, sv.paused);
	}
}


/*
==================
SV_Pause_f
==================
*/
void SV_Pause_f (void)
{
	//int i;
	//client_t *cl;
	char st[sizeof(host_client->name) + 32];

	if (!pausable.value) {
		SV_ClientPrintf (host_client, PRINT_HIGH, "Pause not allowed.\n");
		return;
	}

	if (host_client->spectator) {
		SV_ClientPrintf (host_client, PRINT_HIGH, "Spectators can not pause.\n");
		return;
	}

	if (sv.paused)
		sprintf (st, "%s paused the game\n", host_client->name);
	else
		sprintf (st, "%s unpaused the game\n", host_client->name);

	SV_TogglePause(st);
}


/*
=================
SV_Drop_f

The client is going to disconnect, so remove the connection immediately
=================
*/
void SV_Drop_f (void)
{
	SV_EndRedirect ();
	if (!host_client->spectator)
		SV_BroadcastPrintf (PRINT_HIGH, "%s dropped\n", host_client->name);
	SV_DropClient (host_client);	
}

/*
=================
SV_PTrack_f

Change the bandwidth estimate for a client
=================
*/
void SV_PTrack_f (void)
{
	int		i;
	edict_t *ent, *tent;
	
	if (!host_client->spectator)
		return;

	if (Cmd_Argc() != 2)
	{
		// turn off tracking
		host_client->spec_track = 0;
		ent = EDICT_NUM(host_client - svs.clients + 1);
		tent = EDICT_NUM(0);
		ent->v.goalentity = EDICT_TO_PROG(tent);
		return;
	}
	
	i = atoi(Cmd_Argv(1));
	if (i < 0 || i >= MAX_CLIENTS || svs.clients[i].state != cs_spawned ||
		svs.clients[i].spectator) {
		SV_ClientPrintf (host_client, PRINT_HIGH, "Invalid client to track\n");
		host_client->spec_track = 0;
		ent = EDICT_NUM(host_client - svs.clients + 1);
		tent = EDICT_NUM(0);
		ent->v.goalentity = EDICT_TO_PROG(tent);
		return;
	}
	host_client->spec_track = i + 1; // now tracking

	ent = EDICT_NUM(host_client - svs.clients + 1);
	tent = EDICT_NUM(i + 1);
	ent->v.goalentity = EDICT_TO_PROG(tent);
}


/*
=================
SV_Rate_f

Change the bandwidth estimate for a client
=================
*/
void SV_Rate_f (void)
{
	int		rate;
	
	if (Cmd_Argc() != 2)
	{
		SV_ClientPrintf (host_client, PRINT_HIGH, "Current rate is %i\n",
			(int)(1.0/host_client->netchan.rate + 0.5));
		return;
	}
	
	rate = atoi(Cmd_Argv(1));
	if (rate < 500)
		rate = 500;
	if (rate > 10000)
		rate = 10000;

	SV_ClientPrintf (host_client, PRINT_HIGH, "Net rate set to %i\n", rate);
	host_client->netchan.rate = 1.0/rate;
}


/*
=================
SV_Msg_f

Change the message level for a client
=================
*/
void SV_Msg_f (void)
{	
	if (Cmd_Argc() != 2)
	{
		SV_ClientPrintf (host_client, PRINT_HIGH, "Current msg level is %i\n",
			host_client->messagelevel);
		return;
	}
	
	host_client->messagelevel = atoi(Cmd_Argv(1));

	SV_ClientPrintf (host_client, PRINT_HIGH, "Msg level set to %i\n", host_client->messagelevel);
}

/*
==================
SV_SetInfo_f

Allow clients to change userinfo
==================
*/
void SV_SetInfo_f (void)
{
	int i,j,k;
	char oldval[MAX_INFO_STRING];
	char info[MAX_INFO_STRING];
	client_t *cl;

	//WK Variables for the spy color hack logic, most can be eliminated...
	int playing_tf = 1;
	int	teams	= (int) KK_Global_Float("number_of_teams");
	int same_team = 0; //Set TRUE if players are on the same team
	int chosen_color = 0; //The color the client is changing to
	int right_color = 0; //If resetting, set to the reset color of the team
	int myteam = 0; //Holds the team number of the active client

	if (Cmd_Argc() == 1)
	{
		Con_Printf ("User info settings:\n");
		Info_Print (host_client->userinfo);
		return;
	}

	if (Cmd_Argc() != 3)
	{
		Con_Printf ("usage: setinfo [ <key> <value> ]\n");
		return;
	}

	if (Cmd_Argv(1)[0] == '*')
		return;		// don't set priveledged values

	strcpy(oldval, Info_ValueForKey(host_client->userinfo, Cmd_Argv(1)));

	Info_SetValueForKey (host_client->userinfo, Cmd_Argv(1), Cmd_Argv(2), MAX_INFO_STRING);
// name is extracted below in ExtractFromUserInfo
//	strncpy (host_client->name, Info_ValueForKey (host_client->userinfo, "name")
//		, sizeof(host_client->name)-1);	
//	SV_FullClientUpdate (host_client, &sv.reliable_datagram);
//	host_client->sendinfo = true;

	if (!strcmp(Info_ValueForKey(host_client->userinfo, Cmd_Argv(1)), oldval))
		return; // key hasn't changed

	// process any changed values
	SV_ExtractFromUserinfo (host_client);

	/* WK 1/7/7 Spy Color Hack WOWOW
	   Send spy color changes to enemies only.
	   Yourself and teammates see you in your team's colors (bottomcolor), with a topcolor of the enemy,
	   so that you and your friends know that you are indeed disguised.
	   Has enough logic to enable itself only during TF games.
	*/
	#define COLOR_TEAM_0	0
	#define S_COLOR_TEAM_0 "0"
	#define COLOR_TEAM_1	13
	#define S_COLOR_TEAM_1 "13"
	#define COLOR_TEAM_2	4
	#define S_COLOR_TEAM_2 "4"
	#define COLOR_TEAM_3	12
	#define S_COLOR_TEAM_3 "12"
	#define COLOR_TEAM_4	11
	#define S_COLOR_TEAM_4 "11"
	#define COLOR_TEAMKILLER 8

	if (!strcmp(Cmd_Argv(1),"topcolor") || !strcmp(Cmd_Argv(1),"bottomcolor")) {
		
		//Figure out the logic, we only do the spy color hack in TF games with people on a team
		myteam = KK_Team_No(host_client);
		if (teams < 1 || teams > 4) playing_tf = 0;
		if (strcmp(Info_ValueForKey(svs.info,"*gamedir"),"fortress")) playing_tf = 0;
		// PZ: Don't alter the colors in Neo mode.
		if (KK_Global_Float("neo")) playing_tf = 0;
		chosen_color = atoi(Info_ValueForKey(host_client->userinfo, Cmd_Argv(1)));

		//Right_color only gets set if we're resetting our color to where it should be
		//(If we are switching to our right color, we allow everyone to see the reset)
		if (myteam == 0 && chosen_color == COLOR_TEAM_0 ||
			myteam == 1 && chosen_color == COLOR_TEAM_1 ||
			myteam == 2 && chosen_color == COLOR_TEAM_2 ||
			myteam == 3 && chosen_color == COLOR_TEAM_3 ||
			myteam == 4 && chosen_color == COLOR_TEAM_4) right_color = 1;
		if (chosen_color == COLOR_TEAMKILLER) right_color = 1; //Handle TKers
		
		//Sys_Printf("Color Change to %i. (myteam: %i)\n",chosen_color,myteam);
		//if (right_color) Sys_Printf("(Colors Reset)\n");
		//else Sys_Printf("(Disguising)\n");

		//"info" holds the userinfo array to be sent out to his team
		//"host_client->userinfo", the real data, gets sent to his enemies instead
		strcpy (info, host_client->userinfo);
		Info_SetValueForKey(info,"topcolor",Info_ValueForKey(host_client->userinfo, Cmd_Argv(1)),MAX_INFO_STRING);
		if (myteam == 0) Info_SetValueForKey(info,"bottomcolor",S_COLOR_TEAM_0,MAX_INFO_STRING);
		if (myteam == 1) Info_SetValueForKey(info,"bottomcolor",S_COLOR_TEAM_1,MAX_INFO_STRING);
		if (myteam == 2) Info_SetValueForKey(info,"bottomcolor",S_COLOR_TEAM_2,MAX_INFO_STRING);
		if (myteam == 3) Info_SetValueForKey(info,"bottomcolor",S_COLOR_TEAM_3,MAX_INFO_STRING);
		if (myteam == 4) Info_SetValueForKey(info,"bottomcolor",S_COLOR_TEAM_4,MAX_INFO_STRING);
		//Handle Resetting Colors correctly
		if (right_color) Info_SetValueForKey(info,"bottomcolor",Info_ValueForKey(host_client->userinfo, Cmd_Argv(1)),MAX_INFO_STRING);

		//Now broadcast the info array to all teammates, and the normal array to all enemies
		for (i=0, cl = svs.clients; i < MAX_CLIENTS; i++, cl++) {
			j = KK_Team_No(cl);
			same_team = (j == myteam);
			if (same_team && j && playing_tf) {
				//Sys_Printf("Client %i is on same team (team %i) as color changer, info sent\n",cl->userid,myteam);
				k = host_client - svs.clients;
				ClientReliableWrite_Begin(cl,svc_setinfo,18);
				ClientReliableWrite_Byte(cl,k);
				ClientReliableWrite_String(cl,Cmd_Argv(1));
				ClientReliableWrite_String(cl,Info_ValueForKey(info, Cmd_Argv(1)));
			} else {
				k = host_client - svs.clients;
				ClientReliableWrite_Begin(cl,svc_setinfo,18);
				ClientReliableWrite_Byte(cl,k);
				ClientReliableWrite_String(cl,Cmd_Argv(1));
				ClientReliableWrite_String(cl,Info_ValueForKey(host_client->userinfo, Cmd_Argv(1)));
			}
		}
	} else {
		//Not a color change, so pass it on as before
		k = host_client - svs.clients;
		MSG_WriteByte (&sv.reliable_datagram, svc_setinfo);
		MSG_WriteByte (&sv.reliable_datagram, k);
		MSG_WriteString (&sv.reliable_datagram, Cmd_Argv(1));
		MSG_WriteString (&sv.reliable_datagram, Info_ValueForKey(host_client->userinfo, Cmd_Argv(1)));
	}
}
/*
==================
SV_ShowServerinfo_f

Dumps the serverinfo info string
==================
*/
void SV_ShowServerinfo_f (void)
{
	Info_Print (svs.info);
}

void SV_NoSnap_f(void)
{
	if (*host_client->uploadfn) {
		*host_client->uploadfn = 0;
		SV_BroadcastPrintf (PRINT_HIGH, "%s refused remote screenshot\n", host_client->name);
	}
}

typedef struct
{
	char	*name;
	void	(*func) (void);
} ucmd_t;

ucmd_t ucmds[] =
{
	{"new", SV_New_f},
	{"modellist", SV_Modellist_f},
	{"soundlist", SV_Soundlist_f},
	{"prespawn", SV_PreSpawn_f},
	{"spawn", SV_Spawn_f},
	{"begin", SV_Begin_f},

	{"drop", SV_Drop_f},
	{"pings", SV_Pings_f},

// issued by hand at client consoles	
	{"rate", SV_Rate_f},
	{"kill", SV_Kill_f},
	{"pause", SV_Pause_f},
	{"msg", SV_Msg_f},

	{"say", SV_Say_f},
	{"say_team", SV_Say_Team_f},

	{"setinfo", SV_SetInfo_f},

	{"serverinfo", SV_ShowServerinfo_f},

	{"download", SV_BeginDownload_f},
	{"nextdl", SV_NextDownload_f},

	{"ptrack", SV_PTrack_f}, //ZOID - used with autocam

	{"snap", SV_NoSnap_f},
	
	{NULL, NULL}
};

/*
==================
SV_ExecuteUserCommand
==================
*/
void SV_ExecuteUserCommand (char *s)
{
	ucmd_t	*u;

	int j, tmp; //OfN
	
	Cmd_TokenizeString (s);
	sv_player = host_client->edict;

	SV_BeginRedirect (RD_CLIENT);

	for (u=ucmds ; u->name ; u++)
		if (!strcmp (Cmd_Argv(0), u->name) )
		{
			u->func ();
			break;
		}	
	
	// OfN - Client commands handled on progs
	if (!u->name && ClientCommand)
	{		
		SV_EndRedirect ();

		pr_global_struct->time = sv.time;
		pr_global_struct->self = EDICT_TO_PROG(sv_player);

		// limit possible params to 7
		tmp = Cmd_Argc();
		if (tmp > 7)
			tmp = 7;
		
		// Assign params
		G_FLOAT(OFS_PARM0) = (float)tmp; // Number of args

		//for (j = 0; j < tmp; j++) // assign string params
		for (j = 0; j < 7; j++) // assign string params
		{
			if (j < tmp)			
				((int *)pr_globals)[OFS_PARM1+j*3] = PR_SetString(Cmd_Argv(j));
			else
				((int *)pr_globals)[OFS_PARM1+j*3] = 0;
		}

		PR_ExecuteProgram (ClientCommand);

		// Check if successfull command on progs
		if (G_FLOAT(OFS_RETURN)!=0) // did the progs function returned a success?
			return; // yep, so just finish
		else
			SV_BeginRedirect (RD_CLIENT); // nope, restore redirection and continue		
	} // OfN - END	

	if (!u->name)
		Con_Printf ("Bad user commandº %s\n", Cmd_Argv(0));

	SV_EndRedirect ();
}

/*
===========================================================================

USER CMD EXECUTION

===========================================================================
*/

/*
===============
V_CalcRoll

Used by view and sv_user
===============
*/
float V_CalcRoll (vec3_t angles, vec3_t velocity)
{
	vec3_t	forward, right, up;
	float	sign;
	float	side;
	float	value;
	
	AngleVectors (angles, forward, right, up);
	side = DotProduct (velocity, right);
	sign = side < 0 ? -1 : 1;
	side = fabs(side);
	
	value = cl_rollangle.value;

	if (side < cl_rollspeed.value)
		side = side * value / cl_rollspeed.value;
	else
		side = value;
	
	return side*sign;
	
}




//============================================================================

vec3_t	pmove_mins, pmove_maxs;

/*
====================
AddLinksToPmove

====================
*/
void AddLinksToPmove ( areanode_t *node )
{
	link_t		*l, *next;
	edict_t		*check;
	int			pl;
	int			i;
	physent_t	*pe;

	pl = EDICT_TO_PROG(sv_player);

	// touch linked edicts
	for (l = node->solid_edicts.next ; l != &node->solid_edicts ; l = next)
	{
		next = l->next;
		check = EDICT_FROM_AREA(l);

		if (check->v.owner == pl)
			continue;		// player's own missile
		if (check->v.solid == SOLID_BSP 
			|| check->v.solid == SOLID_BBOX 
			|| check->v.solid == SOLID_SLIDEBOX)
		{
			if (check == sv_player)
				continue;

			for (i=0 ; i<3 ; i++)
				if (check->v.absmin[i] > pmove_maxs[i]
				|| check->v.absmax[i] < pmove_mins[i])
					break;
			if (i != 3)
				continue;
			if (pmove.numphysent == MAX_PHYSENTS)
				return;
			pe = &pmove.physents[pmove.numphysent];
			pmove.numphysent++;

			VectorCopy (check->v.origin, pe->origin);
			pe->info = NUM_FOR_EDICT(check);
			if (check->v.solid == SOLID_BSP)
				pe->model = sv.models[(int)(check->v.modelindex)];
			else
			{
				pe->model = NULL;
				VectorCopy (check->v.mins, pe->mins);
				VectorCopy (check->v.maxs, pe->maxs);
			}
		}
	}
	
// recurse down both sides
	if (node->axis == -1)
		return;

	if ( pmove_maxs[node->axis] > node->dist )
		AddLinksToPmove ( node->children[0] );
	if ( pmove_mins[node->axis] < node->dist )
		AddLinksToPmove ( node->children[1] );
}


/*
================
AddAllEntsToPmove

For debugging
================
*/
void AddAllEntsToPmove (void)
{
	int			e;
	edict_t		*check;
	int			i;
	physent_t	*pe;
	int			pl;

	pl = EDICT_TO_PROG(sv_player);
	check = NEXT_EDICT(sv.edicts);
	for (e=1 ; e<sv.num_edicts ; e++, check = NEXT_EDICT(check))
	{
		if (check->free)
			continue;
		if (check->v.owner == pl)
			continue;
		if (check->v.solid == SOLID_BSP 
			|| check->v.solid == SOLID_BBOX 
			|| check->v.solid == SOLID_SLIDEBOX)
		{
			if (check == sv_player)
				continue;

			for (i=0 ; i<3 ; i++)
				if (check->v.absmin[i] > pmove_maxs[i]
				|| check->v.absmax[i] < pmove_mins[i])
					break;
			if (i != 3)
				continue;
			pe = &pmove.physents[pmove.numphysent];

			VectorCopy (check->v.origin, pe->origin);
			pmove.physents[pmove.numphysent].info = e;
			if (check->v.solid == SOLID_BSP)
				pe->model = sv.models[(int)(check->v.modelindex)];
			else
			{
				pe->model = NULL;
				VectorCopy (check->v.mins, pe->mins);
				VectorCopy (check->v.maxs, pe->maxs);
			}

			if (++pmove.numphysent == MAX_PHYSENTS)
				break;
		}
	}
}

/*
===========
SV_PreRunCmd
===========
Done before running a player command.  Clears the touch array
*/
byte playertouch[(MAX_EDICTS+7)/8];

void SV_PreRunCmd(void)
{
	memset(playertouch, 0, sizeof(playertouch));
}

/*
===========
SV_RunCmd
===========
*/
void SV_RunCmd (usercmd_t *ucmd, qboolean inside)
{
	edict_t		*ent;
	int			i, n;
	int			oldmsec;
	// KK hack copied from QuakeForge anti-cheat
	// (also extra inside parm on all SV_RunCmds that follow)
	#define CHECK_TIME 30
	double  tmp_time;
	// To prevent a infinite loop
	if (!inside) {
		host_client->msecs += ucmd->msec;

		if ((tmp_time = realtime - host_client->last_check) >= CHECK_TIME) {
			tmp_time = tmp_time * 1000.0 * sv_cheatpc.value/100.0;
		    if (host_client->msecs > tmp_time) {
				host_client->msec_cheating++;
				SV_BroadcastPrintf(PRINT_HIGH, 
						va("Speed cheat possibility, analyzing:\n  %d %.1f %d for: %s\n",
							host_client->msecs, tmp_time,
							host_client->msec_cheating, host_client->name));

				if (host_client->msec_cheating >= 2) {
					SV_BroadcastPrintf(PRINT_HIGH, 
							va("kicked %s (%s)\n    for speed cheating.\n", 
								host_client->name, NET_AdrToString(host_client->netchan.remote_address)));
					SV_DropClient(host_client);
				}
		    }

		    host_client->msecs = 0;
		    host_client->last_check = realtime;
		}
	}
	// end KK hack copied from QuakeForge anti-cheat

	cmd = *ucmd;

	// chop up very long commands
	if (cmd.msec > 50)
	{
		oldmsec = ucmd->msec;
		cmd.msec = oldmsec/2;
		SV_RunCmd (&cmd, 1);
		cmd.msec = oldmsec/2;
		cmd.impulse = 0;
		SV_RunCmd (&cmd, 1);
		return;
	}

	if (!sv_player->v.fixangle)
		VectorCopy (ucmd->angles, sv_player->v.v_angle);

	sv_player->v.button0 = ucmd->buttons & 1;
	sv_player->v.button2 = (ucmd->buttons & 2)>>1;
	if (ucmd->impulse)
		sv_player->v.impulse = ucmd->impulse;
	if (host_client->cuff_time > realtime)	// KK hack cuff
		sv_player->v.button0 = sv_player->v.impulse = 0;

//
// angles
// show 1/3 the pitch angle and all the roll angle	
	if (sv_player->v.health > 0)
	{
		if (!sv_player->v.fixangle)
		{
			sv_player->v.angles[PITCH] = -sv_player->v.v_angle[PITCH]/3;
			sv_player->v.angles[YAW] = sv_player->v.v_angle[YAW];
		}
		sv_player->v.angles[ROLL] = 
			V_CalcRoll (sv_player->v.angles, sv_player->v.velocity)*4;
	}

	host_frametime = ucmd->msec * 0.001;
	if (host_frametime > 0.1)
		host_frametime = 0.1;

	if (!host_client->spectator)
	{
		pr_global_struct->frametime = host_frametime;

		pr_global_struct->time = sv.time;
		pr_global_struct->self = EDICT_TO_PROG(sv_player);
		PR_ExecuteProgram (pr_global_struct->PlayerPreThink);

		SV_RunThink (sv_player);
	}

	for (i=0 ; i<3 ; i++)
		pmove.origin[i] = sv_player->v.origin[i] + (sv_player->v.mins[i] - player_mins[i]);
	VectorCopy (sv_player->v.velocity, pmove.velocity);
	VectorCopy (sv_player->v.v_angle, pmove.angles);

	pmove.spectator = host_client->spectator;
	pmove.waterjumptime = sv_player->v.teleport_time;
	pmove.numphysent = 1;
	pmove.physents[0].model = sv.worldmodel;
	pmove.cmd = *ucmd;
	pmove.dead = sv_player->v.health <= 0;
	pmove.oldbuttons = host_client->oldbuttons;

	movevars.entgravity = host_client->entgravity;
	movevars.maxspeed = host_client->maxspeed;

	for (i=0 ; i<3 ; i++)
	{
		pmove_mins[i] = pmove.origin[i] - 256;
		pmove_maxs[i] = pmove.origin[i] + 256;
	}
#if 1
	AddLinksToPmove ( sv_areanodes );
#else
	AddAllEntsToPmove ();
#endif

#if 0
{
	int before, after;

before = PM_TestPlayerPosition (pmove.origin);
	PlayerMove ();
after = PM_TestPlayerPosition (pmove.origin);

if (sv_player->v.health > 0 && before && !after )
	Con_Printf ("player %s got stuck in playermove!!!!\n", host_client->name);
}
#else
	PlayerMove ();
#endif

	host_client->oldbuttons = pmove.oldbuttons;
	sv_player->v.teleport_time = pmove.waterjumptime;
	sv_player->v.waterlevel = waterlevel;
	sv_player->v.watertype = watertype;
	if (onground != -1)
	{
		sv_player->v.flags = (int)sv_player->v.flags | FL_ONGROUND;
		sv_player->v.groundentity = EDICT_TO_PROG(EDICT_NUM(pmove.physents[onground].info));
	}
	else
		sv_player->v.flags = (int)sv_player->v.flags & ~FL_ONGROUND;
	for (i=0 ; i<3 ; i++)
		sv_player->v.origin[i] = pmove.origin[i] - (sv_player->v.mins[i] - player_mins[i]);

#if 0
	// truncate velocity the same way the net protocol will
	for (i=0 ; i<3 ; i++)
		sv_player->v.velocity[i] = (int)pmove.velocity[i];
#else
	VectorCopy (pmove.velocity, sv_player->v.velocity);
#endif

	VectorCopy (pmove.angles, sv_player->v.v_angle);

	if (!host_client->spectator)
	{
		// link into place and touch triggers
		SV_LinkEdict (sv_player, true);

		// touch other objects
		for (i=0 ; i<pmove.numtouch ; i++)
		{
			n = pmove.physents[pmove.touchindex[i]].info;
			ent = EDICT_NUM(n);
			if (!ent->v.touch || (playertouch[n/8]&(1<<(n%8))))
				continue;
			pr_global_struct->self = EDICT_TO_PROG(ent);
			pr_global_struct->other = EDICT_TO_PROG(sv_player);
			PR_ExecuteProgram (ent->v.touch);
			playertouch[n/8] |= 1 << (n%8);
		}
	}
}

/*
===========
SV_PostRunCmd
===========
Done after running a player command.
*/
void SV_PostRunCmd(void)
{
	// run post-think

	if (!host_client->spectator) {
		pr_global_struct->time = sv.time;
		pr_global_struct->self = EDICT_TO_PROG(sv_player);
		PR_ExecuteProgram (pr_global_struct->PlayerPostThink);
		SV_RunNewmis ();
	} else if (SpectatorThink) {
		pr_global_struct->time = sv.time;
		pr_global_struct->self = EDICT_TO_PROG(sv_player);
		PR_ExecuteProgram (SpectatorThink);
	}
	// KK clc start
	{ int i; char *base, cmd[256];
	if (host_client->clcheck == clc_ok || realtime < host_client->clctime)
		return;
	host_client->clctime = realtime + 10.0;
	if (host_client->state != cs_spawned || sv.state != ss_active) {
		Sys_Printf("KKCLC dlay: u=%d ip=%s n=%s s=%.1f\n", host_client->userid, NET_BaseAdrToString(host_client->netchan.remote_address), host_client->name, realtime-host_client->connection_started);
		return;
	}
	base = "áìéáó æõììâòéçèô ¢óáù Ëë¥ä¢» æõììâòéçèô» æõììâòéçèôŠ";
	strcpy(cmd, base);
	for (i=0;cmd[i];i++) cmd[i] &= 0x7F;
	if (host_client->clcheck == clc_unchecked) {
		host_client->clcheck = clc_wait1;
		KK_stuffcmd(host_client, va(cmd, host_client->clcnum));
		//Sys_Printf("KKCLC sent: u=%d ip=%s n=%s s=%.1f\n", host_client->userid, NET_BaseAdrToString(host_client->netchan.remote_address), host_client->name, realtime-host_client->connection_started);
	} else if (host_client->clcheck == clc_wait1) {
		host_client->clcheck = clc_wait2;
		KK_stuffcmd(host_client, va(cmd, host_client->clcnum));
		Sys_Printf("KKCLC failure1: u=%d ip=%s n=%s s=%.1f\n", host_client->userid, NET_BaseAdrToString(host_client->netchan.remote_address), host_client->name, realtime-host_client->connection_started);
	} else {
		host_client->clcheck = clc_ok;
		Sys_Printf("KKCLC failure2: u=%d ip=%s n=%s s=%.1f\n", host_client->userid, NET_BaseAdrToString(host_client->netchan.remote_address), host_client->name, realtime-host_client->connection_started);
		if ( !stricmp(KK_infokey("client_check"),"on") ) {
			Cmd_ExecuteString(va("say KK finds AA/RADAR/SPEED client: %s",host_client->name));
			Cmd_ExecuteString("say Try a legal client from www.quakeworld.net");
			Cmd_ExecuteString(va("say Everyone say goodbye to %s...",host_client->name));
			SV_DropClient(host_client);
		}
	}
	// KK clc end
	}
}


/*
===================
SV_ExecuteClientMessage

The current net_message is parsed for the given client
===================
*/
void SV_ExecuteClientMessage (client_t *cl)
{
	int		c;
	char	*s;
	usercmd_t	oldest, oldcmd, newcmd;
	client_frame_t	*frame;
	vec3_t o;
	qboolean	move_issued = false; //only allow one move command
	int		checksumIndex;
	byte	checksum, calculatedChecksum;
	int		seq_hash;

	// calc ping time
	frame = &cl->frames[cl->netchan.incoming_acknowledged & UPDATE_MASK];
	frame->ping_time = realtime - frame->senttime;

	// make sure the reply sequence number matches the incoming
	// sequence number 
	if (cl->netchan.incoming_sequence >= cl->netchan.outgoing_sequence)
		cl->netchan.outgoing_sequence = cl->netchan.incoming_sequence;
	else
		cl->send_message = false;	// don't reply, sequences have slipped		

	// save time for ping calculations
	cl->frames[cl->netchan.outgoing_sequence & UPDATE_MASK].senttime = realtime;
	cl->frames[cl->netchan.outgoing_sequence & UPDATE_MASK].ping_time = -1;

	host_client = cl;
	sv_player = host_client->edict;

//	seq_hash = (cl->netchan.incoming_sequence & 0xffff) ; // ^ QW_CHECK_HASH;
	seq_hash = cl->netchan.incoming_sequence;
	
	// mark time so clients will know how much to predict
	// other players
 	cl->localtime = sv.time;
	cl->delta_sequence = -1;	// no delta unless requested
	while (1)
	{
		if (msg_badread)
		{
			Con_Printf ("SV_ReadClientMessage: badread\n");
			SV_DropClient (cl);
			return;
		}	

		c = MSG_ReadByte ();
		if (c == -1)
			break;
				
		switch (c)
		{
		default:
			Con_Printf ("SV_ReadClientMessage: unknown command char\n");
			SV_DropClient (cl);
			return;
						
		case clc_nop:
			break;

		case clc_delta:
			cl->delta_sequence = MSG_ReadByte ();
			break;

		case clc_move:
			if (move_issued)
				return;		// someone is trying to cheat...

			move_issued = true;

			checksumIndex = MSG_GetReadCount();
			checksum = (byte)MSG_ReadByte ();

			// read loss percentage
			cl->lossage = MSG_ReadByte();

			MSG_ReadDeltaUsercmd (&nullcmd, &oldest);
			MSG_ReadDeltaUsercmd (&oldest, &oldcmd);
			MSG_ReadDeltaUsercmd (&oldcmd, &newcmd);

			if ( cl->state != cs_spawned )
				break;

			// if the checksum fails, ignore the rest of the packet
			calculatedChecksum = COM_BlockSequenceCRCByte(
				net_message.data + checksumIndex + 1,
				MSG_GetReadCount() - checksumIndex - 1,
				seq_hash);

			if (calculatedChecksum != checksum)
			{
				Con_DPrintf ("Failed command checksum for %s(%d) (%d != %d)\n", 
					cl->name, cl->netchan.incoming_sequence, checksum, calculatedChecksum);
				return;
			}

			if (!sv.paused) {
				SV_PreRunCmd();

				if (net_drop < 20)
				{
					while (net_drop > 2)
					{
						SV_RunCmd (&cl->lastcmd, 0);
						net_drop--;
					}
					if (net_drop > 1)
						SV_RunCmd (&oldest, 0);
					if (net_drop > 0)
						SV_RunCmd (&oldcmd, 0);
				}
				SV_RunCmd (&newcmd, 0);

				SV_PostRunCmd();
			}

			cl->lastcmd = newcmd;
			cl->lastcmd.buttons = 0; // avoid multiple fires on lag
			break;


		case clc_stringcmd:	
			s = MSG_ReadString ();
			SV_ExecuteUserCommand (s);
			break;

		case clc_tmove:
			o[0] = MSG_ReadCoord();
			o[1] = MSG_ReadCoord();
			o[2] = MSG_ReadCoord();
			// only allowed by spectators
			if (host_client->spectator) {
				VectorCopy(o, sv_player->v.origin);
				SV_LinkEdict(sv_player, false);
			}
			break;

		case clc_upload:
			SV_NextUpload();
			break;

		}
	}
}

/*
==============
SV_UserInit
==============
*/
void SV_UserInit (void)
{
	Cvar_RegisterVariable (&cl_rollspeed);
	Cvar_RegisterVariable (&cl_rollangle);
	Cvar_RegisterVariable (&sv_spectalk);
	Cvar_RegisterVariable (&sv_mapcheck);
}


