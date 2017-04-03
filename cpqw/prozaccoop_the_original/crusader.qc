/*=======================================================//
// crusader.QC - CustomTF 3.2.OfN		   - 30/1/2001 - //
// by Sergio Fumaña Grunwaldt - OfteN [cp]				 //
=========================================================//
 This is all the crusader stuff created by SB-1 tech
=========================================================*/

/* defined on ofndefs.qc
#define AURA_POWER		1
#define AURA_RESIS		2
#define AURA_HASTE		3
#define AURA_INVIS		4
#define AURA_REGEN		5
#define AURA_SPEED		6
*/

// External functions
void(entity ent) MuzzleFlash;

// Crusader Settings
#define AURA_REGEN_RATE 	1
#define AURA_REGEN_AMOUNT	3

void() Aura_Regenerate;

void() JobCrusader =
{
	self.current_menu = #MENU_CRUSADER;
	self.menu_count = #MENU_REFRESH_RATE;
	self.StatusRefreshTime = time + 1;
};


// SB - crusader ability menu
void(entity pl, string s1, string s2, string s3) CenterPrint3;


// Gizmo - why aren't these first?
void(float aur) AddAura;
void() CrusaderAddInvisibility;
void() CrusaderMassHeal;
//void() CrusaderMassCure;
#ifdef NO_REVIVE
void() CrusaderDispel;
#endif

void() Menu_Crusader =
{
	local string	str1;
	local float 	amount;
	
	amount = time - self.job_finished;
	if (amount > 60)
		amount = 60;
	
	str1 = ftos(floor(amount));

	if (self.weapons_carried & #WEAP_MEDIKIT)
	{
		//CenterPrint3(self, " Áãôéïî:                 \n\n.. Aura of Power        Û15 manaÝ\n.. Aura of Resistance   Û15 manaÝ\n.. Aura of Haste        Û15 manaÝ\n.. Aura of Regeneration Û15 manaÝ\n.. Aura of Invisibility Û45 manaÝ\n.. Resurrect            Û30 manaÝ\n.. Mass healing         Û20 manaÝ\n.. Mass cure            Û20 manaÝ\n.. Sing                 Û 0 manaÝ\n\nÍáîá ìåæô: ", str1,"\n\n.. Îïôèéîç                       ");

#ifdef NO_REVIVE
		if (amount >= 45)
			CenterPrint3(self, "Áãôéïî:                 \n\n.. Aura of Power        Û íáîáÝ\n.. Aura of Resistance   Û íáîáÝ\n.. Aura of Haste        Û íáîáÝ\n.. Aura of Regeneration Û íáîáÝ\n.. Aura of Speed        Û íáîáÝ\n.. Aura of Invisibility Û íáîáÝ\n.. Dispel Evil          Û íáîáÝ\n.. Mass healing         Û íáîáÝ\n\n.. Start Singing                 \n\nÍáîá ìåæô: ", str1,"\n\n.. Îïôèéîç                       ");
		else if (amount >= 30)
			CenterPrint3(self, "Áãôéïî:                 \n\n.. Aura of Power        Û íáîáÝ\n.. Aura of Resistance   Û íáîáÝ\n.. Aura of Haste        Û íáîáÝ\n.. Aura of Regeneration Û íáîáÝ\n.. Aura of Speed        Û íáîáÝ\n.. Aura of Invisibility Û45 manaÝ\n.. Dispel Evil          Û íáîáÝ\n.. Mass healing         Û íáîáÝ\n\n.. Start Singing                 \n\nÍáîá ìåæô: ", str1,"\n\n.. Îïôèéîç                       ");
		else if (amount >= 20)
			CenterPrint3(self, "Áãôéïî:                 \n\n.. Aura of Power        Û íáîáÝ\n.. Aura of Resistance   Û íáîáÝ\n.. Aura of Haste        Û íáîáÝ\n.. Aura of Regeneration Û íáîáÝ\n.. Aura of Speed        Û íáîáÝ\n.. Aura of Invisibility Û45 manaÝ\n.. Dispel Evil          Û30 manaÝ\n.. Mass healing         Û íáîáÝ\n\n.. Start Singing                 \n\nÍáîá ìåæô: ", str1,"\n\n.. Îïôèéîç                       ");
		else if (amount >= 15)
			CenterPrint3(self, "Áãôéïî:                 \n\n.. Aura of Power        Û íáîáÝ\n.. Aura of Resistance   Û íáîáÝ\n.. Aura of Haste        Û íáîáÝ\n.. Aura of Regeneration Û íáîáÝ\n.. Aura of Speed        Û íáîáÝ\n.. Aura of Invisibility Û45 manaÝ\n.. Dispel Evil          Û30 manaÝ\n.. Mass healing         Û20 manaÝ\n\n.. Start Singing                 \n\nÍáîá ìåæô: ", str1,"\n\n.. Îïôèéîç                       ");
		else
			CenterPrint3(self, "Áãôéïî:                 \n\n.. Aura of Power        Û15 manaÝ\n.. Aura of Resistance   Û15 manaÝ\n.. Aura of Haste        Û15 manaÝ\n.. Aura of Regeneration Û15 manaÝ\n.. Aura of Speed        Û15 manaÝ\n.. Aura of Invisibility Û45 manaÝ\n.. Dispel Evil          Û30 manaÝ\n.. Mass healing         Û20 manaÝ\n\n.. Start Singing                 \n\nÍáîá ìåæô: ", str1,"\n\n.. Îïôèéîç                       ");
#else
		if (amount >= 45)
			CenterPrint3(self, "Áãôéïî:                 \n\n.. Aura of Power        Û íáîáÝ\n.. Aura of Resistance   Û íáîáÝ\n.. Aura of Haste        Û íáîáÝ\n.. Aura of Regeneration Û íáîáÝ\n.. Aura of Speed        Û íáîáÝ\n.. Aura of Invisibility Û íáîáÝ\n.. Mass healing/revive  Û íáîáÝ\n\n.. Start Singing                 \n\nÍáîá ìåæô: ", str1,"\n\n.. Îïôèéîç                       ");
//		else if (amount >= 30)
//			CenterPrint3(self, "Áãôéïî:                 \n\n.. Aura of Power        Û íáîáÝ\n.. Aura of Resistance   Û íáîáÝ\n.. Aura of Haste        Û íáîáÝ\n.. Aura of Regeneration Û íáîáÝ\n.. Aura of Speed        Û íáîáÝ\n.. Aura of Invisibility Û45 manaÝ\n.. Mass healing/revive  Û íáîáÝ\n\n.. Start Singing                 \n\nÍáîá ìåæô: ", str1,"\n\n.. Îïôèéîç                       ");
		else if (amount >= 20)
			CenterPrint3(self, "Áãôéïî:                 \n\n.. Aura of Power        Û íáîáÝ\n.. Aura of Resistance   Û íáîáÝ\n.. Aura of Haste        Û íáîáÝ\n.. Aura of Regeneration Û íáîáÝ\n.. Aura of Speed        Û íáîáÝ\n.. Aura of Invisibility Û45 manaÝ\n.. Mass healing/revive  Û íáîáÝ\n\n.. Start Singing                 \n\nÍáîá ìåæô: ", str1,"\n\n.. Îïôèéîç                       ");
		else if (amount >= 15)
			CenterPrint3(self, "Áãôéïî:                 \n\n.. Aura of Power        Û íáîáÝ\n.. Aura of Resistance   Û íáîáÝ\n.. Aura of Haste        Û íáîáÝ\n.. Aura of Regeneration Û íáîáÝ\n.. Aura of Speed        Û íáîáÝ\n.. Aura of Invisibility Û45 manaÝ\n.. Mass healing/revive  Û20 manaÝ\n\n.. Start Singing                 \n\nÍáîá ìåæô: ", str1,"\n\n.. Îïôèéîç                       ");
		else
			CenterPrint3(self, "Áãôéïî:                 \n\n.. Aura of Power        Û15 manaÝ\n.. Aura of Resistance   Û15 manaÝ\n.. Aura of Haste        Û15 manaÝ\n.. Aura of Regeneration Û15 manaÝ\n.. Aura of Speed        Û15 manaÝ\n.. Aura of Invisibility Û45 manaÝ\n.. Mass healing/revive  Û20 manaÝ\n\n.. Start Singing                 \n\nÍáîá ìåæô: ", str1,"\n\n.. Îïôèéîç                       ");
#endif
	}
	else
	{
		//CenterPrint3(self, " Áãôéïî:                 \n\n.. Aura of Power        Û15 manaÝ\n.. Aura of Resistance   Û15 manaÝ\n.. Aura of Haste        Û15 manaÝ\n.. Aura of Regeneration Û15 manaÝ\n.. Aura of Invisibility Û45 manaÝ\n.. Resurrect            Û30 manaÝ\n.. Sing                 Û 0 manaÝ\n\nÍáîá ìåæô: ", str1,"\n\n.. Îïôèéîç                       ");
		//CenterPrint3(self, " Áãôéïî:                 \n\n.. Aura of Power        Û15 manaÝ\n.. Aura of Resistance   Û15 manaÝ\n.. Aura of Haste        Û15 manaÝ\n.. Aura of Regeneration Û15 manaÝ\n.. Aura of Speed        Û15 manaÝ\n.. Aura of Invisibility Û45 manaÝ\n.. Resurrect            Û30 manaÝ\n.. Sing                 Û 0 manaÝ\n\nÍáîá ìåæô: ", str1,"\n\n.. Îïôèéîç                       ");

#ifdef NO_REVIVE
		if (amount >= 45)
			CenterPrint3(self, "Áãôéïî:                 \n\n.. Aura of Power        Û íáîáÝ\n.. Aura of Resistance   Û íáîáÝ\n.. Aura of Haste        Û íáîáÝ\n.. Aura of Regeneration Û íáîáÝ\n.. Aura of Speed        Û íáîáÝ\n.. Aura of Invisibility Û íáîáÝ\n.. Dispel Evil          Û íáîáÝ\n\n.. Start Singing                 \n\nÍáîá ìåæô: ", str1,"\n\n.. Îïôèéîç                       ");
		else if (amount >= 30)
			CenterPrint3(self, "Áãôéïî:                 \n\n.. Aura of Power        Û íáîáÝ\n.. Aura of Resistance   Û íáîáÝ\n.. Aura of Haste        Û íáîáÝ\n.. Aura of Regeneration Û íáîáÝ\n.. Aura of Speed        Û íáîáÝ\n.. Aura of Invisibility Û45 manaÝ\n.. Dispel Evil          Û íáîáÝ\n\n.. Start Singing                 \n\nÍáîá ìåæô: ", str1,"\n\n.. Îïôèéîç                       ");
//		else if (amount >= 20)
//			CenterPrint3(self, "Áãôéïî:                 \n\n.. Aura of Power        Û íáîáÝ\n.. Aura of Resistance   Û íáîáÝ\n.. Aura of Haste        Û íáîáÝ\n.. Aura of Regeneration Û íáîáÝ\n.. Aura of Speed        Û íáîáÝ\n.. Aura of Invisibility Û45 manaÝ\n.. Dispel Evil          Û30 manaÝ\n\n.. Start Singing                 \n\nÍáîá ìåæô: ", str1,"\n\n.. Îïôèéîç                       ");
		else if (amount >= 15)
			CenterPrint3(self, "Áãôéïî:                 \n\n.. Aura of Power        Û íáîáÝ\n.. Aura of Resistance   Û íáîáÝ\n.. Aura of Haste        Û íáîáÝ\n.. Aura of Regeneration Û íáîáÝ\n.. Aura of Speed        Û íáîáÝ\n.. Aura of Invisibility Û45 manaÝ\n.. Dispel Evil          Û30 manaÝ\n\n.. Start Singing                 \n\nÍáîá ìåæô: ", str1,"\n\n.. Îïôèéîç                       ");
		else
			CenterPrint3(self, "Áãôéïî:                 \n\n.. Aura of Power        Û15 manaÝ\n.. Aura of Resistance   Û15 manaÝ\n.. Aura of Haste        Û15 manaÝ\n.. Aura of Regeneration Û15 manaÝ\n.. Aura of Speed        Û15 manaÝ\n.. Aura of Invisibility Û45 manaÝ\n.. Dispel Evil          Û30 manaÝ\n\n.. Start Singing                 \n\nÍáîá ìåæô: ", str1,"\n\n.. Îïôèéîç                       ");
#else
		if (amount >= 45)
			CenterPrint3(self, "Áãôéïî:                 \n\n.. Aura of Power        Û íáîáÝ\n.. Aura of Resistance   Û íáîáÝ\n.. Aura of Haste        Û íáîáÝ\n.. Aura of Regeneration Û íáîáÝ\n.. Aura of Speed        Û íáîáÝ\n.. Aura of Invisibility Û íáîáÝ\n\n.. Start Singing                 \n\nÍáîá ìåæô: ", str1,"\n\n.. Îïôèéîç                       ");
//		else if (amount >= 30)
//			CenterPrint3(self, "Áãôéïî:                 \n\n.. Aura of Power        Û íáîáÝ\n.. Aura of Resistance   Û íáîáÝ\n.. Aura of Haste        Û íáîáÝ\n.. Aura of Regeneration Û íáîáÝ\n.. Aura of Speed        Û íáîáÝ\n.. Aura of Invisibility Û45 manaÝ\n\n.. Start Singing                 \n\nÍáîá ìåæô: ", str1,"\n\n.. Îïôèéîç                       ");
//		else if (amount >= 20)
//			CenterPrint3(self, "Áãôéïî:                 \n\n.. Aura of Power        Û íáîáÝ\n.. Aura of Resistance   Û íáîáÝ\n.. Aura of Haste        Û íáîáÝ\n.. Aura of Regeneration Û íáîáÝ\n.. Aura of Speed        Û íáîáÝ\n.. Aura of Invisibility Û45 manaÝ\n\n.. Start Singing                 \n\nÍáîá ìåæô: ", str1,"\n\n.. Îïôèéîç                       ");
		else if (amount >= 15)
			CenterPrint3(self, "Áãôéïî:                 \n\n.. Aura of Power        Û íáîáÝ\n.. Aura of Resistance   Û íáîáÝ\n.. Aura of Haste        Û íáîáÝ\n.. Aura of Regeneration Û íáîáÝ\n.. Aura of Speed        Û íáîáÝ\n.. Aura of Invisibility Û45 manaÝ\n\n.. Start Singing                 \n\nÍáîá ìåæô: ", str1,"\n\n.. Îïôèéîç                       ");
		else
			CenterPrint3(self, "Áãôéïî:                 \n\n.. Aura of Power        Û15 manaÝ\n.. Aura of Resistance   Û15 manaÝ\n.. Aura of Haste        Û15 manaÝ\n.. Aura of Regeneration Û15 manaÝ\n.. Aura of Speed        Û15 manaÝ\n.. Aura of Invisibility Û45 manaÝ\n\n.. Start Singing                 \n\nÍáîá ìåæô: ", str1,"\n\n.. Îïôèéîç                       ");
#endif
	}

	self.StatusRefreshTime = time + 1;
};

void(float inp) Menu_Crusader_Input =
{
	// If you read this, this is how you should be doing menus. HEAR ME?? No? Well I assume you
	// are reading it so that'll have to do.
	
	if (inp == 1)
		AddAura(#AURA_POWER);
	else if (inp == 2)
		AddAura(#AURA_RESIS);
	else if (inp == 3)
		AddAura(#AURA_HASTE);
	else if (inp == 4)
		AddAura(#AURA_REGEN);

	else if (inp == 5)
		AddAura(#AURA_SPEED);
	else if (inp == 6)
		CrusaderAddInvisibility();
#ifdef NO_REVIVE
	else if (inp == 7)
		CrusaderDispel();
#endif
	else if (inp == 8)
		CrusaderMassHeal();
		
	/*else if (inp == 5)
		CrusaderAddInvisibility();
	else if (inp == 6)
		CrusaderDispel();
	else if (inp == 7)
		CrusaderMassHeal();
	else if (inp == 8)
		CrusaderMassCure();*/
	else if (inp == 9)
		sound (self, #CHAN_MUSIC, "ambience/orff.wav", 1, #ATTN_NORM);
	else if (inp == 10)
		inp = 0;
	else
		return;

	self.impulse = 0;
	ResetMenu();
};


//float(vector veca, vector vecb) crossproduct;

entity (entity crusader) Crusader_FindIdiot =
{
	local entity	guy;
	local entity	matched;
	local vector	source;
	local vector	vec;
	local float		matchlevel, oldmatch;
	local float		matchResult, guyIsTeammate, matchIsTeammate;

	// Gizmo - reworked aura targeting since the old one would do stupid things when someone was close but no where near your crosshairs
	makevectors( crusader.v_angle );
	source = crusader.origin + '0 0 16';
	traceline( source, source + v_forward*250, #TL_ANY_SOLID, crusader );

	// ugly, but should be faster since QC doesn't support short-circuit logical operators
	// if we directly hit a valid target, then choose that one
	if ( trace_ent != world )
	if ( trace_ent.takedamage )
	if ( trace_ent.health > 0 )
	if ( trace_ent.classname == "player" || IsMonster( trace_ent ) )	// Gizmo - allow non demons and non army soldiers to be affected (coop monsters)
		return trace_ent;

	source = trace_endpos;		// Gizmo - for some reason trace_endpos was equal to guy.origin in the below code when I tested...

	matchlevel = 0;
	matched = crusader;
	oldmatch = 0;

	guy = findradius(crusader.origin, 250);
	while (guy)
	{
		// Gizmo - target must be visible
		if ( guy != crusader )
		if ( guy.takedamage )
		if ( guy.health > 0 )
		if ( guy.classname == "player" || IsMonster( guy ) )	// Gizmo - allow non demons and non army soldiers to be affected (coop monsters)
		if ( visible2( guy, crusader ) )
		{
			vec = normalize( guy.origin - crusader.origin );
			vec_z = vec * v_forward;
			matchlevel = vlen( guy.origin - source );		// guy.origin - trace_endpos

			// Gizmo - don't prefer enemies over teammates, but still pick the closest enemy if all we've found are enemies
			local float temp;

			matchResult = matchlevel < oldmatch;
			temp = GetTeam( guy );
			guyIsTeammate = Teammate( crusader.team_no, temp );
			temp = GetTeam( matched );
			matchIsTeammate = Teammate( crusader.team_no, temp );

			if ( vec_z > 0.3 )
			if ( matched == crusader || ( !matchIsTeammate && guyIsTeammate )
				|| ( matchResult && ( !matchIsTeammate || ( matchIsTeammate && guyIsTeammate ) ) ) ) {
				matched = guy;
				oldmatch = matchlevel;
			}
		}
		guy = guy.chain;
	}

	if (oldmatch < 250)
		return matched;
	else
		return crusader;
};

void(float aur) AddAura =
{
	local float amount;
	local entity targ;

	amount = time - self.job_finished;
	if (amount > 60)
		amount = 60;

	if (amount < 15)
	{
		sprint(self, #PRINT_HIGH, "You don't have enough mana to bestow an aura\n");
		return;
	}

	targ = Crusader_FindIdiot(self);

	#ifndef CRUSADER_TEST
	if (self == targ)
	{
		sprint(self, #PRINT_HIGH, "There is nobody there to bestow an aura upon\n");
		return;
	}
	#endif

	if (targ.aura == aur)
	{
		sprint(self, #PRINT_HIGH, targ.netname, " already has that aura.\n");
		return;
	}

	if (IsOwnedMonster(targ))
	{
		if (aur == #AURA_HASTE)
		{
			if (targ.classname == "monster_army")
				sprint(self, #PRINT_HIGH, "You can't bestow an aura of haste onto an army soldier!\n");
			else
				sprint(self, #PRINT_HIGH, "You can't bestow an aura of haste onto a monster!\n");

			return;
		}
		else if (aur == #AURA_SPEED)
		{
			if (targ.classname == "monster_army")
				sprint(self, #PRINT_HIGH, "You can't bestow an aura of speed onto an army soldier!\n");
			else
				sprint(self, #PRINT_HIGH, "You can't bestow an aura of speed onto a monster!\n");

			return;
		}
	}

	#ifdef DONT_SET_AURA_TO_ENEMIES
	if (!Teammate(targ.team_no,self.team_no) && !Teammate(targ.undercover_team,self.team_no)) // Teammates or spies allowed
	{
		sprint(self, #PRINT_HIGH, "You can't bestow auras onto enemies!\n");
		return;
	}
	#endif

#ifdef COOP_MODE_ENHANCED
	if ( npcAi_IsCoopMonster( targ ) ) {
		sprint( self, #PRINT_HIGH, "You cannot bestow an aura to this monster\n" );
		return;
	}
#endif

	#ifndef CRUSADER_TEST

	#ifndef ALLOW_AURAS_ON_CRUSADERS
	if (!(targ.job & #JOB_CRUSADER))
	{
	#endif

	#endif
		sound (targ, #CHAN_ITEM, "auras/aura3b.wav", 1, #ATTN_NORM);

		// Create Lightning effect for crusader indicating target for aura
		msg_entity = self;
		WriteByte (#MSG_ONE, #SVC_TEMPENTITY);
		WriteByte (#MSG_ONE, #TE_LIGHTNING1);
		WriteEntity (#MSG_ONE, self);
		WriteCoord (#MSG_ONE, self.origin_x);
		WriteCoord (#MSG_ONE, self.origin_y);
		WriteCoord (#MSG_ONE, self.origin_z);
		WriteCoord (#MSG_ONE, targ.origin_x);
		WriteCoord (#MSG_ONE, targ.origin_y);
		WriteCoord (#MSG_ONE, targ.origin_z);

		// Lightning for target too (if a player)
		if (targ.classname == "player")
		{
			msg_entity = targ;
			WriteByte (#MSG_ONE, #SVC_TEMPENTITY);
			WriteByte (#MSG_ONE, #TE_LIGHTNING1);
			WriteEntity (#MSG_ONE, targ);
			WriteCoord (#MSG_ONE, targ.origin_x);
			WriteCoord (#MSG_ONE, targ.origin_y);
			WriteCoord (#MSG_ONE, targ.origin_z);
			WriteCoord (#MSG_ONE, self.origin_x);
			WriteCoord (#MSG_ONE, self.origin_y);
			WriteCoord (#MSG_ONE, self.origin_z);
		}

		// flash the target and crusader
		MuzzleFlash(self);
		MuzzleFlash(targ);

		// Flash screen of both crusader and guy receiving aura
		stuffcmd(self,"bf;bf\n");
		if (targ.classname == "player")
			stuffcmd(targ,"bf;bf\n");

		local string strung;
		local float oldaur;
		local string oldstrung;

		oldaur = targ.aura;
		targ.aura = aur;
		targ.crusader_inspirator = self;
		amount = amount - 15;
		self.job_finished = time - amount;

		// Spawn regeneration timer, if needed (monsters dont use one, they use the AI_Check_Contents sub)
		if (aur == #AURA_REGEN && targ.classname == "player")
		{
			local entity te;
			te = spawn();
			te.nextthink = time + #AURA_REGEN_RATE;
			te.think = Aura_Regenerate;
			te.owner = targ;
			te.classname = "timer";
		}

		if (targ.aura == #AURA_POWER)
			strung = "Aura of Power.\n";
		else if (targ.aura == #AURA_RESIS)
			strung = "Aura of Resistance.\n";
		else if (targ.aura == #AURA_HASTE)
			strung = "Aura of Haste.\n";
		else if (targ.aura == #AURA_REGEN)
			strung = "Aura of Regeneration.\n";
		else if (targ.aura == #AURA_SPEED)
			strung = "Aura of Speed.\n";
		else
			strung = "Aura of Bugs.\n";	// Gizmo

		if (oldaur == #AURA_POWER)
			oldstrung = "Aura of Power";
		else if (oldaur == #AURA_RESIS)
			oldstrung = "Aura of Resistance";
		else if (oldaur == #AURA_HASTE)
			oldstrung = "Aura of Haste";
		else if (oldaur == #AURA_REGEN)
			oldstrung = "Aura of Regeneration";
		else if (oldaur == #AURA_SPEED)
			oldstrung = "Aura of Speed";
		else
			oldstrung = "Aura of Bugs";	// Gizmo

		if (IsOwnedMonster(targ)) // Monsters
		{
			local string thingname;
			local string tmps;
			thingname = GetMonsterName(targ);

			if (oldaur == 0)
				sprint(self, #PRINT_HIGH, "You give to the ",thingname," ",targ.netname, " the ", strung);
			else
			{
				sprint(self, #PRINT_HIGH, "You replace the ", oldstrung," of the ",thingname);
				sprint(self, #PRINT_HIGH," ", targ.netname," with an ",strung); //, targ.netname, "'s ", oldstrung, " with an ", strung);
			}

			sprint(targ.real_owner, #PRINT_HIGH, self.netname, " bestows upon your ",thingname," an ", strung);

			teamprefixsprintbi(self.team_no,self,targ.real_owner);

			tmps = strcat(self.netname," gives to our ");
			teamsprintbi(self,targ.real_owner,tmps,thingname," ",targ.netname," an ",strung);			 
		}
		else // Players
		{
			// TODO?: Use .undercover_name for spies?

			// Set new speed if speed aura is beeing cast or replaced
			if (aur == #AURA_SPEED || oldaur == #AURA_SPEED)
				TeamFortress_SetSpeed(targ);

			if (oldaur == 0)
				sprint(self, #PRINT_HIGH, "You provide ", targ.netname, " with an ", strung);
			else
				sprint(self, #PRINT_HIGH, "You replace ", targ.netname, "'s ", oldstrung, " with an ", strung);

			sprint(targ, #PRINT_HIGH, self.netname, " bestows upon you an ", strung);

			if (!Teammate(self.team_no,targ.team_no))// && Teammate(self.team_no,targ.undercover_team)) // Spies
			{
				teamprefixsprintbi(targ.team_no,self,targ);
				teamsprintbi(targ,self,"The enemy crusader ",self.netname," gives to ",targ.netname," the ",strung);
			}
			else
			{
				teamprefixsprintbi(self.team_no,self,targ);
				teamsprintbi(self,targ,self.netname," gives to ",targ.netname," the ",strung,"");
			}
		}

	#ifndef CRUSADER_TEST

	#ifndef ALLOW_AURAS_ON_CRUSADERS

	}
	else //if (targ.job & #JOB_CRUSADER)
		sprint(self, #PRINT_HIGH, targ.netname, " is a Crusader and their Aura of Righteousness may not be replaced.\n");
	//else
	//	sprint(self, #PRINT_HIGH, "You may only bestow an aura upon a player\n");

	#endif

	#endif
};

void() CrusaderAddInvisibility =
{
	local float amount;
	local entity targ;

	amount = time - self.job_finished;
	if (amount > 60)
		amount = 60;

	if (amount < 45)
	{
		sprint(self, #PRINT_HIGH, "You don't have enough mana to grant invisibility\n");
		return;
	}

	targ = Crusader_FindIdiot(self);

	if (self == targ)
	{
		sprint(self, #PRINT_HIGH, "There is nobody there to bestow an aura upon\n");
		return;
	}

	if (IsSummon(targ))
	{
		sprint(self, #PRINT_HIGH, "You can't make a monster invisible!\n");
		return;
	}

	if (targ.classname == "monster_army")
	{
		sprint(self, #PRINT_HIGH, "You can't make an Army soldier invisible!\n");
		return;
	}

#ifdef COOP_MODE_ENHANCED
	// this shouldn't happen, so don't print out a warning... infact if this happens, it's a bug
	if ( npcAi_IsCoopMonster( targ ) )
		return;
#endif

	#ifndef ALLOW_AURAS_ON_CRUSADERS
	if (!(targ.job & #JOB_CRUSADER))
	{
	#endif
		sound (targ, #CHAN_ITEM, "auras/aura3b.wav", 1, #ATTN_NORM);

		// Create Lightning effect for crusader indicating target for aura
		msg_entity = self;
		WriteByte (#MSG_ONE, #SVC_TEMPENTITY);
		WriteByte (#MSG_ONE, #TE_LIGHTNING1);
		WriteEntity (#MSG_ONE, self);
		WriteCoord (#MSG_ONE, self.origin_x);
		WriteCoord (#MSG_ONE, self.origin_y);
		WriteCoord (#MSG_ONE, self.origin_z);
		WriteCoord (#MSG_ONE, targ.origin_x);
		WriteCoord (#MSG_ONE, targ.origin_y);
		WriteCoord (#MSG_ONE, targ.origin_z);

		// Lightning for target too
		msg_entity = targ;
		WriteByte (#MSG_ONE, #SVC_TEMPENTITY);
		WriteByte (#MSG_ONE, #TE_LIGHTNING1);
		WriteEntity (#MSG_ONE, targ);
		WriteCoord (#MSG_ONE, targ.origin_x);
		WriteCoord (#MSG_ONE, targ.origin_y);
		WriteCoord (#MSG_ONE, targ.origin_z);
		WriteCoord (#MSG_ONE, self.origin_x);
		WriteCoord (#MSG_ONE, self.origin_y);
		WriteCoord (#MSG_ONE, self.origin_z);

		// Flash screen of both crusader and guy receiving aura
		stuffcmd(self,"bf;bf\n");
		stuffcmd(targ,"bf;bf\n");

		// Flash both crusader and target entities
		MuzzleFlash(self);
		MuzzleFlash(targ);

		sprint(self, #PRINT_HIGH, "You provide ", targ.netname, " with powers of invisibility! They will be invisible for the next 10 seconds!\n");
		sprint(targ, #PRINT_HIGH, self.netname, " grants you an Aura of Invisibility! You will be fully invisibile for the next 10 seconds!\n");
		targ.aura = #AURA_INVIS;
		targ.aura_time = time + 10;
		amount = amount - 45;
		self.job_finished = time - amount;
		targ.items = targ.items | #IT_INVISIBILITY;

		if (!Teammate(self.team_no,targ.team_no))// && Teammate(self.team_no,targ.undercover_team)) // Spies
		{
			teamprefixsprintbi(targ.team_no,self,targ);
			teamsprintbi(targ,self,"The enemy crusader ",self.netname," gives to ",targ.netname," the Aura of Invisibility!\n","");
		}
		else
		{
			teamprefixsprintbi(self.team_no,self,targ);
			teamsprintbi(self,targ,self.netname," gives to ",targ.netname," the Aura of Invisibility\n","","");
		}

	#ifndef ALLOW_AURAS_ON_CRUSADERS
	} else
		sprint(self, #PRINT_HIGH, "You cannot bestow invisibility upon another Crusader\n");
	#endif
};

void() CrusaderMassHeal =
{
	local entity te;
	local float amount;
	
	if (!(self.weapons_carried & #WEAP_MEDIKIT))
	{
#ifdef NO_REVIVE
		sprint(self, #PRINT_HIGH, "You cannot perform mass heal without a medikit\n");
#else
		sprint( self, #PRINT_HIGH, "You cannot perform mass heal/revive without a medikit\n" );
#endif
		return;
	}

	amount = time - self.job_finished;
	if (amount > 60)
		amount = 60;
	
	if (amount < 20)
	{
#ifdef NO_REVIVE
		sprint(self, #PRINT_HIGH, "You don't have enough mana to perform a mass heal\n");
#else
		sprint( self, #PRINT_HIGH, "You don't have enough mana to perform a mass heal/revive\n" );
#endif
		return;
	}
	
	te = findradius(self.origin, 600);
	while (te)
	{
		if (te.classname == "player")
		{
			if ( Teammate( te.team_no, self.team_no ) )
			{
#ifndef NO_REVIVE
				if ( MedicRevive( self, te, 0 ) )
					sprint( te, #PRINT_HIGH, self.netname, " revives you\n" );
				else
				{
#endif
					if (te.is_connected)
					if (te != self) // Skip crusader casting this heal
					if (te.health > 0) // alive?
					if (!(te.done_custom & #CUSTOM_BUILDING)) // skip ppl customizing
					if (te.playerclass != #PC_UNDEFINED) // skip observers
					if (te.penance_time < time) // Don't let lame teamkillers take runes
//					if (Teammate(te.team_no, self.team_no))
						if (te.health < te.max_health)
						{
							sound (te, #CHAN_ITEM, "auras/aura3b.wav", 1, #ATTN_NORM);
							
							te.health = te.max_health;
							//if (self != te)
								sprint(te, #PRINT_HIGH, self.netname, " restores you to full health\n");
							//else
							//	sprint(te, #PRINT_HIGH, "Your deity restores you to full health\n");
						}
#ifndef NO_REVIVE
				}
#endif
			}
		}
		else if (IsMonster(te))		// Gizmo - allow non demons and non army soldiers to be affected (coop monsters)
		{
			local float temp;

			temp = GetTeam( te );
			if (Teammate(temp, self.team_no))
			{
				te.health = te.health + 100;
				if (te.health > te.max_health)
					te.health = te.max_health;

				sound (te, #CHAN_ITEM, "auras/aura3b.wav", 1, #ATTN_NORM);
			}
		}

		te = te.chain;
	}
	amount = amount - 20;
	self.job_finished = time - amount;
	sound(self, #CHAN_ITEM, "items/r_item2.wav", 1, #ATTN_NORM);
};

/*float(entity doc, entity patient, vector org) CureAdverseEffects;

void() CrusaderMassCure =
{
	local entity te;
	local float amount;
	local string tmps;
	
	if (!self.weapons_carried & #WEAP_MEDIKIT)
	{
		sprint(self, #PRINT_HIGH, "You cannot perform mass cure without a medikit\n");
		return;
	}
	
	amount = time - self.job_finished;
	if (amount > 60)
		amount = 60;
	
	if (amount < 20)
	{
		sprint(self, #PRINT_HIGH, "You don't have enough mana to perform a mass cure\n");
		return;
	}
	
	te = findradius(self.origin, 600);
	while (te)
	{
		if (te.classname == "player")
		{		
			if (Teammate(te.team_no, self.team_no))
			if (te.has_disconnected == #FALSE)
				CureAdverseEffects(self, te, te.origin);
		}
		else if (IsMonster(te))
		{
			if (Teammate(te.real_owner.team_no, self.team_no))
			if (te.health > 0)
			if (te.tfstate & #TFSTATE_INFECTED)
			{
				te.tfstate = te.tfstate - #TFSTATE_INFECTED;
				
				tmps = GetMonsterName(te);

				// Report to the owner of the monster
				sprint(te.real_owner,#PRINT_HIGH,"Your ",tmps," has been cured by the crusader ",self.netname,"\n");
				
				// Report to teammates
				teamprefixsprintbi(te.real_owner.team_no,te.real_owner,self);
				teamsprintbi(te.real_owner,self,self.netname, " cures the ",tmps," ",te.netname,"\n");
			}
		}
		
		te = te.chain;
	}
	amount = amount - 20;
	self.job_finished = time - amount;
	sound(self, #CHAN_ITEM, "items/health1.wav", 1, #ATTN_NORM);
	
};*/

#ifdef NO_REVIVE
void() CrusaderDispel =
{
	local entity te;
	local float amount;
	
	amount = time - self.job_finished;
	if (amount > 60)
		amount = 60;
	
	if (amount < 30)
	{
		sprint(self, #PRINT_HIGH, "You don't have enough mana to dispel evil\n");
		return;
	}
	
	te = findradius(self.origin, 1000);
	while (te)
	{
		if (!Teammate(self.team_no, te.team_no)) {
			/*if (te.classname == "monster_demon1")
				TF_T_Damage(te, self, self, 500, 0, #TF_TD_OTHER);
			else if (te.classname == "monster_shambler")
				TF_T_Damage(te, self, self, 830, 0, #TF_TD_OTHER);
			else if (coop)
			{
				if (te.classname == "monster_zombie")
					TF_T_Damage(te, self, self, 200, 0, #TF_TD_OTHER);
				else if (te.classname == "monster_wizard")
					TF_T_Damage(te, self, self, 200, 0, #TF_TD_OTHER);
				else if (te.classname == "monster_shalrath")
					TF_T_Damage(te, self, self, 250, 0, #TF_TD_OTHER);
			}*/
			if (IsSummon(te)) {
				TF_T_Damage(te, self, self, 300 + 300*random(), 0, #TF_TD_OTHER); // Original 500
			} else if (te.classname == "player" && te.health > 0) {
				if (te.job & #JOB_WARLOCK)
				{
					local entity oself;
					
					te.attack_finished = time + 5;
					te.job_finished = time + 25;
					sprint(te, #PRINT_HIGH, self.netname, " dispels you!\n");
					oself = self;
					self = te;
					if (te.current_menu == #MENU_DEMON)
						ResetMenu();
					self = oself;

					sound (te, #CHAN_ITEM, "auras/aura3b.wav", 1, #ATTN_NORM);

					deathmsg = #DMSG_DISPEL;
					TF_T_Damage(te, self, self, 25, 0, #TF_TD_OTHER);
				}
			}
#ifdef COOP_MODE_ENHANCED
			else if ( npcAi_IsCoopMonster( te ) ) {
				deathmsg = #DMSG_DISPEL;
				TF_T_Damage( te, self, self, 100 + 400*random(), 0, #TF_TD_OTHER );
			}
#endif
		}

		te = te.chain;
	}
	
	amount = amount - 30;
	self.job_finished = time - amount;
	sound(self, #CHAN_ITEM, "misc/power.wav", 1, #ATTN_NORM);
};
#endif

void() Aura_Regenerate =
{
	if (!(self.owner.is_connected) || self.owner.classname != "player" || self.owner.aura != #AURA_REGEN)
	{
		dremove(self);
		return;
	}	 

	if (self.owner.is_abouttodie || self.owner.health <= 0)
	{
		dremove(self);
		return;
	}

	// Regenerate health
	if (self.owner.health < self.owner.max_health) // Check
	{
		if (self.owner.health + #AURA_REGEN_AMOUNT > self.owner.max_health)
			self.owner.health = self.owner.max_health;
		else
			self.owner.health = self.owner.health + #AURA_REGEN_AMOUNT;
	}
	
	// Regenerate armor if any left
	if (self.owner.armorvalue > 0)
	{
		if (self.owner.armorvalue + #AURA_REGEN_AMOUNT > self.owner.maxarmor)
			self.owner.armorvalue = self.owner.maxarmor;
		else
			self.owner.armorvalue = self.owner.armorvalue + #AURA_REGEN_AMOUNT;
	}

	// Cya soon!
	self.nextthink = time + #AURA_REGEN_RATE;
};
