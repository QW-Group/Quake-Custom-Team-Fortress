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
 *  $Id: scout.c,v 1.26 2006/11/29 23:19:23 AngelD Exp $
 */
#include "g_local.h"

void    T_RadiusBounce( gedict_t * inflictor, gedict_t * attacker, float bounce, gedict_t * ignore );

void CanisterTouch(  )
{
	sound( self, 1, "weapons/tink1.wav", 1, 1 );
	if ( VectorCompareF( self->s.v.velocity, 0, 0, 0 ) )
		SetVector( self->s.v.avelocity, 0, 0, 0 );
}

void CaltropTouch(  )
{
	if ( strneq( other->s.v.classname, "player" )
	     || !( ( int ) other->s.v.flags & FL_ONGROUND ) || other->s.v.deadflag )
		return;
	if ( ( teamplay & 16 ) && other != PROG_TO_EDICT( self->s.v.owner )
	     && other->team_no == PROG_TO_EDICT( self->s.v.owner )->team_no
	     && PROG_TO_EDICT( self->s.v.owner )->team_no )
		return;
	G_sprint( other, 2, "Ow, Ow, Ow! Caltrops!\n" );
	other->leg_damage = other->leg_damage + 2;
	TeamFortress_SetSpeed( other );
	tf_data.deathmsg = DMSG_CALTROP;
	T_Damage( other, self, PROG_TO_EDICT( self->s.v.owner ), 10 );
	dremove( self );
}

void CaltropScatterThink(  )
{
	self->s.v.nextthink = g_globalvars.time + 0.2;
	if ( VectorCompareF( self->s.v.velocity, 0, 0, 0 ) )
	{
		if ( ( int ) self->s.v.flags & FL_ONGROUND )
		{
			self->s.v.nextthink = g_globalvars.time + 10 + g_random(  ) * 5;
			self->s.v.think = ( func_t ) SUB_Remove;
			self->s.v.solid = SOLID_TRIGGER;
			self->s.v.movetype = MOVETYPE_TOSS;
			self->s.v.touch = ( func_t ) CaltropTouch;
			SetVector( self->s.v.angles, 90, 90, 90 );
			sound( self, 0, "weapons/tink1.wav", 1, 1 );
			setorigin( self, PASSVEC3( self->s.v.origin ) );
			return;
		} else
		{
			self->s.v.nextthink = g_globalvars.time + 10 + g_random(  ) * 5;
			self->s.v.think = ( func_t ) SUB_Remove;
			self->s.v.solid = SOLID_TRIGGER;
			self->s.v.movetype = MOVETYPE_TOSS;
			self->s.v.touch = ( func_t ) CanisterTouch;
			setorigin( self, PASSVEC3( self->s.v.origin ) );
			return;
		}
	}
	traceline( PASSVEC3( self->s.v.movedir ), PASSVEC3( self->s.v.origin ), 1, self );
	if ( g_globalvars.trace_fraction == 1 )
	{
		VectorCopy( self->s.v.origin, self->s.v.movedir );
		return;
	}
	VectorScale( self->s.v.velocity, -1, self->s.v.velocity );
	self->heat = self->heat + 1;
	if ( self->heat > 10 )
	{
		ent_remove( self );
		return;
	}
}

void ScatterCaltrops(  )
{
	float   num;
	gedict_t *e;

	for ( num = 6; num > 0; num-- )
	{
		e = spawn(  );
		e->s.v.classname = "grenade";
		e->s.v.weapon = 10;
		e->s.v.owner = self->s.v.owner;
		e->team_no = PROG_TO_EDICT( self->s.v.owner )->team_no;
		setmodel( e, "progs/caltrop.mdl" );
		SetVector( e->s.v.mins, -4, -4, -8 );
		SetVector( e->s.v.maxs, 4, 4, 4 );
		SetVector( e->s.v.angles, 0, 0, 0 );
		e->s.v.angles[0] = g_random(  ) * 360;
		e->s.v.velocity[0] = crandom(  ) * 100;
		e->s.v.velocity[1] = crandom(  ) * 100;
		e->s.v.velocity[2] = 200 + g_random(  ) * 100;
		e->s.v.avelocity[0] = crandom(  ) * 400;
		e->s.v.avelocity[1] = crandom(  ) * 400;
		e->s.v.avelocity[2] = crandom(  ) * 400;
		setorigin( e, PASSVEC3( PROG_TO_EDICT( self->s.v.owner )->s.v.origin ) );
		VectorCopy( e->s.v.origin, e->s.v.movedir );
		e->heat = 0;
		e->s.v.movetype = MOVETYPE_BOUNCE;
		e->s.v.solid = SOLID_NOT;
		e->s.v.nextthink = g_globalvars.time + 0.2;
		e->s.v.think = ( func_t ) CaltropScatterThink;
	}
	dremove( self );
}

void FlashGrenadeTouch(  )
{
	sound( self, 1, "weapons/bounce.wav", 1, 1 );
	if ( VectorCompareF( self->s.v.velocity, 0, 0, 0 ) )
		SetVector( self->s.v.avelocity, 0, 0, 0 );
}

void FlashTimer(  )
{
	gedict_t *te;

	te = PROG_TO_EDICT( self->s.v.owner );
	te->FlashTime = te->FlashTime - 0.6;
	if ( te->FlashTime < 5 || ( self->gren_eff_time <= g_globalvars.time && tg_data.gren_time ) )
	{
		te->FlashTime = 0;
		stuffcmd( te, "v_cshift; wait; bf\n" );
		ent_remove( self );
		return;
	}
	stuffcmd( te, "v_cshift %.0f %.0f %.0f %.0f\n", te->FlashTime * 10,
		  te->FlashTime * 10, te->FlashTime * 10, te->FlashTime * 10 );
	self->s.v.nextthink = g_globalvars.time + 0.6;
}

void FlashTimerNew(  )
{
	gedict_t *te;

	te = PROG_TO_EDICT( self->s.v.owner );
	te->FlashTime = te->FlashTime - 0.6;
	if ( te->FlashTime < 5 || ( self->gren_eff_time <= g_globalvars.time && tg_data.gren_time ) )
	{
		te->FlashTime = 0;
		stuffcmd( te, "v_cshift; wait; bf\n" );
		ent_remove( self );
		return;
	}
	stuffcmd( te, "v_cshift %.0f %.0f %.0f %.0f\n", te->FlashTime * 10,
		  te->FlashTime * 10, te->FlashTime * 10, te->FlashTime * 10 );

	self->s.v.nextthink = g_globalvars.time + 0.6;
}

void FlashPlayer( gedict_t*p, gedict_t*attacker )
{
        gedict_t* te;
        
        if ( !p->FlashTime )
        {
       		te = spawn(  );
       		te->s.v.classname = "timer";
       		te->s.v.netname = "flashtimer";
       		te->s.v.owner = EDICT_TO_PROG( p );
        }else
        {
       		for ( te = world; ( te = trap_find( te, FOFS( s.v.netname ), "flashtimer" ) ); )
       		{
       			if ( te->s.v.owner != EDICT_TO_PROG( p ) )
       				continue;

       			break;
       		}
       		if ( !te )
       		{
       			G_conprintf( "Warning: Error in Flash Timer logic.\n" );
       			return;
       		}
        }
        G_sprint( p, 2, "You are flashed\n" );
       	
       	te->team_no = (attacker)?attacker->team_no:p->team_no;
       	if ( attacker && tg_data.gren_time )
       		te->gren_eff_time = g_globalvars.time + tg_data.gren_time;

       	
       	if ( tf_data.new_flash )
       	{
       	        te->s.v.think = ( func_t ) FlashTimerNew;
       	        te->s.v.nextthink = g_globalvars.time + NEW_FLASH_START_TIME;
       	        if( p == attacker )
       	        {
       	                p->FlashTime = 16;
       	                stuffcmd( p, "v_cshift 160 160 160 160\n" );
       	                disableupdates( p, -1 );	/* server-side flash */
       	        }else
       	        {
       	                p->FlashTime = 24;
			stuffcmd( p, "v_cshift 255 255 255 255\n" );
			disableupdates( p, NEW_FLASH_START_TIME );	/* server-side flash */
       	        }
       	}else
       	{
       	        te->s.v.think = ( func_t ) FlashTimer;
       	        te->s.v.nextthink = g_globalvars.time + 1;
       	        if( p == attacker )
       	        {
       	                p->FlashTime = 16;
       	                stuffcmd( p, "v_cshift 160 160 160 160\n" );
       	        }else
       	        {
       	                p->FlashTime = 24;
       	                stuffcmd( p, "v_cshift 240 240 240 240\n" );
       	        }
       	}
}

void FlashGrenadeExplode(  )
{
	gedict_t *te;
	gedict_t *owner;
	vec3_t  tmp;

	owner = PROG_TO_EDICT( self->s.v.owner );
	self->s.v.effects = ( int ) self->s.v.effects | 4;
	trap_WriteByte( MSG_MULTICAST, SVC_TEMPENTITY );
	trap_WriteByte( MSG_MULTICAST, TE_TAREXPLOSION );
	trap_WriteCoord( MSG_MULTICAST, self->s.v.origin[0] );
	trap_WriteCoord( MSG_MULTICAST, self->s.v.origin[1] );
	trap_WriteCoord( MSG_MULTICAST, self->s.v.origin[2] );
	trap_multicast( PASSVEC3( self->s.v.origin ), 1 );
	for ( te = world; ( te = trap_findradius( te, self->s.v.origin, 300 ) ); )
	{
		if ( strneq( te->s.v.classname, "player" ) )
			continue;


		traceline( PASSVEC3( self->s.v.origin ), PASSVEC3( te->s.v.origin ), 1, self );
		if ( g_globalvars.trace_fraction != 1 )
			continue;

		VectorSubtract( self->s.v.origin, te->s.v.origin, tmp );
		if ( vlen( tmp ) <= 200 )
		{
			tf_data.deathmsg = DMSG_GREN_FLASH;
			TF_T_Damage( te, self, owner, 60, 2, 16 | 4 );
		}
		if ( te->s.v.health <= 0 )
			continue;

		if ( tg_data.gren_effect == TG_GREN_EFFECT_OFF )
			continue;

		if ( te == owner && tg_data.gren_effect == TG_GREN_EFFECT_OFF_FORSELF )
			continue;
		FlashPlayer( te, owner );

	}
	dremove( self );
}

void ConcussionGrenadeTouch(  )
{
	sound( self, 1, "weapons/bounce.wav", 1, 1 );
	if ( VectorCompareF( self->s.v.velocity, 0, 0, 0 ) )
		SetVector( self->s.v.avelocity, 0, 0, 0 );
}

void ConcussionGrenadeExplode(  )
{
	T_RadiusBounce( self, PROG_TO_EDICT( self->s.v.owner ), 240, world );
	trap_WriteByte( MSG_MULTICAST, SVC_TEMPENTITY );
	trap_WriteByte( MSG_MULTICAST, TE_EXPLOSION );
	trap_WriteCoord( MSG_MULTICAST, self->s.v.origin[0] );
	trap_WriteCoord( MSG_MULTICAST, self->s.v.origin[1] );
	trap_WriteCoord( MSG_MULTICAST, self->s.v.origin[2] );
	trap_multicast( PASSVEC3( self->s.v.origin ), 1 );
	dremove( self );
}

void OldConcussionGrenadeTimer(  )
{
	gedict_t *owner = PROG_TO_EDICT( self->s.v.owner );

	if ( owner->invincible_finished > g_globalvars.time )
	{

		stuffcmd( owner, "v_idlescale 0; wait; fov 90\n" );
		dremove( self );
		return;
	}
	if ( tg_data.gren_time && self->gren_eff_time <= g_globalvars.time )
		self->s.v.health = 0;

	newmis = spawn(  );
	g_globalvars.newmis = EDICT_TO_PROG( newmis );
	setmodel( newmis, "progs/s_bubble.spr" );
	setorigin( newmis, PASSVEC3( owner->s.v.origin ) );
	newmis->s.v.movetype = MOVETYPE_NOCLIP;
	newmis->s.v.solid = SOLID_NOT;
	SetVector( newmis->s.v.velocity, 0, 0, 15 );
	newmis->s.v.nextthink = g_globalvars.time + 0.5;
	newmis->s.v.think = ( func_t ) bubble_bob;
	newmis->s.v.touch = ( func_t ) bubble_remove;
	newmis->s.v.classname = "bubble";
	newmis->s.v.frame = 0;
	newmis->cnt = 0;
	setsize( newmis, -8, -8, -8, 8, 8, 8 );
	self->s.v.health = self->s.v.health - 20;
	if ( owner->playerclass == PC_MEDIC )
		self->s.v.health = self->s.v.health - 20;
	if ( self->s.v.health < 0 )
		self->s.v.health = 0;
	self->s.v.nextthink = g_globalvars.time + 5;
	stuffcmd( owner, "v_iroll_cycle 0.5\n" );
	stuffcmd( owner, "v_ipitch_cycle 1\n" );
	stuffcmd( owner, "v_iyaw_cycle 2\n" );
	stuffcmd( owner, "v_idlescale %.0f\n", self->s.v.health );

	stuffcmd( owner, "fov %.0f\n", 90 + self->s.v.health / 2 );
	if ( !self->s.v.health )
		dremove( self );
}

void ConcussionGrenadeTimer(  )
{
	vec3_t  stumble;
	vec3_t  src;
	float   pos;
	gedict_t *owner = PROG_TO_EDICT( self->s.v.owner );

	if ( owner->invincible_finished > g_globalvars.time )
	{
		G_sprint( owner, 2, "Your head feels better now.\n" );
		owner->s.v.fixangle = 0;
		dremove( self );
		return;
	}
	if ( tg_data.gren_time && self->gren_eff_time <= g_globalvars.time )
		self->s.v.health = 0;
	if ( self->s.v.health == 200 || self->s.v.health == 400 || self->s.v.health == 600
	     || self->s.v.health == 800 || self->s.v.health == 1000 )
	{
		newmis = spawn(  );
		g_globalvars.newmis = EDICT_TO_PROG( newmis );
		setmodel( newmis, "progs/s_bubble.spr" );
		setorigin( newmis, PASSVEC3( owner->s.v.origin ) );
		newmis->s.v.movetype = MOVETYPE_NOCLIP;
		newmis->s.v.solid = SOLID_NOT;
		SetVector( newmis->s.v.velocity, 0, 0, 15 );
		newmis->s.v.nextthink = g_globalvars.time + 0.5;
		newmis->s.v.think = ( func_t ) bubble_bob;
		newmis->s.v.touch = ( func_t ) bubble_remove;
		newmis->s.v.classname = "bubble";
		newmis->s.v.frame = 0;
		newmis->cnt = 0;
		setsize( newmis, -8, -8, -8, 8, 8, 8 );
	}
	self->s.v.health = self->s.v.health - 10;
	if ( owner->playerclass == PC_MEDIC )
		self->s.v.health = self->s.v.health - 10;
	if ( self->s.v.health < 0 )
		self->s.v.health = 0;
	self->s.v.nextthink = g_globalvars.time + 0.25;
	pos = trap_pointcontents( PASSVEC3( owner->s.v.origin ) );
	src[0] = owner->s.v.origin[0] + owner->s.v.maxs[0] + 2;
	src[1] = owner->s.v.origin[1] + owner->s.v.maxs[1] + 2;
	src[2] = owner->s.v.origin[2];
	pos = trap_pointcontents( PASSVEC3( src ) );
	if ( ( ( int ) owner->s.v.flags & FL_ONGROUND ) || ( ( int ) owner->s.v.flags & 16 ) )
	{
		if ( !owner->is_feigning )
		{
			trap_makevectors( owner->s.v.v_angle );
			stumble[0] =
			    crandom(  ) * g_globalvars.v_forward[0] * self->s.v.health +
			    crandom(  ) * g_globalvars.v_right[0] * self->s.v.health;
			stumble[1] =
			    crandom(  ) * g_globalvars.v_forward[1] * self->s.v.health +
			    crandom(  ) * g_globalvars.v_right[1] * self->s.v.health;
			stumble[2] =
			    crandom(  ) * g_globalvars.v_forward[2] * self->s.v.health +
			    crandom(  ) * g_globalvars.v_right[2] * self->s.v.health;
			if ( !( pos == -2 && VectorCompareF( owner->s.v.velocity, 0, 0, 0 ) ) )
			{
				VectorAdd( owner->s.v.velocity, stumble, owner->s.v.velocity );
				owner->s.v.fixangle = 1;
			}
		}
	}
	if ( !self->s.v.health )
	{
		G_sprint( owner, 2, "Your head feels better now.\n" );
		dremove( self );
	}
}

void TeamFortress_AutoScan(  )
{
	gedict_t *oldself;

	oldself = self;
	self = PROG_TO_EDICT( oldself->s.v.owner );
	TeamFortress_Scan_Angel( self->ScanRange, 1 );
	self = oldself;
	self->s.v.nextthink = g_globalvars.time + TF_AUTOSCAN_TIME;
}

void ScannerSwitch(  )
{
	gedict_t *te;

	if ( self->ScannerOn != 1 )
	{
		te = spawn(  );
		te->s.v.nextthink = g_globalvars.time + TF_AUTOSCAN_TIME;
		te->s.v.think = ( func_t ) TeamFortress_AutoScan;
		te->s.v.owner = EDICT_TO_PROG( self );
		te->s.v.classname = "timer";
		te->s.v.netname = "scanner";
		G_sprint( self, PRINT_HIGH, "Scanner On.\n" );
		self->ScannerOn = 1;
	} else
	{
		for ( te = world; ( te = trap_find( te, FOFS( s.v.netname ), "scanner" ) ); )
		{
			if ( te->s.v.owner == EDICT_TO_PROG( self ) )
			{
				dremove( te );
				break;
			}
		}
		G_sprint( self, PRINT_HIGH, "Scanner Off.\n" );
		self->ScannerOn = 0;
	}
	self->StatusRefreshTime = g_globalvars.time + 0.1;
}

void ConcPlayer( gedict_t*p, gedict_t*attacker )
{
        gedict_t* te;
       	// Concuss 'em!!
       	// If they are already concussed, set the concussion back up
       	// Try to find a concusstimer entity for this player

       	G_sprint( p, 2, "You are conced\n" );
       	for ( te = world; ( te = trap_find( te, FOFS( s.v.classname ), "timer" ) ); )
       	{
       		if ( te->s.v.owner != EDICT_TO_PROG( p ) )
       			continue;
       		if ( te->s.v.think == ( func_t ) ConcussionGrenadeTimer )
       			break;
       		if ( te->s.v.think == ( func_t ) OldConcussionGrenadeTimer )
       			break;
       	}
       	if( !te )
       	{
       	        te = spawn(  );
       	        te->s.v.classname = "timer";
       	        te->s.v.owner = EDICT_TO_PROG( p );
       	        te->team_no = (attacker)?attacker->team_no:p->team_no;
       	        if ( tf_data.old_grens == 1 )
               	        stuffcmd( p, "bf\n" );
       	}
       	if ( tf_data.old_grens == 1 )
       	{
     		stuffcmd( p, "v_idlescale 100\n" );
     		stuffcmd( p, "fov 130\n" );
     		te->s.v.think = ( func_t ) OldConcussionGrenadeTimer;
     		te->s.v.health = 100;
     		te->s.v.nextthink = g_globalvars.time + 5;
     	} else
     	{
     	        te->s.v.think = ( func_t ) ConcussionGrenadeTimer;
     		te->s.v.health = 800;
     		te->s.v.nextthink = g_globalvars.time + 0.25;
       	}

       	if ( tg_data.gren_time )
       		te->gren_eff_time = g_globalvars.time + tg_data.gren_time;
}
//=========================================================================
// Acts just like T_RadiusDamage, but doesn't damage things, just pushes them away
// from the explosion at a speed relative to the distance from the explosion's origin.
void T_RadiusBounce( gedict_t * inflictor, gedict_t * attacker, float bounce, gedict_t * ignore )
{
	float   points;
	gedict_t *head;
	vec3_t  org, dist;

	for ( head = world; ( head = trap_findradius( head, inflictor->s.v.origin, bounce + 40 ) ); )
	{
		if ( head == ignore )
			continue;
		if ( head->s.v.takedamage == 0 )
			continue;
		VectorAdd( head->s.v.mins, head->s.v.maxs, org );
		VectorScale( org, 0.5, org );
		VectorAdd( head->s.v.origin, org, org );
		VectorSubtract( org, inflictor->s.v.origin, dist );
		points = 0.5 * vlen( dist );

		if ( points < 0 )
			points = 0;
		points = bounce - points;
		if ( points <= 0 )
			continue;
		if ( streq( head->s.v.classname, "building_dispenser" ) )
			continue;
		if ( streq( head->s.v.classname, "building_sentrygun" ) )
			continue;
		if ( streq( head->s.v.classname, "building_sentrygun_base" ) )
			continue;

		// Bounce!!
		VectorScale( dist, ( points / 20.0 ), head->s.v.velocity );
		if ( strneq( head->s.v.classname, "player" ) )
		{
			if ( ( int ) head->s.v.flags & FL_ONGROUND )
				head->s.v.flags = ( int ) head->s.v.flags - FL_ONGROUND;
		} else
		{
			if ( tg_data.gren_effect == TG_GREN_EFFECT_OFF )
				continue;

			if ( head == PROG_TO_EDICT( inflictor->s.v.owner )
			     && tg_data.gren_effect == TG_GREN_EFFECT_OFF_FORSELF )
				continue;

			// Concuss 'em!!
			ConcPlayer( head, attacker );
		}
	}
}


//////////////////////////////////////////

void TeamFortress_Scan_Angel( int scanrange, int typescan )
{
	gedict_t *list;
	gedict_t *saveent = NULL;
	float   minlen;
	float   len;
	float   scen;
	float   scfr;
	vec3_t  lightningvec;
	float   enemy_detected;
	float   friend_detected;
	float   any_detected;
	float   any_detected2;
	vec3_t  tmp;
	float   multiscan;
//	char    st[10];
//	int     opt;

	// prevent scan impulse from triggering anything else
	self->s.v.impulse = 0;
	self->last_impulse = 0;

	if ( strneq( self->s.v.classname, "player" ) )
		return;

	if ( !( self->tf_items & NIT_SCANNER ) )
		return;
	// If Impulse is TF_SCAN_ENEMY, toggle Scanning for Enemies
	if ( scanrange == TF_SCAN_ENEMY )
	{
		if ( self->tf_items_flags & NIT_SCANNER_ENEMY )
		{
			G_sprint( self, 2, "Enemy Scanning disabled.\n" );
			self->tf_items_flags -= NIT_SCANNER_ENEMY;
			self->StatusRefreshTime = g_globalvars.time + 0.1;
			return;
		}
		G_sprint( self, PRINT_HIGH, "Enemy Scanning enabled.\n" );
		self->tf_items_flags |= NIT_SCANNER_ENEMY;
		self->StatusRefreshTime = g_globalvars.time + 0.1;
		return;
	}
	
	// If Impulse is TF_SCAN_FRIENDLY, toggle Scanning for Friendlies
	if ( scanrange == TF_SCAN_FRIENDLY )
	{
		if ( self->tf_items_flags & NIT_SCANNER_FRIENDLY )
		{
			G_sprint( self, PRINT_HIGH, "Friendly Scanning disabled.\n" );
			self->tf_items_flags -= NIT_SCANNER_FRIENDLY;
			self->StatusRefreshTime = g_globalvars.time + 0.1;
			return;
		}
		G_sprint( self, PRINT_HIGH, "Friendly Scanning enabled.\n" );
		self->tf_items_flags |= NIT_SCANNER_FRIENDLY;
		self->StatusRefreshTime = g_globalvars.time + 0.1;
		return;
	}
	if ( scanrange == TF_POST_SCANF_OFF )
	{
		G_sprint( self, PRINT_HIGH, "Friendly Scanning disabled.\n" );
		if ( self->tf_items_flags & NIT_SCANNER_FRIENDLY )
			self->tf_items_flags -= NIT_SCANNER_FRIENDLY;
		self->StatusRefreshTime = g_globalvars.time + 0.1;
		return;
	}

	if ( scanrange == TF_POST_SCANF_ON )
	{
		G_sprint( self, PRINT_HIGH, "Friendly Scanning enabled.\n" );
		self->tf_items_flags |= NIT_SCANNER_FRIENDLY;
		self->StatusRefreshTime = g_globalvars.time + 0.1;
		return;
	}

	if ( scanrange == TF_POST_SCANE_OFF )
	{
		G_sprint( self, PRINT_HIGH, "Enemy Scanning disabled.\n" );
		if ( self->tf_items_flags & NIT_SCANNER_ENEMY )
			self->tf_items_flags -= NIT_SCANNER_ENEMY;
		self->StatusRefreshTime = g_globalvars.time + 0.1;
		return;
	}
	if ( scanrange == TF_POST_SCANE_ON )
	{
		G_sprint( self, PRINT_HIGH, "Enemy Scanning enabled.\n" );
		self->tf_items_flags |= NIT_SCANNER_ENEMY;
		self->StatusRefreshTime = g_globalvars.time + 0.1;
		return;
	}
	if ( scanrange == TF_POST_AUTOSCAN_ON )
	{
		if ( self->ScannerOn != 1 )
		{
			ScannerSwitch(  );
		} else
		{
			G_sprint( self, PRINT_HIGH, "Scanner On.\n" );
		}
	}

	if ( scanrange == TF_POST_AUTOSCAN_OFF )
	{
		if ( self->ScannerOn == 1 )
		{
			ScannerSwitch(  );
		} else
		{
			G_sprint( self, PRINT_HIGH, "Scanner Off.\n" );
		}
	}

	if ( scanrange > 50 )
		scanrange = 50;

	if ( self->ScanRange != scanrange )
	{
		self->ScanRange = scanrange;
		self->StatusRefreshTime = g_globalvars.time + 0.1;
	}
	scen = 0;
	scfr = 0;
	// Set the Scanner flags
	if ( self->tf_items_flags & NIT_SCANNER_ENEMY )
		scen = 1;
	if ( self->tf_items_flags & NIT_SCANNER_FRIENDLY )
		scfr = 1;

	// If no entity type is enabled, don't scan
	if ( !scen && !scfr )
	{
		G_sprint( self, PRINT_HIGH, "All scanner functions are disabled.\n" );
		return;
	}
	multiscan = ( self->settings_bits & TF_MULTISCAN_MASK) ? 0: 1;

	if ( typescan == 0 )
		G_sprint( self, PRINT_HIGH, "Scanning...\n" );
	any_detected2 = 0;
	scanrange = scanrange * 25;
	minlen = scanrange + 100;
	for ( list = world; ( list = trap_findradius( list, self->s.v.origin, scanrange + 40 ) ); )
	{
		enemy_detected = 0;
		friend_detected = 0;
		any_detected = 0;
		if ( list == self )
			continue;
		if ( strneq( list->s.v.classname, "player" ) )
			continue;
		if ( !list->s.v.takedamage )
			continue;
		if ( list->s.v.health <= 0 )
			continue;
		if ( teamplay )
		{
			if ( scfr && list->team_no > 0 && list->team_no == self->team_no )
			{
				friend_detected = 1;
				any_detected = 1;
			}
			if ( scen && ( self->team_no > 0 ) && ( list->team_no > 0 )
			     && ( list->team_no != self->team_no ) )
			{
				enemy_detected = 1;
				any_detected = 1;
			}
		} else
		{
			any_detected = 1;
			if ( ( self->tf_items_flags & 4 ) && ( vlen( list->s.v.velocity ) <= 50 ) )
				any_detected = 0;
		}
		if ( any_detected )
		{
			any_detected2 = 1;
			VectorSubtract( list->s.v.origin, self->s.v.origin, tmp );
			if ( multiscan == 0 )
			{

				len = vlen( tmp );
				if ( !saveent || ( len < minlen ) )
				{
					saveent = list;
					minlen = len;
				}
			} else
			{
				normalize( tmp, lightningvec );
				VectorScale( lightningvec, vlen( tmp ) / 5, lightningvec );
				VectorAdd( lightningvec, self->s.v.origin, lightningvec );
				g_globalvars.msg_entity = EDICT_TO_PROG( self );
				trap_WriteByte( MSG_ONE, SVC_TEMPENTITY );
				trap_WriteByte( MSG_ONE, TE_LIGHTNING1 );
				WriteEntity( MSG_ONE, list );
				trap_WriteCoord( MSG_ONE, self->s.v.origin[0] );
				trap_WriteCoord( MSG_ONE, self->s.v.origin[1] );
				trap_WriteCoord( MSG_ONE, self->s.v.origin[2] + 8 );
				trap_WriteCoord( MSG_ONE, lightningvec[0] );
				trap_WriteCoord( MSG_ONE, lightningvec[1] );
				trap_WriteCoord( MSG_ONE, lightningvec[2] + 8 );
			}
		}
	}

	if ( ( multiscan == 0 ) && saveent )
	{
      		VectorSubtract( saveent->s.v.origin, self->s.v.origin, tmp );
      		normalize( tmp, lightningvec );
      		VectorScale( lightningvec, vlen( tmp ) / 5, lightningvec );
      		VectorAdd( lightningvec, self->s.v.origin, lightningvec );
      		g_globalvars.msg_entity = EDICT_TO_PROG( self );
      		trap_WriteByte( MSG_ONE, SVC_TEMPENTITY );
      		trap_WriteByte( MSG_ONE, TE_LIGHTNING1 );
      		WriteEntity( MSG_ONE, saveent );
      		trap_WriteCoord( MSG_ONE, self->s.v.origin[0] );
      		trap_WriteCoord( MSG_ONE, self->s.v.origin[1] );
      		trap_WriteCoord( MSG_ONE, self->s.v.origin[2] + 8 );
      		trap_WriteCoord( MSG_ONE, lightningvec[0] );
      		trap_WriteCoord( MSG_ONE, lightningvec[1] );
      		trap_WriteCoord( MSG_ONE, lightningvec[2] + 8 );
	}

	if ( typescan == 0 && any_detected2 == 0 )
		G_sprint( self, PRINT_HIGH, "No blips.\n" );

	W_SetCurrentAmmo(  );
	return;
}

