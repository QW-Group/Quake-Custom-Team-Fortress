/*
	common.qc - ai replacement functions, less messy and possibly improved upon
	TODO: move into another folder and rename to something generic like npc_ai.qc or something
*/

#ifndef COOP_MODE_ENHANCED
#pragma DONT_COMPILE_THIS_FILE
#else


.float() OnNoticeEnemy;						// self.enemy is the enemy noticed, return false for invalid targets
//.void() OnRespawn;						// self is the new entity respawning
.float() OnPreAttack;						// self is about to attack self.enemy, return false to prevent

float monster_mode;						// updated every 1.3 seconds from infokey() if at least one monster is present


/*
	COOP_IsCoopMonster - returns true only if this is a coop monster, not if it's a monster in general
*/

float( entity test ) COOP_IsCoopMonster = {
	if ( test.#npc_isCoopMonster )
	if ( IsMonster( test ) )
		return #TRUE;
	return #FALSE;
};

//==============================================================================


/*
	COOP_FindShootOffset - replacement for COOP_SightBlocked()
*/

float (entity start, entity end) COOP_FindShootOffset =
{
	local vector startVec, tempVec;

	makevectors (start.angles);

// set the initial monster's point of view for the line of sight check
	startVec = start.origin + start.#npc_attackoffset;

// start checking for any visible line of sight to enemy
	traceline (startVec, end.origin, #TL_ANY_SOLID, start);
	if (trace_ent == end && (!trace_inopen || !trace_inwater)) {
		start.#npc_enemyoffset = '0 0 0';
		return #TRUE;
	}

	start.#npc_enemyoffset = '0 0 16';
	traceline (startVec, end.origin + start.#npc_enemyoffset, #TL_ANY_SOLID, start);
	if (trace_ent == end && (!trace_inopen || !trace_inwater))
		return #TRUE;

	start.#npc_enemyoffset = end.view_ofs;
	traceline (startVec, end.origin + start.#npc_enemyoffset, #TL_ANY_SOLID, start);
	if (trace_ent == end && (!trace_inopen || !trace_inwater))
		return #TRUE;

	// start on end
//	makevectors (end.angles);
	tempVec = end.origin - startVec;
	tempVec_y = vectoyaw (tempVec);
	tempVec_x = 0;
	tempVec_z = 0;
	makevectors (tempVec);

	start.#npc_enemyoffset = v_right * end.mins_y;
	traceline (startVec, end.origin + start.#npc_enemyoffset, #TL_ANY_SOLID, start);
	if (trace_ent == end && (!trace_inopen || !trace_inwater))
		return #TRUE;

	start.#npc_enemyoffset = v_right * end.maxs_y;
	traceline (startVec, end.origin + start.#npc_enemyoffset, #TL_ANY_SOLID, start);
	if (trace_ent == end && (!trace_inopen || !trace_inwater))
		return #TRUE;

	start.#npc_enemyoffset = v_up * end.mins_z;
	traceline (startVec, end.origin + start.#npc_enemyoffset, #TL_ANY_SOLID, start);
	if (trace_ent == end && (!trace_inopen || !trace_inwater))
		return #TRUE;

	start.#npc_enemyoffset = v_up * end.maxs_z;
	traceline (startVec, end.origin + start.#npc_enemyoffset, #TL_ANY_SOLID, start);
	if (trace_ent == end && (!trace_inopen || !trace_inwater))
		return #TRUE;

	// corners
	start.#npc_enemyoffset = (v_up * end.maxs_z) + (v_right * end.maxs_y);
	traceline (startVec, end.origin + start.#npc_enemyoffset, #TL_ANY_SOLID, start);
	if (trace_ent == end && (!trace_inopen || !trace_inwater))
		return #TRUE;

	start.#npc_enemyoffset = (v_up * end.maxs_z) + (v_right * end.mins_y);
	traceline (startVec, end.origin + start.#npc_enemyoffset, #TL_ANY_SOLID, start);
	if (trace_ent == end && (!trace_inopen || !trace_inwater))
		return #TRUE;

	start.#npc_enemyoffset = (v_up * end.mins_z) + (v_right * end.maxs_y);
	traceline (startVec, end.origin + start.#npc_enemyoffset, #TL_ANY_SOLID, start);
	if (trace_ent == end && (!trace_inopen || !trace_inwater))
		return #TRUE;

	start.#npc_enemyoffset = (v_up * end.mins_z) + (v_right * end.mins_y);
	traceline (startVec, end.origin + start.#npc_enemyoffset, #TL_ANY_SOLID, start);
	if (trace_ent == end && (!trace_inopen || !trace_inwater))
		return #TRUE;

	return #FALSE;
};


/*
	COOP_SightBlocked - checks if an entity's sight to the given entity is blocked

	8/8/07: Gizmo - updated this function for better monster targeting
*/

float (entity start, entity end) COOP_SightBlocked =
{
	makevectors (start.angles);

	// return false if another entity or the map blocked our sight, also if we crossed contents

	traceline (start.origin + start.#npc_attackoffset, end.origin, #TL_ANY_SOLID, start);
	if (trace_ent != end)
		return #TRUE;
	if (trace_inopen && trace_inwater)
		return #TRUE;

/*
	traceline (start.origin + (v_right * start.mins_y), end.origin, #TL_ANY_SOLID, start);
	if (trace_ent != end)
		return #TRUE;
	if (trace_inopen && trace_inwater)
		return #TRUE;

	traceline (start.origin + (v_right * start.maxs_y), end.origin, #TL_ANY_SOLID, start);
	if (trace_ent != end)
		return #TRUE;
	if (trace_inopen && trace_inwater)
		return #TRUE;
*/

	return #FALSE;
};


/*
===============
COOP_IsValidTarget

NOTE: health and takedamage are not checked by this function
NOTE: this will change trace_ent
===============
*/
float( entity us, entity test ) COOP_IsValidTarget = {
	local float r;

	// if our target isn't solid then it's not a valid target
	if ( test.solid == #SOLID_NOT )
		return #FALSE;

	if ( IsOwnedMonster( test ) ) {
		if (!Teammate(test.real_owner.team_no, us.team_no))
			return #TRUE;
/*
	} else if (test.classname == "grenade" && test.netname == "land_mine") {
		if (!Teammate(test.owner.team_no, us.team_no))
			return #TRUE;
*/
	} else if (!Teammate(test.team_no, us.team_no)) {
		if (IsBuilding(test) && test.classname != "building_sentrygun_base") {
			if ( Tesla_IsCloaked( test ) )		// only do this here, so the global list will include it
				return #FALSE;				// and monsters will react faster
			return #TRUE;
		} else if (test.classname == "player") {
			r = vlen(test.origin - us.origin);

			// use Pharse_Client for client checking
			if ( Pharse_Client( test, us, 0, 0, 0, 0 ) ) {
				if ( r > 2048 && !visible2( test, us ) )
					return #FALSE;
				if (!(test.flags & #FL_NOTARGET) && !(test.items & #IT_INVISIBILITY)) {
					// check if he's a theif
					if (test.job & #JOB_THIEF && ((test.job & #JOB_ACTIVE && !(test.job & #JOB_FULL_HIDE) && r >= 140) || test.job & #JOB_FULL_HIDE))
						return #FALSE;

					return #TRUE;
				}
			}
		}
		else if ( IsMonster( test ) )		// IsMonster() should return true for both coop and non-coop monsters
			return #TRUE;
	}

	return #FALSE;
};

/*
===============
COOP_GetTargetPriority

The maximum value this can return is 2. Distance calculation can
add up to 1, and the target's priority in general can add another 1.
NOTE: this assumes e is an enemy.
NOTE: this will change trace_ent
===============
*/
float( entity scanner, entity e ) COOP_GetTargetPriority = {
	local float	priority, ftmp;

	// include distance in all priority calculations (adds up to nearly 1) (TODO: include sizebox in calculation so it _can_ return 1?)
	priority = vlen( e.origin - scanner.origin );
	priority = 1 - priority / 4096;
	if ( priority < 0 )
		priority = 0;

	// if there's an obstacle between us, lower the priority
	traceline( scanner.origin + scanner.view_ofs, e.origin, #TL_ANY_SOLID, scanner );
	if ( trace_ent != e && trace_fraction != 1 )
		priority = priority - 0.3;		// we will always add at least 0.3 below

	// checking for monsters first can possibly be faster because IsBuilding() compares strings
	if ( IsMonster( e ) ) {
		// prefer monsters that are targeting us
		if ( e.enemy == scanner )
			priority = priority + random() * 0.5;

		// protect our comrades!!
		else if ( e.enemy != world ) {
			if ( e.enemy != e ) {
				ftmp = GetTeam( e.enemy );
				if ( Teammate( ftmp, scanner.team_no ) )
					priority = priority + random() * 0.4;
			}
		}

		// monster priority can return up to 2 if the enemy monster is targeting us
		return priority + 0.5;
	}

	if ( IsBuilding( e ) ) {
		// prefer dispensers before everything (except maybe enemy monsters targeting us)
		if ( e.classname == "building_dispenser" )
			return priority + 1;
		// builds that don't attack have lower priority than those that do
		if ( !IsOffenseBuilding( e ) )
			return priority + 0.4;
		return priority + 0.9;
	}

	// client bonuses can add up to 0.2 for a total of 0.5 plus distance priority
	if ( e.flags & #FL_CLIENT ) {
		// give active chaplans an extra bonus
		if ( e.job & #JOB_CHAPLAN && e.job & #JOB_ACTIVE )
			priority = priority + 0.1;
		// give snipers a small bonus also
		else if ( e.current_weapon == #WEAP_SNIPER_RIFLE )
			priority = priority + 0.1;
		else if ( e.current_weapon == #WEAP_ASSAULT_CANNON )
			priority = priority + 0.1;

		// check if he's facing our general direction
		if ( random() < 0.5 ) {
			makevectors( e.v_angle );
			if ( normalize( scanner.origin - e.origin ) * v_forward > 0.3 )
				priority = priority + 0.1;
		}
	}
		
	// some other kind of enemy to destroy, 1.3 is max here for non-players, and 1.5 is max for players
	return priority + 0.3;
};


/*
	COOP_FindTarget - finds something we should attack
*/

float worldscan_delay;
entity npc_teamLists;
.entity npc_nextTeamList;
.entity npc_nextEntInTeamList;

entity( float t ) COOP_GetTeamList = {
	local entity cur;

	cur = npc_teamLists;
	while ( cur ) {
		if ( Teammate( cur.team_no, t ) )
			return cur;

		cur = cur.npc_nextTeamList;
	}

	return world;
};

void( entity list ) COOP_AddTeamList = {
	// npc_teamLists points to the first one
	if ( npc_teamLists == world ) {
		npc_teamLists = list;
		list.npc_nextTeamList = world;
		list.npc_nextEntInTeamList = world;
		return;
	}

	// NOTE: this MUST be a backwards list, because every entity's npc_nextTeamList field points to the next team
	// and if this isn't a backwards list, then you would have to go through and update every entity's npc_nextTeamList
	// on the last teamlist (or maybe just the last entity on it), which would all point to world since it was the last,
	// but is no longer the last. This way, every entity's npc_nextTeamList always remains correct when we add new lists
	list.npc_nextEntInTeamList = world;
	list.npc_nextTeamList = npc_teamLists;
	npc_teamLists = list;
};

entity _npc_lastTeamEntity;
void( entity e ) COOP_AddToTeamList = {
	local entity list;

	// this is to enhance performance, and to prevent runaway loop errors
	// it prevents us from going through every ent every time in the current list for every entity we add to it
	if ( npc_teamLists == world || _npc_lastTeamEntity == world || !Teammate( _npc_lastTeamEntity.team_no, e.team_no ) ) {
		list = COOP_GetTeamList( e.team_no );

		if ( list == world ) {
			COOP_AddTeamList( e );
			return;
		}

		while ( list.npc_nextEntInTeamList != world )
			list = list.npc_nextEntInTeamList;
	} else
		list = _npc_lastTeamEntity;

	list.npc_nextEntInTeamList = e;
	e.npc_nextEntInTeamList = world;
	e.npc_nextTeamList = list.npc_nextTeamList;			// this fixes monsters not seeing other teams, used to be "= world"
	_npc_lastTeamEntity = e;
};

entity (entity scanner) COOP_FindTarget =
{
	local entity	head;
	local entity	best;
	local float		bestPriority, priority;

/*
	// this is here to ease cpu with maps that have a lot of monsters, also adds a human factor for delayed notice
	if (scanner.#npc_noticedelay > time)
		return world;

	// use a random delay so it doesn't all happen at once
	self.#npc_noticedelay = time + 0.5 + random();		// old delay was 1.3

	// FIXME: weigh pros and cons of find vs findradius: cpu, etc.
	head = findradius (scanner.origin, 2048);

	while (head) {
		// seems to be a compiler bug or something, it doesn't work right when the "if" is all on one line
		if (visible2(head, scanner) && head.takedamage && head.health > 0) {
			if (COOP_IsValidTarget(scanner, head))
				return head;
		}

		head = head.chain;
	}

	return world;
*/

	// check if we should scan for new entities that weren't present before
	if ( worldscan_delay <= time ) {
		// update the monster_mode global
		monster_mode = stof( infokey( world, "monster_mode" ) );

		// rescan the valid entity lists
		npc_teamLists = world;
		_npc_lastTeamEntity = world;		// this fixes the monsters randomly not finding targets because of this being some entity that isn't linked in the teamlist

		head = findradius( world.origin, 65536 );

		while ( head ) {
			if ( IsMonster( head ) )			// used IsMonster() so coop monsters and owned monsters are added
				COOP_AddToTeamList( head );
			else if ( IsBuilding(head) ) {
				// don't compare this string unless it's a building, since QC doesn't have short-circuit logical ops
				// also this prevents further checks if it's the building_sentrygun_base
				if ( head.classname != "building_sentrygun_base" )
					COOP_AddToTeamList( head );
			} else if ( head.flags & #FL_CLIENT )	// this will probably add spectators too, but comparing a string is much slower for every ent
				COOP_AddToTeamList( head );

			head = head.chain;
		}

		worldscan_delay = time + 1.3;

		// return here to prevent us from doing too much at once and possibly tripping the infinite loop counter
		return world;
	}

	// this is here to ease cpu with maps that have a lot of monsters, also adds a human factor for delayed notice
	if (scanner.#npc_noticedelay > time)
		return world;

	// check for the non-targeting mode
	if ( monster_mode & 4 )
		return world;

	// use a random delay so it doesn't all happen at once
	scanner.#npc_noticedelay = time + 0.3 + random();		// old delay was 1.3

	if ( npc_teamLists == world )
		return world;

	best = world;
	bestPriority = 0;

	head = npc_teamLists;
	while ( head != world && Teammate( head.team_no, scanner.team_no ) )
		head = head.npc_nextTeamList;

	while ( head ) {
		if (visible2(head, scanner) && head.takedamage && head.health > 0) {
			// Gizmo - now that monsters can hear sounds, only make them see things infront
			if ( infront2( head, scanner ) )
			if (COOP_IsValidTarget(scanner, head)) {
				priority = COOP_GetTargetPriority( scanner, head );
				if ( priority > bestPriority ) {
					best = head;
					bestPriority = priority;
				}
			}
		}

		if ( head.npc_nextEntInTeamList == world ) {
			do {
				head = head.npc_nextTeamList;
			} while ( head != world && Teammate( head.team_no, scanner.team_no ) );
		} else
			head = head.npc_nextEntInTeamList;
	}

	// if nothing was found, and there are active sounds from players, search for one within range
	if ( headActiveSound ) {
		if ( !best ) {
			// monsters with ambush don't pay attention to sounds
			if ( !( scanner.spawnflags & 1 ) ) {
				head = headActiveSound;
				do {
					priority = vlen( head.origin - scanner.origin );
					if ( priority <= 768 ) {
						priority = 1 - priority / 768;
						if ( random() < priority ) {
							if ( head.owner.takedamage && head.owner.health > 0 ) {
								if ( COOP_IsValidTarget( scanner, head.owner ) )
									return head.owner;
							}
						}
					}

					head = head.enemy;
				} while ( head );
			}

			return world;
		}
	}

	// players are always picked last, so if a player was found then return it, but if not best will be world
	// findradius() did this automatically because it returns a chain backward through the entity list
	return best;
};

//====================================

#define NPC_FRAMETIME			0.1
#define NPC_LERPTIME			0.031

/*
===============
COOP_SmoothFrame
===============
*/
void() COOP_SmoothFrame = {
	local float oldyaw;

	if ( time >= self.#npc_smoothtime ) {
		// FIXME: is it ok to call #npc_oldthink directly here?
		self.nextthink = time;
		self.think = self.#npc_oldthink;
		self.#npc_lastruntime = 0;
		return;
	}

	// make sure lastruntime is set to something
	if ( !self.#npc_lastruntime ) {
		self.#npc_lastruntime = self.lastruntime;

		self.nextthink = time + #NPC_LERPTIME;
		return;
	}

	movedist = ( self.#npc_smoothdist / #NPC_FRAMETIME ) * ( self.lastruntime - self.#npc_lastruntime );

	// movetogoal if there's distance to move, it should only be zero if SV_RunThink is in an infinite loop
	// this prevents infinite SV_RunThink loops in the engine
	if ( movedist ) {
		oldyaw = self.yaw_speed;
		self.yaw_speed = ( oldyaw / #NPC_FRAMETIME ) * ( self.lastruntime - self.#npc_lastruntime );
		movetogoal( movedist );
		self.yaw_speed = oldyaw;

		self.#npc_lastruntime = self.lastruntime;
		self.#npc_attemptednextthink = self.nextthink = time + #NPC_LERPTIME;
	} else if ( self.#npc_smoothdist ) {
		//bprint( #PRINT_HIGH, "infinite loop prevented!\n" );
		self.#npc_attemptednextthink = self.nextthink = self.#npc_attemptednextthink + 0.01;
	}
};

/*
===============
COOP_WalkSmooth

This is called, in sort of like a wrapper to movetogoal,
to provide lerping movement.
===============
*/
void( float dist ) COOP_WalkSmooth = {
	if ( !dist )
		return;

	// save old stuff
	self.#npc_oldthink = self.think;
	self.#npc_smoothtime = time + #NPC_FRAMETIME;

	self.#npc_smoothdist = dist;

	// set think function
//	self.nextthink = time + 0.031;
	self.think = COOP_SmoothFrame;

	// do one right away
	COOP_SmoothFrame();
};

//====================================

/*
===============
COOP_CanAttackEnemy
===============
*/
float( entity en ) COOP_CanAttackEnemy = {
	if ( /*!visible2( en, self ) || */!en.takedamage || en.health <= 0 )
		return #FALSE;
	if ( self.tfstate & #TFSTATE_PSIONIZED )
		return #FALSE;
	return #TRUE;
};

/*
===============
COOP_AttackTarget

Sets up the monster to start attacking his enemy.
===============
*/
float( entity en, float check ) COOP_AttackTarget = {
	local entity	lasten;
	local float		ret;

	// check if enemy is valid
	if ( check ) {
		lasten = self.enemy;
		self.enemy = en;

		if ( self.OnNoticeEnemy )
			ret = self.OnNoticeEnemy();
		else
			ret = #TRUE;

		// be sure not to call any run, walk, etc. functions here (could make the monster's frames stop)
		if ( !ret ) {
			self.enemy = lasten;
			return #FALSE;
		}
	}

	self.goalentity = self.enemy = en;

	self.nextthink = time + 0.1;
	self.think = self.th_run;

	self.ideal_yaw = vectoyaw( en.origin - self.origin );

	// erase last time
	self.#npc_lastEnemyTime = 0;

	return #TRUE;
};

/*
===============
COOP_NoticeEnemy
===============
*/
float() COOP_NoticeEnemy = {
	local entity	e;

	e = COOP_FindTarget( self );

	if ( e == world )
		return #FALSE;

// attack the target if valid
	if ( !COOP_AttackTarget( e, #TRUE ) )
		return #FALSE;

	return #TRUE;
};

/*
===============
COOP_Idle

Default idle function for searching.
===============
*/
void() COOP_Idle = {
	// if we got a target somehow, attack it
	if ( self.enemy != world && self.enemy != self )
		COOP_AttackTarget( self.enemy, #FALSE );

	if ( COOP_NoticeEnemy() )
		return;

	// check for pausetime
	if ( time > self.pausetime )
		self.th_walk();
};

/*
===============
COOP_Walk

Default walking function.
===============
*/
void( float dist ) COOP_Walk = {
	// make sure we're solid
	if ( self.solid == #SOLID_NOT )
		self.solid = #SOLID_SLIDEBOX;

	// if we got a target somehow, attack it
	if ( self.enemy != world && self.enemy != self )
		COOP_AttackTarget( self.enemy, #FALSE );

	if ( COOP_NoticeEnemy() )
		return;

	movedist = dist;
	movetogoal( dist );
};

/*
===============
COOP_Turn

Faces ideal_yaw slowly, doesn't move the monster.
===============
*/
void() COOP_Turn = {
	if ( self.enemy )
		self.ideal_yaw = vectoyaw( self.enemy.origin - self.origin );
	else if ( COOP_NoticeEnemy() )
		return;

	ChangeYaw();
};


/*
	COOP_Run - default run function
*/

void (float dist) COOP_Run =
{
	local entity	e;
	local float		sightblocked, r;
	local float		c_attack;

	// for other functions like slide if we use them
	movedist = dist;

// first check if our target is still valid
	if (self.enemy == world || self.enemy == self || self.enemy.health < 0 || !COOP_IsValidTarget(self, self.enemy)) {
		self.enemy = world;
		self.attack_state = #AS_STRAIGHT;

		// this used to have 'if ( self.movetarget )', but now we just compare the string, and it's perfectly safe if it's world
		// and if it's not a valid entity or world which would make the server crash, there's no way to check for that anyways...
		// except looping through every ent, which would be painfully slow, but maybe good for debug builds
		if (self.movetarget.classname == "path_corner") {
			// walk our path again
			self.goalentity = self.movetarget;
			self.th_walk ();
		} else {
			self.pausetime = 99999999;
			self.th_stand ();
		}
		return;
	}

// get default variables so we don't have to calculate them over and over
	sightblocked = (!COOP_FindShootOffset(self, self.enemy));
	r = range (self.enemy);

// check if he's in an attack state (usually for telling the monster to attack but face him first, attacking resets the state)
	// use these to tell the monster to not fire right away and aim at him
	if (self.attack_state && self.attack_state != #AS_STRAIGHT) {
		self.ideal_yaw = vectoyaw ((self.enemy.origin + self.#npc_enemyoffset) - self.origin);
		ChangeYaw ();

		// if sight is blocked, reset the attack state
		if ( sightblocked ) {
			self.attack_state = #AS_STRAIGHT;
			return;
		}

		if (self.attack_state == #AS_MELEE) {
			if (FacingIdeal()) {
				if (self.th_melee)
					self.th_melee ();
				self.attack_state = #AS_STRAIGHT;
			}
			return;
		} else if (self.attack_state == #AS_SLIDING) {
			local float ofs;

			if (sightblocked) {
				self.attack_state = #AS_STRAIGHT;
				return;
			}

			if (self.lefty)
				ofs = 90;
			else
				ofs = -90;
	
			if (!walkmove(self.ideal_yaw + ofs, movedist)) {
				self.lefty = 1 - self.lefty;
	
				walkmove (self.ideal_yaw - ofs, movedist);
			}
		} else if (self.attack_state == #AS_MISSILE) {
			if (FacingIdeal()) {
				if (self.th_missile)
					self.th_missile ();
				self.attack_state = #AS_STRAIGHT;
			}
			return;
		}
	}

// check if we can attack
	// TODO: possibly add another time for melee?
	if ( !sightblocked && COOP_CanAttackEnemy( self.enemy ) ) {
		// call the entity's custom attack checkers if they are present
		if (self.OnPreAttack)
			c_attack = self.OnPreAttack ();
		else
			c_attack = #TRUE;

		if (c_attack) {
			// mark this position as valid
			self.#npc_lastEnemyOrigin = self.enemy.origin;
			self.#npc_lastEnemyTime = time;

			if (r <= #RANGE_MELEE && visible(self.enemy)) {
				if (self.th_melee) {
					// TODO: check if facing, no that's done above if state is set
					self.th_melee ();
					return;
				}
			}
			if (self.th_missile) {
				if (self.attack_finished < time) {
					self.th_missile ();
					return;
				}
			}
		}

		if (r <= #RANGE_MELEE) {
			self.ideal_yaw = vectoyaw ((self.enemy.origin + self.#npc_enemyoffset) - self.origin);
			ChangeYaw ();
		}
	} else if (sightblocked) {
		e = COOP_FindTarget (self);

		if (e != world && e != self.enemy)
			COOP_AttackTarget( e, #FALSE );
/*	TODO: need to also face that direction
		else if ( random() > 0.80 ) {
			// check if we can shoot blindly where they last were, in hopes for a lucky shot
			if ( self.#npc_lastEnemyTime && time - self.#npc_lastEnemyTime < 10 ) {
				if ( self.attack_finished < time ) {
					if ( self.#NPCFireBlind ) {
						self.#NPCFireBlind();
						return;
					}
				}
			}
		}
*/
	}

// at this point we're either sliding or are just heading straight into the enemy
	if (self.attack_state == #AS_SLIDING)
		return;

	// decrease our speed if tranqed
	if ( self.tfstate & #TFSTATE_TRANQUILISED )
		dist = dist * #NPC_TRANQ_FACTOR;
	// decrease our speed if psionized
	if ( self.tfstate & #TFSTATE_PSIONIZED )
		dist = dist * #PSIONIC_MOVEFACTOR;

	// increase our speed by the factor if there is one set
	if (self.#npc_speedfactor)
		COOP_WalkSmooth (dist * self.#npc_speedfactor);
		//movetogoal (dist * self.#npc_speedfactor);
	else
		COOP_WalkSmooth (dist);
};


//====================================


// FIXME: this stuff isn't used, yet


/*
	COOP_RandomName
*/

/*
string () COOP_RandomName =
{
	local float rnum;

	rnum = random();

	if (rnum < 0.5)
		return "fido";
	else
		return "bob";
};
*/


/*
	COOP_GenerateMonsterName
*/

/*
string (entity monster) COOP_GenerateMonsterName =
{
	return monster.netname;
};
*/


//====================================

/*
==============
COOP_PrePain

Called when an entity using the AI functions is about to
have pain. This is called before .th_pain() is called.
NOTE: uses self
==============
*/
void( entity attacker ) COOP_PrePain = {
	local float	currentPriority, attackerPriority;
	local entity	oldTraceEnt;

	oldTraceEnt = trace_ent;

	// the .think will get overridden but that's ok
	if ( !self.enemy ) {
		if ( COOP_IsValidTarget( self, attacker ) )
			COOP_AttackTarget( attacker, #TRUE );

		trace_ent = oldTraceEnt;
		return;
	}

	// don't bother if our attacker is hurting us
	if ( attacker == self.enemy )
		return;

	if ( !visible( self.enemy ) ) {
		if ( COOP_IsValidTarget( self, attacker ) )
			COOP_AttackTarget( attacker, #FALSE );

		trace_ent = oldTraceEnt;
		return;
	}

	// otherwise check if the one attacking is a higher priority
	if ( random() < 0.45 ) {
		currentPriority = COOP_GetTargetPriority( self, self.enemy );
		attackerPriority = COOP_GetTargetPriority( self, attacker );

		// don't switch targets too often when multiple monsters are attacking us
		if ( IsMonster( self.enemy ) && IsMonster( attacker ) )
			currentPriority = currentPriority + 0.5;

		if ( attackerPriority > currentPriority ) {
			if ( COOP_IsValidTarget( self, attacker ) )
				COOP_AttackTarget( attacker, #FALSE );

			trace_ent = oldTraceEnt;
			return;
		}
	}

	trace_ent = oldTraceEnt;
};

/*
==============
COOP_MonsterDead

Called when a monster that uses these AI functions dies,
but before .th_die() is called and after the monster is
already setup for respawning. The monster's targets are
also fired before this function is called.
==============
*/
void( entity e ) COOP_MonsterDead = {
//	e.classname = "dead monster";		// messes up obits.qc when it checks monster classname, use deadflag instead
	e.deadflag = #DEAD_DEAD;		// incase any monster doesn't takedamage and has no health, this is used to check if it's dead
	e.targetname = "";
	e.use = SUB_Null;
};


/*
	COOP_SetLives - automatically sets a monster's lives, either by localinfo or the default
*/

void () COOP_SetLives =
{
	local string temp;

	// if the map already has this set, return
	// a respawning monster will ingore any changes made to .lives
	if ( self.lives ) {
		// subtract one for the initial life
		self.lives = self.lives - 1;
		return;
	}

	temp = infokey( world, "monster_lives" );
	self.lives = stof( temp );

	// set default if none set already
	if ( !self.lives ) {
		// in singleplayer only do one spawn
		if ( !deathmatch && !coop )
			self.lives = 1;
		else
			self.lives = 3;
	}

	// subtract one for the initial life
	self.lives = self.lives - 1;
};


/*
	COOP_SetupRespawn - sets up a monster to respawn, self will be the newly allocated entity to respawn.
	This way we can simply put the same function that the map calls to spawn monsters
	self must be the monster respawning, that means you must call this BEFORE the monster is removed
*/

void () respawn_monster =
{
	local float savedlives;

	// this shouldn't really happen, but it does if deathmatch is changed mid-game
	// possible other work arounds: check if deathmatch is being changed from zero to non-zero or non-zero to zero and handle it in StartFrame()
	if ( deathmatch ) {
		remove( self );
		return;
	}

	// make sure to erase the touch function, the rest should be reset by the spawn function (size, solid, and movetype)
	self.touch = SUB_Null;

	// play teleport effect
	spawn_tfog (self.origin);

	// respawn the monster
	savedlives = self.lives;
	self.think1 ();
	self.lives = savedlives;

	// check if he's in a wall
	if (InSolid(self)) {
		// this is kind of like a hack, but it works to ensure monster count is bumped
		self.takedamage = #DAMAGE_AIM;
		self.flags = self.flags | #FL_MONSTER;
		self.#npc_isCoopMonster = #TRUE;
		self.deathtype = "monster_respawn";
		self.health = -60;
		Killed( self, world );
	}
};

void () respawn_think;
void() respawn_verify =
{
	// if something is in the way, then extend the respawn time 5 seconds and resetup the trigger
	// at that time so we can check for still objects again after the 5 seconds are up
	if (other.takedamage && other.health > 0) {
		self.nextthink = time + 5;
		self.think = respawn_think;

		// don't let anything else touching within 5 seconds reset the timer back to 5 seconds
		self.touch = SUB_Null;
		// don't let the sizebox continue to grow each time
		setsize (self, self.mins + '1 1 1', self.maxs - '1 1 1');
	}
};

void () respawn_think =
{
	// setup the monster to be a trigger before it's spawned, to check for things in the way
	self.movetype	= #MOVETYPE_NONE;
	self.solid		= #SOLID_TRIGGER;
	self.touch		= respawn_verify;
	setsize (self, self.mins - '1 1 1', self.maxs + '1 1 1');

	self.nextthink = time + 0.2;
	self.think = respawn_monster;
	
	force_retouch = 2;		// make sure even still objects get hit
};

/*
==============
COOP_SetupRespawn

Set .respawn_time and .#npc_spawnfunc before calling this,
e must also be a valid spawned entity
==============
*/
void( entity e ) COOP_SetupRespawn = {
	local entity newmon;

	// check for a valid spawn function
	if ( !e.#npc_spawnfunc )
		return;

	// check if it's out of lives
	if ( e.lives <= 0 )
		return;

	// check if there's no respawn time set
	if ( e.respawn_time <= 0 )
		e.respawn_time = 30;

	newmon = spawn();
	newmon.classname = "respawning monster";
	newmon.lives = e.lives - 1;
	newmon.angles = newmon.#npc_originalAngles = e.#npc_originalAngles;
	newmon.target = e.target;
	newmon.targetname = e.targetname;
	newmon.effects = e.effects;		// if map has a glow on monster
	newmon.team_no = e.team_no;
	newmon.respawn_time = e.respawn_time;
	newmon.spawnflags = e.spawnflags;
	newmon.endtime = e.endtime;
	setsize( newmon, e.mins, e.maxs );
	setorigin( newmon, e.#npc_originalloc );

	// check if this monster should re-fire it's target when it dies again
	if ( newmon.spawnflags & #SPAWN_USETARGETSONRESPAWN )
		newmon.#npc_useTargetsOnRespawn = #TRUE;

	newmon.nextthink = time + e.respawn_time;
	newmon.think = respawn_think;
	newmon.think1 = e.#npc_spawnfunc;
};


/*
	COOP_CalcEntityDamage - calculates how much damage an entity should take based on it's damage multipliers

	attacktype is the same as the last field on TF_T_Damage
*/

float (entity targ, entity attacker, float indmg, float attacktype) COOP_CalcEntityDamage =
{
	// check for insane mode
	if ( monster_mode & 1 ) {
		if ( COOP_IsCoopMonster( attacker ) && targ.classname == "player" )
			return indmg * 2;
	}
	if ( monster_mode & 2 ) {
		if (attacker.flags & #FL_CLIENT && COOP_IsCoopMonster(targ))
			indmg = indmg * 0.5;
	}

	if ( !COOP_IsCoopMonster( targ ) ) {
		// make summons and army soldiers stronger against coop monsters
		if ( IsOwnedMonster( targ ) && COOP_IsCoopMonster( attacker ) )
			return indmg * 0.5;
		else
			return indmg;
	}

	// automatic adjustment to the number of players
	if (attacker.flags & #FL_CLIENT) {
		if (num_players <= 2)
			indmg = indmg * 1.7;	// 2
		else if (num_players <= 4)
			indmg = indmg * 1.4;	// 1.6
		else if (num_players == 5)
			indmg = indmg * 1.2;
		else if (num_players >= 8)
			indmg = indmg * 0.8;
	}

	if (!targ.#npc_bulletmult)
		targ.#npc_bulletmult = 1;
	if (!targ.#npc_spikemult)
		targ.#npc_spikemult = 1;
	if (!targ.#npc_explosionmult)
		targ.#npc_explosionmult = 1;
	if (!targ.#npc_electricitymult)
		targ.#npc_electricitymult = 1;
	if (!targ.#npc_firemult)
		targ.#npc_firemult = 1;
	if (!targ.#npc_meleemult)
		targ.#npc_meleemult = 1;
	if (!targ.#npc_othermult)
		targ.#npc_othermult = 1;

	// if the target is a coop monster then do the special stuff
	if (attacktype == #TF_TD_SHOT)
		indmg = indmg * targ.#npc_bulletmult;
	else if (attacktype == #TF_TD_NAIL)
		indmg = indmg * targ.#npc_spikemult;
	else if (attacktype == #TF_TD_EXPLOSION)
		indmg = indmg * targ.#npc_explosionmult;
	else if (attacktype == #TF_TD_ELECTRICITY)
		indmg = indmg * targ.#npc_electricitymult;
	else if (attacktype == #TF_TD_FIRE)
		indmg = indmg * targ.#npc_firemult;
	else if (attacktype == #TF_TD_MELEE)
		indmg = indmg * targ.#npc_meleemult;
	else if (attacktype == #TF_TD_OTHER)
		indmg = indmg * targ.#npc_othermult;

	return indmg;
};

#endif
