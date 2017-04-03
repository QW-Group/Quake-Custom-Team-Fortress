// common.qc - ai replacement functions


.float() OnNoticeEnemy;						// self.enemy is the enemy noticed, return false for invalid targets
//.void() OnRespawn;						// self is the new entity respawning

float	monster_mode;						// updated every 1.3 seconds from infokey() if at least one monster is present

/*
========================================================================================

GENERAL PURPOSE NPC AI FUNCTIONS

========================================================================================
*/

/*
===============
npcAi_IsCoopMonster

Returns TRUE only if this is a coop monster, not if
it's a monster in general.
===============
*/
float( entity test ) npcAi_IsCoopMonster = {
	if ( test.#npc_isCoopMonster )
	if ( IsMonster( test ) )
		return #TRUE;
	return #FALSE;
};

/*
===============
npcAi_FindInfrontEnemies

Usually used to scan for enemies in a melee attack.
NOTE: Cannot be recursively called because of the chain field.
===============
*/
entity( entity start, vector org, vector viewAngle, float radius ) npcAi_FindInfrontEnemies = {
	if ( start == world )
		start = findradius( org, radius );
	else
		start = start.chain;

	makevectors( viewAngle );

	while ( start ) {
		local vector	vec;

		// get vector for infront check
		vec = normalize( start.origin - org );
		// trace for visibility
		traceline( start.origin, org, #TL_BSP_ONLY, start );

		if ( trace_fraction == 1 )
		if ( vec * v_forward > 0.3 || vec * v_up > 0.4 )
		if ( start.health > 0 && start.takedamage )
			return start;

		start = start.chain;
	}

	return world;
};

/*
===============
npcAi_FindEnemies

Usually used to scan for enemies in a melee attack.
NOTE: Cannot be recursively called because of the chain field.
===============
*/
entity( entity start, vector org, float radius ) npcAi_FindEnemies = {
	if ( start == world )
		start = findradius( org, radius );
	else
		start = start.chain;

	while ( start ) {
		// trace for visibility
		traceline( start.origin, org, #TL_BSP_ONLY, start );

		if ( trace_fraction == 1 )
		if ( start.health > 0 && start.takedamage )
			return start;

		start = start.chain;
	}

	return world;
};

/*
===============
npcAi_EnemyRange
===============
*/
float( entity npc ) npcAi_EnemyRange = {
	local vector	spot1;
	local float		r;

	// FIXME: attack offset instead?
	spot1 = npc.origin + npc.view_ofs;
	
	r = vlen( spot1 - npc.#npc_lastEnemyOrigin );
	if ( r < 120 )
		return #RANGE_MELEE;
	if ( r < 500 )
		return #RANGE_NEAR;
	if ( r < 1000 )
		return #RANGE_MID;
	return #RANGE_FAR;
};

/*
===============
npcAi_TraceCrossedContents

Returns TRUE if the trace crossed contents based on if the
map has transparent water enabled.
===============
*/
float( float inopen, float inwater ) npcAi_TraceCrossedContents = {
	// Gizmo - cpqwsv bug? inwater sometimes isn't set if TL_ANY_SOLID is used and the trace does indeed go through water
	if ( inopen && inwater ) {
		if ( !( world.#mapflags & #MAPFLAG_WATERVISED ) ) {
			return #TRUE;
		}
	}

	return #FALSE;
};

/*
===============
npcAi_PredictOrigin

Predicts a new origin from the given entity based on the attack origin, the
attack speed, the entity's current origin, and the entity's current velocity.
===============
*/
vector( entity e, vector attackOrigin, float attackSpeed ) npcAi_PredictOrigin = {
	local vector	vec, move, newOrigin;
	local float		travelTime;

	if ( !attackSpeed )
		return e.origin;

	// get attack vector
	vec = e.origin + e.mins + e.size * 0.7 - attackOrigin;
	// calculate time to reach the entity from attackOrigin
	travelTime = vlen( vec ) / attackSpeed;

	// remove up/down velocity
	move = e.velocity;
	move_z = 0;

	// calculate the new origin for the entity
	newOrigin = e.origin + move * travelTime;

	return newOrigin;
};

/*
========================================================================================

MISC TARGET RELATED FUNCTIONS

========================================================================================
*/

/*
===============
npcAi_FindShootOffset

Returns TRUE if a valid line of sight to the destination entity
was found, and start.#npc_enemyoffset is the offset from end's
origin that is the line of sight.

NOTE: This _does_ call makevectors(), which will destroy any previous call.
===============
*/
float( entity start, entity end ) npcAi_FindShootOffset = {
	local vector	startVec, tempVec;

	makevectors( start.angles );

// set the initial monster's point of view for the line of sight check
	startVec = start.origin + start.#npc_attackoffset;

// start checking for any visible line of sight to enemy
	traceline (startVec, end.origin, #TL_ANY_SOLID, start);
	if ( trace_ent == end || trace_fraction == 1 )
	if ( !npcAi_TraceCrossedContents( trace_inopen, trace_inwater ) ) {
		start.#npc_enemyoffset = '0 0 0';
		return #TRUE;
	}

	start.#npc_enemyoffset = '0 0 16';
	traceline (startVec, end.origin + start.#npc_enemyoffset, #TL_ANY_SOLID, start);
	if ( trace_ent == end || trace_fraction == 1 )
	if ( !npcAi_TraceCrossedContents( trace_inopen, trace_inwater ) )
		return #TRUE;

	start.#npc_enemyoffset = end.view_ofs;
	traceline (startVec, end.origin + start.#npc_enemyoffset, #TL_ANY_SOLID, start);
	if ( trace_ent == end || trace_fraction == 1 )
	if ( !npcAi_TraceCrossedContents( trace_inopen, trace_inwater ) )
		return #TRUE;

	// start on end
//	makevectors (end.angles);
	tempVec = end.origin - startVec;
	tempVec_y = vectoyaw( tempVec );
	tempVec_x = 0;
	tempVec_z = 0;
	makevectors( tempVec );

	start.#npc_enemyoffset = v_right * end.mins_y;
	traceline (startVec, end.origin + start.#npc_enemyoffset, #TL_ANY_SOLID, start);
	if ( trace_ent == end || trace_fraction == 1 )
	if ( !npcAi_TraceCrossedContents( trace_inopen, trace_inwater ) )
		return #TRUE;

	start.#npc_enemyoffset = v_right * end.maxs_y;
	traceline (startVec, end.origin + start.#npc_enemyoffset, #TL_ANY_SOLID, start);
	if ( trace_ent == end || trace_fraction == 1 )
	if ( !npcAi_TraceCrossedContents( trace_inopen, trace_inwater ) )
		return #TRUE;

	start.#npc_enemyoffset = v_up * end.mins_z;
	traceline (startVec, end.origin + start.#npc_enemyoffset, #TL_ANY_SOLID, start);
	if ( trace_ent == end || trace_fraction == 1 )
	if ( !npcAi_TraceCrossedContents( trace_inopen, trace_inwater ) )
		return #TRUE;

	start.#npc_enemyoffset = v_up * end.maxs_z;
	traceline (startVec, end.origin + start.#npc_enemyoffset, #TL_ANY_SOLID, start);
	if ( trace_ent == end || trace_fraction == 1 )
	if ( !npcAi_TraceCrossedContents( trace_inopen, trace_inwater ) )
		return #TRUE;

	// corners
	start.#npc_enemyoffset = (v_up * end.maxs_z) + (v_right * end.maxs_y);
	traceline (startVec, end.origin + start.#npc_enemyoffset, #TL_ANY_SOLID, start);
	if ( trace_ent == end || trace_fraction == 1 )
	if ( !npcAi_TraceCrossedContents( trace_inopen, trace_inwater ) )
		return #TRUE;

	start.#npc_enemyoffset = (v_up * end.maxs_z) + (v_right * end.mins_y);
	traceline (startVec, end.origin + start.#npc_enemyoffset, #TL_ANY_SOLID, start);
	if ( trace_ent == end || trace_fraction == 1 )
	if ( !npcAi_TraceCrossedContents( trace_inopen, trace_inwater ) )
		return #TRUE;

	start.#npc_enemyoffset = (v_up * end.mins_z) + (v_right * end.maxs_y);
	traceline (startVec, end.origin + start.#npc_enemyoffset, #TL_ANY_SOLID, start);
	if ( trace_ent == end || trace_fraction == 1 )
	if ( !npcAi_TraceCrossedContents( trace_inopen, trace_inwater ) )
		return #TRUE;

	start.#npc_enemyoffset = (v_up * end.mins_z) + (v_right * end.mins_y);
	traceline (startVec, end.origin + start.#npc_enemyoffset, #TL_ANY_SOLID, start);
	if ( trace_ent == end || trace_fraction == 1 )
	if ( !npcAi_TraceCrossedContents( trace_inopen, trace_inwater ) )
		return #TRUE;

	return #FALSE;
};

/*
===============
npcAi_ShouldNoticeThief
===============
*/
float( entity npc, entity thief ) npcAi_ShouldNoticeThief = {
	local float	r;

	if ( npc.#npc_thiefDetectTime > time )
		return #FALSE;

	npc.#npc_thiefDetectTime = time + 0.5;

	r = vlen( thief.origin - npc.origin );
	if ( r >= 2000 ) {
		if ( random() >= 0.1 )
			return #FALSE;
	} else if ( r >= 1500 ) {
		if ( random() >= 0.2 )
			return #FALSE;
	} else if ( r >= 1000 ) {
		if ( random() >= 0.3 )
			return #FALSE;
	} else if ( r >= 500 ) {
		if ( random() >= 0.5 )
			return #FALSE;
	} else {
		if ( random() >= 0.6 )
			return #FALSE;
	}

	return #TRUE;
};

/*
===============
npcAi_IsValidTarget2

NOTE: health and takedamage are not checked by this function
NOTE: this will change trace_ent
===============
*/
float( entity us, entity test, float ignoreThieves ) npcAi_IsValidTarget2 = {
	local float	testTeam;

	// if our target isn't solid then it's not a valid target
	if ( test.solid == #SOLID_NOT )
		return #FALSE;

	// get the team of the test entity
	testTeam = GetTeam( test );

	if ( !Teammate( testTeam, us.team_no ) ) {
		// engineer builds
		if ( IsBuilding( test ) ) {
			if ( test.classname == "building_sentrygun_base" )
				return #FALSE;
			if ( Tesla_IsCloaked( test ) )		// only do this here, so the global list will include it
				return #FALSE;				// and monsters will react faster
			return #TRUE;
		}

		// players
		else if ( test.classname == "player" ) {
			// use Pharse_Client for client checking
			if ( Pharse_Client( test, us, 0, 0, 0, 0 ) ) {
				if ( !ignoreThieves ) {
					if ( test.job & #JOB_THIEF && test.job & #JOB_ACTIVE ) {
						if ( test != us.enemy ) {
							// make sure we don't notice fully hidden thieves that we aren't already attacking
							if ( test.job & #JOB_FULL_HIDE )
								return #FALSE;
							if ( !npcAi_ShouldNoticeThief( us, test ) )
								return #FALSE;
						}
					}
				}
				if ( test.items & #IT_INVISIBILITY && !( test.job & #JOB_THIEF && test.job & #JOB_ACTIVE ) ) {
					if ( test != us.enemy && random() > 0.25 )
						return #FALSE;
				}
				if ( !( test.flags & #FL_NOTARGET ) ) {
					return #TRUE;
				}
			}
		}

		// monsters, IsMonster() should return true for both coop and non-coop monsters
		else if ( IsMonster( test ) )
			return #TRUE;

		// fake hologram decoys
		else if ( test.classname == "holo" )
			return #TRUE;
	}

	return #FALSE;
};

/*
===============
npcAi_IsValidTarget

Same as npcAi_IsValidTarget2(), except this one assumes you want to check for thieves.
===============
*/
float( entity us, entity test ) npcAi_IsValidTarget = {
	return npcAi_IsValidTarget2( us, test, #FALSE );
};

/*
===============
npcAi_GetTargetPriority

The maximum value this can return is 2. Distance calculation can
add up to 1, and the target's priority in general can add another 1.
NOTE: this assumes e is an enemy.
NOTE: this will change trace_ent
===============
*/
float( entity scanner, entity e ) npcAi_GetTargetPriority = {
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
		else if ( e.job & #JOB_THIEF && e.job & #JOB_ACTIVE ) {
			if ( e.job & #JOB_FULL_HIDE )
				priority = priority - 0.2;
			else
				priority = priority - 0.1;
		}

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
========================================================================================

TARGET FINDING

========================================================================================
*/

float	worldscan_delay;
entity	npc_teamLists;
.entity	npc_nextTeamList;
.entity	npc_nextEntInTeamList;

entity	_npc_lastTeamEntity;

entity( float t ) npcAi_GetTeamList = {
	local entity cur;

	cur = npc_teamLists;
	while ( cur ) {
		if ( Teammate( cur.team_no, t ) )
			return cur;

		cur = cur.npc_nextTeamList;
	}

	return world;
};

void( entity list ) npcAi_AddTeamList = {
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

void( entity e ) npcAi_AddToTeamList = {
	local entity list;

	// this is to enhance performance, and to prevent runaway loop errors
	// it prevents us from going through every ent every time in the current list for every entity we add to it
	if ( npc_teamLists == world || _npc_lastTeamEntity == world || !Teammate( _npc_lastTeamEntity.team_no, e.team_no ) ) {
		list = npcAi_GetTeamList( e.team_no );

		if ( list == world ) {
			npcAi_AddTeamList( e );
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

/*
===============
npcAi_FindTarget

Finds something we should attack.
===============
*/
entity( entity scanner ) npcAi_FindTarget = {
	local entity	head;
	local entity	best;
	local float		bestPriority, priority;

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
				npcAi_AddToTeamList( head );
			else if ( IsBuilding( head ) ) {
				// don't compare this string unless it's a building, since QC doesn't have short-circuit logical ops
				// also this prevents further checks if it's the building_sentrygun_base
				if ( head.classname != "building_sentrygun_base" )
					npcAi_AddToTeamList( head );
			} else if ( head.flags & #FL_CLIENT )	// this will probably add spectators too, but comparing a string is much slower for every ent
				npcAi_AddToTeamList( head );
			else if ( head.classname == "holo" )
				npcAi_AddToTeamList( head );

			head = head.chain;
		}

		worldscan_delay = time + 1.3;

		// return here to prevent us from doing too much at once and possibly tripping the infinite loop counter
		return world;
	}

	// this is here to ease cpu with maps that have a lot of monsters, also adds a human factor for delayed notice
	if ( scanner.#npc_noticedelay > time )
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
		if ( visible2( head, scanner ) && head.takedamage && head.health > 0 ) {
			// Gizmo - now that monsters can hear sounds, only make them see things infront
			if ( infront2( head, scanner ) )
			if ( npcAi_IsValidTarget( scanner, head ) ) {
				if ( scanner.enemy == head ) {
					// make sure we never return a fully hidden thief that we're already attacking
					if ( !( head.job & #JOB_THIEF ) || !( head.job & #JOB_ACTIVE ) || !( head.job & #JOB_FULL_HIDE ) ) {
						priority = npcAi_GetTargetPriority( scanner, head );
						if ( priority > bestPriority ) {
							best = head;
							bestPriority = priority;
						}
					}
				} else {
					priority = npcAi_GetTargetPriority( scanner, head );
					if ( priority > bestPriority ) {
						best = head;
						bestPriority = priority;
					}
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
								// when checking for sounds, thieves act as normal players
								if ( npcAi_IsValidTarget2( scanner, head.owner, #TRUE ) )
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

/*
========================================================================================

NPC MOVEMENT LERPING

========================================================================================
*/

#define NPC_FRAMETIME			0.1
#define NPC_LERPTIME			0.031
//#define NPC_SMOOTHTURNING					// can be disabled to decrease cpu usage

float	currentLerpingNPCS;
float	lastLerpingTime;					// since there's no way to have an accurate npc lerping count (since any monster could be removed while lerping) we count it in 100ms intervals

/*
===============
npcAi_SmoothFrame

Set .#npc_smoothDestPos, .#npc_smoothDestAngle, and
.#npc_smoothDist before calling this.
===============
*/
void() npcAi_SmoothFrame = {
	local vector	oldPos;
	local float		oldyaw, oldIdeal;

	if ( time >= self.#npc_smoothtime ) {
		// FIXME: is it ok to call #npc_oldthink directly here?
		self.nextthink = time;
		self.think = self.#npc_oldthink;
		return;
	}

	// make sure lastruntime is set to something
	if ( !self.#npc_lastruntime ) {
		self.#npc_lastruntime = self.lastruntime;

		self.nextthink = time + #NPC_LERPTIME;

#ifndef NPC_SMOOTHTURNING
		// adjust the NPC's angles at .yaw_speed one time
//		oldyaw = self.angles_y;
		oldPos = self.goalentity.origin;
		self.goalentity.origin = self.#npc_lastEnemyOrigin;
		movetogoal( 0 );
		self.#npc_smoothDestYaw = self.angles_y;
//		self.angles_y = oldyaw;
		setorigin( self.goalentity, oldPos );
#endif
		return;
	}

	movedist = ( self.#npc_smoothdist / #NPC_FRAMETIME ) * ( self.lastruntime - self.#npc_lastruntime );

	// movetogoal if there's distance to move, it should only be zero if SV_RunThink is in an infinite loop
	// this prevents infinite SV_RunThink loops in the engine
	if ( movedist ) {
#ifdef NPC_SMOOTHTURNING
		oldyaw = self.yaw_speed;
		self.yaw_speed = ( oldyaw / #NPC_FRAMETIME ) * ( self.lastruntime - self.#npc_lastruntime );
#else
		oldyaw = self.yaw_speed;
//		oldIdeal = self.ideal_yaw;
//		self.yaw_speed = ( oldyaw / #NPC_FRAMETIME ) * ( self.lastruntime - self.#npc_lastruntime );
//		self.ideal_yaw = self.#npc_smoothDestYaw;
//		ChangeYaw();
		self.yaw_speed = 0;
//		self.ideal_yaw = oldIdeal;
#endif
		// move to the last known position of the enemy
		oldPos = self.goalentity.origin;
		self.goalentity.origin = self.#npc_lastEnemyOrigin;

		// this is the only way to get ChangeYaw() called by movetogoal() to do an early out
		oldIdeal = self.angles_y;
		self.angles_y = self.ideal_yaw;
		// move to the last known position
		movetogoal( movedist );
		// reset yaw speed back to normal
		self.yaw_speed = oldyaw;
		// reset yaw angle back to normal
		self.angles_y = oldIdeal;

		// reset the goal back to it's original position
		setorigin( self.goalentity, oldPos );

		self.#npc_lastruntime = self.lastruntime;
		self.#npc_attemptednextthink = self.nextthink = time + #NPC_LERPTIME;
	} else if ( self.#npc_smoothdist ) {
		//bprint( #PRINT_HIGH, "infinite loop prevented!\n" );
		self.#npc_attemptednextthink = self.nextthink = self.#npc_attemptednextthink + 0.01;
	}
};

/*
===============
npcAi_WalkSmooth

This is called, in sort of like a wrapper to movetogoal,
to provide lerping movement.
===============
*/
void( float dist ) npcAi_WalkSmooth = {
//	local vector	oldOrigin, oldAngles;

	if ( !dist )
		return;

	// check if it's time to reset the lerping count
	if ( lastLerpingTime + 0.1 <= time ) {
		currentLerpingNPCS = 0;
		lastLerpingTime = time;
	}
	// make sure we haven't reached our maximum lerping limit
	if ( currentLerpingNPCS >= max_lerping_npcs ) {
		movetogoal( dist );
		return;
	}

	// save old stuff
	self.#npc_oldthink = self.think;
	self.#npc_smoothtime = time + #NPC_FRAMETIME;

	self.#npc_smoothdist = dist;

	// find the destination origin and angles
//	oldOrigin = self.origin;
//	oldAngles = self.angles;
//	movetogoal( dist );
	// calculate the distance of the move
//	self.#npc_smoothdist = vlen( oldOrigin - self.origin );
	// set our destination origin and angles
//	self.#npc_smoothDestPos = self.origin;
//	self.#npc_smoothDestAngle = self.angles;
	// set our origin and angles back to the original
//	setorigin( self, oldOrigin );
//	self.angles = oldAngles;

	// increase the current lerping npcs
	currentLerpingNPCS = currentLerpingNPCS + 1;

	// set think function
	self.think = npcAi_SmoothFrame;

	// do one right away
	self.#npc_lastruntime = 0;	// just incase
	npcAi_SmoothFrame();
};

// to save macro space
#undef NPC_FRAMETIME
#undef NPC_LERPTIME

/*
========================================================================================

MAIN PUBLIC FUNCTIONS

========================================================================================
*/

float( entity en, float check ) npcAi_AttackTarget;

/*
===============
npcAi_SetLastKnownEnemyPos
===============
*/
void( entity npc, entity en, vector enemyPos, float timeToLive ) npcAi_SetLastKnownEnemyPos = {
	local entity	oldSelf;

	// we must get angry at this enemy, but we won't magically know where they are
	if ( npc.enemy != en ) {
		if ( npcAi_IsValidTarget( npc, en ) ) {
			oldSelf = self;
			self = npc;

			if ( !npcAi_AttackTarget( en, #TRUE ) ) {
				self = oldSelf;
				return;
			}

			self = oldSelf;
		}
	}

	// set the our last known position of this enemy
	npc.#npc_lastEnemyOrigin = enemyPos;
	npc.#npc_lastEnemyTime = time + timeToLive;
};

/*
===============
npcAi_UpdateEnemyPos

Returns TRUE or FALSE if sight to the enemy is blocked.
This should only be called after npcAi_SetLastKnownEnemyPos() has been
called at least once with the specified enemy.
===============
*/
float( entity npc, entity en, float attackSpeed ) npcAi_UpdateEnemyPos = {
	local vector	oldOffset;
	local float		sightblocked, thiefSpotted;

	oldOffset = npc.#npc_enemyoffset;
	sightblocked = ( !npcAi_FindShootOffset( npc, en ) );

	if ( !sightblocked ) {
		// check if he's a theif
		thiefSpotted = #FALSE;
		if ( en.flags & #FL_CLIENT )
		if ( en.job & #JOB_THIEF && en.job & #JOB_ACTIVE ) {
			if ( !( en.job & #JOB_FULL_HIDE ) ) {
				if ( !infront2( en, npc ) )
					sightblocked = #TRUE;
				else
					sightblocked = ( !npcAi_ShouldNoticeThief( npc, en ) );
			} else
				sightblocked = #TRUE;

			if ( !sightblocked )
				thiefSpotted = #TRUE;
		}

		// make the npc more realistic, if our enemy suddenly pops up behind us, we won't see it
		if ( !infront2( en, npc ) )
		if ( vlen( npc.#npc_lastEnemyOrigin - en.origin ) > 192 )
			sightblocked = #TRUE;
	} else
		npc.#npc_enemyoffset = oldOffset;

	if ( !sightblocked ) {
		local vector	predictedOrigin;

		predictedOrigin = npcAi_PredictOrigin( en, npc.origin, attackSpeed );

		// mark this position as valid for around 10 seconds, longer for thieves
		if ( thiefSpotted )
			npcAi_SetLastKnownEnemyPos( npc, en, predictedOrigin + npc.#npc_enemyoffset, 45 );
		else
			npcAi_SetLastKnownEnemyPos( npc, en, predictedOrigin + npc.#npc_enemyoffset, 15 );
	}

	return sightblocked;
};

/*
===============
npcAi_GetAttackVector2

Same as npcAi_GetAttackVector(), except this allows an offset to the enemy position.
===============
*/
vector( entity npc, vector shootOrg, vector enemyOffset ) npcAi_GetAttackVector2 = {
	local vector	dir;

	// if we're looking at our ideal, then shoot directly at where we want
	if ( npc.angles_y > npc.ideal_yaw - 0.05 && npc.angles_y < npc.ideal_yaw + 0.05 )
		return normalize( ( npc.#npc_lastEnemyOrigin + enemyOffset ) - shootOrg );

	dir = ( npc.#npc_lastEnemyOrigin + enemyOffset ) - shootOrg;
	dir = normalize( dir );

	makevectors( npc.angles );
	dir_x = v_forward_x;
	dir_y = v_forward_y;

	return dir;
};

/*
===============
npcAi_GetAttackVector

Since vectoyaw() and vectoangles() snap the results to an int, we use this
to aim properly at the enemy when we're facing our ideal.

This does not require the enemy to be visible, but the npc must have one.
===============
*/
vector( entity npc, vector shootOrg ) npcAi_GetAttackVector = {
	local vector	dir;

	// if we're looking at our ideal, then shoot directly at where we want
	if ( npc.angles_y > npc.ideal_yaw - 0.05 && npc.angles_y < npc.ideal_yaw + 0.05 )
		return normalize( npc.#npc_lastEnemyOrigin - shootOrg );

	dir = npc.#npc_lastEnemyOrigin - shootOrg;
	dir = normalize( dir );

	makevectors( npc.angles );
	dir_x = v_forward_x;
	dir_y = v_forward_y;

	return dir;
};

/*
===============
npcAi_CanAttackEnemy

Does NOT check if the target is visible.
===============
*/
float( entity en ) npcAi_CanAttackEnemy = {
	if ( !en.takedamage || en.health <= 0 )
		return #FALSE;
	// if it got psionized from a psion grenade, then don't let it attack
	if ( self.tfstate & #TFSTATE_PSIONIZED )
		return #FALSE;
	return #TRUE;
};

/*
===============
npcAi_AttackTarget

Sets up the monster to start attacking it's enemy.
===============
*/
float( entity en, float check ) npcAi_AttackTarget = {
	local entity	lasten, lasten2;
	local float		ret;

	// save last enemy
	lasten2 = self.enemy;

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
	// set his last known enemy position also
	// IMPORTANT: this must happen AFTER the enemy is set, otherwise this will call npcAi_AttackTarget() again
	if ( en.classname == "player" && en.job & #JOB_THIEF && en.job & #JOB_ACTIVE ) {
		if ( en.job & #JOB_FULL_HIDE )
			npcAi_SetLastKnownEnemyPos( self, en, self.origin, 45 );		// we don't actually know where the attack came from
		else
			npcAi_SetLastKnownEnemyPos( self, en, en.origin, 45 );
	} else
		npcAi_SetLastKnownEnemyPos( self, en, en.origin, 15 );

	// only do run frames if we're not already attacking it
	if ( lasten2 != en ) {
		self.nextthink = time + 0.1;
		self.think = self.th_run;
	}

	self.ideal_yaw = vectoyaw( self.#npc_lastEnemyOrigin - self.origin );

	return #TRUE;
};

/*
===============
npcAi_NoticeEnemy
===============
*/
float() npcAi_NoticeEnemy = {
	local entity	e;

	// find something we should attack
	e = npcAi_FindTarget( self );

	// didn't find anything
	if ( e == world )
		return #FALSE;
	// attack the target if valid
	if ( !npcAi_AttackTarget( e, #TRUE ) )
		return #FALSE;

	return #TRUE;
};

/*
===============
npcAi_Idle

Default idle function for searching.
===============
*/
void() npcAi_Idle = {
	// if we got a target somehow, attack it
	if ( self.enemy != world && self.enemy != self )
		npcAi_AttackTarget( self.enemy, #FALSE );

	if ( npcAi_NoticeEnemy() )
		return;

	// check for pausetime
	if ( time > self.pausetime )
		self.th_walk();
};

/*
===============
npcAi_Walk

Default walking function.
===============
*/
void( float dist ) npcAi_Walk = {
	// make sure we're solid
	if ( self.solid == #SOLID_NOT )
		self.solid = #SOLID_SLIDEBOX;

	// if we got a target somehow, attack it
	if ( self.enemy != world && self.enemy != self )
		npcAi_AttackTarget( self.enemy, #FALSE );

	if ( npcAi_NoticeEnemy() )
		return;

	movedist = dist;
	movetogoal( dist );
};

/*
===============
npcAi_Turn2

Faces ideal_yaw slowly, doesn't move the monster.
===============
*/
void( float attackSpeed ) npcAi_Turn2 = {
	if ( self.enemy ) {
		// this avoids monsters reacting too slow when turning to shoot an enemy
		npcAi_UpdateEnemyPos( self, self.enemy, attackSpeed );

		self.ideal_yaw = vectoyaw( self.#npc_lastEnemyOrigin - self.origin );
	} else if ( npcAi_NoticeEnemy() )
		return;

	// turn towards .ideal_yaw at .yaw_speed
	ChangeYaw();
};

/*
===============
npcAi_Turn

Faces ideal_yaw slowly, doesn't move the monster.
===============
*/
void() npcAi_Turn = {
	// zero is instant
	npcAi_Turn2( 0 );
};

/*
===============
npcAi_Run

Default run function.
===============
*/
void( float dist ) npcAi_Run = {
	local entity	e;
	local float		sightblocked, num;

	// for other functions like slide if we use them
	movedist = dist;

	// first check if our target is still valid
	if (self.enemy == world || self.enemy == self || self.enemy.health < 0 || !npcAi_IsValidTarget(self, self.enemy)) {
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

	// Gizmo - this updates the last known enemy position and returns if sight is blocked
	sightblocked = npcAi_UpdateEnemyPos( self, self.enemy, 0 );

	// check if he's in an attack state (usually for telling the monster to attack but face him first, attacking resets the state)
	// use these to tell the monster to not fire right away and aim at him
	if (self.attack_state && self.attack_state != #AS_STRAIGHT) {
	//	self.ideal_yaw = vectoyaw ((self.enemy.origin + self.#npc_enemyoffset) - self.origin);
		self.ideal_yaw = vectoyaw( self.#npc_lastEnemyOrigin - self.origin );
		ChangeYaw ();

		// if sight is blocked, reset the attack state
		if ( sightblocked ) {
			self.attack_state = #AS_STRAIGHT;
			return;
		}

		if (self.attack_state == #AS_SLIDING) {
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
		}
	}

	// check if we can attack
	if ( !sightblocked ) {
		if ( npcAi_CanAttackEnemy( self.enemy ) ) {
			// Gizmo - whether we can attack, or if we should do melee or not is now handled by the npc's attack function, to allow more flexibility
			if ( self.th_missile ) {
				if ( self.attack_finished < time ) {
					self.th_missile();
					// if we attacked, don't move
					if ( self.attack_finished >= time )
						return;
				}
			}
		}
	} else {
		e = npcAi_FindTarget( self );

		if ( e != world && e != self.enemy )
			npcAi_AttackTarget( e, #FALSE );
		else if ( random() > 0.80 ) {
			// check if we can shoot blindly where they last were, in hopes for a lucky shot
			if ( self.#npc_lastEnemyTime && self.#npc_lastEnemyTime > time ) {
				// randomly adjust the blind shooting origin
				if ( random() > 0.80 ) {
					local vector	temp;

					temp = self.#npc_lastEnemyOrigin;
					temp_x = temp_x + random() * 128;
					temp_y = temp_y + random() * 128;
					self.#npc_lastEnemyOrigin = temp;
				}

				// make sure we're not going to team kill
				traceline( self.origin + self.#npc_attackoffset, self.#npc_lastEnemyOrigin, #TL_ANY_SOLID, self );
				if ( trace_fraction < 0.75 )
					num = #FALSE;
				else if ( trace_ent != world ) {
					num = GetTeam( trace_ent );

					// make sure we don't shoot at teammates
					if ( !Teammate( num, self.team_no ) )
						num = #TRUE;
					else
						num = #FALSE;
				} else
					num = #TRUE;

				if ( num ) {
					if ( self.th_missile ) {
						if ( self.attack_finished < time ) {
							self.th_missile();
							return;
						}
					}
				}
			} else
				self.enemy = world;		// Gizmo - the rest will be reset by the code at the beginning
		}
	}

	// at this point we're either sliding or are just heading straight into the enemy
	if (self.attack_state == #AS_SLIDING)
		return;

#ifdef NEVER_DEFINED
	// if we're in melee range, there's no need to get closer
	if ( npcAi_EnemyRange( self ) == #RANGE_MELEE ) {
		self.ideal_yaw = vectoyaw( self.#npc_lastEnemyOrigin - self.origin );
		ChangeYaw();
		return;
	}
#endif

	// decrease our speed if tranqed
	if ( self.tfstate & #TFSTATE_TRANQUILISED )
		dist = dist * #NPC_TRANQ_FACTOR;
	// decrease our speed if psionized
	if ( self.tfstate & #TFSTATE_PSIONIZED )
		dist = dist * #PSIONIC_MOVEFACTOR;

	// increase our speed by the factor if there is one set
	if ( self.#npc_speedfactor )
		npcAi_WalkSmooth( dist * self.#npc_speedfactor );
	else
		npcAi_WalkSmooth( dist );
};

/*
==============
npcAi_Forward
==============
*/
void( float dist ) npcAi_Forward = {
	if ( self.tfstate & #TFSTATE_TRANQUILISED )
		walkmove( self.angles_y, ( dist * ( #AI_TRANQ_FACTOR_UP / #AI_TRANQ_FACTOR_DN ) ) ); //Tranq
	else
		walkmove( self.angles_y, dist );
};

/*
==============
npcAi_Back
==============
*/
void( float dist ) npcAi_Back = {
	if ( self.tfstate & #TFSTATE_TRANQUILISED )
		walkmove( ( self.angles_y + 180 ), ( dist * ( #AI_TRANQ_FACTOR_UP / #AI_TRANQ_FACTOR_DN ) ) ); //Tranq
	else
		walkmove( ( self.angles_y + 180 ), dist );
};

/*
==============
npcAi_Pain
==============
*/
void( float dist ) npcAi_Pain = {
	if ( self.tfstate & #TFSTATE_TRANQUILISED )
		npcAi_Back( dist * ( #AI_TRANQ_FACTOR_UP / #AI_TRANQ_FACTOR_DN ) ); //Tranq
	else
		npcAi_Back( dist );
};

/*
==============
npcAi_PainForward
==============
*/
void( float dist ) npcAi_PainForward = {
	if ( self.tfstate & #TFSTATE_TRANQUILISED )
		walkmove( self.ideal_yaw, ( dist * ( #AI_TRANQ_FACTOR_UP / #AI_TRANQ_FACTOR_DN ) ) ); //Tranq
	else
		walkmove( self.ideal_yaw, dist );
};

/*
==============
npcAi_Charge
==============
*/
void( float d ) npcAi_Charge = {
	npcAi_Turn();
	movetogoal( d );		// done in C code...
};

/*
==============
npcAi_ChargeSide
==============
*/
void() npcAi_ChargeSide = {
	local vector	dtemp;
	local float		heading;
	
// aim to the left of the enemy for a flyby

	self.ideal_yaw = vectoyaw( self.#npc_lastEnemyOrigin - self.origin );
	ChangeYaw();

	makevectors( self.angles );
	dtemp = self.#npc_lastEnemyOrigin - 30*v_right;
	heading = vectoyaw( dtemp - self.origin );
	
	walkmove( heading, 20 );
};

/*
==============
npcAi_Melee
==============
*/
void() npcAi_Melee = {
	local vector	attackVec;
	local float 	ldmg;

	if ( !self.enemy )
		return;		// removed before stroke

	attackVec = npcAi_GetAttackVector( self, self.origin );
	traceline( self.origin, self.origin + attackVec*60, #TL_ANY_SOLID, self );

	if ( trace_ent.health <= 0 || !trace_ent.takedamage )
		return;

	ldmg = ( random() + random() + random() ) * 3;
	T_Damage( trace_ent, self, self, ldmg );
};

/*
==============
npcAi_MeleeSide
==============
*/
void() npcAi_MeleeSide = {
	if ( !self.enemy )
		return;		// removed before stroke

	npcAi_ChargeSide();

	npcAi_Melee();
};

/*
========================================================================================

PAIN, DEATH, AND RESPAWNING FUNCTIONS

========================================================================================
*/

void() respawn_think;

/*
==============
npcAi_PrePain

Called when an entity using the AI functions is about to
have pain. This is called before .th_pain() is called.
NOTE: uses self
==============
*/
void( entity attacker ) npcAi_PrePain = {
	local float	currentPriority, attackerPriority;
	local entity	oldTraceEnt;

	oldTraceEnt = trace_ent;

	// the .think will get overridden but that's ok
	if ( !self.enemy ) {
		if ( npcAi_IsValidTarget2( self, attacker, #TRUE ) )
			npcAi_AttackTarget( attacker, #TRUE );

		trace_ent = oldTraceEnt;
		return;
	}

	// don't bother if our attacker is hurting us
	if ( attacker == self.enemy ) {
		// but make sure we update where our enemy is
		npcAi_AttackTarget( attacker, #FALSE );
		return;
	}

	if ( !visible( self.enemy ) ) {
		if ( npcAi_IsValidTarget2( self, attacker, #TRUE ) )
			npcAi_AttackTarget( attacker, #FALSE );

		trace_ent = oldTraceEnt;
		return;
	}

	// otherwise check if the one attacking is a higher priority
	if ( random() < 0.45 ) {
		currentPriority = npcAi_GetTargetPriority( self, self.enemy );
		attackerPriority = npcAi_GetTargetPriority( self, attacker );

		// don't switch targets too often when multiple monsters are attacking us
		if ( IsMonster( self.enemy ) && IsMonster( attacker ) )
			currentPriority = currentPriority + 0.5;

		if ( attackerPriority > currentPriority ) {
			if ( npcAi_IsValidTarget( self, attacker ) )
				npcAi_AttackTarget( attacker, #FALSE );

			trace_ent = oldTraceEnt;
			return;
		}
	}

	trace_ent = oldTraceEnt;
};

/*
==============
npcAi_MonsterDead

Called when a monster that uses these AI functions dies,
but before .th_die() is called and after the monster is
already setup for respawning. The monster's targets are
also fired before this function is called.
==============
*/
void( entity e ) npcAi_MonsterDead = {
//	e.classname = "dead monster";		// messes up obits.qc when it checks monster classname, use deadflag instead
	e.deadflag = #DEAD_DEAD;		// incase any monster doesn't takedamage and has no health, this is used to check if it's dead
	e.targetname = "";
	e.use = SUB_Null;
};

/*
==============
npcAi_SetLives

Automatically sets a monster's lives, either by localinfo
or the default.
==============
*/
void() npcAi_SetLives = {
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
==============
respawn_monster

Final think function after the area has been successfully checked
when it's time for an NPC to respawn.
==============
*/
void() respawn_monster = {
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
	spawn_tfog( self.origin );

	// respawn the monster
	savedlives = self.lives;
	self.think1();
	self.lives = savedlives;

	// check if he's in a wall
	if ( InSolid( self ) ) {
		// this is kind of like a hack, but it works to ensure monster count is bumped
		self.takedamage = #DAMAGE_AIM;
		self.flags = self.flags | #FL_MONSTER;
		self.#npc_isCoopMonster = #TRUE;
		self.deathtype = "monster_respawn";
		self.health = -60;
		Killed( self, world );
	}
};

/*
==============
respawn_verify

Touch function for a respawning monster to check if anything
is in the way.
==============
*/
void() respawn_verify = {
	// if something is in the way, then extend the respawn time 5 seconds and resetup the trigger
	// at that time so we can check for still objects again after the 5 seconds are up
	if ( other.takedamage && other.health > 0 ) {
		self.nextthink = time + 5;
		self.think = respawn_think;

		// don't let anything else touching within 5 seconds reset the timer back to 5 seconds
		self.touch = SUB_Null;
		// don't let the sizebox continue to grow each time
		setsize( self, self.mins + '1 1 1', self.maxs - '1 1 1' );
	}
};

/*
==============
respawn_think

Initial think function for when it's time for an NPC to respawn.
==============
*/
void() respawn_think = {
	// setup the monster to be a trigger before it's spawned, to check for things in the way
	self.movetype	= #MOVETYPE_NONE;
	self.solid		= #SOLID_TRIGGER;
	self.touch		= respawn_verify;
	setsize( self, self.mins - '1 1 1', self.maxs + '1 1 1' );

	self.nextthink = time + 0.2;
	self.think = respawn_monster;
	
	force_retouch = 2;		// make sure even still objects get hit
};

/*
==============
npcAi_SetupRespawn

Set .respawn_time and .#npc_spawnfunc before calling this,
e must also be a valid spawned entity.

You must call this BEFORE the monster is removed.
==============
*/
void( entity e ) npcAi_SetupRespawn = {
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
==============
npcAi_CalcEntityDamage

Calculates how much damage an entity should take based on it's
damage multipliers. attacktype is the same as the last field on TF_T_Damage.
==============
*/
float( entity targ, entity attacker, float indmg, float attacktype ) npcAi_CalcEntityDamage = {
	// check for insane mode
	if ( monster_mode & 1 ) {
		if ( npcAi_IsCoopMonster( attacker ) && targ.flags & #FL_CLIENT )
			return indmg * 2;
	}
	if ( monster_mode & 2 ) {
		if ( attacker.flags & #FL_CLIENT && npcAi_IsCoopMonster( targ ) )
			indmg = indmg * 0.5;
	}

	// this will catch every target that isn't a coop monster, like players and summons
	if ( !npcAi_IsCoopMonster( targ ) ) {
		// make summons and army soldiers stronger against coop monsters
		if ( IsOwnedMonster( targ ) && npcAi_IsCoopMonster( attacker ) )
			return indmg * 0.5;
		else
			return indmg;
	}

	// automatic adjustment to the number of players
	if ( attacker.flags & #FL_CLIENT ) {
		if ( num_players <= 2 )
			indmg = indmg * 1.7;	// 2
		else if ( num_players <= 4 )
			indmg = indmg * 1.4;	// 1.6
		else if ( num_players == 5 )
			indmg = indmg * 1.2;
		else if ( num_players >= 8 )
			indmg = indmg * 0.8;
	}

	// make sure all NPC damage multipliers are set
	if ( !targ.#npc_bulletmult )
		targ.#npc_bulletmult = 1;
	if ( !targ.#npc_spikemult )
		targ.#npc_spikemult = 1;
	if ( !targ.#npc_explosionmult )
		targ.#npc_explosionmult = 1;
	if ( !targ.#npc_electricitymult )
		targ.#npc_electricitymult = 1;
	if ( !targ.#npc_firemult )
		targ.#npc_firemult = 1;
	if ( !targ.#npc_meleemult )
		targ.#npc_meleemult = 1;
	if ( !targ.#npc_othermult )
		targ.#npc_othermult = 1;

	// if the target is a coop monster then do the special stuff
	if ( attacktype == #TF_TD_SHOT )
		indmg = indmg * targ.#npc_bulletmult;
	else if ( attacktype == #TF_TD_NAIL )
		indmg = indmg * targ.#npc_spikemult;
	else if ( attacktype == #TF_TD_EXPLOSION )
		indmg = indmg * targ.#npc_explosionmult;
	else if ( attacktype == #TF_TD_ELECTRICITY )
		indmg = indmg * targ.#npc_electricitymult;
	else if ( attacktype == #TF_TD_FIRE )
		indmg = indmg * targ.#npc_firemult;
	else if ( attacktype == #TF_TD_MELEE )
		indmg = indmg * targ.#npc_meleemult;
	else if ( attacktype == #TF_TD_OTHER )
		indmg = indmg * targ.#npc_othermult;

	return indmg;
};
