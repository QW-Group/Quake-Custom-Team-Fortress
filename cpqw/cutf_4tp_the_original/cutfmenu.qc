/*=======================================================//
// CuTFMenu.QC - CustomTF 3.2.OfN		  - 30/10/2004 - //
// by Sergio FumaÒa Grunwaldt - OfteN [cp]				 //
=========================================================//
 All the stuff related to the customizing menu is here
 Moved to its own file for organization purposes
 Here now single price definitions also.. finally! =)
=========================================================*/

string(float itemnum, string itemdesc,float cost,float field, float bit) ConstructMenuItemStr;
string(float itemnum, string itemdesc,float cost) ConstructMenuTeslaStr;
string(float itemnum, string itemdesc,float cost) ConstructMenuSentryStr;
string(float itemnum, string itemdesc,float jobid,float cost, float extra1cost, float extra2cost, string extra1st, string extra2st) ConstructMenuJobStr;
string(float itemnum, string itemdesc,float cost,float grentype) ConstructMenuGrenStr;
string(float itemnum, string itemdesc,float cost) ConstructMenuSpeedStr;
string(float itemnum, string itemdesc,float cost) ConstructMenuHPStr;
float() SpentOnJob;
float() SpentOnGrens;
float() SpentOnLegs;
float() SpentOnHP;
void(entity player) UpdateArmorItem;

// Menu Item Strings
// PAGE 1 - Primary Weapons
#define STR_SNIPERRIFLE 	   "Sniper Rifle    "
#define STR_ASSAULTCANNON	   "Assault Cannon  "	
#define STR_ROCKETLAUNCHER	   "Rocket Launcher "
#define STR_PYROTOYS		   "Pyro Toys       "
#define STR_GRENADELAUNCHER    "Grenade Set     "
#define STR_LIGHTNING		   "Lightning Gun   "
#define STR_LIGHTASSAULT	   "Light Assault   "
// PAGE 2 - Secondary Weapons
#define STR_SNG 			   "Super Nailgun   "
#define STR_KNIFE			   "Knife           "
#define STR_SUPERSHOTGUN	   "Double Barrel   "
#define STR_RAILGUN 		   "Rail Gun        "
#define STR_NAILGUN 		   "Nail Gun        "
#define STR_TRANQ			   "Tranquilizer    "
#define STR_SHOTGUN 		   "Single Barrel   "
// PAGE 3 - Misc/Extra Weapons
#define STR_MAUSER			   "Mauser          "
#define STR_AIRF			   "Air-Fist        "
#define STR_AIRFISTUPGRADE	   "Airfist upgrade "
#define STR_DAEDALUS		   "Impulse Rifle   "
#define STR_LASERCANNON 	   "Laser Cannon    "
#define STR_HOLO			   "Holo Device     "
#define STR_CLIPEXTEND			"Clip Extender   "
// PAGE 4 - Tools
#define STR_ZEROGRAVITY 		"Zero-Gravity Gun"
// PAGE 5 - Leg Enhancements
#define STR_SPEED1			   "Cheetah         "
#define STR_SPEED2			   "Cougar          "
#define STR_SPEED3			   "White Rhino     "
#define STR_SPEED4			   "Scrub Jay       "
#define STR_SPEED5			   "KGB Officer     "
#define STR_SPEED6			   "Black Mamba     "
#define STR_SPEED7			   "ImperialPenguin "
// PAGE 6 - Health/Armor
#define STR_HP1 			   "50Ø75 Green     "
#define STR_HP2 			   "50Ø90 Green     "
#define STR_HP3 			   "100Ø80 Yellow   "
#define STR_HP4 			   "120Ø90 Yellow   "
#define STR_HP5 			   "150Ø100 Yellow  "
#define STR_HP6 			   "200Ø100 Red     "
#define STR_HP7 			   "300Ø100 Red     "
// PAGE 7 - Special Armors & Ammo
#define STR_CERAMIC 		   "Ceramic Armor   "
#define STR_GET 			   "Impact Armor    "
#define STR_ASBESTOS		   "Asbestos Armor  "
#define STR_KEVLAR			   "Kevlar Armor    "
#define STR_BLAST			   "Blast Armor     "
#define STR_AMMOBACKPACK	   "Ammo Backpack   "
#define STR_AMMOBANDOLIER	   "Ammo Bandolier  "
// PAGE 8 - Special Items
#define STR_SCANNER 		   "Scanner         "
#define STR_AUTOSCANNER 	   "  Auto-Scanner  "
#define STR_DETPACK 		   "Detpack         "
#define STR_MEDIKIT 		   "Medikit         "
#define STR_SPYKIT			   "Spy Kit         "
#define STR_SCUBA			   "Scuba Gear      "
#define STR_HOOK			   "Grapple         "
// PAGE 9 - More Special Items
#define STR_JAMMER			   "Scanner Jammer  "
#define STR_CYBERAUG		   "CyberAug Unit   "
#define STR_SENSOR			   "Motion Sensor   "
#define STR_FIELDGEN		   "Field Generator "
#define STR_FULLARMOUR		   "Full Armour     "
#define STR_TOSSABLEDET 	   "C4 Tossable Det "
#define STR_DISPENSER		   "Dispenser       "
// PAGE 10 - Combat Grenades
#define STR_GR_NORMAL		   "Normal          "
#define STR_GR_NAPALM		   "Napalm          "
#define STR_GR_GAS			   "Gas             "
#define STR_GR_EMP			   "EMP             "
#define STR_GR_FRAG 		   "Frag            "
#define STR_GR_NAIL 		   "Nail            "
#define STR_GR_MIRV 		   "MIRV            "
// PAGE 11 - Utility Grenades
#define STR_GR_FLARE		   "Flare           "
#define STR_GR_CALTROP		   "Caltrop         "
#define STR_GR_CONCUSSION	   "Concussion      "
#define STR_GR_PSIONIC		   "Psionic         "
#define STR_GR_ANTIGRAV 	   "AntiGrav        "
#define STR_GR_BIOLOGICAL	   "Biological      "
#define STR_GR_KRAC 		   "Krac            "
// PAGE 12 - Engineering
#define STR_SPANNER 		   "Spanner         "
#define STR_SENTRYGUN		   "Sentry Gun      "
#define STR_SENTRYUPGRADE	   " Sentry Upgrade "
#define STR_TESLACOIL		   "Tesla Coil      "
#define STR_TESLAUPGRADE	   "  Tesla Upgrade "
#define STR_SECURITYCAMERA	   "Security Camera "
#define STR_TELEPORTER		   "Teleporter Pads "
// PAGE 13 - Professions
#define STR_THIEF			   "Thief     ®Hide©"
#define STR_RUNNER			   "Runner  ®Sprint©"
#define STR_WARLOCK 		   "Warlock ®Summon©"
  #define STR_WARLOCK_EXTRA1   "2nd Extra Soul  "
  #define STR_WARLOCK_EXTRA2   "3rd Extra Soul  "
#define STR_CHAPLAN 		   "Chaplan®Inspire©"
#define STR_BERSERKER		   "Berserker ®Fury©"
#define STR_GUERILLA		   "Guerilla ®Mines©"
  #define STR_GUERILLA_EXTRA1  "Mine Technician "
  #define STR_GUERILLA_EXTRA2  "Mine Specialist "
#define STR_JUDOKA			   "Judoka  ®Disarm©"
// PAGE 14 - More Professions
#define STR_ARMY			   "Army  ®Soldiers©"
  #define STR_ARMY_EXTRA1	   "Extra Reserve 2 "
  #define STR_ARMY_EXTRA2	   "Extra Reserve 3 "
#define STR_HACKER			   "CyberNet  ®Hack©"
#define STR_MARTYR			   "Martyr ®Suicide©"
#define STR_CRUSADER		   "Crusader ®Auras©"
// PAGE 15 - Proficiencies
#define STR_STEALTH 		   "Stealth         "
#define STR_HIGHJUMP		   "Highjump        "
#define STR_HWGUY			   "Aspect of HWGuy "
#define STR_EXPBODY 		   "Exp. Body       "
#define STR_GYMNAST 		   "Gymnast         "
#define STR_DEMONLORE		   "Demon Lore      "
#define STR_CLOSECOMBAT 	   "Close Combat    "
// PAGE 16 - Optional Equipment
#define STR_AUTOID			   "Auto-ID         "
#define STR_RESPAWNGUARD	   "Respawn Guard   "
#define STR_HOVERBOOTS		   "Hover Boots     "
#define STR_BOOTUPGRADE 	   "  Boot Upgrade  "
#define STR_RLASERGUIDED	   "Laser Guided RL "
#define STR_OTR 			   "OTR Bullets     "
#define STR_CLUSTER 		   "Cluster Rockets "
// PAGE 17 - More Equipment
#define STR_FASTERROCKETS		"Faster Rockets  "
#define STR_FRIENDORFOE			"Friend or Foe   "

#define STR_SELLEXTRAS		   "Sell stuff back "

// For the love of god, we needed this before!! (easily tweakable, SINGLE VALUES!)
// PAGE 1 - Primary Weapons
#ifdef CLASSIC_SNIPER_RIFLE
	#define COST_SNIPERRIFLE		5000
#else
	#define COST_SNIPERRIFLE		4800
#endif
#define COST_ASSAULTCANNON		3000   
#define COST_ROCKETLAUNCHER 	3000
#define COST_PYROTOYS			3000
#define COST_GRENADELAUNCHER	2200
#define COST_LIGHTNING			2200
#define COST_LIGHTASSAULT		1800
// PAGE 2 - Secondary Weapons
#define COST_SNG				 800
#define COST_KNIFE				 650
#define COST_SUPERSHOTGUN		 575
#define COST_RAILGUN			 500
#define COST_NAILGUN			 400
#define COST_TRANQ				 300
#define COST_SHOTGUN			  50
// PAGE 3 - Misc/Extra Weapons
#define COST_MAUSER 			2400
#define COST_AIRF				2000
#define COST_AIRFISTUPGRADE 	1850
#define COST_DAEDALUS			1500
#define COST_LASERCANNON		1400
#define COST_HOLO				1200
#define COST_CLIPEXTEND 		 600
// PAGE 4 - Tools
#define COST_ZEROGRAVITY		1000
// PAGE 5 - Leg Enhancements
#define COST_SPEED1 			9000
#define COST_SPEED2 			6000
#define COST_SPEED3 			3250
#define COST_SPEED4 			2500
#define COST_SPEED5 			1250
#define COST_SPEED6 			 500
// PAGE 6 - Health/Armor
#define COST_HP1				 150
#define COST_HP2				 450
#define COST_HP3				 700
#define COST_HP4				1200
#define COST_HP5				1800
#define COST_HP6				2700
#define COST_HP7				4100
// PAGE 7 - Special Armors & Ammo
#define COST_CERAMIC			 575
#define COST_GET				 625
#define COST_ASBESTOS			 750
#define COST_KEVLAR 			1200
#define COST_BLAST				1500
#define COST_AMMOBACKPACK		 300
#define COST_AMMOBANDOLIER		 200
// PAGE 8 - Special Items
#define COST_SCANNER			 650
#define COST_AUTOSCANNER		 250
#define COST_DETPACK			 800
#define COST_MEDIKIT			1550
#define COST_SPYKIT 			2000
#define COST_SCUBA				1000
#define COST_HOOK				3000
// PAGE 9 - More Special Items
#define COST_JAMMER 			1000
#define COST_CYBERAUG			 800
#define COST_SENSOR 			 450
#define COST_FIELDGEN			1400
#define COST_FULLARMOUR 		 250
#define COST_TOSSABLEDET		1200
#define COST_DISPENSER			 600
// PAGE 10 - Combat Grenades
#define COST_GR_NORMAL			 500
#define COST_GR_NAPALM			1400
#define COST_GR_GAS 			1300
#define COST_GR_EMP 			1200
#define COST_GR_FRAG			1300
#define COST_GR_NAIL			1400
#define COST_GR_MIRV			1500
// PAGE 11 - Utility Grenades
#define COST_GR_FLARE			 300
#define COST_GR_CALTROP 		 500
#define COST_GR_CONCUSSION		1000
#define COST_GR_PSIONIC 		1200
#define COST_GR_ANTIGRAV		1000
#define COST_GR_BIOLOGICAL		1100
#define COST_GR_KRAC			1400
// PAGE 12 - Engineering
#define COST_SPANNER			1200
#define COST_SENTRYGUN			1500
#define COST_SENTRYUPGRADE		 700
#define COST_TESLACOIL			1350
#define COST_TESLAUPGRADE		1650
#define COST_SECURITYCAMERA 	 350
#define COST_TELEPORTER 		1100
// PAGE 13 - Professions
#define COST_THIEF				 950
#define COST_RUNNER 			 400
#define COST_WARLOCK			1150
  #define COST_WARLOCK_EXTRA1	 700
  #define COST_WARLOCK_EXTRA2	 950
#define COST_CHAPLAN			1200
#define COST_BERSERKER			1200
#define COST_GUERILLA			1600
  #define COST_GUERILLA_EXTRA1	 700
  #define COST_GUERILLA_EXTRA2	 950
#define COST_JUDOKA 			1250
// PAGE 14 - More Professions
#define COST_ARMY				1250
  #define COST_ARMY_EXTRA1		 700
  #define COST_ARMY_EXTRA2		 950
#define COST_HACKER 			1200
#define COST_MARTYR 			1000
#define COST_CRUSADER			1600
// PAGE 15 - Proficiencies
#define COST_STEALTH			 400
#define COST_HIGHJUMP			 500 // Original was 200
#define COST_HWGUY				 450
#define COST_EXPBODY			1200
#define COST_GYMNAST			 450
#define COST_DEMONLORE			 300
#define COST_CLOSECOMBAT		 600
// PAGE 16 - Optional Equipment
#define COST_AUTOID 			  25
#define COST_RESPAWNGUARD		  25
#define COST_HOVERBOOTS 		 850
#define COST_BOOTUPGRADE		 350
#define COST_RLASERGUIDED		1000
#define COST_OTR				1850
#define COST_CLUSTER			3250
// PAGE 17 - More Equipment
#define COST_FASTERROCKETS		800
#define COST_FRIENDORFOE		25

// Leg settings (Speeds)
#define CUSTOM_SPEED1	410 // Cheetah (shaka original = 650)
#define CUSTOM_SPEED2	370 // Cougar (shaka original = 420)
#define CUSTOM_SPEED3	330
#define CUSTOM_SPEED4	310
#define CUSTOM_SPEED5	290
#define CUSTOM_SPEED6	270
#define CUSTOM_SPEED7	250 // Imperial Penguin

// Char used to visually indicate a purchased item (DO NOT USE QUOTES!)
//#define CHAR_BOUGHT * // <-- Classic "*" char
#define CHAR_BOUGHT ú	// small yellow dot

//==============================================================================
// The following "ancient" functions have been there doing the work for years
// I feel sad removing them, so they r still here :P

//----------------------------------------------------------------------
// Rod May	kk@rod.net
// mstr and mstr2 and eqstr only exist to cut down on a crap load of code.
//
/*string(float v,float m1,float m2,string s1,string s2,string s3,string s4) mstr =
{
	// return string for matching masks (m1 and m2) on value v.
	// neither match: s1, first only: s2, second only: s3, both: s4

	if ((v & m1) && (v & m2)) return s4;
	if (v & m1) return s2;
	if (v & m2) return s3;
	return s1;
};
string(float v1,float v2,float m1,float m2,string s1,string s2,string s3,string s4) mstr2 =
{
	// same func as above but with a value for each mask.
	// return string for matching mask m1 on value v1, and m2 on v2.

	if ((v1 & m1) && (v2 & m2)) return s4;
	if (v1 & m1) return s2;
	if (v2 & m2) return s3;
	return s1;
};*/
/*string(float v,float v1,float v2,string s1,string s2,string s3) eqstr =
{
	// return string based on v equals values v1 OR v2
	// neither equal: s1, first only: s2, second only: s3

	if (v == v1) return s2;
	if (v == v2) return s3;
	return s1;
};*/
//----------------------------------------------------------------------
//----------------------------------------------------------------------

//WK =====================================================================
//	Prints Menu of Primary Weapons Available
//	 =====================================================================
void() Menu_PrimaryWeapon =
{
	local string temp;
	temp = ftos(self.money);
	
	if (self.tfstate & #TFSTATE_NOTENOUGHMONEY)
		temp = colstr(temp,#COLSTR_RED);
	
	MenuResetCount();
	
	local string msg_custom;
	local string l1,l2,l3,l4, str;

	l1 = ConstructMenuItemStr(1,#STR_SNIPERRIFLE,#COST_SNIPERRIFLE,self.weapons_carried,#WEAP_SNIPER_RIFLE);
	str = ConstructMenuItemStr(2,#STR_ASSAULTCANNON,#COST_ASSAULTCANNON,self.weapons_carried,#WEAP_ASSAULT_CANNON);
	l1 = strcat(l1,str);

	l2 = ConstructMenuItemStr(3,#STR_ROCKETLAUNCHER,#COST_ROCKETLAUNCHER,self.weapons_carried,#WEAP_ROCKET_LAUNCHER);
	str = ConstructMenuItemStr(4,#STR_PYROTOYS,#COST_PYROTOYS,self.weapons_carried,#WEAP_INCENDIARY);
	l2 = strcat(l2,str);

	l3 = ConstructMenuItemStr(5,#STR_GRENADELAUNCHER,#COST_GRENADELAUNCHER,self.weapons_carried,#WEAP_GRENADE_LAUNCHER);
	str = ConstructMenuItemStr(6,#STR_LIGHTNING,#COST_LIGHTNING,self.weapons_carried,#WEAP_LIGHTNING);
	l3 = strcat(l3,str);

	l4 = ConstructMenuItemStr(7,#STR_LIGHTASSAULT,#COST_LIGHTASSAULT,self.weapons_carried,#WEAP_LIGHT_ASSAULT);
	l4 = strcat(l4,"..         \n.. ŒÂ¯Ù    \n.. ƒÔÓÂ!   \n");

	if (self.done_custom & #CUSTOM_SELLING)
		msg_custom	= " dollars left\n\n*CURRENTLY SELLING FRAGS*\nTyping √’”‘œÕ again will waste your cash\n";
	else
		msg_custom =  " dollars left\n\nUse the √’”‘œÕ command to start over\nUse the ’–«“¡ƒ≈ command to sell frags\n";

	centerprint(self,"úãê CısÙoÌi˙e ŸÔıÚÛÂÏÊ ãú\nãú Primary Weapons    úã\n\n",l1,l2,l3,l4,temp,msg_custom);
};													   

void(float inp) Menu_PrimaryWeapon_Input =
{
	if (inp <= 10 && inp >= 1)
	{
//Snipe
		if (inp == 1)
				if (self.weapons_carried & #WEAP_SNIPER_RIFLE) //Already have it
				{
					PrintRefund(#COST_SNIPERRIFLE);
					self.weapons_carried = self.weapons_carried - #WEAP_SNIPER_RIFLE;
					self.weapons_carried = self.weapons_carried - #WEAP_AUTO_RIFLE;
					self.maxammo_shells = self.maxammo_shells - 75;
					Menu_PrimaryWeapon();
				}
				else if (self.money >= #COST_SNIPERRIFLE) {
					self.money = self.money - #COST_SNIPERRIFLE;
					self.weapons_carried = self.weapons_carried | #WEAP_SNIPER_RIFLE | #WEAP_AUTO_RIFLE;
					self.maxammo_shells = self.maxammo_shells + 75;
					PrintMoney();
					Menu_PrimaryWeapon();
				}
				else
					PrintNotEnoughMoney(#COST_SNIPERRIFLE);
			
		if (inp == 2)
		{
			BuyWeapon(#COST_ASSAULTCANNON,#WEAP_ASSAULT_CANNON);
			Menu_PrimaryWeapon();
		}
		if (inp == 3)
		{
			BuyWeapon(#COST_ROCKETLAUNCHER,#WEAP_ROCKET_LAUNCHER);			
			Menu_PrimaryWeapon();
			UpdateWeaponItems();
		}
//IC
		if (inp == 4)
		{
			if (self.weapons_carried & #WEAP_INCENDIARY) //Already have it
			{
				//Clean up asbestos armor
				if (!(self.tf_items & #NIT_ASBESTOS))
					self.money = self.money - #COST_ASBESTOS; //Sync this with asbestos
				self.tf_items = self.tf_items - (self.tf_items & #NIT_ASBESTOS);

				PrintRefund(#COST_PYROTOYS);
				self.weapons_carried = self.weapons_carried - #WEAP_INCENDIARY;
				self.weapons_carried = self.weapons_carried - #WEAP_FLAMETHROWER;
				self.maxammo_cells = self.maxammo_cells - 200;
				self.maxammo_rockets = self.maxammo_rockets - 60;
				Menu_PrimaryWeapon();
			}
			else if (self.money >= #COST_PYROTOYS)
			{
				self.money = self.money - #COST_PYROTOYS;
				self.weapons_carried = self.weapons_carried | #WEAP_INCENDIARY | #WEAP_FLAMETHROWER;
				//Give em asbestos armor, and a refund if they have it
				if (self.tf_items & #NIT_ASBESTOS)
					self.money = self.money + #COST_ASBESTOS; //Sync this with asbestos price
				self.tf_items = self.tf_items | #NIT_ASBESTOS;

				
				self.maxammo_cells = self.maxammo_cells + 200;
				self.maxammo_rockets = self.maxammo_rockets + 60;
				PrintMoney();
				Menu_PrimaryWeapon();
			}
			else
				PrintNotEnoughMoney(#COST_PYROTOYS);

			UpdateWeaponItems();
		}
		if (inp == 5)
		{
				BuyWeapon(#COST_GRENADELAUNCHER,#WEAP_GRENADE_LAUNCHER);
				Menu_PrimaryWeapon();
				UpdateWeaponItems();
		}
		if (inp == 6)
		{
				BuyWeapon(#COST_LIGHTNING,#WEAP_LIGHTNING);
				Menu_PrimaryWeapon();
				UpdateWeaponItems();
		}
		if (inp == 7)
		{
				BuyWeapon(#COST_LIGHTASSAULT,#WEAP_LIGHT_ASSAULT);
				Menu_PrimaryWeapon();
				UpdateWeaponItems();
		}
		if (inp == 9)
		{
			CuTFMenuSound(#MENUSOUND_BROWSE);
			self.current_menu = #MENU_SECONDARY_WEAPON;
			Menu_SecondaryWeapon(); 		
		}
		if (inp == 10)
		{
			DropFromCustomClassGen();
		}

		self.impulse = 0;
	}
	// Otherwise, the impulse is passed on
	// SB to where, nobody knows
};

// ====================================================================
//	Prints Menu of Secondary Weapons Available
// ====================================================================
void() Menu_SecondaryWeapon =
{
	local string temp;
	temp = ftos(self.money);
	
	if (self.tfstate & #TFSTATE_NOTENOUGHMONEY)
		temp = colstr(temp,#COLSTR_RED);
		
	local string l1,l2,l3,l4, str;

	MenuResetCount();

	l1 = ConstructMenuItemStr(1,#STR_SNG,#COST_SNG,self.weapons_carried,#WEAP_SNG);
	str = ConstructMenuItemStr(2,#STR_KNIFE,#COST_KNIFE,self.cutf_items,#CUTF_KNIFE);
	l1 = strcat(l1,str);

	l2 = ConstructMenuItemStr(3,#STR_SUPERSHOTGUN,#COST_SUPERSHOTGUN,self.weapons_carried,#WEAP_SUPER_SHOTGUN);
	str = ConstructMenuItemStr(4,#STR_RAILGUN,#COST_RAILGUN,self.weapons_carried,#WEAP_RAILGUN);
	l2 = strcat(l2,str);

	l3 = ConstructMenuItemStr(5,#STR_NAILGUN,#COST_NAILGUN,self.weapons_carried,#WEAP_NAILGUN);
	str = ConstructMenuItemStr(6,#STR_TRANQ,#COST_TRANQ,self.weapons_carried,#WEAP_TRANQ);
	l3 = strcat(l3,str);

	l4 = ConstructMenuItemStr(7,#STR_SHOTGUN,#COST_SHOTGUN,self.weapons_carried,#WEAP_SHOTGUN);
	l4 = strcat(l4,".. –ÚÂˆ    \n.. ŒÂ¯Ù    \n.. ƒÔÓÂ!   \n");

	centerprint(self, "úãê CısÙoÌi˙e ŸÔıÚÛÂÏÊ ãú\nãúê Secondary Weapons  úã\n\n",l1,l2,l3,l4,temp," dollars left\n");
};

void(float inp) Menu_SecondaryWeapon_Input =
{ 
  if (inp <= 10 && inp >= 1)
  {
	if (inp == 1) {
		BuyWeapon(#COST_SNG,#WEAP_SNG);
		Menu_SecondaryWeapon();
		UpdateWeaponItems();
	}

//Knife
	if (inp == 2) {
		if (self.cutf_items & #CUTF_KNIFE) //Already have it
		{
			//Clean up knife-less warlocks (sync this with Custom.qc)
			if (self.job & #JOB_WARLOCK) { // OfN Fix getting extra money with demon lore
				sprint(self, #PRINT_HIGH, "You will need this knife being a warlock!\n");
				CuTFMenuSound(#MENUSOUND_WRONG);
				self.impulse=0;
				return;
			}

			PrintRefund(#COST_KNIFE);
			self.cutf_items = self.cutf_items - #CUTF_KNIFE;
			Menu_SecondaryWeapon();
		}
		else if (self.money >= #COST_KNIFE) {
			self.money = self.money - #COST_KNIFE;
			self.cutf_items = self.cutf_items | #CUTF_KNIFE;
			PrintMoney();
			Menu_SecondaryWeapon();
		}
		else
			PrintNotEnoughMoney(#COST_KNIFE);
	}
	if (inp == 3) {
		BuyWeapon(#COST_SUPERSHOTGUN,#WEAP_SUPER_SHOTGUN);
		Menu_SecondaryWeapon();
		UpdateWeaponItems();
	}
	if (inp == 4) {
		BuyWeapon(#COST_RAILGUN,#WEAP_RAILGUN);
		Menu_SecondaryWeapon();
	}
	if (inp == 5) {
		BuyWeapon(#COST_NAILGUN,#WEAP_NAILGUN);
		Menu_SecondaryWeapon();
		UpdateWeaponItems();
	}
	if (inp == 6) {
		BuyWeapon(#COST_TRANQ,#WEAP_TRANQ);
		Menu_SecondaryWeapon();
	}
	if (inp == 7) {
		BuyWeapon(#COST_SHOTGUN,#WEAP_SHOTGUN);
		Menu_SecondaryWeapon();
		UpdateWeaponItems();
	}
	if (inp == 8) {
		CuTFMenuSound(#MENUSOUND_BROWSE);
		self.current_menu = #MENU_PRIMARY_WEAPON;
		Menu_PrimaryWeapon();
		
	}
	if (inp == 9)
	{
		CuTFMenuSound(#MENUSOUND_BROWSE);
		self.current_menu = #MENU_MISC_WEAPON;
		Menu_MiscWeapon();		  
	}
	if (inp == 10)
	{
		DropFromCustomClassGen();
	}

	 self.impulse = 0;
  }
};


// ====================================================================
//	Prints Menu of Secondary Weapons Available
// ====================================================================
void() Menu_MiscWeapon =
{
	local string temp;
	temp = ftos(self.money);
	
	if (self.tfstate & #TFSTATE_NOTENOUGHMONEY)
		temp = colstr(temp,#COLSTR_RED);
	
	local string l1,l2,l3,l4, str;

	MenuResetCount();

	l1 = ConstructMenuItemStr(1,#STR_MAUSER,#COST_MAUSER,self.weapons_carried,#WEAP_MAUSER);
	str = ConstructMenuItemStr(2,#STR_AIRF,#COST_AIRF,self.weapons_carried,#WEAP_AIRF);
	l1 = strcat(l1,str);

	l2 = ConstructMenuItemStr(3,#STR_AIRFISTUPGRADE,#COST_AIRFISTUPGRADE,self.cutf_items,#CUTF_AIRFISTUPGRADE);
	str = ConstructMenuItemStr(4,#STR_DAEDALUS,#COST_DAEDALUS,self.weapons_carried,#WEAP_DAEDALUS);
	l2 = strcat(l2,str);

	l3 = ConstructMenuItemStr(5,#STR_LASERCANNON,#COST_LASERCANNON,self.weapons_carried,#WEAP_LASERCANNON);
	str = ConstructMenuItemStr(6,#STR_HOLO,#COST_HOLO,self.cutf_items,#CUTF_HOLO);
	l3 = strcat(l3,str);

	l4 = ConstructMenuItemStr(7,#STR_CLIPEXTEND,#COST_CLIPEXTEND,self.cutf_items,#CUTF_CLIPEXTEND);
	l4 = strcat(l4,".. –ÚÂˆ    \n.. ŒÂ¯Ù    \n.. ƒÔÓÂ!   \n");

	centerprint(self, "úãê CısÙoÌi˙e ŸÔıÚÛÂÏÊ ãú\nãúê MiscØExtra Weapons úã\n\n",l1,l2,l3,l4,temp," dollars left\n");
};

void(float inp) Menu_MiscWeapon_Input =
{ 
  if (inp <= 10 && inp >= 1)
  {

		if (inp == 1) {
			BuyWeapon(#COST_MAUSER, #WEAP_MAUSER);
			//sprint(self, #PRINT_HIGH, "Unfortunately all stocks of this item have been requisitioned to increase the glory of the Queen. God save the Queen!\n");
			Menu_MiscWeapon();
		}
		if (inp == 2) {

			BuyWeapon(#COST_AIRF,#WEAP_AIRF);
			//sprint(self, #PRINT_HIGH, "Unfortunately all stocks of this item have been requisitioned to increase the glory of the Queen. God save the Queen!\n");
			Menu_MiscWeapon();
		}

		if (inp == 3) {
			if (!(self.weapons_carried & #WEAP_AIRF) && !(self.cutf_items & #CUTF_AIRFISTUPGRADE))
			{
				sprint(self,#PRINT_HIGH,"You need to buy an airfist to use the upgrade!\n");
				CuTFMenuSound(#MENUSOUND_WRONG);
			}
			else
			{
				BuyCuTF(#COST_AIRFISTUPGRADE,#CUTF_AIRFISTUPGRADE);
				Menu_MiscWeapon();
			}
		}

		if (inp == 4) {

			BuyWeapon(#COST_DAEDALUS,#WEAP_DAEDALUS);
			Menu_MiscWeapon();
		}
		if (inp == 5) {
		
			BuyWeapon(#COST_LASERCANNON,#WEAP_LASERCANNON);
			Menu_MiscWeapon();
			
		}
		if (inp == 6) {
			BuyCuTF(#COST_HOLO,#CUTF_HOLO);
			Menu_MiscWeapon();
		}

		if (inp == 7) {
			BuyCuTF(#COST_CLIPEXTEND,#CUTF_CLIPEXTEND);
			Menu_MiscWeapon();
		}
	   
		if (inp == 8) {
			CuTFMenuSound(#MENUSOUND_BROWSE);
			self.current_menu = #MENU_SECONDARY_WEAPON;
			Menu_SecondaryWeapon();
			
		}
		if (inp == 9)
		{
			CuTFMenuSound(#MENUSOUND_BROWSE);
			self.current_menu = #MENU_TOOLS;
			Menu_ToolWeapon();			
		}
		if (inp == 10)
		{
			DropFromCustomClassGen();
		}
		
	 self.impulse = 0;
  }
};


// ====================================================================
//	Tools - Gizmo
// ====================================================================
void() Menu_ToolWeapon =
{
	local string temp;
	temp = ftos(self.money);
	
	if (self.tfstate & #TFSTATE_NOTENOUGHMONEY)
		temp = colstr(temp,#COLSTR_RED);
	
	local string l1,l2,l3,l4, str;

	MenuResetCount();

	l1 = ConstructMenuItemStr(1,#STR_ZEROGRAVITY,#COST_ZEROGRAVITY,self.weapons_carried,#WEAP_ZEROGRAVITY);
	str = "\n";
	l1 = strcat(l1,str);

	l2 = l3 = "\n\n";

	l4 = "\n";
	l4 = strcat(l4,".. –ÚÂˆ    \n.. ŒÂ¯Ù    \n.. ƒÔÓÂ!   \n");

	centerprint(self, "úãê CısÙoÌi˙e ŸÔıÚÛÂÏÊ ãú\nãúê Tools              úã\n\n", l1, l2, l3, l4, temp," dollars left\n");
};

void(float inp) Menu_ToolWeapon_Input =
{ 
  if (inp <= 10 && inp >= 1)
  {

		if (inp == 1) {
#ifndef NO_ZEROGRAVGUN
			BuyWeapon(#COST_ZEROGRAVITY, #WEAP_ZEROGRAVITY);
			Menu_ToolWeapon ();
#else
			sprint( self, #PRINT_HIGH, "The Zero-Gravity Gun has been disabled in this compilation\n" );
			CuTFMenuSound( #MENUSOUND_WRONG );
#endif
		}
	   
		if (inp == 8) {
			CuTFMenuSound(#MENUSOUND_BROWSE);
			self.current_menu = #MENU_MISC_WEAPON;
			Menu_MiscWeapon();
			
		}
		if (inp == 9)
		{
			CuTFMenuSound(#MENUSOUND_BROWSE);
			self.current_menu = #MENU_LEGS;
			Menu_Legs();			
		}
		if (inp == 10)
		{
			DropFromCustomClassGen();
		}
		
	 self.impulse = 0;
  }
};


// =============================
//	Prints Menu of Legs for Sale
// =============================
void() Menu_Legs =
{
	local string temp;
	temp = ftos(self.money);
	
	if (self.tfstate & #TFSTATE_NOTENOUGHMONEY)
		temp = colstr(temp,#COLSTR_RED);
	
	local string l1,l2,l3,l4,str;

	MenuResetCount();

/*
650  9000
420  6000
330  3250
310  2500
290  1250
270  500
250  0
*/

	l1 = ConstructMenuSpeedStr(1,#STR_SPEED1,#COST_SPEED1);
	str = ConstructMenuSpeedStr(2,#STR_SPEED2,#COST_SPEED2);
	l1 = strcat(l1,str);

	l2 = ConstructMenuSpeedStr(3,#STR_SPEED3,#COST_SPEED3);
	str = ConstructMenuSpeedStr(4,#STR_SPEED4,#COST_SPEED4);
	l2 = strcat(l2,str);

	l3 = ConstructMenuSpeedStr(5,#STR_SPEED5,#COST_SPEED5);
	str = ConstructMenuSpeedStr(6,#STR_SPEED6,#COST_SPEED6);
	l3 = strcat(l3,str);

	l4 = ConstructMenuSpeedStr(7,#STR_SPEED7,0);
	l4 = strcat(l4,".. –ÚÂˆ    \n.. ŒÂ¯Ù    \n.. ƒÔÓÂ!   \n");

	centerprint(self, "úãê CısÙoÌi˙e ŸÔıÚÛÂÏÊ ãú\nãúê Leg Enhancements   úã\n\n", l1,l2,l3,l4, temp," dollars left\n");
};							  

void(float inp) Menu_Legs_Input =
{

	//First, prevent them from getting high speed while upgraded
	if (inp < 3 && self.done_custom & #CUSTOM_SELLING)
	{
		sprint(self,#PRINT_HIGH,"The upgraded CustomTF soldier is a fighting machine. He doesn't have access to fast legs\n");
		CuTFMenuSound(#MENUSOUND_WRONG);
		self.impulse = 0;
		return;
	}

	//Second, sell off our current legs
	if (inp < 8) {
	if (self.custom_speed == #CUSTOM_SPEED1) { //400 Original 650
		PrintRefund(#COST_SPEED1);
		self.custom_speed = #CUSTOM_SPEED7;
		if (self.impulse == 1) {self.impulse = 0; Menu_Legs(); return;}
	}
	else if (self.custom_speed == #CUSTOM_SPEED2) { //360 Original 420
		PrintRefund(#COST_SPEED2);
		self.custom_speed = #CUSTOM_SPEED7;
		if (self.impulse == 2) {self.impulse = 0; Menu_Legs();	return;}
	}
	else if (self.custom_speed == #CUSTOM_SPEED3) { // Original 330
		PrintRefund(#COST_SPEED3);
		self.custom_speed = #CUSTOM_SPEED7;
		if (self.impulse == 3) {self.impulse = 0; Menu_Legs();	return;}
	}
	else if (self.custom_speed == #CUSTOM_SPEED4) { // Original 310
		PrintRefund(#COST_SPEED4);
		self.custom_speed = #CUSTOM_SPEED7;
		if (self.impulse == 4) {self.impulse = 0; Menu_Legs();	return;}
	}
	else if (self.custom_speed == #CUSTOM_SPEED5) {
		PrintRefund(#COST_SPEED5);
		self.custom_speed = #CUSTOM_SPEED7;
		if (self.impulse == 5) {self.impulse = 0; Menu_Legs();	return;}
	}
	else if (self.custom_speed == #CUSTOM_SPEED6) {
		PrintRefund(#COST_SPEED6);
		self.custom_speed = #CUSTOM_SPEED7;
		if (self.impulse == 6) {self.impulse = 0; Menu_Legs();	return;}
	}
	}
	
	if (inp == 1) {
		if (self.money >= #COST_SPEED1) {
			self.money = self.money - #COST_SPEED1;
			self.custom_speed = #CUSTOM_SPEED1; // Original 650
			PrintMoney();
			Menu_Legs();
		}
		else
			PrintNotEnoughMoney(#COST_SPEED1);
	}
	if (inp == 2) {
		if (self.money >= #COST_SPEED2) {
			self.money = self.money - #COST_SPEED2;
			self.custom_speed = #CUSTOM_SPEED2; // Original 420
			PrintMoney();
			Menu_Legs();
		}
		else
			PrintNotEnoughMoney(#COST_SPEED2);
	}
	if (inp == 3) {
		if (self.money >= #COST_SPEED3) {
			self.money = self.money - #COST_SPEED3;
			self.custom_speed = #CUSTOM_SPEED3;
			PrintMoney();
			Menu_Legs();
		}
		else
			PrintNotEnoughMoney(#COST_SPEED3);
	}
	if (inp == 4) {
		if (self.money >= #COST_SPEED4) {
			self.money = self.money - #COST_SPEED4;
			self.custom_speed = #CUSTOM_SPEED4;
			PrintMoney();
			Menu_Legs();
		}
		else
			PrintNotEnoughMoney(#COST_SPEED4);
	}
	if (inp == 5) {
		if (self.money >= #COST_SPEED5) {
			self.money = self.money - #COST_SPEED5;
			self.custom_speed = #CUSTOM_SPEED5;
			PrintMoney();
			Menu_Legs();
		}
		else
			PrintNotEnoughMoney(#COST_SPEED5);
	}
	if (inp == 6) {
		if (self.money >= #COST_SPEED6) {
			self.money = self.money - #COST_SPEED6;
			self.custom_speed = #CUSTOM_SPEED6;
			PrintMoney();
			Menu_Legs();
		}
		else
			PrintNotEnoughMoney(#COST_SPEED6);
	}	
	
	if (inp == 7) {
		/*if (self.money >= #PRICE) {
			self.money = self.money - #PRICE;*/
			self.custom_speed = #CUSTOM_SPEED7;
			PrintMoney();
			Menu_Legs();
		/*}
		else
			PrintNotEnoughMoney(#PRICE);*/
	}
	if (inp == 8) {
		CuTFMenuSound(#MENUSOUND_BROWSE);
		self.current_menu = #MENU_TOOLS;
		Menu_ToolWeapon();		  
	}
	if (inp == 9)
	{
		CuTFMenuSound(#MENUSOUND_BROWSE);
		self.current_menu = #MENU_HEALTH;
		Menu_Health();		  
	}
	if (inp == 10) {
		DropFromCustomClassGen();
	}

	self.impulse = 0;
};

// ==========================================
//	Prints Menu of Armor and Health Available
// ==========================================

#ifdef OLD_HP_SYSTEM
void() Menu_Health =
{
	local string temp;
	temp = ftos(self.money);
	#ifdef MONEY_RED_ONCUSTOMIZE
	temp = colstr(temp,#COLSTR_RED);
	#endif
	local string l1,l2,l3,l4;

	MenuResetCount();

l1 = eqstr(self.maxarmor, 75, 100,
	"  .. 75 Green armor  ≠  200\n  .. 100 Yellow      ≠  700\n",
	"* .. 75 Green armor  ≠  200\n  .. 100 Yellow      ≠  700\n",
	"  .. 75 Green armor  ≠  200\n* .. 100 Yellow      ≠  700\n");

l2 = eqstr(self.maxarmor, 150, 200,
	"  .. 150 Red         ≠ 1400\n  .. 200 Red         ≠ 2400\n", // original 2200
	"* .. 150 Red         ≠ 1400\n  .. 200 Red         ≠ 2400\n",
	"  .. 150 Red         ≠ 1400\n* .. 200 Red         ≠ 2400\n");

l3 =	"  .. 300 Red         ≠ 4600\n"; // 4200 Original 3600

if (self.maxarmor == 300 )
l3 =	"* .. 300 Red         ≠ 4600\n";

l4 =	"  .. +50 Health      ≠ 1000\n  .. +5 Health       ≠  100\n.. –ÚÂˆ    \n.. ŒÂ¯Ù    \n.. ƒÔÓÂ!   \n";

	centerprint(self, "úãê CısÙoÌi˙e ŸÔıÚÛÂÏÊ ãú\nãú Armor and Health   úã\n\n", l1,l2,l3,l4, temp," dollars left\n");
};

void(float inp) Menu_Health_Input =
{
	//Fix multiple armor buy bug
	//WW: Modded to allow to sell armor back
	if (inp >= 1 && inp <= 5 && self.maxarmor > 0) {
		if (self.maxarmor == 75)
		{
			if (inp == 1) {
				inp = 0;
				PrintRefund(200);
				Menu_Health();
			}
			else
				self.money = self.money + 200;
		}
		else if (self.maxarmor == 100)
		{
			if (inp == 2) {
				inp = 0;
				PrintRefund(700);
				Menu_Health();
			}
			else
				self.money = self.money + 700;
		}
		else if (self.maxarmor == 150)
		{
			if (inp == 3) {
				inp = 0;
				PrintRefund(1400);
				Menu_Health();
			}
			else
				self.money = self.money + 1400;
		}
		else if (self.maxarmor == 200)
		{
			if (inp == 4) {
				inp = 0;
				PrintRefund(2400); // Original 2200
				Menu_Health();
			}
			else
				self.money = self.money + 2400;
		}
		else if (self.maxarmor == 300)
		{
			if (inp == 5) {
				inp = 0;
				PrintRefund(4600); //4200 Original 3600
				Menu_Health();
			}
			else
				self.money = self.money + 4600;
			 
		}
		self.armor_allowed = self.armorvalue = self.maxarmor = 0;
		Menu_Health(); // FIXME: optimize (its actually sent twice)
	}
#define PRICE 200	
	if (inp == 1) {
		if (self.money >= #PRICE) {
			self.money = self.money - #PRICE;
			self.maxarmor = 75;
			self.armorvalue = self.maxarmor;
			self.armortype = 0.3;	// Green
			self.armor_allowed = 0.3; //Green max
			PrintMoney();
			Menu_Health();
		}
		else
			PrintNotEnoughMoney(#PRICE);
	}
#define PRICE 700
	if (inp == 2) {
		if (self.money >= #PRICE) {
			self.money = self.money - #PRICE;
			self.maxarmor = 100;
			self.armorvalue = self.maxarmor;
			self.armortype = 0.6;	// Yellow
			self.armor_allowed = 0.6; //Yellow max
			PrintMoney();
			Menu_Health();
		}
		else
			PrintNotEnoughMoney(#PRICE);
	}
#define PRICE 1400
	if (inp == 3) {
		if (self.money >= #PRICE) {
			self.money = self.money - #PRICE;
			self.maxarmor = 150;
			self.armorvalue = self.maxarmor;
			self.armortype = 0.8; //Red armor
			self.armor_allowed = 0.8; //Max
			PrintMoney();
			Menu_Health();
		}
		else
			PrintNotEnoughMoney(#PRICE);
	}
#define PRICE 2400 // Original 2200
	if (inp == 4) {
		if (self.money >= #PRICE) {
			self.money = self.money - #PRICE;
			self.maxarmor = 200;
			self.armorvalue = self.maxarmor;
			self.armortype = 0.8; //Red armor
			self.armor_allowed = 0.8; //Red max
			PrintMoney();
			Menu_Health();
		}
		else
			PrintNotEnoughMoney(#PRICE);
	}
#define PRICE 4600 //4200 Original 3600
	if (inp == 5) {
		if (self.money >= #PRICE) {
			self.money = self.money - #PRICE;
			self.maxarmor = 300;
			self.armorvalue = self.maxarmor;
			self.armortype = 0.8; //Red armor (used to be 0.9)
			self.armor_allowed = 0.8; //Red max
			PrintMoney();
			W_SetCurrentAmmo ();
			Menu_Health();
		}
		else
			PrintNotEnoughMoney(#PRICE);
	}
#define PRICE 1000
	if (inp == 6) {
		if (self.money >= #PRICE) {
			if (self.max_health + 50 > #MAX_PLAYER_HP)
			{
				sprint(self,#PRINT_HIGH,"You reached maximum health allowed!\n");
				CuTFMenuSound(#MENUSOUND_WRONG);

				self.money = self.money + ((self.max_health - 50) / 5) * 100;
				self.max_health = 50;
				self.health = self.max_health;

				self.impulse = 0;
				return;
			}

			self.money = self.money - #PRICE;
			self.max_health = self.max_health + 50;
			self.health = self.max_health;
			PrintMoney();
			//Menu_Health();
		}
		else
		{
			// WW: Modded to allow to sell health back
			//	   Buying #6 with <#7 money resets hp
			if (self.money < 100)
			{
				self.money = self.money + ((self.max_health - 50) / 5) * 100;
				self.max_health = 50;
				self.health = self.max_health;
				PrintMoney();
				//Menu_Health();
			}
			else
				PrintNotEnoughMoney(#PRICE);
		}
	}
#define PRICE 100
	if (inp == 7) {
		if (self.money >= #PRICE) {
			
			if (self.max_health + 5 > #MAX_PLAYER_HP)
			{
				sprint(self,#PRINT_HIGH,"You reached maximum health allowed!\n");
				CuTFMenuSound(#MENUSOUND_WRONG);
				self.impulse = 0;
				return;
			}
			
			self.money = self.money - #PRICE;
			self.max_health = self.max_health + 5;
			self.health = self.max_health;
			PrintMoney();
			//Menu_Health();
		}
		else
			PrintNotEnoughMoney(#PRICE);
	}
	if (inp == 8)
	{
		CuTFMenuSound(#MENUSOUND_BROWSE);
		self.current_menu = #MENU_LEGS;
		Menu_Legs();		
	}
	if (inp == 9) {
		CuTFMenuSound(#MENUSOUND_BROWSE);
		self.current_menu = #MENU_ARMOR;
		Menu_Armor();		 
	}
	if (inp == 10) {
		DropFromCustomClassGen();
	}

	self.impulse = 0;
};

#else

void() Menu_Health =
{
	local string temp;
	temp = ftos(self.money);
	
	if (self.tfstate & #TFSTATE_NOTENOUGHMONEY)
		temp = colstr(temp,#COLSTR_RED);
		
	local string l1,l2,l3,l4,str;

	MenuResetCount();

	l1 = ConstructMenuHPStr(1,#STR_HP1,#COST_HP1);
	str = ConstructMenuHPStr(2,#STR_HP2,#COST_HP2);
	l1 = strcat(l1,str);

	l2 = ConstructMenuHPStr(3,#STR_HP3,#COST_HP3);
	str = ConstructMenuHPStr(4,#STR_HP4,#COST_HP4);
	l2 = strcat(l2,str);

	l3 = ConstructMenuHPStr(5,#STR_HP5,#COST_HP5);
	str = ConstructMenuHPStr(6,#STR_HP6,#COST_HP6);
	l3 = strcat(l3,str);

	l4 = ConstructMenuHPStr(7,#STR_HP7,#COST_HP7);
	l4 = strcat(l4,".. –ÚÂˆ    \n.. ŒÂ¯Ù    \n.. ƒÔÓÂ!   \n");

	centerprint(self, "úãê CısÙoÌi˙e ŸÔıÚÛÂÏÊ ãú\nãú Armor and Health   úã\n\n", l1,l2,l3,l4, temp," dollars left\n");
};

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

void(float inp) Menu_Health_Input =
{
	if (inp == 8)
	{
		CuTFMenuSound(#MENUSOUND_BROWSE);
		self.current_menu = #MENU_LEGS;
		Menu_Legs();
		self.impulse = 0;
		return;
	}
	else if (inp == 9) {
		CuTFMenuSound(#MENUSOUND_BROWSE);
		self.current_menu = #MENU_ARMOR;
		Menu_Armor();
		self.impulse = 0;
		return;
	}
	else if (inp == 10) {
		DropFromCustomClassGen();
		self.impulse = 0;
		return;
	}

	local float current;
	local float tosell, tobuy;

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
	tobuy = GetHPCost(inp);
	if (self.money < tobuy - tosell)
	{
		PrintNotEnoughMoney(tobuy - tosell);
		self.impulse = 0;
		return;
	}
	
	if (current == inp || current != 0) // sell back?
	{
		self.max_health = 50;
		self.health = self.max_health;
		self.maxarmor = 0;
		self.armorvalue = 0;
		self.armortype = 0;
		self.armor_allowed = 0;

		PrintRefund(tosell);
		UpdateArmorItem(self);

		if (current == inp)
		{
			Menu_Health();
			self.impulse = 0;
			return;
		}
	}

	if (inp == 1)
	{
		self.max_health = 75;
		self.health = self.max_health;
		self.maxarmor = 50;
		self.armorvalue = self.maxarmor;
		self.armortype = 0.3;	// Green
		self.armor_allowed = 0.3; //Green max
		UpdateArmorItem(self);
	}
	else if (inp == 2)
	{
		self.max_health = 90;
		self.health = self.max_health;
		self.maxarmor = 50;
		self.armorvalue = self.maxarmor;
		self.armortype = 0.3;	// Green
		self.armor_allowed = 0.3; //Green max
		UpdateArmorItem(self);
	}
	else if (inp == 3)
	{
		self.max_health = 80;
		self.health = self.max_health;
		self.maxarmor = 100;
		self.armorvalue = self.maxarmor;
		self.armortype = 0.6;
		self.armor_allowed = 0.6;
		UpdateArmorItem(self);
	}
	else if (inp == 4)
	{
		self.max_health = 90;
		self.health = self.max_health;
		self.maxarmor = 120;
		self.armorvalue = self.maxarmor;
		self.armortype = 0.6;
		self.armor_allowed = 0.6;
		UpdateArmorItem(self);
	}
	else if (inp == 5)
	{
		self.max_health = 100;
		self.health = self.max_health;
		self.maxarmor = 150;
		self.armorvalue = self.maxarmor;
		self.armortype = 0.6;	
		self.armor_allowed = 0.6;
		UpdateArmorItem(self);
	}
	else if (inp == 6)
	{
		self.max_health = 100;
		self.health = self.max_health;
		self.maxarmor = 200;
		self.armorvalue = self.maxarmor;
		self.armortype = 0.8;	
		self.armor_allowed = 0.8;
		UpdateArmorItem(self);
	}
	else if (inp == 7)
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
	Menu_Health();
		
	self.impulse = 0;
};
#endif

// ==========================================
//	Prints Menu of Special Armor and Ammo
// ==========================================
void() Menu_Armor  =
{
	local string temp;
	temp = ftos(self.money);
	if (self.tfstate & #TFSTATE_NOTENOUGHMONEY)
		temp = colstr(temp,#COLSTR_RED);
	local string l1,l2,l3,l4,str;

	MenuResetCount();

	l1 = ConstructMenuItemStr(1,#STR_CERAMIC,#COST_CERAMIC,self.tf_items,#NIT_CERAMIC);
	str = ConstructMenuItemStr(2,#STR_GET,#COST_GET,self.tf_items,#NIT_GEL);
	l1 = strcat(l1,str);

	l2 = ConstructMenuItemStr(3,#STR_ASBESTOS,#COST_ASBESTOS,self.tf_items,#NIT_ASBESTOS);
	str = ConstructMenuItemStr(4,#STR_KEVLAR,#COST_KEVLAR,self.tf_items,#NIT_KEVLAR);
	l2 = strcat(l2,str);

	l3 = ConstructMenuItemStr(5,#STR_BLAST,#COST_BLAST,self.tf_items,#NIT_BLAST);
	str = ConstructMenuItemStr(6,#STR_AMMOBACKPACK,#COST_AMMOBACKPACK,self.tf_items,#NIT_AMMO_BACKPACK);
	l3 = strcat(l3,str);

	l4 = ConstructMenuItemStr(7,#STR_AMMOBANDOLIER,#COST_AMMOBANDOLIER,self.tf_items,#NIT_AMMO_BANDOLIER);
	l4 = strcat(l4,".. –ÚÂˆ    \n.. ŒÂ¯Ù    \n.. ƒÔÓÂ!   \n");

	centerprint(self, "úãê CısÙoÌi˙e ŸÔıÚÛÂÏÊ ãú\nãú Special ArmorØAmmo úã\n\n", l1,l2,l3,l4, temp," dollars left\n");
};

void(float inp) Menu_Armor_Input =
{
	if (inp == 1) {
		BuyItem(#COST_CERAMIC,#NIT_CERAMIC);
		Menu_Armor();
	}
	if (inp == 2) {
		BuyItem(#COST_GET, #NIT_GEL);
		Menu_Armor();
	}
	if (inp == 3) {
		BuyItem(#COST_ASBESTOS,#NIT_ASBESTOS);
		Menu_Armor();
	}
	if (inp == 4) {
		BuyItem(#COST_KEVLAR,#NIT_KEVLAR);
		Menu_Armor();
	}
	if (inp == 5) {
		BuyItem(#COST_BLAST,#NIT_BLAST);
		Menu_Armor();
	}
	if (inp == 6) {
		BuyItem(#COST_AMMOBACKPACK,#NIT_AMMO_BACKPACK);
		Menu_Armor();
	}
	if (inp == 7) {
#ifdef COOP_MODE_ENHANCED
		if ( !deathmatch ) {
			sprint( self, #PRINT_HIGH, "Ammo Bandolier is free in coop.\n" );
			CuTFMenuSound( #MENUSOUND_WRONG );
		} else {
			BuyItem( #COST_AMMOBANDOLIER, #NIT_AMMO_BANDOLIER );
			Menu_Armor();
		}
#else
		BuyItem(#COST_AMMOBANDOLIER,#NIT_AMMO_BANDOLIER);
		Menu_Armor();
#endif
	}
	if (inp == 8)
	{
		CuTFMenuSound(#MENUSOUND_BROWSE);
		self.current_menu = #MENU_HEALTH;
		Menu_Health();		  
	}
	if (inp == 9) {
		CuTFMenuSound(#MENUSOUND_BROWSE);
		self.current_menu = #MENU_SPECIAL;
		Menu_Special(); 	   
	}
	if (inp == 10) {
		DropFromCustomClassGen();
	}

	self.impulse = 0;
};

// ==================================
//	Prints Menu of Specials Available
// ==================================
void() Menu_Special =
{
	local string temp;
	temp = ftos(self.money);
	if (self.tfstate & #TFSTATE_NOTENOUGHMONEY)
		temp = colstr(temp,#COLSTR_RED);
	local string l1,l2,l3,l4,str;

	MenuResetCount();

	l1 = ConstructMenuItemStr(1,#STR_SCANNER,#COST_SCANNER,self.tf_items,#NIT_SCANNER);
	str = ConstructMenuItemStr(2,#STR_AUTOSCANNER,#COST_AUTOSCANNER,self.tf_items,#NIT_AUTOSCANNER);
	l1 = strcat(l1,str);

	l2 = ConstructMenuItemStr(3,#STR_DETPACK,#COST_DETPACK,self.cutf_items,#CUTF_DETPACK);
	str = ConstructMenuItemStr(4,#STR_MEDIKIT,#COST_MEDIKIT,self.weapons_carried,#WEAP_MEDIKIT);
	l2 = strcat(l2,str);

	l3 = ConstructMenuItemStr(5,#STR_SPYKIT,#COST_SPYKIT,self.cutf_items,#CUTF_SPY_KIT);
	str = ConstructMenuItemStr(6,#STR_SCUBA,#COST_SCUBA,self.tf_items,#NIT_SCUBA);
	l3 = strcat(l3,str);

	l4 = ConstructMenuItemStr(7,#STR_HOOK,#COST_HOOK,self.weapons_carried,#WEAP_HOOK);
	l4 = strcat(l4,".. –ÚÂˆ    \n.. ŒÂ¯Ù    \n.. ƒÔÓÂ!   \n");

	centerprint(self, "úãê CısÙoÌi˙e ŸÔıÚÛÂÏÊ ãú\nãú Special Items      úã\n\n",l1,l2,l3,l4, temp," dollars left\n");
};

void(float inp) Menu_Special_Input =
{
	local string st2;

//Scanner
		
	//st = infokey(world, "no_grapple");
	st2 = infokey(world, "no_spam");
	if (inp == 1) {
		if (self.tf_items & #NIT_SCANNER)
		{
			//Clean up auto-medic (sync this with Custom.qc)
			if (self.tf_items & #NIT_AUTOSCANNER)
				self.money = self.money + #COST_AUTOSCANNER; //Sync this with price below
			self.tf_items = self.tf_items - (self.tf_items & #NIT_AUTOSCANNER);

			PrintRefund(#COST_SCANNER);
			self.tf_items = self.tf_items - #NIT_SCANNER;
			self.tf_items_flags = self.tf_items_flags - (self.tf_items & #NIT_SCANNER_ENEMY);
			Menu_Special();
		}
		else if (self.money >= #COST_SCANNER) {
			self.money = self.money - #COST_SCANNER;
			self.tf_items = self.tf_items | #NIT_SCANNER;
			self.tf_items_flags = self.tf_items_flags | #NIT_SCANNER_ENEMY;
			PrintMoney();
			Menu_Special();
		}
		else
			PrintNotEnoughMoney(#COST_SCANNER);
	}
	if (inp == 2) { //Sync this with scanner above
		BuyItem(#COST_AUTOSCANNER,#NIT_AUTOSCANNER); 
		Menu_Special();
	}
//Detpack
	if (inp == 3) {
		if (st2 == "on") {//If admin disable it
			sprint(self,#PRINT_HIGH,"The admin has disabled spam devices on this map.\n");
//				  self.impulse=0;
			return;
		}
		if (self.cutf_items & #CUTF_DETPACK) //Already have it
		{
			PrintRefund(#COST_DETPACK);
			self.cutf_items = self.cutf_items - #CUTF_DETPACK;
			self.maxammo_detpack = self.maxammo_detpack - 1;
			Menu_Special();
		}
		else if (self.money >= #COST_DETPACK) {
			self.money = self.money - #COST_DETPACK;
			self.cutf_items = self.cutf_items | #CUTF_DETPACK;
			self.maxammo_detpack = self.maxammo_detpack + 1;
			PrintMoney();
			Menu_Special();
		}
		else
			PrintNotEnoughMoney(#COST_DETPACK);
	}
	if (inp == 4) {
		if (self.weapons_carried & #WEAP_MEDIKIT)
		{
			PrintRefund(#COST_MEDIKIT);
			self.weapons_carried = self.weapons_carried - #WEAP_MEDIKIT;
			self.maxammo_medikit = self.maxammo_medikit - 80;
			Menu_Special();
		}
		else if (self.money >= #COST_MEDIKIT) {
			self.money = self.money - #COST_MEDIKIT;
			self.weapons_carried = self.weapons_carried | #WEAP_MEDIKIT;
			self.maxammo_medikit = self.maxammo_medikit + 80;
			PrintMoney();
			Menu_Special();
		}
		else
			PrintNotEnoughMoney(#COST_MEDIKIT);
	}
	if (inp == 5) {
		BuyCuTF(#COST_SPYKIT,#CUTF_SPY_KIT);
		Menu_Special();
	}
	//Self-Contained Underwater Breathing Apparatus
	if (inp == 6) {
		BuyItem(#COST_SCUBA,#NIT_SCUBA);
		Menu_Special();
	}
	if (inp == 7) {
		if (no_grapple == 1) //If admin disable it
		{
			sprint(self,#PRINT_HIGH,"The admin has disabled the grapple on this map.\n");
			self.impulse = 0;
			return;
		}
		else if (allow_hook) //If map allows it...
		{
		   sprint(self,#PRINT_HIGH,"You can't sell your grapple on this map!\n");
		   CuTFMenuSound(#MENUSOUND_WRONG);
		}
		else
		{
			BuyWeapon(#COST_HOOK,#WEAP_HOOK);
			Menu_Special();
		}
	}
	if (inp == 8) {
		CuTFMenuSound(#MENUSOUND_BROWSE);
		self.current_menu = #MENU_ARMOR;
		Menu_Armor();		 
	}
	if (inp == 9) {
		CuTFMenuSound(#MENUSOUND_BROWSE);
		self.current_menu = #MENU_SPECIAL2;
		Menu_Special2();		
	}
	if (inp == 10) {
		DropFromCustomClassGen();
	}

	self.impulse = 0;
};

// ============================================//
// Prints Menu of Specials Available		   //
// ============================================//
void() Menu_Special2 =
{
	local string temp;
	temp = ftos(self.money);
	if (self.tfstate & #TFSTATE_NOTENOUGHMONEY)
		temp = colstr(temp,#COLSTR_RED);
	local string l1,l2,l3,l4,str;

	MenuResetCount();

	l1 = ConstructMenuItemStr(1,#STR_JAMMER,#COST_JAMMER,self.cutf_items,#CUTF_JAMMER);
	str = ConstructMenuItemStr(2,#STR_CYBERAUG,#COST_CYBERAUG,self.cutf_items,#CUTF_CYBERAUG);
	l1 = strcat(l1,str);

	l2 = ConstructMenuItemStr(3,#STR_SENSOR,#COST_SENSOR,self.cutf_items,#CUTF_SENSOR);
	str = ConstructMenuItemStr(4,#STR_FIELDGEN,#COST_FIELDGEN,self.cutf_items,#CUTF_FIELDGEN);
	l2 = strcat(l2,str);

	l3 = ConstructMenuItemStr(5,#STR_FULLARMOUR,#COST_FULLARMOUR,self.cutf_items,#CUTF_FULLARMOUR);
	str = ConstructMenuItemStr(6,#STR_TOSSABLEDET,#COST_TOSSABLEDET,self.cutf_items,#CUTF_TOSSABLEDET);
	l3 = strcat(l3,str);

	l4 = ConstructMenuItemStr(7,#STR_DISPENSER,#COST_DISPENSER,self.cutf_items,#CUTF_DISPENSER);
	l4 = strcat(l4,".. –ÚÂˆ    \n.. ŒÂ¯Ù    \n.. ƒÔÓÂ!   \n");

	centerprint(self, "úãê CısÙoÌi˙e ŸÔıÚÛÂÏÊ ãú\nãú More Special Items úã\n\n",l1,l2,l3,l4, temp," dollars left\n");
};

void(float inp) Menu_Special2_Input =
{
	if (inp == 1)//SB Jammer
	{
		BuyCuTF(#COST_JAMMER, #CUTF_JAMMER);
		Menu_Special2();
	}
	else if (inp == 2)//SB cybernetic augmentation
	{
		if (self.cutf_items & #CUTF_CYBERAUG)
		{
			self.maxammo_medikit = self.maxammo_medikit - 80;
			self.maxammo_cells = self.maxammo_cells - 80;
		}
		else
		{
			self.maxammo_medikit = self.maxammo_medikit + 80;
			self.maxammo_cells = self.maxammo_cells + 80;
		}
		BuyCuTF(#COST_CYBERAUG,#CUTF_CYBERAUG); 
		Menu_Special2();
	}
	else if (inp == 3)//SB motion sensor
	{
		BuyCuTF(#COST_SENSOR,#CUTF_SENSOR);
		Menu_Special2();
	}
	else if (inp == 4)//OfN Field Generator
	{
		BuyCuTF(#COST_FIELDGEN,#CUTF_FIELDGEN);
		Menu_Special2();
	}
	else if (inp == 5)//SB full armour
	{
#ifdef COOP_MODE_ENHANCED
		if ( !deathmatch ) {
			sprint( self, #PRINT_HIGH, "Full armor is free in coop.\n" );
			CuTFMenuSound( #MENUSOUND_WRONG );
		} else {
			BuyCuTF( #COST_FULLARMOUR, #CUTF_FULLARMOUR );
			Menu_Special2();
		}
#else
		BuyCuTF(#COST_FULLARMOUR,#CUTF_FULLARMOUR);
		Menu_Special2();
#endif
	}
	else if (inp == 6)//SB C4 tossable detpack
	{
		BuyCuTF(#COST_TOSSABLEDET,#CUTF_TOSSABLEDET);
		sprint(self, #PRINT_HIGH, "Type 'throwdet' to throw the detpack.\n");		 
	}
	else if (inp == 7)
	{
		BuyCuTF(#COST_DISPENSER,#CUTF_DISPENSER);
		Menu_Special2();
	}
	else if (inp == 8) {
		CuTFMenuSound(#MENUSOUND_BROWSE);
		self.current_menu = #MENU_SPECIAL;
		Menu_Special(); 	
	}
	else if (inp == 9) {
		CuTFMenuSound(#MENUSOUND_BROWSE);
		self.current_menu = #MENU_GREN1;
		Menu_Gren1();		
	}
	else if (inp == 10) {
		DropFromCustomClassGen();
	}

	self.impulse = 0;	
};

// ====================================
//	Prints Menu of Grenade-1s Available
// ====================================

void() Menu_Gren1 =
{
	local string temp;
	temp = ftos(self.money);
	if (self.tfstate & #TFSTATE_NOTENOUGHMONEY)
		temp = colstr(temp,#COLSTR_RED);
	local string l1,l2,l3,l4,str;

	MenuResetCount();

	l1 = ConstructMenuGrenStr(1,#STR_GR_NORMAL,#COST_GR_NORMAL,#GR_TYPE_NORMAL);
	str = ConstructMenuGrenStr(2,#STR_GR_NAPALM,#COST_GR_NAPALM,#GR_TYPE_NAPALM);
	l1 = strcat(l1,str);

	l2 = ConstructMenuGrenStr(3,#STR_GR_GAS,#COST_GR_GAS,#GR_TYPE_GAS);
	str = ConstructMenuGrenStr(4,#STR_GR_EMP,#COST_GR_EMP,#GR_TYPE_EMP);
	l2 = strcat(l2,str);
	
	l3 = ConstructMenuGrenStr(5,#STR_GR_FRAG,#COST_GR_FRAG,#GR_TYPE_FRAG);
	str = ConstructMenuGrenStr(6,#STR_GR_NAIL,#COST_GR_NAIL,#GR_TYPE_NAIL);
	l3 = strcat(l3,str);
	
	l4 = ConstructMenuGrenStr(7,#STR_GR_MIRV,#COST_GR_MIRV,#GR_TYPE_MIRV);
	l4 = strcat(l4,".. –ÚÂˆ    \n.. ŒÂ¯Ù    \n.. ƒÔÓÂ!   \n");
	
	centerprint(self, "úãê CısÙoÌi˙e ŸÔıÚÛÂÏÊ ãú\nãú Grenades ≠ Combat  úã\n\n",l1,l2,l3,l4, temp," dollars left\n");
};

void(float inp) Menu_Gren1_Input =
{	
	local string st, st2;
	st = infokey(world, "no_gasgren");
	st2 = infokey (world, "no_spam");

	if (inp == 1)
	{
		BuyGren(#COST_GR_NORMAL,#GR_TYPE_NORMAL);
		Menu_Gren1();
	}
	else if (inp == 2)
	{
		BuyGren(#COST_GR_NAPALM,#GR_TYPE_FLAME); // Flame was 750
		Menu_Gren1();
	}
	else if (inp == 3)
	{
		if (st == "on")
		{
			sprint(self, #PRINT_HIGH, "The admin has disabled gas grens on this map.\n");
			return;
		}
		if (st2 == "on") //If admin disable it
		{
			sprint(self,#PRINT_HIGH,"The admin has disabled spam devices on this map.\n");
			return;
		}
		BuyGren(#COST_GR_GAS,#GR_TYPE_GAS);
		Menu_Gren1();
	}
	else if (inp == 4)
	{
		if (st2 == "on") //If admin disable it
		{
			sprint(self,#PRINT_HIGH,"The admin has disabled spam devices on this map.\n");
			return;
		}
		BuyGren(#COST_GR_EMP,#GR_TYPE_EMP);
		Menu_Gren1();
	}
	else if (inp == 5)
	{
		if (st2 == "on") //If admin disable it
		{
			sprint(self,#PRINT_HIGH,"The admin has disabled spam devices on this map.\n");
			return;
		}
		BuyGren(#COST_GR_FRAG,#GR_TYPE_FRAG);
		Menu_Gren1();
	}
	else if (inp == 6)
	{
		BuyGren(#COST_GR_NAIL,#GR_TYPE_NAIL);
		Menu_Gren1();
	}
	if (inp == 7)
	{
		if (st2 == "on") //If admin disable it
		{
			sprint(self,#PRINT_HIGH,"The admin has disabled spam devices on this map.\n");
				return;
		}
		BuyGren(#COST_GR_MIRV,#GR_TYPE_MIRV);
		Menu_Gren1();
	}
	
	if (inp == 8)
	{
		CuTFMenuSound(#MENUSOUND_BROWSE);
		self.current_menu = #MENU_SPECIAL2;
		Menu_Special2();		
	}
	if (inp == 9)
	{
		CuTFMenuSound(#MENUSOUND_BROWSE);
		self.current_menu = #MENU_GREN2;
		Menu_Gren2();		 
	}
	else if (inp == 10)
		DropFromCustomClassGen();

	self.impulse = 0;
};

// ====================================
//	Prints Menu of Grenade-2s Available
// ====================================
void() Menu_Gren2 =
{
	local string temp;
	temp = ftos(self.money);
	if (self.tfstate & #TFSTATE_NOTENOUGHMONEY)
		temp = colstr(temp,#COLSTR_RED);
	local string l1,l2,l3,l4,str;

	MenuResetCount();

	l1 = ConstructMenuGrenStr(1,#STR_GR_FLARE,#COST_GR_FLARE,#GR_TYPE_FLARE);
	str = ConstructMenuGrenStr(2,#STR_GR_CALTROP,#COST_GR_CALTROP,#GR_TYPE_CALTROP);
	l1 = strcat(l1,str);

	l2 = ConstructMenuGrenStr(3,#STR_GR_CONCUSSION,#COST_GR_CONCUSSION,#GR_TYPE_CONCUSSION);
	str = ConstructMenuGrenStr(4,#STR_GR_PSIONIC,#COST_GR_PSIONIC,#GR_TYPE_PSIONIC);
	l2 = strcat(l2,str);	

	l3 = ConstructMenuGrenStr(5,#STR_GR_ANTIGRAV,#COST_GR_ANTIGRAV,#GR_TYPE_ANTIGRAV);
	str = ConstructMenuGrenStr(6,#STR_GR_BIOLOGICAL,#COST_GR_BIOLOGICAL,#GR_TYPE_BIO);
	l3 = strcat(l3,str);
	
	l4 = ConstructMenuGrenStr(7,#STR_GR_KRAC,#COST_GR_KRAC,#GR_TYPE_KRAC);
	l4 = strcat(l4,".. –ÚÂˆ    \n.. ŒÂ¯Ù    \n.. ƒÔÓÂ!   \n");

	centerprint(self, "úãê CısÙoÌi˙e ŸÔıÚÛÂÏÊ ãú\nãú Grenades ≠ Utility úã\n\n",l1,l2,l3,l4, temp," dollars left\n");
};

void(float inp) Menu_Gren2_Input =
{
	local string st, st2;
	st = infokey(world, "no_antigrav");
	st2 = infokey(world, "no_spam");

	//WK I should have done all the buy menus like this
	//SB I reckon - this one actually looks nice and makes sense
	if (inp == 1)
	{
		BuyGren(#COST_GR_FLARE, #GR_TYPE_FLARE);
		Menu_Gren2();
	}
	if (inp == 2)
	{
		if (st2 == "on")
			sprint(self, #PRINT_HIGH, "The admin has disabled spam devices on this map.\n");
		else
		{
			BuyGren(#COST_GR_CALTROP, #GR_TYPE_CALTROP);
			Menu_Gren2();
		}
	}
	if (inp == 3)
	{
		BuyGren(#COST_GR_CONCUSSION, #GR_TYPE_CONCUSSION);
		Menu_Gren2();
	}
	if (inp == 4)
	{
		#ifdef OLD_FLASH
		BuyGren(1000,#GR_TYPE_FLASH);
		#else
		BuyGren(#COST_GR_PSIONIC,#GR_TYPE_PSIONIC);
		#endif
		Menu_Gren2();
	}
	if (inp == 5)
	{	
		if (st == "on")
			sprint(self, #PRINT_HIGH, "The admin has disabled anti-grav grens on this map.\n");
		else	
		{
			BuyGren(#COST_GR_ANTIGRAV, #GR_TYPE_ANTIGRAV);
			Menu_Gren2();
		}
	}
	if (inp == 6)
	{
		BuyGren(#COST_GR_BIOLOGICAL, #GR_TYPE_BIO);
		Menu_Gren2();
	}
	if (inp == 7)
	{
		BuyGren(#COST_GR_KRAC, #GR_TYPE_KRAC);
		Menu_Gren2();
	}
	else if (inp == 8)
	{
		CuTFMenuSound(#MENUSOUND_BROWSE);
		self.current_menu = #MENU_GREN1;
		Menu_Gren1();		 
	}
	else if (inp == 9)
	{
		CuTFMenuSound(#MENUSOUND_BROWSE);
		self.current_menu = #MENU_ENGINEERING;
		Menu_Engineering(); 	   
	}
	if (inp == 10)
	{
		DropFromCustomClassGen();
	}

	self.impulse = 0;
};

// ====================================
//	Prints Menu of Optional Items Here
// ====================================
void() Menu_Engineering =
{
	local string temp;
	temp = ftos(self.money);
	if (self.tfstate & #TFSTATE_NOTENOUGHMONEY)
		temp = colstr(temp,#COLSTR_RED);
	local string l1,l2,l3,l4,str;

	MenuResetCount();

	l1 = ConstructMenuItemStr(1,#STR_SPANNER,#COST_SPANNER,self.weapons_carried,#WEAP_SPANNER);
	str = ConstructMenuSentryStr(2,#STR_SENTRYGUN,#COST_SENTRYGUN);
	l1 = strcat(l1,str);

	l2 = ConstructMenuItemStr(3,#STR_SENTRYUPGRADE,#COST_SENTRYUPGRADE,self.tf_items,#NIT_TURRET);
	str = ConstructMenuTeslaStr(4,#STR_TESLACOIL,#COST_TESLACOIL);
	l2 = strcat(l2,str);

	l3 = ConstructMenuItemStr(5,#STR_TESLAUPGRADE,#COST_TESLAUPGRADE,self.tf_items,#NIT_TESLA_UPGRADE);
	str = ConstructMenuItemStr(6,#STR_SECURITYCAMERA,#COST_SECURITYCAMERA,self.tf_items,#NIT_SECURITY_CAMERA);
	l3 = strcat(l3,str);

	l4 = ConstructMenuItemStr(7,#STR_TELEPORTER,#COST_TELEPORTER,self.tf_items,#NIT_TELEPORTER);
	l4 = strcat(l4,".. –ÚÂˆ    \n.. ŒÂ¯Ù    \n.. ƒÔÓÂ!   \n");

	centerprint(self, "úãê CısÙoÌi˙e ŸÔıÚÛÂÏÊ ãú\nãú Engineering Items  úã\n\n", l1,l2,l3,l4, temp," dollars left\n");
};
void(float inp) Menu_Engineering_Input =
{
	if (inp == 1) {
		BuyWeapon(#COST_SPANNER,#WEAP_SPANNER);
		Menu_Engineering();
	}
	if (inp == 2) {
		if (self.cutf_items & #CUTF_SENTRYGUN)
		{
			if (self.cutf_items & #CUTF_DOUBLESENTRY)
			{
				BuyCuTF(#COST_SENTRYGUN*2,#CUTF_SENTRYGUN | #CUTF_DOUBLESENTRY); // will sell both
			}
			else
			{
				if (self.money < #COST_SENTRYGUN)
					BuyCuTF(#COST_SENTRYGUN,#CUTF_SENTRYGUN); // will sell it
				else
				{
					if (self.tf_items & #NIT_TESLA)
						BuyCuTF(#COST_SENTRYGUN,#CUTF_SENTRYGUN); // will sell it
					else
						BuyCuTF(#COST_SENTRYGUN,#CUTF_DOUBLESENTRY);
				}
			}
		}
		else
		{
			if (self.tf_items & #NIT_DOUBLETESLA)
			{
				sprint(self,#PRINT_HIGH,"You can only carry equipment for 2 offensive machines!\n");
				CuTFMenuSound(#MENUSOUND_WRONG);
				self.impulse = 0;
				return;
			}
			
			BuyCuTF(#COST_SENTRYGUN,#CUTF_SENTRYGUN);
		}

		Menu_Engineering();
	}
	if (inp == 3) {
		BuyItem(#COST_SENTRYUPGRADE,#NIT_TURRET); 
		Menu_Engineering();
	}
	if (inp == 4) {
		if (self.tf_items & #NIT_TESLA)
		{
			if (self.tf_items & #NIT_DOUBLETESLA)
			{
				BuyItem(#COST_TESLACOIL*2,#NIT_TESLA | #NIT_DOUBLETESLA); // will sell both
			}
			else
			{
				if (self.money < #COST_TESLACOIL)
					BuyItem(#COST_TESLACOIL,#NIT_TESLA); // will sell it
				else
				{
					if (self.cutf_items & #CUTF_SENTRYGUN)
						BuyItem(#COST_TESLACOIL,#NIT_TESLA); // will sell it			
					else					
						BuyItem(#COST_TESLACOIL,#NIT_DOUBLETESLA);
				}
			}
		}
		else
		{
			if (self.cutf_items & #CUTF_DOUBLESENTRY)
			{
				sprint(self,#PRINT_HIGH,"You can only carry equipment for 2 offensive machines!\n");
				CuTFMenuSound(#MENUSOUND_WRONG);
				self.impulse = 0;
				return;
			}		  

			BuyItem(#COST_TESLACOIL,#NIT_TESLA);
		}
		
		Menu_Engineering();
	}
	if (inp == 5) {
		BuyItem(#COST_TESLAUPGRADE,#NIT_TESLA_UPGRADE);
		Menu_Engineering();
	}
	if (inp == 6) {
		BuyItem(#COST_SECURITYCAMERA,#NIT_SECURITY_CAMERA);
		Menu_Engineering();
	}
	if (inp == 7) {
		BuyItem(#COST_TELEPORTER,#NIT_TELEPORTER);
		Menu_Engineering();
	}
	if (inp == 8) {
		CuTFMenuSound(#MENUSOUND_BROWSE);
		self.current_menu = #MENU_GREN2;
		Menu_Gren2();		 
	}
	if (inp == 9) {
		CuTFMenuSound(#MENUSOUND_BROWSE);
		if (custom_mode!=1)
		{
			self.current_menu = #MENU_PROFESSION;
			Menu_Profession();			  
		}
		else
		{
			self.current_menu = #MENU_PROFICIENCY;
			Menu_Proficiency(); 		   
		}
	}
	if (inp == 10) {
		DropFromCustomClassGen();
	}

	self.impulse = 0;
};

// =====================================
//	Prints Menu of Professions Available
// =====================================
void() Menu_Profession =
{
	local string temp;
	temp = ftos(self.money);
	if (self.tfstate & #TFSTATE_NOTENOUGHMONEY)
		temp = colstr(temp,#COLSTR_RED);
	local string l1,l2,l3,l4,str;

	MenuResetCount();

	l1 = ConstructMenuJobStr(1,#STR_THIEF,#JOB_THIEF,#COST_THIEF,0,0,"","");
	str = ConstructMenuJobStr(2,#STR_RUNNER,#JOB_RUNNER,#COST_RUNNER,0,0,"","");
	l1 = strcat(l1,str);

	l2 = ConstructMenuJobStr(3,#STR_WARLOCK,#JOB_WARLOCK,#COST_WARLOCK,#COST_WARLOCK_EXTRA1,#COST_WARLOCK_EXTRA2,#STR_WARLOCK_EXTRA1,#STR_WARLOCK_EXTRA2);
	str = ConstructMenuJobStr(4,#STR_CHAPLAN,#JOB_CHAPLAN,#COST_CHAPLAN,0,0,"","");
	l2 = strcat(l2,str);

	l3 = ConstructMenuJobStr(5,#STR_BERSERKER,#JOB_BERSERKER,#COST_BERSERKER,0,0,"","");
	str = ConstructMenuJobStr(6,#STR_GUERILLA,#JOB_GUERILLA,#COST_GUERILLA,#COST_GUERILLA_EXTRA1,#COST_GUERILLA_EXTRA2,#STR_GUERILLA_EXTRA1,#STR_GUERILLA_EXTRA2);
	l3 = strcat(l3,str);

	l4 = ConstructMenuJobStr(7,#STR_JUDOKA,#JOB_JUDOKA,#COST_JUDOKA,0,0,"","");
	l4 = strcat(l4,".. –ÚÂˆ    \n.. ŒÂ¯Ù    \n.. ƒÔÓÂ!   \n");
	
	centerprint(self, "úãê CısÙoÌi˙e ŸÔıÚÛÂÏÊ ãú\nãú Skilled Profession úã\n\n", l1,l2,l3,l4, temp," dollars left\n\nUse ”À…ÃÃ to trigger ability\n");

};
void(float inp) Menu_Profession_Input =
{
	if (inp == 1) {
		BuyJob( #COST_THIEF,#JOB_THIEF);
		Menu_Profession();
	}
	if (inp == 2) {
		BuyJob(#COST_RUNNER,#JOB_RUNNER);
		Menu_Profession();
	}
	if (inp == 3) { //Sync this with price in knife
		if (extras_mode == 0)
		{
			if (self.job & #JOB_WARLOCK)
				BuyExtra(#COST_WARLOCK_EXTRA1,#COST_WARLOCK_EXTRA2);
			else
				BuyJob(#COST_WARLOCK,#JOB_WARLOCK); 		   
		}
		else
			BuyJob(#COST_WARLOCK,#JOB_WARLOCK);

		Menu_Profession();
	}
	if (inp == 4) {
		BuyJob(#COST_CHAPLAN,#JOB_CHAPLAN);
		Menu_Profession();
	}
	if (inp == 5) {
		BuyJob(#COST_BERSERKER,#JOB_BERSERKER);
		Menu_Profession();
	}
	if (inp == 6) {
		if (extras_mode == 0)
		{
			if (self.job & #JOB_GUERILLA)
				BuyExtra(#COST_GUERILLA_EXTRA1,#COST_GUERILLA_EXTRA2);
			else
				BuyJob(#COST_GUERILLA,#JOB_GUERILLA);
		}
		else
			BuyJob(#COST_GUERILLA,#JOB_GUERILLA);

		Menu_Profession();
	}
	if (inp == 7) {
		BuyJob(#COST_JUDOKA,#JOB_JUDOKA); // Original = 700
		Menu_Profession();
	}
	if (inp == 8) {
		CuTFMenuSound(#MENUSOUND_BROWSE);
		self.current_menu = #MENU_ENGINEERING;
		Menu_Engineering(); 	   
	}
	if (inp == 9) {
		CuTFMenuSound(#MENUSOUND_BROWSE);
		self.current_menu = #MENU_PROFESSION2;
		Menu_Profession2(); 	   
	}
	if (inp == 10) {
		DropFromCustomClassGen();
	}

	self.impulse = 0;
};

// ==================================
//	Prints Second page of Professions
// ==================================
void() Menu_Profession2 =
{
	local string temp;
	temp = ftos(self.money);
	if (self.tfstate & #TFSTATE_NOTENOUGHMONEY)
		temp = colstr(temp,#COLSTR_RED);
	local string l1,l2,l3,l4, str;

	MenuResetCount();

	l1 = ConstructMenuJobStr(1,#STR_ARMY,#JOB_ARMY,#COST_ARMY,#COST_ARMY_EXTRA1,#COST_ARMY_EXTRA2,#STR_ARMY_EXTRA1,#STR_ARMY_EXTRA2);
	str = ConstructMenuJobStr(2,#STR_HACKER,#JOB_HACKER,#COST_HACKER,0,0,"","");
	l1 = strcat(l1,str);


	l2 = ConstructMenuJobStr(3,#STR_MARTYR,#JOB_MARTYR,#COST_MARTYR,0,0,"","");
	str = ConstructMenuJobStr(4,#STR_CRUSADER,#JOB_CRUSADER,#COST_CRUSADER,0,0,"","");
	l2 = strcat(l2,str);

	l4 = "\n.. –ÚÂˆ    \n.. ŒÂ¯Ù    \n.. ƒÔÓÂ!   \n";
	l3 = "\n\n";

	centerprint(self, "úãê CısÙoÌi˙e ŸÔıÚÛÂÏÊ ãú\nãú More Professions   úã\n\n", l1,l2,l3,l4, temp," dollars left\n\nUse ”À…ÃÃ to trigger ability\n");
};

void(float inp) Menu_Profession2_Input =
{
	if (inp == 1) {
		if (extras_mode == 0)
		{
			if (self.job & #JOB_ARMY)
			   BuyExtra(#COST_ARMY_EXTRA1,#COST_ARMY_EXTRA2);
			else
			   BuyJob(#COST_ARMY,#JOB_ARMY);
		}
		else
			BuyJob(#COST_ARMY,#JOB_ARMY);

		Menu_Profession2();
	}
	if (inp == 2) {
		BuyJob(#COST_HACKER,#JOB_HACKER);
		Menu_Profession2();
	}
	if (inp == 3) { 
		BuyJob(#COST_MARTYR,#JOB_MARTYR);
		Menu_Profession2();
	}
	if (inp == 4) {
		BuyJob(#COST_CRUSADER,#JOB_CRUSADER);
		Menu_Profession2();
	}
	if (inp == 8) {
		CuTFMenuSound(#MENUSOUND_BROWSE);
		self.current_menu = #MENU_PROFESSION;
		Menu_Profession();		  
	}
	if (inp == 9) {
		CuTFMenuSound(#MENUSOUND_BROWSE);
		self.current_menu = #MENU_PROFICIENCY;
		Menu_Proficiency(); 	   
	}
	if (inp == 10) {
		DropFromCustomClassGen();
	}

	self.impulse = 0;
};

// =====================================
//	Prints Menu of Proficiencies Available
// =====================================
void() Menu_Proficiency =
{
	local string temp;
	temp = ftos(self.money);
	if (self.tfstate & #TFSTATE_NOTENOUGHMONEY)
		temp = colstr(temp,#COLSTR_RED);
	local string l1,l2,l3,l4,str;

	MenuResetCount();

	l1 = ConstructMenuItemStr(1,#STR_STEALTH,#COST_STEALTH,self.cutf_items,#CUTF_STEALTH);
	str = ConstructMenuItemStr(2,#STR_HIGHJUMP,#COST_HIGHJUMP,self.cutf_items,#CUTF_HIGHJUMP);
	l1 = strcat(l1,str);

	l2 = ConstructMenuItemStr(3,#STR_HWGUY,#COST_HWGUY,self.cutf_items,#CUTF_HWGUY);
	str = ConstructMenuItemStr(4,#STR_EXPBODY,#COST_EXPBODY,self.cutf_items,#CUTF_EXPBODY);
	l2 = strcat(l2,str);

	l3 = ConstructMenuItemStr(5,#STR_GYMNAST,#COST_GYMNAST,self.cutf_items,#CUTF_GYMNAST);
	str = ConstructMenuItemStr(6,#STR_DEMONLORE,#COST_DEMONLORE,self.cutf_items,#CUTF_DEMONLORE);
	l3 = strcat(l3,str);

	l4 = ConstructMenuItemStr(7,#STR_CLOSECOMBAT,#COST_CLOSECOMBAT,self.cutf_items,#CUTF_CLOSECOMBAT);
	l4 = strcat(l4,".. –ÚÂˆ    \n.. ŒÂ¯Ù    \n.. ƒÔÓÂ!   \n");

	centerprint(self, "úãê CısÙoÌi˙e ŸÔıÚÛÂÏÊ ãú\nãú Proficiency        úã\n\n", l1,l2,l3,l4, temp," dollars left\n");
}; 

void(float inp) Menu_Proficiency_Input =
{
	if (inp == 1) {
		BuyCuTF(#COST_STEALTH,#CUTF_STEALTH);
		Menu_Proficiency();
	}
	if (inp == 2) {
		BuyCuTF(#COST_HIGHJUMP,#CUTF_HIGHJUMP);
		Menu_Proficiency();
	}
	if (inp == 3) {
		if (self.cutf_items & #CUTF_GYMNAST)
		{
			sprint(self, #PRINT_HIGH, "Having Gymnast and Aspect of HWGuy proficiencies is illogical.\n");
			CuTFMenuSound(#MENUSOUND_WRONG);
		}
		else
		{
			BuyCuTF(#COST_HWGUY,#CUTF_HWGUY);
			Menu_Proficiency();
		}
	}
	if (inp == 4) {
		BuyCuTF(#COST_EXPBODY,#CUTF_EXPBODY);
		Menu_Proficiency();
	}
	if (inp == 5) {
		if (self.cutf_items & #CUTF_HWGUY)
		{
			sprint(self, #PRINT_HIGH, "Trust me, you don't want Aspect of HWGuy AND Gymnast.\n");
			CuTFMenuSound(#MENUSOUND_WRONG);
		}
		else
		{
			BuyCuTF(#COST_GYMNAST,#CUTF_GYMNAST);
			Menu_Proficiency();
		}
	}
	if (inp == 6) {
		BuyCuTF(#COST_DEMONLORE,#CUTF_DEMONLORE);
		Menu_Proficiency();
	}
	if (inp == 7) {
		BuyCuTF(#COST_CLOSECOMBAT,#CUTF_CLOSECOMBAT);
		Menu_Proficiency();
	}
	if (inp == 8) {
		CuTFMenuSound(#MENUSOUND_BROWSE);
		if (custom_mode!=1)
		{
			self.current_menu = #MENU_PROFESSION2;
			Menu_Profession2(); 		   
		}
		else
		{
			self.current_menu = #MENU_ENGINEERING;
			Menu_Engineering(); 		   
		}			  
	}
	if (inp == 9) {
		CuTFMenuSound(#MENUSOUND_BROWSE);
		self.current_menu = #MENU_OPTION;
		Menu_Option();		  
	}
	if (inp == 10) {
		DropFromCustomClassGen();
	}

	self.impulse = 0;
};

// ====================================
//	Prints Menu of Optional Items Here
// ====================================
void() Menu_Option =
{
	local string temp;
	temp = ftos(self.money);
	if (self.tfstate & #TFSTATE_NOTENOUGHMONEY)
		temp = colstr(temp,#COLSTR_RED);
	local string l1,l2,l3,l4,str;

	MenuResetCount();

	l1 = ConstructMenuItemStr(1,#STR_AUTOID,#COST_AUTOID,self.tf_items,#NIT_AUTOID);
	str = ConstructMenuItemStr(2,#STR_RESPAWNGUARD,#COST_RESPAWNGUARD,self.tf_items,#NIT_RESPAWN_GUARD);
	l1 = strcat(l1,str);

	l2 = ConstructMenuItemStr(3,#STR_HOVERBOOTS,#COST_HOVERBOOTS,self.tf_items,#NIT_HOVER_BOOTS);
	str = ConstructMenuItemStr(4,#STR_BOOTUPGRADE,#COST_BOOTUPGRADE,self.tf_items,#NIT_HOVER_BOOTS_UPGRADE);
	l2 = strcat(l2,str);

	l3 = ConstructMenuItemStr(5,#STR_RLASERGUIDED,#COST_RLASERGUIDED,self.tf_items,#NIT_RL_LASER_SIGHT);
	str = ConstructMenuItemStr(6,#STR_OTR,#COST_OTR,self.cutf_items,#CUTF_OTR);
	l3 = strcat(l3,str);

	l4 = ConstructMenuItemStr(7,#STR_CLUSTER,#COST_CLUSTER,self.tf_items,#NIT_CLUSTER_ROCKETS);
	l4 = strcat(l4,".. –ÚÂˆ    \n.. ŒÂ¯Ù    \n.. ƒÔÓÂ!   \n");

	centerprint(self, "úãê CısÙoÌi˙e ŸÔıÚÛÂÏÊ ãú\nãú Optional Equipment úã\n\n", l1,l2,l3,l4, temp," dollars left\n");
};
void(float inp) Menu_Option_Input =
{
	if (inp == 1) {
		BuyItem(#COST_AUTOID,#NIT_AUTOID);
		Menu_Option();
	}
	if (inp == 2) { 
		BuyItem(#COST_RESPAWNGUARD,#NIT_RESPAWN_GUARD);
		Menu_Option();
	}
	if (inp == 6) { 
		if (!(self.weapons_carried & #WEAP_SNIPER_RIFLE) && !(self.cutf_items & #CUTF_OTR))
		{
			CuTFMenuSound(#MENUSOUND_WRONG);
			sprint (self, #PRINT_HIGH, "Are you going to throw these bullets at them or something?\n");
			self.impulse = 0;
			return;
		}

		BuyCuTF(#COST_OTR,#CUTF_OTR);
		Menu_Option();
	}
	if (inp == 3) {
		BuyItem(#COST_HOVERBOOTS,#NIT_HOVER_BOOTS);
		Menu_Option();
	}
	if (inp == 4) {
		BuyItem(#COST_BOOTUPGRADE, #NIT_HOVER_BOOTS_UPGRADE); //sync price with buyitem
		Menu_Option();
	}
	if (inp == 5) {
		BuyItem(#COST_RLASERGUIDED, #NIT_RL_LASER_SIGHT); //sync with RL
		Menu_Option();
	}
	if (inp == 7) {
		  BuyItem(#COST_CLUSTER, #NIT_CLUSTER_ROCKETS); //sync with RL
		  Menu_Option();
	}
	if (inp == 8) {
		CuTFMenuSound(#MENUSOUND_BROWSE);
		self.current_menu = #MENU_PROFICIENCY;
		Menu_Proficiency(); 	   
	}
	if (inp == 9) {
		CuTFMenuSound(#MENUSOUND_BROWSE);
		self.current_menu = #MENU_MOREOPTION;
		Menu_MoreOption ();			
	}
	if (inp == 10) {
		DropFromCustomClassGen();
	}

	self.impulse = 0;
};


// ====================================================================
//	Menu of more optional equipment - Gizmo
// ====================================================================
void() Menu_MoreOption =
{
	local string temp;
	temp = ftos(self.money);
	
	if (self.tfstate & #TFSTATE_NOTENOUGHMONEY)
		temp = colstr(temp,#COLSTR_RED);
	
	local string l1,l2,l3,l4;

	MenuResetCount();

	l1 = ConstructMenuItemStr(1, #STR_FASTERROCKETS, #COST_FASTERROCKETS, self.cutf_moreitems, #CUTF_MI_FASTERROCKETS);
	l2 = ConstructMenuItemStr( 2, #STR_FRIENDORFOE, #COST_FRIENDORFOE, self.cutf_moreitems, #CUTF_MI_FRIENDORFOE );

	l3 = "\n\n\n";

	l4 = "\n";
	l4 = strcat(l4, ".. –ÚÂˆ    \n..         \n.. ƒÔÓÂ!   \n");

	centerprint(self, "úãê CısÙoÌi˙e ŸÔıÚÛÂÏÊ ãú\nãúê More Equipment     úã\n\n", l1, l2, l3, l4, temp," dollars left\n");
};

void(float inp) Menu_MoreOption_Input =
{
	if (inp >= 1 && inp <= 10) {
		// Gizmo - modified version of avirox's mods
		if (inp == 1) {
			if (self.weapons_carried & #WEAP_ROCKET_LAUNCHER) {
				if (self.cutf_moreitems & #CUTF_MI_FASTERROCKETS) {
					PrintRefund (#COST_FASTERROCKETS);
					self.cutf_moreitems = self.cutf_moreitems - #CUTF_MI_FASTERROCKETS;
				} else if (self.money >= #COST_FASTERROCKETS) {
					self.money = self.money - #COST_FASTERROCKETS;
					self.cutf_moreitems = self.cutf_moreitems | #CUTF_MI_FASTERROCKETS;
					PrintMoney ();
				} else
					PrintNotEnoughMoney (#COST_FASTERROCKETS);
			} else {
				// TODO: add these into custom.qc; infact all this should be in a new moreitems function in custom.qc
				sprint( self, #PRINT_HIGH, "Sorry, you have to buy the rocket launcher first!\n" );
				CuTFMenuSound( #MENUSOUND_WRONG );
			}

			Menu_MoreOption ();
		} else if ( inp == 2 ) {
			if ( self.cutf_moreitems & #CUTF_MI_FRIENDORFOE ) {
				PrintRefund( #COST_FRIENDORFOE );
				self.cutf_moreitems = self.cutf_moreitems - #CUTF_MI_FRIENDORFOE;
			} else if ( self.money >= #COST_FRIENDORFOE ) {
				self.money = self.money - #COST_FRIENDORFOE;
				self.cutf_moreitems = self.cutf_moreitems | #CUTF_MI_FRIENDORFOE;
				PrintMoney();
			} else
				PrintNotEnoughMoney( #COST_FRIENDORFOE );

			Menu_MoreOption();
		}

		if (inp == 8) {
			CuTFMenuSound(#MENUSOUND_BROWSE);
			self.current_menu = #MENU_OPTION;
			Menu_Option();
		}
		if (inp == 10)
		{
			DropFromCustomClassGen();
		}

		self.impulse = 0;
	}
};

//___________________________________________________________________________________
//===================================================================================
// Item string constructors for menu displayers  

string(float itemnum, string itemdesc,float cost,float field, float bit) ConstructMenuItemStr =
{
	local string result;
	
	result = ftos(itemnum);
	result = colstr(result,#COLSTR_NUMBER);
	
	if (field & bit)
		result = strcat("#CHAR_BOUGHT ",result);
	else
		result = strcat("  ",result);	 

	if (!CanBuyItem(itemnum))
	{
		result = strcat(result,"ÆÆ ");
		itemdesc = colstr(itemdesc,#COLSTR_RED);
	}
	else if (ItemIsFree(itemnum))
	{
		result = strcat(result,"ÆÆ ");
	}
	else
	{
		result = strcat(result,".. ");
		if (cost > self.money && !(field & bit))
			itemdesc = colstr(itemdesc,#COLSTR_RED);
	}

	result = strcat(result,itemdesc);

	if (cost < 100)
		result = strcat(result,"≠   ");
	else if (cost < 1000)
		result = strcat(result,"≠  ");
	else if (cost < 10000)
		result = strcat(result,"≠ ");
	else
		result = strcat(result,"≠");
	
	itemdesc = ftos(cost);

	if (field & bit)
		itemdesc = colstr(itemdesc,#COLSTR_NUMBER);
	/*else
	{
		if (cost > self.money)
			itemdesc = colstr(itemdesc,#COLSTR_RED);		
	}*/

	result = strcat(result,itemdesc);

	result = strcat(result,"\n");

	return result;
};

string(float itemnum, string itemdesc,float cost) ConstructMenuSentryStr =
{
	local string result;
	local float numbought;

	result = ftos(itemnum);
	result = colstr(result,#COLSTR_NUMBER);
	
	if (!(self.cutf_items & #CUTF_SENTRYGUN))
	{
		result = strcat("  ",result);
		numbought = 0;
	}
	else
	{
		if (self.cutf_items & #CUTF_DOUBLESENTRY)
		{
			result = strcat("2 ",result);	 
			numbought = 2;
		}
		else
		{
			result = strcat("1 ",result);	 
			numbought = 1;
		}
	}

	if (!CanBuyItem(itemnum))
	{
		result = strcat(result,"ÆÆ ");
		itemdesc = colstr(itemdesc,#COLSTR_RED);
	}
	else if (ItemIsFree(itemnum))
	{
		result = strcat(result,"ÆÆ ");
	}
	else
	{
		result = strcat(result,".. ");
		if (cost > self.money && !numbought)
			itemdesc = colstr(itemdesc,#COLSTR_RED);
	}

	result = strcat(result,itemdesc);

	if (cost < 100)
		result = strcat(result,"≠   ");
	else if (cost < 1000)
		result = strcat(result,"≠  ");
	else if (cost < 10000)
		result = strcat(result,"≠ ");
	else
		result = strcat(result,"≠");
	
	itemdesc = ftos(cost);

	if (numbought)
	{
		if (numbought == 2)
			itemdesc = ftos(cost*2);

		itemdesc = colstr(itemdesc,#COLSTR_NUMBER);
	}
	/*else
	{
		if (cost > self.money)
			itemdesc = colstr(itemdesc,#COLSTR_RED);		
	}*/

	result = strcat(result,itemdesc);

	result = strcat(result,"\n");

	return result;
};

string(float itemnum, string itemdesc,float cost) ConstructMenuTeslaStr =
{
	local string result;
	local float numbought;

	result = ftos(itemnum);
	result = colstr(result,#COLSTR_NUMBER);
	
	if (!(self.tf_items & #NIT_TESLA))
	{
		result = strcat("  ",result);
		numbought = 0;
	}
	else
	{
		if (self.tf_items & #NIT_DOUBLETESLA)
		{
			result = strcat("2 ",result);	 
			numbought = 2;
		}
		else
		{
			result = strcat("1 ",result);	 
			numbought = 1;
		}
	}

	if (!CanBuyItem(itemnum))
	{
		result = strcat(result,"ÆÆ ");
		itemdesc = colstr(itemdesc,#COLSTR_RED);
	}
	else if (ItemIsFree(itemnum))
	{
		result = strcat(result,"ÆÆ ");
	}
	else
	{
		result = strcat(result,".. ");
		if (cost > self.money && !numbought)
			itemdesc = colstr(itemdesc,#COLSTR_RED);
	}

	result = strcat(result,itemdesc);

	if (cost < 100)
		result = strcat(result,"≠   ");
	else if (cost < 1000)
		result = strcat(result,"≠  ");
	else if (cost < 10000)
		result = strcat(result,"≠ ");
	else
		result = strcat(result,"≠");
	
	itemdesc = ftos(cost);

	if (numbought)
	{
		if (numbought == 2)
			itemdesc = ftos(cost*2);

		itemdesc = colstr(itemdesc,#COLSTR_NUMBER);
	}
	/*else
	{
		if (cost > self.money)
			itemdesc = colstr(itemdesc,#COLSTR_RED);		
	}*/

	result = strcat(result,itemdesc);

	result = strcat(result,"\n");

	return result;
};

string(float itemnum, string itemdesc,float jobid,float cost, float extra1cost, float extra2cost, string extra1st, string extra2st) ConstructMenuJobStr =
{
	local string result;
	local float numbought;

	result = ftos(itemnum);
	result = colstr(result,#COLSTR_NUMBER);
	
	if (!(self.job & jobid))
	{
		result = strcat("  ",result);
		numbought = 0;
	}
	else
	{
		if (self.job & #JOB_EXTRA2)
		{
			result = strcat("3 ",result);	 
			numbought = 3;
		}
		else if (self.job & #JOB_EXTRA1)
		{
			result = strcat("2 ",result);	 
			numbought = 2;
		}
		else
		{
			if (!extra1cost || extras_mode)
				result = strcat("#CHAR_BOUGHT ",result);	
			else
				result = strcat("1 ",result);	 
			
			numbought = 1;
		}
	}

	if (numbought)
	if (!extras_mode)
	if (extra1cost)
	{
		if (numbought == 1)
			itemdesc = extra1st;
		else if (numbought == 2)
			itemdesc = extra2st;
		else if (numbought == 3)
			itemdesc = #STR_SELLEXTRAS;
	}

	if (!CanBuyItem(itemnum))
	{
		result = strcat(result,"ÆÆ ");
		itemdesc = colstr(itemdesc,#COLSTR_RED);
	}
	else if (ItemIsFree(itemnum))
	{
		result = strcat(result,"ÆÆ ");
	}
	else
	{
		result = strcat(result,".. ");

		if (!numbought)
		if (cost > self.money + SpentOnJob())
			itemdesc = colstr(itemdesc,#COLSTR_RED);		
	}

	result = strcat(result,itemdesc);

	if (cost < 100)
		result = strcat(result,"≠  ");
	else if (cost < 1000)
		result = strcat(result,"≠ ");
	else if (cost < 10000)
		result = strcat(result,"≠");
	else
		result = strcat(result,"");

	if (numbought && extra1cost && numbought != 3 && !extras_mode)
		result = strcat(result," +");
	else
		result = strcat(result," ");
	
	itemdesc = ftos(cost);

	if (numbought)
	{
		if (numbought == 3)
			itemdesc = ftos(cost+extra1cost+extra2cost);
		else if (numbought == 2)
			itemdesc = ftos(extra2cost);
		else if (extra1cost && !extras_mode)
			itemdesc = ftos(extra1cost);

		itemdesc = colstr(itemdesc,#COLSTR_NUMBER);
	}
	/*else
	{
		if (cost > self.money)
			itemdesc = colstr(itemdesc,#COLSTR_RED);		
	}*/

	result = strcat(result,itemdesc);

	result = strcat(result,"\n");

	return result;
};

float() SpentOnJob =
{
	if (self.job & #JOB_THIEF)
		return #COST_THIEF;
	if (self.job & #JOB_RUNNER)
		return #COST_RUNNER;
	if (self.job & #JOB_WARLOCK)
	{
		if (self.job & #JOB_EXTRA2)
			return #COST_WARLOCK + #COST_WARLOCK_EXTRA1 + #COST_WARLOCK_EXTRA2;
		if (self.job & #JOB_EXTRA1)
			return #COST_WARLOCK + #COST_WARLOCK_EXTRA1;
		
		return #COST_WARLOCK;
	}
	if (self.job & #JOB_CHAPLAN)
		return #COST_CHAPLAN;
	if (self.job & #JOB_BERSERKER)
		return #COST_BERSERKER;
	if (self.job & #JOB_GUERILLA)
	{
		if (self.job & #JOB_EXTRA2)
			return #COST_GUERILLA + #COST_GUERILLA_EXTRA1 + #COST_GUERILLA_EXTRA2;
		if (self.job & #JOB_EXTRA1)
			return #COST_GUERILLA + #COST_GUERILLA_EXTRA1;
		
		return #COST_GUERILLA;
	}
	if (self.job & #JOB_JUDOKA)
		return #COST_JUDOKA;
	if (self.job & #JOB_ARMY)
	{
		if (self.job & #JOB_EXTRA2)
			return #COST_ARMY + #COST_ARMY_EXTRA1 + #COST_ARMY_EXTRA2;
		if (self.job & #JOB_EXTRA1)
			return #COST_ARMY + #COST_ARMY_EXTRA1;
		
		return #COST_ARMY;
	}
	if (self.job & #JOB_HACKER)
		return #COST_HACKER;
	if (self.job & #JOB_MARTYR)
		return #COST_MARTYR;
	if (self.job & #JOB_CRUSADER)
		return #COST_CRUSADER;
};

string(float itemnum, string itemdesc,float cost,float grentype) ConstructMenuGrenStr =
{
	local string result;
	local float numbought;

	result = ftos(itemnum);
	result = colstr(result,#COLSTR_NUMBER);
	
	if ((self.tp_grenades_1 != grentype) && (self.tp_grenades_2 != grentype))
	{
		result = strcat("  ",result);
		numbought = 0;
	}
	else
	{
		if ((self.tp_grenades_1 == grentype) && (self.tp_grenades_2 == grentype))
		{
			result = strcat("2 ",result);	 
			numbought = 2;
		}
		else
		{
			result = strcat("1 ",result);	 
			numbought = 1;
		}		 
	}
	
	if (!CanBuyItem(itemnum))
	{
		result = strcat(result,"ÆÆ ");
		itemdesc = colstr(itemdesc,#COLSTR_RED);
	}
	else if (ItemIsFree(itemnum))
	{
		result = strcat(result,"ÆÆ ");
	}
	else
	{
		result = strcat(result,".. ");

		if (!numbought)
		if (cost > self.money + SpentOnGrens())
			itemdesc = colstr(itemdesc,#COLSTR_RED);		
	}

	result = strcat(result,itemdesc);

	if (numbought == 2)
		cost = cost * 2;

	if (cost < 100)
		result = strcat(result,"≠   ");
	else if (cost < 1000)
		result = strcat(result,"≠  ");
	else if (cost < 10000)
		result = strcat(result,"≠ ");
	else
		result = strcat(result,"≠");
	 
	itemdesc = ftos(cost);

	if (numbought)
		itemdesc = colstr(itemdesc,#COLSTR_NUMBER);
	/*else
	{
		if (cost > self.money)
			itemdesc = colstr(itemdesc,#COLSTR_RED);		
	}*/

	result = strcat(result,itemdesc);

	result = strcat(result,"\n");

	return result;
};

float(float grentype) GetGrenCost =
{
	if (grentype == 0)
		return 0;
	if (grentype == #GR_TYPE_NORMAL)
		return #COST_GR_NORMAL;
	if (grentype == #GR_TYPE_CONCUSSION)
		return #COST_GR_CONCUSSION;
	if (grentype == #GR_TYPE_NAIL)
		return #COST_GR_NAIL;
	if (grentype == #GR_TYPE_MIRV)
		return #COST_GR_MIRV;
	if (grentype == #GR_TYPE_NAPALM)
		return #COST_GR_NAPALM;
	if (grentype == #GR_TYPE_FLARE)
		return #COST_GR_FLARE;
	if (grentype == #GR_TYPE_GAS)
		return #COST_GR_GAS;
	if (grentype == #GR_TYPE_EMP)
		return #COST_GR_EMP;
	if (grentype == #GR_TYPE_PSIONIC)
		return #COST_GR_PSIONIC;
	if (grentype == #GR_TYPE_FRAG)
		return #COST_GR_FRAG;
	if (grentype == #GR_TYPE_KRAC)
		return #COST_GR_KRAC;
	if (grentype == #GR_TYPE_ANTIGRAV)
		return #COST_GR_ANTIGRAV;
	if (grentype == #GR_TYPE_BIO)
		return #COST_GR_BIOLOGICAL;
	if (grentype == #GR_TYPE_CALTROP)
		return #COST_GR_CALTROP;

	return 0;
};

float() SpentOnGrens =
{
	local float result;

	result = GetGrenCost(self.tp_grenades_1);
	result = result + GetGrenCost(self.tp_grenades_2);

	return result;
};

float() SpentOnLegs =
{
	if (self.custom_speed == #CUSTOM_SPEED1)
		return #COST_SPEED1;
	if (self.custom_speed == #CUSTOM_SPEED2)
		return #COST_SPEED2;
	if (self.custom_speed == #CUSTOM_SPEED3)
		return #COST_SPEED3;
	if (self.custom_speed == #CUSTOM_SPEED4)
		return #COST_SPEED4;
	if (self.custom_speed == #CUSTOM_SPEED5)
		return #COST_SPEED5;
	if (self.custom_speed == #CUSTOM_SPEED6)
		return #COST_SPEED6;
	
	return 0;
};

float() GetCurrentLegs =
{
	if (self.custom_speed == #CUSTOM_SPEED1)
		return 1;
	if (self.custom_speed == #CUSTOM_SPEED2)
		return 2;
	if (self.custom_speed == #CUSTOM_SPEED3)
		return 3;
	if (self.custom_speed == #CUSTOM_SPEED4)
		return 4;
	if (self.custom_speed == #CUSTOM_SPEED5)
		return 5;
	if (self.custom_speed == #CUSTOM_SPEED6)
		return 6;
	
	return 7;
};

string(float itemnum, string itemdesc,float cost) ConstructMenuSpeedStr =
{
	local string result;
	local float bought;
	
	result = ftos(itemnum);
	result = colstr(result,#COLSTR_NUMBER);
	
	bought = #FALSE;

	if (GetCurrentLegs() == itemnum)
	{
		result = strcat("#CHAR_BOUGHT ",result);
		bought = #TRUE;
	}
	else
		result = strcat("  ",result);	 

	if (!CanBuyItem(itemnum))
	{
		result = strcat(result,"ÆÆ ");
		itemdesc = colstr(itemdesc,#COLSTR_RED);
	}
	else if (ItemIsFree(itemnum))
	{
		result = strcat(result,"ÆÆ ");
	}
	else
	{
		result = strcat(result,".. ");

		if (!bought)
		if (cost > self.money + SpentOnLegs())
			itemdesc = colstr(itemdesc,#COLSTR_RED);
	}

	result = strcat(result,itemdesc);

	if (cost < 10)
		result = strcat(result,"≠    ");
	else if (cost < 100)
		result = strcat(result,"≠   ");
	else if (cost < 1000)
		result = strcat(result,"≠  ");
	else if (cost < 10000)
		result = strcat(result,"≠ ");
	else
		result = strcat(result,"≠");
	
	itemdesc = ftos(cost);

	if (bought && cost)
		itemdesc = colstr(itemdesc,#COLSTR_NUMBER);
	/*else
	{
		if (cost > self.money)
			itemdesc = colstr(itemdesc,#COLSTR_RED);		
	}*/

	result = strcat(result,itemdesc);

	result = strcat(result,"\n");

	return result;
};

float() SpentOnHP =
{
	//WK 1/7/7 This needs to be aligned with the constants
	if (self.maxarmor == 300)
		return #COST_HP7;
	if (self.maxarmor == 200)
		return #COST_HP6;
	if (self.maxarmor == 150)
		return #COST_HP5;
	if (self.maxarmor == 120)
		return #COST_HP4;
	if (self.maxarmor == 100)
		return #COST_HP3;
	if (self.health == 90)
		return #COST_HP2;
	if (self.health == 75)
		return #COST_HP1;
	
	return 0;
};

float() GetCurrentHPItem =
{
	//WK 1/7/7 This needs to be aligned with the constants
	if (self.maxarmor == 300)
		return 7;
	if (self.maxarmor == 200)
		return 6;
	if (self.maxarmor == 150)
		return 5;
	if (self.maxarmor == 120)
		return 4;
	if (self.maxarmor == 100)
		return 3;
	if (self.health == 90)
		return 2;
	if (self.health == 75)
		return 1;
	
	return 0;
};

string(float itemnum, string itemdesc,float cost) ConstructMenuHPStr =
{
	local string result;
	local float bought;
	
	result = ftos(itemnum);
	result = colstr(result,#COLSTR_NUMBER);
	
	bought = #FALSE;

	if (GetCurrentHPItem() == itemnum)
	{
		result = strcat("#CHAR_BOUGHT ",result);
		bought = #TRUE;
	}
	else
		result = strcat("  ",result);	 

	if (!CanBuyItem(itemnum))
	{
		result = strcat(result,"ÆÆ ");
		itemdesc = colstr(itemdesc,#COLSTR_RED);
	}
	else if (ItemIsFree(itemnum))
	{
		result = strcat(result,"ÆÆ ");
	}
	else
	{
		result = strcat(result,".. ");

		if (!bought)
		if (cost > self.money + SpentOnHP())
			itemdesc = colstr(itemdesc,#COLSTR_RED);
	}

	result = strcat(result,itemdesc);

	if (cost < 10)
		result = strcat(result,"≠    ");
	else if (cost < 100)
		result = strcat(result,"≠   ");
	else if (cost < 1000)
		result = strcat(result,"≠  ");
	else if (cost < 10000)
		result = strcat(result,"≠ ");
	else
		result = strcat(result,"≠");
	
	itemdesc = ftos(cost);

	if (bought && cost)
		itemdesc = colstr(itemdesc,#COLSTR_NUMBER);
	/*else
	{
		if (cost > self.money)
			itemdesc = colstr(itemdesc,#COLSTR_RED);		
	}*/

	result = strcat(result,itemdesc); 
	
	result = strcat(result,"\n");

	return result;
};

void(entity player) UpdateArmorItem =
{
	player.items = player.items - (player.items & (#IT_ARMOR1 | #IT_ARMOR2 | #IT_ARMOR3));	
	if (player.armortype >= 0.8)
		player.items = player.items | #IT_ARMOR3;
	else if (player.armortype >= 0.6)
		player.items = player.items | #IT_ARMOR2;
	else if (player.armortype >= 0.3)
		player.items = player.items | #IT_ARMOR1;
};