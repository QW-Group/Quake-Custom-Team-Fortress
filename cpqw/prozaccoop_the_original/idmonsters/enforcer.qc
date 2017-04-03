/*
	enforcer.qc
*/


#ifndef COOP_MODE_ENHANCED
#pragma DONT_COMPILE_THIS_FILE
#else


#define IDMON_ENFORCER_HEALTH		300
#define IDMON_ENFORCER_ZAPDMG		60
#define IDMON_ENFORCER_ZAPVELOCITY	1200


/*
==============================================================================

SOLDIER / PLAYER

==============================================================================
*/

$cd id1/models/enforcer
$origin 0 -6 24
$base base		
$skin skin

$frame stand1 stand2 stand3 stand4 stand5 stand6 stand7

$frame walk1 walk2 walk3 walk4 walk5 walk6 walk7 walk8 walk9 walk10
$frame walk11 walk12 walk13 walk14 walk15 walk16

$frame run1 run2 run3 run4 run5 run6 run7 run8

$frame attack1 attack2 attack3 attack4 attack5 attack6
$frame attack7 attack8 attack9 attack10

$frame death1 death2 death3 death4 death5 death6 death7 death8
$frame death9 death10 death11 death12 death13 death14

$frame fdeath1 fdeath2 fdeath3 fdeath4 fdeath5 fdeath6 fdeath7 fdeath8
$frame fdeath9 fdeath10 fdeath11

$frame paina1 paina2 paina3 paina4

$frame painb1 painb2 painb3 painb4 painb5

$frame painc1 painc2 painc3 painc4 painc5 painc6 painc7 painc8

$frame paind1 paind2 paind3 paind4 paind5 paind6 paind7 paind8
$frame paind9 paind10 paind11 paind12 paind13 paind14 paind15 paind16
$frame paind17 paind18 paind19


void() _Laser_Touch =
{
	local vector org;
	
	if (other == self.owner)
		return;		// don't explode on owner

	if (pointcontents(self.origin) == #CONTENT_SKY)
	{
		remove(self);
		return;
	}
	
	sound (self, #CHAN_WEAPON, "enforcer/enfstop.wav", 1, #ATTN_STATIC);
	org = self.origin - 8*normalize(self.velocity);

	if (other.health)
	{
		SpawnBlood (org, 15);
		TF_T_Damage (other, self, self.owner, #IDMON_ENFORCER_ZAPDMG + random()*10, #TF_TD_NOTTEAM, #TF_TD_ELECTRICITY);
	}
	else
	{
		WriteByte (#MSG_MULTICAST, #SVC_TEMPENTITY);
		WriteByte (#MSG_MULTICAST, #TE_GUNSHOT);
		WriteByte (#MSG_MULTICAST, 3);
		WriteCoord (#MSG_MULTICAST, org_x);
		WriteCoord (#MSG_MULTICAST, org_y);
		WriteCoord (#MSG_MULTICAST, org_z);
		multicast (org, #MULTICAST_PHS);
		if (other.takedamage) {
			other.show_hostile = time + 1;	// wake monsters up
		}
	}

	remove(self);
};

void(vector org, vector vec) _LaunchLaser =
{
	if (self.classname == "idmonster_enforcer")
		sound (self, #CHAN_WEAPON, "enforcer/enfire.wav", 1, #ATTN_NORM);

	vec = normalize(vec);

	newmis = spawn();
	newmis.owner = self;
	newmis.movetype = #MOVETYPE_FLY;
	newmis.solid = #SOLID_BBOX;
	newmis.effects = #EF_DIMLIGHT;

	setmodel (newmis, "progs/laser.mdl");
	setsize (newmis, '0 0 0', '0 0 0');		

	setorigin (newmis, org);

	newmis.velocity = vec * #IDMON_ENFORCER_ZAPVELOCITY;
	newmis.angles = vectoangles(newmis.velocity);

	newmis.nextthink = time + 5;
	newmis.think = SUB_Remove;
	newmis.touch = _Laser_Touch;
};



void() enforcer_fire = {
	local vector org, dir;

	muzzleflash();
	makevectors( self.angles );
	
	org = self.origin + v_forward * 30 + v_right * 8.5 + '0 0 16';
	dir = npcAi_GetAttackVector( self, org );

	_LaunchLaser( org, dir );
};

//============================================================================

void()	enf_stand1	=[	$stand1,	enf_stand2	] {npcAi_Idle();};
void()	enf_stand2	=[	$stand2,	enf_stand3	] {};
void()	enf_stand3	=[	$stand3,	enf_stand4	] {};
void()	enf_stand4	=[	$stand4,	enf_stand5	] {npcAi_Idle();};
void()	enf_stand5	=[	$stand5,	enf_stand6	] {};
void()	enf_stand6	=[	$stand6,	enf_stand7	] {};
void()	enf_stand7	=[	$stand7,	enf_stand1	] {};

void()	enf_walk1	=[	$walk1 ,	enf_walk2	] {
if (random() < 0.2)
	sound (self, #CHAN_VOICE, "enforcer/idle1.wav", 1, #ATTN_IDLE);
npcAi_Walk(2);};
void()	enf_walk2	=[	$walk2 ,	enf_walk3	] {npcAi_Walk(4);};
void()	enf_walk3	=[	$walk3 ,	enf_walk4	] {npcAi_Walk(4);};
void()	enf_walk4	=[	$walk4 ,	enf_walk5	] {npcAi_Walk(3);};
void()	enf_walk5	=[	$walk5 ,	enf_walk6	] {npcAi_Walk(1);};
void()	enf_walk6	=[	$walk6 ,	enf_walk7	] {npcAi_Walk(2);};
void()	enf_walk7	=[	$walk7 ,	enf_walk8	] {npcAi_Walk(2);};
void()	enf_walk8	=[	$walk8 ,	enf_walk9	] {npcAi_Walk(1);};
void()	enf_walk9	=[	$walk9 ,	enf_walk10	] {npcAi_Walk(2);};
void()	enf_walk10	=[	$walk10,	enf_walk11	] {npcAi_Walk(4);};
void()	enf_walk11	=[	$walk11,	enf_walk12	] {npcAi_Walk(4);};
void()	enf_walk12	=[	$walk12,	enf_walk13	] {npcAi_Walk(1);};
void()	enf_walk13	=[	$walk13,	enf_walk14	] {npcAi_Walk(2);};
void()	enf_walk14	=[	$walk14,	enf_walk15	] {npcAi_Walk(3);};
void()	enf_walk15	=[	$walk15,	enf_walk16	] {npcAi_Walk(4);};
void()	enf_walk16	=[	$walk16,	enf_walk1	] {npcAi_Walk(2);};

void()	enf_run1	=[	$run1  ,	enf_run2	] {
if (random() < 0.2)
	sound (self, #CHAN_VOICE, "enforcer/idle1.wav", 1, #ATTN_IDLE);
npcAi_Run(18);};
void()	enf_run2	=[	$run2  ,	enf_run3	] {npcAi_Run(14);};
void()	enf_run3	=[	$run3  ,	enf_run4	] {npcAi_Run(7);};
void()	enf_run4	=[	$run4  ,	enf_run5	] {npcAi_Run(12);};
void()	enf_run5	=[	$run5  ,	enf_run6	] {npcAi_Run(14);};
void()	enf_run6	=[	$run6  ,	enf_run7	] {npcAi_Run(14);};
void()	enf_run7	=[	$run7  ,	enf_run8	] {npcAi_Run(7);};
void()	enf_run8	=[	$run8  ,	enf_run1	] {npcAi_Run(11);};

void()	enf_atk1	=[	$attack1,	enf_atk2	] {
	if ( !skill )
		skill = 5;
	npcAi_Turn2( #IDMON_ENFORCER_ZAPVELOCITY + ( random() * 100 - 50 ) / skill );
};
void()	enf_atk2	=[	$attack2,	enf_atk3	] {npcAi_Turn2( #IDMON_ENFORCER_ZAPVELOCITY + ( random() * 100 - 50 ) / skill );};
void()	enf_atk3	=[	$attack3,	enf_atk4	] {npcAi_Turn2( #IDMON_ENFORCER_ZAPVELOCITY + ( random() * 100 - 50 ) / skill );};
void()	enf_atk4	=[	$attack4,	enf_atk5	] {npcAi_Turn2( #IDMON_ENFORCER_ZAPVELOCITY + ( random() * 100 - 50 ) / skill );};
void()	enf_atk5	=[	$attack5,	enf_atk6	] {npcAi_Turn2( #IDMON_ENFORCER_ZAPVELOCITY + ( random() * 100 - 50 ) / skill );};
void()	enf_atk6	=[	$attack6,	enf_atk7	] {enforcer_fire();};
void()	enf_atk7	=[	$attack7,	enf_atk8	] {npcAi_Turn2( #IDMON_ENFORCER_ZAPVELOCITY + ( random() * 100 - 50 ) / skill );};
void()	enf_atk8	=[	$attack8,	enf_atk9	] {npcAi_Turn2( #IDMON_ENFORCER_ZAPVELOCITY + ( random() * 100 - 50 ) / skill );};
void()	enf_atk9	=[	$attack5,	enf_atk10	] {npcAi_Turn2( #IDMON_ENFORCER_ZAPVELOCITY + ( random() * 100 - 50 ) / skill );};
void()	enf_atk10	=[	$attack6,	enf_atk11	] {enforcer_fire();};
void()	enf_atk11	=[	$attack7,	enf_atk12	] {npcAi_Turn2( #IDMON_ENFORCER_ZAPVELOCITY + ( random() * 100 - 50 ) / skill );};
void()	enf_atk12	=[	$attack8,	enf_atk13	] {npcAi_Turn2( #IDMON_ENFORCER_ZAPVELOCITY + ( random() * 100 - 50 ) / skill );};
void()	enf_atk13	=[	$attack9,	enf_atk14	] {npcAi_Turn2( #IDMON_ENFORCER_ZAPVELOCITY + ( random() * 100 - 50 ) / skill );};
void()	enf_atk14	=[	$attack10,	enf_run1	] {npcAi_Turn2( #IDMON_ENFORCER_ZAPVELOCITY + ( random() * 100 - 50 ) / skill );
SUB_CheckRefire (enf_atk1);
	Attack_Finished( random()*2 );
};

void()	enf_paina1	=[	$paina1,	enf_paina2	] {};
void()	enf_paina2	=[	$paina2,	enf_paina3	] {};
void()	enf_paina3	=[	$paina3,	enf_paina4	] {};
void()	enf_paina4	=[	$paina4,	enf_run1	] {};

void()	enf_painb1	=[	$painb1,	enf_painb2	] {};
void()	enf_painb2	=[	$painb2,	enf_painb3	] {};
void()	enf_painb3	=[	$painb3,	enf_painb4	] {};
void()	enf_painb4	=[	$painb4,	enf_painb5	] {};
void()	enf_painb5	=[	$painb5,	enf_run1	] {};

void()	enf_painc1	=[	$painc1,	enf_painc2	] {};
void()	enf_painc2	=[	$painc2,	enf_painc3	] {};
void()	enf_painc3	=[	$painc3,	enf_painc4	] {};
void()	enf_painc4	=[	$painc4,	enf_painc5	] {};
void()	enf_painc5	=[	$painc5,	enf_painc6	] {};
void()	enf_painc6	=[	$painc6,	enf_painc7	] {};
void()	enf_painc7	=[	$painc7,	enf_painc8	] {};
void()	enf_painc8	=[	$painc8,	enf_run1	] {};

void()	enf_paind1	=[	$paind1,	enf_paind2	] {};
void()	enf_paind2	=[	$paind2,	enf_paind3	] {};
void()	enf_paind3	=[	$paind3,	enf_paind4	] {};
void()	enf_paind4	=[	$paind4,	enf_paind5	] {npcAi_PainForward(2);};
void()	enf_paind5	=[	$paind5,	enf_paind6	] {npcAi_PainForward(1);};
void()	enf_paind6	=[	$paind6,	enf_paind7	] {};
void()	enf_paind7	=[	$paind7,	enf_paind8	] {};
void()	enf_paind8	=[	$paind8,	enf_paind9	] {};
void()	enf_paind9	=[	$paind9,	enf_paind10	] {};
void()	enf_paind10	=[	$paind10,	enf_paind11	] {};
void()	enf_paind11	=[	$paind11,	enf_paind12	] {npcAi_PainForward(1);};
void()	enf_paind12	=[	$paind12,	enf_paind13	] {npcAi_PainForward(1);};
void()	enf_paind13	=[	$paind13,	enf_paind14	] {npcAi_PainForward(1);};
void()	enf_paind14	=[	$paind14,	enf_paind15	] {};
void()	enf_paind15	=[	$paind15,	enf_paind16	] {};
void()	enf_paind16	=[	$paind16,	enf_paind17	] {npcAi_Pain(1);};
void()	enf_paind17	=[	$paind17,	enf_paind18	] {npcAi_Pain(1);};
void()	enf_paind18	=[	$paind18,	enf_paind19	] {};
void()	enf_paind19	=[	$paind19,	enf_run1	] {};

void(entity attacker, float damage)	enf_pain =
{
	local float r;

	r = random ();
	if (self.pain_finished > time)
		return;

	
	if (r < 0.5)
		sound (self, #CHAN_VOICE, "enforcer/pain1.wav", 1, #ATTN_NORM);
	else
		sound (self, #CHAN_VOICE, "enforcer/pain2.wav", 1, #ATTN_NORM);

	if (r < 0.2)
	{
		self.pain_finished = time + 1;
		enf_paina1 ();
	}
	else if (r < 0.4)
	{
		self.pain_finished = time + 1;
		enf_painb1 ();
	}
	else if (r < 0.7)
	{
		self.pain_finished = time + 1;
		enf_painc1 ();
	}
	else
	{
		self.pain_finished = time + 2;
		enf_paind1 ();
	}
};

//============================================================================




void()	enf_die1	=[	$death1,	enf_die2	] {};
void()	enf_die2	=[	$death2,	enf_die3	] {};
void()	enf_die3	=[	$death3,	enf_die4	]
{self.solid = #SOLID_NOT;self.ammo_cells = 30;DropBackpack();};
void()	enf_die4	=[	$death4,	enf_die5	] {npcAi_Forward(14);};
void()	enf_die5	=[	$death5,	enf_die6	] {npcAi_Forward(2);};
void()	enf_die6	=[	$death6,	enf_die7	] {};
void()	enf_die7	=[	$death7,	enf_die8	] {};
void()	enf_die8	=[	$death8,	enf_die9	] {};
void()	enf_die9	=[	$death9,	enf_die10	] {npcAi_Forward(3);};
void()	enf_die10	=[	$death10,	enf_die11	] {npcAi_Forward(5);};
void()	enf_die11	=[	$death11,	enf_die12	] {npcAi_Forward(5);};
void()	enf_die12	=[	$death12,	enf_die13	] {npcAi_Forward(5);};
void()	enf_die13	=[	$death13,	enf_die14	] {};
void()	enf_die14	=[	$death14,	enf_die14	] {MonsterCorpse();};

void()	enf_fdie1	=[	$fdeath1,	enf_fdie2	] {

};
void()	enf_fdie2	=[	$fdeath2,	enf_fdie3	] {};
void()	enf_fdie3	=[	$fdeath3,	enf_fdie4	] 
{self.solid = #SOLID_NOT;self.ammo_cells = 30;DropBackpack();};
void()	enf_fdie4	=[	$fdeath4,	enf_fdie5	] {};
void()	enf_fdie5	=[	$fdeath5,	enf_fdie6	] {};
void()	enf_fdie6	=[	$fdeath6,	enf_fdie7	] {};
void()	enf_fdie7	=[	$fdeath7,	enf_fdie8	] {};
void()	enf_fdie8	=[	$fdeath8,	enf_fdie9	] {};
void()	enf_fdie9	=[	$fdeath9,	enf_fdie10	] {};
void()	enf_fdie10	=[	$fdeath10,	enf_fdie11	] {};
void()	enf_fdie11	=[	$fdeath11,	enf_fdie11	] {MonsterCorpse();};


void() enf_die =
{
// check for gib
	if (self.health < -35)
	{
		sound (self, #CHAN_VOICE, "player/udeath.wav", 1, #ATTN_NORM);
		ThrowMonsterHead ("progs/h_mega.mdl", self.health);
		ThrowGib("progs/gib1.mdl", -40, #TRUE, 0, #GIB1_KGS, #FALSE);
		ThrowGib("progs/gib2.mdl", -40, #TRUE, 0, #GIB2_KGS, #FALSE);
		ThrowGib("progs/gib3.mdl", -40, #TRUE, 0, #GIB3_KGS, #FALSE);
		remove (self);
		return;
	}

// regular death
	sound (self, #CHAN_VOICE, "enforcer/death1.wav", 1, #ATTN_NORM);
	if (random() > 0.5)
		enf_die1 ();
	else
		enf_fdie1 ();
};



float() EnforcerOnSight =
{
	local float rsnd;

	rsnd = rint(random() * 3);			
	if (rsnd == 1)
		sound (self, #CHAN_VOICE, "enforcer/sight1.wav", 1, #ATTN_NORM);
	else if (rsnd == 2)
		sound (self, #CHAN_VOICE, "enforcer/sight2.wav", 1, #ATTN_NORM);
	else if (rsnd == 0)
		sound (self, #CHAN_VOICE, "enforcer/sight3.wav", 1, #ATTN_NORM);
	else
		sound (self, #CHAN_VOICE, "enforcer/sight4.wav", 1, #ATTN_NORM);

	return #TRUE;
};

/*
=================
EnforcerMainAttack
=================
*/
void() EnforcerMainAttack = {
	// make sure we're facing the right direction
	if ( !FacingIdeal() )
		return;		// not facing the right direction, wait until we are

	enf_atk1();
};

/*QUAKED monster_enforcer (1 0 0) (-16 -16 -24) (16 16 40) Ambush

*/
void() monster_enforcer =
{
	if ( deathmatch ) {
		remove( self );
		return;
	}

	self.classname = "idmonster_enforcer";

	if (!server_spawned) {
		precache_model2 ("progs/enforcer.mdl");
		precache_model2 ("progs/h_mega.mdl");
		precache_model2 ("progs/laser.mdl");

		precache_sound2 ("enforcer/death1.wav");
		precache_sound2 ("enforcer/enfire.wav");
		precache_sound2 ("enforcer/enfstop.wav");
		precache_sound2 ("enforcer/idle1.wav");
		precache_sound2 ("enforcer/pain1.wav");
		precache_sound2 ("enforcer/pain2.wav");
		precache_sound2 ("enforcer/sight1.wav");
		precache_sound2 ("enforcer/sight2.wav");
		precache_sound2 ("enforcer/sight3.wav");
		precache_sound2 ("enforcer/sight4.wav");
	}
	
	self.solid = #SOLID_SLIDEBOX;
	self.movetype = #MOVETYPE_STEP;

	self.mdl = "progs/h_mega.mdl";
	setmodel (self, "progs/enforcer.mdl");

	setsize (self, '-16 -16 -24', '16 16 40');
	self.max_health = self.health = #IDMON_ENFORCER_HEALTH;

	self.th_stand = enf_stand1;
	self.th_walk = enf_walk1;
	self.th_run = enf_run1;
	self.th_pain = enf_pain;
	self.th_die = enf_die;
	self.th_missile = EnforcerMainAttack;


	self.netname = "enforcer";

	self.monsterweight = #MWEIGHT_NORMAL;
	self.monsterflags = #MFLAG_HASWEAPON | #MFLAG_HUMANOID | #MFLAG_NOBREATHING;

	// monsters have a team of their own
	if ( !self.team_no )
		self.team_no = #TEAMNO_MONSTERS;
	self.#monsterflag = #STRFLAG_MONSTER;

	self.is_connected = #TRUE;

	self.OnNoticeEnemy = EnforcerOnSight;
	self.#npc_spawnfunc = monster_enforcer;
	npcAi_SetLives ();

	self.#npc_electricitymult = 0.75;
	self.#npc_firemult = 0.75;

	// set ammo for emp
	self.ammo_cells = 125;

	coop_walkmonster_start ();
};

#undef IDMON_ENFORCER_HEALTH
#undef IDMON_ENFORCER_ZAPDMG

#endif
