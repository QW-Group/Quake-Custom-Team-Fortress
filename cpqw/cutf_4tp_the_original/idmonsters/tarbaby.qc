/*
	tarbaby.qc
*/

#ifndef COOP_MODE_ENHANCED
#pragma DONT_COMPILE_THIS_FILE
#else


#define IDMON_TARBABY_HEALTH	275
#define IDMON_TARBABY_HITDMG	50


/*
==============================================================================

BLOB

==============================================================================
*/

$cd id1/models/tarbaby
$origin 0 0 24
$base base		

$skin skin

$frame walk1 walk2 walk3 walk4  walk5 walk6 walk7 walk8 walk9 walk10
$frame walk11 walk12 walk13 walk14 walk15 walk16 walk17 walk18 walk19
$frame walk20 walk21 walk22 walk23 walk24 walk25

$frame run1 run2 run3 run4 run5 run6  run7 run8 run9 run10 run11 run12 run13
$frame run14 run15 run16 run17 run18 run19 run20 run21 run22 run23
$frame run24 run25

$frame jump1 jump2 jump3 jump4 jump5 jump6

$frame fly1 fly2 fly3 fly4

$frame exp

void()	tbaby_stand1	=[	$walk1,		tbaby_stand1	] {COOP_Idle();};

void()	tbaby_hang1		=[	$walk1,		tbaby_hang1	] {COOP_Idle();};

void()	tbaby_walk1	=[	$walk1,		tbaby_walk2	] {COOP_Turn();};
void()	tbaby_walk2	=[	$walk2,		tbaby_walk3	] {COOP_Turn();};
void()	tbaby_walk3	=[	$walk3,		tbaby_walk4	] {COOP_Turn();};
void()	tbaby_walk4	=[	$walk4,		tbaby_walk5	] {COOP_Turn();};
void()	tbaby_walk5	=[	$walk5,		tbaby_walk6	] {COOP_Turn();};
void()	tbaby_walk6	=[	$walk6,		tbaby_walk7	] {COOP_Turn();};
void()	tbaby_walk7	=[	$walk7,		tbaby_walk8	] {COOP_Turn();};
void()	tbaby_walk8	=[	$walk8,		tbaby_walk9	] {COOP_Turn();};
void()	tbaby_walk9	=[	$walk9,		tbaby_walk10	] {COOP_Turn();};
void()	tbaby_walk10	=[	$walk10,		tbaby_walk11	] {COOP_Turn();};
void()	tbaby_walk11	=[	$walk11,		tbaby_walk12	] {COOP_Walk(2);};
void()	tbaby_walk12	=[	$walk12,		tbaby_walk13	] {COOP_Walk(2);};
void()	tbaby_walk13	=[	$walk13,		tbaby_walk14	] {COOP_Walk(2);};
void()	tbaby_walk14	=[	$walk14,		tbaby_walk15	] {COOP_Walk(2);};
void()	tbaby_walk15	=[	$walk15,		tbaby_walk16	] {COOP_Walk(2);};
void()	tbaby_walk16	=[	$walk16,		tbaby_walk17	] {COOP_Walk(2);};
void()	tbaby_walk17	=[	$walk17,		tbaby_walk18	] {COOP_Walk(2);};
void()	tbaby_walk18	=[	$walk18,		tbaby_walk19	] {COOP_Walk(2);};
void()	tbaby_walk19	=[	$walk19,		tbaby_walk20	] {COOP_Walk(2);};
void()	tbaby_walk20	=[	$walk20,		tbaby_walk21	] {COOP_Walk(2);};
void()	tbaby_walk21	=[	$walk21,		tbaby_walk22	] {COOP_Walk(2);};
void()	tbaby_walk22	=[	$walk22,		tbaby_walk23	] {COOP_Walk(2);};
void()	tbaby_walk23	=[	$walk23,		tbaby_walk24	] {COOP_Walk(2);};
void()	tbaby_walk24	=[	$walk24,		tbaby_walk25	] {COOP_Walk(2);};
void()	tbaby_walk25	=[	$walk25,		tbaby_walk1	] {COOP_Walk(2);};

void()	tbaby_run1	=[	$run1,		tbaby_run2	] {COOP_Turn();};
void()	tbaby_run2	=[	$run2,		tbaby_run3	] {COOP_Turn();};
void()	tbaby_run3	=[	$run3,		tbaby_run4	] {COOP_Turn();};
void()	tbaby_run4	=[	$run4,		tbaby_run5	] {COOP_Turn();};
void()	tbaby_run5	=[	$run5,		tbaby_run6	] {COOP_Turn();};
void()	tbaby_run6	=[	$run6,		tbaby_run7	] {COOP_Turn();};
void()	tbaby_run7	=[	$run7,		tbaby_run8	] {COOP_Turn();};
void()	tbaby_run8	=[	$run8,		tbaby_run9	] {COOP_Turn();};
void()	tbaby_run9	=[	$run9,		tbaby_run10	] {COOP_Turn();};
void()	tbaby_run10	=[	$run10,		tbaby_run11	] {COOP_Turn();};
void()	tbaby_run11	=[	$run11,		tbaby_run12	] {COOP_Run(2);};
void()	tbaby_run12	=[	$run12,		tbaby_run13	] {COOP_Run(2);};
void()	tbaby_run13	=[	$run13,		tbaby_run14	] {COOP_Run(2);};
void()	tbaby_run14	=[	$run14,		tbaby_run15	] {COOP_Run(2);};
void()	tbaby_run15	=[	$run15,		tbaby_run16	] {COOP_Run(2);};
void()	tbaby_run16	=[	$run16,		tbaby_run17	] {COOP_Run(2);};
void()	tbaby_run17	=[	$run17,		tbaby_run18	] {COOP_Run(2);};
void()	tbaby_run18	=[	$run18,		tbaby_run19	] {COOP_Run(2);};
void()	tbaby_run19	=[	$run19,		tbaby_run20	] {COOP_Run(2);};
void()	tbaby_run20	=[	$run20,		tbaby_run21	] {COOP_Run(2);};
void()	tbaby_run21	=[	$run21,		tbaby_run22	] {COOP_Run(2);};
void()	tbaby_run22	=[	$run22,		tbaby_run23	] {COOP_Run(2);};
void()	tbaby_run23	=[	$run23,		tbaby_run24	] {COOP_Run(2);};
void()	tbaby_run24	=[	$run24,		tbaby_run25	] {COOP_Run(2);};
void()	tbaby_run25	=[	$run25,		tbaby_run1	] {COOP_Run(2);};


//============================================================================


void()	tbaby_jump1;

void()	Tar_JumpTouch =
{
	local	float	ldmg;

	if (other.takedamage && other.classname != self.classname)
	{
		if ( vlen(self.velocity) > 400 )
		{
			ldmg = #IDMON_TARBABY_HITDMG + 10*random();
			TF_T_Damage (other, self, self, ldmg, #TF_TD_NOTTEAM, #TF_TD_MELEE);
			sound (self, #CHAN_WEAPON, "blob/hit1.wav", 1, #ATTN_NORM);
		}
	}
	else
		sound (self, #CHAN_WEAPON, "blob/land1.wav", 1, #ATTN_NORM);


	if (!checkbottom(self))
	{
		if (self.flags & #FL_ONGROUND)
		{	// jump randomly to not get hung up
//dprint ("popjump\n");
	self.touch = SUB_Null;
	self.think = tbaby_run1;
	self.movetype = #MOVETYPE_STEP;
	self.nextthink = time + 0.1;

//			self.velocity_x = (random() - 0.5) * 600;
//			self.velocity_y = (random() - 0.5) * 600;
//			self.velocity_z = 200;
//			self.flags = self.flags - #FL_ONGROUND;
		}
		return;	// not on ground yet
	}

	self.touch = SUB_Null;
	self.think = tbaby_jump1;
	self.nextthink = time + 0.1;
};

void()	tbaby_jump5;

void()	tbaby_fly1		=[	$fly1,	tbaby_fly2	] {};
void()	tbaby_fly2		=[	$fly2,	tbaby_fly3	] {};
void()	tbaby_fly3		=[	$fly3,	tbaby_fly4	] {};
void()	tbaby_fly4		=[	$fly4,	tbaby_fly1	] {
self.cnt = self.cnt + 1;
if (self.cnt == 4)
{
//dprint ("spawn hop\n");
tbaby_jump5 ();
}
};

void()	tbaby_jump1		=[	$jump1,	tbaby_jump2		] {COOP_Turn();};
void()	tbaby_jump2		=[	$jump2,	tbaby_jump3		] {COOP_Turn();};
void()	tbaby_jump3		=[	$jump3,	tbaby_jump4		] {COOP_Turn();};
void()	tbaby_jump4		=[	$jump4,	tbaby_jump5		] {COOP_Turn();};
void()	tbaby_jump5		=[	$jump5,	tbaby_jump6		]
{	
	self.movetype = #MOVETYPE_BOUNCE;
	self.touch = Tar_JumpTouch;
	makevectors (self.angles);
	self.origin_z = self.origin_z + 1;
	self.velocity = v_forward * 600 + '0 0 200';
	self.velocity_z = self.velocity_z + random()*150;
	if (self.flags & #FL_ONGROUND)
		self.flags = self.flags - #FL_ONGROUND;
	self.cnt = 0;
};
void()	tbaby_jump6	=[	$jump6,tbaby_fly1	] {};



//=============================================================================

void()	tbaby_die1	=[	$exp,		tbaby_die2	] {
self.takedamage = #DAMAGE_NO;
};
void()	tbaby_die2	=[	$exp,		tbaby_run1	] 
{
	T_RadiusDamage (self, self, 120, world);

	sound (self, #CHAN_VOICE, "blob/death1.wav", 1, #ATTN_NORM);
	self.origin = self.origin - 8*normalize(self.velocity);

	WriteByte (#MSG_MULTICAST, #SVC_TEMPENTITY);
	WriteByte (#MSG_MULTICAST, #TE_TAREXPLOSION);
	WriteCoord (#MSG_MULTICAST, self.origin_x);
	WriteCoord (#MSG_MULTICAST, self.origin_y);
	WriteCoord (#MSG_MULTICAST, self.origin_z);
	multicast (self.origin, #MULTICAST_PHS);

	remove (self);
};

//=============================================================================

float() TarbabyOnSight =
{
	sound (self, #CHAN_VOICE, "blob/sight1.wav", 1, #ATTN_NORM);
	return #TRUE;
};


/*QUAKED monster_tarbaby (1 0 0) (-16 -16 -24) (16 16 24) Ambush
*/
void() monster_tarbaby =
{
	if ( deathmatch ) {
		remove( self );
		return;
	}

	self.classname = "idmonster_tarbaby";

	if (!server_spawned) {
		precache_model2 ("progs/tarbaby.mdl");

		precache_sound2 ("blob/death1.wav");
		precache_sound2 ("blob/hit1.wav");
		precache_sound2 ("blob/land1.wav");
		precache_sound2 ("blob/sight1.wav");
	}
	
	self.solid = #SOLID_SLIDEBOX;
	self.movetype = #MOVETYPE_STEP;

	// tarbaby doesn't gib, so no need for a head
	setmodel (self, "progs/tarbaby.mdl");

	setsize (self, '-16 -16 -24', '16 16 40');
	self.max_health = self.health = #IDMON_TARBABY_HEALTH;

	self.th_stand = tbaby_stand1;
	self.th_walk = tbaby_walk1;
	self.th_run = tbaby_run1;
	self.th_missile = tbaby_jump1;
	self.th_melee = tbaby_jump1;
	self.th_die = tbaby_die1;


	self.netname = "spawn";

	self.monsterweight = #MWEIGHT_SMALL;
	self.monsterflags = #MFLAG_NOHEART | #MFLAG_NOLEGS;

	// monsters have a team of their own
	if ( !self.team_no )
		self.team_no = #TEAMNO_MONSTERS;
	self.#monsterflag = #STRFLAG_MONSTER;

	self.OnNoticeEnemy = TarbabyOnSight;
	self.#npc_spawnfunc = monster_tarbaby;
	COOP_SetLives ();

	self.#npc_explosionmult = 1.25;
	
	coop_walkmonster_start ();
};

#endif
