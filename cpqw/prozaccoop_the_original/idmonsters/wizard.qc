/*
	wizard.qc
*/

#ifndef COOP_MODE_ENHANCED
#pragma DONT_COMPILE_THIS_FILE
#else


#define IDMON_WIZARD_HEALTH			220
#define IDMON_WIZARD_SPIKEDMG		60		// 150
#define IDMON_WIZARD_SPIKEVELOCITY	600


/*
==============================================================================

WIZARD

==============================================================================
*/

$cd id1/models/a_wizard
$origin 0 0 24
$base wizbase	
$skin wizbase

$frame hover1 hover2 hover3 hover4 hover5 hover6 hover7 hover8
$frame hover9 hover10 hover11 hover12 hover13 hover14 hover15

$frame fly1 fly2 fly3 fly4 fly5 fly6 fly7 fly8 fly9 fly10
$frame fly11 fly12 fly13 fly14

$frame magatt1 magatt2 magatt3 magatt4 magatt5 magatt6 magatt7
$frame magatt8 magatt9 magatt10 magatt11 magatt12 magatt13

$frame pain1 pain2 pain3 pain4

$frame death1 death2 death3 death4 death5 death6 death7 death8

/*
==============================================================================

WIZARD

If the player moves behind cover before the missile is launched, launch it
at the last visible spot with no velocity leading, in hopes that the player
will duck back out and catch it.
==============================================================================
*/

/*
=============
LaunchMissile

Sets the given entities velocity and angles so that it will hit self.enemy
if self.enemy maintains it's current velocity
0.1 is moderately accurate, 0.0 is totally accurate
=============
*/
void(entity missile, float mspeed, float accuracy) LaunchMissile =
{
	local	vector	vec, move;
	local	float	fly;

	makevectors (self.angles);
		
// set missile speed
	vec = self.enemy.origin + self.enemy.mins + self.enemy.size * 0.7 - missile.origin;

// calc aproximate time for missile to reach vec
	fly = vlen (vec) / mspeed;
	
// get the entities xy velocity
	move = self.enemy.velocity;
	move_z = 0;

// project the target forward in time
	vec = vec + move * fly;
	
	vec = normalize(vec);
	vec = vec + accuracy*v_up*(random()- 0.5) + accuracy*v_right*(random()- 0.5);
	
	missile.velocity = vec * mspeed;

//	missile.angles = '0 0 0';
//	missile.angles_y = vectoyaw(missile.velocity);
	missile.angles = vectoangles (missile.velocity);

// set missile duration
	missile.nextthink = time + 5;
	missile.think = SUB_Remove;	
};


void() _wiz_run1;
void() _wiz_side1;

void() _Wiz_Missile;

/*
=================
WizardCheckAttack
=================
*/
void()	_WizardCheckAttack = {
	local float		chance, r;

	// make sure we're facing the right direction
	if ( !FacingIdeal() )
		return;		// not facing the right direction, wait until we are

	r = npcAi_EnemyRange( self );
	// don't attack if we're too far away
	if ( r == #RANGE_FAR )
		return;
			
	if ( r == #RANGE_MELEE )
		chance = 0.9;
	else if ( r == #RANGE_NEAR )
		chance = 0.6;
	else if ( r == #RANGE_MID )
		chance = 0.2;
	else
		chance = 0;

	if ( random() < chance ) {
		_Wiz_Missile();
		return;
	}

	// if we're not attacking this time, slide or get closer if we're too far out
	if ( r == #RANGE_MID ) {
		self.attack_state = #AS_STRAIGHT;
	} else {
		self.attack_state = #AS_SLIDING;
	}
};

/*
=================
WizardAttackFinished
=================
*/
void()	_WizardAttackFinished =
{
	if ( npcAi_EnemyRange( self ) >= #RANGE_MID || !visible( self.enemy ) )
	{
		self.attack_state = #AS_STRAIGHT;
		self.think = _wiz_run1;
	}
	else
	{
		self.attack_state = #AS_SLIDING;
		self.think = _wiz_side1;
	}
};

/*
==============================================================================

FAST ATTACKS

==============================================================================
*/

void() wizspike_touch =
{
	if (other == self.owner)
		return;

	if (other.solid == #SOLID_TRIGGER)
		return; // trigger field, do nothing

	if (pointcontents(self.origin) == #CONTENT_SKY) {
		remove(self);
		return;
	}
	
// hit something that bleeds
	if (other.takedamage) {
		spawn_touchblood (#IDMON_WIZARD_SPIKEDMG);
		other.deathtype = "nail";
		TF_T_Damage (other, self, self.owner, #IDMON_WIZARD_SPIKEDMG + random()*50, #TF_TD_NOTTEAM, #TF_TD_NAIL);
	} else {
		WriteByte (#MSG_MULTICAST, #SVC_TEMPENTITY);
		WriteByte (#MSG_MULTICAST, #TE_WIZSPIKE);
		WriteCoord (#MSG_MULTICAST, self.origin_x);
		WriteCoord (#MSG_MULTICAST, self.origin_y);
		WriteCoord (#MSG_MULTICAST, self.origin_z);
		multicast (self.origin, #MULTICAST_PHS);
	}

	remove(self);
};


void() _Wiz_FastFire = {
	local vector		vec;

	if ( self.owner.health > 0 ) {
		muzzleflash();

#ifdef NEVER_DEFINED
		local vector		dst;

		makevectors (self.enemy.angles);
		dst = self.enemy.origin - 13*self.movedir;
	
		vec = normalize(dst - self.origin);
#endif
		vec = npcAi_GetAttackVector( self.owner, self.origin );
		sound (self, #CHAN_WEAPON, "wizard/wattack.wav", 1, #ATTN_NORM);


		newmis = spawn();
		newmis.movetype = #MOVETYPE_FLYMISSILE;
		newmis.solid = #SOLID_BBOX;

		newmis.angles = vectoangles( vec );

		newmis.touch = wizspike_touch;
		newmis.think = SUB_Remove;
		newmis.nextthink = time + 6;
		setorigin( newmis, self.origin );

//		newmis.velocity = vec * 2000;
		newmis.velocity = vec*#IDMON_WIZARD_SPIKEVELOCITY;

#ifdef NEVER_DEFINED
		// TODO: Gizmo - someday I want monsters to look at where they want to shoot, and just have weapons shoot via v_forward
		LaunchMissile (newmis, 600, 0.1);
#endif
		newmis.owner = self.owner;
		newmis.classname = "wizspike";
		setmodel( newmis, "progs/w_spike.mdl" );
		setsize( newmis, #VEC_ORIGIN, #VEC_ORIGIN );		
	}

	remove( self );
};


void() _Wiz_StartFast =
{
	local	entity	missile;
	
	sound (self, #CHAN_WEAPON, "wizard/wattack.wav", 1, #ATTN_NORM);
	self.v_angle = self.angles;
	makevectors (self.angles);

	missile = spawn ();
	missile.owner = self;
	missile.nextthink = time + 0.6;
	setsize (missile, '0 0 0', '0 0 0');		
	setorigin (missile, self.origin + '0 0 30' + v_forward*14 + v_right*14);
	missile.enemy = self.enemy;
	missile.nextthink = time + 0.8;
	missile.think = _Wiz_FastFire;
	missile.movedir = v_right;

	missile = spawn ();
	missile.owner = self;
	missile.nextthink = time + 1;
	setsize (missile, '0 0 0', '0 0 0');		
	setorigin (missile, self.origin + '0 0 30' + v_forward*14 + v_right* -14);
	missile.enemy = self.enemy;
	missile.nextthink = time + 0.3;
	missile.think = _Wiz_FastFire;
	missile.movedir = #VEC_ORIGIN - v_right;
};



void() _Wiz_idlesound =
{
local float wr;
	wr = random() * 5;

	if (self.waitmin < time)
	{
	 	self.waitmin = time + 2;
	 	if (wr > 4.5) 
	 		sound (self, #CHAN_VOICE, "wizard/widle1.wav", 1,  #ATTN_IDLE);
	 	if (wr < 1.5)
	 		sound (self, #CHAN_VOICE, "wizard/widle2.wav", 1, #ATTN_IDLE);
	}
	return;
};

void()	_wiz_stand1	=[	$hover1,		_wiz_stand2	] {npcAi_Idle();};
void()	_wiz_stand2	=[	$hover2,		_wiz_stand3	] {};
void()	_wiz_stand3	=[	$hover3,		_wiz_stand4	] {};
void()	_wiz_stand4	=[	$hover4,		_wiz_stand5	] {};
void()	_wiz_stand5	=[	$hover5,		_wiz_stand6	] {npcAi_Idle();};
void()	_wiz_stand6	=[	$hover6,		_wiz_stand7	] {};
void()	_wiz_stand7	=[	$hover7,		_wiz_stand8	] {};
void()	_wiz_stand8	=[	$hover8,		_wiz_stand1	] {};

void()	_wiz_walk1	=[	$hover1,		_wiz_walk2	] {npcAi_Walk(8);
_Wiz_idlesound();};
void()	_wiz_walk2	=[	$hover2,		_wiz_walk3	] {npcAi_Walk(8);};
void()	_wiz_walk3	=[	$hover3,		_wiz_walk4	] {npcAi_Walk(8);};
void()	_wiz_walk4	=[	$hover4,		_wiz_walk5	] {npcAi_Walk(8);};
void()	_wiz_walk5	=[	$hover5,		_wiz_walk6	] {npcAi_Walk(8);};
void()	_wiz_walk6	=[	$hover6,		_wiz_walk7	] {npcAi_Walk(8);};
void()	_wiz_walk7	=[	$hover7,		_wiz_walk8	] {npcAi_Walk(8);};
void()	_wiz_walk8	=[	$hover8,		_wiz_walk1	] {npcAi_Walk(8);};

void()	_wiz_side1	=[	$hover1,		_wiz_side2	] {npcAi_Run(8);
_Wiz_idlesound();};
void()	_wiz_side2	=[	$hover2,		_wiz_side3	] {npcAi_Run(8);};
void()	_wiz_side3	=[	$hover3,		_wiz_side4	] {npcAi_Run(8);};
void()	_wiz_side4	=[	$hover4,		_wiz_side5	] {npcAi_Run(8);};
void()	_wiz_side5	=[	$hover5,		_wiz_side6	] {npcAi_Run(8);};
void()	_wiz_side6	=[	$hover6,		_wiz_side7	] {npcAi_Run(8);};
void()	_wiz_side7	=[	$hover7,		_wiz_side8	] {npcAi_Run(8);};
void()	_wiz_side8	=[	$hover8,		_wiz_side1	] {npcAi_Run(8);};

void()	_wiz_run1	=[	$fly1,		_wiz_run2	] {npcAi_Run(16);
_Wiz_idlesound();
};
void()	_wiz_run2	=[	$fly2,		_wiz_run3	] {npcAi_Run(16);};
void()	_wiz_run3	=[	$fly3,		_wiz_run4	] {npcAi_Run(16);};
void()	_wiz_run4	=[	$fly4,		_wiz_run5	] {npcAi_Run(16);};
void()	_wiz_run5	=[	$fly5,		_wiz_run6	] {npcAi_Run(16);};
void()	_wiz_run6	=[	$fly6,		_wiz_run7	] {npcAi_Run(16);};
void()	_wiz_run7	=[	$fly7,		_wiz_run8	] {npcAi_Run(16);};
void()	_wiz_run8	=[	$fly8,		_wiz_run9	] {npcAi_Run(16);};
void()	_wiz_run9	=[	$fly9,		_wiz_run10	] {npcAi_Run(16);};
void()	_wiz_run10	=[	$fly10,		_wiz_run11	] {npcAi_Run(16);};
void()	_wiz_run11	=[	$fly11,		_wiz_run12	] {npcAi_Run(16);};
void()	_wiz_run12	=[	$fly12,		_wiz_run13	] {npcAi_Run(16);};
void()	_wiz_run13	=[	$fly13,		_wiz_run14	] {npcAi_Run(16);};
void()	_wiz_run14	=[	$fly14,		_wiz_run1	] {npcAi_Run(16);};

void()	_wiz_fast1	=[	$magatt1,		_wiz_fast2	] {
	if ( !skill )
		skill = 5;
	npcAi_Turn2( #IDMON_WIZARD_SPIKEVELOCITY + ( random() * 100 - 50 ) / skill );
	_Wiz_StartFast();
};
void()	_wiz_fast2	=[	$magatt2,		_wiz_fast3	] {npcAi_Turn2( #IDMON_WIZARD_SPIKEVELOCITY + ( random() * 100 - 50 ) / skill );};
void()	_wiz_fast3	=[	$magatt3,		_wiz_fast4	] {npcAi_Turn2( #IDMON_WIZARD_SPIKEVELOCITY + ( random() * 100 - 50 ) / skill );};
void()	_wiz_fast4	=[	$magatt4,		_wiz_fast5	] {npcAi_Turn2( #IDMON_WIZARD_SPIKEVELOCITY + ( random() * 100 - 50 ) / skill );};
void()	_wiz_fast5	=[	$magatt5,		_wiz_fast6	] {npcAi_Turn2( #IDMON_WIZARD_SPIKEVELOCITY + ( random() * 100 - 50 ) / skill );};
void()	_wiz_fast6	=[	$magatt6,		_wiz_fast7	] {npcAi_Turn2( #IDMON_WIZARD_SPIKEVELOCITY + ( random() * 100 - 50 ) / skill );};
void()	_wiz_fast7	=[	$magatt5,		_wiz_fast8	] {npcAi_Turn2( #IDMON_WIZARD_SPIKEVELOCITY + ( random() * 100 - 50 ) / skill );};
void()	_wiz_fast8	=[	$magatt4,		_wiz_fast9	] {npcAi_Turn2( #IDMON_WIZARD_SPIKEVELOCITY + ( random() * 100 - 50 ) / skill );};
void()	_wiz_fast9	=[	$magatt3,		_wiz_fast10	] {npcAi_Turn2( #IDMON_WIZARD_SPIKEVELOCITY + ( random() * 100 - 50 ) / skill );};
void()	_wiz_fast10	=[	$magatt2,		_wiz_run1	] {npcAi_Turn2( #IDMON_WIZARD_SPIKEVELOCITY + ( random() * 100 - 50 ) / skill );
	local float r;

	r = npcAi_EnemyRange( self );

	if ( r <= #RANGE_MELEE )
		Attack_Finished( 0.1 );
	else if (r > #RANGE_NEAR)
		Attack_Finished( 2 );
	else
		Attack_Finished( 0.5 );
	_WizardAttackFinished();
};

void()	_wiz_pain1	=[	$pain1,		_wiz_pain2	] {};
void()	_wiz_pain2	=[	$pain2,		_wiz_pain3	] {};
void()	_wiz_pain3	=[	$pain3,		_wiz_pain4	] {};
void()	_wiz_pain4	=[	$pain4,		_wiz_run1	] {};

void()	_wiz_death1	=[	$death1,		_wiz_death2	] {

self.velocity_x = -200 + 400*random();
self.velocity_y = -200 + 400*random();
self.velocity_z = 100 + 100*random();
self.flags = self.flags - (self.flags & #FL_ONGROUND);
sound (self, #CHAN_VOICE, "wizard/wdeath.wav", 1, #ATTN_NORM);
};
void()	_wiz_death2	=[	$death2,		_wiz_death3	] {};
void()	_wiz_death3	=[	$death3,		_wiz_death4	]{self.solid = #SOLID_NOT;};
void()	_wiz_death4	=[	$death4,		_wiz_death5	] {};
void()	_wiz_death5	=[	$death5,		_wiz_death6	] {};
void()	_wiz_death6	=[	$death6,		_wiz_death7	] {};
void()	_wiz_death7	=[	$death7,		_wiz_death8	] {};
void()	_wiz_death8	=[	$death8,		_wiz_death8	] {MonsterCorpse();};

void() _wiz_die =
{
// check for gib
	if (self.health < -40)
	{
		sound (self, #CHAN_VOICE, "player/udeath.wav", 1, #ATTN_NORM);
		ThrowMonsterHead ("progs/h_wizard.mdl", self.health);
		ThrowGib("progs/gib2.mdl", -40, #TRUE, 0, #GIB2_KGS, #FALSE);
		ThrowGib("progs/gib2.mdl", -40, #TRUE, 0, #GIB2_KGS, #FALSE);
		ThrowGib("progs/gib2.mdl", -40, #TRUE, 0, #GIB2_KGS, #FALSE);
		remove (self);
		return;
	}

	_wiz_death1 ();
};


void(entity attacker, float damage) _Wiz_Pain =
{
	sound (self, #CHAN_VOICE, "wizard/wpain.wav", 1, #ATTN_NORM);
	if (random()*70 > damage)
		return;		// didn't flinch

	_wiz_pain1 ();
};


void() _Wiz_Missile =
{
	_wiz_fast1();
};


float() _WizardOnSight =
{
	sound (self, #CHAN_VOICE, "wizard/wsight.wav", 1, #ATTN_NORM);
	return #TRUE;
};

/*QUAKED monster_wizard (1 0 0) (-16 -16 -24) (16 16 40) Ambush
*/
void() monster_wizard =
{
	if ( deathmatch ) {
		remove( self );
		return;
	}

	self.classname = "idmonster_wizard";

	if (!server_spawned) {
		precache_model ("progs/wizard.mdl");
		precache_model ("progs/h_wizard.mdl");
		precache_model ("progs/w_spike.mdl");

		precache_sound ("wizard/hit.wav");		// used by c code
		precache_sound ("wizard/wattack.wav");
		precache_sound ("wizard/wdeath.wav");
		precache_sound ("wizard/widle1.wav");
		precache_sound ("wizard/widle2.wav");
		precache_sound ("wizard/wpain.wav");
		precache_sound ("wizard/wsight.wav");
	}

	self.solid = #SOLID_SLIDEBOX;
	self.movetype = #MOVETYPE_STEP;

	self.mdl = "progs/h_wizard.mdl";
	setmodel (self, "progs/wizard.mdl");

	setsize (self, '-16 -16 -24', '16 16 40');
	self.max_health = self.health = #IDMON_WIZARD_HEALTH;

	self.th_stand = _wiz_stand1;
	self.th_walk = _wiz_walk1;
	self.th_run = _wiz_run1;
	self.th_missile = _WizardCheckAttack;
	self.th_pain = _Wiz_Pain;
	self.th_die = _wiz_die;


	self.netname = "scrag";

	self.monsterweight = #MWEIGHT_SMALL;
	self.monsterflags = #MFLAG_NOLEGS;

	// monsters have a team of their own
	if ( !self.team_no )
		self.team_no = #TEAMNO_MONSTERS;
	self.#monsterflag = #STRFLAG_MONSTER;

	self.is_connected = #TRUE;

	self.OnNoticeEnemy = _WizardOnSight;
	self.#npc_speedfactor = 3;
	self.#npc_spawnfunc = monster_wizard;
	npcAi_SetLives ();

	self.#npc_spikemult = 1.2;
	self.#npc_explosionmult = 1.2;
		
	coop_flymonster_start ();
};

#undef IDMON_WIZARD_HEALTH
#undef IDMON_WIZARD_SPIKEDMG
#undef IDMON_WIZARD_SPIKEVELOCITY

#endif
