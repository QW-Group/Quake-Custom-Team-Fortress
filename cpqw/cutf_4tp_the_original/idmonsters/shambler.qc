/*
	shambler.qc
*/

#ifndef COOP_MODE_ENHANCED
#pragma DONT_COMPILE_THIS_FILE
#else


#define IDMON_SHAMBLER_HEALTH		4000
#define IDMON_SHAMBLER_LIGHTNINGDMG	30		// was 25
#define IDMON_SHAMBLER_CLAWDMG	125
#define IDMON_SHAMBLER_SMASHDMG	220

#define _sham_healtime			lip


/*
==============================================================================

SHAMBLER

==============================================================================
*/

$cd id1/models/shams
$origin 0 0 24
$base base		
$skin base

$frame stand1 stand2 stand3 stand4 stand5 stand6 stand7 stand8 stand9
$frame stand10 stand11 stand12 stand13 stand14 stand15 stand16 stand17

$frame walk1 walk2 walk3 walk4 walk5 walk6 walk7 
$frame walk8 walk9 walk10 walk11 walk12

$frame	run1 run2 run3 run4 run5 run6

$frame smash1 smash2 smash3 smash4 smash5 smash6 smash7 
$frame smash8 smash9 smash10 smash11 smash12

$frame swingr1 swingr2 swingr3 swingr4 swingr5 
$frame swingr6 swingr7 swingr8 swingr9

$frame swingl1 swingl2 swingl3 swingl4 swingl5 
$frame swingl6 swingl7 swingl8 swingl9

$frame magic1 magic2 magic3 magic4 magic5 
$frame magic6 magic7 magic8 magic9 magic10 magic11 magic12

$frame pain1 pain2 pain3 pain4 pain5 pain6

$frame death1 death2 death3 death4 death5 death6 
$frame death7 death8 death9 death10 death11

void() _ShamHeal =
{
	local float hp;

	if (self.health >= self.max_health || self.#_sham_healtime > time)
		return;

	self.#_sham_healtime = time + 5;

	hp = self.max_health - self.health;

	if (hp > 10)
		hp = hp / (8 + random()*10);
	else if (hp < 1)
		hp = 1;

	// round the heal amount up
	hp = ceil (hp);
	self.health = self.health + hp;

	// heal leg wounds
	self.#npc_speedfactor = 2.8;

	sound(self, #CHAN_ITEM, "items/r_item1.wav", 1, #ATTN_NORM);
};

void() _sham_stand1	=[	$stand1,	_sham_stand2	] {COOP_Idle();};
void() _sham_stand2	=[	$stand2,	_sham_stand3	] {};
void() _sham_stand3	=[	$stand3,	_sham_stand4	] {};
void() _sham_stand4	=[	$stand4,	_sham_stand5	] {};
void() _sham_stand5	=[	$stand5,	_sham_stand6	] {};
void() _sham_stand6	=[	$stand6,	_sham_stand7	] {COOP_Idle();};
void() _sham_stand7	=[	$stand7,	_sham_stand8	] {};
void() _sham_stand8	=[	$stand8,	_sham_stand9	] {};
void() _sham_stand9	=[	$stand9,	_sham_stand10] {};
void() _sham_stand10	=[	$stand10,	_sham_stand11] {};
void() _sham_stand11	=[	$stand11,	_sham_stand12] {COOP_Idle();};
void() _sham_stand12	=[	$stand12,	_sham_stand13] {};
void() _sham_stand13	=[	$stand13,	_sham_stand14] {};
void() _sham_stand14	=[	$stand14,	_sham_stand15] {};
void() _sham_stand15	=[	$stand15,	_sham_stand16] {COOP_Idle();};
void() _sham_stand16	=[	$stand16,	_sham_stand17] {};
void() _sham_stand17	=[	$stand17,	_sham_stand1	] {
	_ShamHeal ();
};

void() _sham_walk1		=[      $walk1,        _sham_walk2 ] {COOP_Walk(10);};
void() _sham_walk2       =[      $walk2,        _sham_walk3 ] {COOP_Walk(9);};
void() _sham_walk3       =[      $walk3,        _sham_walk4 ] {COOP_Walk(9);};
void() _sham_walk4       =[      $walk4,        _sham_walk5 ] {COOP_Walk(5);};
void() _sham_walk5       =[      $walk5,        _sham_walk6 ] {COOP_Walk(6);};
void() _sham_walk6       =[      $walk6,        _sham_walk7 ] {COOP_Walk(12);};
void() _sham_walk7       =[      $walk7,        _sham_walk8 ] {COOP_Walk(8);};
void() _sham_walk8       =[      $walk8,        _sham_walk9 ] {COOP_Walk(3);};
void() _sham_walk9       =[      $walk9,        _sham_walk10] {COOP_Walk(13);};
void() _sham_walk10      =[      $walk10,       _sham_walk11] {COOP_Walk(9);};
void() _sham_walk11      =[      $walk11,       _sham_walk12] {COOP_Walk(7);};
void() _sham_walk12      =[      $walk12,       _sham_walk1 ] {COOP_Walk(7);
	if (random() > 0.8)
		sound (self, #CHAN_VOICE, "shambler/sidle.wav", 1, #ATTN_IDLE);
	_ShamHeal ();
};

void() _sham_throw;
void() _sham_run1       =[      $run1,        _sham_run2      ] {COOP_Run(20);};
void() _sham_run2       =[      $run2,        _sham_run3      ] {COOP_Run(24);};
void() _sham_run3       =[      $run3,        _sham_run4      ] {COOP_Run(20);};
void() _sham_run4       =[      $run4,        _sham_run5      ] {COOP_Run(20);};
void() _sham_run5       =[      $run5,        _sham_run6      ] {COOP_Run(24);};
void() _sham_run6       =[      $run6,        _sham_run1      ] {
if (random() > 0.8)
	sound (self, #CHAN_VOICE, "shambler/sidle.wav", 1, #ATTN_IDLE);

	// check if things are in the way
	if ( random() < 0.25 ) {
		local entity head;

		head = findradius( self.origin, 128 );
		while ( head ) {
			if ( !( head.flags & #FL_ITEM ) )
			if ( !head.takedamage )
			if ( visible( head ) )
			if ( head.solid != #SOLID_BSP && head.movetype != #MOVETYPE_NONE && infront( head ) ) {
				_sham_throw();
				return;
			}

			if ( head.touch == NailGrenadeTouch || head.think == NailGrenadeExplode ) {
				_sham_throw();
				return;
			}
			head = head.chain;
		}
	}

	// only run if we're not wacking something out of the way
	COOP_Run(20);
};

void() _sham_smash1     =[      $smash1,       _sham_smash2    ] {
sound (self, #CHAN_VOICE, "shambler/melee1.wav", 1, #ATTN_NORM);
ai_charge(2);};
void() _sham_smash2     =[      $smash2,       _sham_smash3    ] {ai_charge(6);};
void() _sham_smash3     =[      $smash3,       _sham_smash4    ] {ai_charge(6);};
void() _sham_smash4     =[      $smash4,       _sham_smash5    ] {ai_charge(5);};
void() _sham_smash5     =[      $smash5,       _sham_smash6    ] {ai_charge(4);};
void() _sham_smash6     =[      $smash6,       _sham_smash7    ] {ai_charge(1);};
void() _sham_smash7     =[      $smash7,       _sham_smash8    ] {ai_charge(0);};
void() _sham_smash8     =[      $smash8,       _sham_smash9    ] {ai_charge(0);};
void() _sham_smash9     =[      $smash9,       _sham_smash10   ] {ai_charge(0);};
void() _sham_smash10    =[      $smash10,      _sham_smash11   ] {
local vector	delta;
local float 	ldmg;

	if (!self.enemy)
		return;
	ai_charge(0);

	delta = self.enemy.origin - self.origin;

	if (vlen(delta) > 175 || !visible(self.enemy))
		return;
	if (!CanDamage (self.enemy, self))
		return;
		
	ldmg = (random() + random() + random()) * #IDMON_SHAMBLER_SMASHDMG;
	TF_T_Damage (self.enemy, self, self, ldmg, #TF_TD_NOTTEAM, #TF_TD_MELEE);
	sound (self, #CHAN_VOICE, "shambler/smack.wav", 1, #ATTN_NORM);

	SpawnMeatSpray (self.origin + v_forward*16, crandom() * 100 * v_right);
	SpawnMeatSpray (self.origin + v_forward*16, crandom() * 100 * v_right);
};
void() _sham_smash11    =[      $smash11,      _sham_smash12   ] {ai_charge(5);};
void() _sham_smash12    =[      $smash12,      _sham_run1	   ] {ai_charge(4);};

void() _sham_swingr1;

void(float side) _ShamClaw =
{
local vector	delta;
local float 	ldmg;

	if (!self.enemy)
		return;
	ai_charge(10);

	delta = self.enemy.origin - self.origin;

	if (vlen(delta) > 175 || !visible(self.enemy))
		return;
		
	ldmg = (random() + random() + random()) * #IDMON_SHAMBLER_CLAWDMG;
	TF_T_Damage (self.enemy, self, self, ldmg, #TF_TD_NOTTEAM, #TF_TD_MELEE);
	sound (self, #CHAN_VOICE, "shambler/smack.wav", 1, #ATTN_NORM);

	if (side)
	{
		makevectors (self.angles);
		SpawnMeatSpray (self.origin + v_forward*16, side * v_right);
	}
};

void() _sham_swingl1	=[      $swingl1,      _sham_swingl2   ] {
sound (self, #CHAN_VOICE, "shambler/melee2.wav", 1, #ATTN_NORM);
ai_charge(5);};
void() _sham_swingl2 =[      $swingl2,      _sham_swingl3   ] {ai_charge(3);};
void() _sham_swingl3 =[      $swingl3,      _sham_swingl4   ] {ai_charge(7);};
void() _sham_swingl4 =[      $swingl4,      _sham_swingl5   ] {ai_charge(3);};
void() _sham_swingl5 =[      $swingl5,      _sham_swingl6   ] {ai_charge(7);};
void() _sham_swingl6 =[      $swingl6,      _sham_swingl7   ] {ai_charge(9);};
void() _sham_swingl7 =[      $swingl7,      _sham_swingl8   ] {ai_charge(5); _ShamClaw(250);};
void() _sham_swingl8 =[      $swingl8,      _sham_swingl9   ] {ai_charge(4);};
void() _sham_swingl9 =[      $swingl9,      _sham_run1  ] {
ai_charge(8);
if (random()<0.5)
	self.think = _sham_swingr1;
};

void() _sham_swingr1	=[      $swingr1,      _sham_swingr2   ] {
sound (self, #CHAN_VOICE, "shambler/melee1.wav", 1, #ATTN_NORM);
ai_charge(1);};
void() _sham_swingr2	=[      $swingr2,      _sham_swingr3   ] {ai_charge(8);};
void() _sham_swingr3 =[      $swingr3,      _sham_swingr4   ] {ai_charge(14);};
void() _sham_swingr4 =[      $swingr4,      _sham_swingr5   ] {ai_charge(7);};
void() _sham_swingr5 =[      $swingr5,      _sham_swingr6   ] {ai_charge(3);};
void() _sham_swingr6 =[      $swingr6,      _sham_swingr7   ] {ai_charge(6);};
void() _sham_swingr7 =[      $swingr7,      _sham_swingr8   ] {ai_charge(6); _ShamClaw(-250);};
void() _sham_swingr8 =[      $swingr8,      _sham_swingr9   ] {ai_charge(3);};
void() _sham_swingr9 =[      $swingr9,      _sham_run1  ] {ai_charge(1);
ai_charge(10);
if (random()<0.5)
	self.think = _sham_swingl1;
};

void() _sham_melee =
{
	local float chance;
	
	chance = random();
	if (chance > 0.6 || self.health == #IDMON_SHAMBLER_HEALTH)
		_sham_smash1 ();
	else if (chance > 0.3)
		_sham_swingr1 ();
	else
		_sham_swingl1 ();
};


//============================================================================


/*
=============
_ShamThrowObjects

Knocks objects out of the way
=============
*/
void() _ShamThrowObjects = {
	local entity	head;
	local vector	dir;

	head = findradius( self.origin, 128 );
	while ( head ) {
		if ( !( head.flags & #FL_ITEM ) )
		if ( visible( head ) )
		if ( head.solid != #SOLID_BSP && head.movetype != #MOVETYPE_NONE && infront( head ) ) {
			if ( head.flags & #FL_ONGROUND ) {
				head.flags = head.flags - #FL_ONGROUND;
				head.velocity_z = head.velocity_z + ( ( random() + 1 ) * 300 );
			}

			dir = normalize( head.origin - self.origin );
			head.velocity = head.velocity + dir * ( ( random() + 1 ) * 500 );
		}

		head = head.chain;
	}
};

void() _sham_throwl1	=[      $swingl1,      _sham_throwl2   ] {
sound (self, #CHAN_VOICE, "shambler/melee2.wav", 1, #ATTN_NORM);};
void() _sham_throwl2 =[      $swingl2,      _sham_throwl3   ] {};
void() _sham_throwl3 =[      $swingl3,      _sham_throwl4   ] {};
void() _sham_throwl4 =[      $swingl4,      _sham_throwl5   ] {};
void() _sham_throwl5 =[      $swingl5,      _sham_throwl6   ] {};
void() _sham_throwl6 =[      $swingl6,      _sham_throwl7   ] {};
void() _sham_throwl7 =[      $swingl7,      _sham_throwl8   ] {_ShamThrowObjects();};
void() _sham_throwl8 =[      $swingl8,      _sham_throwl9   ] {};
void() _sham_throwl9 =[      $swingl9,      _sham_run1  ] {};

void() _sham_throwr1	=[      $swingr1,      _sham_throwr2   ] {
sound (self, #CHAN_VOICE, "shambler/melee1.wav", 1, #ATTN_NORM);};
void() _sham_throwr2	=[      $swingr2,      _sham_throwr3   ] {};
void() _sham_throwr3 =[      $swingr3,      _sham_throwr4   ] {};
void() _sham_throwr4 =[      $swingr4,      _sham_throwr5   ] {};
void() _sham_throwr5 =[      $swingr5,      _sham_throwr6   ] {};
void() _sham_throwr6 =[      $swingr6,      _sham_throwr7   ] {};
void() _sham_throwr7 =[      $swingr7,      _sham_throwr8   ] {_ShamThrowObjects();};
void() _sham_throwr8 =[      $swingr8,      _sham_throwr9   ] {};
void() _sham_throwr9 =[      $swingr9,      _sham_run1  ] {};

void() _sham_throw =
{
	if (random() < 0.5)
		_sham_throwr1 ();
	else
		_sham_throwl1 ();
};


//============================================================================

void() _CastLightning =
{
	local	vector	org, dir;
	
	muzzleflash ();

	COOP_Turn ();

	org = self.origin + '0 0 40';

//	dir = self.enemy.origin + '0 0 16' - org;
	dir = (self.enemy.origin + self.#npc_enemyoffset) - org;
	dir = normalize (dir);

	// self.origin or org?
	traceline (org, org + dir*4096, #TRUE, self);

	WriteByte (#MSG_MULTICAST, #SVC_TEMPENTITY);
	WriteByte (#MSG_MULTICAST, #TE_LIGHTNING1);
	WriteEntity (#MSG_MULTICAST, self);
	WriteCoord (#MSG_MULTICAST, org_x);
	WriteCoord (#MSG_MULTICAST, org_y);
	WriteCoord (#MSG_MULTICAST, org_z);
	WriteCoord (#MSG_MULTICAST, trace_endpos_x);
	WriteCoord (#MSG_MULTICAST, trace_endpos_y);
	WriteCoord (#MSG_MULTICAST, trace_endpos_z);
	multicast (org, #MULTICAST_PHS);

	LightningDamage (org, trace_endpos, self, #IDMON_SHAMBLER_LIGHTNINGDMG);
};

void() _sham_magic1     =[      $magic1,       _sham_magic2    ] {COOP_Turn();
	sound (self, #CHAN_WEAPON, "shambler/sattck1.wav", 1, #ATTN_NORM);
};
void() _sham_magic2     =[      $magic2,       _sham_magic3    ] {COOP_Turn();};
void() _sham_magic3     =[      $magic3,       _sham_magic4    ] {COOP_Turn();self.nextthink = self.nextthink + 0.2;
local entity o;

muzzleflash ();
COOP_Turn();
self.owner = spawn();
o = self.owner;
setmodel (o, "progs/s_light.mdl");
setorigin (o, self.origin);
o.angles = self.angles;
o.nextthink = time + 0.7;
o.think = SUB_Remove;
};
void() _sham_magic4     =[      $magic4,       _sham_magic5    ]
{
muzzleflash ();
self.owner.frame = 1;
};
void() _sham_magic5     =[      $magic5,       _sham_magic6    ]
{
muzzleflash ();
self.owner.frame = 2;
};
void() _sham_magic6     =[      $magic6,       _sham_magic9    ]
{
remove (self.owner);
_CastLightning();
sound (self, #CHAN_WEAPON, "shambler/sboom.wav", 1, #ATTN_NORM);
};
void() _sham_magic9     =[      $magic9,       _sham_magic10   ]
{_CastLightning();};
void() _sham_magic10    =[      $magic10,      _sham_magic11   ]
{_CastLightning();};
void() _sham_magic11    =[      $magic11,      _sham_magic12   ]
{
	_CastLightning();
};
void() _sham_magic12    =[      $magic12,      _sham_run1	   ] {};



void() _sham_pain1       =[      $pain1, _sham_pain2      ] {};
void() _sham_pain2       =[      $pain2, _sham_pain3      ] {};
void() _sham_pain3       =[      $pain3, _sham_pain4      ] {};
void() _sham_pain4       =[      $pain4, _sham_pain5      ] {};
void() _sham_pain5       =[      $pain5, _sham_pain6      ] {};
void() _sham_pain6       =[      $pain6, _sham_run1      ] {};

void(entity attacker, float damage)	_sham_pain =
{
	sound (self, #CHAN_VOICE, "shambler/shurt2.wav", 1, #ATTN_NORM);

	if (self.health <= 0)
		return;		// allready dying, don't go into pain frame

	if (random()*400 > damage)
		return;		// didn't flinch

	if (self.pain_finished > time)
		return;
	self.pain_finished = time + 2;
		
	_sham_pain1 ();
};


//============================================================================

void() _sham_death1      =[      $death1,       _sham_death2     ] {};
void() _sham_death2      =[      $death2,       _sham_death3     ] {};
void() _sham_death3      =[      $death3,       _sham_death4     ] {self.solid = #SOLID_NOT;};
void() _sham_death4      =[      $death4,       _sham_death5     ] {};
void() _sham_death5      =[      $death5,       _sham_death6     ] {};
void() _sham_death6      =[      $death6,       _sham_death7     ] {};
void() _sham_death7      =[      $death7,       _sham_death8     ] {};
void() _sham_death8      =[      $death8,       _sham_death9     ] {};
void() _sham_death9      =[      $death9,       _sham_death10    ] {};
void() _sham_death10     =[      $death10,      _sham_death11    ] {};
void() _sham_death11     =[      $death11,      _sham_death11    ] {MonsterCorpse();};

void() _sham_die =
{
// check for gib
	if (self.health < -60)
	{
		sound (self, #CHAN_VOICE, "player/udeath.wav", 1, #ATTN_NORM);
		ThrowMonsterHead ("progs/h_shams.mdl", self.health);
		ThrowGib("progs/gib1.mdl", -40, #TRUE, 0, #GIB1_KGS, #FALSE);
		ThrowGib("progs/gib2.mdl", -40, #TRUE, 0, #GIB2_KGS, #FALSE);
		ThrowGib("progs/gib3.mdl", -40, #TRUE, 0, #GIB3_KGS, #FALSE);
		remove (self);
		return;
	}

// regular death
	//sound (self, #CHAN_VOICE, "shambler/sdeath.wav", 1, #ATTN_NORM);
	sound (self, #CHAN_VOICE, "shambler/sdeath.wav", 1, #ATTN_NONE);
	_sham_death1 ();
};

//============================================================================

float() _ShamCheckAttack =
{
	local vector	spot1, spot2;
	local entity	targ;

	enemy_range = range (self.enemy);
//	enemy_vis = visible (self.enemy);
	enemy_vis = #TRUE;

	if (enemy_range == #RANGE_MELEE)
	{
		self.attack_state = #AS_MELEE;
		return #TRUE;
	}

	if (time < self.attack_finished)
		return #FALSE;
	
//	if (!enemy_vis)
//		return #FALSE;
		
	targ = self.enemy;

	spot1 = self.origin + self.view_ofs;
	spot2 = targ.origin + targ.view_ofs;

	if (vlen(spot1 - spot2) > 4096)
		return #FALSE;

// missile attack
		
	self.attack_state = #AS_MISSILE;
	// make shamblers more aggressive against hwguys
	if ( !( self.enemy.flags & #FL_CLIENT ) || self.enemy.current_weapon != #WEAP_ASSAULT_CANNON )
		Attack_Finished( 1 + 2*random() );
	return #TRUE;
};

//============================================================================


float() _ShamOnSight =
{
	sound (self, #CHAN_VOICE, "shambler/ssight.wav", 1, #ATTN_NORM);
	return #TRUE;
};


/*QUAKED monster_shambler (1 0 0) (-32 -32 -24) (32 32 64) Ambush
*/
void() monster_shambler =
{
	if ( deathmatch ) {
		remove( self );
		return;
	}

	self.classname = "idmonster_shambler";

	if (!server_spawned) {
		precache_model ("progs/shambler.mdl");
		precache_model ("progs/s_light.mdl");
		precache_model ("progs/h_shams.mdl");
		precache_model ("progs/bolt.mdl");

		precache_sound ("shambler/sattck1.wav");
		precache_sound ("shambler/sboom.wav");
		precache_sound ("shambler/sdeath.wav");
		precache_sound ("shambler/shurt2.wav");
		precache_sound ("shambler/sidle.wav");
		precache_sound ("shambler/ssight.wav");
		precache_sound ("shambler/melee1.wav");
		precache_sound ("shambler/melee2.wav");
		precache_sound ("shambler/smack.wav");
	}

	self.#npc_attackoffset = '0 0 40';

	self.solid = #SOLID_SLIDEBOX;
	self.movetype = #MOVETYPE_STEP;

	self.mdl = "progs/h_shams.mdl";
	setmodel (self, "progs/shambler.mdl");

	setsize (self, #VEC_HULL2_MIN, #VEC_HULL2_MAX);
	self.max_health = self.health = #IDMON_SHAMBLER_HEALTH;

	self.th_stand = _sham_stand1;
	self.th_walk = _sham_walk1;
	self.th_run = _sham_run1;
	self.th_die = _sham_die;
	self.th_melee = _sham_melee;
	self.th_missile = _sham_magic1;
	self.th_pain = _sham_pain;


	self.netname = "shambler";

	self.monsterweight = #MWEIGHT_LARGE;
	self.monsterflags = #MFLAG_NOBREATHING;

	// monsters have a team of their own
	if ( !self.team_no )
		self.team_no = #TEAMNO_MONSTERS;
	self.#monsterflag = #STRFLAG_MONSTER;

	self.is_connected = #TRUE;

	self.OnPreAttack = _ShamCheckAttack;
	self.OnNoticeEnemy = _ShamOnSight;
	self.#npc_speedfactor = 2.8;
	self.#npc_spawnfunc = monster_shambler;
	COOP_SetLives ();

	self.#npc_bulletmult		= 0.80;
	self.#npc_electricitymult	= 0.25;
	self.#npc_spikemult		= 1.60;
	self.#npc_meleemult		= 0.50;

	coop_walkmonster_start();
};

#endif
