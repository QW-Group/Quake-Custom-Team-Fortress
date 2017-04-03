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
 *  $Id: flare.c,v 1.7 2005/05/28 18:33:52 AngelD Exp $
 */
/*==================================
This file handles all the functions
to deal with the flare 'grenade'.
==================================*/
#include "g_local.h"
static int     num_team_flares[5] = { 0, 0, 0, 0, 0 };

void FlareGrenadeTouch(  )
{
	sound( self, 1, "weapons/bounce.wav", 1, 1 );
	if ( trap_pointcontents( PASSVEC3( self->s.v.origin ) ) == CONTENT_SKY )
	{
		dremove( self );
		return;
	}
	if ( other == world )
	{
		self->s.v.movetype = MOVETYPE_NONE;
		SetVector( self->s.v.velocity, 0, 0, 0 );
	}
	if ( VectorCompareF( self->s.v.velocity, 0, 0, 0 ) )
	{
		SetVector( self->s.v.avelocity, 0, 0, 0 );
		self->s.v.touch = ( func_t ) SUB_Null;
	}
}

void FlareGrenadeThink(  )
{
	float   rnum;
	float   time_left;

	time_left = self->s.v.health - g_globalvars.time;
	if ( time_left > 33 )
	{
		rnum = g_random(  );
		if ( rnum < 0.5 )
			self->s.v.effects = 8;
		else
			self->s.v.effects = 0;
		self->s.v.nextthink = g_globalvars.time + 0.05 + g_random(  ) * 0.1;
	} else
	{
		if ( time_left > 31 )
		{
			rnum = g_random(  );
			if ( rnum < 0.5 )
				self->s.v.effects = 4;
			else
				self->s.v.effects = 8;
			self->s.v.nextthink = g_globalvars.time + 0.05 + g_random(  ) * 0.1;
		} else
		{
			if ( time_left > 15 )
			{
				self->s.v.effects = 4;
				self->s.v.nextthink = g_globalvars.time + 10;
			} else
			{
				if ( time_left < 1 )
					RemoveFlare(  );
				else
				{
					self->s.v.effects = 8;
					self->s.v.nextthink = g_globalvars.time + time_left;
				}
			}
		}
	}
}


/*============================
void() FlareGrenadeExplode

It is not really a grenade, nor does it
'explode'. But it fits in well with the
rest of the grenade code.
=============================*/
void FlareGrenadeExplode(  )
{


	if ( self->s.v.weapon )
	{
		num_team_flares[( int ) self->s.v.weapon]++;
		if ( num_team_flares[( int ) self->s.v.weapon] > 9 / number_of_teams )
			RemoveOldFlare( self->s.v.weapon );
	} else
	{
		num_team_flares[0]++;
		if ( num_team_flares[0] > 9 )
			RemoveOldFlare( 0 );
	}
	self->s.v.skin = 1;
	self->s.v.health = g_globalvars.time + 40;
	self->s.v.nextthink = g_globalvars.time + 0.05 + g_random(  ) * 0.1;
	self->s.v.think = ( func_t ) FlareGrenadeThink;
}

void RemoveFlare(  )
{
	self->s.v.effects = ( int ) self->s.v.effects - ( ( int ) self->s.v.effects & 4 );
	dremove( self );
	if ( num_team_flares[( int ) self->s.v.weapon] )
		num_team_flares[( int ) self->s.v.weapon]--;
}


void RemoveOldFlare( int tno )
{
	gedict_t *old;
	int     index;

	index = num_team_flares[tno];
	index = index - 9 / number_of_teams;

	old = trap_find( world, FOFS( mdl ), "flare" );
	while ( index > 0 )
	{
		if ( !old )
		{
			num_team_flares[0] = 0;
			num_team_flares[1] = 0;
			num_team_flares[2] = 0;
			num_team_flares[3] = 0;
			num_team_flares[4] = 0;
			return;
		}
		if ( old->s.v.weapon == tno || !tno )
		{
			old->s.v.think = ( func_t ) RemoveFlare;
			old->s.v.nextthink = g_globalvars.time + 0.1;
			index -= 1;
		}
		old = trap_find( old, FOFS( mdl ), "flare" );
	}
}

/*void increment_team_flares( int tno )
{
	if ( tno < 0 || tno > 4 )
		return;
	num_team_flares[tno]++;
}*/

/*void decrement_team_flares( int tno )
{
	if ( tno < 0 || tno > 4 )
		return;
	num_team_flares[tno]--;
}*/

