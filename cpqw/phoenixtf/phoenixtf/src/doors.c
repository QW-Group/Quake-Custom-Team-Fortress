/*
 *  QWProgs-TF2003
 *  Copyright (C) 2004  [sd] angel
 *
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 *
 *
 *  $Id: doors.c,v 1.8 2006/11/29 23:19:23 AngelD Exp $
 */
#include "g_local.h"

#define DOOR_START_OPEN   1
#define DOOR_DONT_LINK    4
#define DOOR_GOLD_KEY     8
#define DOOR_SILVER_KEY  16
#define DOOR_TOGGLE      32

/*

Doors are similar to buttons, but can spawn a fat trigger field around them
to open without a touch, and they link together to form simultanious
double/quad doors.
 
Door.owner is the master door.  If there is only one door, it points to itself.
If multiple doors, all will point to a single one.

Door.enemy chains from the master door through all doors linked in the chain.

*/
/*
=============================================================================

THINK FUNCTIONS

=============================================================================
*/

void    door_blocked(  );
void    door_hit_top(  );
void    door_hit_bottom(  );
void    door_go_down(  );
void    door_go_up(  );
void    door_fire(  );

void door_blocked(  )
{
	if ( streq( other->s.v.classname, "detpack" ) )
	{
		G_sprint( PROG_TO_EDICT( other->s.v.owner ), 2, "Your detpack was squashed.\n" );
		if ( other->weaponmode == 1 )
		{
			TeamFortress_SetSpeed( PROG_TO_EDICT( other->s.v.enemy ) );
			dremove( other->observer_list );
		}
		dremove( other->oldenemy );
		dremove( other );
		return;
	}
	if ( streq( other->s.v.classname, "player" ) && other->s.v.health <= 0 )
		return;

	T_Damage( other, self, self, self->dmg );

// if a door has a negative wait, it would never come back if blocked,
// so let it just squash the object to death real fast

	if ( self->wait >= 0 )
	{
		if ( self->state == STATE_DOWN )
			door_go_up(  );
		else
			door_go_down(  );
	}
}

void door_hit_top(  )
{
	sound( self, CHAN_VOICE, self->s.v.noise1, 1, ATTN_NORM );
	self->state = STATE_TOP;

	if ( ( int ) ( self->s.v.spawnflags ) & DOOR_TOGGLE )
		return;		// don't come down automatically

	self->s.v.think = ( func_t ) door_go_down;
	self->s.v.nextthink = self->s.v.ltime + self->wait;
}

void door_hit_bottom(  )
{
	self->goal_state = TFGS_INACTIVE;
	sound( self, CHAN_VOICE, self->s.v.noise1, 1, ATTN_NORM );
	self->state = STATE_BOTTOM;
}

void door_go_down(  )
{
	sound( self, CHAN_VOICE, self->s.v.noise2, 1, ATTN_NORM );
	if ( self->s.v.max_health )
	{
		self->s.v.takedamage = DAMAGE_YES;
		self->s.v.health = self->s.v.max_health;
	}

	self->state = STATE_DOWN;
	SUB_CalcMove( self->pos1, self->speed, door_hit_bottom );
}

void door_go_up(  )
{

	if ( self->state == STATE_UP )
		return;		// allready going up

	if ( self->state == STATE_TOP )
	{			// reset top wait time

		self->s.v.nextthink = self->s.v.ltime + self->wait;
		return;
	}

	sound( self, CHAN_VOICE, self->s.v.noise2, 1, ATTN_NORM );
	self->state = STATE_UP;

	SUB_CalcMove( self->pos2, self->speed, door_hit_top );
	SUB_UseTargets(  );
}

/*
=============================================================================

ACTIVATION FUNCTIONS

=============================================================================
*/


void door_fire(  )
{
	gedict_t *oself, *starte;

	if ( PROG_TO_EDICT( self->s.v.owner ) != self )
		G_Error( "door_fire: self.owner != self" );

// play use key sound

	if ( self->s.v.items )
		sound( self, CHAN_VOICE, self->noise4, 1, ATTN_NORM );

	self->s.v.message = 0;	// no more message
	oself = self;

	if ( ( int ) ( self->s.v.spawnflags ) & DOOR_TOGGLE )
	{
		if ( self->state == STATE_UP || self->state == STATE_TOP )
		{
			starte = self;
			do
			{
				door_go_down(  );

				self = PROG_TO_EDICT( self->s.v.enemy );
			}
			while ( ( self != starte ) && ( self != world ) );
			self = oself;
			return;
		}
	}
// trigger all paired doors
	starte = self;
	do
	{
		door_go_up(  );
		self = PROG_TO_EDICT( self->s.v.enemy );
	}
	while ( ( self != starte ) && ( self != world ) );
	self = oself;
}

void door_use(  )
{
	gedict_t *oself;

	self->s.v.message = "";	// door message are for touch only
	PROG_TO_EDICT( self->s.v.owner )->s.v.message = "";
	PROG_TO_EDICT( self->s.v.enemy )->s.v.message = "";

	oself = self;
	self = PROG_TO_EDICT( self->s.v.owner );
	door_fire(  );
	self = oself;
}

void door_trigger_touch(  )
{
	gedict_t *te;

	if ( other->s.v.health <= 0 )
		return;

	if ( !other->playerclass )
		return;
	if ( !Activated( self, other ) )
	{
		if ( self->else_goal )
		{
			te = Findgoal( self->else_goal );
			if ( te )
				AttemptToActivate( te, other, self );
		}
		return;
	}
	if ( g_globalvars.time < self->attack_finished )
		return;
	self->attack_finished = g_globalvars.time + 1;

	activator = other;

	self = PROG_TO_EDICT( self->s.v.owner );
	door_use(  );
}

void door_killed(  )
{
	gedict_t *oself;

	oself = self;
	self = PROG_TO_EDICT( self->s.v.owner );
	self->s.v.health = self->s.v.max_health;
	self->s.v.takedamage = DAMAGE_NO;	// wil be reset upon return

	door_use(  );
	self = oself;
}

/*
================
door_touch

Prints messages and opens key doors
================
*/

int     DoorShouldOpen(  );

void door_touch(  )
{
	gedict_t *te;
	char   *msg;

	if ( strneq( other->s.v.classname, "player" ) )
		return;

	if ( PROG_TO_EDICT( self->s.v.owner )->attack_finished > g_globalvars.time )
		return;


	if ( !Activated( self, other ) )
	{
		if ( self->else_goal )
		{
			te = Findgoal( self->else_goal );
			if ( te )
				AttemptToActivate( te, other, self );
		}
		return;
	}
	PROG_TO_EDICT( self->s.v.owner )->attack_finished = g_globalvars.time + 2;
	msg = PROG_TO_EDICT( self->s.v.owner )->s.v.message;

	if ( msg && msg[0] )
	{
		G_centerprint( other, "%s", PROG_TO_EDICT( self->s.v.owner )->s.v.message );
		sound( other, CHAN_VOICE, "misc/talk.wav", 1, ATTN_NORM );
	}
// key door stuff
	if ( self->s.v.items == 0 )
		return;

// FIXME: blink key on player's status bar
	if ( ( ( int ) self->s.v.items & ( int ) other->s.v.items ) != self->s.v.items )
	{
		if ( PROG_TO_EDICT( self->s.v.owner )->s.v.items == IT_KEY1 )
		{
			if ( world->worldtype == 2 )
			{
				G_centerprint( other, "You need the silver keycard" );
				sound( self, CHAN_VOICE, self->s.v.noise3, 1, ATTN_NORM );
			} else if ( world->worldtype == 1 )
			{
				G_centerprint( other, "You need the silver runekey" );
				sound( self, CHAN_VOICE, self->s.v.noise3, 1, ATTN_NORM );
			} else if ( world->worldtype == 0 )
			{
				G_centerprint( other, "You need the silver key" );
				sound( self, CHAN_VOICE, self->s.v.noise3, 1, ATTN_NORM );
			}
		} else
		{
			if ( world->worldtype == 2 )
			{
				G_centerprint( other, "You need the gold keycard" );
				sound( self, CHAN_VOICE, self->s.v.noise3, 1, ATTN_NORM );
			} else if ( world->worldtype == 1 )
			{
				G_centerprint( other, "You need the gold runekey" );
				sound( self, CHAN_VOICE, self->s.v.noise3, 1, ATTN_NORM );
			} else if ( world->worldtype == 0 )
			{
				G_centerprint( other, "You need the gold key" );
				sound( self, CHAN_VOICE, self->s.v.noise3, 1, ATTN_NORM );
			}
		}
		return;
	}

	other->s.v.items -= self->s.v.items;

	other->tf_items = other->tf_items | ( int ) self->s.v.items;

	if ( DoorShouldOpen(  ) )
	{
		self->s.v.touch = ( func_t ) SUB_Null;
		if ( self->s.v.enemy )
			PROG_TO_EDICT( self->s.v.enemy )->s.v.touch = ( func_t ) SUB_Null;	// get paired door

		door_use(  );
	}
}

/*
=============================================================================

SPAWNING FUNCTIONS

=============================================================================
*/



gedict_t *spawn_field( vec3_t fmins, vec3_t fmaxs )
{
	gedict_t *trigger;

	trigger = spawn(  );
	trigger->s.v.movetype = MOVETYPE_NONE;
	trigger->s.v.solid = SOLID_TRIGGER;
	trigger->s.v.owner = EDICT_TO_PROG( self );
	trigger->s.v.touch = ( func_t ) door_trigger_touch;

	trigger->team_no = self->team_no;
	trigger->playerclass = self->playerclass;
	trigger->items_allowed = self->items_allowed;
	trigger->activate_goal_no = self->activate_goal_no;
	trigger->inactivate_goal_no = self->inactivate_goal_no;
	trigger->remove_goal_no = self->remove_goal_no;
	trigger->restore_goal_no = self->restore_goal_no;
	trigger->activate_group_no = self->activate_group_no;
	trigger->inactivate_group_no = self->inactivate_group_no;
	trigger->remove_group_no = self->remove_group_no;
	trigger->restore_group_no = self->restore_group_no;
	trigger->goal_activation = self->goal_activation;
	trigger->goal_effects = self->goal_effects;
	trigger->goal_result = self->goal_result;
	trigger->goal_group = self->goal_group;
	trigger->all_active = self->all_active;
	trigger->last_impulse = self->last_impulse;
	trigger->else_goal = self->else_goal;

	setsize( trigger, fmins[0] - 60, fmins[1] - 60, fmins[2] - 8, fmaxs[0] + 60, fmaxs[1] + 60, fmaxs[2] + 8 );
	return ( trigger );

}

qboolean EntitiesTouching( gedict_t * e1, gedict_t * e2 )
{
	if ( e1->s.v.mins[0] > e2->s.v.maxs[0] )
		return false;

	if ( e1->s.v.mins[1] > e2->s.v.maxs[1] )
		return false;

	if ( e1->s.v.mins[2] > e2->s.v.maxs[2] )
		return false;

	if ( e1->s.v.maxs[0] < e2->s.v.mins[0] )
		return false;

	if ( e1->s.v.maxs[1] < e2->s.v.mins[1] )
		return false;

	if ( e1->s.v.maxs[2] < e2->s.v.mins[2] )
		return false;

	return true;
}

/*
=============
LinkDoors


=============
*/

void LinkDoors(  )
{
	gedict_t *t, *starte;
	vec3_t  cmins, cmaxs;

	if ( self->s.v.enemy )
		return;		// already linked by another door

	if ( ( int ) ( self->s.v.spawnflags ) & 4 )
	{
		self->s.v.owner = self->s.v.enemy = EDICT_TO_PROG( self );
		return;		// don't want to link this door
	}

	VectorCopy( self->s.v.mins, cmins );
	VectorCopy( self->s.v.maxs, cmaxs );
	//cmins = self->s.v.mins;
	//cmaxs = self->s.v.maxs;

	starte = self;
	t = self;

	do
	{
		self->s.v.owner = EDICT_TO_PROG( starte );	// master door

		if ( self->s.v.health )
			starte->s.v.health = self->s.v.health;

		if ( self->s.v.targetname )
			starte->s.v.targetname = self->s.v.targetname;

		if ( strneq( self->s.v.message, "" ) )
			starte->s.v.message = self->s.v.message;

		t = trap_find( t, FOFS( s.v.classname ), self->s.v.classname );

		if ( !t )
		{
			self->s.v.enemy = EDICT_TO_PROG( starte );	// make the chain a loop

			// shootable, fired, or key doors just needed the owner/enemy links,
			// they don't spawn a field

			self = PROG_TO_EDICT( self->s.v.owner );

			if ( self->s.v.health )
				return;
			if ( self->s.v.targetname )
				return;
			if ( self->s.v.items )
				return;
			PROG_TO_EDICT( self->s.v.owner )->trigger_field = spawn_field( cmins, cmaxs );

			return;
		}
		if ( EntitiesTouching( self, t ) )
		{
			if ( t->s.v.enemy )
				G_Error( "cross connected doors" );

			self->s.v.enemy = EDICT_TO_PROG( t );
			self = t;

			if ( t->s.v.mins[0] < cmins[0] )
				cmins[0] = t->s.v.mins[0];

			if ( t->s.v.mins[1] < cmins[1] )
				cmins[1] = t->s.v.mins[1];

			if ( t->s.v.mins[2] < cmins[2] )
				cmins[2] = t->s.v.mins[2];

			if ( t->s.v.maxs[0] > cmaxs[0] )
				cmaxs[0] = t->s.v.maxs[0];

			if ( t->s.v.maxs[1] > cmaxs[1] )
				cmaxs[1] = t->s.v.maxs[1];

			if ( t->s.v.maxs[2] > cmaxs[2] )
				cmaxs[2] = t->s.v.maxs[2];
		}
	}
	while ( 1 );

}

/*QUAKED func_door (0 .5 .8) ? START_OPEN x DOOR_DONT_LINK GOLD_KEY SILVER_KEY TOGGLE
if two doors touch, they are assumed to be connected and operate as a unit.

TOGGLE causes the door to wait in both the start and end states for a trigger event.

START_OPEN causes the door to move to its destination when spawned, and operate in reverse.  It is used to temporarily or permanently close off an area when triggered (not usefull for touch or takedamage doors).

Key doors are allways wait -1.

"message"       is printed when the door is touched if it is a trigger door and it hasn't been fired yet
"angle"         determines the opening direction
"targetname" if set, no touch field will be spawned and a remote button or trigger field activates the door.
"health"        if set, door must be shot open
"speed"         movement speed (100 default)
"wait"          wait before returning (3 default, -1 = never return)
"lip"           lip remaining at end of move (8 default)
"dmg"           damage to inflict when blocked (2 default)
"sounds"
0)      no sound
1)      stone
2)      base
3)      stone chain
4)      screechy metal
*/

void SP_func_door(  )
{
	float   tmp;

	if ( !CheckExistence(  ) )
	{
		dremove( self );
		return;
	}

	if ( world->worldtype == 0 )
	{
		trap_precache_sound( "doors/medtry.wav" );
		trap_precache_sound( "doors/meduse.wav" );
		self->s.v.noise3 = "doors/medtry.wav";
		self->noise4 = "doors/meduse.wav";
	} else if ( world->worldtype == 1 )
	{
		trap_precache_sound( "doors/runetry.wav" );
		trap_precache_sound( "doors/runeuse.wav" );
		self->s.v.noise3 = "doors/runetry.wav";
		self->noise4 = "doors/runeuse.wav";
	} else if ( world->worldtype == 2 )
	{
		trap_precache_sound( "doors/basetry.wav" );
		trap_precache_sound( "doors/baseuse.wav" );
		self->s.v.noise3 = "doors/basetry.wav";
		self->noise4 = "doors/baseuse.wav";
	} else
	{
		G_dprintf( "no worldtype set!\n" );
	}
	if ( self->s.v.sounds == 0 )
	{
		trap_precache_sound( "misc/null.wav" );
		trap_precache_sound( "misc/null.wav" );
		self->s.v.noise1 = "misc/null.wav";
		self->s.v.noise2 = "misc/null.wav";
	}
	if ( self->s.v.sounds == 1 )
	{
		trap_precache_sound( "doors/drclos4.wav" );
		trap_precache_sound( "doors/doormv1.wav" );
		self->s.v.noise1 = "doors/drclos4.wav";
		self->s.v.noise2 = "doors/doormv1.wav";
	}
	if ( self->s.v.sounds == 2 )
	{
		trap_precache_sound( "doors/hydro1.wav" );
		trap_precache_sound( "doors/hydro2.wav" );
		self->s.v.noise2 = "doors/hydro1.wav";
		self->s.v.noise1 = "doors/hydro2.wav";
	}
	if ( self->s.v.sounds == 3 )
	{
		trap_precache_sound( "doors/stndr1.wav" );
		trap_precache_sound( "doors/stndr2.wav" );
		self->s.v.noise2 = "doors/stndr1.wav";
		self->s.v.noise1 = "doors/stndr2.wav";
	}
	if ( self->s.v.sounds == 4 )
	{
		trap_precache_sound( "doors/ddoor1.wav" );
		trap_precache_sound( "doors/ddoor2.wav" );
		self->s.v.noise1 = "doors/ddoor2.wav";
		self->s.v.noise2 = "doors/ddoor1.wav";
	}


	SetMovedir(  );

	self->s.v.max_health = self->s.v.health;
	self->s.v.solid = SOLID_BSP;
	self->s.v.movetype = MOVETYPE_PUSH;

	setorigin( self, PASSVEC3( self->s.v.origin ) );
	setmodel( self, self->s.v.model );

	self->s.v.classname = "door";

	self->s.v.blocked = ( func_t ) door_blocked;
	self->s.v.use = ( func_t ) door_use;

	if ( ( int ) ( self->s.v.spawnflags ) & DOOR_SILVER_KEY )
		self->s.v.items = IT_KEY1;

	if ( ( int ) ( self->s.v.spawnflags ) & DOOR_GOLD_KEY )
		self->s.v.items = IT_KEY2;

	if ( !self->speed )
		self->speed = 100;

	if ( !self->wait )
		self->wait = 3;

	if ( !self->lip )
		self->lip = 8;

	if ( !self->dmg )
		self->dmg = 2;

	VectorCopy( self->s.v.origin, self->pos1 );

	//
	tmp = fabs( DotProduct( self->s.v.movedir, self->s.v.size ) ) - self->lip;

	self->pos2[0] = self->pos1[0] + self->s.v.movedir[0] * tmp;
	self->pos2[1] = self->pos1[1] + self->s.v.movedir[1] * tmp;
	self->pos2[2] = self->pos1[2] + self->s.v.movedir[2] * tmp;

// DOOR_START_OPEN is to allow an entity to be lighted in the closed position
// but spawn in the open position
	if ( ( int ) ( self->s.v.spawnflags ) & DOOR_START_OPEN )
	{
		setorigin( self, PASSVEC3( self->pos2 ) );
		VectorCopy( self->pos1, self->pos2 );
		VectorCopy( self->s.v.origin, self->pos1 );
	}

	self->state = STATE_BOTTOM;

	if ( self->s.v.health )
	{
		self->s.v.takedamage = DAMAGE_YES;
		self->th_die = door_killed;
	}

	if ( self->s.v.items )
		self->wait = -1;

	self->s.v.touch = ( func_t ) door_touch;

// LinkDoors can't be done until all of the doors have been spawned, so
// the sizes can be detected properly.
	self->s.v.think = ( func_t ) LinkDoors;
	self->s.v.nextthink = self->s.v.ltime + 0.1;
}

/*
=============================================================================

SECRET DOORS

=============================================================================
*/

void    fd_secret_move1(  );
void    fd_secret_move2(  );
void    fd_secret_move3(  );
void    fd_secret_move4(  );
void    fd_secret_move5(  );
void    fd_secret_move6(  );
void    fd_secret_done(  );

#define SECRET_OPEN_ONCE 1	// stays open
#define SECRET_1ST_LEFT 2	// 1st move is left of arrow
#define SECRET_1ST_DOWN 4	// 1st move is down from arrow
#define SECRET_NO_SHOOT 8	// only opened by trigger
#define SECRET_YES_SHOOT 16	// shootable even if targeted


void fd_secret_use( gedict_t * attacker, float take )
{
	float   temp;

	self->s.v.health = 10000;

	// exit if still moving around...
	if ( !VectorCompare( self->s.v.origin, self->s.v.oldorigin ) )
		return;

	// TF Disable doors with spawnflags of DOOR_TOGGLE
	if ( ( int ) ( self->s.v.spawnflags ) & DOOR_TOGGLE )
		return;

	self->s.v.message = 0;	// no more message
	//activator=attacker;
	SUB_UseTargets(  );	// fire all targets / killtargets

	if ( !( ( int ) ( self->s.v.spawnflags ) & SECRET_NO_SHOOT ) )
	{
		self->th_pain = ( th_pain_func_t ) ( 0 );	//SUB_Null;
		self->s.v.takedamage = DAMAGE_NO;
	}

	VectorClear( self->s.v.velocity );

	// Make a sound, wait a little...

	sound( self, CHAN_VOICE, self->s.v.noise1, 1, ATTN_NORM );
	self->s.v.nextthink = self->s.v.ltime + 0.1;

	temp = 1 - ( ( int ) ( self->s.v.spawnflags ) & SECRET_1ST_LEFT );	// 1 or -1
	trap_makevectors( self->mangle );

	if ( self->t_width == 0 )
	{
		if ( ( int ) ( self->s.v.spawnflags ) & SECRET_1ST_DOWN )
			self->t_width = fabs( DotProduct( g_globalvars.v_up, self->s.v.size ) );
		else
			self->t_width = fabs( DotProduct( g_globalvars.v_right, self->s.v.size ) );
	}

	if ( self->t_length == 0 )
		self->t_length = fabs( DotProduct( g_globalvars.v_forward, self->s.v.size ) );

	if ( ( int ) ( self->s.v.spawnflags ) & SECRET_1ST_DOWN )
	{
		self->dest1[0] = self->s.v.origin[0] - g_globalvars.v_up[0] * self->t_width;
		self->dest1[1] = self->s.v.origin[1] - g_globalvars.v_up[1] * self->t_width;
		self->dest1[2] = self->s.v.origin[2] - g_globalvars.v_up[2] * self->t_width;
	} else
	{
		self->dest1[0] = self->s.v.origin[0] + g_globalvars.v_right[0] * ( self->t_width * temp );
		self->dest1[1] = self->s.v.origin[1] + g_globalvars.v_right[1] * ( self->t_width * temp );
		self->dest1[2] = self->s.v.origin[2] + g_globalvars.v_right[2] * ( self->t_width * temp );
	}

	self->dest2[0] = self->dest1[0] + g_globalvars.v_forward[0] * self->t_length;
	self->dest2[1] = self->dest1[1] + g_globalvars.v_forward[1] * self->t_length;
	self->dest2[2] = self->dest1[2] + g_globalvars.v_forward[2] * self->t_length;

	SUB_CalcMove( self->dest1, self->speed, fd_secret_move1 );
	sound( self, CHAN_VOICE, self->s.v.noise2, 1, ATTN_NORM );
}

// Wait after first movement...
void fd_secret_move1(  )
{
	self->s.v.nextthink = self->s.v.ltime + 1.0;
	self->s.v.think = ( func_t ) fd_secret_move2;
	sound( self, CHAN_VOICE, self->s.v.noise3, 1, ATTN_NORM );
}

// Start moving sideways w/sound...
void fd_secret_move2(  )
{
	sound( self, CHAN_VOICE, self->s.v.noise2, 1, ATTN_NORM );
	SUB_CalcMove( self->dest2, self->speed, fd_secret_move3 );
}

// Wait here until time to go back...
void fd_secret_move3(  )
{
	sound( self, CHAN_VOICE, self->s.v.noise3, 1, ATTN_NORM );
	if ( !( ( int ) ( self->s.v.spawnflags ) & SECRET_OPEN_ONCE ) )
	{
		self->s.v.nextthink = self->s.v.ltime + self->wait;
		self->s.v.think = ( func_t ) fd_secret_move4;
	}
}

// Move backward...
void fd_secret_move4(  )
{
	sound( self, CHAN_VOICE, self->s.v.noise2, 1, ATTN_NORM );
	SUB_CalcMove( self->dest1, self->speed, fd_secret_move5 );
}

// Wait 1 second...
void fd_secret_move5(  )
{
	self->s.v.nextthink = self->s.v.ltime + 1.0;
	self->s.v.think = ( func_t ) fd_secret_move6;
	sound( self, CHAN_VOICE, self->s.v.noise3, 1, ATTN_NORM );
}

void fd_secret_move6(  )
{
	sound( self, CHAN_VOICE, self->s.v.noise2, 1, ATTN_NORM );
	SUB_CalcMove( self->s.v.oldorigin, self->speed, fd_secret_done );
}


void fd_secret_done(  )
{
	if ( !self->s.v.targetname || ( int ) ( self->s.v.spawnflags ) & SECRET_YES_SHOOT )
	{
		self->s.v.health = 10000;
		self->s.v.takedamage = DAMAGE_YES;
		self->th_pain = fd_secret_use;
		self->th_die = ( void ( * )(  ) ) fd_secret_use;
	}
	sound( self, CHAN_VOICE, self->s.v.noise3, 1, ATTN_NORM );
}

void secret_blocked(  )
{
	if ( g_globalvars.time < self->attack_finished )
		return;
	self->attack_finished = g_globalvars.time + 0.5;
//      other->deathtype = "squish";
	T_Damage( other, self, self, self->dmg );
}

/*
================
secret_touch

Prints messages
================
*/

void secret_touch(  )
{
	if ( strneq( other->s.v.classname, "player" ) )
		return;

	if ( self->attack_finished > g_globalvars.time )
		return;

	// TF Disable doors with spawnflags of DOOR_TOGGLE
	if ( ( int ) ( self->s.v.spawnflags ) & DOOR_TOGGLE )
		return;

	self->attack_finished = g_globalvars.time + 2;

	if ( self->s.v.message )
	{
		G_centerprint( other, "%s", self->s.v.message );
		sound( other, CHAN_BODY, "misc/talk.wav", 1, ATTN_NORM );
	}
}

/*QUAKED func_door_secret (0 .5 .8) ? open_once 1st_left 1st_down no_shoot always_shoot
Basic secret door. Slides back, then to the side. Angle determines direction.
wait  = # of seconds before coming back
1st_left = 1st move is left of arrow
1st_down = 1st move is down from arrow
always_shoot = even if targeted, keep shootable
t_width = override WIDTH to move back (or height if going down)
t_length = override LENGTH to move sideways
"dmg"           damage to inflict when blocked (2 default)

If a secret door has a targetname, it will only be opened by it's botton or trigger, not by damage.
"sounds"
1) medieval
2) metal
3) base
*/

void SP_func_door_secret(  )
{
	if ( !CheckExistence(  ) )
	{
		dremove( self );
		return;
	}

	if ( self->s.v.sounds == 0 )
		self->s.v.sounds = 3;

	if ( self->s.v.sounds == 1 )
	{
		trap_precache_sound( "doors/latch2.wav" );
		trap_precache_sound( "doors/winch2.wav" );
		trap_precache_sound( "doors/drclos4.wav" );
		self->s.v.noise1 = "doors/latch2.wav";
		self->s.v.noise2 = "doors/winch2.wav";
		self->s.v.noise3 = "doors/drclos4.wav";
	}
	if ( self->s.v.sounds == 2 )
	{
		trap_precache_sound( "doors/airdoor1.wav" );
		trap_precache_sound( "doors/airdoor2.wav" );
		self->s.v.noise2 = "doors/airdoor1.wav";
		self->s.v.noise1 = "doors/airdoor2.wav";
		self->s.v.noise3 = "doors/airdoor2.wav";
	}
	if ( self->s.v.sounds == 3 )
	{
		trap_precache_sound( "doors/basesec1.wav" );
		trap_precache_sound( "doors/basesec2.wav" );
		self->s.v.noise2 = "doors/basesec1.wav";
		self->s.v.noise1 = "doors/basesec2.wav";
		self->s.v.noise3 = "doors/basesec2.wav";
	}

	if ( self->dmg == 0 )
		self->dmg = 2;

	// Magic formula...
	VectorCopy( self->s.v.angles, self->mangle );
	SetVector( self->s.v.angles, 0, 0, 0 );
	self->s.v.solid = SOLID_BSP;
	self->s.v.movetype = MOVETYPE_PUSH;
	self->s.v.classname = "door";
	setmodel( self, self->s.v.model );
	setorigin( self, PASSVEC3( self->s.v.origin ) );

	self->s.v.touch = ( func_t ) secret_touch;
	self->s.v.blocked = ( func_t ) secret_blocked;
	self->speed = 50;
	self->s.v.use = ( func_t ) fd_secret_use;
	if ( !self->s.v.targetname || ( int ) ( self->s.v.spawnflags ) & SECRET_YES_SHOOT )
	{
		self->s.v.health = 10000;
		self->s.v.takedamage = DAMAGE_YES;
		self->th_pain = fd_secret_use;
	}
	VectorCopy( self->s.v.origin, self->s.v.oldorigin );

	if ( self->wait == 0 )
		self->wait = 5;	// 5 seconds before closing
}
