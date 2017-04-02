/*
	demon.qc
*/

#ifndef COOP_MODE_ENHANCED
#pragma DONT_COMPILE_THIS_FILE
#else


#define IDMON_DEMON_HEALTH		700
#define IDMON_DEMON_DMGIGNORE		200
#define IDMON_DEMON_SLASHDMG		80
#define IDMON_DEMON_JUMPDMG		110
#define IDMON_DEMON_JUMPVEL		800


/*
==============================================================================

DEMON

==============================================================================
*/

$cd id1/models/demon3
$scale	0.8
$origin 0 0 24
$base base
$skin base

$frame stand1 stand2 stand3 stand4 stand5 stand6 stand7 stand8 stand9
$frame stand10 stand11 stand12 stand13

$frame walk1 walk2 walk3 walk4 walk5 walk6 walk7 walk8

$frame run1 run2 run3 run4 run5 run6

$frame leap1 leap2 leap3 leap4 leap5 leap6 leap7 leap8 leap9 leap10
$frame leap11 leap12

$frame pain1 pain2 pain3 pain4 pain5 pain6

$frame death1 death2 death3 death4 death5 death6 death7 death8 death9

$frame attacka1 attacka2 attacka3 attacka4 attacka5 attacka6 attacka7 attacka8
$frame attacka9 attacka10 attacka11 attacka12 attacka13 attacka14 attacka15

//============================================================================

void()	_Demon_JumpTouch;
void(float side)	_Demon_Melee;
float() _DemonCheckAttack;

void()	_demon1_stand1	=[	$stand1,	_demon1_stand2	] {COOP_Idle();};
void()	_demon1_stand2	=[	$stand2,	_demon1_stand3	] {};
void()	_demon1_stand3	=[	$stand3,	_demon1_stand4	] {};
void()	_demon1_stand4	=[	$stand4,	_demon1_stand5	] {};
void()	_demon1_stand5	=[	$stand5,	_demon1_stand6	] {COOP_Idle();};
void()	_demon1_stand6	=[	$stand6,	_demon1_stand7	] {};
void()	_demon1_stand7	=[	$stand7,	_demon1_stand8	] {};
void()	_demon1_stand8	=[	$stand8,	_demon1_stand9	] {};
void()	_demon1_stand9	=[	$stand9,	_demon1_stand10	] {COOP_Idle();};
void()	_demon1_stand10	=[	$stand10,	_demon1_stand11	] {};
void()	_demon1_stand11	=[	$stand11,	_demon1_stand12	] {};
void()	_demon1_stand12	=[	$stand12,	_demon1_stand13	] {};
void()	_demon1_stand13	=[	$stand13,	_demon1_stand1	] {};

void()	_demon1_walk1	=[	$walk1,		_demon1_walk2	] {
if (random() < 0.2)
    sound (self, #CHAN_VOICE, "demon/idle1.wav", 1, #ATTN_IDLE);
COOP_Walk(8);
};
void()	_demon1_walk2	=[	$walk2,		_demon1_walk3	] {COOP_Walk(6);};
void()	_demon1_walk3	=[	$walk3,		_demon1_walk4	] {COOP_Walk(6);};
void()	_demon1_walk4	=[	$walk4,		_demon1_walk5	] {COOP_Walk(7);};
void()	_demon1_walk5	=[	$walk5,		_demon1_walk6	] {COOP_Walk(4);};
void()	_demon1_walk6	=[	$walk6,		_demon1_walk7	] {COOP_Walk(6);};
void()	_demon1_walk7	=[	$walk7,		_demon1_walk8	] {COOP_Walk(10);};
void()	_demon1_walk8	=[	$walk8,		_demon1_walk1	] {COOP_Walk(10);};

void()	_demon1_run1	=[	$run1,		_demon1_run2	] {
if (random() < 0.2)
    sound (self, #CHAN_VOICE, "demon/idle1.wav", 1, #ATTN_IDLE);
COOP_Run(20);};
void()	_demon1_run2	=[	$run2,		_demon1_run3	] {COOP_Run(15);};
void()	_demon1_run3	=[	$run3,		_demon1_run4	] {COOP_Run(36);};
void()	_demon1_run4	=[	$run4,		_demon1_run5	] {COOP_Run(20);};
void()	_demon1_run5	=[	$run5,		_demon1_run6	] {COOP_Run(15);};
void()	_demon1_run6	=[	$run6,		_demon1_run1	] {COOP_Run(36);};

void()	_demon1_jump1	=[	$leap1,		_demon1_jump2	] {COOP_Turn();};
void()	_demon1_jump2	=[	$leap2,		_demon1_jump3	] {COOP_Turn();};
void()	_demon1_jump3	=[	$leap3,		_demon1_jump4	] {COOP_Turn();};
void()	_demon1_jump4	=[	$leap4,		_demon1_jump5	]
{
	COOP_Turn();
	
	self.touch = _Demon_JumpTouch;
	makevectors (self.angles);
	self.origin_z = self.origin_z + 1;
	self.velocity = v_forward * #IDMON_DEMON_JUMPVEL + '0 0 250';
	if (self.flags & #FL_ONGROUND)
		self.flags = self.flags - #FL_ONGROUND;
};
void()	_demon1_jump5	=[	$leap5,		_demon1_jump6	] {};
void()	_demon1_jump6	=[	$leap6,		_demon1_jump7	] {};
void()	_demon1_jump7	=[	$leap7,		_demon1_jump8	] {};
void()	_demon1_jump8	=[ 	$leap8,		_demon1_jump9	] {};
void()	_demon1_jump9	=[ 	$leap9,		_demon1_jump10	] {};
void()	_demon1_jump10	=[ 	$leap10,	_demon1_jump1	] {
self.nextthink = time + 3;
// if three seconds pass, assume demon is stuck and jump again
};

void()	_demon1_jump11	=[ 	$leap11,	_demon1_jump12	] {};
void()	_demon1_jump12	=[ 	$leap12,	_demon1_run1	] {
Attack_Finished( random()*2 );
};


void()	_demon1_atta1	=[	$attacka1,		_demon1_atta2	] {ai_charge(4);};
void()	_demon1_atta2	=[	$attacka2,		_demon1_atta3	] {ai_charge(0);};
void()	_demon1_atta3	=[	$attacka3,		_demon1_atta4	] {ai_charge(0);};
void()	_demon1_atta4	=[	$attacka4,		_demon1_atta5	] {ai_charge(1);};
void()	_demon1_atta5	=[	$attacka5,		_demon1_atta6	] {ai_charge(2); _Demon_Melee(200);};
void()	_demon1_atta6	=[	$attacka6,		_demon1_atta7	] {ai_charge(1);};
void()	_demon1_atta7	=[	$attacka7,		_demon1_atta8	] {ai_charge(6);};
void()	_demon1_atta8	=[	$attacka8,		_demon1_atta9	] {ai_charge(8);};
void()	_demon1_atta9	=[	$attacka9,		_demon1_atta10] {ai_charge(4);};
void()	_demon1_atta10	=[	$attacka10,		_demon1_atta11] {ai_charge(2);};
void()	_demon1_atta11	=[	$attacka11,		_demon1_atta12] {_Demon_Melee(-200);};
void()	_demon1_atta12	=[	$attacka12,		_demon1_atta13] {ai_charge(5);};
void()	_demon1_atta13	=[	$attacka13,		_demon1_atta14] {ai_charge(8);};
void()	_demon1_atta14	=[	$attacka14,		_demon1_atta15] {ai_charge(4);};
void()	_demon1_atta15	=[	$attacka15,		_demon1_run1] {ai_charge(4);};

void()	_demon1_pain1	=[	$pain1,		_demon1_pain2	] {};
void()	_demon1_pain2	=[	$pain2,		_demon1_pain3	] {};
void()	_demon1_pain3	=[	$pain3,		_demon1_pain4	] {};
void()	_demon1_pain4	=[	$pain4,		_demon1_pain5	] {};
void()	_demon1_pain5	=[	$pain5,		_demon1_pain6	] {};
void()	_demon1_pain6	=[	$pain6,		_demon1_run1	] {};

void(entity attacker, float damage)	_demon1_pain =
{
	if (self.touch == _Demon_JumpTouch)
		return;

	if (self.pain_finished > time)
		return;

	self.pain_finished = time + 1;
    sound (self, #CHAN_VOICE, "demon/dpain1.wav", 1, #ATTN_NORM);

	if (random()*#IDMON_DEMON_DMGIGNORE > damage)
		return;		// didn't flinch
		
	_demon1_pain1 ();
};

void()	_demon1_die1		=[	$death1,		_demon1_die2	] {
sound (self, #CHAN_VOICE, "demon/ddeath.wav", 1, #ATTN_NORM);};
void()	_demon1_die2		=[	$death2,		_demon1_die3	] {};
void()	_demon1_die3		=[	$death3,		_demon1_die4	] {};
void()	_demon1_die4		=[	$death4,		_demon1_die5	] {};
void()	_demon1_die5		=[	$death5,		_demon1_die6	] {};
void()	_demon1_die6		=[	$death6,		_demon1_die7	]
{self.solid = #SOLID_NOT;};
void()	_demon1_die7		=[	$death7,		_demon1_die8	] {};
void()	_demon1_die8		=[	$death8,		_demon1_die9	] {};
void()	_demon1_die9		=[	$death9,		_demon1_die9 ] {MonsterCorpse();};

void() _demon_die =
{
// check for gib
	if (self.health < -80)
	{
		sound (self, #CHAN_VOICE, "player/udeath.wav", 1, #ATTN_NORM);
		ThrowMonsterHead ("progs/h_demon.mdl", self.health);
		ThrowGib("progs/gib1.mdl", -40, #TRUE, 0, #GIB2_KGS, #FALSE);
		ThrowGib("progs/gib1.mdl", -40, #TRUE, 0, #GIB2_KGS, #FALSE);
		ThrowGib("progs/gib1.mdl", -40, #TRUE, 0, #GIB3_KGS, #FALSE);
		remove (self);
		return;
	}

// regular death
	_demon1_die1 ();
};


void() _Demon_MeleeAttack =
{
	_demon1_atta1 ();
};


float() _Demon_OnSight =
{
	sound (self, #CHAN_VOICE, "demon/sight2.wav", 1, #ATTN_NORM);
	return #TRUE;
};


/*QUAKED monster_demon1 (1 0 0) (-32 -32 -24) (32 32 64) Ambush

*/
void() monster_demon1 =
{
	if ( deathmatch ) {
		remove( self );
		return;
	}

	self.classname = "idmonster_demon1";

	if (!server_spawned) {
		precache_model ("progs/demon.mdl");
		precache_model ("progs/h_demon.mdl");

		precache_sound ("demon/ddeath.wav");
		precache_sound ("demon/dhit2.wav");
		precache_sound ("demon/djump.wav");
		precache_sound ("demon/dpain1.wav");
		precache_sound ("demon/idle1.wav");
		precache_sound ("demon/sight2.wav");
	}

	self.solid = #SOLID_SLIDEBOX;
	self.movetype = #MOVETYPE_STEP;

	self.mdl = "progs/h_demon.mdl";
	setmodel (self, "progs/demon.mdl");

	setsize (self, #VEC_HULL2_MIN, #VEC_HULL2_MAX);
	self.max_health = self.health = #IDMON_DEMON_HEALTH;

	self.th_stand = _demon1_stand1;
	self.th_walk = _demon1_walk1;
	self.th_run = _demon1_run1;
	self.th_die = _demon_die;
	self.th_melee = _Demon_MeleeAttack;		// one of two attacks
	self.th_missile = _demon1_jump1;			// jump attack
	self.th_pain = _demon1_pain;


	self.netname = "fiend";
	//self.netname = COOP_GenerateMonsterName (self);

	self.monsterweight = #MWEIGHT_MEDIUM;

	// monsters have a team of their own
	if ( !self.team_no )
		self.team_no = #TEAMNO_MONSTERS;
	self.#monsterflag = #STRFLAG_MONSTER;

	self.is_connected = #TRUE;

	self.OnPreAttack = _DemonCheckAttack;
	self.OnNoticeEnemy = _Demon_OnSight;
	self.#npc_spawnfunc = monster_demon1;
	COOP_SetLives ();

	self.#npc_firemult = 1.25;
		
	coop_walkmonster_start();
};


/*
==============================================================================

DEMON

==============================================================================
*/

/*
==============
CheckDemonMelee

Returns TRUE if a melee attack would hit right now
==============
*/
float()	_CheckDemonMelee =
{
	if (enemy_range == #RANGE_MELEE)
	{	// FIXME: check canreach
		self.attack_state = #AS_MELEE;
		return #TRUE;
	}
	return #FALSE;
};

/*
==============
CheckDemonJump

==============
*/
float()	_CheckDemonJump =
{
	local	vector	dist;
	local	float	d;

	if (self.origin_z + self.mins_z > self.enemy.origin_z + self.enemy.mins_z
	+ 0.75 * self.enemy.size_z)
		return #FALSE;
		
	if (self.origin_z + self.maxs_z < self.enemy.origin_z + self.enemy.mins_z
	+ 0.25 * self.enemy.size_z)
		return #FALSE;
		
	dist = self.enemy.origin - self.origin;
	dist_z = 0;
	
	d = vlen(dist);
	
	if (d < 100)
		return #FALSE;
		
	if (d > 200)
	{
		if (random() < 0.9)
			return #FALSE;
	}
		
	return #TRUE;
};

float()	_DemonCheckAttack =
{
	enemy_range = range (self.enemy);
	
// if close enough for slashing, go for it
	if (_CheckDemonMelee ())
	{
		self.attack_state = #AS_MELEE;
		return #TRUE;
	}
	
	if (_CheckDemonJump ())
	{
		self.attack_state = #AS_MISSILE;
		sound (self, #CHAN_VOICE, "demon/djump.wav", 1, #ATTN_NORM);
		return #TRUE;
	}
	
	return #FALSE;
};


//===========================================================================

void(float side)	_Demon_Melee =
{
	local	float	ldmg;
	local vector	delta;
	
	COOP_Turn ();
	walkmove (self.ideal_yaw, 12);	// allow a little closing

	delta = self.enemy.origin - self.origin;

	if (vlen(delta) > 100)
		return;
	if (!CanDamage (self.enemy, self))
		return;

	sound (self, #CHAN_WEAPON, "demon/dhit2.wav", 1, #ATTN_NORM);
	ldmg = #IDMON_DEMON_SLASHDMG + 5*random();
	TF_T_Damage (self.enemy, self, self, ldmg, #TF_TD_NOTTEAM, #TF_TD_MELEE);

	makevectors (self.angles);
	SpawnMeatSpray (self.origin + v_forward*16, side * v_right);
};


void()	_Demon_JumpTouch =
{
	local	float	ldmg;

	if (self.health <= 0)
		return;
		
	if (other.takedamage)
	{
		if ( vlen(self.velocity) > 400 )
		{
			ldmg = #IDMON_DEMON_JUMPDMG + 10*random();
			TF_T_Damage (other, self, self, ldmg, #TF_TD_NOTTEAM, #TF_TD_MELEE);
		}
	}

	if (!checkbottom(self))
	{
		if (self.flags & #FL_ONGROUND)
		{	// jump randomly to not get hung up
//dprint ("popjump\n");
	self.touch = SUB_Null;
	self.think = _demon1_jump1;
	self.nextthink = time + 0.1;

//			self.velocity_x = (random() - 0.5) * 600;
//			self.velocity_y = (random() - 0.5) * 600;
//			self.velocity_z = 200;
//			self.flags = self.flags - #FL_ONGROUND;
		}
		return;	// not on ground yet
	}

	self.touch = SUB_Null;
	self.think = _demon1_jump11;
	self.nextthink = time + 0.1;
};

#endif
