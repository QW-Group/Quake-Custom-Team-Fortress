/*
	coop_ai.qc - standard ai functions

	GOING AWAY!
*/

#ifndef COOP_MODE_ENHANCED
#pragma DONT_COMPILE_THIS_FILE
#else


//============================================================================

void() COOP_HuntTarget =
{
	self.goalentity = self.enemy;
	self.think = self.th_run;
	self.ideal_yaw = vectoyaw(self.enemy.origin - self.origin);
	self.nextthink = time + 0.1;
	SUB_AttackFinished (1);	// wait a while before first attack
};

void() COOP_SightSound =
{
local float	rsnd;

	if (self.classname == "monster_ogre")	
		sound (self, #CHAN_VOICE, "ogre/ogwake.wav", 1, #ATTN_NORM);
	else if (self.classname == "monster_knight")
		sound (self, #CHAN_VOICE, "knight/ksight.wav", 1, #ATTN_NORM);
	else if (self.classname == "monster_shambler")
		sound (self, #CHAN_VOICE, "shambler/ssight.wav", 1, #ATTN_NORM);
	else if (self.classname == "monster_demon1")
		sound (self, #CHAN_VOICE, "demon/sight2.wav", 1, #ATTN_NORM);
	else if (self.classname == "monster_wizard")
		sound (self, #CHAN_VOICE, "wizard/wsight.wav", 1, #ATTN_NORM);
	else if (self.classname == "monster_zombie")
		sound (self, #CHAN_VOICE, "zombie/z_idle.wav", 1, #ATTN_NORM);
	else if (self.classname == "monster_dog")
		sound (self, #CHAN_VOICE, "dog/dsight.wav", 1, #ATTN_NORM);
	else if (self.classname == "monster_hell_knight")
		sound (self, #CHAN_VOICE, "hknight/sight1.wav", 1, #ATTN_NORM);
	else if (self.classname == "monster_tarbaby")
		sound (self, #CHAN_VOICE, "blob/sight1.wav", 1, #ATTN_NORM);
	else if (self.classname == "monster_vomit")
		sound (self, #CHAN_VOICE, "vomitus/v_sight1.wav", 1, #ATTN_NORM);
	else if (self.classname == "monster_enforcer")
	{
		rsnd = rint(random() * 3);			
		if (rsnd == 1)
			sound (self, #CHAN_VOICE, "enforcer/sight1.wav", 1, #ATTN_NORM);
		else if (rsnd == 2)
			sound (self, #CHAN_VOICE, "enforcer/sight2.wav", 1, #ATTN_NORM);
		else if (rsnd == 0)
			sound (self, #CHAN_VOICE, "enforcer/sight3.wav", 1, #ATTN_NORM);
		else
			sound (self, #CHAN_VOICE, "enforcer/sight4.wav", 1, #ATTN_NORM);
	}
	else if (self.classname == "monster_army")
		sound (self, #CHAN_VOICE, "soldier/sight1.wav", 1, #ATTN_NORM);
	else if (self.classname == "monster_shalrath")
		sound (self, #CHAN_VOICE, "shalrath/sight.wav", 1, #ATTN_NORM);
};

void() COOP_FoundTarget =
{
	if (self.enemy.classname == "player")
	{	// let other monsters see this monster for a while
		sight_entity = self;
		sight_entity_time = time;
	}
	
	self.show_hostile = time + 1;		// wake up other monsters

	COOP_SightSound ();
	COOP_HuntTarget ();
};

/*
===========
FindTarget

Self is currently not attacking anything, so try to find a target

Returns TRUE if an enemy was sighted

When a player fires a missile, the point of impact becomes a fakeplayer so
that monsters that see the impact will respond as if they had seen the
player.

To avoid spending too much time, only a single client (or fakeclient) is
checked each frame.  This means multi player games will have slightly
slower noticing monsters.
============
*/
float() COOP_FindTarget =
{
	local entity	client;
	local float		r;

// if the first spawnflag bit is set, the monster will only wake up on
// really seeing the player, not another monster getting angry

// spawnflags & 3 is a big hack, because zombie crucified used the first
// spawn flag prior to the ambush flag, and I forgot about it, so the second
// spawn flag works as well
	if (sight_entity_time >= time - 0.1 && !(self.spawnflags & 3) )
	{
		client = sight_entity;
		if (client.enemy == self.enemy)
			return;
	}
	else
	{
		client = checkclient ();
		if (!client)
			return #FALSE;	// current check entity isn't in PVS
	}

	if (client == self.enemy)
		return #FALSE;

	if (client.flags & #FL_NOTARGET)
		return #FALSE;
	if (client.items & #IT_INVISIBILITY)
		return #FALSE;

	r = range (client);
	if (r == #RANGE_FAR)
		return #FALSE;
		
	if (!visible (client))
		return #FALSE;

	if (r == #RANGE_NEAR)
	{
		if (client.show_hostile < time && !infront (client))
			return #FALSE;
	}
	else if (r == #RANGE_MID)
	{
		if ( /* client.show_hostile < time || */ !infront (client))
			return #FALSE;
	}
	
//
// got one
//
	self.enemy = client;
	if (self.enemy.classname != "player")
	{
		self.enemy = self.enemy.enemy;
		if (self.enemy.classname != "player")
		{
			self.enemy = world;
			return #FALSE;
		}
	}
	
	COOP_FoundTarget ();

	return #TRUE;
};


//=============================================================================

void(float dist) COOP_ai_forward =
{
	walkmove (self.angles_y, dist);
};

void(float dist) COOP_ai_back =
{
	walkmove ( (self.angles_y+180), dist);
};


/*
=============
ai_pain

stagger back a bit
=============
*/
void(float dist) COOP_ai_pain =
{
	COOP_ai_back (dist);
/*
	local float	away;
	
	away = anglemod (vectoyaw (self.origin - self.enemy.origin) 
	+ 180*(random()- 0.5) );
	
	walkmove (away, dist);
*/
};

/*
=============
ai_painforward

stagger back a bit
=============
*/
void(float dist) COOP_ai_painforward =
{
	walkmove (self.ideal_yaw, dist);
};

/*
=============
ai_walk

The monster is walking it's beat
=============
*/
void(float dist) COOP_ai_walk =
{
	local vector		mtemp;
	
	movedist = dist;
	
	if (self.classname == "monster_dragon")
	{
		movetogoal (dist);
		return;
	}
	// check for noticing a player
	if (COOP_FindTarget ())
		return;

	movetogoal (dist);
};


/*
=============
ai_stand

The monster is staying in one place for a while, with slight angle turns
=============
*/
void() COOP_ai_stand =
{

	if (COOP_FindTarget ())
		return;
	
	if (time > self.pausetime)
	{
		self.th_walk ();
		return;
	}
	
// change angle slightly

};

/*
=============
ai_turn

don't move, but turn towards ideal_yaw
=============
*/
void() COOP_ai_turn =
{
	if (COOP_FindTarget ())
		return;
	
	ChangeYaw ();
};

//=============================================================================

// ChooseTurn and FacingIdeal went here, don't think we need them

//=============================================================================

float()	WizardCheckAttack;
float()	DogCheckAttack;

float() CheckAnyAttack =
{
	if (!enemy_vis)
		return;
	if (self.classname == "monster_army")
		return SoldierCheckAttack ();
	if (self.classname == "monster_ogre")
		return OgreCheckAttack ();
	if (self.classname == "monster_shambler")
		return ShamCheckAttack ();
	if (self.classname == "monster_demon1")
		return DemonCheckAttack ();
	if (self.classname == "monster_dog")
		return DogCheckAttack ();
	if (self.classname == "monster_wizard")
		return WizardCheckAttack ();
	return CheckAttack ();
};


/*
=============
ai_run_melee

Turn and close until within an angle to launch a melee attack
=============
*/
void() ai_run_melee =
{
	self.ideal_yaw = enemy_yaw;
	ChangeYaw ();

	if (FacingIdeal())
	{
		self.th_melee ();
		self.attack_state = AS_STRAIGHT;
	}
};


/*
=============
ai_run_missile

Turn in place until within an angle to launch a missile attack
=============
*/
void() ai_run_missile =
{
	self.ideal_yaw = enemy_yaw;
	ChangeYaw ();
	if (FacingIdeal())
	{
		self.th_missile ();
		self.attack_state = AS_STRAIGHT;
	}
};


/*
=============
ai_run_slide

Strafe sideways, but stay at aproximately the same range
=============
*/
void() ai_run_slide =
{
	local float	ofs;
	
	self.ideal_yaw = enemy_yaw;
	ChangeYaw ();
	if (self.lefty)
		ofs = 90;
	else
		ofs = -90;
	
	if (walkmove (self.ideal_yaw + ofs, movedist))
		return;
		
	self.lefty = 1 - self.lefty;
	
	walkmove (self.ideal_yaw - ofs, movedist);
};


/*
=============
ai_run

The monster has an enemy it is trying to kill
=============
*/
void(float dist) ai_run =
{
	local	vector	delta;
	local	float	axis;
	local	float	direct, ang_rint, ang_floor, ang_ceil;
	
	movedist = dist;
// see if the enemy is dead
	if (self.enemy.health <= 0)
	{
		self.enemy = world;
	// FIXME: look all around for other targets
		if (self.oldenemy.health > 0)
		{
			self.enemy = self.oldenemy;
			HuntTarget ();
		}
		else
		{
			if (self.movetarget)
				self.th_walk ();
			else
				self.th_stand ();
			return;
		}
	}

	self.show_hostile = time + 1;		// wake up other monsters

// check knowledge of enemy
	enemy_vis = visible(self.enemy);
	if (enemy_vis)
		self.search_time = time + 5;

// look for other coop players
	if (self.search_time < time)
	{
		if (FindTarget ())
			return;
	}

	enemy_infront = infront(self.enemy);
	enemy_range = range(self.enemy);
	enemy_yaw = vectoyaw(self.enemy.origin - self.origin);
	
	if (self.attack_state == AS_MISSILE)
	{
//dprint ("ai_run_missile\n");
		ai_run_missile ();
		return;
	}
	if (self.attack_state == AS_MELEE)
	{
//dprint ("ai_run_melee\n");
		ai_run_melee ();
		return;
	}

	if (CheckAnyAttack ())
		return;					// beginning an attack
		
	if (self.attack_state == AS_SLIDING)
	{
		ai_run_slide ();
		return;
	}
		
// head straight in
	movetogoal (dist);		// done in C code...
};

#endif
