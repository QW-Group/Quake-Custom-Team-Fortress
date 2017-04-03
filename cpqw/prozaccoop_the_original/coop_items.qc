/*
	coop_items.qc

	FIXME: rename to coop_ents.qc or coop_entities.qc
*/

#ifndef COOP_MODE_ENHANCED
#pragma DONT_COMPILE_THIS_FILE
#else

/*
=============
weapon_dummy_touch
=============
*/
void() weapon_dummy_touch =
{
	if ( !( other.flags & #FL_CLIENT ) )
		return;

	sound( other, #CHAN_ITEM, self.noise, 1, #ATTN_NORM );

	Respawn_Item( self, other );

	self.touch = SUB_Null;
	self.nextthink = time + 0.1;
	self.think = SUB_Remove;
};

/*
=============
weapon_dummy

Only exists when the weapon has targets it needs to fire
when picked up, since some maps depend upon that.
This is not an entity spawned by maps, it's called by each
weapon_*** function in items.qc.
Returns #TRUE if the weapon should exist, and #FALSE if it was removed.
=============
*/
float() weapon_dummy =
{
	if (!self.killtarget && !self.target) {
		remove (self);
		return #FALSE;
	}

	// grenade3.mdl is the gift model from the birthday mode
	// couldn't think of a better model, didn't want to just use the weapon
	// because it's not really a weapon, nor does it give you any ammo
	// a spinning model that says 'pick me up' would be the best
	precache_model ("progs/grenade3.mdl");
	setmodel (self, "progs/grenade3.mdl");
	self.touch = weapon_dummy_touch;
	self.noise = "misc/medkey.wav";
	precache_sound (self.noise);

	return #TRUE;
};

//============================================================================

#define touch_finished	attack_finished			// this allows trigger_monsterteam entities with targetname to be touched

/*
=============
monsterteam_touch
=============
*/
void() monsterteam_touch = {
	local entity	te;

	if ( other.takedamage )
	if ( other.health <= 0 )
		return;
	if ( other.flags & #FL_CLIENT )
		return;
	if ( !npcAi_IsCoopMonster( other ) )
		return;				// not a coop monster
	if ( other.deadflag )
		return;

	if ( self.team_no ) {
		if ( other.team_no != self.team_no )
			return;			// wrong team
	}

	if ( self.targetname ) {
		if ( self.#touch_finished < time )
			return;			// not fired yet
		else {
			if ( self.spawnflags & 2 ) {
				// every monster except the one that fired can get changed
				if ( other == self.enemy ) {
					self.enemy = world;
					return;
				}
			} else if ( self.spawnflags & 4 ) {
				if ( other == self.enemy )	// if it's the activator, reset .enemy and fire the targets
					self.enemy = world;
				else					// some other monster besides the activator, just return
					return;
			}

			// trigger-touch bypasses .wait for obvious reasons
			self.nextthink = time;
		}
	}

	// already triggered
	if ( self.nextthink > time )
		return;

	// tf goal code
	if (!Activated(self,other))
	{
		// If an else goal should be activated, activate it
		if (self.else_goal != 0)
		{
			te = Findgoal(self.else_goal);
			if (te)
				DoResults(te, other, (self.goal_result & #TFGR_ADD_BONUSES));
		}

		return;
	}

	// valid monster has touched the trigger
	if ( self.team )
		other.team_no = self.team;

	activator = other;
	SUB_UseTargets();

	if ( !self.targetname ) {
		// allow zero to be instant no waits
		if ( self.wait < 0 ) {
			self.use = SUB_Null;		// don't allow it to be triggered again
			self.touch = SUB_Null;
			self.nextthink = time + 0.1;
			self.think = SUB_Remove;
		} else
			self.nextthink = time + self.wait;
	}
};

/*
=============
monsterteam_use
=============
*/
void() monsterteam_use = {
	local entity	te;
	local float		numChanged;

	// don't allow non-players to fire the trigger if spawnflags 1 is present
	if ( self.spawnflags & 1 && !( activator.flags & #FL_CLIENT ) )
		return;
	// already triggered
	if ( self.nextthink > time )
		return;

	if ( self.event ) {
		numChanged = 0;

		te = find( world, targetname, self.event );
		while ( te ) {
			if ( ( te.deadflag == #DEAD_NO && npcAi_IsCoopMonster( te ) ) || te.classname == "respawning monster" ) {
				if ( !( self.spawnflags & 2 ) || te != activator )
				if ( !( self.spawnflags & 4 ) || te == activator )
				if ( !self.team_no || te.team_no == self.team_no )
				if ( te.team_no != self.team ) {
					te.team_no = self.team;
					numChanged = 1;	// for now we don't care how many, just that some were
				}
			}

			te = find( te, targetname, self.event );
		}

		if ( numChanged ) {
			SUB_UseTargets();

			// allow zero to be instant no waits
			if ( self.wait < 0 ) {
				self.use = SUB_Null;		// don't allow it to be triggered again
				self.nextthink = time + 0.3;	// leave time for it to be trigger-touched
				self.think = SUB_Remove;
			} else
				self.nextthink = time + self.wait;
		}
	}

	// spawnflags 8 means no touch, so return if it's present
	if ( self.spawnflags & 8 )
		return;

	// spawnflags 2 changes every monster's team except the one that fired the trigger
	// spawnflags 4 changes only the activator's team
	if ( self.spawnflags & 2 || self.spawnflags & 4 )
		self.enemy = activator;

	// allow the trigger to be touched
	self.#touch_finished = time + 0.2;
	force_retouch = 2;		// make sure even still objects get hit
};

/*QUAKED trigger_monsterteam (.5 .5 .5) PLAYER_ONLY NOACTIVATOR ACTIVATOR_ONLY NOTOUCH
Gizmo - Any non-player owned monster touching this (unless the notouch spawnflag is set) will have it's team changed to the value in the "team" field if set. If the "team_no" field is set, only monsters belonging to the "team_no" team will have their team changed to the "team" field.
The trigger_monsterteam will fire it's targets if it has been touched and notouch isn't present (even if "team" isn't present), or if the trigger_monsterteam is fired and "event" is present and at least one monster (that isn't already on "team") is affected.
This trigger can have all the fields a trigger_relay can have for firing it's targets.

If the trigger_monsterteam has the "event" field, all monsters that have a matching "targetname" field will have their team set to "team" when fired, spawnflags and "team_no" still apply when this happens. Note that "event" works on monsters that are dead and are respawning but haven't respawned yet, whereas with touch this is not possible.
If the trigger_monsterteam has a "targetname" field, it will only change any monster's teams by touch or "event" when it has been fired.

If the trigger_monsterteam has a "wait" field, it waits this amount of time before it's able to be
fired again after it has been fired. If it has a "targetname" field, then "wait" affects how often
it can be fired. If it does not have a "targetname" field, then "wait" affects how often it can be touched.
Note that if "targetname" is present then the wait time does not affect the trigger being touched
after the trigger_monsterteam has been fired to touch entities. If "wait" is less than zero then the
trigger removes itself after being used and firing it's targets (triggered touches still work).

If the trigger_monsterteam has a "targetname" the following spawnflags are valid:
Bit 1:	Can only be fired by players (IE: if a monster dies from another monster and the dead monster has a "target" matching the trigger_monsterteam's "targetname" the trigger_monsterteam will not be fired).
Bit 2:	Every monster except the monster that fired the trigger_monsterteam (and those filtered by the "team_no" field) can get their team changed.
Bit 4:	Only the monster that fired the trigger_monsterteam can get it's team changed, if it's "team_no" matches. (cannot be used in conjunction with 2)
Bit 8:	The trigger_monsterteam cannot be touched
*/
void() trigger_monsterteam = {
	if ( CheckExistence() == #FALSE ) {
		dremove( self );
		return;
	}

	if ( deathmatch ) {
		remove( self );
		return;
	}

	if ( self.event )
	if ( !self.targetname )
		objerror( "event without targetname doesn't do anything" );

	if ( self.spawnflags & 8 )
	if ( !self.targetname )
		objerror( "notouch without targetname would be useless" );

	if ( self.spawnflags & 2 && self.spawnflags & 4 )
		objerror( "noactivator and activator_only doesn't make sense" );

	InitTrigger();
	if ( !( self.spawnflags & 8 ) )
		self.touch = monsterteam_touch;
	self.use = monsterteam_use;
	self.think = SUB_Null;
};

#undef touch_finished

//============================================================================

void() info_tfgoal;

/*QUAKED info_tfgoal_monster (.5 .5 .5)
Gizmo - Exactly the same as a normal info_tfgoal except this only allows coop monsters to touch.
*/
void() info_tfgoal_monster = {
	// Gizmo - this is a separately named entity so we can have
	// a portable way of letting an info_tfgoal know it allows monsters to touch
	// DO NOT set option2 manually in an info_tfgoal in your map, it's not guaranteed to work
	self.option2 = 1;

	self.classname = "info_tfgoal";
	info_tfgoal();
};

//============================================================================

void() multi_trigger;
void() multi_touch;
void() trigger_multiple;

/*
=============
multi_touch_monster
=============
*/
void() multi_touch_monster = {
	local entity	te;

	// Gizmo - this differs from a standard trigger_multiple
	if ( self.team_no )
	if ( other.team_no != self.team_no )	// Gizmo - we don't use Teammate() here because the trigger may not want allied teams to touch
		return;

	if ( !npcAi_IsCoopMonster( other ) )
		return;

	if (other.health <= 0) // dead players out
		return;

	if (!Activated(self,other))
	{
		// If an else goal should be activated, activate it
		if (self.else_goal != 0)
		{
			te = Findgoal(self.else_goal);
			if (te)
				DoResults(te, other, (self.goal_result & #TFGR_ADD_BONUSES));
		}

		return;
	}

// if the trigger has an angles field, check player's facing direction
	if (self.movedir != '0 0 0')
	{
		makevectors (other.angles);
		if (v_forward * self.movedir < 0)
			return;		// not facing the right way
	}

	self.enemy = other;
	multi_trigger();
};

/*
=============
multi_init_monster
=============
*/
void() multi_init_monster = {
	if ( self.touch == multi_touch )
		self.touch = multi_touch_monster;
};

/*QUAKED trigger_multiple_monster (.5 .5 .5) ? notouch
Gizmo - Exactly the same as a normal trigger_multiple except this only allows coop monsters to touch,
and the team_no field applies to touching.
*/
void() trigger_multiple_monster =
{
	// the entity may have been removed afterwords
	self.nextthink = time + 0.1;
	self.think = multi_init_monster;

	trigger_multiple();
};

#endif
