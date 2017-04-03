/*======================================================
	WEAPONS.QC			Custom TeamFortress v3.1

	(c) TeamFortress Software Pty Ltd	29/2/97
	(c) William Kerney			5/21/00
========================================================
All the functions for firing all the weapons, holds
all new precache() functions, finding best weapons, 
choosing next weapon, and all impulse commands.
======================================================*/
void() SniperSight_Update2; //CH for RL
void() I_DID_CHEAT_ONE; //CH for speed.qc
void() I_DID_CHEAT_TWO;
void() I_DID_CHEAT_THREE;
//void(string gibname, float dm) ThrowGib;	
void(string gibname, float dm, float makecool, float gibskin, float gibkgs, float randorg) ThrowGib;
void (entity targ, entity inflictor, entity attacker, float damage) T_Damage;
void (entity targ, entity inflictor, entity attacker, float damage, float T_flags, float T_AttackType) TF_T_Damage;
void () player_run;
void(entity bomb, entity attacker, float rad, entity ignore) T_RadiusDamage;
void() TeamFortress_DisplayDetectionItems;
float(vector veca, vector vecb) crossproduct;
void(vector org, float damage) SpawnBlood;
void(entity rhook) Reset_Grapple;
void() SuperDamageSound;
float() W_BestWeapon;
void() ConcussionGrenadeTimer;
void() W_PrintWeaponMessage;
void() button_touch;
void() button_fire;
void() MauserRecoilThink;
float() ReturnWeaponVelocity;
vector() Grunty_LeadShot;

// TeamFortress Impulse Commands
void() TeamFortress_ChangeClass;
void() TeamFortress_DisplayLegalClasses;
void() TeamFortress_Inventory;
void() TeamFortress_SaveMe;
void(float inAuto) TeamFortress_ID;
void() TeamFortress_ShowTF;
void() TeamFortress_SniperWeapon;
void() TeamFortress_AssaultWeapon;
void() TeamFortress_IncendiaryCannon;
void() TeamFortress_FlameThrower;
void() TeamFortress_PrimeGrenade;
void() TeamFortress_ThrowGrenade;
void() TeamFortress_Discard;
void(entity p) TeamFortress_SetSpeed;
void() TeamFortress_DetonatePipebombs;
void() PipebombTouch;
void(float foo) TeamFortress_DetpackStop;
void(float type) SniperSight_Create;
void(float zoom_level) TF_zoom;
void() TeamFortress_ReloadCurrentWeapon;
void() TeamFortress_AutoZoomToggle;
void() TeamFortress_StatusQuery;
void() TeamFortress_SpyGoUndercover;
void(float type) TeamFortress_SpyFeignDeath;
void() TeamFortress_EngineerBuild;
void() DropKey;
void() UseSpecialSkill;
void() UseJobSkill; //WK Function for handling professions
void (entity targ, float pain) RevealThief;
void(vector startpos) GuerillaMineSweep;
void(entity foo,float bar) makeImmune;
float() CheckForReload;
void() SBBuildSensor;
void() SBFireInterface;
//void() SBInitiateInterface;
void() W_FireMauser;
void() W_FireDaedalus;

// TeamFortress Pre-Impulse Commands
void(float scanrange,float inAuto) TeamFortress_Scan;
void(float timer) TeamFortress_SetDetpack;

// Team Functions
float(float tno) TeamFortress_TeamSet;
//void(float tno) TeamFortress_TeamShowScores;
void(float all, float teamscored, float scorepoints) TeamFortress_TeamShowScores;
void(entity Player) TeamFortress_TeamShowMemberClasses;

#ifdef DEMO_STUFF
// Camera Functions
void() CamLock;
void() CamDistLock;
void() CamVecLock; 
void() CamAngleLock;
void() CamRevAngleLock;
void() CamProjectileLock;
void() CamProjectileZoom;
void() CamProjectileLockOn;
void() CamProjectileLockOff;
void() CamOffset;
void() CamDrop;
void() fadetoblack;
void() fadefromblack;
void() fadetowhite;
void() fadefromwhite;
#endif

// Engineer Functions
void(entity disp) Engineer_UseDispenser;
void(entity cam) Engineer_UseSensor;
void(entity gun) Engineer_UseSentryGun;
void(entity gun) Engineer_UseTesla;
void(entity cam) Engineer_UseCamera;
void(entity tele) Engineer_UseTeleporter;
void(entity field) Engineer_UseFieldGen;

void(entity spy) Spy_RemoveDisguise;

// Help functions
void() TeamFortress_MOTD;
void() TeamFortress_HelpMap;
void(float res) StatusRes;

// BioInfection functions
void() BioInfection_Decay;
void() BioInfection_MonsterDecay;

// Attacking functions
void() W_FireFlame;
void() W_FireIncendiaryCannon;
void() W_FireTranq;
void() W_FireLaser;

// Timer Functions
void() HallucinationTimer;
void() TranquiliserTimer;

// CTF Support functions
void() TeamFortress_CTF_FlagInfo;

// #PC_UNDEFINED viewing functions
void() TF_MovePlayer;

//WK CustomTF Functions
void() custom_demon_precache;
void() custom_lay;
//void() CameraSwitchView;

//CH dropitems
float() TeamFortress_DropItems;

//- OfN -
void(entity player) ActivateHolo;
void(entity who) MakeMeDebug;
void(vector org, vector dir) grunty_spike;
//void (float startup) UpdateInfos;
void() launch_horn;
void() player_laser1;
//void(entity field) PutFieldWork;
//void(entity tfield, vector where, entity thing) FieldExplosion;

void(entity tfield, vector where, entity thing) FieldEvent;

void() Player_Punish;
void() Player_VoteMap;
void() Player_VoteYes;
void() Player_VoteNo;

float(float imp) GoodIntermissionImpulse;

string(entity themonster) GetMonsterName;
void(entity ignore, string st, string st2, string st3, string st4, string st5, string st6) teamsprint6;

void(entity targetent, vector where, float spiketype, float bloodtype, float bloodammount) SpawnDmgFX;

void(vector src, vector endpos) BulletTraceline;

// called by worldspawn
void() W_Precache =
{
	precache_sound ("weapons/r_exp3.wav");	// new rocket explosion
	precache_sound ("weapons/rocket1i.wav");  // spike gun
	precache_sound ("weapons/sgun1.wav");
	precache_sound ("weapons/guncock.wav"); // player shotgun
	precache_sound ("weapons/ric1.wav");	// ricochet (used in c code)
	precache_sound ("weapons/ric2.wav");	// ricochet (used in c code)
	precache_sound ("weapons/ric3.wav");	// ricochet (used in c code)
	precache_sound ("weapons/spike2.wav");	// super spikes
	precache_sound ("weapons/tink1.wav");	// spikes tink (used in c code)
	precache_sound ("weapons/grenade.wav"); // grenade launcher
	precache_sound ("weapons/bounce.wav");	// grenade bounce
	precache_sound ("weapons/shotgn2.wav"); // super shotgun
	precache_sound ("wizard/wattack.wav");	  // sniper rifle
	precache_sound ("items/r_item1.wav");	// Medikit
	precache_sound ("items/r_item2.wav");	// Medikit
	precache_model ("progs/flame2.mdl");	// Flamethrower
	precache_sound ("ambience/fire1.wav");
	//UNUSED_TEST precache_sound2("blob/land1.wav");		// Hook
	//precache_model2("progs/v_spike.mdl"); // Hook
	precache_sound ("hknight/hit.wav"); 	// Hook
// NEW FILES
	precache_sound ("weapons/turrset.wav"); // Sentry Gun Setup
	precache_sound ("weapons/turrspot.wav");	// Sentry Gun Spot 
	precache_sound ("weapons/turridle.wav");	// Sentry Gun Idle
		precache_sound ("weapons/sniper.wav");	// sniper rifle
		precache_sound ("weapons/flmfire2.wav");	// flamethrower
		precache_sound ("weapons/flmgrexp.wav");	// flamethrower
	precache_sound ("misc/vapeur2.wav");	// flamethrower
	precache_sound ("weapons/asscan1.wav"); // Assault Cannon Powerup
	precache_sound ("weapons/asscan2.wav"); // Assault Cannon Churning
	precache_sound ("weapons/asscan3.wav"); // Assault Cannon Powerdown
	precache_sound ("weapons/railgun.wav"); // Railgun
	precache_sound ("weapons/dartgun.wav"); // Spy's dart gun
	  //precache_sound ("ambience/thunder1.wav");	// Connect sound
	
	//WK
	//precache_model ("progs/v_merc.mdl");		//Carbine Model
	//precache_sound ("weapons/carbfire.wav");		// Carbine shooting
	//precache_sound ("weapons/carbreld.wav");		// Carbine shooting
	//precache_sound ("weapons/carbrock.wav");		// Carbine shooting
	//precache_sound ("weapons/nishi.wav"); 	// Nishi shooting
	precache_model ("progs/telepad.mdl");		//Teleporter pad
	precache_model ("progs/camera.mdl");		// Security Camera
	precache_sound ("ambience/orff.wav");		// Chaplan sound
	precache_sound ("weapons/guerblip.wav");	// Landmine beep - Ofn was guerilla_blip
	precache_sound ("weapons/guerset.wav"); // Landmine set - oFn guerilla_set
	precache_sound ("weapons/cambeep.wav"); // CH camera beep - OfN camera_beep
	precache_sound ("misc/enemy.wav"); // sensor alert
	precache_sound ("weapons/fith.wav");	// WK Fire in the hole
	//precache_model2("progs/guerilla_mine.mdl");	// The Landmine
	//precache_model ("progs/tesla.mdl");			  // The Tesla (by --Warrior--)
	precache_model ("progs/minimis.mdl");		  // Swarm missile (BLOG) - OfN was minimissile
	//precache_model ("progs/newtesla.mdl");		  // The Tesla (by --Warrior-- & BLOG)

	precache_model ("progs/coil.mdl");		  // The Tesla (by --Warrior-- & BLOG)

	//precache_model ("progs/tscloak.mdl");

	precache_model ("progs/tesgib1.mdl");		  // Tesla Gib
	precache_model ("progs/tesgib2.mdl");		  // Tesla Gib
	precache_model ("progs/tesgib3.mdl");		  // Tesla Gib
	precache_sound ("doors/medtry.wav");		  //CH Dropping detpack sound
	precache_sound ("doors/baseuse.wav");		  //CH Detpack warning sound
	precache_sound ("enforcer/sight1.wav");   // WK Taunt
	precache_sound ("enforcer/sight2.wav");   // WK Taunt
	precache_sound ("enforcer/sight3.wav");   // WK Taunt
	precache_sound ("enforcer/sight4.wav");   // WK Taunt

	custom_demon_precache();
};

float() crandom =
{
	return 2*(random() - 0.5);
};

//======================================================================
// Calculate the attack_finished time
void(float att_delay) Attack_Finished =
{
	if (self.tfstate & #TFSTATE_TRANQUILISED)
		att_delay = att_delay * 1.5;
	
	if (self.aura == #AURA_HASTE && self.#runes & #RUNE_SPEED)
		att_delay = att_delay * 0.5;
	else
	{
		if (self.aura == #AURA_HASTE)
			att_delay = att_delay * 0.75;
		else if (self.#runes & #RUNE_SPEED)
			att_delay = att_delay * 0.7;
	}
	
	self.attack_finished = time + att_delay;

	/*OLD CODEif (self.tfstate & #TFSTATE_TRANQUILISED)
		self.attack_finished = time + (att_delay * 1.5);
	else if (self.aura == #AURA_HASTE)
		self.attack_finished = time + (att_delay * 0.75);
	else 
		self.attack_finished = time + att_delay;*/
};

/*
================
W_FireAxe
================
*/
void() W_FireAxe =
{
	local	vector	source;
	local	vector	org, def;
	local	vector	dir;
	local entity oself; // OfN

	if (self.classname == "player")
		makevectors(self.v_angle);
	else
		dir = normalize (self.enemy.origin - self.origin);
	source = self.origin + '0 0 16';
	
	if (self.classname == "player")
	{
		if (!(self.cutf_items & #CUTF_CLOSECOMBAT))
			//traceline (source, source + v_forward*64, #TL_ANY_SOLID, self);
			BulletTraceline(source, source + v_forward*64);
		else
			//traceline (source, source + v_forward*96, #TL_ANY_SOLID, self);
			BulletTraceline(source, source + v_forward*96);
	}
	else
		//traceline (source, source + dir*64, #TL_ANY_SOLID, self);
		BulletTraceline(source, source + dir*64);

	if (trace_fraction == 1.0)
		return;
	
	org = trace_endpos - v_forward*4;

	if (trace_ent.classname == "force_field")
	{
		FieldEvent(trace_ent,trace_endpos,trace_ent);		 
		return;
	}

	#ifdef GIBABLE_CORPSES
	if (trace_ent.#corpseflag == #STRFLAG_CORPSE)
	{
		if (self.cutf_items & #CUTF_KNIFE)
		{
			if (self.cutf_items & #CUTF_CLOSECOMBAT)
				DamageCorpse(trace_ent,30,trace_ent.origin,self,#TRUE);    
			else
				DamageCorpse(trace_ent,15,trace_ent.origin,self,#TRUE);
		}
		else
		{
			if (self.cutf_items & #CUTF_CLOSECOMBAT)
				DamageCorpse(trace_ent,20,trace_ent.origin,self,#TRUE);    
			else
				DamageCorpse(trace_ent,10,trace_ent.origin,self,#TRUE);
		}
		
		return;
	}
	#endif

	if (trace_ent.takedamage)
	{
		trace_ent.axhitme = 1;

		SpawnBlood (org, 20);

#ifdef COOP_MODE_ENHANCED
		if (!(self.cutf_items & #CUTF_KNIFE) || (trace_ent.classname != "player" && !COOP_IsCoopMonster( trace_ent )))
#else
		if (!(self.cutf_items & #CUTF_KNIFE) || trace_ent.classname != "player")
#endif
		{
			deathmsg = #DMSG_AXE;

			if (!(self.cutf_items & #CUTF_CLOSECOMBAT))
				TF_T_Damage (trace_ent, self, self, 30, #TF_TD_NOTTEAM, #TF_TD_OTHER);
			else
				TF_T_Damage (trace_ent, self, self, 60, #TF_TD_NOTTEAM, #TF_TD_OTHER);
		}
		else	// spy can try for the backstab!
		{
			//WK Only give blood if you hit an enemy when being a warlock
			if ((!Teammate(trace_ent.team_no, self.team_no) || !(self.job & #JOB_WARLOCK)) && prematch < time)
			{
				self.job = self.job | #JOB_BLOODY_KNIFE;
				self.weaponmode = 1; // Put blood on the knife
				self.weaponmodel = "progs/v_knife2.mdl";
			}
			else if (self.job & #JOB_WARLOCK)
			{
				sprint(self,#PRINT_HIGH,"You may only draw blood from enemies\n");
			}

			// Check direction of Attack
#ifdef COOP_MODE_ENHANCED
			if (trace_ent.classname != "player")
				makevectors (trace_ent.angles);
			else
				makevectors (trace_ent.v_angle);
#else
			makevectors (trace_ent.v_angle);
#endif

			def = v_right;
			if (self.classname == "player")
				makevectors(self.v_angle);
			else
				makevectors(self.angles);

			// Backstab
			if (crossproduct(def,v_forward) > 0)
			{
				deathmsg = #DMSG_BACKSTAB;
				oself = self;
				self = trace_ent;
				ThrowGib("progs/gib1.mdl", -50, #TRUE,0,#GIB1_KGS, #FALSE);
				ThrowGib("progs/gib2.mdl", 10, #TRUE,0,#GIB2_KGS, #FALSE);
				ThrowGib("progs/gib3.mdl", 50, #TRUE,0,#GIB3_KGS, #FALSE);
				self = oself;
				//ThrowGib ("progs/gib2.mdl", 25); //-added

//WK 120 & no IGNOREARMOR
				if (!(self.cutf_items & #CUTF_CLOSECOMBAT))
					TF_T_Damage (trace_ent, self, self, 100, #TF_TD_IGNOREARMOUR | #TF_TD_NOTTEAM, #TF_TD_OTHER);
				else
					TF_T_Damage (trace_ent, self, self, 200, #TF_TD_IGNOREARMOUR | #TF_TD_NOTTEAM, #TF_TD_OTHER);
			}
			else
			{
				deathmsg = #DMSG_AXE;
//WK 40
				if (!(self.cutf_items & #CUTF_CLOSECOMBAT))
					TF_T_Damage (trace_ent, self, self, 50, #TF_TD_NOTTEAM, #TF_TD_OTHER);
				else
					TF_T_Damage (trace_ent, self, self, 100, #TF_TD_NOTTEAM, #TF_TD_OTHER); 			
			}
		}
	}
	else
	{	// hit wall
		sound (self, #CHAN_WEAPON, "player/axhit2.wav", 1, #ATTN_NORM);
		WriteByte (#MSG_BROADCAST, #SVC_TEMPENTITY);
		WriteByte (#MSG_BROADCAST, #TE_GUNSHOT);
	#ifdef QUAKE_WORLD
		WriteByte (#MSG_MULTICAST, 3);
	#endif
		WriteCoord (#MSG_BROADCAST, org_x);
		WriteCoord (#MSG_BROADCAST, org_y);
		WriteCoord (#MSG_BROADCAST, org_z);
	#ifdef QUAKE_WORLD
		multicast (org, #MULTICAST_PVS);
	#endif
	}
};

/*
================
W_FireSpanner
================
*/
void() W_FireSpanner =
{
	local vector source;
	local vector org;//, def;
	local float healam;
	local entity te;

	makevectors(self.v_angle);
	source = self.origin + '0 0 16';
	if (self.cutf_items & #CUTF_CLOSECOMBAT)
		traceline (source, source + v_forward*96, #TL_ANY_SOLID, self);
	else
		traceline (source, source + v_forward*64, #TL_ANY_SOLID, self);

	if (trace_fraction == 1.0)
		return;
	
	org = trace_endpos - v_forward*4;

	if (trace_ent.classname == "force_field")
	{
		FieldEvent(trace_ent,trace_endpos,trace_ent);
		
		//FieldExplosion(trace_ent,trace_endpos,trace_ent);
		//PutFieldWork(trace_ent);

		deathmsg = #DMSG_SPANNERFIELD;
		TF_T_Damage(self, self, self, self.health + 50, #TF_TD_IGNOREARMOUR, #TF_TD_OTHER);
		sound (self, #CHAN_MISC, "effects/crunch.wav", 1, #ATTN_NONE);

		return;
	}

	// It may be a trigger that can be activated by the engineer's spanner
	if (trace_ent.goal_activation & #TFGA_SPANNER)
	{
		// Does the AP match the AP Criteria?
		if (Activated(trace_ent,self))
		{
			DoResults(trace_ent, self, #TRUE);

			if (trace_ent.classname == "func_button")
			{
				trace_ent.enemy = self;
				other = self;
				self = trace_ent;
				self.dont_do_triggerwork = #TRUE;	// Already done in DoResults
				button_fire();
				self = other;
			}
		}
		else
		{
			// If an else goal should be activated, activate it
			if (trace_ent.else_goal != 0)
			{
				te = Findgoal(trace_ent.else_goal);
				if (te)
					DoResults(te, self, (trace_ent.goal_result & #TFGR_ADD_BONUSES));
			}
			else
			{
				sound (self, #CHAN_WEAPON, "player/axhit2.wav", 1, #ATTN_NORM);
				WriteByte (#MSG_BROADCAST, #SVC_TEMPENTITY);
				WriteByte (#MSG_BROADCAST, #TE_GUNSHOT);
			#ifdef QUAKE_WORLD
				WriteByte (#MSG_MULTICAST, 3);
			#endif
				WriteCoord (#MSG_BROADCAST, org_x);
				WriteCoord (#MSG_BROADCAST, org_y);
				WriteCoord (#MSG_BROADCAST, org_z);
			#ifdef QUAKE_WORLD
				multicast (org, #MULTICAST_PVS);
			#endif
			}
		}

		return;
	}

	if (trace_ent.takedamage)
	{
		// Engineer can repair/use his buildings
		if (trace_ent.classname == "building_dispenser")
		{
			Engineer_UseDispenser(trace_ent);
			return;
		}
		else if (trace_ent.classname == "building_sentrygun")
		{
			Engineer_UseSentryGun(trace_ent);
			return;
		}
		else if (trace_ent.classname == "building_sentrygun_base")
		{
			if (trace_ent.oldenemy)
				Engineer_UseSentryGun(trace_ent.oldenemy);
			return;
		}
		else if (trace_ent.classname == "building_tesla")
		{
			Engineer_UseTesla(trace_ent);
			return;
		}
		else if (trace_ent.classname == "building_camera")
		{
			Engineer_UseCamera(trace_ent);
			return;
		}
		else if (trace_ent.classname == "building_sensor")
		{
			Engineer_UseSensor(trace_ent);
			return;
		}
		else if (trace_ent.classname == "building_teleporter")
		{
			Engineer_UseTeleporter(trace_ent);
			return;
		}
		else if (trace_ent.classname == "building_fieldgen")
		{
			Engineer_UseFieldGen(trace_ent);
			return;
		}
		else
		{
			if (trace_ent.classname == "player")
			{
				if (Teammate(trace_ent.team_no, self.team_no) && (teamplay) || (coop))
				{
					healam = #WEAP_SPANNER_REPAIR;
					if (self.ammo_cells < healam)
						healam = self.ammo_cells;

					// Only fix armor if they've got some
					if (trace_ent.armor_allowed == 0) //WK
						return;
						
					if (trace_ent.armorvalue <= 0) // SB
						return;
					
					if (trace_ent.maxarmor - trace_ent.armorvalue < (healam * 4))
						healam = ceil((trace_ent.maxarmor - trace_ent.armorvalue) / 4);
						
					if (healam > 0)
					{
						trace_ent.armorvalue = trace_ent.armorvalue + (healam * 4);
						if (trace_ent.armorvalue > trace_ent.maxarmor)
							trace_ent.armorvalue = trace_ent.maxarmor;

						//WK Give them full armor color
						trace_ent.armortype = trace_ent.armor_allowed;

						self.ammo_cells = self.ammo_cells - healam;

						sound(trace_ent, #CHAN_WEAPON, "items/r_item1.wav", 1, #ATTN_NORM);
						WriteByte (#MSG_BROADCAST, #SVC_TEMPENTITY);
						WriteByte (#MSG_BROADCAST, #TE_GUNSHOT);
					#ifdef QUAKE_WORLD
						WriteByte (#MSG_MULTICAST, 3);
					#endif
						WriteCoord (#MSG_BROADCAST, org_x);
						WriteCoord (#MSG_BROADCAST, org_y);
						WriteCoord (#MSG_BROADCAST, org_z);
					#ifdef QUAKE_WORLD
						multicast (org, #MULTICAST_PVS);
					#endif

						W_SetCurrentAmmo ();
					}
					return;
				}
			}

			trace_ent.axhitme = 1;
			SpawnBlood (org, 20);

			deathmsg = #DMSG_SPANNER;
//WK 20
			if (!(self.cutf_items & #CUTF_CLOSECOMBAT))
				TF_T_Damage (trace_ent, self, self, 20, #TF_TD_NOTTEAM, #TF_TD_OTHER);
			else
				TF_T_Damage (trace_ent, self, self, 40, #TF_TD_NOTTEAM, #TF_TD_OTHER);
		}
	}
	else // hit wall
	{	
		sound (self, #CHAN_WEAPON, "player/axhit2.wav", 1, #ATTN_NORM);
		WriteByte (#MSG_BROADCAST, #SVC_TEMPENTITY);
		WriteByte (#MSG_BROADCAST, #TE_GUNSHOT);
	#ifdef QUAKE_WORLD
		WriteByte (#MSG_MULTICAST, 3);
	#endif
		WriteCoord (#MSG_BROADCAST, org_x);
		WriteCoord (#MSG_BROADCAST, org_y);
		WriteCoord (#MSG_BROADCAST, org_z);
	#ifdef QUAKE_WORLD
		multicast (org, #MULTICAST_PVS);
	#endif
	}
};

/*
================
W_FireMedikit  
================
*/

void(entity ignore, entity ignore2, string st, string st2, string st3, string st4, string st5, string st6) teamsprintbi;
void(float tno, entity ignore, entity ignore2) teamprefixsprintbi;
#ifndef NO_REVIVE
float( entity medic, entity deadPlayer, float reviveFlags ) MedicRevive;
#endif

void(float inAuto) W_FireMedikit =
{
	local	vector	source;
	local	vector	org;
	local	float healam;	
	local	entity te, BioInfection, tempTraceEnt;

#ifndef NO_REVIVE
	// Gizmo - check for reviving dead teammates
	if ( !inAuto )
	if ( MedicRevive( self, world, #REVIVE_PRINTMSGS | #REVIVE_MEDIKITAMMO ) )		// don't continue if we revived someone
		return;
#endif

	source = self.origin + '0 0 16';
	if (self.cutf_items & #CUTF_CLOSECOMBAT)
		traceline (source, source + v_forward*96, #TL_ANY_SOLID, self);
	else
		traceline (source, source + v_forward*64, #TL_ANY_SOLID, self);

	if (trace_fraction == 1.0)
		return;
	
	org = trace_endpos - v_forward*4;

	if (!trace_ent) // OfN - Fixes crash?
		return;

	// Gizmo - sometimes trace_ent will change down in all this code
	tempTraceEnt = trace_ent;

	if (tempTraceEnt.takedamage)
	{
		if (tempTraceEnt.classname == "player")
		{
			if (Teammate(tempTraceEnt.team_no, self.team_no) || (coop))
			{
				healam = #WEAP_MEDIKIT_HEAL;

				// remove concussion from player
				// Try to find a concusstimer entity for this player
				te = find(world, classname, "timer");
				while (((te.owner != tempTraceEnt) || (te.think != ConcussionGrenadeTimer)) && (te != world))
				{
					te = find(te, classname, "timer");
				}

				if (te != world)
				{
					stuffcmd(tempTraceEnt ,"v_idlescale 0\n");
					SpawnBlood(org, 20);
					sprint(tempTraceEnt, #PRINT_HIGH, "you have been healed of your concussion\n");

					// Give the medic a frag for doing it, only if it was caused by an enemy
					if (!Teammate(self.team_no,te.team_no))
					{
						self.real_frags = self.real_frags + 1;
						if (!(toggleflags & #TFLAG_TEAMFRAGS))
							self.frags = self.real_frags;
					}

					dremove(te);
				}

				// remove hallucination from player
				// Try to find a hallucination timer entity for this player
				if (tempTraceEnt.tfstate & #TFSTATE_HALLUCINATING)
				{
					te = find(world, classname, "timer");
					while (((te.owner != tempTraceEnt) || (te.think != HallucinationTimer)) && (te != world))
					{
						te = find(te, classname, "timer");
					}

					if (te != world)
					{
						tempTraceEnt.tfstate = tempTraceEnt.tfstate - (tempTraceEnt.tfstate & #TFSTATE_HALLUCINATING);

						SpawnBlood(org, 20);
						sprint(tempTraceEnt, #PRINT_HIGH, "you have been healed of your hallucinations\n");

						// Give the medic a frag for doing it, only if it was caused by an enemy
						if (!Teammate(self.team_no,te.team_no))
						{
							self.real_frags = self.real_frags + 1;
							if (!(toggleflags & #TFLAG_TEAMFRAGS))
								self.frags = self.real_frags;
						}

						dremove(te);
					}
					else
					{
						RPrint("Warning: Error in Hallucination Timer logic.\n");
					}
				}

				// remove tranquilisation from player
				// Try to find a tranquilisation timer entity for this player
				if (tempTraceEnt.tfstate & #TFSTATE_TRANQUILISED)
				{
					te = find(world, classname, "timer");
					while (((te.owner != tempTraceEnt) || (te.think != TranquiliserTimer)) && (te != world))
					{
						te = find(te, classname, "timer");
					}

					if (te != world)
					{
						tempTraceEnt.tfstate = tempTraceEnt.tfstate - (tempTraceEnt.tfstate & #TFSTATE_TRANQUILISED);
						TeamFortress_SetSpeed(tempTraceEnt);

						SpawnBlood(org, 20);
						sprint(tempTraceEnt, #PRINT_HIGH, "you have been healed of your tranquilisation\n");

						// Give the medic a frag for doing it, only if it was caused by an enemy
						if (!Teammate(self.team_no,te.team_no))
						{
							self.real_frags = self.real_frags + 1;
							if (!(toggleflags & #TFLAG_TEAMFRAGS))
								self.frags = self.real_frags;
						}

						dremove(te);
					}
					else
					{
						RPrint("Warning: Error in Tranquilisation Timer logic.\n");
					}
				}
				
				#ifdef OLD_FLASH
				// check if the healed player is blinded
				if (tempTraceEnt.FlashTime > 0)
				{
					te = find(world, netname, "flashtimer");
					while ((te.owner != tempTraceEnt || te.classname != "timer") && (te != world))
						te = find(te, netname, "flashtimer");

					if (te != world)
					{
						tempTraceEnt.FlashTime = 0;
						SpawnBlood(org, 20);

						// Give the medic a frag for doing it, only if it was caused by an enemy
						stuffcmd(tempTraceEnt, "v_cshift 0\n"); //WK -- /CH te -> tempTraceEnt
						stuffcmd(tempTraceEnt, "r_norefresh 0;wait;echo;wait;echo;wait;echo;wait;echo\n"); //WK -- /CH te -> tempTraceEnt

						if (!Teammate(self.team_no,te.team_no))
						{
							self.real_frags = self.real_frags + 1;
							if (!(toggleflags & #TFLAG_TEAMFRAGS))
								self.frags = self.real_frags;
						}

						dremove(te);
					}
					else
					{
						RPrint("Warning: Error in Flash Timer logic.\n");
						tempTraceEnt.FlashTime = 0;
					}
				}

				#else // OLD_FLASH

				if (tempTraceEnt.tfstate & #TFSTATE_PSIONIZED && tempTraceEnt != world) // << FIX?
				{
					tempTraceEnt.tfstate = tempTraceEnt.tfstate - #TFSTATE_PSIONIZED;

					TeamFortress_SetSpeed(tempTraceEnt);

					te = find(world, netname, "psionictimer");
					while ((te.owner != tempTraceEnt || te.classname != "timer") && (te != world))
						te = find(te, netname, "psionictimer");

					if (te != world)
					{
						SpawnBlood(org, 20);

						sprint(tempTraceEnt, #PRINT_HIGH, self.netname, " restores your psionic problems!\n");
						sprint(self, #PRINT_HIGH, "You restore ", tempTraceEnt.netname, "'s psionic normality\n");
						
						// Give the medic a frag for doing it, only if it was caused by an enemy
						if (!Teammate(self.team_no,te.team_no))
						{
							self.real_frags = self.real_frags + 1;
							if (!(toggleflags & #TFLAG_TEAMFRAGS))
								self.frags = self.real_frags;
						}

						dremove(te);
					}
				}

				#endif // FLASH/PSIONIC

				// check if the healed player is infected
				if (tempTraceEnt.tfstate & #TFSTATE_INFECTED && tempTraceEnt != world) // << FIX?
				{
					healam = rint(tempTraceEnt.health / 2);

					// remove the infection
					tempTraceEnt.tfstate = tempTraceEnt.tfstate - (tempTraceEnt.tfstate & #TFSTATE_INFECTED);

					// some damage is caused (because of the use of leeches!)
					// remove half their remaining health
					deathmsg = #DMSG_MEDIKIT;
					T_Damage(tempTraceEnt, self, self, healam);

					SpawnBlood(org, 30);
					sprint(tempTraceEnt, #PRINT_HIGH,self.netname);
					sprint(tempTraceEnt, #PRINT_HIGH, " cures your infection!\n");

					if (self.classname == "player")
					{
						sprint(self, #PRINT_HIGH, "You have healed ");
						sprint(self, #PRINT_HIGH, tempTraceEnt.netname);
						sprint(self, #PRINT_HIGH, " of the infection.\n");

						teamprefixsprintbi(self.team_no,self,tempTraceEnt);
						teamsprintbi(self,tempTraceEnt,tempTraceEnt.netname," infection has been cured by ",self.netname,"\n","","");

						// Give the medic a frag for doing it, only if it was caused by an enemy
						if (!Teammate(tempTraceEnt.infection_team_no, self.team_no))
						{
							self.real_frags = self.real_frags + 1;
							if (!(toggleflags & #TFLAG_TEAMFRAGS))
								self.frags = self.real_frags;
						}
					}

					return;
				}

				// put out the fire if they are burning
				if (tempTraceEnt.numflames > 0)
				{
					sound(tempTraceEnt, #CHAN_WEAPON, "items/r_item1.wav", 1, #ATTN_NORM);

					tempTraceEnt.numflames = 0;

					sprint(tempTraceEnt, #PRINT_HIGH, "The flames have been doused!\n");

					if (self.classname == "player")
					{		
						sprint(self, #PRINT_MEDIUM, "You have put out ");
						sprint(self, #PRINT_MEDIUM, tempTraceEnt.netname);
						sprint(self, #PRINT_MEDIUM, "'s fire.\n");	
					}
					
					return;
				}

				if (healam > 0 && tempTraceEnt.health < tempTraceEnt.max_health)
				{
					sound(tempTraceEnt, #CHAN_WEAPON, "items/r_item1.wav", 1, #ATTN_NORM);
					tempTraceEnt.axhitme = 1;
					SpawnBlood (org, 20);

					T_Heal(tempTraceEnt, healam, 0);
				}
				else if (tempTraceEnt.health >= tempTraceEnt.max_health && tempTraceEnt.health < (tempTraceEnt.max_health + #WEAP_MEDIKIT_OVERHEAL))
				{
					healam = 10;
					if (healam > (self.ammo_medikit * 10))
						healam = (self.ammo_medikit * 10);
					if (healam > 0)
					{
						sound(tempTraceEnt, #CHAN_ITEM, "items/r_item2.wav", 1, #ATTN_NORM);
						T_Heal(tempTraceEnt, healam, 1);
						self.ammo_medikit = self.ammo_medikit - rint(healam / 10);
						if (!(tempTraceEnt.items & #IT_SUPERHEALTH))
						{
							tempTraceEnt.items = tempTraceEnt.items | #IT_SUPERHEALTH;
							newmis = spawn();
							newmis.classname = "medikit_rot";
							newmis.nextthink = time + 20;
							newmis.think = item_megahealth_rot;
							newmis.owner = tempTraceEnt;
						}
					}
				}
			}

#ifdef MEDIKIT_IS_BIOWEAPON
			//WK Don't infect if they're invincible or observing
			else if (!(tempTraceEnt.invincible_finished) && !(tempTraceEnt.playerclass == #PC_UNDEFINED))
			{
				if (inAuto)
					return;
				tempTraceEnt.axhitme = 1;
				SpawnBlood (org, 20);

				deathmsg = #DMSG_BIOWEAPON_ATT;
				if (!(self.cutf_items & #CUTF_CLOSECOMBAT))
					T_Damage (tempTraceEnt, self, self, 10);
				else
					T_Damage (tempTraceEnt, self, self, 20);
					
				if (tempTraceEnt.weapons_carried & #WEAP_MEDIKIT) //WK
					return;

				//Melee armor stops infection 75% of the time
				if (tempTraceEnt.tf_items & #NIT_GEL && random() < 0.75)
					return;

				if (tempTraceEnt.#runes & #RUNE_RESIS)
					return;

				if (tempTraceEnt.penance_time > time) // Don't let lame teamkillers get infected
					return;

				// Reports, only if first infection
				if (!(tempTraceEnt.tfstate & #TFSTATE_INFECTED))
				{
					sprint(tempTraceEnt,#PRINT_HIGH,"You have been infected!\n");

					// Report to infecter
					sprint(self,#PRINT_HIGH,"You infect ",tempTraceEnt.netname,"!\n");

					// Report to teammates of infected
					teamprefixsprint(tempTraceEnt.team_no,tempTraceEnt);
					teamsprint6(tempTraceEnt,tempTraceEnt.netname," has been infected!\n","","","","");

					// Update infection flag
					tempTraceEnt.tfstate = tempTraceEnt.tfstate | #TFSTATE_INFECTED;
				}

				BioInfection = spawn ();
				BioInfection.classname = "timer";
				BioInfection.netname = "biotimer";
				BioInfection.owner = tempTraceEnt;
				BioInfection.nextthink = time + 2;
				BioInfection.think = BioInfection_Decay;
				BioInfection.enemy = self;

				tempTraceEnt.infection_team_no = self.team_no;
			}
#endif

		}
		else if (IsMonster(tempTraceEnt))//- OfN - Monsters	// Gizmo - allow non demons and non army soldiers to be affected (coop monsters)
		{
			local string tmps;
			local float temp;

			temp = GetTeam( tempTraceEnt );
			if (Teammate(temp, self.team_no))
			{
				if (tempTraceEnt.health < tempTraceEnt.max_health)
				{
					local float healfactor;
					healfactor = 3;

					if (tempTraceEnt.classname == "monster_army")
						healfactor = 2;

					if (tempTraceEnt.max_health - tempTraceEnt.health < 50 * healfactor) // 50 for players
						healam = tempTraceEnt.max_health - tempTraceEnt.health;
					else
						healam = 50 * healfactor;
					if (healam > self.ammo_medikit * healfactor)
						healam = self.ammo_medikit * healfactor;
						
					if (healam == 0)
						return;

					sound(tempTraceEnt, #CHAN_WEAPON, "items/r_item1.wav", 1, #ATTN_NORM);
					tempTraceEnt.axhitme = 1;
					SpawnBlood (org, 20);

					T_Heal(tempTraceEnt, healam, 0);
					self.ammo_medikit = self.ammo_medikit - (healam/healfactor);

					self.ammo_medikit = rint(self.ammo_medikit);

					if (self.ammo_medikit < 0)
						self.ammo_medikit = 0;

					if (tempTraceEnt.health > tempTraceEnt.max_health)
						tempTraceEnt.health = tempTraceEnt.max_health;
				}

				if (tempTraceEnt.tfstate & #TFSTATE_INFECTED) // infected monsters
				{
					tempTraceEnt.tfstate = tempTraceEnt.tfstate - #TFSTATE_INFECTED;

					tmps = GetMonsterName(tempTraceEnt);
					
					// Inform the medic
					sprint(self,#PRINT_HIGH,"You have cured this ",tmps," from the infection\n");

					if ( IsOwnedMonster( tempTraceEnt ) ) {
						// Report to the owner of the monster
						sprint(tempTraceEnt.real_owner,#PRINT_HIGH,"Your ",tmps," has been cured by ",self.netname,"\n");
						
						// Report to teammates
						teamprefixsprintbi(tempTraceEnt.real_owner.team_no,tempTraceEnt.real_owner,self);
						teamsprintbi(tempTraceEnt.real_owner,self,self.netname, " cures the ",tmps," ",tempTraceEnt.netname,"\n");
					}

					// Give the medic a frag for doing it, only if it was caused by an enemy
					if (!Teammate(tempTraceEnt.infection_team_no, self.team_no))
					{
						self.real_frags = self.real_frags + 1;
						if (!(toggleflags & #TFLAG_TEAMFRAGS))
							self.frags = self.real_frags;
					}
				}
			}
			else // enemy monsters
			{
				// Gizmo - no more auto-infection of monsters
				if ( inAuto )
					return;

				tempTraceEnt.axhitme = 1;
				SpawnBlood(org, 20);
#ifdef COOP_MODE_ENHANCED
				deathmsg = #DMSG_BIOWEAPON_ATT;
#endif

				if (!(self.cutf_items & #CUTF_CLOSECOMBAT))
					T_Damage (tempTraceEnt, self, self, 10);
				else
					T_Damage (tempTraceEnt, self, self, 20);

				// Report to owner, only if first infection
#ifdef COOP_MODE_ENHANCED
				if (COOP_IsCoopMonster( tempTraceEnt ) && !(tempTraceEnt.tfstate & #TFSTATE_INFECTED)) {
					// report to infecter
					sprint (self, #PRINT_HIGH, "You infect ", tempTraceEnt.netname, "!\n");

					// update infection flag
					tempTraceEnt.tfstate = tempTraceEnt.tfstate | #TFSTATE_INFECTED;
				} else
#endif
				if (!(tempTraceEnt.tfstate & #TFSTATE_INFECTED))
				{
					tmps = GetMonsterName(tempTraceEnt);
					sprint(tempTraceEnt.real_owner,#PRINT_HIGH,"Your ",tmps," ",tempTraceEnt.netname," has been infected!\n");

					// Report to infecter
					sprint(self,#PRINT_HIGH,"You infect the ",tmps, " ", tempTraceEnt.netname,"!\n");

					// Report to teammates of owner
					teamprefixsprint(tempTraceEnt.real_owner.team_no,tempTraceEnt.real_owner);
					teamsprint6(tempTraceEnt.real_owner,"The ",tmps," ", tempTraceEnt.netname," has been infected!\n","");

					// Update infection flag
					tempTraceEnt.tfstate = tempTraceEnt.tfstate | #TFSTATE_INFECTED;
				}

				// Infect it!
				BioInfection = spawn ();
				BioInfection.classname = "timer";
				BioInfection.classname = "biotimer";
				BioInfection.nextthink = time + 2;
				BioInfection.think = BioInfection_MonsterDecay;
				BioInfection.owner = self;
				BioInfection.enemy = tempTraceEnt;

				tempTraceEnt.infection_team_no = self.team_no;
			}
		} 
		else // OfN - Buttons, Switches, doors
		{
			if (!inAuto)
			if (tempTraceEnt.classname == "func_button" || tempTraceEnt.classname == "door")
			{
				tempTraceEnt.axhitme = 1;
				SpawnBlood (org, 30);

				T_Damage(tempTraceEnt, self, self, 40);
			}
		}
	}
	else
	{	
		if (inAuto) return; //Don't click for automedic
		// hit wall
		sound (self, #CHAN_WEAPON, "player/axhit2.wav", 1, #ATTN_NORM);
		WriteByte (#MSG_BROADCAST, #SVC_TEMPENTITY);
		WriteByte (#MSG_BROADCAST, #TE_GUNSHOT);
	#ifdef QUAKE_WORLD
		WriteByte (#MSG_MULTICAST, 3);
	#endif
		WriteCoord (#MSG_BROADCAST, org_x);
		WriteCoord (#MSG_BROADCAST, org_y);
		WriteCoord (#MSG_BROADCAST, org_z);
	#ifdef QUAKE_WORLD
		multicast (org, #MULTICAST_PVS);
	#endif
	}
};

/*
================
W_FireBioweapon
================
*/

void() W_FireBioweapon =
{
	local	vector	source;
	local	vector	org;
	//local float healam;	

	local	entity BioInfection;

	source = self.origin + '0 0 16';
	traceline (source, source + v_forward*64, #TL_ANY_SOLID, self);
	if (trace_fraction == 1.0)
		return;
	
	org = trace_endpos - v_forward*4;

	if (trace_ent.takedamage)
	{
		if (trace_ent.classname == "player")
		{
			if ((!Teammate(trace_ent.team_no, self.team_no) && teamplay) || teamplay == 0)
			{
				trace_ent.axhitme = 1;
				SpawnBlood (org, 20);
		
				deathmsg = #DMSG_BIOWEAPON_ATT;
				if (!(self.cutf_items & #CUTF_CLOSECOMBAT))
					T_Damage (trace_ent, self, self, 10);
				else
					T_Damage (trace_ent, self, self, 20);

				if (trace_ent.weapons_carried & #WEAP_MEDIKIT) //WK
					return;

				trace_ent.tfstate = trace_ent.tfstate | #TFSTATE_INFECTED;

				BioInfection = spawn ();
				BioInfection.classname = "timer";
				BioInfection.netname = "biotimer";
				BioInfection.owner = trace_ent;
				BioInfection.nextthink = time + 2;
				BioInfection.think = BioInfection_Decay;
				BioInfection.enemy = self;

				trace_ent.infection_team_no = self.team_no;
			}
		}
		else if ( IsMonster( trace_ent ) )		// Gizmo - both coop monsters and summons
		{
			if (trace_ent.classname == "monster_zombie")
			{
				// zombie slayer!
				T_Damage (trace_ent, self, self, 200);
			}

			trace_ent.axhitme = 1;
			SpawnBlood(org, 20);
			if (!(self.cutf_items & #CUTF_CLOSECOMBAT))
				T_Damage (trace_ent, self, self, 10);
			else
				T_Damage (trace_ent, self, self, 20);

			BioInfection = spawn ();
			BioInfection.classname = "timer";
			BioInfection.classname = "biotimer";
			BioInfection.nextthink = time + 2;
			BioInfection.think = BioInfection_MonsterDecay;
			BioInfection.owner = self;
			BioInfection.enemy = trace_ent;
		}
		else // must be a switch
		{
			trace_ent.axhitme = 1;
			SpawnBlood (org, 30);

			T_Damage(trace_ent, self, self, 40);
		}
	}
	else
	{	// hit wall
		sound (self, #CHAN_WEAPON, "player/axhit2.wav", 1, #ATTN_NORM);
		WriteByte (#MSG_BROADCAST, #SVC_TEMPENTITY);
		WriteByte (#MSG_BROADCAST, #TE_GUNSHOT);
	#ifdef QUAKE_WORLD
		WriteByte (#MSG_MULTICAST, 3);
	#endif
		WriteCoord (#MSG_BROADCAST, org_x);
		WriteCoord (#MSG_BROADCAST, org_y);
		WriteCoord (#MSG_BROADCAST, org_z);
	#ifdef QUAKE_WORLD
		multicast (org, #MULTICAST_PVS);
	#endif
	}
};


//============================================================================


vector() wall_velocity =
{
	local vector	vel;
	
	vel = normalize (self.velocity);
	vel = normalize(vel + v_up*(random()- 0.5) + v_right*(random()- 0.5));
	vel = vel + 2*trace_plane_normal;
	vel = vel * 200;
	
	return vel;
};


/*
================
SpawnMeatSpray
================
*/
void(vector org, vector vel) SpawnMeatSpray =
{
	local	entity missile;

	missile = spawn ();
	missile.owner = self;
	missile.movetype = #MOVETYPE_BOUNCE;
	missile.solid = #SOLID_NOT;

	makevectors (self.angles);

	missile.velocity = vel;
	missile.velocity_z = missile.velocity_z + 250 + 50*random();

	missile.avelocity = '3000 1000 2000';
	
// set missile duration
	missile.nextthink = time + 1;
	missile.think = SUB_Remove;

	setmodel (missile, "progs/zom_gib.mdl");
	setsize (missile, '0 0 0', '0 0 0');		
	setorigin (missile, org);
};

/*
================
SpawnBlood
================
*/

void(vector org, float damage) SpawnBlood =
{
#ifndef QUAKE_WORLD
	particle (org, #VEC_ORIGIN, 73, damage*2);
#else
	WriteByte (#MSG_MULTICAST, #SVC_TEMPENTITY);
	WriteByte (#MSG_MULTICAST, #TE_BLOOD);
	WriteByte (#MSG_MULTICAST, 1);
	WriteCoord (#MSG_MULTICAST, org_x);
	WriteCoord (#MSG_MULTICAST, org_y);
	WriteCoord (#MSG_MULTICAST, org_z);
	multicast (org, #MULTICAST_PVS);
#endif
};



/*
================
spawn_touchblood
================
*/
void(float damage) spawn_touchblood =
{
	local vector	vel;

	vel = wall_velocity () * 0.2;
	SpawnBlood (self.origin + vel*0.01, damage);
};

/*
================
SpawnChunk
================
*/
void(vector org, vector vel) SpawnChunk =
{
	particle (org, vel*0.02, 0, 10);
};

/*
==============================================================================

MULTI-DAMAGE

Collects multiple small damages into a single damage

==============================================================================
*/

entity	multi_ent;
float	multi_damage;

#ifdef QUAKE_WORLD
vector	blood_org;
float	blood_count;

vector	puff_org;
float	puff_count;
#endif

void() ClearMultiDamage =
{
	multi_ent = world;
	multi_damage = 0;
#ifdef QUAKE_WORLD
	blood_count = 0;
	puff_count = 0;
#endif
};

void() ApplyMultiDamage =
{
	if (!multi_ent)
		return;
	// don't set deathmsg here, since it'll be set by the weapon that fired
	if (self.current_weapon & #WEAP_LIGHT_ASSAULT)
		TF_T_Damage (multi_ent, self, self, multi_damage, #TF_TD_NOTTEAM, #TF_TD_NAIL);
	else
		TF_T_Damage (multi_ent, self, self, multi_damage, #TF_TD_NOTTEAM, #TF_TD_SHOT);
};

void(entity hit, float damage) AddMultiDamage =
{
	if (!hit)
		return;
	
	if (hit != multi_ent)
	{
		ApplyMultiDamage ();
		multi_damage = damage;
		multi_ent = hit;
	}
	else
		multi_damage = multi_damage + damage;
};

#ifdef QUAKE_WORLD
void() Multi_Finish =
{
	/* WK Save spam SB ok, you save spam*/
	if (puff_count)
	{
		WriteByte (#MSG_MULTICAST, #SVC_TEMPENTITY);
		WriteByte (#MSG_MULTICAST, #TE_GUNSHOT);
		WriteByte (#MSG_MULTICAST, puff_count);
		WriteCoord (#MSG_MULTICAST, puff_org_x);
		WriteCoord (#MSG_MULTICAST, puff_org_y);
		WriteCoord (#MSG_MULTICAST, puff_org_z);
		multicast (puff_org, #MULTICAST_PVS);
	}
	

	if (blood_count)
	{
		WriteByte (#MSG_MULTICAST, #SVC_TEMPENTITY);
		WriteByte (#MSG_MULTICAST, #TE_BLOOD);
		WriteByte (#MSG_MULTICAST, blood_count);
		WriteCoord (#MSG_MULTICAST, blood_org_x);
		WriteCoord (#MSG_MULTICAST, blood_org_y);
		WriteCoord (#MSG_MULTICAST, blood_org_z);
		multicast (puff_org, #MULTICAST_PVS);
	}
};
#endif

/*
==============================================================================

BULLETS

==============================================================================
*/

#ifdef COOL_GIBS
#ifdef COOL_GIBS_TRACE
void(vector org, vector dir,float intensity,float radius) CoolPush =
{
	// Go away if its disabled..
	if (!cool_gibs)
		return;

	local entity head;
	head = findradius(org, radius); 

	while (head)
	{
		if (head.#coolflag == #STRFLAG_COOL) 
		{
			// Wheeeeeeeeee
			head.velocity = head.velocity + (dir * intensity * 16);
			
			// Are we onground? is so put us up
			if (head.flags & #FL_ONGROUND)
			{
				head.flags = head.flags - #FL_ONGROUND;
				head.velocity_z = head.velocity_z + (135 + intensity*2 +random()*120);
			}				
			
			// Do an appropiate spin movement if we arent spinning currently and sometimes even if we are
			if (head.avelocity == '0 0 0' || random() < 0.2)
			{
				// is this a head?
				if (head.classname != "gib")
					head.avelocity = crandom() * '0 600 0';
				else // should be a gib then
				{
					head.avelocity_x = crandom()*600;
					head.avelocity_y = crandom()*600;
					head.avelocity_z = crandom()*600;
				}
			}
		}

		head = head.chain;
	}
};
#endif
#endif

/*
================
TraceAttack
================
*/
void(float damage, vector dir) TraceAttack =
{
	local	vector	vel, org;
	
	vel = normalize(dir + v_up*crandom() + v_right*crandom());
	vel = vel + 2*trace_plane_normal;
	vel = vel * 200;

	org = trace_endpos - dir*4;

	//WK Sweep mines at the end of the attack
	GuerillaMineSweep(trace_endpos);

	#ifdef COOL_GIBS
	#ifdef COOL_GIBS_TRACE
	CoolPush(trace_endpos,dir,damage,30);
	#endif
	#endif

	if (trace_ent.takedamage)
	{
		#ifndef QUAKE_WORLD
			SpawnBlood (org, damage);
		#else
			blood_count = blood_count + 1;
			blood_org = org;
		#endif

		AddMultiDamage (trace_ent, damage);
	}
	else
	{
		if (trace_ent.classname == "force_field") //- OfN - Makes field explosion b4 removing it
			FieldEvent(trace_ent,trace_endpos,trace_ent);
		else
		{
		#ifndef QUAKE_WORLD
			WriteByte (#MSG_BROADCAST, #SVC_TEMPENTITY);
			WriteByte (#MSG_BROADCAST, #TE_GUNSHOT);
			WriteCoord (#MSG_BROADCAST, org_x);
			WriteCoord (#MSG_BROADCAST, org_y);
			WriteCoord (#MSG_BROADCAST, org_z);
		#else
			//multicast (trace_endpos, #MULTICAST_PVS);
			#ifndef REALISTIC_SHOTGUN_PARTS 
			puff_count = puff_count + 1;
			#endif
		#endif
		}
	}
	
};

//======================================================================
// Used for bullets, does a traceline with TL_EVERYTHING, and if an
// inapropiate entity is hit, it drops down to a standard traceline.
// This function should skip any wrong entity, and allows corpses to
// be damaged by trace attacks.

void(vector src, vector endpos) BulletTraceline =
{
	#ifdef USE_CORPSE_CODE	  
	traceline(src, endpos, #TL_EVERYTHING,self);
	
		#ifdef IDABLE_TFITEMS
	if (trace_ent.classname == "item_tfgoal")
	{
		traceline(src, endpos, #TL_ANY_SOLID,self); 	 
		return;
	}
		#endif

		#ifdef IDABLE_RUNES
	if (trace_ent.classname == "rune")
	{
		traceline(src, endpos, #TL_ANY_SOLID,self); 	 
		return;
	}
		#endif

	#else // USE_CORPSE_CODE disabled..
	
		traceline(src, endpos, #TL_ANY_SOLID,self);
	#endif
};

/*
================
FireBullets

Used by shotgun, super shotgun, assault cannon, and enemy soldier firing
Go to the trouble of combining multiple pellets into a single damage call.
================
*/
void(float shotcount, vector dir, vector spread, float dist) FireBullets =
{
	local	vector direction;
	local	vector	src;
	
	makevectors(self.v_angle);

	src = self.origin + v_forward*10;
	src_z = self.absmin_z + self.size_z * 0.7;

	ClearMultiDamage ();

#ifdef QUAKE_WORLD
	if (self.current_weapon & #WEAP_ASSAULT_CANNON)
	{
		direction = dir + crandom()*0.2*v_right + crandom()*0.1*v_up;
		//traceline (src, src + direction*2048, #TL_ANY_SOLID, self); //WK 2048
		//traceline (src, src + direction*dist, #TL_ANY_SOLID, self); //WK 2048
		BulletTraceline(src, src + direction*dist);
	}
	else
		//traceline (src, src + dir*1024, #TL_ANY_SOLID, self); //WK 2048
		//traceline (src, src + dir*dist, #TL_ANY_SOLID, self); //WK 2048
		BulletTraceline(src, src + dir*dist);
	
	#ifdef REALISTIC_SHOTGUN_PARTS 
	// OfN - Don't make particles if it doesnt hit anything!
	if (trace_fraction != 1.0)
	{
	#endif
	puff_org = trace_endpos - dir*4;
	puff_count = shotcount;
	#ifdef REALISTIC_SHOTGUN_PARTS 
	}
	#endif
#endif

	while (shotcount > 0)
	{
		direction = dir + crandom()*spread_x*v_right + crandom()*spread_y*v_up;
		if (self.current_weapon & #WEAP_ASSAULT_CANNON)
			//traceline (src, src + direction*2048, #TL_ANY_SOLID, self); //WK 2048
			BulletTraceline(src, src + direction*dist);
		else
			//traceline (src, src + direction*1024, #TL_ANY_SOLID, self); //WK 2048
			BulletTraceline(src, src + direction*dist);

		if (trace_fraction != 1.0)
		{
			if (self.current_weapon & #WEAP_ASSAULT_CANNON) //WK Sinth's bugfix
				TraceAttack (5, direction); //WK(12) (6) Reversed from 2.5
			else if (self.current_weapon & #WEAP_LIGHT_ASSAULT)
			{
				TraceAttack (4, direction);
			}
			else 
				TraceAttack (6, direction); //WK 4
		}

		shotcount = shotcount - 1;
	}
	ApplyMultiDamage ();
#ifdef QUAKE_WORLD
	Multi_Finish ();
#endif
};

/*
================
W_FireShotgun
================
*/
void() W_FireShotgun =
{
	local vector dir;

	sound (self, #CHAN_WEAPON, "weapons/guncock.wav", 1, #ATTN_NORM);	

	if (self.classname == "player")
		KickPlayer(-2, self);
				 
	self.currentammo = self.ammo_shells = self.ammo_shells - 1;
	if (self.classname == "player")
		dir = aim (self, 100000);
	else
	{
		dir = self.enemy.origin - self.enemy.velocity * (0.08 / self.has_sensor);
		dir = normalize (dir - self.origin);
	}

	deathmsg = #DMSG_SHOTGUN;
	FireBullets (6, dir, '0.04 0.04 0',1536);
};


/*
================
W_FireSuperShotgun
================
*/
void() W_FireSuperShotgun =
{
	local vector dir;

	if (self.currentammo == 1)
	{
		W_FireShotgun ();
		return;
	}
		
	sound (self ,#CHAN_WEAPON, "weapons/shotgn2.wav", 1, #ATTN_NORM);	

	if (self.classname == "player")
		KickPlayer(-4, self);

	self.currentammo = self.ammo_shells = self.ammo_shells - 2;
	if (self.classname == "player")
		dir = aim (self, 100000);
	else
	{
		dir = self.enemy.origin - self.enemy.velocity * (0.08 / self.has_sensor);
		dir = normalize (dir - self.origin);
	}
	deathmsg = #DMSG_SSHOTGUN;
	FireBullets (12, dir, '0.19 0.10 0',1024); //WK 14, 0.14, 0.08
};


/*
================
FireSniperBullet
Used by sniper rifle firing (W_FireSniperRifle)
================
*/
void(vector direction, float damage) FireSniperBullet =
{
	local	vector	src;

	makevectors(self.v_angle);

	src = self.origin + v_forward*10;
	src_z = self.absmin_z + self.size_z * 0.7;

	ClearMultiDamage ();

	  traceline (src, src + direction*4096, #TL_ANY_SOLID, self);

	if (trace_fraction != 1.0)
		TraceAttack (damage, direction);

	ApplyMultiDamage ();

	// OfN
	if (trace_fraction != 1.0)
		SpawnDmgFX(trace_ent,trace_endpos, 0.25,1,1);
};


/*
=================================
TeamFortress : W_FireSniperRifle
=================================
*/
void() W_FireSniperRifle =
{
	local vector dir, src;
	local float dam_mult, zdif, use_this, damg;

	sound (self ,#CHAN_WEAPON, "weapons/sniper.wav", 1, #ATTN_NORM);
	KickPlayer(-2, self);
	//self.currentammo = self.ammo_shells = self.ammo_shells - 1; // ofn moved!

	makevectors(self.v_angle);
	src = self.origin + v_forward * 10;
	src_z = self.absmin_z + self.size_z * 0.7;

	use_this = #FALSE;
	dir = v_forward;
	traceline (src, src + dir*8192, #TL_ANY_SOLID, self);
	if (trace_fraction != 1.0)
	{
		if (trace_ent != world)
		{
			if (trace_ent.classname == "player")
			{
				use_this = #TRUE;
			}
		}
	}

	KickPlayer(-4, self);

	if (!use_this)
	{
		// aim, 'cause no entity in sights
		dir = aim (self, 10000);	// this corrects the aiming slightly, for bad players
		traceline (src, src + dir*3072, #TL_ANY_SOLID, self);
	}

	local float OTR;
	OTR = 1; // 1 = No OTR

	if (self.cutf_items & #CUTF_OTR)
		if (self.ammo_shells >= #OTR_AMMO_COST)
		OTR = #OTR_DMG_FACTOR;

	deathmsg = #DMSG_SNIPERRIFLE;
	dam_mult = 1;

	// PZ - code added for randomer's charge-up fix
	damg = (time - self.heat) / #WEAP_SNIPER_RIFLE_MAX_TIME;
	if (damg < 0)
		damg = 0;
	if (damg > 1)
		damg = 1;
	damg = damg * (#WEAP_SNIPER_RIFLE_MAX_DAMG - #WEAP_SNIPER_RIFLE_MIN_DAMG) + #WEAP_SNIPER_RIFLE_MIN_DAMG; // Powerup * damage range + minimum damage.

/*
	// TODO: Gizmo: Print how much damage was dealt?
	// TEST
	bprint (#PRINT_HIGH, ftos(damg));
	bprint (#PRINT_HIGH, "\n");
*/

	if (OTR > 1)
		self.currentammo = self.ammo_shells = self.ammo_shells - #OTR_AMMO_COST;
	else
		self.currentammo = self.ammo_shells = self.ammo_shells - 1;

	if (trace_ent)
	{
		local vector f, g, h;
		local float x;
		local float legdmgdone;

		if (trace_ent.classname == "player")
		{
			f = trace_endpos - src;

			g_x = trace_endpos_x;
			g_y = trace_endpos_y;
			g_z = 0;

			h_x = trace_ent.origin_x;
			h_y = trace_ent.origin_y;
			h_z = 0;

			x = vlen(g - h);

			f = (normalize(f) * x) + trace_endpos;

			zdif = f_z - trace_ent.origin_z;
			deathmsg = #DMSG_SNIPERRIFLE;

			trace_ent.head_shot_vector = '0 0 0';
			if (zdif < 0)
			{
				// leg shot
				dam_mult = 0.75;

				if (OTR > 1)
					legdmgdone = HurtLegs(trace_ent,2);
				else
					legdmgdone = HurtLegs(trace_ent,1);

				//TeamFortress_SetSpeed(trace_ent); 
				deathmsg = #DMSG_SNIPERLEGSHOT;
				//WK Kevlar ignored for snipers again.
				TF_T_Damage (trace_ent, self, self, damg * dam_mult * OTR, 0, 0);


				if (trace_ent.health > 0 && legdmgdone)
				{
					if (OTR > 1)
					{
						sprint(trace_ent, #PRINT_MEDIUM, "Leg injury! That was OTR stuff!\n");
						sprint(self, #PRINT_MEDIUM, "Leg shot - that really will slow him down!\n");
					}
					else
					{
						sprint(trace_ent, #PRINT_MEDIUM, "Leg injury!\n");
						sprint(self, #PRINT_MEDIUM, "Leg shot - that'll slow him down!\n");
					}
				}

				return;
			}
			else if (zdif > 20)
			{
				// head shot
				dam_mult = 2;

				if (OTR > 1)
					stuffcmd(trace_ent, "bf;bf\n");
				else
					stuffcmd(trace_ent, "bf\n");

				trace_ent.head_shot_vector = trace_ent.origin - self.origin;
				deathmsg = #DMSG_SNIPERHEADSHOT;
				TF_T_Damage (trace_ent, self, self, damg * dam_mult * OTR, 0, #TF_TD_SHOT);

				if (trace_ent.health > 0)
				{
					if (OTR > 1)
					{
						sprint(trace_ent, #PRINT_MEDIUM, "Head injury! That was OTR stuff!\n");
						sprint(self, #PRINT_MEDIUM, "Head shot - that's really gotta hurt!\n");
					}
					else
					{
						sprint(trace_ent, #PRINT_MEDIUM, "Head injury!\n");
						sprint(self, #PRINT_MEDIUM, "Head shot - that's gotta hurt!\n");
					}
				}

				return;
			}
			else
				deathmsg = #DMSG_SNIPERRIFLE;

		}
#ifdef COOP_MODE_ENHANCED
		else if ( COOP_IsCoopMonster( trace_ent ) ) {
			f = trace_endpos - src;

			g_x = trace_endpos_x;
			g_y = trace_endpos_y;
			g_z = 0;

			h_x = trace_ent.origin_x;
			h_y = trace_ent.origin_y;
			h_z = 0;

			x = vlen(g - h);

			f = (normalize(f) * x) + trace_endpos;

			zdif = f_z - trace_ent.origin_z;

//			trace_ent.head_shot_vector = '0 0 0';
			// Gizmo - monsters need special checking since they have multiple different sizes
			if ( zdif < trace_ent.mins_z * 0.5 ) {
				// leg shot
				dam_mult = 0.75;

				if (OTR > 1)
					legdmgdone = HurtLegs(trace_ent,2);
				else
					legdmgdone = HurtLegs(trace_ent,1);

				//TeamFortress_SetSpeed(trace_ent); 
				deathmsg = #DMSG_SNIPERLEGSHOT;
				//WK Kevlar ignored for snipers again.
				TF_T_Damage (trace_ent, self, self, damg * dam_mult * OTR, 0, 0);


				if (trace_ent.health > 0 && legdmgdone)
				{
					if (OTR > 1)
						sprint(self, #PRINT_MEDIUM, "Leg shot - that really will slow him down!\n");
					else
						sprint(self, #PRINT_MEDIUM, "Leg shot - that'll slow him down!\n");
				}

				return;
			}
			if ( zdif > trace_ent.maxs_z * 0.75 ) {
				// head shot
				dam_mult = 2;

				deathmsg = #DMSG_SNIPERHEADSHOT;
				TF_T_Damage( trace_ent, self, self, damg * dam_mult * OTR, 0, #TF_TD_SHOT );

				if ( trace_ent.health > 0 ) {
					if ( OTR > 1 )
						sprint( self, #PRINT_MEDIUM, "Head shot - that's really gotta hurt!\n" );
					else
						sprint( self, #PRINT_MEDIUM, "Head shot - that's gotta hurt!\n" );
				}

				return;
			}
		}
#endif
	}

	ClearMultiDamage ();

	if (trace_fraction != 1.0)	// if it hit something
		TraceAttack (damg * dam_mult * OTR * sniper_factor, dir);

	// OfN - Particle/sound stuff and dot removal
	local entity sight;

	sight = find(world,netname,"sniperdot");

	while (sight)
	{
		if (sight.classname == "timer")
		if (sight.owner == self)
		{				
			// Remove sight dot always
			dremove(sight);
			//return; // and stop rearching for dot
		}

		sight = find(sight,netname,"sniperdot");
	}

	// Do particle and sound if it hits anything
	if (trace_fraction != 1.0) // Did it hit something? 		   
		SpawnDmgFX(trace_ent,trace_endpos,0.5,1,1);

	ApplyMultiDamage ();
};

/*
===================================
TeamFortress : W_FireAutoRifle
===================================
*/
void() W_FireAutoRifle =
{
	local vector dir;

	sound (self ,#CHAN_WEAPON, "weapons/sniper.wav", 1, #ATTN_NORM);

	KickPlayer(-1, self);

	self.currentammo = self.ammo_shells = self.ammo_shells - 1;
	makevectors(self.v_angle);
	dir = v_forward;
	deathmsg = #DMSG_AUTORIFLE;
	//WK 1/7/7 Added OTR autorifle shots. They don't consume more bullets, unlike normal OTR shots.
	if (self.cutf_items & #CUTF_OTR)
		FireSniperBullet (dir, 10); //WK 1/7/7 OTR autoshots deal 10 damage instead of 8.
	else 
		FireSniperBullet (dir, 8);
};

/*
================
TeamFortress : W_FireAssaultCannon
================
*/
void() W_FireAssaultCannon =
{
	local vector dir;

	KickPlayer(-4, self);

	//WK Judoka's usually don't have enough ammo to shoot this thing...
	if (!(self.job & #JOB_JUDOKA && self.job & #JOB_ACTIVE))
		self.currentammo = self.ammo_shells = self.ammo_shells - 1;
	dir = aim (self, 100000);
	deathmsg = #DMSG_ASSAULTCANNON;
	//WK FireBullets (5, dir, '0.1 0.1 0');
	//We want more of a cone of fire...
//	FireBullets (5, dir, '0.2 0.1 0');
//	FireBullets (5, dir, '0.4 0.1 0');
	FireBullets (7, dir, '0.15 0.1 0',2048);
	FireBullets (3, dir, '0.3 0.1 0',2048);
};

/*
=========================================
Custom TeamFortress : W_FireLightAssault
=========================================
*/
void() W_FireLightAssault =
{
	local vector dir;

	if (self.ammo_nails < 1)
	{
		self.current_weapon = W_BestWeapon ();
		W_SetCurrentAmmo ();
		W_PrintWeaponMessage();
		return;
	}

	sound (self, #CHAN_WEAPON, "weapons/guncock.wav", 0.6, #ATTN_NORM); 

	KickPlayer(-4, self);

	makevectors(self.v_angle);

	dir = v_forward;
	deathmsg = #DMSG_LIGHT_ASSAULT;
	self.currentammo = self.ammo_nails = self.ammo_nails - 1;
	self.reload_light_assault = self.reload_light_assault + 1;

	if (CheckForReload() == #TRUE) return;
	FireBullets (5, dir, '0.2 0.1 0',1024);
	Attack_Finished(0.2);
};

/*
==============================================================================

ROCKETS

==============================================================================
*/

void()	s_explode1	=	[0, 	s_explode2] {};
void()	s_explode2	=	[1, 	s_explode3] {};
void()	s_explode3	=	[2, 	s_explode4] {};
void()	s_explode4	=	[3, 	s_explode5] {};
void()	s_explode5	=	[4, 	s_explode6] {};
void()	s_explode6	=	[5, 	SUB_Remove] {};

void() BecomeExplosion =
{
#ifndef QUAKE_WORLD
	self.movetype = #MOVETYPE_NONE;
	self.velocity = '0 0 0';
	self.touch = SUB_Null;
	setmodel (self, "progs/s_explod.spr");
	self.solid = #SOLID_NOT;
	s_explode1 ();
#else
	dremove(self);
#endif
};

void() T_MissileTouch =
{
	local float damg;
	local float bonus;

	if (pointcontents(self.origin) == #CONTENT_SKY)
	{
		dremove(self);
		return;
	}

	// Lowered from 120
	damg = 92;
	
	if (self.owner.classname == "trap_shooter" || self.owner.classname == "trap_spikeshooter" || self.owner.classname == "trap_tf_spikeshooter" || self.owner.classname == "trap_tf_shooter")
		if (self.owner.dmg != 0)
			damg = self.owner.dmg;

	/*
	if (self.owner)
		if (self.owner.tf_items & #NIT_RL_LASER_SIGHT) {
			//RPrint("Laser rocket hit!\n");
			damg = damg - 10;
		}
	*/
	if (self.has_tesla) //Cluster rockets do less
		damg = damg - 20; //WK 2/26/7 Lowered from -15 //WK 1/7/7 -25, they need to do a little more

	deathmsg = self.weapon;
	if (other.health)
	{
		bonus = 10 + random()*20;
		if (self.has_tesla)
			bonus = 10; //WK 0, have direct cluster hits mean a little something, since they're hard as hell to steer.
		TF_T_Damage (other, self, self.owner, damg+bonus, 0, #TF_TD_EXPLOSION);
	}

	// don't do radius damage to the other, because all the damage
	// was done in the impact
	// Lowered from 120
	// WK 1/7/7 Note: Cluster Rockets no longer cause knockation
	T_RadiusDamage (self, self.owner, damg, other);

	self.origin = self.origin - 8*normalize(self.velocity);

#ifdef DEMO_STUFF
	// Remove any camera's locks on this missile
	if (self.enemy)
		CamProjectileLockOff();
#endif

	WriteByte (#MSG_BROADCAST, #SVC_TEMPENTITY);
	WriteByte (#MSG_BROADCAST, #TE_EXPLOSION);
	WriteCoord (#MSG_BROADCAST, self.origin_x);
	WriteCoord (#MSG_BROADCAST, self.origin_y);
	WriteCoord (#MSG_BROADCAST, self.origin_z);
#ifdef QUAKE_WORLD
	multicast (self.origin, #MULTICAST_PHS);

	if (other.classname == "force_field") //- OfN - Makes field explosion b4 removing it
		FieldEvent(other,self.origin,self);//FieldExplosion(other,self.origin,self);

	dremove(self);
#else
	BecomeExplosion ();
#endif
};

//CH rocket tracker (taken from shalrath.qc)
void() Rocket_Track_Dot =
{
	//local vector olorigin;
	local float dist;

	if (time > self.has_sentry) {
		self.think = SUB_Remove;
	}
	else
	{
		local vector	dir, vtemp;
		local entity tg, sight;

		sight = world;
		tg = find (world, classname, "timer");
		while (tg)
		{
			if (tg.owner == self.owner && tg.think == SniperSight_Update2)
				sight = tg;
			tg = find(tg, classname, "timer");
		}
		if (sight != world) //Found a sight
		{
			vtemp = sight.origin;
			dir = normalize(vtemp - self.origin);
			//if (self.owner.cluster_mode && !(self.has_tesla)) //Slow down main rocket
			//	self.velocity = dir * 500;
			//else
			if (self.owner.cluster_mode)
				self.velocity = dir * 700; //WK 1/7/7 600 -- sped up clusters a bit.
			else
				self.velocity = dir * 900;
			self.angles = vectoangles(self.velocity);
			self.think = Rocket_Track_Dot;
			//WK Add in cluster munitions support
			if (self.has_tesla) { //We're a cluster, so act crazy	
				makevectors(self.angles);
				self.v_angle = sight.origin; //Save last direction for losing sight
				//WK 1/7/7 Increased think rate means swarming amplitude has to be increased (from 300)
				self.velocity = self.velocity + 450 * v_right * (random() - 0.5);
				self.velocity = self.velocity + 450 * v_up * (random() - 0.5);
			}
		}
		else { //Lost sight of sight
			if (self.has_tesla && self.v_angle != '0 0 0') {
				vtemp = self.v_angle; //Last point we saw the sight at
				dir = normalize(vtemp - self.origin);
				//WK 1/7/7 Note that this next line is impossible to reach...
				if (self.owner.cluster_mode && !(self.has_tesla)) //Slow down main rocket
					self.velocity = dir * 900;
				else
					self.velocity = dir * 1000;
				self.angles = vectoangles(self.velocity);
				self.think = Rocket_Track_Dot;
				makevectors(self.angles);
				//WK 1/7/7 Increased think rate means swarming amplitude has to be increased (from 300)
				//WK 1/7/7 Stop bug where rockets can swarm around a point in space and never hit -- when within 100 fly straight
				dist = vlen(self.v_angle - self.origin);
				if (dist > 300) { //We can swarm as long as we're more than 300 from last seen target
					self.velocity = self.velocity + 450 * v_right * (random() - 0.5);
					self.velocity = self.velocity + 450 * v_up * (random() - 0.5);
				} else { //Stop swarming around an empty point in space
					if (self.has_sentry > time + 1) 
						self.has_sentry = time + 0.5; //Remove within a half second of reaching point.
				}
			}
			//	self.velocity = 1000 * normalize(self.v_angle);
		}
	}

/* WK 1/7/7 Was every 0.1 seconds before, now wastes bandwidth to give a much smoother rocket path. It looks nicer, and the prevailence of broadband means that people can handle this now. More importantly, the gameplay control of steering rockets is a lot more manageable now. Note: We randomly think every 0.01 to 0.03 seconds on each rocket, to break up network load with cluster rox. */
	self.nextthink = time + 0.01*floor(1+3*random());
};


/*
================
W_FireRocket
================
*/

// Gizmo - modified version of avirox's rocket speed; look for 'RocketSpeedMult()' to see what's changed
float() RocketSpeedMult =
{
	if (self.cutf_moreitems & #CUTF_MI_FASTERROCKETS)
		return 1.444444;
	else
		return 1;
};

void() W_FireRocket =
{
	local float loops;
	local vector olorigin, dir;

	loops = 0;
	if (self.tf_items & #NIT_CLUSTER_ROCKETS && self.cluster_mode == #TRUE)
		loops = 5;
	while (loops >= 0) {
	self.currentammo = self.ammo_rockets = self.ammo_rockets - 1;
	if (self.ammo_rockets < 0) {
		self.currentammo = self.ammo_rockets = 0;
		return;
	}
	if (loops == 0)
	{
		sound (self, #CHAN_WEAPON, "weapons/sgun1.wav", 1, #ATTN_NORM);
		if (self.classname == "player")
			KickPlayer(-2, self);
	}
	newmis = spawn ();
	newmis.owner = self;
	newmis.movetype = #MOVETYPE_FLYMISSILE;
	newmis.solid = #SOLID_BBOX;
	
	newmis.classname = "rocket"; //- OfN - Checked on airfist

	// set newmis speed 
	if (self.classname == "player")
	{
		makevectors (self.v_angle);
		dir = v_forward;
	}
	else if (self.classname == "monster_army")
		dir = Grunty_LeadShot();
	else {
		makevectors (self.angles);
		dir = v_forward;
	}
			
	newmis.velocity = dir;	
	if (!loops)
	{ //WK Not a cluster Rocket
		if (self.tf_items & #NIT_CLUSTER_ROCKETS && self.cluster_mode == #TRUE)
		{ //Make lead rocket start slower too
			if (self.tf_items & #NIT_RL_LASER_SIGHT) //Cluster and sight to start
				newmis.velocity = (newmis.velocity * 400) * RocketSpeedMult();
			else
				newmis.velocity = (newmis.velocity * 600) * RocketSpeedMult(); //Cluster and no sight
		}
		else 
			newmis.velocity = (newmis.velocity * 900) * RocketSpeedMult();
	}
	else if (self.tf_items & #NIT_RL_LASER_SIGHT) //Cluster and sight to start
		newmis.velocity = (newmis.velocity * 400) * RocketSpeedMult();
	else
		newmis.velocity = (newmis.velocity * 600) * RocketSpeedMult(); //Cluster and no sight
	newmis.angles = vectoangles(newmis.velocity);

	newmis.touch = T_MissileTouch;

	// set newmis duration
	if (self.tf_items & #NIT_RL_LASER_SIGHT) {
		newmis.nextthink = time + 0.1; //Because tracks a sight
		if (loops)
			//newmis.nextthink = time + 0.2; // Delay one second to spread out
			newmis.nextthink = time + 0.1*floor(1+3*random()); //WK 1/7/7 To reduce corridor issues, clusters come alive earlier (0.5)
		newmis.think = Rocket_Track_Dot;
		newmis.has_sentry = time + 20; //WK 1/7/7 Was 6 -- Greatly increased in order to allow more tricks with laser guided rockets
	} else {
		newmis.nextthink = time + 4;
		newmis.think = SUB_Remove;
	}

	newmis.weapon = #DMSG_ROCKETL;
	if (!loops)
		setmodel (newmis, "progs/missile.mdl");
	else
		setmodel (newmis, "progs/minimis.mdl"); //Diff model for swarm rockets
	setsize (newmis, '0 0 0', '0 0 0'); 	
	setorigin (newmis, self.origin + dir*8 + '0 0 16');
	if (loops) { //WK Vary the starting point of the cluster
		traceline (self.origin, self.origin + v_forward*9192, #TL_ANY_SOLID, self); //Make this TRUE
		newmis.v_angle = trace_endpos;
		newmis.has_tesla = loops; //Tell the rocket it is a cluster
		newmis.weapon = #DMSG_CLUSTER_ROCKET;
		olorigin = newmis.origin;
		newmis.origin = newmis.origin + v_right * (random() * 80 - 40); //WK 1/7/7 Pulled in from 120-60 to make corridors better
		newmis.origin = newmis.origin + v_forward * (random() * 40);
		newmis.origin = newmis.origin + v_up * (random() * 50 - 20);
		olorigin = olorigin - newmis.origin; //Get vector to new point
		olorigin = 200 * normalize(olorigin);
		if (self.tf_items & #NIT_RL_LASER_SIGHT) //Dont spread without sight
			newmis.velocity = newmis.velocity + olorigin;			
	}
	loops = loops - 1;
	} //End while loops
#ifdef DEMO_STUFF
	// Have we got a live camera in projectile mode?
	if (live_camera)
		CamProjectileLockOn();
#endif
};

/*
===============================================================================

LIGHTNING

===============================================================================
*/

#ifdef QUAKE_WORLD
void(entity from, float damage) LightningHit =
{
	WriteByte (#MSG_MULTICAST, #SVC_TEMPENTITY);
	WriteByte (#MSG_MULTICAST, #TE_LIGHTNINGBLOOD);
	WriteCoord (#MSG_MULTICAST, trace_endpos_x);
	WriteCoord (#MSG_MULTICAST, trace_endpos_y);
	WriteCoord (#MSG_MULTICAST, trace_endpos_z);
	multicast (trace_endpos, #MULTICAST_PVS);

	TF_T_Damage (trace_ent, from, from, damage, #TF_TD_NOTTEAM, #TF_TD_ELECTRICITY);
};
#endif

/*
=================
LightningDamage
=================
*/
void(vector p1, vector p2, entity from, float damage) LightningDamage =
{
	local entity		e1, e2;
	local vector		f;
	
	f = p2 - p1;
	normalize (f);
	f_x = 0 - f_y;
	f_y = f_x;
	f_z = 0;
	f = f*16;

	e1 = e2 = world;

	traceline (p1, p2, #TL_ANY_SOLID, self);

	//WK Sweep mines at point of impact
	GuerillaMineSweep(trace_endpos);

	deathmsg = #DMSG_LIGHTNING;
	if (trace_ent.takedamage)
	{
		#ifdef QUAKE_WORLD
			LightningHit (from, damage);
		#else
			particle (trace_endpos, '0 0 100', 225, damage*4);
			TF_T_Damage (trace_ent, from, from, damage, #TF_TD_NOTTEAM, #TF_TD_ELECTRICITY);
		#endif

		#ifdef LIGHTNING_PUSHES
		if (self.classname == "player")
		{
			if (trace_ent.classname == "player")//if (other.classname == "player") // <-- OfN fixed Ancient bug
				trace_ent.velocity_z = trace_ent.velocity_z + 400;
		}
		#endif
	}
	e1 = trace_ent;

	traceline (p1 + f, p2 + f, #TL_ANY_SOLID, self);
	if (trace_ent != e1 && trace_ent.takedamage)
	{
	#ifdef QUAKE_WORLD
		LightningHit (from, damage);
	#else
		particle (trace_endpos, '0 0 100', 225, damage*4);
		TF_T_Damage (trace_ent, from, from, damage, #TF_TD_NOTTEAM, #TF_TD_ELECTRICITY);
	#endif
	}
	e2 = trace_ent;

	traceline (p1 - f, p2 - f, #TL_ANY_SOLID, self);
	if (trace_ent != e1 && trace_ent != e2 && trace_ent.takedamage)
	{
	#ifdef QUAKE_WORLD
		LightningHit (from, damage);
	#else
		particle (trace_endpos, '0 0 100', 225, damage*4);
		TF_T_Damage (trace_ent, from, from, damage, #TF_TD_NOTTEAM, #TF_TD_ELECTRICITY);
	#endif
	}
};


void() W_FireLightning =
{
	local	vector	org;
	local float 	cells;

	if (self.ammo_cells < 1)
	{
		self.current_weapon = W_BestWeapon ();
		W_SetCurrentAmmo ();
		W_PrintWeaponMessage();
		return;
	}

// explode if under water
	if (self.waterlevel > 1)
	{
		cells = self.ammo_cells;
		if (cells > 10) cells = 10; //WK Don't allow detpacks on the fly!
		self.ammo_cells = self.ammo_cells - cells;
		W_SetCurrentAmmo ();
		deathmsg = #DMSG_LIGHTNING;
		//WK T_RadiusDamage (self, self, 35*cells, world);
		T_RadiusDamage (self, self, 20*cells, world);
		Attack_Finished(5);
		return;
	}

	if (self.t_width < time)
	{
		sound (self, #CHAN_WEAPON, "weapons/lhit.wav", 1, #ATTN_NORM);
		self.t_width = time + 0.6;
	}

	KickPlayer(-2, self);

#ifdef CLASSIC_LIGHTNING_GUN
	local float excess;

	#define BIGLIGHT
	#ifdef BIGLIGHT
		if (self.ammo_cells > 100) {
			excess = (self.ammo_cells - 100) * 2 / 3;
			if (excess < 50) excess = 50;
			self.ammo_cells = 100;
		} else {
			excess = 0;
			self.ammo_cells = self.ammo_cells - 0.75;
		}
	#else
		//Or this method, which consumes cells at a rate to ensure we run out
		//In a few seconds, no matter what. But resupplying is a bitch.
		excess = 0;
		self.ammo_cells = self.ammo_cells - ceil(self.maxammo_cells / 30);
		if (self.ammo_cells < 0) self.ammo_cells = 0;
	#endif
#else
	#define BIGLIGHT
	#ifdef BIGLIGHT
		// Gizmo - no more discharging all your cells
		self.ammo_cells = self.ammo_cells - 0.75;
	#else
		//Or this method, which consumes cells at a rate to ensure we run out
		//In a few seconds, no matter what. But resupplying is a bitch.
		excess = 0;
		self.ammo_cells = self.ammo_cells - ceil(self.maxammo_cells / 30);
		if (self.ammo_cells < 0) self.ammo_cells = 0;
	#endif
#endif
	self.currentammo = self.ammo_cells;
	

	org = self.origin + '0 0 16';
	
	// OfN - Check for force field
	traceline (org, org + v_forward*600, #TL_ANY_SOLID, self);

	if (trace_ent.classname == "force_field")
	{
		FieldEvent(trace_ent,trace_endpos,trace_ent);

		//FieldExplosion(trace_ent,trace_endpos,trace_ent);
		//PutFieldWork(trace_ent);

		WriteByte (#MSG_BROADCAST, #SVC_TEMPENTITY);
		WriteByte (#MSG_BROADCAST, #TE_LIGHTNING2);
		WriteEntity (#MSG_BROADCAST, self);
		WriteCoord (#MSG_BROADCAST, org_x);
		WriteCoord (#MSG_BROADCAST, org_y);
		WriteCoord (#MSG_BROADCAST, org_z);
		WriteCoord (#MSG_BROADCAST, trace_endpos_x);
		WriteCoord (#MSG_BROADCAST, trace_endpos_y);
		WriteCoord (#MSG_BROADCAST, trace_endpos_z);
	#ifdef QUAKE_WORLD
		multicast (org, #MULTICAST_PHS);
	#endif

		return;
	}
	//_------------------------------------_//

	traceline (org, org + v_forward*600, #TL_BSP_ONLY, self);

	WriteByte (#MSG_BROADCAST, #SVC_TEMPENTITY);
	WriteByte (#MSG_BROADCAST, #TE_LIGHTNING2);
	WriteEntity (#MSG_BROADCAST, self);
	WriteCoord (#MSG_BROADCAST, org_x);
	WriteCoord (#MSG_BROADCAST, org_y);
	WriteCoord (#MSG_BROADCAST, org_z);
	WriteCoord (#MSG_BROADCAST, trace_endpos_x);
	WriteCoord (#MSG_BROADCAST, trace_endpos_y);
	WriteCoord (#MSG_BROADCAST, trace_endpos_z);
#ifdef QUAKE_WORLD
	multicast (org, #MULTICAST_PHS);
#endif

#ifdef CLASSIC_LIGHTNING_GUN
	if (excess) {
		sprint(self,#PRINT_HIGH,"You discharge your excess cells\n");
		LightningDamage (self.origin, trace_endpos + v_forward*4, self, excess);
	} else
		//WK 30. Lowered damage to make it a $2200 weapon
		LightningDamage (self.origin, trace_endpos + v_forward*4, self, 12);
#else
	// Gizmo - increased damage to 18
	LightningDamage (self.origin, trace_endpos + v_forward*4, self, 18);
#endif
};

//=============================================================================

float (float tno) num_team_pipebombs =
{
	if (tno == 1)
		return num_team_pipebombs_1;
	else if (tno == 2)
		return num_team_pipebombs_2;
	else if (tno == 3)
		return num_team_pipebombs_3;
	else if (tno == 4)
		return num_team_pipebombs_4;

	return 0;
};

void(float tno) ExplodeOldPipebomb =
{
	local entity old;
	local float index;

	if (!agr) // PZ: only remove the oldest in AGR
	{
		if (tno != 0)
		{
			index = num_team_pipebombs(tno);
			index = index - (#MAX_WORLD_PIPEBOMBS / number_of_teams);
		}
		else
			index = num_world_pipebombs - #MAX_WORLD_PIPEBOMBS;
	}
	else
		index = 1;

	old = find(world, classname, "pipebomb");
	while (index > 0)
	{
		if (old == world)
		{
			RPrint("*** ERROR: ExplodeOldPipebomb. ***\n");
			RPrint("*** Please report this.        ***\n");
			num_world_pipebombs = 0;
			num_team_pipebombs_1 = 0;
			num_team_pipebombs_2 = 0;
			num_team_pipebombs_3 = 0;
			num_team_pipebombs_4 = 0;
			return;
		}

		if (old.owner.team_no == tno || tno == 0)
		{
			old.nextthink = time + 0.5;
			index = index - 1;
		}

		old = find(old, classname, "pipebomb");
	}
};

void(float tno) increment_team_pipebombs =
{
	if (tno == 1)
		num_team_pipebombs_1 = num_team_pipebombs_1 + 1;
	else if (tno == 2)
		num_team_pipebombs_2 = num_team_pipebombs_2 + 1;
	else if (tno == 3)
		num_team_pipebombs_3 = num_team_pipebombs_3 + 1;
	else if (tno == 4)
		num_team_pipebombs_4 = num_team_pipebombs_4 + 1;
};

void(float tno) decrement_team_pipebombs =
{
	if (tno == 1)
		num_team_pipebombs_1 = num_team_pipebombs_1 - 1;
	else if (tno == 2)
		num_team_pipebombs_2 = num_team_pipebombs_2 - 1;
	else if (tno == 3)
		num_team_pipebombs_3 = num_team_pipebombs_3 - 1;
	else if (tno == 4)
		num_team_pipebombs_4 = num_team_pipebombs_4 - 1;
};

//=============================================================================


void() GrenadeExplode =
{
	if (self.classname == "pipebomb")
	{
		num_world_pipebombs = num_world_pipebombs - 1;
		decrement_team_pipebombs(self.owner.team_no);
	}

	deathmsg = self.weapon;
	T_RadiusDamage (self, self.owner, 120, world);

#ifdef DEMO_STUFF
	// Remove any camera's locks on this missile
	if (self.enemy)
		CamProjectileLockOff();
#endif

	WriteByte (#MSG_BROADCAST, #SVC_TEMPENTITY);
	WriteByte (#MSG_BROADCAST, #TE_EXPLOSION);
	WriteCoord (#MSG_BROADCAST, self.origin_x);
	WriteCoord (#MSG_BROADCAST, self.origin_y);
	WriteCoord (#MSG_BROADCAST, self.origin_z);
#ifdef QUAKE_WORLD
	multicast (self.origin, #MULTICAST_PHS);
	dremove(self);
#else
	BecomeExplosion ();
#endif
};

void() GrenadeTouch =
{
	if (other == self.owner)
		return; 	// don't explode on owner
	if (other.takedamage == #DAMAGE_AIM)
	{
		GrenadeExplode();
		return;
	}
	sound (self, #CHAN_WEAPON, "weapons/bounce.wav", 1, #ATTN_NORM);	// bounce sound
	if (self.velocity == '0 0 0')
		self.avelocity = '0 0 0';
};

/*
================
W_FireGrenade
================
*/
void() W_FireGrenade =
{
	self.currentammo = self.ammo_rockets = self.ammo_rockets - 1;
	sound (self, #CHAN_WEAPON, "weapons/grenade.wav", 1, #ATTN_NORM);
	KickPlayer(-2, self);
	newmis = spawn ();
	newmis.owner = self;
	newmis.movetype = #MOVETYPE_BOUNCE;
	newmis.solid = #SOLID_BBOX;

	// Set grenade type based on firing mode
	if (self.weaponmode == #GL_NORMAL)
	{
		newmis.weapon = #DMSG_GRENADEL;
		newmis.classname = "grenade";
		newmis.skin = 1;
		newmis.touch = GrenadeTouch;
		newmis.nextthink = time + 2.5;
	}
	else // if (self.weaponmode == #GL_PIPEBOMB)
	{
		if (self.team_no != 0)
		{
			increment_team_pipebombs(self.team_no);
			if (agr) // PZ: give blue more pipes in AGR (less pipes for red)
			{
				if (self.team_no == 1)
					if (num_team_pipebombs(self.team_no) > (#MAX_WORLD_PIPEBOMBS / number_of_teams + 5))
						ExplodeOldPipebomb(self.team_no);
				if (self.team_no == 2)
					if (num_team_pipebombs(self.team_no) > (#MAX_WORLD_PIPEBOMBS / number_of_teams - 5))
						ExplodeOldPipebomb(self.team_no);
			}
			else if (num_team_pipebombs(self.team_no) > (#MAX_WORLD_PIPEBOMBS / number_of_teams))
				ExplodeOldPipebomb(self.team_no);
		}
		else 
		{
			num_world_pipebombs = num_world_pipebombs + 1;
			if (num_world_pipebombs > #MAX_WORLD_PIPEBOMBS)
				ExplodeOldPipebomb(0);
		}

		newmis.classname = "pipebomb";
		newmis.skin = 2;
		newmis.touch = PipebombTouch;
		newmis.nextthink = time + 120;		// Remove pipebombs older than 2 minutes
		newmis.weapon = #DMSG_GREN_PIPE;
	}
		
	// set newmis speed 
	makevectors (self.v_angle);
	if (self.v_angle_x)
		newmis.velocity = v_forward*600 + v_up * 200 + crandom()*v_right*10 + crandom()*v_up*10;
	else
	{
		newmis.velocity = aim(self, 10000);
		newmis.velocity = newmis.velocity * 600;
		newmis.velocity_z = 200;
	}
	newmis.avelocity = '300 300 300';
	newmis.angles = vectoangles(newmis.velocity);

	newmis.think = GrenadeExplode;
	setmodel (newmis, "progs/grenade2.mdl");
	setsize (newmis, '0 0 0', '0 0 0'); 	
	setorigin (newmis, self.origin);

#ifdef DEMO_STUFF
	// Have we got a live camera in projectile mode?
	if (live_camera)
		CamProjectileLockOn();
#endif
};

//=============================================================================

void() spike_touch;


/*
===============
launch_spike

Used for both the player and the ogre
===============
*/
void(vector org, vector dir) launch_spike =
{
	newmis = spawn ();
	newmis.owner = self;
	newmis.movetype = #MOVETYPE_FLYMISSILE;
	newmis.solid = #SOLID_BBOX;

	newmis.angles = vectoangles(dir);

	newmis.touch = spike_touch;
	newmis.weapon = #DMSG_NAILGUN;
	newmis.classname = "spike";
	newmis.think = SUB_Remove;
	newmis.nextthink = time + 6;
	setmodel (newmis, "progs/spike.mdl");
	setsize (newmis, #VEC_ORIGIN, #VEC_ORIGIN); 	
	setorigin (newmis, org);

	newmis.velocity = dir * 2000; // WK was 1000

#ifdef DEMO_STUFF
	// Have we got a live camera in projectile mode?
	if (live_camera)
		CamProjectileLockOn();
#endif
};

// OfN - For nail grens, invisible direct impact nail (no entity)
void(vector org, vector dir) launch_directspike =
{		
	local entity oldowner;
	oldowner = self.owner;
	self.owner = self;

	traceline(org, org + (dir * 4096),#TL_ANY_SOLID,self);
	
	self.owner = oldowner;

	if (pointcontents(trace_endpos) == #CONTENT_SKY)
		return;
	
	//WK Sweep mines at point of impact
	GuerillaMineSweep(trace_endpos);

	// hit something that bleeds
	if (trace_ent.takedamage)
	{
		SpawnBlood (trace_endpos, 9);
		deathmsg = #DMSG_GREN_NAIL;

		TF_T_Damage (trace_ent, self, self.owner, #NAILGREN_DMG, #TF_TD_NOTTEAM | #TF_TD_DONTGIB, #TF_TD_NAIL); 	   
	}
	else
	{		 
		if (trace_fraction != 1.0)
		{
			if (trace_ent.classname == "force_field") // Makes field explosion 
				FieldEvent(trace_ent,trace_endpos,self);
			else
			{
				WriteByte (#MSG_BROADCAST, #SVC_TEMPENTITY);
				WriteByte (#MSG_BROADCAST, #TE_SPIKE);
				WriteCoord (#MSG_BROADCAST, trace_endpos_x);
				WriteCoord (#MSG_BROADCAST, trace_endpos_y);
				WriteCoord (#MSG_BROADCAST, trace_endpos_z);
			#ifdef QUAKE_WORLD
				multicast (trace_endpos, #MULTICAST_PHS);
			#endif
			}
		}
	}
};

void() superspike_touch =
{
	local float ndmg;

	if (other == self.owner)
		return;

	if (other.solid == #SOLID_TRIGGER)
		return; // trigger field, do nothing

	if (pointcontents(self.origin) == #CONTENT_SKY)
	{
		dremove(self);
		return;
	}
	
// hit something that bleeds
	if (other.takedamage)
	{
		spawn_touchblood (18);
		deathmsg = self.weapon;

/*
#ifdef QUAKE_WORLD
		// In QW, nail grens only launch 1 nail, and it does more damage.
		if (deathmsg == #DMSG_GREN_NAIL)
			ndmg = 40;
		else
#endif
*/

		ndmg = 13;

		if (self.owner.classname == "grenade")
			TF_T_Damage (other, self, self.owner.owner, ndmg, #TF_TD_NOTTEAM, #TF_TD_NAIL);
		else
			TF_T_Damage (other, self, self.owner, ndmg, #TF_TD_NOTTEAM, #TF_TD_NAIL);
	}
	else
	{
		if (other.classname == "force_field") //- OfN - Makes field explosion b4 removing it
		   FieldEvent(other,self.origin,self);//FieldExplosion(other,self.origin,self);
		else
		{
			WriteByte (#MSG_BROADCAST, #SVC_TEMPENTITY);
			WriteByte (#MSG_BROADCAST, #TE_SUPERSPIKE);
			WriteCoord (#MSG_BROADCAST, self.origin_x);
			WriteCoord (#MSG_BROADCAST, self.origin_y);
			WriteCoord (#MSG_BROADCAST, self.origin_z);
		#ifdef QUAKE_WORLD
			multicast (self.origin, #MULTICAST_PHS);
		#endif						
		}
	}

	dremove(self);
};


void() W_FireSuperSpikes =
{
	local vector	dir;
	//local entity	old;
	
	sound (self, #CHAN_WEAPON, "weapons/spike2.wav", 1, #ATTN_NORM);
	Attack_Finished(0.2);
	self.currentammo = self.ammo_nails = self.ammo_nails - 2;
	dir = aim (self, 1000);
	launch_spike (self.origin + '0 0 16', dir);
	newmis.touch = superspike_touch;
	newmis.weapon = #DMSG_SNG;
	setmodel (newmis, "progs/s_spike.mdl");
	setsize (newmis, #VEC_ORIGIN, #VEC_ORIGIN); 	

	KickPlayer(-2, self);
};

void(float ox) W_FireSpikes =
{
	if (self.ammo_nails >= 2 && self.current_weapon == #WEAP_SNG)
	{
		W_FireSuperSpikes ();
		return;
	}
	
	local vector	dir;
	//local entity	old;
	
	if (self.classname == "player")
		makevectors (self.v_angle);
	else
		makevectors (self.angles);
	
	if (self.ammo_nails < 1)
		if (self.classname == "player")
		{
			self.current_weapon = W_BestWeapon ();
			W_SetCurrentAmmo ();
			W_PrintWeaponMessage();
			return;
		}

	sound (self, #CHAN_WEAPON, "weapons/rocket1i.wav", 1, #ATTN_NORM);
	Attack_Finished(0.2);
	self.currentammo = self.ammo_nails = self.ammo_nails - 1;
	if (self.classname == "player")
	{
		dir = aim (self, 1000);
		launch_spike (self.origin + '0 0 16' + v_right*ox, dir);
		KickPlayer(-2, self);
	}
	else if (self.classname == "monster_army") //- OfN -
	{
		dir = Grunty_LeadShot();
		grunty_spike(self.origin + '0 0 16' + v_right*ox, dir);
	}		
};



//.float hit_z;
void() spike_touch =
{
	if (other.solid == #SOLID_TRIGGER)
		return; // trigger field, do nothing

	if (pointcontents(self.origin) == #CONTENT_SKY)
	{
		dremove(self);
		return;
	}
	
	//WK Sweep mines at point of impact
	GuerillaMineSweep(self.origin);

	// hit something that bleeds
	if (other.takedamage)
	{
		spawn_touchblood (9);
		deathmsg = self.weapon;

		//- OfN - Wizard projectiles do SCRAG_DMG damage
		if (self.classname == "wizspike")
		{
		   local float wizdmg;
		   wizdmg = #SCRAG_DMG;
	
		   if (other.classname == "player")
		   {
			  if (other.cutf_items & #CUTF_DEMONLORE) // if we have demon lore, it does less damage to us
				 wizdmg = wizdmg * 0.8;
		   }

		   TF_T_Damage (other, self, self.owner, wizdmg, #TF_TD_NOTTEAM | #TF_TD_DONTGIB, 0);
		   sound (self, #CHAN_MISC, "effects/crunch.wav", 0.4, #ATTN_NORM); // any better sound?
		} // - OfN -
		else 
		if (self.owner.classname == "grenade")
			TF_T_Damage (other, self, self.owner.owner, #NAILGREN_DMG, #TF_TD_NOTTEAM, #TF_TD_NAIL);
		else 
			TF_T_Damage (other, self, self.owner, 12, #TF_TD_NOTTEAM, #TF_TD_NAIL);
	}
	else
	{
		if (other.classname == "force_field") //- OfN - Makes field explosion b4 removing it
		   FieldEvent(other,self.origin,self);//FieldExplosion(other,self.origin,self);
		else
		{
			WriteByte (#MSG_BROADCAST, #SVC_TEMPENTITY);
			if (self.classname == "wizspike")
				WriteByte (#MSG_BROADCAST, #TE_WIZSPIKE);
			else if (self.classname == "knightspike")
				WriteByte (#MSG_BROADCAST, #TE_KNIGHTSPIKE);
			else
				WriteByte (#MSG_BROADCAST, #TE_SPIKE);
			WriteCoord (#MSG_BROADCAST, self.origin_x);
			WriteCoord (#MSG_BROADCAST, self.origin_y);
			WriteCoord (#MSG_BROADCAST, self.origin_z);
		#ifdef QUAKE_WORLD
			multicast (self.origin, #MULTICAST_PHS);
		#endif
		}
	}

#ifdef DEMO_STUFF
	// Remove any camera's locks on this missile
	if (self.enemy)
		CamProjectileLockOff();
#endif

	dremove(self);
};

/*
===============================================================================

PLAYER WEAPON USE

===============================================================================
*/

void() W_SetCurrentAmmo =
{

	//local string st;

	if (self.health <= 0 || self.current_weapon == 0)
		return; 	// get out of any weapon firing states

	// Gizmo - ensure the assault cannon never gets messed up
	if ( self.current_weapon != #WEAP_ASSAULT_CANNON )
		player_run();

	self.items = self.items - ( self.items & (#IT_SHELLS | #IT_NAILS | #IT_ROCKETS | #IT_CELLS) );
	self.weapon = 0;

	//WK Set armor here... update armor picture
	self.items = self.items - (self.items & (#IT_ARMOR1 | #IT_ARMOR2 | #IT_ARMOR3));	
	if (self.armortype >= 0.8)
		self.items = self.items | #IT_ARMOR3;
	else if (self.armortype >= 0.6)
		self.items = self.items | #IT_ARMOR2;
	else if (self.armortype >= 0.3)
		self.items = self.items | #IT_ARMOR1;

	//WK Show nothing for custom playerclass while building
	if (self.playerclass == #PC_CUSTOM && (self.done_custom & #CUSTOM_BUILDING)) //We are building a class
	{
		self.currentammo = 0;
		self.weaponmodel = "";
		return;
	}
	if (self.current_weapon == #WEAP_AXE)
	{
		self.currentammo = 0;

		if (self.cutf_items & #CUTF_KNIFE) //WK
		{
			if (self.job & #JOB_BLOODY_KNIFE)
				self.weaponmode = 1;
			else
				self.weaponmode = 0; //CH maybe fix bug that knife is bloody when not?
			if (self.weaponmode == 0)
				self.weaponmodel = "progs/v_knife.mdl"; //Nonbloody
			else
				self.weaponmodel = "progs/v_knife2.mdl"; //Bloody
		}
		else
			self.weaponmodel = "progs/v_axe.mdl";

		self.weaponframe = 0;
	}
	else if (self.current_weapon == #WEAP_HOOK)
	{
		self.currentammo = 0;
		self.weaponmodel = "progs/v_grap.mdl";
		self.weaponframe = 0;
	}
	else if (self.current_weapon == #WEAP_SPANNER)
	{
		self.currentammo = self.ammo_cells;
		self.weaponmodel = "progs/v_span.mdl";
		self.weaponframe = 0;
	}
	else if (self.current_weapon == #WEAP_SHOTGUN)
	{
		self.currentammo = self.ammo_shells;
		self.items = self.items | #IT_SHELLS; //WK 1/7/7 Was "Cells" o_O?
		if (!(self.tfstate & #TFSTATE_RELOADING))
		{
			self.weaponmodel = "progs/v_shot.mdl";
			self.weaponframe = 0;
		}
		self.items = self.items | #IT_SHELLS;
		self.weapon = #IT_SHOTGUN;
	}
	else if (self.current_weapon == #WEAP_SUPER_SHOTGUN)
	{
		self.currentammo = self.ammo_shells;
		if (!(self.tfstate & #TFSTATE_RELOADING))
		{
			self.weaponmodel = "progs/v_shot2.mdl";
			self.weaponframe = 0;
		}
		self.items = self.items | #IT_SHELLS;
		self.weapon = #IT_SUPER_SHOTGUN;
	}
	else if (self.current_weapon == #WEAP_NAILGUN)
	{
		self.currentammo = self.ammo_nails;
		if (!(self.tfstate & #TFSTATE_RELOADING))
		{
			self.weaponmodel = "progs/v_nail.mdl";
			self.weaponframe = 0;
		}

		self.items = self.items | #IT_NAILS;
		self.weapon = #IT_NAILGUN;
	}
	else if (self.current_weapon == #WEAP_LIGHT_ASSAULT)
	{
		self.currentammo = self.ammo_nails;
		if (!(self.tfstate & #TFSTATE_RELOADING))
		{
			self.weaponmodel = "progs/v_nail2.mdl";
			//self.weaponmodel = "progs/v_chain.mdl";
			
			self.weaponframe = 0;
		}
		self.items = self.items | #IT_NAILS;
		self.weapon = #IT_LIGHT_ASSAULT;
	}
	else if (self.current_weapon == #WEAP_GRENADE_LAUNCHER)
	{
		self.currentammo = self.ammo_rockets;
		if (!(self.tfstate & #TFSTATE_RELOADING))
		{
			self.weaponmodel = "progs/v_rock.mdl";
			self.weaponframe = 0;
		}

		self.weapon = #IT_GRENADE_LAUNCHER;
		self.items = self.items | #IT_ROCKETS;
	}
	else if (self.current_weapon == #WEAP_ROCKET_LAUNCHER)
	{
		self.currentammo = self.ammo_rockets;
		if (!(self.tfstate & #TFSTATE_RELOADING))
		{
			self.weaponmodel = "progs/v_rock2.mdl";
			self.weaponframe = 0;
		}
		self.items = self.items | #IT_ROCKETS;
		self.weapon = #IT_ROCKET_LAUNCHER;
	}
	else if (self.current_weapon == #WEAP_LIGHTNING)
	{
		self.currentammo = self.ammo_cells;
		if (!(self.tfstate & #TFSTATE_RELOADING))
		{
			self.weaponmodel = "progs/v_light.mdl";
			self.weaponframe = 0;
		}
		self.items = self.items | #IT_CELLS;
		self.weapon = #IT_LIGHTNING;
	}
	else if (self.current_weapon == #WEAP_SNIPER_RIFLE)
	{
			self.currentammo = self.ammo_shells;
		if (!(self.tfstate & #TFSTATE_RELOADING))
		{
			self.weaponmodel = "progs/v_srifle.mdl";
			self.weaponframe = 0;
		}
		self.items = self.items | #IT_SHELLS;
		self.weapon = #IT_SHOTGUN;
	}
	else if (self.current_weapon == #WEAP_AUTO_RIFLE)
	{
		self.currentammo = self.ammo_shells;
		if (!(self.tfstate & #TFSTATE_RELOADING))
		{
				self.weaponmodel = "progs/v_srifle.mdl";
				self.weaponframe = 0;
		}
		self.items = self.items | #IT_SHELLS;
		self.weapon = #IT_SUPER_SHOTGUN;
	}
	else if (self.current_weapon == #WEAP_ASSAULT_CANNON)
	{
		self.currentammo = self.ammo_shells;
		if (!(self.tfstate & #TFSTATE_RELOADING))
		{
			self.weaponmodel = "progs/v_asscan.mdl";
				self.weaponframe = 0;
		}
		self.items = self.items | #IT_SHELLS;
		self.weapon = #IT_ROCKET_LAUNCHER;
	}
	else if (self.current_weapon == #WEAP_FLAMETHROWER)
	{
		self.currentammo = self.ammo_cells;
		if (!(self.tfstate & #TFSTATE_RELOADING))
		{
			self.weaponmodel = "progs/v_rock.mdl";
			self.weaponframe = 0;
		}
		self.items = self.items | #IT_CELLS;
		self.weapon = #IT_GRENADE_LAUNCHER;
	}
	else if (self.current_weapon == #WEAP_INCENDIARY)
	{
		self.currentammo = self.ammo_rockets;
		if (!(self.tfstate & #TFSTATE_RELOADING))
		{
			self.weaponmodel = "progs/v_rock2.mdl";
			self.weaponframe = 0;
		}
		self.items = self.items | #IT_ROCKETS;
		self.weapon = #IT_ROCKET_LAUNCHER;
	}
	else if (self.current_weapon == #WEAP_MEDIKIT)
	{
		self.currentammo = 0;
		self.weaponmodel = "progs/v_medi.mdl";
		self.weaponframe = 0;
	}
	else if (self.current_weapon == #WEAP_TRANQ)
	{
		self.currentammo = self.ammo_nails;
		if (!(self.tfstate & #TFSTATE_RELOADING))
		{
			self.weaponmodel = "progs/v_shot.mdl";
			self.weaponframe = 0;
		}
		self.items = self.items | #IT_NAILS;
		self.weapon = #IT_SHOTGUN;
	}
	else if (self.current_weapon == #WEAP_RAILGUN)
	{
		self.currentammo = self.ammo_nails;

		if (!(self.tfstate & #TFSTATE_RELOADING))
		{
			self.weaponmodel = "progs/v_rail.mdl";
			self.weaponframe = 0;
		}

		self.items = self.items | #IT_NAILS;
		self.weapon = #IT_SHOTGUN;
	}
	else if (self.current_weapon == #WEAP_DAEDALUS)
	{
		self.currentammo = self.ammo_cells;

		if (!(self.tfstate & #TFSTATE_RELOADING))
		{
			self.weaponmodel = "progs/v_rock.mdl";
			self.weaponframe = 0;
		}

		self.items = self.items | #IT_CELLS;
		self.weapon = #IT_LIGHTNING;
	}
	else if (self.current_weapon == #WEAP_MAUSER)
	{
		self.currentammo = self.ammo_nails;

		if (!(self.tfstate & #TFSTATE_RELOADING))
		{
			self.weaponmodel = "progs/v_rail.mdl";
			self.weaponframe = 0;
		}

		self.items = self.items | #IT_NAILS;
		self.weapon = #IT_LIGHT_ASSAULT;
	}
	else if (self.current_weapon == #WEAP_AIRF)
	{
		self.currentammo = self.ammo_cells;

		if (!(self.tfstate & #TFSTATE_RELOADING))
		{
			self.weaponmodel = "progs/v_airgun.mdl";
			self.weaponframe = 0;
		}

		self.items = self.items | #IT_CELLS;
	}
	else if (self.current_weapon == #WEAP_SNG)
	{
		self.currentammo = self.ammo_nails;
		if (!(self.tfstate & #TFSTATE_RELOADING))
		{
			self.weaponmodel = "progs/v_nail2.mdl";
			self.weaponframe = 0;
		}
		self.items = self.items | #IT_NAILS;
		self.weapon = #IT_LIGHT_ASSAULT;//IT_SUPER_NAILGUN;
	}
	else if (self.current_weapon == #WEAP_LASERCANNON)
	{
		self.currentammo = self.ammo_cells;
		if (!(self.tfstate & #TFSTATE_RELOADING))
		{
			self.weaponmodel = "progs/v_laserg.mdl";
				self.weaponframe = 0;
		}

		self.items = self.items | #IT_CELLS;
		self.weapon = #WEAP_LASERCANNON;
	} else if (self.current_weapon == #WEAP_ZEROGRAVITY) {
		self.currentammo = 0;
		self.weaponmodel = "progs/v_light.mdl";
		self.weaponframe = 0;
	}
	else
	{
		self.currentammo = 0;
		self.weaponmodel = "";
		self.weaponframe = 0;
	}
};

float() W_BestWeapon =
{
	local	float	it;
	
	it = self.weapons_carried;

	if (self.ammo_cells >= 1 && (it & #WEAP_LIGHTNING) && self.waterlevel <= 1)
		return #WEAP_LIGHTNING;
	else if(self.ammo_shells >= 1 && (it & #WEAP_SNIPER_RIFLE) )
		return #WEAP_SNIPER_RIFLE;
	else if(self.ammo_rockets >= 1 && (it & #WEAP_ROCKET_LAUNCHER) )
		return #WEAP_ROCKET_LAUNCHER;
	else if (self.ammo_cells >= 5 && (it & #WEAP_DAEDALUS) )
		return #WEAP_DAEDALUS;
	else if (self.ammo_cells >= 6 && (self.ammo_shells >= 1) && (it  & #WEAP_ASSAULT_CANNON))
		return #WEAP_ASSAULT_CANNON;
	else if(self.ammo_nails >= 10 && (it & #WEAP_LIGHT_ASSAULT) )
		return #WEAP_LIGHT_ASSAULT;
	else if(self.ammo_rockets >= 3 && (it & #WEAP_INCENDIARY) )
		return #WEAP_INCENDIARY;
	else if(self.ammo_rockets >= 1 && (it & #WEAP_GRENADE_LAUNCHER) )
		return #WEAP_GRENADE_LAUNCHER;
	else if (self.ammo_cells >= 1 && (it & #WEAP_LASERCANNON))
		return #WEAP_LASERCANNON;
	else if(self.ammo_nails >= 2 && (it & #WEAP_SNG))
		return #WEAP_SNG;
	else if (self.ammo_cells >= 1 && (it & #WEAP_FLAMETHROWER))
		return #WEAP_FLAMETHROWER;
	else if(self.ammo_shells >= 2 && (it & #WEAP_SUPER_SHOTGUN) )
		return #WEAP_SUPER_SHOTGUN;
	else if (self.ammo_nails >= 1 && (it & #WEAP_RAILGUN) )
		return #WEAP_RAILGUN;
	else if(self.ammo_nails >= 1 && (it & #WEAP_NAILGUN) )
		return #WEAP_NAILGUN;
	else if(self.ammo_shells >= 1 && (it & #WEAP_SHOTGUN) )
		return #WEAP_SHOTGUN;
	else if (self.ammo_nails >= 1 && (it & #WEAP_MAUSER) )
		return #WEAP_MAUSER;
	else if (self.ammo_cells >= #AIRFIST_CELLS_COST && (it & #WEAP_AIRF))
		return #WEAP_AIRF;	  
	else if (self.ammo_nails >= 1 && (it & #WEAP_TRANQ) )
		return #WEAP_TRANQ;
	else if (it & #WEAP_MEDIKIT)
		return #WEAP_MEDIKIT;	 
	else if (it & #WEAP_SPANNER)
		return #WEAP_SPANNER;
	else if (it & #WEAP_AXE)
		return #WEAP_AXE;

	return 0;
};

float() W_CheckNoAmmo =
{
	if (self.current_weapon == #WEAP_ZEROGRAVITY)
		return #TRUE;
	if (self.current_weapon == #WEAP_MEDIKIT)
		return #TRUE;
	if (self.current_weapon == #WEAP_AIRF)
	{
		if (self.currentammo >= #AIRFIST_CELLS_COST)
			return #TRUE;
	}
	else if (self.current_weapon == #WEAP_AXE || self.current_weapon == #WEAP_HOOK || self.current_weapon == #WEAP_SPANNER)
		return #TRUE;
	else if (self.current_weapon == #WEAP_INCENDIARY)
	{
		if (self.currentammo >= 3)
			return #TRUE;
	}
	else if (self.current_weapon == #WEAP_DAEDALUS)
	{
		if (self.currentammo >= 5)
			return #TRUE;
	}
	else if (self.currentammo > 0)
		return #TRUE;

	self.current_weapon = W_BestWeapon ();
	W_SetCurrentAmmo ();
	W_PrintWeaponMessage();
	
// drop the weapon down
	return #FALSE;
};

/*====================
W_Reload
Is called when weapon has finished reloading
====================*/
void() W_Reload_shotgun =
{
	self.owner.tfstate = self.owner.tfstate - (self.owner.tfstate & #TFSTATE_RELOADING);
	self.owner.weaponmodel = "progs/v_shot.mdl";
	sprint(self.owner, #PRINT_LOW, "finished reloading\n");

	dremove(self);

	self.owner.StatusRefreshTime = time + 0.1;
};

void() W_Reload_light_assault =
{
	self.owner.tfstate = self.owner.tfstate - (self.owner.tfstate & #TFSTATE_RELOADING);
	self.owner.weaponmodel = "progs/v_nail2.mdl";
	//self.owner.weaponmodel = "progs/v_chain.mdl";
	
	sprint(self.owner, #PRINT_LOW, "finished reloading\n");
	self.owner.StatusRefreshTime = time + 0.1;

	dremove(self);
};

void() W_Reload_super_shotgun =
{
	self.owner.tfstate = self.owner.tfstate - (self.owner.tfstate & #TFSTATE_RELOADING);
	self.owner.weaponmodel = "progs/v_shot2.mdl";
	sprint(self.owner, #PRINT_LOW, "finished reloading\n");
	dremove(self);

	self.owner.StatusRefreshTime = time + 0.1;
};

void() W_Reload_grenade_launcher =
{
	self.owner.tfstate = self.owner.tfstate - (self.owner.tfstate & #TFSTATE_RELOADING);
	self.owner.weaponmodel = "progs/v_rock.mdl";
	sprint(self.owner, #PRINT_LOW, "finished reloading\n");
	dremove(self);

	self.owner.StatusRefreshTime = time + 0.1;
};

void() W_Reload_rocket_launcher =
{
	self.owner.tfstate = self.owner.tfstate - (self.owner.tfstate & #TFSTATE_RELOADING);
	self.owner.weaponmodel = "progs/v_rock2.mdl";
	sprint(self.owner, #PRINT_LOW, "finished reloading\n");
	dremove(self);

	self.owner.StatusRefreshTime = time + 0.1;
};

void() W_Reload_laser_cannon =
{
	self.owner.tfstate = self.owner.tfstate - (self.owner.tfstate & #TFSTATE_RELOADING);
	self.owner.weaponmodel = "progs/v_laserg.mdl";
	sprint(self.owner, #PRINT_LOW, "Laser Cannon charged\n");

	dremove(self);

	self.owner.StatusRefreshTime = time + 0.1;
};

float() CheckForReload =
{
	local float speedmult;
	local entity tWeapon;

	speedmult = 1;

	if (self.#runes & #RUNE_SPEED)
		speedmult = #SPEEDRUNE_RELOADMULT;

	//---------------- CLIP EXTENDER (same as below but with _EX values -------------//
	if (self.cutf_items & #CUTF_CLIPEXTEND)
	{
		//---//
		if (self.current_weapon == #WEAP_SHOTGUN)
		{
			if (self.reload_shotgun >= #RE_SHOTGUN_EX && self.ammo_shells > 0)
			{
				self.reload_shotgun = 0;
				if (self.ammo_shells < #RE_SHOTGUN_EX)
					self.reload_shotgun = #RE_SHOTGUN_EX - self.ammo_shells;

				sprint (self, #PRINT_HIGH, "reloading...\n");
				self.tfstate = (self.tfstate | #TFSTATE_RELOADING);
				tWeapon = spawn();
				tWeapon.owner = self;
				tWeapon.classname = "timer";
				tWeapon.nextthink = time + (#RE_SHOTGUN_TIME_EX * speedmult);
				tWeapon.think = W_Reload_shotgun;

				self.weaponmodel = "";
				self.weaponframe = 0;

				return #TRUE;
			}
		}
		else if (self.current_weapon == #WEAP_SUPER_SHOTGUN)
		{
			if (self.reload_super_shotgun > #RE_SUPER_SHOTGUN_EX)
				self.reload_super_shotgun = #RE_SUPER_SHOTGUN_EX;
			if (self.reload_super_shotgun >= #RE_SUPER_SHOTGUN_EX && self.ammo_shells > 0)
			{
				self.reload_super_shotgun = 0;
				if (self.ammo_shells < #RE_SUPER_SHOTGUN_EX)
					self.reload_super_shotgun = #RE_SUPER_SHOTGUN_EX - self.ammo_shells;

				sprint (self, #PRINT_HIGH, "reloading...\n");
				self.tfstate = (self.tfstate | #TFSTATE_RELOADING);
				tWeapon = spawn();
				tWeapon.owner = self;
				tWeapon.classname = "timer";
				tWeapon.nextthink = time + (#RE_SUPER_SHOTGUN_TIME_EX * speedmult);
				tWeapon.think = W_Reload_super_shotgun;

				self.weaponmodel = "";
				self.weaponframe = 0;

				return #TRUE;
			}
		}
		else if (self.current_weapon == #WEAP_LIGHT_ASSAULT)
		{
			if (self.reload_light_assault >= #RE_LIGHT_ASSAULT_EX && self.ammo_nails > 0)
			{
				self.reload_light_assault = 0;
				if (self.ammo_nails < #RE_LIGHT_ASSAULT_EX)
					self.reload_light_assault = #RE_LIGHT_ASSAULT_EX - self.ammo_nails;

				sprint (self, #PRINT_HIGH, "reloading...\n");
				self.tfstate = (self.tfstate | #TFSTATE_RELOADING);
				tWeapon = spawn();
				tWeapon.owner = self;
				tWeapon.classname = "timer";
				tWeapon.nextthink = time + (#RE_LIGHT_ASSAULT_TIME_EX * speedmult);
				tWeapon.think = W_Reload_light_assault;

				self.weaponmodel = "";
				self.weaponframe = 0;

				return #TRUE;
			}
		}
		else if (self.current_weapon == #WEAP_LASERCANNON)
		{
			if (self.reload_laser_cannon >= #RE_LASER_CANNON_EX && self.ammo_cells > 0)
			{
				self.reload_laser_cannon = 0;
				if (self.ammo_cells < #RE_LASER_CANNON_EX)
					self.reload_laser_cannon = #RE_LASER_CANNON_EX - self.ammo_cells;

				sprint (self, #PRINT_HIGH, "Charging cannon...\n");
				self.tfstate = (self.tfstate | #TFSTATE_RELOADING);
				tWeapon = spawn();
				tWeapon.owner = self;
				tWeapon.classname = "timer";
				tWeapon.nextthink = time + (#RE_LASER_CANNON_TIME_EX * speedmult);
				tWeapon.think = W_Reload_laser_cannon;

				self.weaponmodel = "";
				self.weaponframe = 0;

				return #TRUE;
			}
		}
		else if (self.current_weapon == #WEAP_GRENADE_LAUNCHER)
		{
			if (self.reload_grenade_launcher >= #RE_GRENADE_LAUNCHER_EX && self.ammo_rockets > 0)
			{
				self.reload_grenade_launcher = 0;
				if (self.ammo_rockets < #RE_GRENADE_LAUNCHER_EX)
					self.reload_grenade_launcher = #RE_GRENADE_LAUNCHER_EX - self.ammo_rockets;

				sprint (self, #PRINT_HIGH, "reloading...\n");
				self.tfstate = (self.tfstate | #TFSTATE_RELOADING);
				tWeapon = spawn();
				tWeapon.owner = self;
				tWeapon.classname = "timer";
				tWeapon.nextthink = time + (#RE_GRENADE_LAUNCHER_TIME_EX * speedmult);
				tWeapon.think = W_Reload_grenade_launcher;

				self.weaponmodel = "";
				self.weaponframe = 0;

				return #TRUE;
			}
		}
		else if (self.current_weapon == #WEAP_ROCKET_LAUNCHER)
		{
			if (self.reload_rocket_launcher >= #RE_ROCKET_LAUNCHER_EX && self.ammo_rockets > 0)
			{
				self.reload_rocket_launcher = 0;
				if (self.ammo_rockets < #RE_ROCKET_LAUNCHER_EX)
					self.reload_rocket_launcher = #RE_ROCKET_LAUNCHER_EX - self.ammo_rockets;

				sprint (self, #PRINT_HIGH, "reloading...\n");
				self.tfstate = (self.tfstate | #TFSTATE_RELOADING);
				tWeapon = spawn();
				tWeapon.owner = self;
				tWeapon.classname = "timer";
				if(self.tf_items & #NIT_CLUSTER_ROCKETS)
					tWeapon.nextthink = time + ((#RE_ROCKET_LAUNCHER_TIME_EX - 1) * speedmult);
				else
					tWeapon.nextthink = time + (#RE_ROCKET_LAUNCHER_TIME_EX * speedmult);
				tWeapon.think = W_Reload_rocket_launcher;

				self.weaponmodel = "";
				self.weaponframe = 0;

				return #TRUE;
			}
		}

		return #FALSE;


	//---//
	}

	if (self.current_weapon == #WEAP_SHOTGUN)
	{
		if (self.reload_shotgun >= #RE_SHOTGUN && self.ammo_shells > 0)
		{
			self.reload_shotgun = 0;
			if (self.ammo_shells < #RE_SHOTGUN)
				self.reload_shotgun = #RE_SHOTGUN - self.ammo_shells;

			sprint (self, #PRINT_HIGH, "reloading...\n");
			self.tfstate = (self.tfstate | #TFSTATE_RELOADING);
			tWeapon = spawn();
			tWeapon.owner = self;
			tWeapon.classname = "timer";
			tWeapon.nextthink = time + (#RE_SHOTGUN_TIME * speedmult);
			tWeapon.think = W_Reload_shotgun;

			self.weaponmodel = "";
			self.weaponframe = 0;

			return #TRUE;
		}
	}
	else if (self.current_weapon == #WEAP_SUPER_SHOTGUN)
	{
		if (self.reload_super_shotgun > #RE_SUPER_SHOTGUN)
			self.reload_super_shotgun = #RE_SUPER_SHOTGUN;
		if (self.reload_super_shotgun >= #RE_SUPER_SHOTGUN && self.ammo_shells > 0)
		{
			self.reload_super_shotgun = 0;
			if (self.ammo_shells < #RE_SUPER_SHOTGUN)
				self.reload_super_shotgun = #RE_SUPER_SHOTGUN - self.ammo_shells;

			sprint (self, #PRINT_HIGH, "reloading...\n");
			self.tfstate = (self.tfstate | #TFSTATE_RELOADING);
			tWeapon = spawn();
			tWeapon.owner = self;
			tWeapon.classname = "timer";
			tWeapon.nextthink = time + (#RE_SUPER_SHOTGUN_TIME * speedmult);
			tWeapon.think = W_Reload_super_shotgun;

			self.weaponmodel = "";
			self.weaponframe = 0;

			return #TRUE;
		}
	}
	else if (self.current_weapon == #WEAP_LIGHT_ASSAULT)
	{
		if (self.reload_light_assault >= #RE_LIGHT_ASSAULT && self.ammo_nails > 0)
		{
			self.reload_light_assault = 0;
			if (self.ammo_nails < #RE_LIGHT_ASSAULT)
				self.reload_light_assault = #RE_LIGHT_ASSAULT - self.ammo_nails;

			sprint (self, #PRINT_HIGH, "reloading...\n");
			self.tfstate = (self.tfstate | #TFSTATE_RELOADING);
			tWeapon = spawn();
			tWeapon.owner = self;
			tWeapon.classname = "timer";
			tWeapon.nextthink = time + (#RE_LIGHT_ASSAULT_TIME * speedmult);
			tWeapon.think = W_Reload_light_assault;

			self.weaponmodel = "";
			self.weaponframe = 0;

			return #TRUE;
		}
	}
	else if (self.current_weapon == #WEAP_LASERCANNON)
	{
		if (self.reload_laser_cannon >= #RE_LASER_CANNON && self.ammo_cells > 0)
		{
			self.reload_laser_cannon = 0;
			if (self.ammo_cells < #RE_LASER_CANNON)
				self.reload_laser_cannon = #RE_LASER_CANNON - self.ammo_cells;

			sprint (self, #PRINT_HIGH, "Charging cannon...\n");
			self.tfstate = (self.tfstate | #TFSTATE_RELOADING);
			tWeapon = spawn();
			tWeapon.owner = self;
			tWeapon.classname = "timer";
			tWeapon.nextthink = time + (#RE_LASER_CANNON_TIME * speedmult);
			tWeapon.think = W_Reload_laser_cannon;

			self.weaponmodel = "";
			self.weaponframe = 0;

			return #TRUE;
		}
	}
	else if (self.current_weapon == #WEAP_GRENADE_LAUNCHER)
	{
		if (self.reload_grenade_launcher >= #RE_GRENADE_LAUNCHER && self.ammo_rockets > 0)
		{
			self.reload_grenade_launcher = 0;
			if (self.ammo_rockets < #RE_GRENADE_LAUNCHER)
				self.reload_grenade_launcher = #RE_GRENADE_LAUNCHER - self.ammo_rockets;

			sprint (self, #PRINT_HIGH, "reloading...\n");
			self.tfstate = (self.tfstate | #TFSTATE_RELOADING);
			tWeapon = spawn();
			tWeapon.owner = self;
			tWeapon.classname = "timer";
			tWeapon.nextthink = time + (#RE_GRENADE_LAUNCHER_TIME * speedmult);
			tWeapon.think = W_Reload_grenade_launcher;

			self.weaponmodel = "";
			self.weaponframe = 0;

			return #TRUE;
		}
	}
	else if (self.current_weapon == #WEAP_ROCKET_LAUNCHER)
	{
		if (self.reload_rocket_launcher >= #RE_ROCKET_LAUNCHER && self.ammo_rockets > 0)
		{
			self.reload_rocket_launcher = 0;
			if (self.ammo_rockets < #RE_ROCKET_LAUNCHER)
				self.reload_rocket_launcher = #RE_ROCKET_LAUNCHER - self.ammo_rockets;

			sprint (self, #PRINT_HIGH, "reloading...\n");
		self.tfstate = (self.tfstate | #TFSTATE_RELOADING);
			tWeapon = spawn();
			tWeapon.owner = self;
			tWeapon.classname = "timer";
		if(self.tf_items & #NIT_CLUSTER_ROCKETS)
				tWeapon.nextthink = time + ((#RE_ROCKET_LAUNCHER_TIME - 1) * speedmult);
		else
				tWeapon.nextthink = time + (#RE_ROCKET_LAUNCHER_TIME * speedmult);
			tWeapon.think = W_Reload_rocket_launcher;

			self.weaponmodel = "";
			self.weaponframe = 0;

			return #TRUE;
		}
	}

	return #FALSE;
};

/*
============
W_Attack

An attack impulse can be triggered now
============
*/
void()	player_axe1;
void()	player_axeb1;
void()	player_axec1;
void()	player_axed1;
void()	player_shot1;
void()	player_nail1;

void()	player_snail1; // ofn SNG

void()	player_light1;
void()	player_light_assault1;
void()	player_rocket1;

void()	player_autorifle1;
void()	player_assaultcannon1;
void()	player_assaultcannonup1;
void()	player_assaultcannondown1;
void()	player_medikit1;
void()	player_medikitb1;
void()	player_medikitc1;
void()	player_medikitd1;
void()	player_bioweapon1;
void()	player_bioweaponb1;
void()	player_bioweaponc1;
void()	player_bioweapond1;
void()	player_chain1;
void()	player_chain2;
void()	player_chain3;
void()	player_chain4;
void()	player_chain5;


void() W_Attack =
{
	local float  r;//, tc;
	//local entity tcool;
	//local string st;

	if (!W_CheckNoAmmo ())
		return;

	if (self.playerclass == #PC_CUSTOM && (self.done_custom & #CUSTOM_BUILDING))
		return;

	if (self.tfstate & #TFSTATE_RELOADING)
		return;

	if (self.penance_time > time)
		return;

	// OfN - Psionized guys can't shoot
	if (self.tfstate & #TFSTATE_PSIONIZED)
		return;

	//WK Tranq and Mauser does not remove disguise
	if (self.is_undercover && (self.current_weapon != #WEAP_TRANQ && self.current_weapon != #WEAP_MAUSER))
		Spy_RemoveDisguise(self);

	if (self.job & #JOB_THIEF && (self.job & #JOB_ACTIVE || self.job & #JOB_FULL_HIDE))
		RevealThief(self,#FALSE);

	//WK When conced you randomly don't fire
	if (self.tfstate & #TFSTATE_CONCUSSIONED)
		if (random() <= 0.3)
			return;

	makevectors (self.v_angle); 		// calculate forward angle for velocity
	self.show_hostile = time + 1;	// wake monsters up

	if (self.current_weapon == #WEAP_AXE)
	{
		//if (self.cutf_items & #CUTF_KNIFE) //WK Go berserk with the knife
		//	Attack_Finished(0.5); // no, don't (0.35)
		//else 
			Attack_Finished(0.5);
		
		sound (self, #CHAN_WEAPON, "weapons/ax1.wav", 1, #ATTN_NORM);
		r = random();
		if (r < 0.25)
			player_axe1 ();
		else if (r<0.5)
			player_axeb1 ();
		else if (r<0.75)
			player_axec1 ();
		else
			player_axed1 ();
	}
	else if (self.current_weapon == #WEAP_SPANNER)
	{
		Attack_Finished(0.35); //WK Berserk with spanner
		sound (self, #CHAN_WEAPON, "weapons/ax1.wav", 1, #ATTN_NORM);
		player_axe1 ();
	}
	else if (self.current_weapon == #WEAP_HOOK)
	{
		if (!self.hook_out)
			player_chain1 ();

		Attack_Finished(1); //WK
	}
	else if (self.current_weapon == #WEAP_SHOTGUN)
	{
		if (CheckForReload() == #TRUE)
			return;

		player_shot1 ();
		W_FireShotgun ();

		self.reload_shotgun = self.reload_shotgun + 1;
		self.StatusRefreshTime = time + 0.1;

		CheckForReload();
		Attack_Finished(0.5);
	}
	else if (self.current_weapon == #WEAP_SUPER_SHOTGUN)
	{
		if (CheckForReload() == #TRUE)
			return;

		player_shot1 ();
		W_FireSuperShotgun ();
 
		self.reload_super_shotgun = self.reload_super_shotgun + 2;
			
		self.StatusRefreshTime = time + 0.1;

		CheckForReload();
		Attack_Finished(0.7);
	}
	else if (self.current_weapon == #WEAP_SNG)
	{
		player_snail1 ();
	}
	else if (self.current_weapon == #WEAP_NAILGUN)
	{
		player_nail1 ();
	}
	else if (self.current_weapon == #WEAP_LIGHT_ASSAULT)
	{
		if (CheckForReload() == #TRUE)
			return;

		player_light_assault1();
		CheckForReload();
	}
	else if (self.current_weapon == #WEAP_GRENADE_LAUNCHER)
	{
		if (CheckForReload() == #TRUE)
			return;

		player_rocket1();
		W_FireGrenade();

		self.reload_grenade_launcher = self.reload_grenade_launcher + 1;
		self.StatusRefreshTime = time + 0.1;

		CheckForReload();
		Attack_Finished(0.6);
	}
	else if (self.current_weapon == #WEAP_ROCKET_LAUNCHER)
	{
		if (CheckForReload() == #TRUE)
			return;

		player_rocket1();
		W_FireRocket();

		if (self.tf_items & #NIT_CLUSTER_ROCKETS && self.cluster_mode == #TRUE) //WK Clusters are multiple shots
			self.reload_rocket_launcher = self.reload_rocket_launcher + 8;
		else
			self.reload_rocket_launcher = self.reload_rocket_launcher + 1;
		self.StatusRefreshTime = time + 0.1;

		CheckForReload();
//CH so that the dot can be removed quicker (reset after dot gone)
		if (self.tf_items & #NIT_RL_LASER_SIGHT)
			Attack_Finished(0.1);
		else
			Attack_Finished(0.8);
	}
	else if (self.current_weapon == #WEAP_LIGHTNING)
	{
		player_light1();
		Attack_Finished(0.1);
		sound (self, #CHAN_AUTO, "weapons/lstart.wav", 1, #ATTN_NORM);
	}
	else if (self.current_weapon == #WEAP_DAEDALUS) //CHANGEME
	{
		player_rocket1();
		W_FireDaedalus();
		Attack_Finished(0.8);
		sound (self, #CHAN_AUTO, "weapons/lstart.wav", 1, #ATTN_NORM);
	}
	else if (self.current_weapon == #WEAP_SNIPER_RIFLE)
	{
		// Can't fire while jumping
		// WK You can if you are a scuba commando!
		if ((self.flags & #FL_ONGROUND) || (self.hook_out) || ((self.tf_items & #NIT_SCUBA) && self.waterlevel) )
		{
			player_shot1();
			W_FireSniperRifle();
				Attack_Finished(#SNIPER_RIFLE_RELOAD_TIME);
		}
	}
	else if (self.current_weapon == #WEAP_AUTO_RIFLE)
	{
		player_autorifle1();
			W_FireAutoRifle();
			Attack_Finished(0.1);
	}
	else if (self.current_weapon == #WEAP_ASSAULT_CANNON)
	{
		// Need 4 cells to power up the Assault Cannon
		if (self.ammo_cells < 4)
		{
			sprint (self, #PRINT_MEDIUM, "Insufficient cells to power up the Assault Cannon.\n");
		}
		else
		{
			self.ammo_cells = self.ammo_cells - 4;

			// Can't move while firing the Assault Cannon :)
			self.heat = 1;
			makeImmune(self,time+2);
			//self.immune_to_check = time + 2;
			//WK 2/8/7 Allow Ass Cannons to move now, ala Classic TF
			//self.tfstate = self.tfstate | #TFSTATE_CANT_MOVE;
			TeamFortress_SetSpeed(self);
			player_assaultcannonup1();
		}
	}
	else if (self.current_weapon == #WEAP_FLAMETHROWER)
	{
		player_shot1();
		W_FireFlame();
		if (self.waterlevel >2)
			Attack_Finished(1);
		else
			Attack_Finished(0.15);
	}
	else if (self.current_weapon == #WEAP_INCENDIARY)
	{
		player_rocket1();
		W_FireIncendiaryCannon();
		Attack_Finished(1.2);
	}
	else if (self.current_weapon == #WEAP_MEDIKIT)
	{
		sound (self, #CHAN_WEAPON, "weapons/ax1.wav", 1, #ATTN_NORM);
		r = random();
		if (r < 0.25)
			player_medikit1 ();
		else if (r<0.5)
			player_medikitb1 ();
		else if (r<0.75)
			player_medikitc1 ();
		else
			player_medikitd1 ();
		Attack_Finished(0.5);

	}
	else if (self.current_weapon == #WEAP_TRANQ)
	{
		sound (self, #CHAN_WEAPON, "weapons/dartgun.wav", 1, #ATTN_NORM);
		player_shot1 ();
		W_FireTranq ();
			Attack_Finished(1.5);
	}
	else if (self.current_weapon == #WEAP_RAILGUN)
	{
		sound (self, #CHAN_WEAPON, "weapons/railgun.wav", 1, #ATTN_NORM);
		player_shot1();
		W_FireLaser();
		Attack_Finished(0.4);
	}
	else if (self.current_weapon == #WEAP_MAUSER)
	{
		sound (self, #CHAN_WEAPON, "weapons/dartgun.wav", 1, #ATTN_NORM);
		//player_shot1();
		W_FireMauser();
		Attack_Finished(2.0);
	}
	else if (self.current_weapon == #WEAP_AIRF)
	{
		launch_horn();
	}
#ifndef NO_ZEROGRAVGUN
	// Gizmo - zero-gravity tool
	else if ( self.current_weapon == #WEAP_ZEROGRAVITY ) {
		zg_togglepickup( self, #FALSE );
		Attack_Finished( 0.4 );
	}
#endif
	if (self.current_weapon == #WEAP_LASERCANNON)
	{
		if (CheckForReload() == #TRUE)
			return;

		player_laser1();
		CheckForReload();
	}
};

/*=========================
	W_PrintWeaponMessage

Prints a message indicating
the current selected weapon,
if needed.
=========================*/
void() W_PrintWeaponMessage =
{
	//WK Custom class friendly
	if (self.current_weapon == #WEAP_AXE) // && (self.weapons_carried & #WEAP_HOOK))
	{
		if (!(self.cutf_items & #CUTF_KNIFE))
			sprint(self, #PRINT_MEDIUM, "Axe selected\n");
		else
		{
		if (self.weaponmode == 0)
			sprint(self, #PRINT_MEDIUM, "Knife selected\n"); //Nonbloody
		else
			sprint(self, #PRINT_MEDIUM, "Bloody Knife selected\n"); //Bloody
		}
	}
	else if (self.current_weapon == #WEAP_HOOK)
		sprint(self, #PRINT_MEDIUM, "Grappling Hook selected\n");
//CH because they use the same mdl, say what they are.
	else if (self.current_weapon == #WEAP_FLAMETHROWER)
		sprint(self, #PRINT_MEDIUM, "Flamethrower selected\n");
	else if (self.current_weapon == #WEAP_ROCKET_LAUNCHER) {
		sprint(self, #PRINT_MEDIUM, "Rocket Launcher selected");

		if (self.cluster_mode == #TRUE && self.tf_items & #NIT_CLUSTER_ROCKETS) //set to fire cluster rockets
			sprint(self, #PRINT_MEDIUM, "  Cluster Mode");
		else if (self.tf_items & #NIT_CLUSTER_ROCKETS)
			sprint(self, #PRINT_MEDIUM, "  Normal Mode");

		sprint(self, #PRINT_MEDIUM, "\n");
	}
	else if (self.current_weapon == #WEAP_INCENDIARY)
		sprint(self, #PRINT_MEDIUM, "Incendiary cannon selected\n");
	else if (self.current_weapon == #WEAP_LIGHTNING)
			sprint(self, #PRINT_MEDIUM, "Lightning Gun selected\n");
	else if (self.current_weapon == #WEAP_SPANNER)
			sprint(self, #PRINT_MEDIUM, "Spanner readied\n");

	else if (self.current_weapon == #WEAP_GRENADE_LAUNCHER)
	{
		if (self.weaponmode == #GL_NORMAL)
			sprint(self, #PRINT_MEDIUM, "Normal grenade mode\n");
		else if (self.weaponmode == #GL_PIPEBOMB)
			sprint(self, #PRINT_MEDIUM, "Pipebomb mode\n");
	}
	else if (self.current_weapon == #WEAP_SNIPER_RIFLE)
		sprint(self, #PRINT_MEDIUM, "Sniper Rifle ready\n");
	else if (self.current_weapon == #WEAP_AUTO_RIFLE)
		sprint(self, #PRINT_MEDIUM, "Rifle on fully auto\n");
	else if (self.current_weapon == #WEAP_TRANQ)
		sprint(self, #PRINT_MEDIUM, "Tranquiliser gun selected\n");
	else if (self.current_weapon == #WEAP_MEDIKIT)
		sprint(self, #PRINT_MEDIUM, "Medikit/Bioweapon readied\n");
	else if (self.current_weapon == #WEAP_ASSAULT_CANNON)
		sprint(self, #PRINT_MEDIUM, "Assault Cannon ready\n");
	else if (self.current_weapon == #WEAP_MAUSER)
		sprint(self, #PRINT_MEDIUM, "Mauser WK-77 Assassin's Gun readied\n");
	else if (self.current_weapon == #WEAP_DAEDALUS)
		sprint(self, #PRINT_MEDIUM, "Daedalus Impulse Rifle readied\n");
	else if (self.current_weapon == #WEAP_LIGHTNING)
		sprint(self, #PRINT_MEDIUM, "Lighting gun selected\n");
	else if (self.current_weapon == #WEAP_AIRF)
		sprint(self, #PRINT_MEDIUM, "Airfist prepared\n");
	else if (self.current_weapon == #WEAP_LASERCANNON)
		sprint(self, #PRINT_MEDIUM, "Laser Cannon selected\n");
	else if (self.current_weapon == #WEAP_SNG)
		sprint(self, #PRINT_MEDIUM, "Super Nailgun selected\n");
	else if (self.current_weapon == #WEAP_NAILGUN)
		sprint(self, #PRINT_MEDIUM, "Nailgun selected\n");
	else if (self.current_weapon == #WEAP_LIGHT_ASSAULT)
		sprint(self, #PRINT_MEDIUM, "Light Assault cannon selected\n");
	else if (self.current_weapon == #WEAP_SHOTGUN)
		sprint(self, #PRINT_MEDIUM, "Shotgun selected\n");
	else if (self.current_weapon == #WEAP_SUPER_SHOTGUN)
		sprint(self, #PRINT_MEDIUM, "Super Shotgun selected\n");
	else if (self.current_weapon == #WEAP_RAILGUN)
		sprint(self, #PRINT_MEDIUM, "Railgun selected\n");
#ifndef NO_ZEROGRAVGUN
	// Gizmo -
	else if (self.current_weapon == #WEAP_ZEROGRAVITY)
		sprint (self, #PRINT_MEDIUM, "Zero-Gravity Gun selected\n");
#endif
};


/*
============
W_ChangeWeapon

============
*/
void() W_ChangeWeapon =
{
	local	float	it, am, fl, loopck;
	local	float	have_weapon, usable;
	
	if (self.tfstate & #TFSTATE_RELOADING)
		return;

	if (self.tfstate & #TFSTATE_CANT_MOVE)
		return; 

	it = self.weapons_carried;
	fl = self.current_weapon;
	am = 0;
	usable = 0;
	have_weapon = #TRUE;

	if (self.impulse == 1)
	{
		if (!(it & (#WEAP_HOOK | #WEAP_MEDIKIT | #WEAP_AXE | #WEAP_SPANNER)))
			have_weapon = #FALSE;			

		while (!usable && have_weapon)
		{
			if (fl == #WEAP_SPANNER)
			{
				fl = #WEAP_MEDIKIT;

				if (it & #WEAP_MEDIKIT)
					usable = 1;
			}
			else if (fl == #WEAP_MEDIKIT)
			{
				fl = #WEAP_HOOK;

				if ((self.weapons_carried & #WEAP_HOOK) && (fl & #WEAP_HOOK))
					usable = 1;

				if (self.hook_out)
					Reset_Grapple(self.hook);
			}
			else if (fl == #WEAP_HOOK)
			{
				fl = #WEAP_AXE;

				if (it & #WEAP_AXE)
					usable = 1;
			}
			else
			{
				fl = #WEAP_SPANNER;

				if (it & #WEAP_SPANNER)
					usable = 1;
			}
		}
	}
	else if ((self.weapons_carried & #WEAP_HOOK) && (self.impulse == #HOOK_IMP1 || self.impulse == #HOOK_IMP2)) 
	{
		fl = #WEAP_HOOK;		
	}
	else if (self.impulse == #AXE_IMP)
	{
		if (!(it & (#WEAP_MEDIKIT | #WEAP_AXE | #WEAP_SPANNER)))
			have_weapon = #FALSE;			

		while (!usable && have_weapon)
		{
			if (fl == #WEAP_SPANNER)
			{
				fl = #WEAP_MEDIKIT;

				if (it & #WEAP_MEDIKIT)
					usable = 1;
			}
			else if (fl == #WEAP_MEDIKIT)
			{
				fl = #WEAP_AXE;

				if (it & #WEAP_AXE)
					usable = 1;
			}
			else
			{
				fl = #WEAP_SPANNER;

				if (it & #WEAP_SPANNER)
					usable = 1;
			}
		}
	}
	else if (self.impulse == 2)
	{
		if (!(((it & #WEAP_SNIPER_RIFLE || it & #WEAP_SHOTGUN || it & #WEAP_TRANQ) && self.ammo_shells > 0) || (it & #WEAP_RAILGUN && self.ammo_nails > 0)|| (it & #WEAP_DAEDALUS && self.ammo_cells > 0)))
			have_weapon = #FALSE;
		loopck = 0;
		while (!usable && have_weapon)
		{
			loopck = (loopck + 1);
			if (loopck >= 10)
				have_weapon = #FALSE;
			if (fl == #WEAP_SNIPER_RIFLE)
			{
				fl = #WEAP_SHOTGUN;
				if (it & #WEAP_SHOTGUN && self.ammo_shells > 0)
					usable = 1;
			}
			else if (fl == #WEAP_SHOTGUN)
			{
				fl = #WEAP_TRANQ;
				if (it & #WEAP_TRANQ && self.ammo_nails > 0)
					usable = 1;
			}
			else if (fl == #WEAP_TRANQ)
			{
				fl = #WEAP_RAILGUN;
				if (it & #WEAP_RAILGUN && self.ammo_nails > 0)
					usable = 1;
			}
			else
			{
				fl = #WEAP_SNIPER_RIFLE;
				if (it & #WEAP_SNIPER_RIFLE && self.ammo_shells > 0)
					usable = 1;
			}
		}
		if (fl == #WEAP_RAILGUN)
		{
			if (self.ammo_nails < 1)
				am = 1;
		}
		else
		{	
			if (self.ammo_shells < 1)
				am = 1;
		}
	}
	else if (self.impulse == 3)
	{
		if (!((it & #WEAP_AUTO_RIFLE && self.ammo_shells > 0) || (it & #WEAP_SUPER_SHOTGUN && self.ammo_shells >1)))
			have_weapon = #FALSE;
		loopck = 0;
		while (!usable && have_weapon)
		{
			loopck = (loopck + 1);
			if (loopck >= 10)
				have_weapon = #FALSE;
			if (fl == #WEAP_AUTO_RIFLE)
			{
				fl = #WEAP_SUPER_SHOTGUN;
				if (it & #WEAP_SUPER_SHOTGUN && self.ammo_shells > 1)
					usable = 1;
			}
			else
			{
				fl = #WEAP_AUTO_RIFLE;
				if (it & #WEAP_AUTO_RIFLE && self.ammo_shells > 0)
					usable = 1;
			}
		}
		if (fl == #WEAP_SUPER_SHOTGUN)
		{
			if (self.ammo_shells < 2)
				am = 1;
		}
		else
		{	
			if (self.ammo_shells < 1)
				am = 1;
		}
	}		
	else if (self.impulse == 4)
	{
		/*fl = #WEAP_NAILGUN;
		if (self.ammo_nails < 1)
			am = 1;*/

		if (!(it & #WEAP_LASERCANNON || it & #WEAP_NAILGUN))
			have_weapon = #FALSE;
		loopck = 0;
		while (!usable && have_weapon)
		{
			loopck = (loopck + 1);
			if (loopck >= 10)
				have_weapon = #FALSE;
			if (fl == #WEAP_LASERCANNON)
			{
				fl = #WEAP_NAILGUN;
				if (it & #WEAP_NAILGUN)
					usable = 1;
			}
			else
			{
				fl = #WEAP_LASERCANNON;
				if (it & #WEAP_LASERCANNON)
					usable = 1;
			}
		}
		if (fl == #WEAP_NAILGUN)
		{
			if (self.ammo_nails < 1)
				am = 1;
		}
		else if (fl == #WEAP_LASERCANNON)
		{
			if (self.ammo_cells < 1)
				am = 1;
		}
	}
	else if (self.impulse == 5)
	{
		if (!(it & #WEAP_LIGHT_ASSAULT || it & #WEAP_MAUSER || it & #WEAP_SNG))
			have_weapon = #FALSE;
		loopck = 0;
		while (!usable && have_weapon)
		{
			loopck = (loopck + 1);
			if (loopck >= 10)
				have_weapon = #FALSE;
			if (fl == #WEAP_LIGHT_ASSAULT)
			{
				fl = #WEAP_MAUSER;
				if (it & #WEAP_MAUSER)
					usable = 1;
			}
			
			//-
			else if (fl == #WEAP_MAUSER)
			{
				fl = #WEAP_SNG;
				if (it & #WEAP_SNG)
					usable = 1;
			}
			//-

			else
			{
				fl = #WEAP_LIGHT_ASSAULT;
				if (it & #WEAP_LIGHT_ASSAULT)
					usable = 1;
			}
		}
		if (fl == #WEAP_MAUSER)
		{
			if (self.ammo_nails < 1)
				am = 1;
		}
		else if (fl == #WEAP_LIGHT_ASSAULT)
		{
			if (self.ammo_nails < 1)
				am = 1;
		}
		//
		else if (fl == #WEAP_SNG)
		{
			if (self.ammo_nails < 2)
				am = 1;
		}
	}
	else if (self.impulse == 6)
	{
		if (!((it & #WEAP_FLAMETHROWER && self.ammo_cells > 0) || (it & #WEAP_GRENADE_LAUNCHER && self.ammo_rockets > 0)))
			have_weapon = #FALSE;
		loopck = 0;
		while (!usable && have_weapon)
		{
			loopck = (loopck + 1);
			if (loopck >= 10)
				have_weapon = #FALSE;
			if (fl == #WEAP_FLAMETHROWER)
			{
				fl = #WEAP_GRENADE_LAUNCHER;
				self.weaponmode = #GL_NORMAL;
				if (it & #WEAP_GRENADE_LAUNCHER && self.ammo_rockets > 0)
					usable = 1;
			}
			else
			{
				fl = #WEAP_FLAMETHROWER;
				if (it & #WEAP_FLAMETHROWER && self.ammo_cells > 0)
					usable = 1;
			}
		}
		if (fl == #WEAP_FLAMETHROWER)
		{
			if (self.ammo_cells < 1)
				am = 1;
		}
		else
		{	
			if (self.ammo_rockets < 1)
				am = 1;
		}
	}
	else if (self.impulse == 7)
	{
		if (!((it & #WEAP_INCENDIARY && self.ammo_rockets > 2) || ((it & #WEAP_ROCKET_LAUNCHER || it & #WEAP_GRENADE_LAUNCHER) && self.ammo_rockets > 0) || (it & #WEAP_ASSAULT_CANNON && self.ammo_shells > 0 && self.ammo_cells > 3)))
			have_weapon = #FALSE;
		loopck = 0;
		while (!usable && have_weapon)
		{
			loopck = (loopck + 1);
			if (loopck >= 10)
				have_weapon = #FALSE;
			if (fl == #WEAP_INCENDIARY)
			{
				fl = #WEAP_ROCKET_LAUNCHER;
				if (it & #WEAP_ROCKET_LAUNCHER && self.ammo_rockets > 0)
					usable = 1;
			}
			else if (fl == #WEAP_ROCKET_LAUNCHER)
			{
				if (self.tf_items & #NIT_CLUSTER_ROCKETS)
				{
					if (self.cluster_mode == #TRUE)
					{
//						bprint(#PRINT_HIGH, "cluster mode FALSE\n");
						self.cluster_mode = #FALSE;
						fl = #WEAP_ASSAULT_CANNON;
						if (it & #WEAP_ASSAULT_CANNON && self.ammo_shells > 0 && self.ammo_cells > 3)
							usable = 1;
					}
					else
					{
//						bprint(#PRINT_HIGH, "cluster mode TRUE\n");
						self.cluster_mode = #TRUE;
						fl = #WEAP_ROCKET_LAUNCHER;
						if (it & #WEAP_ROCKET_LAUNCHER && self.ammo_rockets > 0)
							usable = 1;
					}
				} 
				else
				{
					fl = #WEAP_ASSAULT_CANNON;
					if (it & #WEAP_ASSAULT_CANNON && self.ammo_shells > 0 && self.ammo_cells > 3)
						usable = 1;
				}
			}
			else if (fl == #WEAP_ASSAULT_CANNON)
			{
				fl = #WEAP_GRENADE_LAUNCHER;
				self.weaponmode = #GL_PIPEBOMB;
				if (it & #WEAP_GRENADE_LAUNCHER && self.ammo_rockets > 0)
					usable = 1;
			}
			else
			{
				fl = #WEAP_INCENDIARY;
				if (it & #WEAP_INCENDIARY && self.ammo_rockets > 2)
					usable = 1;
			}
		}
		if (fl == #WEAP_ASSAULT_CANNON)
		{
			if (self.ammo_cells < 4 || self.ammo_shells < 1)
				am = 1;
		}
		else if (fl == #WEAP_INCENDIARY)
		{
			if (self.ammo_rockets < 3)
				am = 1;
		}
		else
		{
			if (self.ammo_rockets < 1)
				am = 1;
		}
	}
	// Gizmo - modified for zero-gravity
	else if (self.impulse == 8)
	{
		if (!(it & #WEAP_LIGHTNING || it & #WEAP_DAEDALUS || it & #WEAP_AIRF || it & #WEAP_ZEROGRAVITY))
			have_weapon = #FALSE;
		loopck = 0;
		while (!usable && have_weapon)
		{
			loopck = (loopck + 1);
			if (loopck >= 10)
				have_weapon = #FALSE;
			if (fl == #WEAP_DAEDALUS)
			{
				fl = #WEAP_LIGHTNING;
				if (it & #WEAP_LIGHTNING) //WEAP_DAEDALUS
					usable = 1;
			}
			else if (fl == #WEAP_LIGHTNING)
			{
				fl = #WEAP_AIRF;
				if (it & #WEAP_AIRF) //WEAP_DAEDALUS
					usable = 1;
			}
			else if (fl == #WEAP_AIRF)
			{
				fl = #WEAP_ZEROGRAVITY;
				if (it & #WEAP_ZEROGRAVITY)
					usable = 1;
			} else {
				fl = #WEAP_DAEDALUS;
				if (it & #WEAP_DAEDALUS)
					usable = 1;
			}
		}
		if (fl == #WEAP_DAEDALUS)
		{
			if (self.ammo_cells < 5)
				am = 1;
		}
		else if (fl == #WEAP_LIGHTNING)
		{
			if (self.ammo_cells < 1)
				am = 1;
		}	
		else if (fl == #WEAP_AIRF)
		{
			if (self.ammo_cells < #AIRFIST_CELLS_COST)
				am = 3;
		}
	}
	else if (self.impulse == #TF_MEDIKIT)
	{
		fl = #WEAP_MEDIKIT;

		if (it & #WEAP_MEDIKIT)
			usable = 1;
	}

	self.impulse = 0;
	
	// don't have the weapon
	if (!have_weapon || (!(it & fl)))
	{	
		sprint (self, #PRINT_HIGH, "no weapon.\n");
		return;
	}
	
	// don't have the ammo
	if (am == 1)
	{	
		sprint(self, #PRINT_HIGH, "not enough ammo.\n");
		return;
	}

	// don't have the cells for the cannon
	if (am == 2)
	{
		sprint(self, #PRINT_HIGH, "not enough cells to power assault cannon.\n");
		return;
	}

	// Don't have enough cells for airfist
	if (am == 3)
	{
		sprint(self,#PRINT_HIGH,"Not enough cells to power the airfist.\n");
		return;
	}

#ifndef NO_ZEROGRAVGUN
	// Gizmo - drop anything picked up
	if ( self.current_weapon == #WEAP_ZEROGRAVITY && self.pickedupobject_hands != world )
		zg_drop( self, #FALSE );
#endif

	// set weapon, set ammo
	self.current_weapon = fl;
	W_SetCurrentAmmo ();
	W_PrintWeaponMessage();

	self.StatusRefreshTime = time + 0.1;
};

/*
============
CycleWeaponCommand

Go to the next weapon with ammo
============
*/
void() CycleWeaponCommand =
{
//CH reorder so that they please me
	local	float	it, am, cont, loopcount;
	
	// Some safety code
	if (self.weaponmodel == string_null || self.current_weapon == 0)
		return;

	if (self.tfstate & #TFSTATE_RELOADING)
		return;

	if (self.tfstate & #TFSTATE_CANT_MOVE)
		return;

#ifndef NO_ZEROGRAVGUN
	// Gizmo - drop anything picked up
	if ( self.pickedupobject_hands != world )
		zg_drop( self, #FALSE );
#endif

	it = self.weapons_carried;
	self.impulse = 0;
	loopcount = 0;
	
	while (1)
	{
		am = 0;
		cont = #FALSE;

		if (self.current_weapon == #WEAP_AXE)
		{
			self.current_weapon = #WEAP_SPANNER;
		}
		else if (self.current_weapon == #WEAP_SPANNER)
		{
			self.current_weapon = #WEAP_SHOTGUN;
			if (self.ammo_shells < 1)
				am = 1;
		}
		else if (self.current_weapon == #WEAP_SHOTGUN)
		{
			self.current_weapon = #WEAP_RAILGUN;
			if (self.ammo_nails < 1)
				am = 1;
		}		
		else if (self.current_weapon == #WEAP_RAILGUN)
		{
			self.current_weapon = #WEAP_TRANQ;
			if (self.ammo_nails < 1)
				am = 1;
		}		
		else if (self.current_weapon == #WEAP_TRANQ)
		{
			self.current_weapon = #WEAP_SNIPER_RIFLE;
			if (self.ammo_shells < 1)
				am = 1;
		}		
		else if (self.current_weapon == #WEAP_SNIPER_RIFLE)
		{
			self.current_weapon = #WEAP_AUTO_RIFLE;
			if (self.ammo_shells < 1)
				am = 1;
		}
		else if (self.current_weapon == #WEAP_AUTO_RIFLE)
		{
			self.current_weapon = #WEAP_MAUSER;
			if (self.ammo_nails < 1)
				am = 1;
		}
		else if (self.current_weapon == #WEAP_MAUSER)
		{
			self.current_weapon = #WEAP_SUPER_SHOTGUN;
			if (self.ammo_shells < 2)
				am = 1;
		}
		else if (self.current_weapon == #WEAP_SUPER_SHOTGUN)
		{
			self.current_weapon = #WEAP_NAILGUN;
			if (self.ammo_nails < 1)
				am = 1;
		}
		
		//-
		else if (self.current_weapon == #WEAP_NAILGUN)
		{
			self.current_weapon = #WEAP_SNG;
			if (self.ammo_nails < 2)
				am = 1;
		}
		//-

		else if (self.current_weapon == #WEAP_SNG)
		{
			self.current_weapon = #WEAP_LASERCANNON;
			if (self.ammo_cells < 1)
				am = 1;
		}
		//-
		
		else if (self.current_weapon == #WEAP_LASERCANNON) // was WEAP_NAILGUN
		{
			self.current_weapon = #WEAP_LIGHT_ASSAULT;
			if (self.ammo_nails < 2)
				am = 1;
		}
		else if (self.current_weapon == #WEAP_LIGHT_ASSAULT)
		{
			self.current_weapon = #WEAP_FLAMETHROWER;
			if (self.ammo_cells < 1)
				am = 1;
		}
		else if (self.current_weapon == #WEAP_FLAMETHROWER)
		{
			self.current_weapon = #WEAP_GRENADE_LAUNCHER;
			self.weaponmode = #GL_NORMAL;
			if (self.ammo_rockets < 1)
				am = 1;
		}
		else if (self.current_weapon == #WEAP_GRENADE_LAUNCHER && self.weaponmode == #GL_NORMAL)
		{
			self.current_weapon = #WEAP_GRENADE_LAUNCHER;
			self.weaponmode = #GL_PIPEBOMB;
			if (self.ammo_rockets < 1)
				am = 1;
		}
		else if (self.current_weapon == #WEAP_GRENADE_LAUNCHER && self.weaponmode == #GL_PIPEBOMB)
		{
			self.current_weapon = #WEAP_INCENDIARY;
			if (self.ammo_rockets < 3)
				am = 1;
		}
		else if (self.current_weapon == #WEAP_INCENDIARY)
		{
			self.current_weapon = #WEAP_DAEDALUS;
			if (self.ammo_cells < 1)
				am = 1;
		}
		else if (self.current_weapon == #WEAP_DAEDALUS)
		{
			self.current_weapon = #WEAP_ROCKET_LAUNCHER;
			if (self.ammo_rockets < 1)
				am = 1;
		}
		else if (self.current_weapon == #WEAP_ROCKET_LAUNCHER)
		{
			if (self.tf_items & #NIT_CLUSTER_ROCKETS)
			{
				if (self.cluster_mode == #TRUE)
				{
//					bprint(#PRINT_HIGH, "cluster mode FALSE\n");
					self.cluster_mode = #FALSE;
					self.current_weapon = #WEAP_ASSAULT_CANNON;
					if (self.ammo_cells < 4)
						am = 1;
					if (self.ammo_shells < 1)
						am = 1;
				}
				else
				{
//					bprint(#PRINT_HIGH, "cluster mode TRUE\n");
					self.cluster_mode = #TRUE;
					self.current_weapon = #WEAP_ROCKET_LAUNCHER;
					if (self.ammo_rockets < 1)
						am = 1;
				}
			}
			else
			{
				self.current_weapon = #WEAP_ASSAULT_CANNON;
				if (self.ammo_cells < 4)
					am = 1;
				if (self.ammo_shells < 1)
					am = 1;
			}

		}
		else if (self.current_weapon == #WEAP_ASSAULT_CANNON)
		{
				self.current_weapon = #WEAP_LIGHTNING;
				if (self.ammo_cells < 1)
					am = 1;
		}
		else if (self.current_weapon == #WEAP_LIGHTNING)
		{
			self.current_weapon = #WEAP_AIRF;

			if (!(self.weapons_carried & #WEAP_AIRF))
				am = 1;

			if (self.ammo_cells < #AIRFIST_CELLS_COST)
				am = 1;
		}
		// Gizmo - added zg to cycle
		else if (self.current_weapon == #WEAP_AIRF)
		{
			self.current_weapon = #WEAP_ZEROGRAVITY;

			if (!(self.weapons_carried & #WEAP_ZEROGRAVITY))
				am = 1;
		}
		else if (self.current_weapon == #WEAP_ZEROGRAVITY)
		{
			self.current_weapon = #WEAP_HOOK;

			if (!(self.weapons_carried & #WEAP_HOOK))
				am = 1;
		}
		else if (self.current_weapon == #WEAP_HOOK)
		{
			self.current_weapon = #WEAP_MEDIKIT;
		}
		else if (self.current_weapon == #WEAP_MEDIKIT)
		{
			self.current_weapon = #WEAP_AXE;
		}

		// Safety precaution
		if (loopcount > 30)
			return;

		loopcount = loopcount + 1;

		// check if player actually has the weapon
		// if not, loop again
		if ((self.weapons_carried & self.current_weapon) && (am == 0))
		{
			if (self.current_weapon != #WEAP_GRENADE_LAUNCHER)
				self.weaponmode = #GL_NORMAL;	// reset the pipebombs

			W_SetCurrentAmmo ();
			W_PrintWeaponMessage();

			self.StatusRefreshTime = time + 0.1;
			return;
		}
	}
};

/*
============
ChangeToWeapon

Gizmo: Switches to the specified weapon if possible
============
*/
void( string weaponName ) ChangeToWeapon = {
	local float fl;

	if ( self.tfstate & #TFSTATE_RELOADING )
		return;

	if ( self.tfstate & #TFSTATE_CANT_MOVE )
		return;

#ifndef NO_ZEROGRAVGUN
	// drop anything picked up
	if ( self.pickedupobject_hands != world )
		zg_drop( self, #FALSE );
#endif

	// TODO: create macros for the weapon names
	if ( !strcasecmp( weaponName, "Hook" ) )
		fl = #WEAP_HOOK;
	else if ( !strcasecmp( weaponName, "Medikit" ) )
		fl = #WEAP_MEDIKIT;
	else if ( !strcasecmp( weaponName, "Spanner" ) )
		fl = #WEAP_SPANNER;
	else if ( !strcasecmp( weaponName, "Axe" ) )
		fl = #WEAP_AXE;
	else if ( !strcasecmp( weaponName, "Sniper" ) )
		fl = #WEAP_SNIPER_RIFLE;
	else if ( !strcasecmp( weaponName, "AutoRifle" ) )
		fl = #WEAP_AUTO_RIFLE;
	else if ( !strcasecmp( weaponName, "Shotgun" ) )
		fl = #WEAP_SHOTGUN;
	else if ( !strcasecmp( weaponName, "SuperShotgun" ) )
		fl = #WEAP_SUPER_SHOTGUN;
	else if ( !strcasecmp( weaponName, "Nailgun" ) )
		fl = #WEAP_NAILGUN;
	else if ( !strcasecmp( weaponName, "LightAssault" ) )
		fl = #WEAP_LIGHT_ASSAULT;
	else if ( !strcasecmp( weaponName, "Grenade" ) ) {
		self.weaponmode = #GL_NORMAL;
		fl = #WEAP_GRENADE_LAUNCHER;
	} else if ( !strcasecmp( weaponName, "Pipe" ) ) {
		self.weaponmode = #GL_PIPEBOMB;
		fl = #WEAP_GRENADE_LAUNCHER;
	} else if ( !strcasecmp( weaponName, "Flame" ) )
		fl = #WEAP_FLAMETHROWER;
	else if ( !strcasecmp( weaponName, "Rocket" ) ) {
		self.cluster_mode = #FALSE;
		fl = #WEAP_ROCKET_LAUNCHER;
	} else if ( !strcasecmp( weaponName, "Cluster" ) ) {
		if ( self.tf_items & #NIT_CLUSTER_ROCKETS ) {
			self.cluster_mode = #TRUE;
			fl = #WEAP_ROCKET_LAUNCHER;
		} else
			fl = 0;
	} else if ( !strcasecmp( weaponName, "Incendiary" ) )
		fl = #WEAP_INCENDIARY;
	else if ( !strcasecmp( weaponName, "Assault" ) )
		fl = #WEAP_ASSAULT_CANNON;
	else if ( !strcasecmp( weaponName, "Lightning" ) )
		fl = #WEAP_LIGHTNING;
	else if ( !strcasecmp( weaponName, "Daedalus" ) )
		fl = #WEAP_DAEDALUS;
	else if ( !strcasecmp( weaponName, "Tranq" ) )
		fl = #WEAP_TRANQ;
	else if ( !strcasecmp( weaponName, "Railgun" ) )
		fl = #WEAP_RAILGUN;
	else if ( !strcasecmp( weaponName, "Mauser" ) )
		fl = #WEAP_MAUSER;
	else if ( !strcasecmp( weaponName, "Airfist" ) )
		fl = #WEAP_AIRF;
	else if ( !strcasecmp( weaponName, "LaserCannon" ) )
		fl = #WEAP_LASERCANNON;
	else if ( !strcasecmp( weaponName, "SNG" ) )
		fl = #WEAP_SNG;
#ifndef NO_ZEROGRAVGUN
	else if ( !strcasecmp( weaponName, "ZeroGrav" ) )
		fl = #WEAP_ZEROGRAVITY;
#endif
	else {
		sprint( self, #PRINT_HIGH, "invalid weapon specified\n" );
		return;
	}

	if ( !( self.weapons_carried & fl ) ) {
		sprint( self, #PRINT_HIGH, "you do not have that weapon\n" );
		return;
	}

	self.current_weapon = fl;
	W_SetCurrentAmmo();
	W_PrintWeaponMessage();

	self.StatusRefreshTime = time + 0.1;
};



#ifndef QUAKE_WORLD
void() QuadCheat =
{
	if (deathmatch || coop)
		return;
	self.super_time = 1;
	self.super_damage_finished = time + 30;
	self.items = self.items | #IT_QUAD;
	RPrint ("quad cheat\n");
};
#endif

/*
============
ImpulseCommands

============
*/
void() DeadImpulses;

float(float inp) BuildingImpulses =
{
	if (inp < 10) return #TRUE;
	if (inp > #TF_CHANGEPC && inp <= #TF_CHANGEPC + #PC_LASTCLASS) return #TRUE;
	if (inp == #TF_CHANGECLASS) return #TRUE;
	if (inp == #TF_HELP_MAP) return #TRUE;
	if (inp == #TF_SHOWTF) return #TRUE;
	if (inp == #TF_TEAM_CLASSES) return #TRUE;
	if (inp == #TF_TEAM_SCORES) return #TRUE;
	if (inp == #TF_TEAM_LIST) return #TRUE;
	if (inp == #TF_TEAM_ENUM) return #TRUE;
	if (inp == #TF_ID) return #TRUE;
	if (inp == #TF_SELL) return #TRUE;
	if (inp == #I_CHEAT_ONE) return #TRUE;
	if (inp == #I_CHEAT_TWO) return #TRUE;
	if (inp == #I_CHEAT_THREE) return #TRUE;	
	if (inp == #IMPULSE_VOTEYES) return #TRUE;
	if (inp == #IMPULSE_VOTENO) return #TRUE;
	return #FALSE;
};

//WK 10/10/7 This function now holds all the impulses that can be done during
//	 an attack_finished global cooldown. Fixed sticky grens, sticky jobs, etc.
// RETURNS: 1 if the function handled the command, 0 if it didn't
float() NoCooldownImpulseCommands =
{
	//WK 10/10/7
	if ((self.impulse== #TF_CHANGEPC + #PC_CUSTOM || self.impulse==#TF_SELL) && custom_mode==2)
	{
		self.impulse=0;
		sprint(self,#PRINT_MEDIUM,"Custom player classes are disabled\n");
		return 1;
	}

	if (self.impulse <= #TF_CHANGEPC + #PC_RANDOM && self.impulse >= #TF_CHANGEPC + #PC_SCOUT && stock_mode==2)
	{
		self.impulse=0;
		sprint(self,#PRINT_MEDIUM,"Stock player classes are disabled\n");
		return 1;
	}

	//local entity te; //- OfN - Unused!
	
	//WK Don't allow any commands except menu ones when building a class
	if (self.playerclass == #PC_CUSTOM && (self.done_custom & #CUSTOM_BUILDING))
	{
		if (!BuildingImpulses(self.impulse))
		{
			self.impulse = 0;
			return 1;
		}
	}

	//WK Don't allow bastards to do any commands
	if (self.penance_time > time)
		return 1;
	
	// PZ: we're going to try allowing all commands during prematch	
	/* if (prematch >= time)
		if (self.impulse > 10 || self.impulse < 1)
		{
			self.impulse = 0;
			return 1;
		} */

	// Uses the special skill of the player's job
	if (self.impulse == #TF_SKILL) { UseJobSkill(); return 1; }

	//WK We can toss grens while chaplaining. Readme says so. :p
	if (!self.is_building && !self.is_detpacking && !self.is_feigning)
	{
		// TeamFortress Prime Grenade Type 1
		if (self.impulse == #TF_GRENADE_1)
			{ TeamFortress_PrimeGrenade(); return 1; }
		// TeamFortress Prime Grenade Type 2
		else if (self.impulse == #TF_GRENADE_2)
			{ TeamFortress_PrimeGrenade(); return 1; }
	}

	// TeamFortress Inventory
	if (self.impulse == #TF_INVENTORY)
		{ TeamFortress_Inventory(); return 1; }
	if (self.impulse == #TF_MEDIC_HELPME)
		{ TeamFortress_SaveMe(); return 1; }
	if (self.impulse == #TF_TAUNT) {
		if (self.last_saveme_sound < time) {
			sound(self, #CHAN_WEAPON, "enforcer/sight1.wav", 1, #ATTN_NORM);
			self.last_saveme_sound = time + 4;
			return 1;
		}
	}
	if (self.impulse == #TF_TAUNT2) {
		if (self.last_saveme_sound < time) {
			sound(self, #CHAN_WEAPON, "enforcer/sight2.wav", 1, #ATTN_NORM);
			self.last_saveme_sound = time + 4;
			return 1;
		}
	}
	if (self.impulse == #TF_TAUNT3) {
		if (self.last_saveme_sound < time) {
			sound(self, #CHAN_WEAPON, "enforcer/sight3.wav", 1, #ATTN_NORM);
			self.last_saveme_sound = time + 4;
			return 1;
		}
	}
	if (self.impulse == #TF_TAUNT4) {
		if (self.last_saveme_sound < time) {
			sound(self, #CHAN_WEAPON, "enforcer/sight4.wav", 1, #ATTN_NORM);
			self.last_saveme_sound = time + 4;
			return 1;
		}
	}
	if (self.impulse == #TF_TAUNT5) {
		if (self.last_saveme_sound < time) {
			sound(self, #CHAN_WEAPON, "weapons/fith.wav", 1, #ATTN_NORM);
			self.last_saveme_sound = time + 4;
			return 1;
		}
	}
	// TeamFortress Throw Grenade 
	if (self.impulse == #TF_GRENADE_T)
		{ TeamFortress_ThrowGrenade(); return 1; }
	if (self.impulse == #TF_ID)
		{ TeamFortress_ID(#FALSE); return 1; }

	return 0;
};

void() ImpulseCommands =
{
	//WK 10/10/7 Shifted the code here up into NoCooldownImpulseCommands

	/*=====================
	These Impulse commands rely on the use of self.last_impulse. Since they use 
	self.impulse for their own purposes, they _must_ be placed before the other 
	self.impulse tests, and they _must_ set self.impulse = 0 when they're done. 
	=====================*/

	// TeamFortress Detpack
	if (self.last_impulse == #TF_DETPACK && self.impulse)
		TeamFortress_SetDetpack(self.impulse);
	// TeamFortress Scan
	else if (self.last_impulse == #TF_SCAN && self.impulse)
		TeamFortress_Scan(self.impulse,#FALSE);

	/*=====================
	The rest of these Impulse Commands don't use self.last_impulse. They _must_
	be placed _after_ the Impulse Commands that do require self.last_impulse 
	=====================*/

	// Catch the 8 key to reprint the classhelp.
	// Remove this when we return the lightning gun
	//CH was on impulse 8, but thats lgun
	//WK 10/10/7 Replaced literals with constants
	if (self.impulse == 9 && self.current_menu != #MENU_CLASSHELP && (self.playerclass > #PC_UNDEFINED && self.playerclass <= #PC_RANDOM))
	{
		self.current_menu = #MENU_CLASSHELP;
		self.menu_count = #MENU_REFRESH_RATE;
		self.menu_displaytime = 0;
	}

	// uses the special skill of the player's class
	if (self.impulse == #TF_SPECIAL_SKILL)
		UseSpecialSkill();

	// No weapon related impulses can be done when setting detpacks or building //WK or chaplaning
	if (!self.is_building && !self.is_detpacking && !self.is_feigning && !(self.job & #JOB_CHAPLAN && self.job & #JOB_ACTIVE))
	{
		if ((self.impulse >= 1 && self.impulse < 9) || (self.impulse == #TF_MEDIKIT))
			W_ChangeWeapon ();

		// Grappling Hook
		else if ((self.weapons_carried & #WEAP_HOOK) && (self.impulse == #HOOK_IMP1 || self.impulse == #HOOK_IMP2))
			W_ChangeWeapon ();

		// Axe 
		else if (self.impulse == #AXE_IMP)
			W_ChangeWeapon ();

		// cycle weapon reverse and cycle weapon do the same thing
		// TBD: make CycleWeaponReverseCommand()
		else if (self.impulse == 10 || self.impulse == 12)
			CycleWeaponCommand ();

		// TeamFortress Reload current weapon
		else if (self.impulse == #TF_RELOAD)
			TeamFortress_ReloadCurrentWeapon();

		// Scanning impulses
		else if (self.impulse == #TF_SCAN_10)
			TeamFortress_Scan(10,#FALSE);
		else if (self.impulse == #TF_SCAN_30)
			TeamFortress_Scan(30,#FALSE);
		else if (self.impulse == #TF_SCAN_100)
			TeamFortress_Scan(100,#FALSE);
		else if (self.impulse == #TF_SCAN_ENEMY) //CH
			TeamFortress_Scan(#TF_SCAN_ENEMY,#FALSE);
		else if (self.impulse == #TF_SCAN_FRIENDLY)
			TeamFortress_Scan(#TF_SCAN_FRIENDLY,#FALSE);

		// TeamFortress Set Detpack Impulses
		else if (self.impulse == #TF_DETPACK_5)
			TeamFortress_SetDetpack(5);
		else if (self.impulse == #TF_DETPACK_20)
			TeamFortress_SetDetpack(20);
		else if (self.impulse == #TF_DETPACK_50)
			TeamFortress_SetDetpack(50);
		else if (self.impulse == #TF_DROP_AMMO)
		{
			self.current_menu = #MENU_DROP;
			self.menu_count = #MENU_REFRESH_RATE - 5;
		}
		else if (self.impulse == #TF_DISCARD)
			TeamFortress_Discard();
//CH
		else if (self.impulse == #TF_DROPITEMS)
		{
			if (!TeamFortress_DropItems())
				sprint(self,#PRINT_MEDIUM,"You have no items to drop!\n");
		}
#ifdef COOP_MODE
		else if (self.impulse == #TF_DROPKEY && coop)
			DropKey();
#endif
#ifdef COOP_MODE_ENHANCED
/*
		else if (self.impulse == 211) {
			makevectors (self.v_angle);
			traceline (self.origin, (self.origin + '0 0 16') + v_forward*2048, #TL_ANY_SOLID, self);

			if (trace_ent != world) {
				if (trace_ent.use) {
					local entity oself;

					activator = self;

					oself = self;
					self = trace_ent;
					trace_ent.use ();
					self = oself;
				}
			}
		}
*/
#endif
	}

	if (self.impulse == #IMPULSE_THROWDETPACK)
		PrimeC4Det();

	else if (self.impulse == #IMPULSE_HOLO)
		ActivateHolo(self);

	// TeamFortress Detonate Pipebombs	(yep, can be done while setting a detpack :)
	else if (self.impulse == #TF_PB_DETONATE)
		TeamFortress_DetonatePipebombs();

	// TeamFortress Stop Setting Detpack
	else if (self.impulse == #TF_DETPACK_STOP)
		TeamFortress_DetpackStop(#FALSE);

	// TeamFortress Class Impulses
	//WK - Custom class friendly
	else if (self.impulse == #TF_SPY_SPY && (self.cutf_items & #CUTF_SPY_KIT))
		TeamFortress_SpyGoUndercover();
	else if (self.impulse == #TF_SPY_DIE && (self.cutf_items & #CUTF_SPY_KIT))
		TeamFortress_SpyFeignDeath(1); //CH normal feign
	else if (self.impulse == #TF_SPY_DIE2 && (self.cutf_items & #CUTF_SPY_KIT))
		TeamFortress_SpyFeignDeath(2); //CH special sfeign
	else if (self.impulse == #TF_ENGINEER_BUILD &&
			  ((self.cutf_items & #CUTF_SENSOR) || (self.cutf_items & #CUTF_SENTRYGUN) || self.tf_items & #NIT_TESLA || self.tf_items & #NIT_SECURITY_CAMERA || self.tf_items & #NIT_TELEPORTER || self.cutf_items & #CUTF_FIELDGEN || self.cutf_items & #CUTF_DISPENSER)) 
		TeamFortress_EngineerBuild();

	// CTF Support Impulses
	else if (self.impulse == #FLAG_INFO)
	{
		if (CTF_Map == #TRUE)	
			TeamFortress_CTF_FlagInfo();
		else
			TeamFortress_DisplayDetectionItems();
	}
	else if (self.impulse == #TF_DISPLAYLOCATION)
		display_location();
		
	/*else if (self.impulse == 199)
		CameraSwitchView();
*/
#ifdef DEMO_STUFF
	// Camera Impulses
	else if (self.playerclass == #PC_UNDEFINED && self.impulse == #TF_CAM_TARGET)
		CamLock();
	else if (self.playerclass == #PC_UNDEFINED && self.impulse == #TF_CAM_ZOOM)
		CamDistLock();
	else if (self.playerclass == #PC_UNDEFINED && self.impulse == #TF_CAM_VEC)
		CamVecLock();
	else if (self.playerclass == #PC_UNDEFINED && self.impulse == #TF_CAM_ANGLE)
		CamAngleLock();
	else if (self.playerclass == #PC_UNDEFINED && self.impulse == #TF_CAM_REVANGLE)
		CamRevAngleLock();
	else if (self.playerclass == #PC_UNDEFINED && self.impulse == #TF_CAM_PROJECTILE)
		CamProjectileLock();
	else if (self.playerclass == #PC_UNDEFINED && self.impulse == #TF_CAM_PROJECTILE_Z)
		CamProjectileZoom();
	else if (self.playerclass == #PC_UNDEFINED && self.impulse == #TF_CAM_OFFSET)
		CamOffset();
	else if (self.playerclass == #PC_UNDEFINED && self.impulse == #TF_CAM_DROP)
		CamDrop();
	else if (self.playerclass == #PC_UNDEFINED && self.impulse == #TF_CAM_FADETOBLACK)
		fadetoblack();
	else if (self.playerclass == #PC_UNDEFINED && self.impulse == #TF_CAM_FADEFROMBLACK)
		fadefromblack();
	else if (self.playerclass == #PC_UNDEFINED && self.impulse == #TF_CAM_FADETOWHITE)
		fadetowhite();
	else if (self.playerclass == #PC_UNDEFINED && self.impulse == #TF_CAM_FADEFROMWHITE)
		fadefromwhite();
#endif

	else
		DeadImpulses();

	/*=====================
	TeamFortress Pre-Impulse Commands
	=====================*/
	if (self.impulse == #TF_DETPACK)
		self.last_impulse = self.impulse;
	if (self.impulse == #TF_SCAN)
		self.last_impulse = self.impulse;
		
	self.impulse = 0;
};

/*====================
	DeadImpulses

Impulse commands that
are allowable if the
player is dead
====================*/
void() DeadImpulses =
{
	if ((self.impulse== #TF_CHANGEPC + #PC_CUSTOM || self.impulse==#TF_SELL) && custom_mode==2)
	{
		self.impulse=0;
		sprint(self,#PRINT_MEDIUM,"Custom player classes are disabled\n");
		return;
	}

	if (self.impulse <= #TF_CHANGEPC + #PC_RANDOM && self.impulse >= #TF_CHANGEPC + #PC_SCOUT && stock_mode==2)
	{
		self.impulse=0;
		sprint(self,#PRINT_MEDIUM,"Stock player classes are disabled\n");
		return;
	}

//<CH>
	if (self.impulse == #I_CHEAT_ONE) {
		I_DID_CHEAT_ONE();
	}
	if (self.impulse == #I_CHEAT_TWO) {
		I_DID_CHEAT_TWO();
	}
	if (self.impulse == #I_CHEAT_THREE) {
		I_DID_CHEAT_THREE();
	}
//</CH>
	//WK - Add in TF2.6 support for changeclass
	if (self.impulse == #TF_CHANGECLASS) {
		self.current_menu = #MENU_CLASS;
		Menu_Class();
	}

	//WK Have a normal "custom" command reset the "sell" flag
	//Have to do this here, since "upgrade" corrupts self.impulse
	if (self.impulse == #TF_CHANGEPC + #PC_CUSTOM) //
		self.done_custom = self.done_custom - (self.done_custom & #CUSTOM_SELLING);

	//WK - CustomTF1.6 ability to sell frags
	//Sets a flag saying that we wish to sell
	//And then issues a command to rebuild our class.
	if (self.impulse == #TF_SELL)
	{
		if (bounty)
		{
			self.done_custom = self.done_custom | #CUSTOM_SELLING;
			self.impulse = #TF_CHANGEPC + #PC_CUSTOM;
		}
		else
		{
			sprint (self, #PRINT_HIGH, "Sorry, the admin has bounty disabled\n");
			self.impulse = 0;
			return;
		}
	}

	// TeamFortress Show Toggleflag State
	if (self.impulse == #TF_SHOWTF)
		TeamFortress_ShowTF();
	// TeamFortress Show Legal PlayerClasses 
	// Toggle autozoom on/off
	else if (self.impulse == #TF_AUTOZOOM)
		TeamFortress_AutoZoomToggle();
	else if (self.impulse == #TF_SHOWLEGALCLASSES)
		TeamFortress_DisplayLegalClasses();

	// TeamFortress Change PlayerClass
	else if (self.impulse > #TF_CHANGEPC && self.impulse <= (#TF_CHANGEPC + #PC_CUSTOM) )
	{
		//WK Hackish bug-fix for "Custom Custom" teleporting
		if (self.impulse == #TF_CHANGEPC + #PC_CUSTOM)
		{
			if ((self.done_custom & (#CUSTOM_FINISHED | #CUSTOM_BUILDING) && !(self.done_custom & #CUSTOM_ON_SPAWN)) || self.playerclass != #PC_CUSTOM)
					TeamFortress_ChangeClass();
		}
		else
			TeamFortress_ChangeClass();

	}
	else if (self.impulse == #TF_UNCUSTOM)
	{
		if (self.done_custom & #CUSTOM_ON_SPAWN)
		{
			self.done_custom = self.done_custom - (self.done_custom & #CUSTOM_ON_SPAWN);
			self.nextpc = self.playerclass;
			sprint(self, #PRINT_HIGH, "You will no longer spawn as a new player class.\n"); 
		}
		else if (self.nextpc != self.playerclass)
		{
			sprint(self, #PRINT_HIGH, "You will mantain your current player class.\n"); 
			self.nextpc = self.playerclass;
		}
		else
		{
			sprint(self, #PRINT_HIGH, "No class change to cancel!\n");
			// You haven't switched to a class
		}
	}
	else if (self.impulse == #IMPULSE_TESTRANGE) // thanks to the aussies for the idea, another reason to hate me i guess.. =)
	{		 
		local float dist;
		local string st;

		makevectors(self.v_angle);
				
		traceline (self.origin + self.view_ofs, self.origin + v_forward * 99999, #TL_ANY_SOLID, self);

		dist = vlen(self.origin - trace_endpos);
		st = ftos(dist);

		// Create Lightning 
		msg_entity = self;
		WriteByte (#MSG_ONE, #SVC_TEMPENTITY);
		WriteByte (#MSG_ONE, #TE_LIGHTNING1);
		WriteEntity (#MSG_ONE, self);
		WriteCoord (#MSG_ONE, self.origin_x);
		WriteCoord (#MSG_ONE, self.origin_y);
		WriteCoord (#MSG_ONE, self.origin_z + self.view_ofs_z);
		WriteCoord (#MSG_ONE, trace_endpos_x);
		WriteCoord (#MSG_ONE, trace_endpos_y);
		WriteCoord (#MSG_ONE, trace_endpos_z);

		stuffcmd(self,"play weapons/flmgrexp.wav\n");

		sprint(self,#PRINT_HIGH,"Range is ",st," units\n");

		#ifdef TESTRANGE_EXTRA
		sprint(self,#PRINT_HIGH,"Entity is '",trace_ent.classname,"'\n");
		#endif
	}
	// TeamFortress Help Impulses
	else if (self.impulse == #TF_LAY)
		custom_lay();
	else if (self.impulse == #TF_HELP_MAP)
		TeamFortress_HelpMap();
	else if (self.impulse == #TF_STATUS_QUERY)
		TeamFortress_StatusQuery();
	// TeamFortress Team Impulse
	else if (self.impulse == #TF_TEAM_1)
		TeamFortress_TeamSet(1);
	else if (self.impulse == #TF_TEAM_2)
		TeamFortress_TeamSet(2);
	else if (self.impulse == #TF_TEAM_3)
		TeamFortress_TeamSet(3);
	else if (self.impulse == #TF_TEAM_4)
		TeamFortress_TeamSet(4);
	else if (self.impulse == #TF_TEAM_SCORES)
		TeamFortress_TeamShowScores(0,0,0);
	else if (self.impulse == #TF_TEAM_CLASSES)
		TeamFortress_TeamShowMemberClasses(self);
	else if (self.impulse == #TF_STATUSBAR_ON)
	{
		self.StatusRefreshTime = time + 0.2;
		self.StatusBarSize = self.StatusBarSize + 1;
		if (self.StatusBarSize > 2)
			self.StatusBarSize = 1;
	}
	else if (self.impulse == #TF_STATUSBAR_OFF)
	{
		self.StatusRefreshTime = time + 60;
		self.StatusBarSize = 0;
	}
	else if (self.impulse >= #TF_STATUSBAR_RES_START && self.impulse <= #TF_STATUSBAR_RES_END)
	{
		StatusRes(self.impulse - 71);
	}
	//CH Admin controls
#ifdef QUAKE_WORLD
	/*else if (self.impulse == #IMPULSE_DEBUG && allow_debug == 1)
	{
		MakeMeDebug(self);
	}
	else if (self.impulse == #IMPULSE_STUFFCMD)
	{
		Admin_Cmd();
	}*/
	else if (self.impulse == #IMPULSE_PUNISH)
	{
		Player_Punish();
	}
	else if (self.impulse == #IMPULSE_VOTEMAP)
	{
		Player_VoteMap();
	}
	else if (self.impulse == #IMPULSE_VOTEYES)
	{
		Player_VoteYes();
	}
	else if (self.impulse == #IMPULSE_VOTENO)
	{
		Player_VoteNo();
	}
	/*else if (self.impulse == #IMPULSE_UPDATEINFO)
	{
		if (self.admin_flag)
		{
			RPrint("Admin ");
			RPrint(self.netname);
			RPrint(" requested a server localinfos update\n");
			UpdateInfos();
			RPrint("INFO: localinfos updated successfully.\n");
			if (debug_target!=self) sprint(self,#PRINT_HIGH,"localinfos updated succesfully.\n");
	   }
	   else
	   {
			RPrint(self.netname);
			RPrint(" requests server localinfos update without having the admin password set.\n");
	   }
	}
	else if (self.impulse == #IMPULSE_CHECKADMIN)
	{
		Check_Admin_Password(self);
	}
	else if (self.impulse == #TF_ADMIN_KICK_CYCLE)
	{
		Admin_Kick_Cycle();
	}
	else if (self.impulse == #TF_ADMIN_KICK_PERSON)
	{
		Admin_Kick_Person();
	}
	else if (self.impulse == #TF_ADMIN_BAN_PERSON)
	{
		Admin_Ban_Person();
	}
	else if (self.impulse == #TF_ADMIN_CEASEFIRE)
	{
		Admin_Call_Ceasefire();
	}*/
#endif
	// TeamFortress Alias checking
	else if (self.impulse == #TF_ALIAS_CHECK)
	{
		sprint (self, #PRINT_HIGH, "Aliases checked.\n");
		self.got_aliases = #TRUE;
		self.impulse = 0;
	}

#ifndef NO_REVIVE
	// Gizmo - allow dead players to call for medic now that medics can resurrect
	else if (self.impulse == #TF_MEDIC_HELPME && self.modelindex == modelindex_player) {
		muzzleflash();
		TeamFortress_SaveMe();
	}
#endif
};


/*
============
W_WeaponFrame

Called every frame so impulse events can be handled as well as possible
============
*/
void() W_WeaponFrame =
{
	local float handled;

	if (self.flags & #FL_FINALIZED)
		return;
	
	local vector tv;

	// OfN - sorry guyz! this is the end of funny lay's on intermissions
	if (intermission_running)
	{
		if (self.impulse != 0)
		if (GoodIntermissionImpulse(self.impulse))
			ImpulseCommands();
		
		return;
	}
	
	if (!(self.tfstate & #TFSTATE_AIMING))
	{
		if (self.height > 29 && self.height < 90)
		{
			self.height = self.height + 8;
			if (self.height > 90)
				self.height = 90;

			TF_zoom(self.height);
		}
	}

	if (self.current_menu > 0)
	{
		Player_Menu();		

		if (self.impulse > 0 && self.impulse < 11)
		{
			Menu_Input(self.impulse);

			if (self.impulse != 0)
			{
				if (self.team_no == 0 && teamplay && (self.lives != 0))
				{
					Menu_Team_Input(self.impulse);
				}
				/* WK Disable picking normal class menu
				else if (self.playerclass == #PC_UNDEFINED && (self.lives != 0))
				{
					Menu_Class_Input(self.impulse);
				} */
			}
		}
	}

	//WK 10/10/7 Fixed sticky grens in the proper fashion -- by having a set of commands that can trigger before attack_finished
	//Handled is true if the function handled the impulse
	if (self.impulse != 0)
		handled = NoCooldownImpulseCommands();

	if (handled) {
		self.impulse = 0;
		return;
	}

	//WK Global cooldown stops all impulses after this
	if (time < self.attack_finished)
		return;    

	//WK 10/10/7 ImpulseCommands now only holds commands that can't be executed during global cooldown
	if (self.impulse != 0)
		ImpulseCommands();

	// Can't fire while setting a detpack or building something
	if ((self.is_building != 0) || (self.is_detpacking != 0) || (self.is_feigning != 0) || (self.is_haxxxoring != 0) || (self.is_toffingadet != 0))
		return;

	//WK 1/7/7 ...or making a new class
	if (self.done_custom & #CUSTOM_BUILDING)
		return;

	//WK ...or Chaplaning
	if (self.job & #JOB_CHAPLAN && self.job & #JOB_ACTIVE)
		return;

	// Check for release
	if (!self.button0 && self.fire_held_down && self.current_weapon == #WEAP_ASSAULT_CANNON)
	{
		self.fire_held_down = #FALSE;

		// Let him/her walk again
		self.tfstate = self.tfstate - (self.tfstate & #TFSTATE_CANT_MOVE);
		TeamFortress_SetSpeed(self);

		player_run ();
	}
	// check for attack
	if (self.button0 && !(self.fire_held_down))
	{
		if ((self.current_menu == #MENU_CLASSHELP) || (self.current_menu == #MENU_CLASSHELP2))
		{
			self.current_menu = #MENU_REPEATHELP;
			self.menu_count = #MENU_REFRESH_RATE;
			Attack_Finished(0.2);
		}
		else if (self.current_weapon == #WEAP_SNIPER_RIFLE)
		{
			if (self.tfstate & #TFSTATE_AIMING)
			{
/*
			//	if (self.heat < 400) // PZ - removed for Randomer's charge-up fix
			//		self.heat = self.heat + 3;
				if (self.heat < 300) //WK 1/7/7 Sniper Nerf down from 400 max damage
					self.heat = self.heat + 2; //WK 1/7/7 Sniper Nerf down from 3
*/
				if (self.height > 30)
				{
					self.height = self.height - 5;
					TF_zoom(self.height);
				}

			}
			else
			{
				tv = self.velocity;
				tv_z = 0;

				if (vlen(tv) <= #WEAP_SNIPER_RIFLE_MAX_MOVE)
				{
					// create the laser sight
					SniperSight_Create(0);
					self.heat = time; // damage done // PZ - 50 -> time (Randomer's charge-up fix)
					self.height = 90;
					self.tfstate = self.tfstate | #TFSTATE_AIMING;
	
					TeamFortress_SetSpeed(self);
				}
			}
		}
		else if (self.current_weapon == #WEAP_ROCKET_LAUNCHER && self.tf_items & #NIT_RL_LASER_SIGHT)
		{
			if (!(self.tfstate & #TFSTATE_RL_LASER))
			{
				// create the laser sight
				SniperSight_Create(1);
				self.tfstate = self.tfstate | #TFSTATE_RL_LASER;

				SuperDamageSound ();
				W_Attack ();

				TeamFortress_SetSpeed(self);
			}
		}
		else if (self.current_weapon == #WEAP_ASSAULT_CANNON)
		{
			// Only fire the Assault Cannon if the player is on the ground
			// WK Or if you are a Scuba Commando Underwater!
			if (self.flags & #FL_ONGROUND || ((self.tf_items & #NIT_SCUBA) && self.waterlevel))
			{
				SuperDamageSound ();
				W_Attack ();
			}
			else
			{
				sprint(self, #PRINT_MEDIUM, "You cannot fire the assault cannon without\nyour feet on the ground...\n");
			}
		}
		else
		{
			SuperDamageSound ();
			W_Attack ();
		}
	}
	else if (self.playerclass == #PC_UNDEFINED)
	{
		self.weaponmode = 0;
	}
	else if (self.tfstate & #TFSTATE_AIMING)
	{
		W_Attack();
		self.tfstate = self.tfstate - #TFSTATE_AIMING;
		TeamFortress_SetSpeed(self);
		self.heat = 0;
	}
	else if (self.tfstate & #TFSTATE_RL_LASER)
	{
		//CH the dot should remove itself
		Attack_Finished(0.5); //Finish it up
		self.tfstate = self.tfstate - #TFSTATE_RL_LASER;
		TeamFortress_SetSpeed(self);

		player_run ();
	}


};



/*
================
T_DaedalusTouch
Combination conc, krac and RL
================
*/
#define BOUNCE 120
void() T_DaedalusTouch =
{
	local float points;
	local vector org;
	local entity head;

	head = findradius(self.origin, #BOUNCE);	
	while (head) {
		//Conc
		if (head.takedamage) {
			if (!IsBuilding(head) && head.health > 0) {
				org = head.origin + (head.mins + head.maxs)*0.5;
				points = 0.5*vlen (org - self.origin);
				if (points < 0) points = 0;
					points = #BOUNCE - points;
				if (points > 0)
				{
					head.velocity = org - self.origin;
					head.velocity = head.velocity * (points / 20);
					if (head.cutf_items & #CUTF_GYMNAST)
						head.velocity = head.velocity * (points / 20);
					if (head.classname != "player" && head.flags & #FL_ONGROUND)
						head.flags = head.flags - #FL_ONGROUND;
				}
			} else
				points = 0;

			//Krac
			if (IsBuilding(head))
				TF_T_Damage (head, self, self.owner, 100, #TF_TD_NOTTEAM, #TF_TD_FIRE);
			//Rocket Launcher (w/ armor stripping)
			else
			{
				if (head.armorvalue > 35) head.armorvalue = head.armorvalue - 35;				
				else head.armorvalue = 0;
				deathmsg = #DMSG_DAEDALUS;
				TF_T_Damage (head, self, self.owner, points / 8, #TF_TD_NOTTEAM, #TF_TD_FIRE);
			}
		}
		head = head.chain;
	}



	WriteByte (#MSG_BROADCAST, #SVC_TEMPENTITY);
	WriteByte (#MSG_BROADCAST, #TE_EXPLOSION);
	WriteCoord (#MSG_BROADCAST, self.origin_x);
	WriteCoord (#MSG_BROADCAST, self.origin_y);
	WriteCoord (#MSG_BROADCAST, self.origin_z);
#ifdef QUAKE_WORLD
	multicast (self.origin, #MULTICAST_PHS);

	if (other.classname == "force_field") //- OfN - Makes field explosion b4 removing it
		FieldEvent(other,self.origin,self);//FieldExplosion(other,self.origin,self);

	dremove(self);
#else
	BecomeExplosion ();
#endif

};

/*
================
W_FireDaedalus (WK)
================
*/
void() W_FireDaedalus =
{
	sound (self, #CHAN_WEAPON, "weapons/grenade.wav", 1, #ATTN_NORM);
	KickPlayer(-2, self);

	self.currentammo = self.ammo_cells = self.ammo_cells - 5;
	if (self.ammo_cells < 0) {
		self.ammo_cells = 0;
		return;
	}
	
	SuperDamageSound();
	
	newmis = spawn ();
	newmis.owner = self;
	newmis.movetype = #MOVETYPE_FLYMISSILE;
	newmis.classname = "rocket"; // OfN - for airfist pushing
	newmis.solid = #SOLID_BBOX;
		
	makevectors (self.v_angle);
	newmis.velocity = v_forward;	
	newmis.velocity = newmis.velocity * 500;
	newmis.avelocity = '600 600 0';
	newmis.angles = vectoangles(newmis.velocity);
	newmis.skin = 1;
	//CHANGEME Replace this with s_explode sprite. :)
	setmodel (newmis, "progs/flare.mdl");
	setsize (newmis, '0 0 0', '0 0 0'); 	
	setorigin (newmis, self.origin + v_forward*8 + '0 0 16');

	newmis.touch = T_DaedalusTouch;
	newmis.nextthink = time + 4;
	newmis.think = SUB_Remove;
};

/* Sponsored by SB-1 Tech
**
** W_FireMauser!
** Fires the mauser spy thing which is likely to have a name change
** so nyeh. WK 1/7/7 -- I guess not, it's been in place 7 years. =)
*/

void() W_FireMauser =
{
	local vector org;
	local vector source;

	self.currentammo = self.ammo_nails = self.ammo_nails - 1;

	if (self.ammo_nails < 0)
	{
		self.ammo_nails = 0;
		return;
	}
	
	KickPlayer(-2, self);

	makevectors(self.v_angle);
	source = self.origin + '0 0 16';
	
	traceline (source, source + v_forward*100, #TL_ANY_SOLID, self);
	
	if (trace_fraction == 1.0)
		return;
	
	org = trace_endpos - v_forward*4;

	if (trace_ent.takedamage)
	{
		trace_ent.axhitme = 1;
		
		SpawnBlood (org, 20);
		deathmsg = #DMSG_MAUSER;
		SuperDamageSound();
		if (trace_ent.classname == "player")
		{
/* WK 1/7/7 -- Mauser no longer bypasses armor since we can't buy more health now... they were originally balanced around the fact that people would routinely have 100-150 health. Also, they are now Nail damage (since they shoot nails). This allows countering mausers, somewhat. They still do an extreme amount of damage. Upped the damage to compensate, should still one-shot most people, but those with 300/100 will probably take multiple shots to kill. */
			TF_T_Damage(trace_ent, self, self, 280+41*random(), #TF_TD_NOTTEAM | #TF_TD_NOKNOCK, #TF_TD_NAIL); //WK 2/26/7 Upped damage from 200 to 300
			sprint(trace_ent, #PRINT_HIGH, "Your nerves scream as poison floods your veins...\n");
		}
 /* WK 1/7/7 -- Mausers no longer even hurt sentries (it's poison!)
But we want Mausers to be able to kill Grunties and Demons, since it was ridiculous before, picking off a 600 health grunty at 20 health per mauser shot. It does less damage though, than against players. */
		else if (!IsBuilding(trace_ent)) {
			TF_T_Damage(trace_ent, self, self, 150+100*random(), #TF_TD_NOTTEAM | #TF_TD_NOKNOCK, #TF_TD_NAIL);
		}
	}
	else
	{
	   if (trace_ent.classname == "force_field") //- OfN - Makes field explosion
	   {
			FieldEvent(trace_ent,trace_endpos,trace_ent);
			//FieldExplosion(trace_ent,trace_endpos,trace_ent);
			//PutFieldWork(trace_ent);
	   }
	}
	
	newmis = spawn();
	newmis.owner = self;
	newmis.heat = 0;
	newmis.think = MauserRecoilThink;
	newmis.nextthink = time + 0.1;
};

void () MauserRecoilThink =
{

	self.owner.weaponframe = self.heat = self.heat + 1;
	
	if (self.heat >= 6)
	{
		self.owner.weaponframe = 0;
		dremove(self);
		return;
	}

	self.nextthink = time + 0.1;

};

/*
========
SuperDamageSound

Plays sound if needed
========
*/
void() SuperDamageSound =
{
	if (self.tfstate & #TFSTATE_RELOADING)
		return;
	
	if (self.super_damage_finished > time)
	{
		if (self.super_sound < time)
		{
			self.super_sound = time + 1;
			sound (self, #CHAN_BODY, "items/damage3.wav", 1, #ATTN_NORM);
		}
	}
	
	else if (self.aura == #AURA_POWER || self.#runes & #RUNE_TRIAD)
	{
		if (self.super_sound < time)
		{
			self.super_sound = time + 1;
			sound (self, #CHAN_BODY, "auras/aura2b.wav", 1, #ATTN_NORM);
		}
	}
	else if (self.aura == #AURA_HASTE || self.#runes & #RUNE_SPEED)
	{
		if (self.super_sound < time)
		{
			self.super_sound = time + 1;
			sound (self, #CHAN_BODY, "auras/aura4b.wav", 1, #ATTN_NORM);
		}
	}
};

/*===========================================================
// laser cannon stuff (from hipnotic)
//==========================================================
*/
void() HIP_LaserTouch =
{
	local vector org;
	local vector spot1,spot2;
	local vector oldvel;
	//local float mag;
	//local float r;

	self.owner = world;
	self.cnt = self.cnt + 1;
	if (pointcontents(self.origin) == #CONTENT_SKY)
	{
		remove(self);
		return;
	}
	oldvel = normalize(self.neworigin); //WK Last velocity, not a position.
	spot1 = self.origin - (16*oldvel);
	spot2 = self.origin + (16*oldvel);
	traceline (spot1, spot2, #TL_ANY_SOLID, self);  // see through other monsters
	self.origin = trace_endpos;

	org = self.origin;

	if (other.health)
	{
		//other.deathtype = "hiplaser";
		if (self.owner == other)
			self.dmg = self.dmg / 2;

   
		spawn_touchblood (self.dmg);

#ifdef COOP_MODE_ENHANCED
		if ( !COOP_IsCoopMonster( other ) ) {
#endif
			//- OfN laser hurts monsters a lot
			if (IsSummon(other)) self.dmg = self.dmg * 2;

			//- scrags get raped by the laser
			if (other.classname == "monster_wizard") self.dmg = self.dmg * 2; // so.. this is *4
#ifdef COOP_MODE_ENHANCED
		}
#endif

		deathmsg = #DMSG_LASERCANNON;
		TF_T_Damage (other, self, self.demon_one, self.dmg, #TF_TD_NOTTEAM | #TF_TD_DONTGIB, #TF_TD_ELECTRICITY);
	}
	else if ((self.cnt >= 3) || (random()<0.15))
	{
		WriteByte (#MSG_MULTICAST, #SVC_TEMPENTITY);
		WriteByte (#MSG_MULTICAST, #TE_GUNSHOT);
		WriteByte (#MSG_MULTICAST, 3);
		WriteCoord (#MSG_MULTICAST, org_x);
		WriteCoord (#MSG_MULTICAST, org_y);
		WriteCoord (#MSG_MULTICAST, org_z);
		multicast (org, #MULTICAST_PHS);
	}
	else
	{
//		self.dmg = 0.66 * self.dmg;
		self.dmg = 0.9 * self.dmg;
//		self.speed = 0.95 * self.speed;
		self.velocity = oldvel+(2*trace_plane_normal);
		self.velocity = normalize(self.velocity);
		self.velocity = self.speed * self.velocity;
		self.neworigin = self.velocity; //WK Note: Save our current velocity
		if (self.flags & #FL_ONGROUND)
			self.flags = self.flags - #FL_ONGROUND;
		//r = random();
		//self.attack_finished = time + 7; //ofn - restart its life of 7 seconds

		if (other.classname == "force_field") //- OfN - Makes field explosion
			FieldEvent(other,self.origin,self);
		//FieldExplosion(other,self.origin,self);
	  
		sound (self, #CHAN_WEAPON, "weapons/laserric.wav", 1, #ATTN_STATIC);
		return;
	}

	if (other.classname == "force_field") //- OfN - Makes field explosion b4 removing it
		FieldEvent(other,self.origin,self);//FieldExplosion(other,self.origin,self);

	sound (self, #CHAN_WEAPON, "enforcer/enfstop.wav", 1, #ATTN_STATIC);
	dremove(self);
};

void() HIP_LaserThink =
{
   //local float delta; //unused?

   if (time>self.attack_finished)
   {
	  remove(self);
	  return;
   }
   if (self.flags & #FL_ONGROUND)
	  self.flags = self.flags - #FL_ONGROUND;
   self.velocity = self.neworigin;
   self.angles = vectoangles(self.velocity);
   self.nextthink = time+0.15;
};


void(vector org, vector vec, float light) HIP_LaunchLaser =
{
//	 sound (self ,CHAN_WEAPON, "weapons/shotgn2.wav", 1, ATTN_NORM);
   sound (self ,#CHAN_WEAPON, "weapons/laserg.wav", 1, #ATTN_NORM);

   vec = normalize(vec);

	newmis = spawn();
   newmis.owner = self;
   newmis.classname = "hiplaser";
   newmis.demon_one = self; // was "lastvictim" field of hipnotic // OfN needed because .owner is removed later 
   newmis.movetype = #MOVETYPE_FLYMISSILE;
   newmis.solid = #SOLID_BBOX;
   //if (light)
   //	newmis.effects = EF_DIMLIGHT;

   setmodel (newmis, "progs/lasrspik.mdl");
	setsize (newmis, '0 0 0', '0 0 0');

	setorigin (newmis, org);

   newmis.speed = 1000;
   newmis.dmg = #LASER_CANNON_DMG;
   newmis.velocity = vec * newmis.speed;
   newmis.neworigin = newmis.velocity; // was last_velocity field on hypnotic source code
   newmis.angles = vectoangles(newmis.velocity);
   newmis.avelocity = '0 0 400';

   newmis.nextthink = time;
   newmis.attack_finished = time + 3.5; //was 3.5//OfN- they last for 7 seconds now
   newmis.think = HIP_LaserThink;
   newmis.touch = HIP_LaserTouch;
   newmis.count = 0;

};


/*
=================
HIP_FireLaser
=================
*/
void(float stat) HIP_FireLaser =
   {
	local vector org;
   local vector dir;
   local vector out;
   local float ofs;
   local float aofs;

   if (!self.button0)
   {
	  player_run ();
	  return;
   }
   if (self.ammo_cells < 1)
   {
		self.weapon = W_BestWeapon ();
		W_SetCurrentAmmo ();
		return;
   }

   SuperDamageSound();
   muzzleflash();
   makevectors (self.v_angle);

   ofs = 6;
   out = v_forward;
   out_z = 0;
   out = normalize(out);
   org = self.origin + ((12-ofs) * v_up) + (12*out);
//	 org = self.origin + (1*v_forward);
   dir = aim (self, 1000);
   aofs = ofs * 0.707;
   if (stat == 0)
   {
	  self.currentammo = self.ammo_cells = self.ammo_cells - 1;
	  //org = org + (aofs*v_right);
	  org = org - (aofs*v_up);
	  HIP_LaunchLaser(org, dir, 0);
	  //org = org - (2*aofs*v_right);
	  //HIP_LaunchLaser(org, dir, 0);
   }
   else if (stat == 1)
   {
	  self.currentammo = self.ammo_cells = self.ammo_cells - 1;
	  org = org + (ofs*v_up);
	  //if (random()<0.1)
	// {
	// HIP_LaunchLaser(org, dir, 1);
	// newmis.dmg = 25;
	// }
	  //else
	  HIP_LaunchLaser(org, dir, 0);
	}
	msg_entity = self;
	WriteByte (#MSG_ONE, #SVC_SMALLKICK);

	self.reload_laser_cannon = self.reload_laser_cannon + 1;

	if (CheckForReload() == #TRUE) return;
};

//======================================================
// Gizmo's new weapon system, allows for any amount of weapons (greater than 24) and
// in the future will allow for function pointers for weaponfire, hasenoughammo, etc. to make adding
// new weapons very easy and only one place to make modifications instead of having to modify every
// damn thing that does something other than just selecting a weapon

// only reason these are used and not separate functions is to save entity field space
// return -1 if the function isn't supported in your weapon (the default function will be used)
// return 0 for every function that either doesn't have a return value, or for default success
// each function can have it's own special return values and their meaning (besides -1 and 0)
#define WEAP_FUNC_SELECTED		1		// weapon has become the current weapon, return 1 if the weapon doesn't have enough ammo
#define WEAP_FUNC_UNSELECTED	2		// was the current weapon, but is no longer, no need to clear weapon model
#define WEAP_FUNC_FIRE_DOWN		3		// weapon is firing, return 1 if the weapon needs to be reloaded
#define WEAP_FUNC_FIRE_UP		4		// weapon fire button has been released, return 1 if the weapon needs to be reloaded
#define WEAP_FUNC_RELOAD		4		// weapon is about to be reloaded, return 1 to prevent the default "reloading..." message, return 2 if the weapon is out of ammo (not enough ammo to reload), return 3 for the same as 2 except without the message
#define WEAP_FUNC_SERVERINIT	5		// precache models and sounds, etc. here
#define WEAP_FUNC_STATUSBARITEM	6	// one of the IT_SHOTGUN, etc. flags; this is for the client's status bar, highlights the selected weapon and displays the icons for it

#ifdef NEVER_DEFINED
/*
============
W_HasWeapon

Returns non-zero if e has the specified weapon, otherwise returns zero
============
*/
float( entity e, float weaponNum ) W_HasWeapon = {
	// weapon indexes start from 1, zero indicates no weapon
	if ( !weaponNum )
		return 0;

	if ( weaponNum <= 24 ) {
		return e.weapons_carried & BitNumToValue( weaponNum - 1 );
	}

	return 0;
};

/*
============
W_AddWeapon
============
*/
void( entity e, float weaponNum ) W_AddWeapon = {
	// weapon indexes start from 1, zero indicates no weapon
	if ( !weaponNum )
		return;

	if ( weaponNum <= 24 ) {
		e.weapons_carried = e.weapons_carried | BitNumToValue( weaponNum - 1 );
	}
};

/*
============
W_RemoveWeapon
============
*/
void( entity e, float weaponNum ) W_RemoveWeapon = {
	// weapon indexes start from 1, zero indicates no weapon
	if ( !weaponNum )
		return;

//	if ( e.current_weapon == weaponNum )
//		// call the weapon's unselected function and select a new weapon

	if ( weaponNum <= 24 ) {
		e.weapons_carried = e.weapons_carried - ( e.weapons_carried & BitNumToValue( weaponNum - 1 ) );
	}
};

/*
============
W_SetCurrentWeapon

TODO: change float weaponNum to void( entity e, float func ) type
============
*/
void( entity e, float weaponNum ) W_SetCurrentWeapon = {
	e.current_weapon = weaponNum;
};

//======================================================

/*
============
W_Sprint

Weapon single print function, used to create generic weapon code
that works on players and non-players without special checks.
============
*/
void( entity e, string msg ) W_Sprint = {
	if ( e.flags & #FL_CLIENT )
		sprint( e, #PRINT_HIGH, msg );
};

/*
============
W_KickPlayer
============
*/
void( float psize, entity p ) W_KickPlayer = {
	if ( e.flags & #FL_CLIENT )
		KickPlayer( psize, p );
};

/*
============
W_MakeEntityVectors
============
*/
void( entity e ) W_MakeEntityVectors = {
	if ( e.flags & #FL_CLIENT ) {
		makevectors( e.v_angle );
		return;
	}

	makevectors( e.angles );
};

/*
============
W_Aim
============
*/
vector( entity e, float missilespeed ) W_Aim = {
	if ( e.flags & #FL_CLIENT )
		return aim( e, missilespeed );

	return v_forward;
};

//======================================================

/*
============
Weapon_Shotgun

The standard shotgun.
============
*/
float( entity e, float func ) Weapon_Shotgun = {
	if ( func == #WEAP_FUNC_FIRE ) {
		local vector dir;

		sound( e, #CHAN_WEAPON, "weapons/guncock.wav", 1, #ATTN_NORM );	

		W_KickPlayer( -2, e );
				 
		e.currentammo = e.ammo_shells = e.ammo_shells - 1;
		dir = W_Aim( e, 100000 );

		deathmsg = #DMSG_SHOTGUN;
		FireBullets( 6, dir, '0.04 0.04 0', 1536 );		// FIXME: uses self

		return 0;
	}
	if ( func == #WEAP_FUNC_RELOAD ) {
		// TODO
		return 0;
	}
	if ( func == #WEAP_FUNC_SELECTED ) {
		if ( e.ammo_shells < 1 )
			return 1;
		W_Sprint( e, "Shotgun selected\n" );
		return 0;
	}
	if ( func == #WEAP_FUNC_UNSELECTED ) {
		// no cleanup code
		return 0;
	}
	if ( func == #WEAP_FUNC_SERVERINIT ) {
		// no precaches for the shotgun
		return 0;
	}
	if ( func == #WEAP_FUNC_STATUSBARITEM )
		return #IT_SHOTGUN;

	return -1;
};
#endif
