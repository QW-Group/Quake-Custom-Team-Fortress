/*======================================================
	CUSTOM.QC			Custom TeamFortress v3.2	

	(c) William Kerney			5/21/00
========================================================
All the functions pertaining to custom class generation and 
the miscellanious new features of Custom TF
======================================================*/

float(float t1, float t2) Teammate; //KK: are team_no's current teammates
void() DropToCustomClassGen; //Called when starting class generation
void() DropFromCustomClassGen; //Called when finished class generation
void() PrintMoney;
void(float in) PrintRefund;
void(float in) PrintNotEnoughMoney;
void( float type ) BuyHealth;
void(float cost, float type) BuyWeapon;
void(float cost, float type) BuyCuTF;
void(float cost, float type) BuyItem;
void(float cost, float type) BuyJob;
/*void(float cost, float type) BuyGren1;
void(float cost, float type) BuyGren2;*/
void(entity tif, float pain) RevealThief;
void() FragGrenadeTouch;
void() FragGrenadeExplode;
void() KracGrenadeTouch;
void() KracGrenadeExplode; 
void(entity bastard,float threshold) createBastard;
void(entity immuner,float timer) makeImmune;
void() UseJobSkill; //Function for handling professions
void() DetonateAllGuns;
/*void (string temp) DebugSprint;
void (float temp)  DebugSprintFloat;*/
float(entity tester) IsBuilding;
void() autoteam_think;
//Extern
void (vector org, entity death_owner) spawn_tdeath;
//void (string gib, float health) ThrowGib;
void(string gibname, float dm, float makecool, float gibskin, float gibkgs, float randorg) ThrowGib;
void() TeamFortress_SetHealth;
void() TeamFortress_SetEquipment;
float() W_BestWeapon;
void() W_SetCurrentAmmo;
void(entity p) TeamFortress_SetSpeed;
void(entity p) TeamFortress_SetSkin;
void(entity Viewer, float pc) TeamFortress_PrintJobName;
void () BecomeExplosion;
void(entity bomb, entity attacker, float rad, entity ignore) T_RadiusDamage;
void() SUB_regen;
float modelindex_eyes, modelindex_player, modelindex_null;
void(float inAuto) W_FireMedikit;
void(float inAuto) TeamFortress_ID;
void(float range,float inAuto) TeamFortress_Scan;
void() kill_my_demons;
void() player_assaultcannondown1;
void (entity rhook) Reset_Grapple;
void() GuerillaExplode;
void(float krac) TeamFortress_DetpackStop;
void(float all, float teamscored, float scorepoints) TeamFortress_TeamShowScores;
void () execute_changelevel;
void(entity Item, entity AP, float method) tfgoalitem_RemoveFromPlayer;

//- OfN
void(entity mine_owner) DetonateMines; //external, job.qc
string (float tno) TeamGetNiceColor;
void(entity player, float start) SetArmyTimer; 
void() RemoveArmyTimer;
entity() SelectSpawnPoint;
void() CleanUpEverything;
//void(entity tfield, vector where, entity thing) FieldExplosion;
void(entity tfield, vector where, entity thing) FieldEvent;
float(entity player) GiveFreeStuff;

void(entity player, float usage) SetMeatUsage;
void(entity player, float usage) SetHeadsUsage;
void(entity player, float soul) SetCurrentSoul;

void(entity player) PlayerDropRunes;
void(entity player) ResetStripedAndGiven;

//KK: are team_no's current teammates
float(float targteam, float attackteam) Teammate =
{
	local float teammask;

	if ( !targteam ) return #FALSE;
	if ( targteam == attackteam ) return #TRUE;
	if ( number_of_teams < 3 ) return #FALSE;

	if		( targteam == 1 ) teammask = 1;
	else if ( targteam == 2 ) teammask = 2;
	else if ( targteam == 3 ) teammask = 4;
	else if ( targteam == 4 ) teammask = 8;
	else
		teammask = 0;						// Gizmo - only happens if there's a bug

	if		( attackteam == 1 && (friends1_mask & teammask)) return #TRUE;
	else if ( attackteam == 2 && (friends2_mask & teammask)) return #TRUE;
	else if ( attackteam == 3 && (friends3_mask & teammask)) return #TRUE;
	else if ( attackteam == 4 && (friends4_mask & teammask)) return #TRUE;

	return #FALSE;
};

/*
void (string temp) DebugSprint =
{
	sprint(self,#PRINT_HIGH,temp);
	sprint(self,#PRINT_HIGH,"\n");
};

void (float foo)  DebugSprintFloat =
{
	local string temp;
	temp = ftos(foo);
	sprint(self,#PRINT_HIGH,temp);
	sprint(self,#PRINT_HIGH,"\n");
};
*/

/*
==============
BuyStockClassItems

Used to buy all the items of a stock class, if we
have enough money. This way we can start from an
already built class and make a few changes.
==============
*/
void( float stockClass ) BuyStockClassItems = {
	if ( stockClass == #PC_SCOUT ) {
		BuyHealth( 1 );
		if ( self.custom_speed == #CUSTOM_SPEED7 && self.money >= #COST_SPEED1 ) {
			self.money = self.money - #COST_SPEED1;
			self.custom_speed = #CUSTOM_SPEED1; // Original 650
			PrintMoney();
		}
		BuyWeapon( #COST_SHOTGUN, #WEAP_SHOTGUN );
		BuyWeapon( #COST_NAILGUN, #WEAP_NAILGUN );
		BuyWeapon( #COST_AIRF, #WEAP_AIRF );
		BuyGren( #COST_GR_CALTROP, #GR_TYPE_CALTROP );
		BuyGren( #COST_GR_CONCUSSION, #GR_TYPE_CONCUSSION );
		BuyItem( #COST_SECURITYCAMERA, #NIT_SECURITY_CAMERA );
		BuyJob( #COST_THIEF, #JOB_THIEF );
	}
};

void() DropToCustomClassGen =
{
	//local entity te;
	local float sell_no;
	//local string st;
	sell_no = 0;

	self.gravity = 1;
	self.aura = 0;

	//Remove everything he's carrying	
	self.job = 0;
	
	// This is the appropiate place to: (after clearing job due to armytimer stuff weirdness)
	CleanUpEverything();

	ResetStripedAndGiven(self);

	self.is_malfunctioning = 0;
	//self.is_cameraviewing = 0;
#ifdef COOP_MODE_ENHANCED
	if ( !deathmatch )
		self.tf_items = #NIT_AMMO_BANDOLIER;
	else
		self.tf_items = 0;
#else
	self.tf_items = 0;
#endif
#ifdef COOP_MODE_ENHANCED
	if ( !deathmatch )
		self.cutf_items = #CUTF_FULLARMOUR;
	else
		self.cutf_items = 0;
#else
	self.cutf_items = 0;
#endif
	// Gizmo - new item flags
	self.cutf_moreitems = 0;

	self.tf_items_flags = 0;
	self.items = 0;
	self.ammo_rockets = 0;
	self.ammo_nails = 0;
	self.ammo_shells = 0;
	self.ammo_cells = 0;
	self.maxammo_rockets = 10; //Give em a minimal carrying capacity
	self.maxammo_nails = 10;
	self.maxammo_shells = 10;
	self.maxammo_cells = 10;
	self.maxammo_medikit = 0;
	self.maxammo_detpack = 0;
	self.ammo_c4det = 0;
	
	self.demon_one = world; //SB - this tells us who our demon is for easy reference
	self.demon_two = world; //- OfN-  Used for hacker job, target building and for timer (% on sbar)
	self.demon_three = world;

	self.demon_blood = 0;

	self.all_active = 0; // OfN Number of mines set by the player

	self.no_grenades_1 = 0;
	self.no_grenades_2 = 0;
	self.tp_grenades_1 = 0;
	self.tp_grenades_2 = 0;

	self.armor_allowed = 0.3; //Red yellow or green
	self.armorclass = 0; //Red yellow or green
	self.armorvalue = 0; //200 etc
	self.maxarmor = 0;	//200 etc
	self.weapon = 0; // #WEAP_HOOK & #WEAP_SHOTGUN etc
	self.current_weapon = 0; // No current weapon
	
	if ((allow_hook) && (no_grapple != 1)) //If map allows it...
		self.weapons_carried = #WEAP_HOOK; // Start with grapple
	else
		self.weapons_carried = 0; // Or remove everything

	self.weaponmodel = ""; //Remove the model of a weapon in front

	self.solid = #SOLID_NOT;
	self.movetype = #MOVETYPE_NONE;
	self.takedamage = #DAMAGE_NO;

//Ready to buy
	self.maxspeed = 0; //Can't move while buying
	self.max_health = 50;
	self.health = 50;

	GiveFreeStuff(self);

#define PRICE_PER_FRAG 100
#define MAX_FRAGS_TO_SELL 50
//Calculate starting money
//This means the most someone can get is 50*100 = $5000
	if (self.done_custom & #CUSTOM_SELLING)
	{
		if (self.real_frags >= #MAX_FRAGS_TO_SELL)
			sell_no = #MAX_FRAGS_TO_SELL;
		else if (self.real_frags > 0)
			sell_no = self.real_frags;
		else {
			sell_no = 0;
			self.done_custom = self.done_custom - (self.done_custom & #CUSTOM_SELLING);
		}

		self.real_frags = self.real_frags - sell_no;
		self.frags = self.real_frags; //TODO: Make this work with TEAMFRAGS on
		self.money = custom_money + sell_no * #PRICE_PER_FRAG;
	}
	else
		self.money = custom_money;

	self.custom_speed = 250; //HWGUY Speed

	//Overrides the menu handler to always display my menu
	//Hack alert! This preserves the selling flag. :p
	if (self.done_custom & #CUSTOM_SELLING)
		self.done_custom = #CUSTOM_BUILDING | #CUSTOM_SELLING; 
	else
		self.done_custom = #CUSTOM_BUILDING; 
	
	//Destroy Buildings... again. :p
	//DetonateAllGuns();
	

	//And then kill all demons I own
	
	//kill_my_demon();
	//DetonateMines(self);
	//RemoveArmyTimer();

	  self.current_menu = #MENU_PRIMARY_WEAPON;
	  Menu_PrimaryWeapon();
	//return;
};

void(vector org) spawn_tfog;

void() DropFromCustomClassGen =
{
	// OfN
	self.is_killed = #FALSE;

	self.done_custom = #CUSTOM_FINISHED;
	self.maxspeed = self.custom_speed;
	self.gravity = 1;

	if (self.cutf_items & #CUTF_TOSSABLEDET)
		self.maxammo_detpack = 1;

	//Make sure they have at least one axe-like weapon
	if (!(self.weapons_carried & (#WEAP_MEDIKIT | #WEAP_SPANNER)) || (self.cutf_items & #CUTF_KNIFE))
		self.weapons_carried = self.weapons_carried | #WEAP_AXE;

	//CH if you bought Guerilla, you get 20 rockets :)
	if (self.job & #JOB_GUERILLA)
		self.maxammo_rockets = self.maxammo_rockets + 20;

	//OfN if we got the holo we get extra cells ammo space
	if (self.cutf_items & #CUTF_HOLO)
		self.maxammo_cells = self.maxammo_cells + 40;

	//If they bought weapons, remove their basic ammo allotment
	if (self.maxammo_rockets > 10)
		self.maxammo_rockets = self.maxammo_rockets - 10;
	  if (self.maxammo_nails > 10)
		self.maxammo_nails = self.maxammo_nails - 10;
	  if (self.maxammo_shells > 10)
		self.maxammo_shells = self.maxammo_shells - 10;
	  if (self.maxammo_cells > 10)
		self.maxammo_cells = self.maxammo_cells - 10;

	//Increase their supply if they bought a backpack or bandolier
	if (self.tf_items & #NIT_AMMO_BACKPACK) {
		self.maxammo_rockets = self.maxammo_rockets + 30;
		self.maxammo_nails	 = self.maxammo_nails	+ 100;
		self.maxammo_shells  = self.maxammo_shells	+ 100;
		if (self.weapons_carried & #WEAP_SPANNER)
			self.maxammo_cells	 = self.maxammo_cells	+ 170;
		else
			self.maxammo_cells	 = self.maxammo_cells	+ 50;
		if (self.maxammo_medikit > 0) //Only increase their medical supplies when...
			self.maxammo_medikit = self.maxammo_medikit + 70;
		if (self.maxammo_detpack > 0)
			self.maxammo_detpack = self.maxammo_detpack + 0.5;
	}
	if (self.tf_items & #NIT_AMMO_BANDOLIER) {
		self.maxammo_rockets = self.maxammo_rockets + 10;
		self.maxammo_nails	 = self.maxammo_nails	+ 50;
		self.maxammo_shells  = self.maxammo_shells	+ 50;
		self.maxammo_cells	 = self.maxammo_cells	+ 30;
		if (self.maxammo_medikit > 0)
			self.maxammo_medikit = self.maxammo_medikit + 50;
		if (self.maxammo_detpack > 1) //Only give extra det if they bought both
			self.maxammo_detpack = 2;
	}

	//Clean up detpack fraction
	if (self.maxammo_detpack > 1 && self.maxammo_detpack < 2) 
		self.maxammo_detpack = 1;

	if (self.cutf_items & #CUTF_SENSOR) // SB
		self.maxammo_cells = self.maxammo_cells + 70;
	if (self.cutf_items & #CUTF_DISPENSER) // SB
		self.maxammo_cells = self.maxammo_cells + 100;
	if (self.cutf_items & #CUTF_FIELDGEN) // SB
		self.maxammo_cells = self.maxammo_cells + 140;

	//- OfN
	if (self.weapons_carried & #WEAP_LASERCANNON) self.maxammo_cells = self.maxammo_cells + 70;
	if (self.weapons_carried & #WEAP_SNG) self.maxammo_nails = self.maxammo_nails + 70;
	if (self.weapons_carried & #WEAP_AIRF) self.maxammo_cells = self.maxammo_cells + 60;

	//Now cap the max ammo
	if (self.maxammo_rockets > 100)
		self.maxammo_rockets = 100;
	  if (self.maxammo_nails > 350)
		self.maxammo_nails = 350;
	  if (self.maxammo_shells > 300)
		self.maxammo_shells = 300;
	  if (self.maxammo_cells > #MAXAMMO_CELLS)
		self.maxammo_cells = #MAXAMMO_CELLS;

/* WK 1/7/7 We don't need all this complication
	  //- ofn
	  if (self.tf_items & #NIT_AMMO_BANDOLIER && self.tf_items & #NIT_AMMO_BACKPACK)
	  {
		if (self.maxammo_cells > #MAXAMMO_CELLS + 100) 
			self.maxammo_cells = #MAXAMMO_CELLS + 100;
	  }
	  else if (self.tf_items & #NIT_AMMO_BACKPACK)
	  {
		if (self.maxammo_cells > #MAXAMMO_CELLS + 50) // was 360
			self.maxammo_cells = #MAXAMMO_CELLS + 50;
	  } 	 
	  else
	  {
		if (self.maxammo_cells > #MAXAMMO_CELLS) // was 320
			self.maxammo_cells = #MAXAMMO_CELLS;
	  }
*/

	//- OFN HERE FRONTLIN HELI BUG FIX ---//
	local entity spot;
	spot = SelectSpawnPoint ();

	self.observer_list = spot;
	self.origin = spot.origin + '0 0 1';
	self.angles = spot.angles;
	self.fixangle = #TRUE;		// turn this way immediately

	makevectors(self.angles);
	spawn_tfog (self.origin + v_forward*20);
	//------------------------------------//
	
	//Telefrag anyone sitting on top of us
	spawn_tdeath(self.origin,self);
	
	//Remove observer-like mode
	self.takedamage = #DAMAGE_AIM;
	//Prevent bad movetype errors, or something
	if (self.classname != "player") {
		RPrint("BUG BUG BUG BUG BUG BUG BUG BUG BUG\n");
		RPrint("Non-player was in custom class generation!\n");
		return;
	}
	self.movetype = #MOVETYPE_WALK;
	self.flags = #FL_CLIENT | #FL_ONGROUND;
	self.waterlevel = 0;
	self.air_finished = time + 12;
	self.solid = #SOLID_SLIDEBOX;
	self.pausetime = 0;

	//Remove invisibility
	//setmodel (self, "progs/eyes.mdl");
	//setmodel (self, "progs/player.mdl");
	self.modelindex = modelindex_player;

	// Stock him up
	// Display the Player's Class
	TeamFortress_PrintJobName(self,self.job);
	// Set the weapons and ammo for the player based on class
	TeamFortress_SetEquipment();
	// Set the health for the player based on class
	TeamFortress_SetHealth();
	// Set the speed for the player based on class
	TeamFortress_SetSpeed(self);
	// Set the skin for the player based on class
	TeamFortress_SetSkin(self);
	stuffcmd(self, "v_idlescale 0\n");
	stuffcmd(self, "v_cshift 0 0 0 0\n");
	stuffcmd(self, "bf\n");

	ResetMenu();		
	self.impulse = 0;

	//Make them invincible if they bought respawn protection
	if (self.tf_items & #NIT_RESPAWN_GUARD) {
		self.items = self.items + #IT_INVULNERABILITY;
		self.invincible_time = 1;
#ifdef COOP_MODE_ENHANCED
		if ( !deathmatch )
			self.invincible_finished = time + #COOP_RESPAWN_GUARD_TIME;
		else
#endif
		self.invincible_finished = time + #RESPAWN_GUARD_TIME;
		if (self.custom_speed > 300)
			self.invincible_finished = self.invincible_finished - 1;			
		if (self.custom_speed > 400)
			self.invincible_finished = self.invincible_finished - 1;			
	}

	//Come again!
	sprint(self,#PRINT_HIGH,"Type ¢custom¢ at the console to build a new class.\n");
	return;
};

void() PrintMoney =
{
	CuTFMenuSound(#MENUSOUND_BUY);
	
	if (pay_msgs != 1)
		return;

	local string as;
	sprint(self,#PRINT_HIGH,"You have ");
	as = ftos(self.money);
	sprint(self,#PRINT_HIGH,as);
	sprint(self,#PRINT_HIGH," dollars left.\n");
	return;
};


void(float in) PrintRefund=
{
	CuTFMenuSound(#MENUSOUND_SELL);

	local string as;

	if (pay_msgs == 1)
	{
		sprint(self,#PRINT_HIGH,"You sell it back for ");
		as = ftos(in);
		sprint(self,#PRINT_HIGH,as);
		sprint(self,#PRINT_HIGH," dollars.\n");
	}

	self.money = self.money + in; //Give em a refund

	if (pay_msgs == 1)
	{
		sprint(self,#PRINT_HIGH,"You now have ");
		as = ftos(self.money);
		sprint(self,#PRINT_HIGH,as);
		sprint(self,#PRINT_HIGH," dollars available.\n");
	}

	return;
};

void(float in) PrintNotEnoughMoney =
{
	CuTFMenuSound(#MENUSOUND_WRONG);

	self.tfstate = self.tfstate | #TFSTATE_NOTENOUGHMONEY;

	if (pay_msgs != 1)
	{
		sprint(self,#PRINT_HIGH,"Not enough money!\n");
		return;
	}

	local string as;
	
	sprint(self,#PRINT_HIGH,"Sorry, that costs ");
	as = ftos(in);
	sprint(self,#PRINT_HIGH,as);
	sprint(self,#PRINT_HIGH," dollars.\n");

	sprint(self,#PRINT_HIGH,"You only have ");
	as = ftos(self.money);
	sprint(self,#PRINT_HIGH,as);
	sprint(self,#PRINT_HIGH," dollars left.\n");
	return;
};

//Functions for determining ammo carrying capacity
float (float item) countshells =
{
/*	if (chris)
	{
		if (item == #WEAP_SHOTGUN) return 16;
		if (item == #WEAP_SPANNER) return 20;
		if (item == #WEAP_SUPER_SHOTGUN) return 32;
		if (item == #WEAP_ASSAULT_CANNON) return 75;
	}
	else
	{*/
		if (item == #WEAP_SHOTGUN) return 25;
		if (item == #WEAP_SPANNER) return 40;
		if (item == #WEAP_SUPER_SHOTGUN) return 50;
		if (item == #WEAP_ASSAULT_CANNON) return 100;
	//}
	return 0;
};
float (float item) countnails =
{
	/*if (chris)
	{
		if (item == #WEAP_MAUSER) return 10;
		if (item == #WEAP_TRANQ) return 20;
		if (item == #WEAP_LASER) return 10;
		if (item == #WEAP_NAILGUN) return 75;
		if (item == #WEAP_LIGHT_ASSAULT) return 100;
	}
	else
	{*/
		if (item == #WEAP_MAUSER) return 30;
		if (item == #WEAP_TRANQ) return 30;
		if (item == #WEAP_RAILGUN) return 50;
		if (item == #WEAP_NAILGUN) return 100;
		if (item == #WEAP_LIGHT_ASSAULT) return 150;
	//}
	return 0;
};
float (float item) countrockets =
{
	/*if (chris)
	{
		if (item == #WEAP_SPANNER) return 2;
		if (item == #WEAP_ROCKET_LAUNCHER) return 3;
		if (item == #WEAP_GRENADE_LAUNCHER) return 7;
	}
	else
	{*/
		if (item == #WEAP_SPANNER) return 30;
		if (item == #WEAP_ROCKET_LAUNCHER) return 30;
		if (item == #WEAP_GRENADE_LAUNCHER) return 50;
	//}
	return 0;
};
float (float item) countcells =
{
	/*if (chris)
	{
		if (item == #WEAP_ASSAULT_CANNON) return 16;
		if (item == #WEAP_DAEDALUS) return 50;
		if (item == #WEAP_LIGHTNING) return 75;
		if (item == #WEAP_SPANNER) return 150;
	}
	else
	{*/
		if (item == #WEAP_ASSAULT_CANNON) return 50;
		if (item == #WEAP_DAEDALUS) return 100;
		if (item == #WEAP_LIGHTNING) return 100;
		if (item == #WEAP_SPANNER) return 150;
	//}
	return 0;
};

#ifdef NEVER_DEFINED
float(float numitem) GetHPCost =
{
	if (numitem == 1)
		return #COST_HP1;
	else if (numitem == 2)
		return #COST_HP2;
	else if (numitem == 3)
		return #COST_HP3;
	else if (numitem == 4)
		return #COST_HP4;
	else if (numitem == 5)
		return #COST_HP5;
	else if (numitem == 6)
		return #COST_HP6;
	else if (numitem == 7)
		return #COST_HP7;

	return 0;
};
#endif

/*
==============
BuyHealth

Gizmo - so we don't have to duplicate code when buying
health and armor.
==============
*/
void( float type ) BuyHealth = {
	local float	current;
	local float	tosell, tobuy;

	if ( !type )
		return;

	if (self.maxarmor == 50)
	{
		if (self.health == 75)
			current = 1;
		else
			current = 2;		
	}
	else if (self.maxarmor == 100)
		current = 3;
	else if (self.maxarmor == 120)
		current = 4;
	else if (self.maxarmor == 150)
		current = 5;
	else if (self.maxarmor == 200)
		current = 6;
	else if (self.maxarmor == 300)
		current = 7;
	else
		current = 0;	// Gizmo - only set to zero if all others fail

	tosell = GetHPCost(current);
	tobuy = GetHPCost(type);
	if (self.money < tobuy - tosell)
	{
		PrintNotEnoughMoney(tobuy - tosell);
		return;
	}
	
	if ( current == type || current ) { // sell back?
		self.max_health = 50;
		self.health = self.max_health;
		self.maxarmor = 0;
		self.armorvalue = 0;
		self.armortype = 0;
		self.armor_allowed = 0;

		PrintRefund(tosell);
		UpdateArmorItem(self);

		if (current == type)
			return;
	}

	if (type == 1)
	{
		self.max_health = 75;
		self.health = self.max_health;
		self.maxarmor = 50;
		self.armorvalue = self.maxarmor;
		self.armortype = 0.3;	// Green
		self.armor_allowed = 0.3; //Green max
		UpdateArmorItem(self);
	}
	else if (type == 2)
	{
		self.max_health = 90;
		self.health = self.max_health;
		self.maxarmor = 50;
		self.armorvalue = self.maxarmor;
		self.armortype = 0.3;	// Green
		self.armor_allowed = 0.3; //Green max
		UpdateArmorItem(self);
	}
	else if (type == 3)
	{
		self.max_health = 80;
		self.health = self.max_health;
		self.maxarmor = 100;
		self.armorvalue = self.maxarmor;
		self.armortype = 0.6;
		self.armor_allowed = 0.6;
		UpdateArmorItem(self);
	}
	else if (type == 4)
	{
		self.max_health = 90;
		self.health = self.max_health;
		self.maxarmor = 120;
		self.armorvalue = self.maxarmor;
		self.armortype = 0.6;
		self.armor_allowed = 0.6;
		UpdateArmorItem(self);
	}
	else if (type == 5)
	{
		self.max_health = 100;
		self.health = self.max_health;
		self.maxarmor = 150;
		self.armorvalue = self.maxarmor;
		self.armortype = 0.6;	
		self.armor_allowed = 0.6;
		UpdateArmorItem(self);
	}
	else if (type == 6)
	{
		self.max_health = 100;
		self.health = self.max_health;
		self.maxarmor = 200;
		self.armorvalue = self.maxarmor;
		self.armortype = 0.8;	
		self.armor_allowed = 0.8;
		UpdateArmorItem(self);
	}
	else if (type == 7)
	{
		self.max_health = 100;
		self.health = self.max_health;
		self.maxarmor = 300;
		self.armorvalue = self.maxarmor;
		self.armortype = 0.8;	
		self.armor_allowed = 0.8;
		UpdateArmorItem(self);
	}

	self.money = self.money - tobuy;
	PrintMoney();
};

void(float cost, float item) BuyWeapon =
{
	if (item == 0) //Make sure we don't buy a null weapon
		return;
	
	if (self.weapons_carried & item) //We are selling
	{
		// Gizmo - changed this to just one rocket launcher check
		if ( item == #WEAP_ROCKET_LAUNCHER ) {
			if ( self.tf_items & #NIT_RL_LASER_SIGHT ) {
				self.money = self.money + #COST_RLASERGUIDED;
				self.tf_items = self.tf_items - #NIT_RL_LASER_SIGHT;
			}
			if ( self.tf_items & #NIT_CLUSTER_ROCKETS ) {
				self.money = self.money + #COST_CLUSTER;
				self.tf_items = self.tf_items - #NIT_CLUSTER_ROCKETS;
			}
			if ( self.cutf_moreitems & #CUTF_MI_FASTERROCKETS ) {
				self.money = self.money + #COST_FASTERROCKETS;
				self.cutf_moreitems = self.cutf_moreitems - #CUTF_MI_FASTERROCKETS;
			}
		}
		self.maxammo_shells = self.maxammo_shells - countshells(item);
		self.maxammo_nails = self.maxammo_nails - countnails(item);
		self.maxammo_rockets = self.maxammo_rockets - countrockets(item);
		self.maxammo_cells = self.maxammo_cells - countcells(item);
		PrintRefund(cost);
		self.weapons_carried = self.weapons_carried - item;
		return;
	}
	if (cost > self.money)
	{
		PrintNotEnoughMoney(cost);
		return;
	}
	//Add to max ammo
	self.maxammo_shells = self.maxammo_shells + countshells(item);
	self.maxammo_nails = self.maxammo_nails + countnails(item);
	self.maxammo_rockets = self.maxammo_rockets + countrockets(item);
	self.maxammo_cells = self.maxammo_cells + countcells(item);

	self.weapons_carried = self.weapons_carried | item;
	self.money = self.money - cost;
	PrintMoney();
};


void(float cost, float item) BuyCuTF =
{
	if (item == 0) //Make sure we don't buy a null weapon
		return;
	
	if (item == #CUTF_HOLO && !(self.cutf_items & #CUTF_HOLO)) {
		if (!(cost > self.money))
			sprint(self,#PRINT_HIGH,"Use the 'holo' command to activate/deactivate the holograph\n");
	}

	if (self.cutf_items & item) //We are selling
	{
		if (item & #CUTF_SENTRYGUN) {
			self.maxammo_shells = self.maxammo_shells - 130;
			self.maxammo_cells	= self.maxammo_cells  - 130;
		}
		PrintRefund(cost);
		self.cutf_items = self.cutf_items - item;
		return;
	}
	if (cost > self.money)
	{
		PrintNotEnoughMoney(cost);
		return;
	}
	//Add to max ammo if sentrygun purchase
	if (item & #CUTF_SENTRYGUN) {
		self.maxammo_shells = self.maxammo_shells + 130;
		self.maxammo_cells	= self.maxammo_cells  + 130;
	}

	self.cutf_items = self.cutf_items | item;
	self.money = self.money - cost;
	PrintMoney();
};

//CH gives ammo for items
void(float item) Apply_Item_Ammo =
{
	local float cellsfoo,rocketsfoo;
	cellsfoo = rocketsfoo = 0;

	if (item == #NIT_TESLA)
		cellsfoo = 150;
	if (item == #NIT_SECURITY_CAMERA)
		cellsfoo = 60;
	if (item == #NIT_TELEPORTER)
		cellsfoo = 100;

	if (item == #NIT_RL_LASER_SIGHT)
		rocketsfoo = 10;
	if (item == #NIT_CLUSTER_ROCKETS)
		rocketsfoo = 20;

	if (self.tf_items & item) { //we selling
		self.maxammo_cells = self.maxammo_cells - cellsfoo;
		self.maxammo_rockets = self.maxammo_rockets - rocketsfoo;
	}
	else {
		self.maxammo_cells = self.maxammo_cells + cellsfoo;
		self.maxammo_rockets = self.maxammo_rockets + rocketsfoo;
	}
};
void(float cost, float item) BuyItem =
{
	if (item == 0) //Make sure we don't buy a null item
		return;

	Apply_Item_Ammo(item); //CH

	if (self.tf_items & item) //We are selling
	{
		if (item == #NIT_HOVER_BOOTS && self.tf_items & #NIT_HOVER_BOOTS_UPGRADE) {
			self.money = self.money + #COST_BOOTUPGRADE; //sync with buying of upgrade
			item = item + #NIT_HOVER_BOOTS_UPGRADE;
		}

		PrintRefund(cost);
		self.tf_items = self.tf_items - item;
		return;
	}
	//Special rules
	if (item == #NIT_AUTOSCANNER && !(self.tf_items & #NIT_SCANNER)) {
		sprint(self,#PRINT_HIGH,"Sorry, you have to buy the scanner first!\n");
		CuTFMenuSound(#MENUSOUND_WRONG);
		return;
	}
	if ((item == #NIT_RL_LASER_SIGHT || item == #NIT_CLUSTER_ROCKETS) && !(self.weapons_carried & #WEAP_ROCKET_LAUNCHER)) {
		sprint(self,#PRINT_HIGH,"Sorry, you have to buy the rocket launcher first!\n");
		CuTFMenuSound(#MENUSOUND_WRONG);
		return;
	}

	if (item == #NIT_HOVER_BOOTS && !(cost > self.money))
		sprint(self,#PRINT_HIGH,"Hold down jump to use the boots\n");

	if (item == #NIT_HOVER_BOOTS_UPGRADE && !(self.tf_items & #NIT_HOVER_BOOTS)) {
		sprint(self,#PRINT_HIGH,"Sorry, you have to buy the hover boots first!\n");
		CuTFMenuSound(#MENUSOUND_WRONG);
		return;
	}
	if (cost > self.money)
	{
		PrintNotEnoughMoney(cost);
		return;
	}

	self.tf_items = self.tf_items | item;
	self.money = self.money - cost;
	PrintMoney();
};

void(float cost, float type) BuyJob =
{
	if (type == 0) //Make sure we don't buy a null grenade
		return;
	
	if (type == self.job) //We are selling
	{
		/*if (self.job & #JOB_WARLOCK)
		{
			if (!self.cutf_items & #CUTF_DEMONLORE)
				cost = cost - #COST_DEMONLORE; // sync with demonlore cost
			else
				self.cutf_items = self.cutf_items - (self.cutf_items & #CUTF_DEMONLORE);
		}
		if (self.job & #JOB_RUNNER)
		{
			if (!self.cutf_items & #CUTF_HIGHJUMP)
				cost = cost - #COST_HIGHJUMP; // sync with highjump cost
			else
				self.cutf_items = self.cutf_items - (self.cutf_items & #CUTF_HIGHJUMP);
		}
		if (self.job & #JOB_JUDOKA)
		{
			if (!self.cutf_items & #CUTF_STEALTH)
				cost = cost - #COST_STEALTH; // sync with stealth cost
			else
				self.cutf_items = self.cutf_items - (self.cutf_items & #CUTF_STEALTH);
		}*/
		PrintRefund(cost);
		self.job = 0;
		return;
	}
	if (cost > self.money)
	{
		PrintNotEnoughMoney(cost);
		return;
	}
	if (self.job) { //Make sure we haven't bought another kind already
		sprint(self,#PRINT_HIGH,"You already have a job. Leave your other one first.\n");
		CuTFMenuSound(#MENUSOUND_WRONG);
		return;
	}
	//Special rules for buying jobs
	if (type == #JOB_WARLOCK && !(self.cutf_items & #CUTF_KNIFE)) {
		sprint(self,#PRINT_HIGH,"Every Warlock needs a good bloody knife. Buy one.\n");
		CuTFMenuSound(#MENUSOUND_WRONG);
		return;
	}
	/*if (type == #JOB_WARLOCK)
		if (self.cutf_items & #CUTF_DEMONLORE)
			self.money = self.money + #COST_DEMONLORE; // sync this with demonlore cost
		else
			self.cutf_items = self.cutf_items | #CUTF_DEMONLORE; // warlocks see demon health
	
	if (type == #JOB_RUNNER)
		if (self.cutf_items & #CUTF_HIGHJUMP)
			self.money = self.money + #COST_HIGHJUMP; // sync with highjump cost
		else
			self.cutf_items = self.cutf_items | #CUTF_HIGHJUMP; // runner jumps high
	
	if (type == #JOB_JUDOKA)
		if (self.cutf_items & #CUTF_STEALTH)
			self.money = self.money + #COST_STEALTH; // sync with stealth price
		else
			self.cutf_items = self.cutf_items | #CUTF_STEALTH; // Judo is a master of stealth by default
	*/
	
	//Ok we buy it
	self.job = type;
	self.money = self.money - cost;
	PrintMoney();
};

void (float cost1, float cost2) BuyExtra =
{
	local float allcost;
	allcost = 0;
	
	if (self.job & #JOB_EXTRA1) // we have extra1
	{
		if (self.money < cost2) // not enough money for extra2, sell back job and extra1 then..
		{
			if (self.job & #JOB_WARLOCK)
			{
				allcost = #COST_WARLOCK + cost1;

				/*if (!self.cutf_items & #CUTF_DEMONLORE)
					allcost = allcost - #COST_DEMONLORE; // sync with demonlore cost
				else
					self.cutf_items = self.cutf_items - (self.cutf_items & #CUTF_DEMONLORE);*/
			}
			else if (self.job & #JOB_ARMY)
			{
				allcost = #COST_ARMY + cost1;
			}
			else if (self.job & #JOB_GUERILLA)
			{
				allcost = #COST_GUERILLA + cost1;
			}

			self.job = 0;
		PrintNotEnoughMoney(cost1);
			PrintRefund(allcost);
			return;
		}
		else // ok, buy second extra
		{
			self.job = self.job - (self.job & #JOB_EXTRA1);
			self.job = self.job | #JOB_EXTRA2;
			
			// decrease our money
			self.money = self.money - cost2;	
		}
	}
	else if (self.job & #JOB_EXTRA2) // we have extra2, so sell back everything..
	{
		if (self.job & #JOB_WARLOCK)
		{
			allcost = (cost1+cost2)+#COST_WARLOCK;

			/*if (!self.cutf_items & #CUTF_DEMONLORE)
				allcost = allcost - #COST_DEMONLORE; // sync with demonlore cost
			else
				self.cutf_items = self.cutf_items - (self.cutf_items & #CUTF_DEMONLORE);*/
		}
		else if (self.job & #JOB_ARMY)
		{
			allcost = (cost1+cost2)+#COST_ARMY;
		}
		else if (self.job & #JOB_GUERILLA)
		{
			allcost = (cost1+cost2)+#COST_GUERILLA;
		}
			
		self.job = 0;
		PrintRefund(allcost);
		return;
	}
	else // we dont have any extra
	{
		if (self.money < cost1) // not enough money for 1st extra, so sell back job
		{
			if (self.job & #JOB_WARLOCK)
			{
				allcost = #COST_WARLOCK;

				/*if (!self.cutf_items & #CUTF_DEMONLORE)
					allcost = allcost - #COST_DEMONLORE; // sync with demonlore cost
				else
					self.cutf_items = self.cutf_items - (self.cutf_items & #CUTF_DEMONLORE);*/
			}
			else if (self.job & #JOB_ARMY)
			{
				allcost = #COST_ARMY;
			}
			else if (self.job & #JOB_GUERILLA)
			{
				allcost = #COST_GUERILLA;
			}

			self.job = 0;
			PrintNotEnoughMoney(cost1);
			PrintRefund(allcost);
			return;
		}
		else // ok, buy 1st extra
		{
			self.job = self.job | #JOB_EXTRA1;

			// decrease our money
			self.money = self.money - cost1;
		}
	}

	// Print money
	PrintMoney();
};

void (float cost, float type) BuyGren =
{
	//local string talk;
	///local float level; // This is the level of legs we have.
	
	if (type == 0) // if type is 0 we are buying the NULL GRENADE(tm)
	{
		sprint(self, #PRINT_HIGH, "Congratulations. You have just attempted to buy a null grenade.\n");
		RPrint("WARNING: Attempted purchase of NULL GRENADE. BUG BUG BUG BUG BUG BUG BUG\n");
		return;
	}
	// Check whether we're allowing gren purchase.
	/*level = ReturnLegLevel(self.custom_speed);
	if (level == 1) // grens are a no-no
	{
		sprint(self, #PRINT_HIGH, "Sorry, you are not allowed any grenades at that speed. It is very dangerous.\n");
		return;
	}
	else if (level == 2)
	{
		local float acc; // Acceptable.
		
		acc = #FALSE;
		
		if (type == #GR_TYPE_CALTROP)
			acc = #TRUE;
		else if (type == #GR_TYPE_CONCUSSION)
			acc = #TRUE;
		else if (type == GR_TYPE_STASIS)
			acc = #TRUE;
		else if (type == #GR_TYPE_ANTIGRAV)
			acc = #TRUE;
		else if (type == #GR_TYPE_FLARE)
			acc = #TRUE;
		if (!acc)
		{
			sprint(self, #PRINT_HIGH, "Sorry, using those grenades at your speed could be dangerous.\n");
			return;
		}
	}
	else if (level == 3)
	{
		if (type == #GR_TYPE_MIRV)
		{
			sprint(self, #PRINT_HIGH, "Sorry, you aren't allowed MIRVs at that speed.\n");
			return;
		}
	}*/
	// Grenade and speed is fine.
	
	if (!self.tp_grenades_1 && cost <= self.money) // if we don't have gren1s, make it a gren1
	{
/*		if (self.money_misc + cost > self.money_spent - self.money_misc)
		{
			PrintTooHighProportion();
			return;
		} */
		self.tp_grenades_1 = type;
		//sprint(self, #PRINT_HIGH, "You buy the grenades and add them to your first grenade slot for ");
	}
	else if (!self.tp_grenades_2 && cost <= self.money) // We already have gren1s, can we buy gren2s?
	{
		/*if (self.money_misc + cost > self.money_spent - self.money_misc)
		{
			PrintTooHighProportion();
			return;
		}*/
		self.tp_grenades_2 = type;
		//sprint(self, #PRINT_HIGH, "You buy the grenades and add them to your second grenade slot for ");
	}
	else	// We have both gren1s and gren2s so now we need to try to sell some
	{		// If our type matches gren1 AND gren2s we want to sell both
		if (self.tp_grenades_1 == type && self.tp_grenades_2 == type)
		{
			PrintRefund(cost * 2);
			//self.money_misc = self.money_misc - cost * 2;
			//self.money = self.money + cost * 2; //*2
			self.tp_grenades_1 = 0;
			self.tp_grenades_2 = 0;
		}
		else if (self.tp_grenades_1 == type) // otherwise if our gren1s are the type
		{
			PrintRefund(cost);
			//self.money_misc = self.money_misc - cost;
			//self.money = self.money + cost;
			self.tp_grenades_1 = 0;
		}
		else if (self.tp_grenades_2 == type) // otherwise if we have gren2s as the type..
		{
			PrintRefund(cost);
			//self.money_misc = self.money_misc - cost;
			//self.money = self.money + cost;
			self.tp_grenades_2 = 0;
		}
		else if (cost <= self.money)
		{
			CuTFMenuSound(#MENUSOUND_WRONG);
			sprint(self,#PRINT_HIGH,"You already have a full set of grenades. Sell some back first.\n");
		}
		else
			PrintNotEnoughMoney(cost);
		
		return;
	}
	self.money = self.money - cost;
	PrintMoney();
	//self.money_misc = self.money_misc + cost;
	//self.money_spent = self.money_spent + cost;
	/*talk = ftos(cost);
	sprint(self, #PRINT_HIGH, talk);
	sprint(self, #PRINT_HIGH, " dollars. You have ");
	talk = ftos(self.money);
	sprint(self, #PRINT_HIGH, talk);
	sprint(self, #PRINT_HIGH, " dollars left.\n");*/
};
/*

void(float cost, float type) BuyGren1 =
{
	if (type == 0) //Make sure we don't buy a null grenade
		return;
	
	if (type == self.tp_grenades_1) //We are selling
	{
		PrintRefund(cost);
		self.tp_grenades_1 = 0;
		return;
	}
	if (cost > self.money)
	{
		PrintNotEnoughMoney(cost);
		return;
	}
	if (self.tp_grenades_1) { //Make sure we haven't bought another kind already
		sprint(self,#PRINT_HIGH,"You already have grenades. Sell back the ones you bought first.\n");
		return;
	}
	//Ok we buy it
	self.tp_grenades_1 = type;
	self.money = self.money - cost;
	PrintMoney();
};

void(float cost, float type) BuyGren2 =
{
	if (type == 0) //Make sure we don't buy a null grenade
		return;
	
	if (type == self.tp_grenades_2) //We are selling
	{
		PrintRefund(cost);
		self.tp_grenades_2 = 0;
		return;
	}
	if (cost > self.money)
	{
		PrintNotEnoughMoney(cost);
		return;
	}
	if (self.tp_grenades_2) { //Make sure we haven't bought another kind already
		sprint(self,#PRINT_HIGH,"You already have grenades. Sell back the ones you bought first.\n");
		return;
	}

	//Ok we buy it
	self.tp_grenades_2 = type;
	self.money = self.money - cost;
	PrintMoney();
};
*/

//Functions for our new grenades
void() fragspike_touch =
{
	//if (pointcontents(self.origin) == #CONTENT_SKY)
	if (pointcontents(self.origin) != #CONTENT_EMPTY)
	{
		dremove(self);
		return;
	}
	
// hit something that bleeds
	if (other.takedamage)
	{
		deathmsg = #DMSG_GREN_FRAG;

		TF_T_Damage (other, self, self.real_owner, 150, #TF_TD_NOTTEAM, #TF_TD_NAIL);
		dremove(self);
	}
	else
	{
		//We bounce off world since we are fragments
		if (self.heat > 0) {
//			self.heat = self.heat - 1;
//			if (self.velocity = '0 0 0') { //Skip around
			if (1) { //Skip around
				self.velocity_x = (random() - 0.5) * 200;
				self.velocity_y = (random() - 0.5) * 200;
				self.velocity_z = random() * 200;
			}
		}
		else {
			if (other.classname == "force_field") //- OfN - Makes field explosion b4 removing it
			   //FieldExplosion(other,self.origin,self);
			   FieldEvent(other,self.origin,self);
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

			dremove(self);
		}
	}
};
void() FragSpikeThink =
{
	if (self.heat > 0) {
		self.heat = self.heat - 1;

		self.angles_y = random() * 360;
		self.angles_x = 0;
		self.angles_z = 0;
		makevectors(self.angles);
		if (self.velocity == '0 0 0')
			self.origin_z = self.origin_z + 50;

		self.velocity = v_forward * 1000;
		self.velocity_z = (random() + 0.25) * 1000;

		self.nextthink = time + 0.5 + random();
	}
	else {
		WriteByte (#MSG_BROADCAST, #SVC_TEMPENTITY);
		WriteByte (#MSG_BROADCAST, #TE_SUPERSPIKE);
		WriteCoord (#MSG_BROADCAST, self.origin_x);
		WriteCoord (#MSG_BROADCAST, self.origin_y);
		WriteCoord (#MSG_BROADCAST, self.origin_z);
	#ifdef QUAKE_WORLD
		multicast (self.origin, #MULTICAST_PHS);
	#endif						
		dremove(self);
	}
};

void() FragGrenadeTouch =
{
	if (other == self.owner)
		return; 	// don't explode on owner

	// Thrown grenades don't detonate when hitting an enemy

	sound (self, #CHAN_WEAPON, "weapons/bounce.wav", 1, #ATTN_NORM);	// bounce sound
	if (self.velocity == '0 0 0')
		self.avelocity = '0 0 0';
};
void() FragGrenadeExplode =
{
	local float shraps;
	//local string happy;
	local entity newmis; // (???)

//Small explosive radius
	deathmsg = #DMSG_GREN_HAND;
	T_RadiusDamage (self, self.owner, 80, world);

	WriteByte (#MSG_BROADCAST, #SVC_TEMPENTITY);
	WriteByte (#MSG_BROADCAST, #TE_EXPLOSION);
	WriteCoord (#MSG_BROADCAST, self.origin_x);
	WriteCoord (#MSG_BROADCAST, self.origin_y);
	WriteCoord (#MSG_BROADCAST, self.origin_z);
#ifdef QUAKE_WORLD
	multicast (self.origin, #MULTICAST_PHS);
#endif

	shraps = rint(6 * random()) + 6; //Pieces of shrapmetal;
	while (shraps > 0) {
		self.angles_y = random() * 360;
		self.angles_x = 0;
		self.angles_z = 0;
		makevectors(self.angles);

		deathmsg = #DMSG_GREN_NAIL;
		newmis = spawn ();
		//WK Make shraps hit owner newmis.owner = self.owner;
		newmis.real_owner = self.owner;
		newmis.movetype = #MOVETYPE_BOUNCE;
		newmis.solid = #SOLID_BBOX;

		newmis.angles = '0 0 0';
		newmis.classname = "spike";
		newmis.think = FragSpikeThink;
//		newmis.think = SUB_Remove;
		newmis.nextthink = time + 1;
		setmodel (newmis, "progs/spike.mdl");
		setsize (newmis, #VEC_ORIGIN, #VEC_ORIGIN); 	
		setorigin (newmis, self.origin);

		//Start it over the ground
		newmis.origin_z = newmis.origin_z + 10;

		newmis.velocity = v_forward * 1000;
		if (random() < 0.5) 
			newmis.velocity_z = 20;
		else
			newmis.velocity_z = random() * 1000;
		newmis.avelocity = '100 100 100';
		newmis.touch = fragspike_touch;
		newmis.weapon = #DMSG_GREN_NAIL;

		//Make it bounce six times.
		newmis.heat = 5;
		shraps = shraps - 1;
	}
#ifdef QUAKE_WORLD
	WriteByte (#MSG_BROADCAST, #SVC_TEMPENTITY);
	WriteByte (#MSG_BROADCAST, #TE_EXPLOSION);
	WriteCoord (#MSG_BROADCAST, self.origin_x);
	WriteCoord (#MSG_BROADCAST, self.origin_y);
	WriteCoord (#MSG_BROADCAST, self.origin_z);
	multicast (self.origin, #MULTICAST_PHS);
	dremove(self);
#else
	BecomeExplosion();
#endif

};

void() KracGrenadeTouch =
{
	//WK Have it detonate on impact
	if (other == self.owner)
		return; 	// don't explode on owner

	sound (self, #CHAN_WEAPON, "weapons/bounce.wav", 1, #ATTN_NORM);	// bounce sound
	
	KracGrenadeExplode();
};


#ifdef COOP_MODE_ENHANCED
float (entity test) COOP_IsCoopMonster;
#endif

void() KracGrenadeExplode =
{
	local entity te;
	local entity oldself;
	local float damage;

	te = findradius(self.origin, 150);
	while (te)
	{	
		// Player?
		if (te.classname == "player" && te.health > 0)
		{
			//WW: Kracs disable detpack
			oldself = self;
			self = te;
			TeamFortress_DetpackStop(#TRUE);
			self = oldself;

			//WK 1/7/7 Krac nerf
			//Deals 200, tapers off linearly with radius (min 75)
			damage = 200 - vlen(te.origin - self.origin);
			if (damage > 200 || damage < 0) {
				bprint(#PRINT_MEDIUM,"Logic error in krac occured.\n");
				dremove(self);
				return;
			}
			if (damage < 75) damage = 75;
			if (te.armorclass & #AT_SAVEMELEE) damage = floor(damage / 2);
			te.armorvalue = te.armorvalue - damage;
			if (te.armorvalue < 10) te.armorvalue = 10;

			//Damage is now dealt to cells instead of killing it all at once.
			//Do this before we adjust for armor damage
			te.ammo_cells = te.ammo_cells - damage; 
			if (te.ammo_cells < 0) te.ammo_cells = 0;

			//WK 1/7/7 Fix the "dead thunderbolt" bug when you get kraced.
			//This should force a weapon switch on the next frame.
			if (te.current_weapon == #WEAP_LIGHTNING || te.current_weapon == #WEAP_LASERCANNON ||
				te.current_weapon == #WEAP_DAEDALUS || te.current_weapon == #WEAP_AIRF ||
				te.current_weapon == #WEAP_FLAMETHROWER)
				te.currentammo = te.ammo_cells;

			/* WK 1/7/7 Old damage code:
			//Gel armor makes kracs do less damage
			if (te.armorclass & #AT_SAVEMELEE) {
				if (te.armorvalue > 75)
					te.armorvalue = 75;
			} else {
				if (te.armorvalue > 10)
					te.armorvalue = 10;
			}
			te.ammo_cells = 0; //Kill their metal supply too
			*/
		}
		else if (te.classname == "pipebomb")
			te.nextthink = time + 0.1 + random() / 4; //WK 1/7/7 Speed up kracs breaking pipebombs, since a 1.1 second delay is too long
		else if (te.classname == "grenade" && te.netname == "land_mine")
		{
			te.think = GuerillaExplode;
			te.nextthink = time + 0.1;
		}
		else if (te.classname == "building_sentrygun") {
			// Gizmo - this was left out here...
			damage = 200 - vlen(te.origin - self.origin);
			if (damage > 200 || damage < 0) {
				bprint(#PRINT_MEDIUM,"Logic error in krac occured.\n");
				dremove(self);
				return;
			}
			if (damage < 75) damage = 75;

			TF_T_Damage(te, self, self.owner, damage, 0, 0); //WK 1/7/7 Teslas and sentries take less now
		} else if (te.classname == "building_tesla") {
			// Gizmo - this was left out here...
			damage = 200 - vlen(te.origin - self.origin);
			if (damage > 200 || damage < 0) {
				bprint(#PRINT_MEDIUM,"Logic error in krac occured.\n");
				dremove(self);
				return;
			}
			if (damage < 75) damage = 75;

			TF_T_Damage(te, self, self.owner, damage, 0, 0);
		} else if (te.classname == "building_dispenser")
			TF_T_Damage(te, self, self.owner, 500, 0, 0);
		else if (te.classname == "building_camera")
			TF_T_Damage(te, self, self.owner, 400, 0, 0);
		else if (te.classname == "building_teleporter")
			TF_T_Damage(te, self, self.owner, 200, 0, 0);
		else if (te.classname == "building_sensor") //- Often - needed?
			TF_T_Damage(te, self, self.owner, 200, 0, 0);
		else if (te.classname == "building_fieldgen") //- Often - needed?
			TF_T_Damage(te, self, self.owner, 200, 0, 0);
		else if (te.classname == "item_armor1" || te.classname == "item_armor2" || te.classname == "item_armorInv") {
			te.solid = #SOLID_NOT;
			te.model = string_null;
			te.nextthink = time + 45; //WK 20
			te.think = SUB_regen;
			//SUB_UseTargets(); 
		}
		else if (te.classname == "detpack") {
			if (te.owner.netname != self.owner.netname) {
				bprint (#PRINT_MEDIUM, te.owner.netname);
				bprint (#PRINT_MEDIUM, "'s detpack was Kraced by ");
				bprint (#PRINT_MEDIUM, self.owner.netname);
				bprint (#PRINT_MEDIUM, "\n");
			} else {
				sprint (te.owner, #PRINT_MEDIUM, "You Kraced your own detpack!\n");
			}
			// This code handles disarming a detpack
			if (te.weaponmode == 1) // Detpack was being disarmed
			{
				te.enemy.tfstate = te.enemy.tfstate - (te.enemy.tfstate & #TFSTATE_CANT_MOVE);
		#ifdef QUAKE_WORLD
				TeamFortress_SetSpeed(te.enemy);
		#else
				te.enemy.pausetime = time;		
		#endif

				dremove(te.oldenemy);	 // CountDown
				dremove(te.observer_list); //	Disarm timer
			}
			else { //Not being disarmed
				dremove(te.oldenemy);	 // CountDown
			}
			te.think = BecomeExplosion;
			te.nextthink = time + 0.1;
		}
#ifdef COOP_MODE_ENHANCED
		// Gizmo - enable kracs to work on monsters
		else if (COOP_IsCoopMonster(te)) {
			// code is just copied from above
			damage = 200 - vlen(te.origin - self.origin);
			if (damage > 200 || damage < 0) {
				bprint(#PRINT_MEDIUM,"Logic error in krac occured.\n");
				dremove(self);
				return;
			}
			if (damage < 75) damage = 75;
			te.armorvalue = te.armorvalue - damage;
			if (te.armorvalue < 10) te.armorvalue = 10;
		}
#endif

		te = te.chain;
	}

#ifdef QUAKE_WORLD
	WriteByte (#MSG_BROADCAST, #SVC_TEMPENTITY);
	WriteByte (#MSG_BROADCAST, #TE_EXPLOSION);
	WriteCoord (#MSG_BROADCAST, self.origin_x);
	WriteCoord (#MSG_BROADCAST, self.origin_y);
	WriteCoord (#MSG_BROADCAST, self.origin_z);
	multicast (self.origin, #MULTICAST_PHS);
	dremove(self);
#else
	BecomeExplosion();
#endif
};

//Stops us from lowering the time immunity
void(entity immuner,float timeimmune) makeImmune =
{
	if (immuner == world) return;
	if (immuner.immune_to_chec > timeimmune) return;
	immuner.immune_to_chec = timeimmune;
};

void() BastardTimer =
{
	local entity te;
	local string st;
	te = self.owner;

	//makeImmune(te,time+5);

	// Bastard Memory
	// If the timer's bastard is no longer connected to the server, the timer
	// will sit dormant and remove itself, once penance time has passed. -Pulseczar
	if (!te || (te != world && !te.is_connected))
	{
		if (self.penance_time <= time)
		{
			delstr(self.t_s_h);
			dremove(self);
			return;
		}
		self.nextthink = time + 2;
		return;
	}

	if (te.penance_time < time)
	{
		stuffcmd(te, "cl_yawspeed 140;-right;-left\n");
		//stuffcmd(te, "name \"");
		//stuffcmd(te, te.old_netname);
		//stuffcmd(te, "\"\n");

		//Reset their color
		stuffcmd(te, "color ");
		st = ftos(TeamFortress_TeamGetColor(te.team_no) - 1);
		
		//- OfN - Nice colors
		if (nicecolors==1) st =TeamGetNiceColor(te.team_no);

		stuffcmd(te, st);
		stuffcmd(te, "\n");

		bprint (#PRINT_MEDIUM, te.netname);
		bprint (#PRINT_MEDIUM, " has his teamkill curse removed\n");

		//Don't let up on them. Two more teamkills and its back into the tarpit for them
		te.ff_count = self.frags - 1.9;
		if (te.ff_count < 0) te.ff_count = 0;
		
		TF_T_Damage(te, world, world, te.health + 300, #TF_TD_IGNOREARMOUR, #TF_TD_OTHER);
		
		delstr(self.t_s_h);
		remove(self);
		return;
	}

	if (random() > 0.5) 
		stuffcmd(te, "cl_yawspeed 500;-left;+right;color 8 8\n");
	else
		stuffcmd(te, "cl_yawspeed 500;-right;+left;color 8 8\n"); // <-- was 9 9
	//te.immune_to_check = time + 5;
	te.ammo_rockets = 0;
	te.ammo_cells = 0;
	te.ammo_nails = 0;
	te.ammo_shells = 0;
	te.ammo_detpack = 0;
	te.ammo_c4det = 0;
	  te.no_grenades_1 = 0;
	  te.no_grenades_2 = 0;
	if (te.health > 50) te.health = 50;
	if (te.armorvalue > 10) te.armorvalue = 10;

	self.nextthink = time + 2;
};

void(entity bastard,float threshold) createBastard =
{
	//if (mapname == "border1" || mapname == "border1r") // dont curse ppl on these maps, thay use a bug
	// done - TODO: Make triggers ignore cursed persons instead..
	//	  return;
	
	local entity te;

	if (bastard == world) return;

	if (bastard.penance_time > time) {
		bastard.ff_count = bastard.ff_count - 1; //Dont count it
		bastard.penance_time = time + 60; //Just reset the clock
		makeImmune(bastard,time+65);
		return;
	}

	//---------------------------------------------------------------------------//
	// Why do I not like MegaTF? ------------------------------------------------//
	// Look at http://www.planetfortress.com/history/people/shaka.html ----------//
	if (bastard.ff_count == threshold + 0.1 || bastard.ff_count == threshold + 0.6) {
		//- OfN - lol
		//bprint(#PRINT_HIGH,"ÔÉÍÅ ÔÏ ËÉÃË ÈÉM\n");
		bprint(#PRINT_HIGH,"ok, lets send ");
		bprint(#PRINT_HIGH,bastard.netname);
		bprint(#PRINT_HIGH," to a nice megaTF server...\n");
		stuffcmd(bastard, "name \"CustomTF reject-wanna play Mega\"\n");		
		//stuffcmd(bastard, "name \"im gay, wanna make new friends\"\n");  
		
		local string st;
#ifdef QUAKE_WORLD
		st = infokey(world,"curseserver");
#endif
		if (st == string_null) st = "amnesia.matrux.net:27502"; //WK 1/7/7 Updated ip
			stuffcmd(bastard, "connect ");
		stuffcmd(bastard, st);
		stuffcmd(bastard, "\n");

		return; //- OfN - (missing) OLD BUG?
	} //---------------------------------------------------------------------------//


	newmis = spawn();

	newmis.classname = "timer";
	newmis.netname = "bastardtimer";
	newmis.owner = bastard;
	newmis.think = BastardTimer;
	newmis.nextthink = time + 1;
	newmis.frags = threshold; //Let the timer know what the thresh is

	// Bastard Memory
	// Bastard timer will now continue to live after the bastard leaves the game.
	// If bastard returns before their curse time is complete, they will continue
	// to be punished until penance served. -Pulseczar (Jan 2010)
	newmis.t_s_h = infokey(bastard, "ip");      // Bastard timer will hold bastard's IP and penance time.
	newmis.t_s_h = makestr(newmis.t_s_h);       // Penance time is stored in the timer's .penance_time.

	makeImmune(bastard,time+65);
	//bastard.immune_to_check = time + 65; //Make him immune while purple
	//bastard.old_netname = bastard.netname;

	bprint (#PRINT_MEDIUM, bastard.netname);
	bprint (#PRINT_MEDIUM, " has been struck down by the wrath of the admin.\n");
	bprint (#PRINT_MEDIUM, "Feel free to frag him at will.\n");

	bastard.penance_time = time + 60;
	stuffcmd(bastard, "name \"ÔåáíËéììåò (");
	stuffcmd(bastard, bastard.netname);
	stuffcmd(bastard, ")\"\n");

	// Drop any GoalItems
	te = find (world, classname, "item_tfgoal");
	while (te)
	{
		if (te.owner == bastard)
		{
			// Remove it from the player, if it is supposed to be
			if (!(te.goal_activation & #TFGI_KEEP))
			{
				tfgoalitem_RemoveFromPlayer(te, bastard, 0);
			}

			// CTF support
			if (CTF_Map == #TRUE && te.goal_no == #CTF_FLAG1)
			{
				bprint(#PRINT_HIGH, bastard.netname);
				bprint(#PRINT_HIGH, " ÌÏÓÔ the ÂÌÕÅ flag!\n");
			}
			else if (CTF_Map == #TRUE && te.goal_no == #CTF_FLAG2)
			{
				bprint(#PRINT_HIGH, bastard.netname);
				bprint(#PRINT_HIGH, " ÌÏÓÔ the ÒÅÄ flag!\n");
			}

		}
		te = find(te, classname, "item_tfgoal");
	}

	// Drop any runes too!
	PlayerDropRunes(bastard);

	//return;
};

/*
void() Autoitem_think =
{
	local entity oself;
	local float happy;
	if (self.heat == #TRUE)
		self.heat = #FALSE;
	else
		self.heat = #TRUE;
	happy = self.heat;

	oself = self;
	self = self.owner;
	if (self.tf_items & #NIT_AUTOID) {
		//Do an id
		TeamFortress_ID(#TRUE); //TRUE means we are in autoitemthink
	}
	if (self.weapons_carried & #WEAP_MEDIKIT) {
		//Do a heal, passing it #TRUE tells it not to "tink"
		//Don't automedic whack while fully invisible
		if (!(self.job & #JOB_THIEF && (self.job & #JOB_ACTIVE || self.job & #JOB_FULL_HIDE)))
			W_FireMedikit(#TRUE);
	}
	if (happy) { //Only do this every two seconds
	if (self.tf_items & #NIT_AUTOSCANNER) {
		//Do a scan15
		TeamFortress_Scan(15,#TRUE);
	}
	}

	self = oself;
	self.nextthink = time + 0.5;
};
*/
void() Autoitem_think =
{
	local entity	oself;
	local vector	src;
	local float 	tmp;

	oself = self;
	self = self.owner;

	// Gizmo - made extensive mods to this function, it's now a lot better
	makevectors( self.v_angle );
	src = self.origin + self.view_ofs;
	traceline( src, src + v_forward*2048, #TL_ANY_SOLID, self );

	// if trace_ent is world, everything should still work out fine
	if ( trace_ent != oself.oldenemy ) {
		if (self.tf_items & #NIT_AUTOID) {
			if ( trace_ent != world && trace_ent.solid != #SOLID_BSP )
				//Do an id
				TeamFortress_ID(#TRUE); //TRUE means we are in autoitemthink
			else
				centerprint( self, "" );
		}
		// TODO: set initial crosshair color when spawning
		if ( self.cutf_moreitems & #CUTF_MI_FRIENDORFOE ) {
			if ( trace_ent != world && trace_ent.solid != #SOLID_BSP && trace_ent.takedamage ) {
				// if teamplay is disabled, then always report as an enemy
				if ( teamplay >= 1 ) {
					tmp = GetTeam( trace_ent );

					// team zero when teamplay is on should be neutral
					if ( !tmp )
						stuffcmd( self, "crosshaircolor 254\n" );
					else if ( !Teammate( tmp, self.team_no ) ) {
						// check for spies
						if ( trace_ent.classname == "player" && trace_ent.cutf_items & #CUTF_SPY_KIT && trace_ent.undercover_team != 0 ) {
							if ( Teammate( trace_ent.undercover_team, self.team_no ) )
								stuffcmd( self, "crosshaircolor 210\n" );
							else
								stuffcmd( self, "crosshaircolor 79\n" );
						} else
							stuffcmd( self, "crosshaircolor 79\n" );
					} else
						stuffcmd( self, "crosshaircolor 210\n" );
				} else
					stuffcmd( self, "crosshaircolor 79\n" );
			} else
				stuffcmd( self, "crosshaircolor 254\n" );
		}

		oself.oldenemy = trace_ent;
	}

	if ( oself.attack_finished <= time ) {
		if (self.weapons_carried & #WEAP_MEDIKIT) {
			//Do a heal, passing it #TRUE tells it not to "tink"
			//Don't automedic whack while fully invisible
			if (!(self.job & #JOB_THIEF && (self.job & #JOB_ACTIVE || self.job & #JOB_FULL_HIDE)))
				W_FireMedikit(#TRUE);
		}
		oself.attack_finished = time + 0.5;
	}

	// only do this every second
	if ( oself.pain_finished <= time ) {
		if (self.tf_items & #NIT_AUTOSCANNER) {
			//Do a scan15
			TeamFortress_Scan(15,#TRUE);
		}
		oself.pain_finished = time + 1;
	}

	self = oself;
	self.nextthink = time + 0.1;
};

void() custom_lay =
{
	if (intermission_running)
		return;

	//local string st;
	if (self.last_saveme_sound < time) {
		bprint(#PRINT_HIGH,self.netname);
		bprint(#PRINT_HIGH,"'s legs were broken when he tried to 'lay'\n");
		sound(self,#CHAN_VOICE,"player/pain1.wav",1,#ATTN_NONE);
		self.last_saveme_sound = time + 60;
	}
	self.suicide_time = time + 60;
	self.leg_damage = 8; // Original was 9
	TeamFortress_SetSpeed(self);
	if (self.health > 50) self.health = 50;
	if (self.armorvalue > 10) self.armorvalue = 10;
};

//Blow up all sentries, dispensers and teslas if we can no longer build them
void() DetonateAllGuns =
{
	if (!(self.cutf_items & #CUTF_DISPENSER))
		Find_And_Dmg("building_dispenser", self, 1,0);
	if (!(self.cutf_items & #CUTF_SENTRYGUN)) 
		Find_And_Dmg("building_sentrygun", self, 1,0);
	if (!(self.tf_items & #NIT_TESLA)) //WK
		Find_And_Dmg("building_tesla", self, 1,0);
	if (!(self.tf_items & #NIT_SECURITY_CAMERA)) //CH
		Find_And_Dmg("building_camera", self, 1,0);
	if (!(self.tf_items & #NIT_TELEPORTER)) //CH
		Find_And_Dmg("building_teleporter", self, 1,0);
	if (!(self.cutf_items & #CUTF_SENSOR)) //SB
		Find_And_Dmg("building_sensor", self, 1,0);
	if (!(self.cutf_items & #CUTF_FIELDGEN)) //OfN
		Find_And_Dmg("building_fieldgen", self, 1,0);
};

//Blow up all sentries, dispensers and teslas if we can no longer build them
void() DetonateAllGunsForced =
{
	Find_And_Dmg("building_dispenser", self, 1,0);
	Find_And_Dmg("building_sentrygun", self, 1,0);
	Find_And_Dmg("building_tesla", self, 1,0);
	Find_And_Dmg("building_camera", self, 1,0);
	Find_And_Dmg("building_teleporter", self, 1,0);
	Find_And_Dmg("building_sensor", self, 1,0);
	Find_And_Dmg("building_fieldgen", self, 1,0);
};

//Returns true if the entity is a building -- UPDATE THIS WHEN A NEW ONE IS ADDED
float(entity tester) IsBuilding =
{
	if (
		tester.classname == "building_sentrygun" ||
		tester.classname == "building_sentrygun_base" ||
		tester.classname == "building_tesla" ||
		tester.classname == "building_dispenser" ||
		tester.classname == "building_camera" ||
		tester.classname == "building_arawana" ||
		tester.classname == "building_teleporter"||
		tester.classname == "building_fieldgen"||
		tester.classname == "building_sensor"
	   )
		return #TRUE;
	return #FALSE;
};

void() UpdateWeaponItems =
{
	//#ifdef CUSTOM_PC_USES_ITEMS
	if (self.weapons_carried & #WEAP_SHOTGUN)
		self.items = self.items | #IT_SHOTGUN;
	else
		self.items = self.items - (self.items & #IT_SHOTGUN);

	if (self.weapons_carried & #WEAP_SUPER_SHOTGUN)
		self.items = self.items | #IT_SUPER_SHOTGUN;
	else
		self.items = self.items - (self.items & #IT_SUPER_SHOTGUN);

	if (self.weapons_carried & #WEAP_NAILGUN)
		self.items = self.items | #IT_NAILGUN;
	else
		self.items = self.items - (self.items & #IT_NAILGUN);

	if (self.weapons_carried & (#WEAP_LIGHT_ASSAULT | #WEAP_SNG))
		self.items = self.items | #IT_LIGHT_ASSAULT;// #IT_SUPER_NAILGUN;
	else
		self.items = self.items - (self.items & #IT_LIGHT_ASSAULT);

	if (self.weapons_carried & (#WEAP_GRENADE_LAUNCHER | #WEAP_FLAMETHROWER | #WEAP_DAEDALUS))
		self.items = self.items | #IT_GRENADE_LAUNCHER;
	else
		self.items = self.items - (self.items & #IT_GRENADE_LAUNCHER);

	if (self.weapons_carried & (#WEAP_ROCKET_LAUNCHER | #WEAP_INCENDIARY))
		self.items = self.items | #IT_ROCKET_LAUNCHER;
	else
		self.items = self.items - (self.items & #IT_ROCKET_LAUNCHER);

	if (self.weapons_carried & #WEAP_LIGHTNING)
		self.items = self.items | #IT_LIGHTNING;
	else
		self.items = self.items - (self.items & #IT_LIGHTNING);
	//#endif
};

float(float inp) CanBuyItem =
{
	local float mnu_offset;
	local float mnu_num;
	local float itm_num;

	mnu_offset = self.current_menu - #MENU_PRIMARY_WEAPON;
	mnu_num = mnu_offset - (floor(mnu_offset/3))*3;
	itm_num = inp + (mnu_num * 7);

	if (mnu_offset < 3)
	{
		if (disabledstuff1 & itob(itm_num))
			return #FALSE;
	}
	else if (mnu_offset < 6)
	{
		if (disabledstuff2 & itob(itm_num))
			return #FALSE;
	}
	else if (mnu_offset < 9)
	{
		if (disabledstuff3 & itob(itm_num))
			return #FALSE;
	}
	else if (mnu_offset < 12)
	{
		if (disabledstuff4 & itob(itm_num))
			return #FALSE;
	}
	else if (mnu_offset < 15)
	{
		if (disabledstuff5 & itob(itm_num))
			return #FALSE;
	}
	else
		return #TRUE; // bug, anyway

	return #TRUE;
};

float(float inp) ItemIsFree =
{
	local float mnu_offset;
	local float mnu_num;
	local float itm_num;

	mnu_offset = self.current_menu - #MENU_PRIMARY_WEAPON;
	mnu_num = mnu_offset - (floor(mnu_offset/3))*3;
	itm_num = inp + (mnu_num * 7);

	if (mnu_offset < 3)
	{
		if (givenstuff1 & itob(itm_num))
			return #TRUE;
	}
	else if (mnu_offset < 6)
	{
		if (givenstuff2 & itob(itm_num))
			return #TRUE;
	}
	else if (mnu_offset < 9)
	{
		if (givenstuff3 & itob(itm_num))
			return #TRUE;
	}
	else if (mnu_offset < 12)
	{
		if (givenstuff4 & itob(itm_num))
			return #TRUE;
	}
	else if (mnu_offset < 15)
	{
		if (givenstuff5 & itob(itm_num))
			return #TRUE;
	}
	else
		return #FALSE; // bug, anyway

	return #FALSE;
};
