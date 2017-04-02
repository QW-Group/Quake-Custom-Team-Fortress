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
#include "dblog.h"

#define	RETURN_EDICT(e) (((int *)pr_globals)[OFS_RETURN] = EDICT_TO_PROG(e))
#define	RETURN_STRING(s) (((int *)pr_globals)[OFS_RETURN] = PR_SetString(s))

/*
===============================================================================

						BUILT-IN FUNCTIONS

===============================================================================
*/

char *PF_VarString (int	first)
{
	int		i;
	static char out[256];
	
	out[0] = 0;
	for (i=first ; i<pr_argc ; i++)
	{
		strcat (out, G_STRING((OFS_PARM0+i*3)));
	}
	return out;
}


/*
=================
PF_errror

This is a TERMINAL error, which will kill off the entire server.
Dumps self.

error(value)
=================
*/
void PF_error (void)
{
	char	*s;
	edict_t	*ed;
	
	s = PF_VarString(0);
	Con_Printf ("======SERVER ERROR in %s:\n%s\n", PR_GetString(pr_xfunction->s_name) ,s);
	ed = PROG_TO_EDICT(pr_global_struct->self);
	ED_Print (ed);

	SV_Error ("Program error");
}

/*
=================
PF_objerror

Dumps out self, then an error message.  The program is aborted and self is
removed, but the level can continue.

objerror(value)
=================
*/
void PF_objerror (void)
{
	char	*s;
	edict_t	*ed;
	
	s = PF_VarString(0);
	Con_Printf ("======OBJECT ERROR in %s:\n%s\n", PR_GetString(pr_xfunction->s_name),s);
	ed = PROG_TO_EDICT(pr_global_struct->self);
	ED_Print (ed);
	ED_Free (ed);
	
	SV_Error ("Program error");
}



/*
==============
PF_makevectors

Writes new values for v_forward, v_up, and v_right based on angles
makevectors(vector)
==============
*/
void PF_makevectors (void)
{
	AngleVectors (G_VECTOR(OFS_PARM0), pr_global_struct->v_forward, pr_global_struct->v_right, pr_global_struct->v_up);
}

/*
=================
PF_setorigin

This is the only valid way to move an object without using the physics of the world (setting velocity and waiting).  Directly changing origin will not set internal links correctly, so clipping would be messed up.  This should be called when an object is spawned, and then only if it is teleported.

setorigin (entity, origin)
=================
*/
void PF_setorigin (void)
{
	edict_t	*e;
	float	*org;
	
	e = G_EDICT(OFS_PARM0);
	org = G_VECTOR(OFS_PARM1);
	VectorCopy (org, e->v.origin);
	SV_LinkEdict (e, false);
}


/*
=================
PF_setsize

the size box is rotated by the current angle

setsize (entity, minvector, maxvector)
=================
*/
void PF_setsize (void)
{
	edict_t	*e;
	float	*min, *max;
	
	e = G_EDICT(OFS_PARM0);
	min = G_VECTOR(OFS_PARM1);
	max = G_VECTOR(OFS_PARM2);
	VectorCopy (min, e->v.mins);
	VectorCopy (max, e->v.maxs);
	VectorSubtract (max, min, e->v.size);
	SV_LinkEdict (e, false);
}


/*
=================
PF_setmodel

setmodel(entity, model)
Also sets size, mins, and maxs for inline bmodels
=================
*/
void PF_setmodel (void)
{
	edict_t	*e;
	char	*m, **check;
	int		i;
	model_t	*mod;

	e = G_EDICT(OFS_PARM0);
	m = G_STRING(OFS_PARM1);

// check to see if model was properly precached
	for (i=0, check = sv.model_precache ; *check ; i++, check++)
		if (!strcmp(*check, m))
			break;

	if (!*check)
		PR_RunError ("no precache: %s\n", m);
		
	e->v.model = PR_SetString(m);
	e->v.modelindex = i;

// if it is an inline model, get the size information for it
	if (m[0] == '*')
	{
		mod = Mod_ForName (m, true);
		VectorCopy (mod->mins, e->v.mins);
		VectorCopy (mod->maxs, e->v.maxs);
		VectorSubtract (mod->maxs, mod->mins, e->v.size);
		SV_LinkEdict (e, false);
	}

}

int team_no_offset;      // enitity offset of field 'team_no'
int real_owner_offset;   // enitity offset of field 'real_owner'
int runes_owned_offset;
int job_offset; //WK

int cltype_offset;
int clversion_offset;

char *type[] = { "s", "e", "so", "eo", "sr", "er" };

/*
=================
KK_Is_Player_Name

insert userid in sysprint of player name

=================
*/
qboolean KK_Is_Player_Name (char *name)
{
	int	 i, count, entnum;
	client_t *cl;
	edict_t	 *self, *enemy, *edicts[10];
	eval_t	 *val;

	count = 0; cl = NULL;

	edicts[count++] = self  = PROG_TO_EDICT(pr_global_struct->self);
        edicts[count++] = enemy = PROG_TO_EDICT(self->v.enemy);
	edicts[count++] = PROG_TO_EDICT(self->v.owner);
	edicts[count++] = PROG_TO_EDICT(enemy->v.owner);
	if (real_owner_offset) {
		val = (eval_t *)((char *)&self->v + real_owner_offset);
		edicts[count++] = PROG_TO_EDICT(val->edict);
		val = (eval_t *)((char *)&enemy->v + real_owner_offset);
		edicts[count++] = PROG_TO_EDICT(val->edict);
	}
	for (i=0; i<count ; i++) {
		entnum = NUM_FOR_EDICT(edicts[i]);
        	if (entnum < 1 || entnum > MAX_CLIENTS) 
			continue;
		if (!Q_strcmp(name, svs.clients[entnum-1].name)) {
			//Sys_Printf("[%s] ", type[i]);
			cl = &svs.clients[entnum-1];
			break;
		}
	}
//	for (i=0, p=svs.clients ; !cl && i<MAX_CLIENTS ; i++,p++) {
//		if (!p->state) continue;
//		if (!Q_strcmp(name, p->name)) {
//			Sys_Printf("[p] ");
//			cl = p;
//		}
//	}
	if (cl) {
		//Sys_Printf("%s%s <%d>", KK_Team_Color(cl), name, cl->userid);
		SetConsoleToUserColor(cl);
		Sys_Printf("%s <%d>", name, cl->userid);
		Sys_EndColor();
		return true;
	}
	return false;
}

/*
=================
PF_bprint

broadcast print to everyone on server

bprint(value)
=================
*/
void PF_bprint (void)
{
	char		*s;
	int		level;

	level = G_FLOAT(OFS_PARM0);

	s = PF_VarString(1);

	if (KK_Is_Player_Name(s)) 		// did sysprintf with color
		dont_sysprint_in_bdcast = true;	// so stop broadcast's sysprintf
	SV_BroadcastPrintf (level, "%s", s);
}

/*
=================
PF_sprint

single print to a specific client

sprint(clientent, value)
=================
*/
void PF_sprint (void)
{
	char		*s;
	client_t	*client;
	int			entnum;
	int			level;
	
	entnum = G_EDICTNUM(OFS_PARM0);
	level = G_FLOAT(OFS_PARM1);

	s = PF_VarString(2);
	
	if (entnum < 1 || entnum > MAX_CLIENTS)
	{
		Con_Printf ("tried to sprint to a non-client\n");
		return;
	}
		
	client = &svs.clients[entnum-1];
	
	SV_ClientPrintf (client, level, "%s", s);
}


/*
=================
PF_centerprint

single print to a specific client

centerprint(clientent, value)
=================
*/
void PF_centerprint (void)
{
	char		*s;
	int			entnum;
	client_t	*cl;
	
	entnum = G_EDICTNUM(OFS_PARM0);
	s = PF_VarString(1);
	
	if (entnum < 1 || entnum > MAX_CLIENTS)
	{
		Con_Printf ("tried to sprint to a non-client\n");
		return;
	}
		
	cl = &svs.clients[entnum-1];

	// OfN - Dont print to finalized players (see prozac mod source)
	if ((int)cl->edict->v.flags & FL_FINALIZED)
		return;

	ClientReliableWrite_Begin (cl, svc_centerprint, 2 + strlen(s));
	ClientReliableWrite_String (cl, s);
}


/*
=================
PF_normalize

vector normalize(vector)
=================
*/
void PF_normalize (void)
{
	float	*value1;
	vec3_t	newvalue;
	float	new;
	
	value1 = G_VECTOR(OFS_PARM0);

	new = value1[0] * value1[0] + value1[1] * value1[1] + value1[2]*value1[2];
	new = sqrt(new);
	
	if (new == 0)
		newvalue[0] = newvalue[1] = newvalue[2] = 0;
	else
	{
		new = 1/new;
		newvalue[0] = value1[0] * new;
		newvalue[1] = value1[1] * new;
		newvalue[2] = value1[2] * new;
	}
	
	VectorCopy (newvalue, G_VECTOR(OFS_RETURN));	
}

/*
=================
PF_vlen

scalar vlen(vector)
=================
*/
void PF_vlen (void)
{
	float	*value1;
	float	new;
	
	value1 = G_VECTOR(OFS_PARM0);

	new = value1[0] * value1[0] + value1[1] * value1[1] + value1[2]*value1[2];
	new = sqrt(new);
	
	G_FLOAT(OFS_RETURN) = new;
}

/*
=================
PF_vectoyaw

float vectoyaw(vector)
=================
*/
void PF_vectoyaw (void)
{
	float	*value1;
	float	yaw;
	
	value1 = G_VECTOR(OFS_PARM0);

	if (value1[1] == 0 && value1[0] == 0)
		yaw = 0;
	else
	{
		yaw = (int) (atan2(value1[1], value1[0]) * 180 / M_PI);
		if (yaw < 0)
			yaw += 360;
	}

	G_FLOAT(OFS_RETURN) = yaw;
}


/*
=================
PF_vectoangles

vector vectoangles(vector)
=================
*/
void PF_vectoangles (void)
{
	float	*value1;
	float	forward;
	float	yaw, pitch;
	
	value1 = G_VECTOR(OFS_PARM0);

	if (value1[1] == 0 && value1[0] == 0)
	{
		yaw = 0;
		if (value1[2] > 0)
			pitch = 90;
		else
			pitch = 270;
	}
	else
	{
		yaw = (int) (atan2(value1[1], value1[0]) * 180 / M_PI);
		if (yaw < 0)
			yaw += 360;

		forward = sqrt (value1[0]*value1[0] + value1[1]*value1[1]);
		pitch = (int) (atan2(value1[2], forward) * 180 / M_PI);
		if (pitch < 0)
			pitch += 360;
	}

	G_FLOAT(OFS_RETURN+0) = pitch;
	G_FLOAT(OFS_RETURN+1) = yaw;
	G_FLOAT(OFS_RETURN+2) = 0;
}

/*
=================
PF_Random

Returns a number from 0<= num < 1

random()
=================
*/
void PF_random (void)
{
	float		num;
		
	num = (rand ()&0x7fff) / ((float)0x7fff);
	
	G_FLOAT(OFS_RETURN) = num;
}


/*
=================
PF_ambientsound

=================
*/
void PF_ambientsound (void)
{
	char		**check;
	char		*samp;
	float		*pos;
	float 		vol, attenuation;
	int			i, soundnum;

	pos = G_VECTOR (OFS_PARM0);			
	samp = G_STRING(OFS_PARM1);
	vol = G_FLOAT(OFS_PARM2);
	attenuation = G_FLOAT(OFS_PARM3);
	
// check to see if samp was properly precached
	for (soundnum=0, check = sv.sound_precache ; *check ; check++, soundnum++)
		if (!strcmp(*check,samp))
			break;
			
	if (!*check)
	{
		Con_Printf ("no precache: %s\n", samp);
		return;
	}

// add an svc_spawnambient command to the level signon packet

	MSG_WriteByte (&sv.signon,svc_spawnstaticsound);
	for (i=0 ; i<3 ; i++)
		MSG_WriteCoord(&sv.signon, pos[i]);

	MSG_WriteByte (&sv.signon, soundnum);

	MSG_WriteByte (&sv.signon, vol*255);
	MSG_WriteByte (&sv.signon, attenuation*64);

}

/*
=================
PF_sound

Each entity can have eight independant sound sources, like voice,
weapon, feet, etc.

Channel 0 is an auto-allocate channel, the others override anything
allready running on that entity/channel pair.

An attenuation of 0 will play full volume everywhere in the level.
Larger attenuations will drop off.

=================
*/
void PF_sound (void)
{
	char		*sample;
	int			channel;
	edict_t		*entity;
	int 		volume;
	float attenuation;
		
	entity = G_EDICT(OFS_PARM0);
	channel = G_FLOAT(OFS_PARM1);
	sample = G_STRING(OFS_PARM2);
	volume = G_FLOAT(OFS_PARM3) * 255;
	attenuation = G_FLOAT(OFS_PARM4);
	
	SV_StartSound (entity, channel, sample, volume, attenuation);
}

/*
=================
PF_break

break()
=================
*/
void PF_break (void)
{
Con_Printf ("break statement\n");
*(int *)-4 = 0;	// dump to debugger
//	PR_RunError ("break statement");
}

/*
=================
PF_traceline

Used for use tracing and shot targeting
Traces are blocked by bbox and exact bsp entityes, and also slide box entities
if the tryents flag is set.

traceline (vector1, vector2, tryents)
=================
*/
void PF_traceline (void)
{
	float	*v1, *v2;
	trace_t	trace;
	int		nomonsters;
	edict_t	*ent;

	v1 = G_VECTOR(OFS_PARM0);
	v2 = G_VECTOR(OFS_PARM1);
	nomonsters = G_FLOAT(OFS_PARM2);
	ent = G_EDICT(OFS_PARM3);

	trace = SV_Move (v1, vec3_origin, vec3_origin, v2, nomonsters, ent);

	pr_global_struct->trace_allsolid = trace.allsolid;
	pr_global_struct->trace_startsolid = trace.startsolid;
	pr_global_struct->trace_fraction = trace.fraction;
	pr_global_struct->trace_inwater = trace.inwater;
	pr_global_struct->trace_inopen = trace.inopen;
	VectorCopy (trace.endpos, pr_global_struct->trace_endpos);
	VectorCopy (trace.plane.normal, pr_global_struct->trace_plane_normal);
	pr_global_struct->trace_plane_dist =  trace.plane.dist;	
	if (trace.ent)
		pr_global_struct->trace_ent = EDICT_TO_PROG(trace.ent);
	else
		pr_global_struct->trace_ent = EDICT_TO_PROG(sv.edicts);
}

/*
=================
PF_checkpos

Returns true if the given entity can move to the given position from it's
current position by walking or rolling.
FIXME: make work...
scalar checkpos (entity, vector)
=================
*/
void PF_checkpos (void)
{
}

//============================================================================

byte	checkpvs[MAX_MAP_LEAFS/8];

int PF_newcheckclient (int check)
{
	int		i;
	byte	*pvs;
	edict_t	*ent;
	mleaf_t	*leaf;
	vec3_t	org;

// cycle to the next one

	if (check < 1)
		check = 1;
	if (check > MAX_CLIENTS)
		check = MAX_CLIENTS;

	if (check == MAX_CLIENTS)
		i = 1;
	else
		i = check + 1;

	for ( ;  ; i++)
	{
		if (i == MAX_CLIENTS+1)
			i = 1;

		ent = EDICT_NUM(i);

		if (i == check)
			break;	// didn't find anything else

		if (ent->free)
			continue;
		if (ent->v.health <= 0)
			continue;
		if ((int)ent->v.flags & FL_NOTARGET)
			continue;

	// anything that is a client, or has a client as an enemy
		break;
	}

// get the PVS for the entity
	VectorAdd (ent->v.origin, ent->v.view_ofs, org);
	leaf = Mod_PointInLeaf (org, sv.worldmodel);
	pvs = Mod_LeafPVS (leaf, sv.worldmodel);
	memcpy (checkpvs, pvs, (sv.worldmodel->numleafs+7)>>3 );

	return i;
}

/*
=================
PF_checkclient

Returns a client (or object that has a client enemy) that would be a
valid target.

If there are more than one valid options, they are cycled each frame

If (self.origin + self.viewofs) is not in the PVS of the current target,
it is not returned at all.

name checkclient ()
=================
*/
#define	MAX_CHECK	16
int c_invis, c_notvis;
void PF_checkclient (void)
{
	edict_t	*ent, *self;
	mleaf_t	*leaf;
	int		l;
	vec3_t	view;
	
// find a new check if on a new frame
	if (sv.time - sv.lastchecktime >= 0.1)
	{
		sv.lastcheck = PF_newcheckclient (sv.lastcheck);
		sv.lastchecktime = sv.time;
	}

// return check if it might be visible	
	ent = EDICT_NUM(sv.lastcheck);
	if (ent->free || ent->v.health <= 0)
	{
		RETURN_EDICT(sv.edicts);
		return;
	}

// if current entity can't possibly see the check entity, return 0
	self = PROG_TO_EDICT(pr_global_struct->self);
	VectorAdd (self->v.origin, self->v.view_ofs, view);
	leaf = Mod_PointInLeaf (view, sv.worldmodel);
	l = (leaf - sv.worldmodel->leafs) - 1;
	if ( (l<0) || !(checkpvs[l>>3] & (1<<(l&7)) ) )
	{
c_notvis++;
		RETURN_EDICT(sv.edicts);
		return;
	}

// might be able to see it
c_invis++;
	RETURN_EDICT(ent);
}

//============================================================================


/*
=================
PF_stuffcmd

Sends text over to the client's execution buffer

stuffcmd (clientent, value)
=================
*/
void PF_stuffcmd (void)
{
	int		entnum;
	char	*str;
	client_t	*cl;
	
	entnum = G_EDICTNUM(OFS_PARM0);
	if (entnum < 1 || entnum > MAX_CLIENTS)
		PR_RunError ("Parm 0 not a client");
	str = G_STRING(OFS_PARM1);	
	
	cl = &svs.clients[entnum-1];

	if (strcmp(str, "disconnect\n") == 0) {
		// so long and thanks for all the fish
		cl->drop = true;
		return;
	}

	ClientReliableWrite_Begin (cl, svc_stufftext, 2+strlen(str));
	ClientReliableWrite_String (cl, str);
}

/*
=================
PF_localcmd

Sends text over to the client's execution buffer

localcmd (string)
=================
*/
void PF_localcmd (void)
{
	char	*str;
	
	str = G_STRING(OFS_PARM0);	
	Cbuf_AddText (str);
}

/*
=================
PF_cvar

float cvar (string)
=================
*/
void PF_cvar (void)
{
	char	*str;
	
	str = G_STRING(OFS_PARM0);
	
	G_FLOAT(OFS_RETURN) = Cvar_VariableValue (str);
}

/*
=================
PF_cvar_set

float cvar (string)
=================
*/
void PF_cvar_set (void)
{
	char	*var, *val;
	
	var = G_STRING(OFS_PARM0);
	val = G_STRING(OFS_PARM1);
	
	Cvar_Set (var, val);
}

/*
=================
PF_findradius

Returns a chain of entities that have origins within a spherical area

findradius (origin, radius)
=================
*/
void PF_findradius (void)
{
	edict_t	*ent, *chain;
	float	rad;
	float	*org;
	vec3_t	eorg;
	int		i, j;

	chain = (edict_t *)sv.edicts;
	
	org = G_VECTOR(OFS_PARM0);
	rad = G_FLOAT(OFS_PARM1);

	ent = NEXT_EDICT(sv.edicts);
	for (i=1 ; i<sv.num_edicts ; i++, ent = NEXT_EDICT(ent))
	{
		if (ent->free)
			continue;                 //OfN Below, if FINDABLE_NONSOLID flag is set
		if (ent->v.solid == SOLID_NOT && !((int)ent->v.flags & FL_FINDABLE_NONSOLID))
			continue;
		for (j=0 ; j<3 ; j++)
			eorg[j] = org[j] - (ent->v.origin[j] + (ent->v.mins[j] + ent->v.maxs[j])*0.5);			
		if (Length(eorg) > rad)
			continue;
			
		ent->v.chain = EDICT_TO_PROG(chain);
		chain = ent;
	}

	RETURN_EDICT(chain);
}


/*
=========
PF_dprint
=========
*/
void PF_dprint (void)
{
	Con_Printf ("%s",PF_VarString(0));
}

// OfN - Added a define
//#define PR_STRING_TEMP_LEN 256
#define PR_STRING_TEMP_LEN MAX_BUFFER_STRINGS_LEN //<-- Need to be the same!

char	pr_string_temp[PR_STRING_TEMP_LEN];

/*  OfN - Made it multi-buffer capable (see below)
void PF_ftos (void)
{
	float	v;
	v = G_FLOAT(OFS_PARM0);
	
	if (v == (int)v)
		sprintf (pr_string_temp, "%d",(int)v);
	else
		sprintf (pr_string_temp, "%5.1f",v);
	G_INT(OFS_RETURN) = PR_SetString(pr_string_temp);
}*/


void PF_fabs (void)
{
	float	v;
	v = G_FLOAT(OFS_PARM0);
	G_FLOAT(OFS_RETURN) = fabs(v);
}

void PF_vtos (void)
{
	sprintf (pr_string_temp, "'%5.1f %5.1f %5.1f'", G_VECTOR(OFS_PARM0)[0], G_VECTOR(OFS_PARM0)[1], G_VECTOR(OFS_PARM0)[2]);
	G_INT(OFS_RETURN) = PR_SetString(pr_string_temp);
}

void PF_Spawn (void)
{
	edict_t	*ed;
	ed = ED_Alloc();
	RETURN_EDICT(ed);
}

void PF_Remove (void)
{
	edict_t	*ed;
	
	ed = G_EDICT(OFS_PARM0);
	ED_Free (ed);
}


// entity (entity start, .string field, string match) find = #5;
void PF_Find (void)
{
	int		e;	
	int		f;
	char	*s, *t;
	edict_t	*ed;
	
	e = G_EDICTNUM(OFS_PARM0);
	f = G_INT(OFS_PARM1);
	s = G_STRING(OFS_PARM2);
	if (!s)
		PR_RunError ("PF_Find: bad search string");
		
	for (e++ ; e < sv.num_edicts ; e++)
	{
		ed = EDICT_NUM(e);
		if (ed->free)
			continue;
		t = E_STRING(ed,f);
		if (!t)
			continue;
		if (!strcmp(t,s))
		{
			RETURN_EDICT(ed);
			return;
		}
	}
	
	RETURN_EDICT(sv.edicts);
}

void PR_CheckEmptyString (char *s)
{
	if (s[0] <= ' ')
		PR_RunError ("Bad string");
}

void PF_precache_file (void)
{	// precache_file is only used to copy files with qcc, it does nothing
	G_INT(OFS_RETURN) = G_INT(OFS_PARM0);
}

void PF_precache_sound (void)
{
	char	*s;
	int		i;
	
	if (sv.state != ss_loading)
		PR_RunError ("PF_Precache_*: Precache can only be done in spawn functions");
		
	s = G_STRING(OFS_PARM0);
	G_INT(OFS_RETURN) = G_INT(OFS_PARM0);
	PR_CheckEmptyString (s);
	
	for (i=0 ; i<MAX_SOUNDS ; i++)
	{
		if (!sv.sound_precache[i])
		{
			sv.sound_precache[i] = s;
			return;
		}
		if (!strcmp(sv.sound_precache[i], s))
			return;
	}
	PR_RunError ("PF_precache_sound: overflow");
}

void PF_precache_model (void)
{
	char	*s;
	int		i;
	
	if (sv.state != ss_loading)
		PR_RunError ("PF_Precache_*: Precache can only be done in spawn functions");
		
	s = G_STRING(OFS_PARM0);
	G_INT(OFS_RETURN) = G_INT(OFS_PARM0);
	PR_CheckEmptyString (s);

	for (i=0 ; i<MAX_MODELS ; i++)
	{
		if (!sv.model_precache[i])
		{
			sv.model_precache[i] = s;
			return;
		}
		if (!strcmp(sv.model_precache[i], s))
			return;
	}
	PR_RunError ("PF_precache_model: overflow");
}


void PF_coredump (void)
{
	ED_PrintEdicts ();
}

void PF_traceon (void)
{
	pr_trace = true;
}

void PF_traceoff (void)
{
	pr_trace = false;
}

void PF_eprint (void)
{
	ED_PrintNum (G_EDICTNUM(OFS_PARM0));
}

/*
===============
PF_walkmove

float(float yaw, float dist) walkmove
===============
*/
void PF_walkmove (void)
{
	edict_t	*ent;
	float	yaw, dist;
	vec3_t	move;
	dfunction_t	*oldf;
	int 	oldself;
	
	ent = PROG_TO_EDICT(pr_global_struct->self);
	yaw = G_FLOAT(OFS_PARM0);
	dist = G_FLOAT(OFS_PARM1);
	
	if ( !( (int)ent->v.flags & (FL_ONGROUND|FL_FLY|FL_SWIM) ) )
	{
		G_FLOAT(OFS_RETURN) = 0;
		return;
	}

	yaw = yaw*M_PI*2 / 360;
	
	move[0] = cos(yaw)*dist;
	move[1] = sin(yaw)*dist;
	move[2] = 0;

// save program state, because SV_movestep may call other progs
	oldf = pr_xfunction;
	oldself = pr_global_struct->self;
	
	G_FLOAT(OFS_RETURN) = SV_movestep(ent, move, true);
	
	
// restore program state
	pr_xfunction = oldf;
	pr_global_struct->self = oldself;
}

/*
===============
PF_droptofloor

void() droptofloor
===============
*/
void PF_droptofloor (void)
{
	edict_t		*ent;
	vec3_t		end;
	trace_t		trace;
	
	ent = PROG_TO_EDICT(pr_global_struct->self);

	VectorCopy (ent->v.origin, end);
	end[2] -= 256;
	
	trace = SV_Move (ent->v.origin, ent->v.mins, ent->v.maxs, end, false, ent);

	if (trace.fraction == 1 || trace.allsolid)
		G_FLOAT(OFS_RETURN) = 0;
	else
	{
		VectorCopy (trace.endpos, ent->v.origin);
		SV_LinkEdict (ent, false);
		ent->v.flags = (int)ent->v.flags | FL_ONGROUND;
		ent->v.groundentity = EDICT_TO_PROG(trace.ent);
		G_FLOAT(OFS_RETURN) = 1;
	}
}

/*
===============
PF_lightstyle

void(float style, string value) lightstyle
===============
*/
void PF_lightstyle (void)
{
	int		style;
	char	*val;
	client_t	*client;
	int			j;
	
	style = G_FLOAT(OFS_PARM0);
	val = G_STRING(OFS_PARM1);

// change the string in sv
	sv.lightstyles[style] = val;
	
// send message to all clients on this server
	if (sv.state != ss_active)
		return;
	
	for (j=0, client = svs.clients ; j<MAX_CLIENTS ; j++, client++)
		if ( client->state == cs_spawned )
		{
			ClientReliableWrite_Begin (client, svc_lightstyle, strlen(val)+3);
			ClientReliableWrite_Char (client, style);
			ClientReliableWrite_String (client, val);
		}
}

void PF_rint (void)
{
	float	f;
	f = G_FLOAT(OFS_PARM0);
	if (f > 0)
		G_FLOAT(OFS_RETURN) = (int)(f + 0.5);
	else
		G_FLOAT(OFS_RETURN) = (int)(f - 0.5);
}
void PF_floor (void)
{
	G_FLOAT(OFS_RETURN) = floor(G_FLOAT(OFS_PARM0));
}
void PF_ceil (void)
{
	G_FLOAT(OFS_RETURN) = ceil(G_FLOAT(OFS_PARM0));
}


/*
=============
PF_checkbottom
=============
*/
void PF_checkbottom (void)
{
	edict_t	*ent;
	
	ent = G_EDICT(OFS_PARM0);

	G_FLOAT(OFS_RETURN) = SV_CheckBottom (ent);
}

/*
=============
PF_pointcontents
=============
*/
void PF_pointcontents (void)
{
	float	*v;
	
	v = G_VECTOR(OFS_PARM0);

	G_FLOAT(OFS_RETURN) = SV_PointContents (v);	
}

/*
=============
PF_nextent

entity nextent(entity)
=============
*/
void PF_nextent (void)
{
	int		i;
	edict_t	*ent;
	
	i = G_EDICTNUM(OFS_PARM0);
	while (1)
	{
		i++;
		if (i == sv.num_edicts)
		{
			RETURN_EDICT(sv.edicts);
			return;
		}
		ent = EDICT_NUM(i);
		if (!ent->free)
		{
			RETURN_EDICT(ent);
			return;
		}
	}
}

/*
=============
PF_aim

Pick a vector for the player to shoot along
vector aim(entity, missilespeed)
=============
*/
//cvar_t	sv_aim = {"sv_aim", "0.93"};
cvar_t	sv_aim = {"sv_aim", "2"};
void PF_aim (void)
{
	edict_t	*ent, *check, *bestent;
	vec3_t	start, dir, end, bestdir;
	int		i, j;
	trace_t	tr;
	float	dist, bestdist;
	float	speed;
	char	*noaim;

	ent = G_EDICT(OFS_PARM0);
	speed = G_FLOAT(OFS_PARM1);

	VectorCopy (ent->v.origin, start);
	start[2] += 20;

// noaim option
	i = NUM_FOR_EDICT(ent);
	if (i>0 && i<MAX_CLIENTS)
	{
		noaim = Info_ValueForKey (svs.clients[i-1].userinfo, "noaim");
		if (atoi(noaim) > 0)
		{
			VectorCopy (pr_global_struct->v_forward, G_VECTOR(OFS_RETURN));
			return;
		}
	}

// try sending a trace straight
	VectorCopy (pr_global_struct->v_forward, dir);
	VectorMA (start, 2048, dir, end);
	tr = SV_Move (start, vec3_origin, vec3_origin, end, false, ent);
	if (tr.ent && tr.ent->v.takedamage == DAMAGE_AIM
	&& (!teamplay.value || ent->v.team <=0 || ent->v.team != tr.ent->v.team) )
	{
		VectorCopy (pr_global_struct->v_forward, G_VECTOR(OFS_RETURN));
		return;
	}


// try all possible entities
	VectorCopy (dir, bestdir);
	bestdist = sv_aim.value;
	bestent = NULL;
	
	check = NEXT_EDICT(sv.edicts);
	for (i=1 ; i<sv.num_edicts ; i++, check = NEXT_EDICT(check) )
	{
		if (check->v.takedamage != DAMAGE_AIM)
			continue;
		if (check == ent)
			continue;
		if (teamplay.value && ent->v.team > 0 && ent->v.team == check->v.team)
			continue;	// don't aim at teammate
		for (j=0 ; j<3 ; j++)
			end[j] = check->v.origin[j]
			+ 0.5*(check->v.mins[j] + check->v.maxs[j]);
		VectorSubtract (end, start, dir);
		VectorNormalize (dir);
		dist = DotProduct (dir, pr_global_struct->v_forward);
		if (dist < bestdist)
			continue;	// to far to turn
		tr = SV_Move (start, vec3_origin, vec3_origin, end, false, ent);
		if (tr.ent == check)
		{	// can shoot at this one
			bestdist = dist;
			bestent = check;
		}
	}
	
	if (bestent)
	{
		VectorSubtract (bestent->v.origin, ent->v.origin, dir);
		dist = DotProduct (dir, pr_global_struct->v_forward);
		VectorScale (pr_global_struct->v_forward, dist, end);
		end[2] = dir[2];
		VectorNormalize (end);
		VectorCopy (end, G_VECTOR(OFS_RETURN));	
	}
	else
	{
		VectorCopy (bestdir, G_VECTOR(OFS_RETURN));
	}
}

/*
==============
PF_changeyaw

This was a major timewaster in progs, so it was converted to C
==============
*/
void PF_changeyaw (void)
{
	edict_t		*ent;
	float		ideal, current, move, speed;
	
	ent = PROG_TO_EDICT(pr_global_struct->self);
	current = anglemod( ent->v.angles[1] );
	ideal = ent->v.ideal_yaw;
	speed = ent->v.yaw_speed;
	
	if (current == ideal)
		return;
	move = ideal - current;
	if (ideal > current)
	{
		if (move >= 180)
			move = move - 360;
	}
	else
	{
		if (move <= -180)
			move = move + 360;
	}
	if (move > 0)
	{
		if (move > speed)
			move = speed;
	}
	else
	{
		if (move < -speed)
			move = -speed;
	}
	
	ent->v.angles[1] = anglemod (current + move);
}

/*
===============================================================================

MESSAGE WRITING

===============================================================================
*/

#define	MSG_BROADCAST	0		// unreliable to all
#define	MSG_ONE			1		// reliable to one (msg_entity)
#define	MSG_ALL			2		// reliable to all
#define	MSG_INIT		3		// write to the init string
#define	MSG_MULTICAST	4		// for multicast()

sizebuf_t *WriteDest (void)
{
	//int		entnum;
	int		dest;
	//edict_t	*ent;

	dest = G_FLOAT(OFS_PARM0);
	switch (dest)
	{
	case MSG_BROADCAST:
		return &sv.datagram;
	
	case MSG_ONE:
		SV_Error("Shouldn't be at MSG_ONE");
#if 0
		ent = PROG_TO_EDICT(pr_global_struct->msg_entity);
		entnum = NUM_FOR_EDICT(ent);
		if (entnum < 1 || entnum > MAX_CLIENTS)
			PR_RunError ("WriteDest: not a client");
		return &svs.clients[entnum-1].netchan.message;
#endif
		
	case MSG_ALL:
		return &sv.reliable_datagram;
	
	case MSG_INIT:
		if (sv.state != ss_loading)
			PR_RunError ("PF_Write_*: MSG_INIT can only be written in spawn functions");
		return &sv.signon;

	case MSG_MULTICAST:
		return &sv.multicast;

	default:
		PR_RunError ("WriteDest: bad destination");
		break;
	}
	
	return NULL;
}

static client_t *Write_GetClient(void)
{
	int		entnum;
	edict_t	*ent;

	ent = PROG_TO_EDICT(pr_global_struct->msg_entity);
	entnum = NUM_FOR_EDICT(ent);
	if (entnum < 1 || entnum > MAX_CLIENTS)
		PR_RunError ("WriteDest: not a client");
	return &svs.clients[entnum-1];
}


void PF_WriteByte (void)
{
	if (G_FLOAT(OFS_PARM0) == MSG_ONE) {
		client_t *cl = Write_GetClient();
		ClientReliableCheckBlock(cl, 1);
		ClientReliableWrite_Byte(cl, G_FLOAT(OFS_PARM1));
	} else
		MSG_WriteByte (WriteDest(), G_FLOAT(OFS_PARM1));
}

void PF_WriteChar (void)
{
	if (G_FLOAT(OFS_PARM0) == MSG_ONE) {
		client_t *cl = Write_GetClient();
		ClientReliableCheckBlock(cl, 1);
		ClientReliableWrite_Char(cl, G_FLOAT(OFS_PARM1));
	} else
		MSG_WriteChar (WriteDest(), G_FLOAT(OFS_PARM1));
}

void PF_WriteShort (void)
{
	if (G_FLOAT(OFS_PARM0) == MSG_ONE) {
		client_t *cl = Write_GetClient();
		ClientReliableCheckBlock(cl, 2);
		ClientReliableWrite_Short(cl, G_FLOAT(OFS_PARM1));
	} else
		MSG_WriteShort (WriteDest(), G_FLOAT(OFS_PARM1));
}

void PF_WriteLong (void)
{
	if (G_FLOAT(OFS_PARM0) == MSG_ONE) {
		client_t *cl = Write_GetClient();
		ClientReliableCheckBlock(cl, 4);
		ClientReliableWrite_Long(cl, G_FLOAT(OFS_PARM1));
	} else
		MSG_WriteLong (WriteDest(), G_FLOAT(OFS_PARM1));
}

void PF_WriteAngle (void)
{
	if (G_FLOAT(OFS_PARM0) == MSG_ONE) {
		client_t *cl = Write_GetClient();
		ClientReliableCheckBlock(cl, 1);
		ClientReliableWrite_Angle(cl, G_FLOAT(OFS_PARM1));
	} else
		MSG_WriteAngle (WriteDest(), G_FLOAT(OFS_PARM1));
}

void PF_WriteCoord (void)
{
	if (G_FLOAT(OFS_PARM0) == MSG_ONE) {
		client_t *cl = Write_GetClient();
		ClientReliableCheckBlock(cl, 2);
		ClientReliableWrite_Coord(cl, G_FLOAT(OFS_PARM1));
	} else
		MSG_WriteCoord (WriteDest(), G_FLOAT(OFS_PARM1));
}

void PF_WriteString (void)
{
	if (G_FLOAT(OFS_PARM0) == MSG_ONE) {
		client_t *cl = Write_GetClient();
		ClientReliableCheckBlock(cl, 1+strlen(G_STRING(OFS_PARM1)));
		ClientReliableWrite_String(cl, G_STRING(OFS_PARM1));
	} else
		MSG_WriteString (WriteDest(), G_STRING(OFS_PARM1));
}


void PF_WriteEntity (void)
{
	if (G_FLOAT(OFS_PARM0) == MSG_ONE) {
		client_t *cl = Write_GetClient();
		ClientReliableCheckBlock(cl, 2);
		ClientReliableWrite_Short(cl, G_EDICTNUM(OFS_PARM1));
	} else
		MSG_WriteShort (WriteDest(), G_EDICTNUM(OFS_PARM1));
}

//=============================================================================

int SV_ModelIndex (char *name);

void PF_makestatic (void)
{
	edict_t	*ent;
	int		i;
	
	ent = G_EDICT(OFS_PARM0);

	MSG_WriteByte (&sv.signon,svc_spawnstatic);

	MSG_WriteByte (&sv.signon, SV_ModelIndex(PR_GetString(ent->v.model)));

	MSG_WriteByte (&sv.signon, ent->v.frame);
	MSG_WriteByte (&sv.signon, ent->v.colormap);
	MSG_WriteByte (&sv.signon, ent->v.skin);
	for (i=0 ; i<3 ; i++)
	{
		MSG_WriteCoord(&sv.signon, ent->v.origin[i]);
		MSG_WriteAngle(&sv.signon, ent->v.angles[i]);
	}

// throw the entity away now
	ED_Free (ent);
}

//=============================================================================

/*
==============
PF_setspawnparms
==============
*/
void PF_setspawnparms (void)
{
	edict_t	*ent;
	int		i;
	client_t	*client;

	ent = G_EDICT(OFS_PARM0);
	i = NUM_FOR_EDICT(ent);
	if (i < 1 || i > MAX_CLIENTS)
		PR_RunError ("Entity is not a client");

	// copy spawn parms out of the client_t
	client = svs.clients + (i-1);

	for (i=0 ; i< NUM_SPAWN_PARMS ; i++)
		(&pr_global_struct->parm1)[i] = client->spawn_parms[i];
}

/*
==============
PF_changelevel
==============
*/
void PF_changelevel (void)
{
	char	*s;
	static	int	last_spawncount;

// make sure we don't issue two changelevels
	if (svs.spawncount == last_spawncount)
		return;
	last_spawncount = svs.spawncount;
	
	s = G_STRING(OFS_PARM0);
	Cbuf_AddText (va("map %s\n",s));
}


/*
==============
PF_logfrag

logfrag (killer, killee)
==============
*/
void PF_logfrag (void)
{
	edict_t	*ent1, *ent2;
	int		e1, e2;
	char	*s;

	ent1 = G_EDICT(OFS_PARM0);
	ent2 = G_EDICT(OFS_PARM1);

	e1 = NUM_FOR_EDICT(ent1);
	e2 = NUM_FOR_EDICT(ent2);
	
	if (e1 < 1 || e1 > MAX_CLIENTS
	|| e2 < 1 || e2 > MAX_CLIENTS)
		return;
	
	s = va("\\%s\\%s\\\n",svs.clients[e1-1].name, svs.clients[e2-1].name);

	SZ_Print (&svs.log[svs.logsequence&1], s);
	if (sv_fraglogfile) {
		fprintf (sv_fraglogfile, s);
		fflush (sv_fraglogfile);
	}
}


/*
==============
PF_infokey

string(entity e, string key) infokey
==============
*/
void PF_infokey (void)
{
	edict_t	*e;
	int		e1;
	char	*value;
	char	*key;
	static	char ov[256];

	e = G_EDICT(OFS_PARM0);
	e1 = NUM_FOR_EDICT(e);
	key = G_STRING(OFS_PARM1);

	if (e1 == 0) {
		if ((value = Info_ValueForKey (svs.info, key)) == NULL ||
			!*value)
			value = Info_ValueForKey(localinfo, key);
	} else if (e1 <= MAX_CLIENTS) {
		if (!strcmp(key, "ip"))
			value = strcpy(ov, NET_BaseAdrToString (svs.clients[e1-1].netchan.remote_address));
		else if (!strcmp(key, "ping")) {
			int ping = SV_CalcPing (&svs.clients[e1-1]);
			sprintf(ov, "%d", ping);
			value = ov;
		} else
			value = Info_ValueForKey (svs.clients[e1-1].userinfo, key);
	} else
		value = "";

	RETURN_STRING(value);
}

/*
==============
PF_stof

float(string s) stof
==============
*/
void PF_stof (void)
{
	char	*s;

	s = G_STRING(OFS_PARM0);

	G_FLOAT(OFS_RETURN) = atof(s);
}


/*
==============
PF_multicast

void(vector where, float set) multicast
==============
*/
void PF_multicast (void)
{
	float	*o;
	int		to;

	o = G_VECTOR(OFS_PARM0);
	to = G_FLOAT(OFS_PARM1);

	SV_Multicast (o, to);
}

//=====================================================
// OfN - Built-in functions added for prozac

/*
=====================
Extra string buffer functions
Added to be able to use several string return values from
functions on progs (for a single centerprint for example)
=====================
*/

char* GetNewStringBuffer()
{
	int i;
	for (i = 0; i < MAX_BUFFER_STRINGS; i++)
	{
		if (!ProgsStringsBuffer[i].isUsed)
		{
			ProgsStringsBuffer[i].isUsed = true;
			ProgsStringsBuffer[i].OwnerFunction = pr_xfunction;
			ProgsStringsBuffer[i].str[0]='\0';
						
			// increase our counter
			NumStrBuffersUsed++;
			
			// return it..			
			return ProgsStringsBuffer[i].str;
		}
	}	

	Con_Printf("WARNING: String buffers limit reached!\n");
	
	return pr_string_temp;
}

/*char* UseStringBuffer(char* thestring)
{
	int i;
	qboolean had_error;

	had_error = false;
	
	// check if given string exceeds our max len
	if (Q_strlen(thestring) > MAX_BUFFER_STRINGS_LEN - 2)
		had_error = true;

	for (i = 0; i < MAX_BUFFER_STRINGS; i++)
	{
		if (!ProgsStringsBuffer[i].isUsed)
		{
			ProgsStringsBuffer[i].isUsed = true;
			ProgsStringsBuffer[i].OwnerFunction = pr_xfunction;
			ProgsStringsBuffer[i].str[0]='\0';
			
			// copy given text into buffer
			if (had_error)
				Q_strcpy(thestring,"String length too long on UseStringBuffer()");
			else
				Q_strcpy(ProgsStringsBuffer[i].str,thestring);
			
			// increase our counter
			NumStrBuffersUsed++;
			
			// string buffer ready! return it..			
			return ProgsStringsBuffer[i].str;
		}
	}	

	Con_Printf("WARNING: String buffers limit reached!\n");

	return thestring; // this is executed if no more room on our string buffers
}*/

// This one is executed on every funcion end (on PR_LeaveFunction)
// and clears any string buffers used by it

void CheckUnusedStrBuffers()
{
	int i;
	
	for (i = 0; i < MAX_BUFFER_STRINGS; i++)
	{
		if (ProgsStringsBuffer[i].isUsed)
		{
			if (ProgsStringsBuffer[i].OwnerFunction == pr_xfunction)
			{
				if (G_STRING(OFS_RETURN) == ProgsStringsBuffer[i].str)
					ProgsStringsBuffer[i].OwnerFunction = PR_GetReturningFunction();
				else
				{
					ProgsStringsBuffer[i].isUsed = false;
					ProgsStringsBuffer[i].OwnerFunction = NULL;
					NumStrBuffersUsed--;
				}

				if (NumStrBuffersUsed == 0)
					return;
			}
		}
	}	
}

// This is called just on progs loading to reset all string buffers

void ResetStrBuffers()
{
	int i;
	
	for (i = 0; i < MAX_BUFFER_STRINGS; i++)
	{
		ProgsStringsBuffer[i].isUsed = false;
		ProgsStringsBuffer[i].OwnerFunction = NULL;
		ProgsStringsBuffer[i].str[0]='\0';
	}

	NumStrBuffersUsed = 0;
}

//============================================================
// The folling functions manage "permanent" strings on progs
// Any string can be made permanent by using makestr()
// Every makestr() call should have a corresponding delstr()

char* UsePermString(char* thestring)
{
	int i;
	qboolean had_error;

	had_error = false;
	
	// check if given string exceeds our max len
	if (Q_strlen(thestring) > MAX_PERM_STRING_LEN - 2)
		had_error = true;

	for (i = 0; i < MAX_PERM_STRINGS; i++)
	{
		if (!ProgsPermString[i].isUsed)
		{
			ProgsPermString[i].isUsed = true;
			ProgsPermString[i].str[0]='\0';
			
			// copy given text into buffer
			if (had_error)
				Q_strcpy(thestring,"String too long for perm buffer!");
			else
				Q_strcpy(ProgsPermString[i].str,thestring);
			
			// string ready! return it..			
			return ProgsPermString[i].str;
		}
	}	

	Con_Printf("WARNING: Permanent string buffer limit reached!\n");

	return thestring; // this is executed if no more room on our string buffers
}

void RemovePermString(char* thestring)
{
	int i;

	for (i=0; i < MAX_PERM_STRINGS; i++)
	{
		if (thestring == ProgsPermString[i].str)
		{
			ProgsPermString[i].isUsed = false;
			ProgsPermString[i].str[0]='\0';
			return;
		}
	}

	Con_Printf("WARNING: Unmatched permanent string on removal!\n");
}

void ResetPermStrings()
{
	int i;
	
	for (i = 0; i < MAX_PERM_STRINGS; i++)
	{
		ProgsPermString[i].isUsed = false;		
		ProgsPermString[i].str[0]='\0';
	}
}

/*
=============
Modified ftos() to make it use our new string buffers
=============
*/

void PF_ftos (void)
{
	float	v;
	char* result;

	v = G_FLOAT(OFS_PARM0);

	result = GetNewStringBuffer();
	
	if (v == (int)v)
		sprintf (result, "%d",(int)v);
	else
		sprintf (result, "%5.1f",v);
		
	G_INT(OFS_RETURN) = PR_SetString(result);
}

/*
==============
PF_getuid

float(entity client) getuid
==============
*/

void PF_getuid(void)
{
	edict_t* client_ent;
	int e_num;

	float retval = 0;
	
	client_ent = G_EDICT(OFS_PARM0);
	e_num = NUM_FOR_EDICT(client_ent);

	if (e_num <= MAX_CLIENTS && e_num >= 1)
		retval = (float)svs.clients[e_num-1].userid;
	
	G_FLOAT(OFS_RETURN) = retval;
}

/*
==============
PF_strcat

string(string st1, string st2) strcat
==============
*/

void PF_strcat(void)
{
	char *st1;
	char *st2;
	
	char* result;

	st1 = G_STRING(OFS_PARM0);
	st2 = G_STRING(OFS_PARM1);

	result = GetNewStringBuffer();

	if (Q_strlen(st1)+Q_strlen(st2) > MAX_BUFFER_STRINGS_LEN - 2)
		Q_strcpy(result,"String too long for strcat()");
	else
		sprintf (result, "%s%s", st1, st2);

	G_INT(OFS_RETURN) = PR_SetString(result);	
}

/*
==============
PF_padstr

string(string st, float len) padstr
==============
*/

void PF_padstr(void)
{
	char *st;
	unsigned int i, padlen, givenlen;
	char* result;
		
	st = G_STRING(OFS_PARM0);
	padlen = (unsigned int)G_FLOAT(OFS_PARM1);
	givenlen = Q_strlen(st);

	// Check if nothing should be done due to error or no need to..
	if ( (givenlen > MAX_BUFFER_STRINGS_LEN -2) || // given string cant fit in our buffer
		 (padlen > MAX_BUFFER_STRINGS_LEN -2) || // specified padding is beyond allowed len for buffer
		 (padlen <= givenlen)) // nothing should be done
	{
		G_INT(OFS_RETURN) = PR_SetString(st); // return given string
		return;
	}

	// ok, lets pad it!
	result = GetNewStringBuffer();
	Q_strcpy(result,st);

	for (i = givenlen; i < padlen; i++)
		result[i]=' ';

	// set the NULL termination
	result[i]='\0';

	// done!
	G_INT(OFS_RETURN) = PR_SetString(result);	
}

/*
==============
PF_colstr

string(string srcstr, float action) colstr
==============
*/

// Possible action values
#define COLSTR_WHITE   0 // converts any red chars to white
#define COLSTR_MIX1    1 // mix red and white chars
#define COLSTR_RED     2 // converts any white chars to red
#define COLSTR_MIX2    3 // mix red and white chars
#define COLSTR_NUMBER  4 // converts any numbers to special number chars
#define COLSTR_NUMBERV 5 // second variant of special number chars (only different on some non-original charsets)

void PF_colstr (void)
{
	char* srcstr;
	char* result;
	unsigned int action, len, i;

	srcstr = G_STRING(OFS_PARM0);
	action = (unsigned int)G_FLOAT(OFS_PARM1);
	len = Q_strlen(srcstr);

	// Check for errors, if any, return given string
	if (len == 0 || len > MAX_BUFFER_STRINGS_LEN -2 || action > COLSTR_NUMBERV)
	{
		G_INT(OFS_RETURN) = PR_SetString(srcstr); // return given string
		return;
	}

	// Process string..
	result = GetNewStringBuffer();
	Q_strcpy(result,srcstr);

	switch (action)
	{
		case COLSTR_WHITE:
			
			for (i = 0; i < len; i++)
			{
				if ((unsigned char)result[i] > 160) // is red char
					result[i] -= 128;
			}
			
			break;

		case COLSTR_MIX1:
			
			for (i = 0; i < len; i++)
			{
				if (i & 0x01)
				{				
					if ((unsigned char)result[i] < 128 && (unsigned char)result[i] > 32) // is white char
						result[i] += 128;
				}
				else
				{
					if ((unsigned char)result[i] > 160) // is red char
						result[i] -= 128;
				}
			}
			
			break;

		case COLSTR_RED:
			
			for (i = 0; i < len; i++)
			{
				if ((unsigned char)result[i] < 128 && (unsigned char)result[i] > 32) // is white char
					result[i] += 128;
			}

			break;

		case COLSTR_MIX2:
			
			for (i = 0; i < len; i++)
			{
				if (i & 0x01)
				{				
					if ((unsigned char)result[i] > 160) // is red char
						result[i] -= 128;
				}
				else
				{
					if ((unsigned char)result[i] < 128 && (unsigned char)result[i] > 32) // is white char
						result[i] += 128;					
				}
			}

			break;
			
		case COLSTR_NUMBER:
			
			for (i = 0; i < len; i++)
			{
				if ((unsigned char)result[i] > 47 && (unsigned char)result[i] < 58) // is a white number 
					result[i] -= 30;
				/*else if ((unsigned char)pr_string_temp[i] > 175 && (unsigned char)pr_string_temp[i] < 186) // is a red number 
					pr_string_temp[i] -= 158;*/
			}

			break;

		case COLSTR_NUMBERV:
			
			for (i = 0; i < len; i++)
			{
				if ((unsigned char)result[i] > 47 && (unsigned char)result[i] < 58) // is a white number 
					result[i] += 98;
				/*else if ((unsigned char)pr_string_temp[i] > 175 && (unsigned char)pr_string_temp[i] < 186) // is a red number 
					pr_string_temp[i] -= 30;*/
			}
	}

	G_INT(OFS_RETURN) = PR_SetString(result);	
}

/*
==============
PF_strcasecmp

float(string st1, string st2) strcasecmp
==============
*/

void PF_strcasecmp (void)
{
	float retval;

	char *st1;
	char *st2;
	
	st1 = G_STRING(OFS_PARM0);
	st2 = G_STRING(OFS_PARM1);

	retval = (float)Q_strncasecmp(st1,st2,99999);
	
	G_FLOAT(OFS_RETURN) = retval;
}

/*
==============
PF_strlen

float(string st) strlen
==============
*/

void PF_strlen (void)
{
	float retval;

	char *st;
	
	st = G_STRING(OFS_PARM0);
	
	retval = (float)Q_strlen(st);
	
	G_FLOAT(OFS_RETURN) = retval;
}

/*
==============
PF_getclient

entity(string st) getclient
==============
*/

void PF_getclient (void)
{
	edict_t* ent;
	char *st;
	int i, uid;
	client_t *cl;
	
	st = G_STRING(OFS_PARM0);

	ent = (edict_t*)KK_Match_Str2(st);

	// no substring match?
	if (!ent) 
	{
		uid = atoi(st); // lets assume its an user id

		if (uid != 0) // was it even a number?
		{
			// then, lets see if a client with that userid is here
			for (i = 0, cl = svs.clients; i < MAX_CLIENTS && !ent; i++, cl++)
			{
				if (cl->userid == uid) // yeah, found it
					ent = cl->edict;				
			}
		}
	}
	
	// Failed retrieving an user by name and by userid, so return world
	if (!ent)
		ent = sv.edicts;
	
	RETURN_EDICT(ent);
}

/*
==============
PF_mutedtime

float(entity client) mutedtime
==============
*/

void PF_mutedtime (void)
{
	edict_t* client_ent;
	int e_num;

	float retval = 0;
	
	client_ent = G_EDICT(OFS_PARM0);
	e_num = NUM_FOR_EDICT(client_ent);

	if (e_num <= MAX_CLIENTS && e_num > 0)
	{
		if (realtime >= svs.clients[e_num-1].lockedtill)
			retval = (float)0;
		else
			retval = (float)svs.clients[e_num-1].lockedtill - realtime;		
	}
	
	G_FLOAT(OFS_RETURN) = retval;
}

/*
==============
PF_validatefile

float(string st) validatefile
==============
*/

void PF_validatefile (void)
{
	float retval;
	FILE	*f;
	char *st;
	
	st = G_STRING(OFS_PARM0);
		
	COM_FOpenFile (st, &f);
	if (!f)
		retval = (float)0;
	else
	{
		retval = (float)1;
		fclose (f);
	}	

	G_FLOAT(OFS_RETURN) = retval;
}

/*
==============
PF_putsaytime

void(entity client) putsaytime
==============
*/

extern int fp_messages, fp_persecond, fp_secondsdead;

void PF_putsaytime (void)
{
	edict_t* client_ent;
	int e_num, tmp;
	
	client_ent = G_EDICT(OFS_PARM0);
	e_num = NUM_FOR_EDICT(client_ent);

	if (e_num <= MAX_CLIENTS && e_num >= 1)
	{
		tmp = svs.clients[e_num-1].whensaidhead - fp_messages + 1;
		if (tmp < 0)
			tmp = 10+tmp;
		if (svs.clients[e_num-1].whensaid[tmp] && (realtime-svs.clients[e_num-1].whensaid[tmp] < fp_persecond))
		{
			svs.clients[e_num-1].lockedtill = realtime + fp_secondsdead;
			return;
		}

		svs.clients[e_num-1].whensaidhead++;
		if (svs.clients[e_num-1].whensaidhead > 9)
			svs.clients[e_num-1].whensaidhead = 0;
		svs.clients[e_num-1].whensaid[svs.clients[e_num-1].whensaidhead] = realtime;
	}
}

/*
==============
PF_makestr

string(string st) makestr
==============
*/

void PF_makestr (void)
{
	char *st;
	char *res;
	
	st = G_STRING(OFS_PARM0);

	res = UsePermString(st);
	
	G_INT(OFS_RETURN) = PR_SetString(res);
}

/*
==============
PF_delstr

void(string st) delstr
==============
*/

void PF_delstr (void)
{
	char *st;
	
	st = G_STRING(OFS_PARM0);

	RemovePermString(st);
}

/*
==============
PF_getwave

float(float inputnum, float modes, float minnum, float maxnum, float balance, float offset, float shape) getwave
==============
*/

float GetCircleWave (float inputnum)
{
	inputnum = inputnum - (int)inputnum;

	if (inputnum >= 0.75) // -1 to 0
	{
		if (inputnum == 0.75) return -1;

		inputnum = inputnum - 0.75;

		inputnum = inputnum * 4;

		return (1 - sqrt(1 - (inputnum*inputnum))) - 1;		
	}
	else if (inputnum >= 0.5) // 0 to -1
	{
		if (inputnum == 0.5) return 0;

		inputnum = inputnum - 0.5;

		inputnum = 0.25 - inputnum;			
		inputnum = inputnum * 4;

		return (1 - sqrt(1 - (inputnum*inputnum))) - 1;
	}
	else if (inputnum >= 0.25) // 1 to 0
	{
		if (inputnum == 0.25) return 1;

		inputnum = inputnum - 0.25;

		inputnum = inputnum * 4;

		return sqrt(1 - (inputnum*inputnum));		
	}
	else // 0 to 1
	{
		if (inputnum == 0) return 0;
		
		inputnum = 0.25 - inputnum;
		inputnum = inputnum * 4;		

		return sqrt(1- (inputnum*inputnum));		
	}

	return 0;
}

float GetLinearWave (float inputnum)
{
	inputnum = inputnum - (int)inputnum;

	if (inputnum <= 0.25)
		return inputnum / 0.25;
	else if (inputnum <= 0.5)
		return 1-((inputnum-0.25)/0.25);
	else if (inputnum <= 0.75)
		return - (inputnum-0.5)/0.25;
	else
		return -1 + (inputnum-0.75)/0.25;
	
	return 0;
}

// GetWave possible mode flags
#define GWAVE_STANDARD    0
#define GWAVE_USEMINMAX   1
#define GWAVE_USEBALANCE  2 // TODO: Unimplemented yet
#define GWAVE_USEOFFSET   4
#define GWAVE_USESHAPE    8

void PF_getwave (void)
{
	float retval, inputnum, minnum, maxnum, balance, offset, shape;
	float temp;

	unsigned int modes;

	inputnum = G_FLOAT(OFS_PARM0);

	modes = (unsigned int)G_FLOAT(OFS_PARM1);
			
	balance = G_FLOAT(OFS_PARM4);

	if (modes & GWAVE_USEOFFSET)
		offset = G_FLOAT(OFS_PARM5);
	else
		offset = 0;
	
	// Use special shape?
	if (modes & GWAVE_USESHAPE)
	{		
		shape = G_FLOAT(OFS_PARM6);
		
		if (shape >= -1 && shape <= 1 && shape != 0)
		{
			if (shape < 0) // sine/linear mix
			{
				if (shape == -1) // full linear
					retval = GetLinearWave(inputnum+offset);
				else
				{
					// Get standard sinus
					retval = sin(2*M_PI*(inputnum+offset));	
					
					temp = GetLinearWave(inputnum+offset);
					retval = (retval*(1-fabs(shape))) + (temp*fabs(shape));
				}
			}
			else // sine/circular mix
			{
				if (shape == 1) // full circular
					retval = GetCircleWave(inputnum+offset);
				else
				{
					// Get standard sinus
					retval = sin(2*M_PI*(inputnum+offset));	
					
					temp = GetCircleWave(inputnum+offset);
					retval = retval*(1-shape) + temp*shape;
				}
			}
		}
		else // 0 or invalid shape
		{
			// Get standard sinus
			retval = sin(2*M_PI*(inputnum+offset));	
		}
	}
	else // dont use shape then..
	{
		// Get standard sinus
		retval = sin(2*M_PI*(inputnum+offset));	
	}

	// Use maximum/minimum values?
	if (modes & GWAVE_USEMINMAX)
	{
		minnum = G_FLOAT(OFS_PARM2);
		maxnum = G_FLOAT(OFS_PARM3);

		retval = minnum + ((retval + 1)/2)*(maxnum - minnum);
	}

	// Return it!
	G_FLOAT(OFS_RETURN) = retval;
}

/*
==============
PF_clientsound

void(entity client) clientsound
==============
*/

void PF_clientsound (void)
{
	char		*sample;
	int			channel;
	edict_t		*entity;
	int 		volume;
	float attenuation;
	
	int         sound_num;
    int			i;
	int			ent;
	vec3_t		origin;
	
	entity = G_EDICT(OFS_PARM0);
	channel = G_FLOAT(OFS_PARM1);
	sample = G_STRING(OFS_PARM2);
	volume = G_FLOAT(OFS_PARM3) * 255;
	attenuation = G_FLOAT(OFS_PARM4);
		
	ent = NUM_FOR_EDICT(entity);

	// If not a client go away
	if (ent > MAX_CLIENTS || ent < 1)
		return;
	
	if (volume < 0 || volume > 255)
		SV_Error ("SV_StartSound: volume = %i", volume);

	if (attenuation < 0 || attenuation > 4)
		SV_Error ("SV_StartSound: attenuation = %f", attenuation);

	if (channel < 0 || channel > 15)
		SV_Error ("SV_StartSound: channel = %i", channel);

// find precache number for sound
    for (sound_num=1 ; sound_num<MAX_SOUNDS
        && sv.sound_precache[sound_num] ; sound_num++)
        if (!strcmp(sample, sv.sound_precache[sound_num]))
            break;
    
    if ( sound_num == MAX_SOUNDS || !sv.sound_precache[sound_num] )
    {
        Con_Printf ("SV_StartSound: %s not precacheed\n", sample);
        return;
    }
	
	channel &= 7;

	channel = (ent<<3) | channel;

	if (volume != DEFAULT_SOUND_PACKET_VOLUME)
		channel |= SND_VOLUME;
	if (attenuation != DEFAULT_SOUND_PACKET_ATTENUATION)
		channel |= SND_ATTENUATION;

	// use the entity origin
	VectorCopy (entity->v.origin, origin);
	
	MSG_WriteByte(&svs.clients[ent - 1].netchan.message, svc_sound);
	MSG_WriteShort(&svs.clients[ent - 1].netchan.message, channel);
	if (channel & SND_VOLUME)
		MSG_WriteByte (&svs.clients[ent - 1].netchan.message, volume);
	if (channel & SND_ATTENUATION)
		MSG_WriteByte (&svs.clients[ent - 1].netchan.message, attenuation*64);
	MSG_WriteByte (&svs.clients[ent - 1].netchan.message, sound_num);
	for (i=0 ; i<3 ; i++)
		MSG_WriteCoord (&svs.clients[ent - 1].netchan.message, origin[i]);
}

/*
==============
PF_touchworld

void() touchworld
==============
*/

void PF_touchworld (void)
{
	edict_t* self;
	int oself;
	dfunction_t	*oldf;

	oldf = pr_xfunction;
	oself = pr_global_struct->self;

	self = PROG_TO_EDICT(pr_global_struct->self);
	SV_LinkEdict(self,true);

	pr_global_struct->self = oself;
	pr_xfunction = oldf;	
}

// OfN - END
//======================================================

void PF_Fixme (void)
{
	PR_RunError ("unimplemented bulitin");
}

/*
==============
PF_logfragex

void(entity attacker, float aflags, float aspeed,
     entity victim, float vflags, float vspeed,
	  vector info) logfragex

info[0] = speed,
info[1] = distance,
info[2] = weapon
==============
*/

void PF_logfragex(void) {
	client_t *attacker, *victim;
	float *vec;
	unsigned int aid, aflags, aspeed, vid, vflags, vspeed, speed, distance, weapon;

	aid = G_EDICTNUM(OFS_PARM0) - 1;

	if(aid >= MAX_CLIENTS)
		SV_Error("logfragex: edict id is not a client id");

	attacker = &svs.clients[aid];

	vid = G_EDICTNUM(OFS_PARM3) - 1;

	if(vid >= MAX_CLIENTS)
		SV_Error("logfragex: edict id is not a client id");

	victim = &svs.clients[vid];

	aid = attacker->databaseid;
	if(!aid) attacker->databaseid = aid = DB_GetPlayerId(attacker->name);

	aflags = G_FLOAT(OFS_PARM1);
	aspeed = G_FLOAT(OFS_PARM2);

	vid = victim->databaseid;
	if(!vid) victim->databaseid = vid = DB_GetPlayerId(victim->name);

	vflags = G_FLOAT(OFS_PARM4);
	vspeed = G_FLOAT(OFS_PARM5);

	vec = G_VECTOR(OFS_PARM6);

	speed = vec[0];
	distance = vec[1];
	weapon = vec[2];

	DB_LogFrag(aid, aflags, aspeed, vid, vflags, vspeed, speed, distance, weapon);
}

builtin_t pr_builtin[] =
{
	PF_Fixme,
PF_makevectors,	// void(entity e)	makevectors 		= #1;
PF_setorigin,	// void(entity e, vector o) setorigin	= #2;
PF_setmodel,	// void(entity e, string m) setmodel	= #3;
PF_setsize,	// void(entity e, vector min, vector max) setsize = #4;
PF_Fixme,	// void(entity e, vector min, vector max) setabssize = #5;
PF_break,	// void() break						= #6;
PF_random,	// float() random						= #7;
PF_sound,	// void(entity e, float chan, string samp) sound = #8;
PF_normalize,	// vector(vector v) normalize			= #9;
PF_error,	// void(string e) error				= #10;
PF_objerror,	// void(string e) objerror				= #11;
PF_vlen,	// float(vector v) vlen				= #12;
PF_vectoyaw,	// float(vector v) vectoyaw		= #13;
PF_Spawn,	// entity() spawn						= #14;
PF_Remove,	// void(entity e) remove				= #15;
PF_traceline,	// float(vector v1, vector v2, float tryents) traceline = #16;
PF_checkclient,	// entity() clientlist					= #17;
PF_Find,	// entity(entity start, .string fld, string match) find = #18;
PF_precache_sound,	// void(string s) precache_sound		= #19;
PF_precache_model,	// void(string s) precache_model		= #20;
PF_stuffcmd,	// void(entity client, string s)stuffcmd = #21;
PF_findradius,	// entity(vector org, float rad) findradius = #22;
PF_bprint,	// void(string s) bprint				= #23;
PF_sprint,	// void(entity client, string s) sprint = #24;
PF_dprint,	// void(string s) dprint				= #25;
PF_ftos,	// void(string s) ftos				= #26;
PF_vtos,	// void(string s) vtos				= #27;
PF_coredump,
PF_traceon,
PF_traceoff,
PF_eprint,	// void(entity e) debug print an entire entity
PF_walkmove, // float(float yaw, float dist) walkmove
PF_Fixme, // float(float yaw, float dist) walkmove
PF_droptofloor,
PF_lightstyle,
PF_rint,
PF_floor,
PF_ceil,
PF_Fixme,
PF_checkbottom,
PF_pointcontents,
PF_Fixme,
PF_fabs,
PF_aim,
PF_cvar,
PF_localcmd,
PF_nextent,
PF_Fixme,
PF_changeyaw,
PF_Fixme,
PF_vectoangles,

PF_WriteByte,
PF_WriteChar,
PF_WriteShort,
PF_WriteLong,
PF_WriteCoord,
PF_WriteAngle,
PF_WriteString,
PF_WriteEntity,

PF_Fixme,
PF_Fixme,
PF_Fixme,
PF_Fixme,
PF_Fixme,
PF_Fixme,
PF_Fixme,

SV_MoveToGoal,
PF_precache_file,
PF_makestatic,

PF_changelevel,
PF_Fixme,

PF_cvar_set,
PF_centerprint,

PF_ambientsound,

PF_precache_model,
PF_precache_sound,		// precache_sound2 is different only for qcc
PF_precache_file,

PF_setspawnparms,

PF_logfrag,

PF_infokey,
PF_stof,
PF_multicast,

// OfN - New built-ins
PF_getuid,
PF_strcat,
PF_padstr,
PF_colstr,
PF_strcasecmp,
PF_strlen,
PF_getclient,
PF_mutedtime,
PF_validatefile,
PF_putsaytime,
PF_makestr,
PF_delstr,
PF_getwave,
PF_clientsound,
PF_touchworld,

// phrosty - New built-in for database logging.
PF_logfragex
};

builtin_t *pr_builtins = pr_builtin;
int pr_numbuiltins = sizeof(pr_builtin)/sizeof(pr_builtin[0]);

