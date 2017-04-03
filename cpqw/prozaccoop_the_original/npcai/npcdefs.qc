// npcdefs.qc


// misc stuff
#define NPC_TRANQ_FACTOR			0.6				// how much monsters slow down when tranqed

// .spawnflags values
#define SPAWN_USETARGETSONRESPAWN	4				// if present, monsters that respawn will re-fire their triggers upon death
#define SPAWN_DONTCOUNT				8				// if present, monster doesn't count towards the total number of monsters or killed monsters
#define SPAWN_RUN					16				// if present on a path_corner, any monster using that path_corner will run to the next path_corner; if present on a monster, the monster always runs

// macros for certain variables so we can reuse unused variables and still give it a unique name
#define npc_speedfactor				speed
#define npc_noticedelay				invisible_finished
#define npc_spawnfunc				think1			// safe to use?
//#define npc_spawndelay			walkframe		// was gravity
#define npc_originalloc				pos1
#define npc_attackoffset			pos2			// where the npc shoots from, IE: '0 0 40' for shams
#define npc_enemyoffset				dest			// offset that our enemy is visible
#define npc_inpain					demon_one		// if the monster is currently in pain
#define npc_originalAngles			finalangle		// original angles when first spawned
#define npc_lastEnemyOrigin			dest1			// last visible origin our enemy was spotted at
#define npc_lastEnemyTime			lip				// time enemy was last spotted at npc_lastEnemyOrigin
#define npc_isCoopMonster			nextpc			// used for determining a coop monster from a normal monster
#define npc_useTargetsOnRespawn		StatusBarSize	// if true then monster should call SUB_UseTargets() again when he dies after respawning
#define npc_thiefDetectTime			option2			// used to rate limit how often thieves are scanned for

// damage multipliers
#define npc_bulletmult				money
#define npc_spikemult				custom_speed
#define npc_explosionmult			ff_count
#define npc_electricitymult			hover_time
#define npc_firemult				penance_time
#define npc_meleemult				has_cheated
#define npc_othermult				has_cheated		// FIXME: right now melee works by other, we should make all melee weapons use TF_TD_MELEE

// used for smooth movement of monsters, FIXME: change vars I just made up some crap to see if it compiles
.void() npc_oldthink;

#define npc_oldthink				npc_oldthink
//#define npc_smoothDestPos			dest2			// dest2 is also used for doors.qc, rotate.qc, and the gremlin summon
#define npc_smoothDestYaw			fly_sound		// used by gremlin.qc and triggers.qc
#define npc_smoothDestAngles		finaldest		// finaldest is also used for subs.qc, rotate.qc, and the gremline summon
#define npc_smoothtime				maxspeed		// this is the time when we need to give back control to monster and stop lerping
#define npc_smoothdist				demon_blood		// the distance to go
#define npc_lastruntime				axhitme			// last time our lerp function was called, BUG: RECUSTOMIZE
#define npc_attemptednextthink		cnt
