// tfdefs.qc - to keep defs.qc a little cleaner, place teamfortress specific defs.qc stuff in here instead


//
// globals
//
float	server_spawned;									// TRUE if server is spawned and ready to go

//
// player only fields
//
#define team_damage_dealt			cnt					// total amount of team damage this player has dealt
#define enemy_damage_dealt			volume				// total amount of damage done to enemies only
#define damage_taken				distance			// player that took the most amount of damage from enemies
#define teleporter_teamkiller		trigger_field		// a teammate that teleported us into lava (requires teleporter.qc, client.qc: PlayerPostThink(), and obits.qc)
#define goals_attached				remove_spawnpoint	// number of goals attached to this player (like a flag)

//
// grunty.qc
//
#define allowed_weapons				wait				// weapons the grunt can use

//
// tesla fields
//
#define tesla_upgrades				activate_group_no	// holds the expensive tesla upgrades
#define tesla_recharge_time			remove_spawngroup	// time when tesla can heal/recharge itself
#define tesla_battery_overcharge	restore_goal_no		// the level
#define tesla_chain_lightning		remove_item_group	// the level

//
// tesla constants
//
#define TESLA_UPGRADE_NANOBOTS		1
#define TESLA_UPGRADE_SOLARPANEL	2
#define TESLA_UPGRADE_HEALINGFIELD	4
#define TESLA_UPGRADE_PROXYDEFENSE	8

//
// prototypes
//
float( entity ent ) InSolid;
float( entity e ) GetTeam;
float( entity thing ) IsOwnedMonster;
string( string s1, string s2, string s3, string s4, string s5, string s6, string s7, string s8 ) ConstructString;

//
// MedicRevive() flags
//
#define REVIVE_PRINTMSGS			1					// display messages to the medic and dead player
#define REVIVE_MEDIKITAMMO			2					// medikit ammo required

//=======================================================================

/*
============
BitNumToValue

Converts the bit number (0 - 23) to it's value, IE: 9 == 512.
Similar to 1<<x in C since QC doesn't have the << operator.
NOTE: this could be implemented in the engine to speed things up.
============
*/
float( float bitNum ) BitNumToValue = {
	local float value;

	value = 1;

	while ( bitNum ) {
		value = value * 2;
		bitNum = bitNum - 1;
	}

	return value;
};

// FIXME: a QC implementation of tracebox
/*
void(vector v1, vector v2, vector bbox_mins, vector bbox_maxs, entity forent) tracebox =
{
	local entity	tent, oself;
	local vector	vec;
	local float		dist;

	vec = v2 - v1;
	dist = vlen (vec);

	// create an entity to perform the tracebox with
	tent = spawn ();

	// setup the starting position
	tent.owner		= forent;
	tent.solid		= #SOLID_SLIDEBOX;
	tent.movetype	= #MOVETYPE_STEP;
	tent.flags		= #FL_ONGROUND | #FL_PARTIALGROUND;
	setsize (tent, bbox_mins, bbox_maxs);
	setorigin (tent, v1);

	// move tent in the direction of 'vec' with a distance of 'dist'
	oself = self;
	self = tent;
	walkmove (
*/


/*
	qc_droptofloor - allows drops that aren't bound to 256 down, though it cannot be negative
*/
/*
#define DROPDIST 256
float(entity e, float dist, float nodrop) qc_droptofloor =
{
	local entity	oself;
	local vector	oldorg;
	local float		destz;

	oself = self;
	self = e;

	destz = self.origin_z - dist;
	oldorg = self.origin;

	do {
		if (droptofloor()) {
			self = oself;
			if (e.origin_z >= destz) {
				if (nodrop) {
					e.flags = e.flags - #FL_ONGROUND;
					setorigin (e, oldorg);
				}
				return #TRUE;
			} else {
				// droptofloor() always sets FL_ONGROUND when it returns TRUE, so no need for '- (e.flags & FL_ONGROUND)'
				e.flags = e.flags - #FL_ONGROUND;
				setorigin (e, oldorg);
				return #FALSE;
			}
		}

		// if droptofloor() failed, check if we started in a solid, and if so abort right away
		if (InSolid(self)) {
			setorigin (self, oldorg);
			self = oself;
			return #FALSE;
		}
		// no need to call setorigin() here, because droptofloor() uses current origin and links if successful
		self.origin_z = self.origin_z - #DROPDIST;
	} while (self.origin_z > destz);

	setorigin (self, oldorg);
	self = oself;
	return #FALSE;
};
*/


#ifdef NEVER_DEFINED
/*
	precache_sound - prevents precache_*** overflow crashes
*/

float precached_sounds;

string( string s ) precache_sound = {
	local string mp;

	// check if it's already precached
	mp = infokey( world, s );
	if ( mp == "1" )
		return;

	if ( precached_sounds + 1 > 256 ) {
		dprint( "WARNING: precache_sound: attempted to precache more than 256 sounds\n" );
		return "";
	}

	localcmd( "localinfo \"" );
	localcmd( s );
	localcmd( "\" 1\n" );

	precached_sounds = precached_sounds + 1;

	precache_sound_C( s );
	return s;
};


/*
	precache_model
*/

float precached_models;

string( string s ) precache_model = {
	local string mp;

	// check if it's already precached
	mp = infokey( world, s );
	if ( mp == "1" )
		return;

	if ( precached_models + 1 > 256 ) {
		dprint( "WARNING: precache_model: attempted to precache more than 256 models\n" );
		return "";
	}

	localcmd( "localinfo \"" );
	localcmd( s );
	localcmd( "\" 1\n" );

	precached_models = precached_models + 1;

	precache_model_C( s );
	return s;
};


/*
	setmodel
*/

void( entity e, string m ) setmodel = {
	local string s;

	if ( m == "" ) {
		setmodel_C( e, m );
		return;
	}

	s = infokey( world, m );

	if ( s != "1" ) {
		dprint( "WARNING: setmodel: " );
		dprint( m );
		dprint( " not precached\n" );
		setmodel_C( e, "progs/player.mdl" );
		return;
	}

	setmodel_C( e, m );
};
#endif

//========================================================================

entity	headActiveSound;

/*
==============
RemoveActiveSound
==============
*/
void() RemoveActiveSound = {
	local entity	head;

	// unlink
	if ( headActiveSound == self )
		headActiveSound = headActiveSound.enemy;
	else {
		head = headActiveSound;
		while ( head ) {
			// we know headActiveSound isn't self since we checked that above, so start with headActiveSound.enemy
			if ( head.enemy == self ) {
				head.enemy = head.enemy.enemy;
				head = world;
			} else
				head = head.enemy;
		}
	}

	remove( self );
};

/*
==============
sound

Hack to get monsters to hear sounds.
==============
*/
void( entity e, float chan, string samp, float vol, float atten ) sound = {
	local entity	soundEnt;
	local entity	playerEnt;

	// play the actual sound
	sound_C( e, chan, samp, vol, atten );

	if ( e == world )
		return;

	// only sounds from players cause monsters to wake up
	if ( e.classname == "player" )
		playerEnt = e;
	else if ( e.owner.classname == "player" )
		playerEnt = e.owner;
	else if ( e.real_owner.classname == "player" )
		playerEnt = e.real_owner;
	else
		return;

	if ( atten != #ATTN_NORM )
		return;

	// only allow one sound per player
	soundEnt = headActiveSound;
	while ( soundEnt ) {
		if ( soundEnt.owner == playerEnt ) {
			soundEnt.nextthink = time + 0.5 + random() * 0.8;
			setorigin( soundEnt, e.origin );
			return;
		}

		soundEnt = soundEnt.enemy;
	}

	soundEnt = spawn();
	soundEnt.owner = playerEnt;
	soundEnt.nextthink = time + 0.5 + random() * 0.8;
	soundEnt.think = RemoveActiveSound;
	setorigin( soundEnt, e.origin );			// used for distance calculation

	// we do it like this because find() has too much overhead with a lot of monsters
	// so only go through the sound entities
	if ( !headActiveSound )
		headActiveSound = soundEnt;
	else {
		soundEnt.enemy = headActiveSound;
		headActiveSound = soundEnt;
	}
};
