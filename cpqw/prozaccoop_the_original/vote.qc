/*=======================================================//
// Vote.QC - CustomTF 3.2.OfN			  - 04/11/2002 - //
// by Sergio FumaÒa Grunwaldt - OfteN [cp]				 //
=========================================================//
 Voting system functions and stuff...
 (Requires PROZAC qwsv, uses special built-ins)
=========================================================*/
// modified vote system provided by randomer. -Pulseczar (1/15/07)
//=======================================================

// Flag defines

// vote entity types
// Gizmo - if voting for AGR in coop, TF will be enabled with AGR
#define VOTE_NONE			0	// Gizmo - this MUST be zero!
#define VOTE_PUNISH 		1
#define VOTE_NEXTMAP		2	// Gizmo - use VOTEMAP_ macros to determine the type of next or switchmap vote
#define VOTE_SWITCHMAP		3
#define VOTE_USEOBJECT		4	// Gizmo - similar to admin use

// punish types
#define PUNISH_NONE 		0
#define PUNISH_CURSE		1
#define PUNISH_KICK 		2
#define PUNISH_BAN			3
#define PUNISH_MUTE 		4
#define PUNISH_CUFF 		5

// Gizmo - map vote types, nextmap or switchmap is determined by the #VOTE_*** type itself, not this
#define VOTEMAP_DEFAULT		0	// the default mode the server has set
#define VOTEMAP_AGR		1	// if TF is default, this acts normally, if coop is default then it'll be in TF mode with AGR
#ifdef COOP_MODE_ENHANCED
#define VOTEMAP_TF		2	// only valid if the server has coop as default
#define VOTEMAP_COOP		3	// only valid if the server has TF as default
#define VOTEMAP_INSANECOOP	4	// only valid if the server has TF as default
#endif

// player voting status
#define VOTED_READY 		0
#define VOTED_YES			1
#define VOTED_NO			2

// Settings defines

#define VOTE_TIME			60
#define VOTE_MIN_TIME		10
#define VOTE_TIME_REFRESH	25
#define VOTE_DELAY			240 // seconds to wait until another vote from same user is allowed

// Fraction of votes required for each action
#define VOTESNEEDED_CURSE	0.5
#define VOTESNEEDED_MUTE	0.5
#define VOTESNEEDED_KICK	0.5
#define VOTESNEEDED_CUFF	0.5
#define VOTESNEEDED_BAN 	0.5
#define VOTESNEEDED_MAP 	0.5
#define VOTESNEEDED_NEXTMAP	0.5
#define VOTESNEEDED_USE		0.5

//#define BAN_VOTED_TIME		0 // permanent ban
#define BAN_VOTED_TIME		 60 // 60 minutes
#define MUTE_VOTED_TIME 	 30
#define CUFF_VOTED_TIME 	 15

#ifdef VOTING_TEST
#define VOTE_DELAY			0 // for testing
#endif

#define VOTESLEEP_RATECHECK   5 // Rate in seconds of the think for sleeping votes
#define VOTESLEEP_DURATION	 10 // Maximum minutes for a vote to be sleeping before getting discarded

/*===============================================================================================

EXPLANATION OF HOW THE ENTITY FIELDS ARE USED (thnx? np.. :P)
---------------------------------------------

Global vars used:
-----------------

current_voteent   - Points to current vote entity, if any, if not it points to world

For player entity:
------------------

.g_a			  - Contains the type of punishment selected on menu
.goal_no		  - Controls delay between same client votes
.group_no		  - Gizmo - first byte is #VOTE_NEXTMAP, etc.. second byte is one of the #VOTEMAP_ modes above
.goal_state 	  - Determines what page of maps to be shown for voting
.owned_by		  - Contains #VOTED_XXXX, yes, no or none

For vote entity:
----------------

.has_sentry 		 - Type of vote
.g_a				 - Type of punishment to vote
.admin_kick 		 - Player to be punished
.all_active 		 - Number of affirmative votes
.has_holo			 - Number of negative votes
.group_no			 - Gizmo - one of the #VOTEMAP_ modes above
.has_tesla			 - Number of map beeing voted
.dont_do_triggerwork - If TRUE, means the player to be banned has left
	(when banning a user that left)
.t_s_h				 - Permanent string containing IP to be banned
.t_s_m				 - Permanent string with the name of user to be banned
	(when map voting)
.netname			 - Permanent string that is the name of map

===============================================================================================*/

void() PunishClientCycle;
void() StartPunishmentVote;
void() CleanClientVotes;
void() ResetClientsMenu;
float() ValidVoteEnt;
float(float final) CheckVoting;
void(float nummap, string themap) StartVoteMap;
string(float themap) GetMapString;
void() bprintVotesLeft;
//float() GetRemainingVotes;
void() CleanUpSleepVote;
void() VoteSleep_think;
void( float num_for, float num_against ) bprintVotesNeeded;

// External
void(string text) CmdMsg;

//====================================================================================================

/*
============
IsMapVote

Determines if the current vote is a map related vote.
============
*/
float() IsMapVote = {
	if ( current_voteent.has_sentry == #VOTE_NEXTMAP )
		return #TRUE;
	if ( current_voteent.has_sentry == #VOTE_SWITCHMAP )
		return #TRUE;

	return #FALSE;
};

/*
============
PrintVoteMapType

May print nothing at all.
============
*/
void( string preString, float voteMapType, string postString ) PrintVoteMapType = {
	if ( voteMapType == #VOTEMAP_AGR ) {
		bprint( #PRINT_HIGH, preString );
		bprint( #PRINT_HIGH, "¡ÙÙ·„ÎÂÚÛ «Ô “Â‰" );
		bprint( #PRINT_HIGH, postString );
	}
#ifdef COOP_MODE_ENHANCED
	else if ( voteMapType == #VOTEMAP_TF ) {
		bprint( #PRINT_HIGH, preString );
		bprint( #PRINT_HIGH, "‘Â·Ì ∆ÔÚÙÚÂÛÛ" );
		bprint( #PRINT_HIGH, postString );
	} else if ( voteMapType == #VOTEMAP_COOP ) {
		bprint( #PRINT_HIGH, preString );
		bprint( #PRINT_HIGH, "√ÔÔ" );
		bprint( #PRINT_HIGH, postString );
	} else if ( voteMapType == #VOTEMAP_INSANECOOP ) {
		bprint( #PRINT_HIGH, preString );
		bprint( #PRINT_HIGH, "…ÓÛ·ÓÂ √ÔÔ" );
		bprint( #PRINT_HIGH, postString );
	}
#endif
};

//====================================================================================================
// both player and spectators share the same menu handlers for voting, so we need this

void() AllResetMenu =
{
	if (self.classname == "spec")
		SpecResetMenu();
	else if (self.classname == "player")
		ResetMenu();  
};

void() Player_Punish = 
{
	if (self.playerclass == #PC_UNDEFINED && self.classname == "player") // Observers
		return;
	
	if (current_voteent != world)
	{
		sprint(self,#PRINT_HIGH,"Already running a vote!\n");
		return;
	}
	
	if (self.goal_no > time)
	{
		sprint(self,#PRINT_HIGH,"You just have ran a vote!\n");
		return;
	}

	if (self.classname == "player")
		self.current_menu = #MENU_PUNISH;
	else if (self.classname == "spec")
		self.current_menu = #SPEC_MENU_PUNISH;
	else
		return;
		//RPrint("BUG: Non-spec/player on Player_Punish()\n");

	self.g_a = #PUNISH_CURSE;		// Gizmo - fix this stupid bug

	CuTFMenuSound(#MENUSOUND_BUY);
	Menu_Punish();
	BackFlash(self,1);
};

void() Menu_Punish =
{
	local string st, st2, st3;
		
	// if we didn't disconnect and we are a valid class, player or spectator..
	if (HasValidAdminTarget2(self))
	{
		st2 = self.admin_kick.netname;	  
		
		if (self.admin_kick.classname == "spec")
			st="’ÛÂÚ: ®spectator© \n\n";
		else
			st="’ÛÂÚ:             \n\n";
	}
	else
	{
		st = "";
		st2 = "’ÛÂÚ:             \n\nNo user selected! ";
	}

	if (self.g_a == #PUNISH_BAN)
		st3 = ".. Ban°          ";
	else if (self.g_a == #PUNISH_KICK)
		st3 = ".. Kick°         ";
	else if (self.g_a == #PUNISH_MUTE)
		st3 = ".. Mute°         ";
	else if (self.g_a == #PUNISH_CUFF)
		st3 = ".. Cuff°         ";
	else
		st3 = ".. Curse°        "; 	   

	CenterPrint5(self,st,st2,"\n\n.. Next UserÆÆÆ  \n\n.. √ËÔÔÛÂ ¡„ÙÈÔÓ:\n\n",st3,"\n\nÆÆ ≈¯ÈÙ          \n");
														   
};

void(float input) Menu_Punish_Input =
{
	if (input == 1)
	{
		PunishClientCycle();
		CuTFMenuSound(#MENUSOUND_BROWSE);
		Menu_Punish();
		self.impulse = 0;
		return;
	}
	else if (input == 2)
	{
		if (self.g_a == #PUNISH_CURSE)
			self.g_a = #PUNISH_KICK;
		else if (self.g_a == #PUNISH_KICK)
			self.g_a = #PUNISH_MUTE;
		else if (self.g_a == #PUNISH_MUTE)
			self.g_a = #PUNISH_BAN;
		else if (self.g_a == #PUNISH_BAN)
			self.g_a = #PUNISH_CUFF;
		else
			self.g_a = #PUNISH_CURSE;

		CuTFMenuSound(#MENUSOUND_BUY);
		Menu_Punish();
		self.impulse = 0;
		return;
	}
	else if (input == 3)
	{
		self.impulse = 0;
		
		if (current_voteent != world)
		{
			sprint(self,#PRINT_HIGH,"Already running a vote!\n");
			AllResetMenu();
			return;
		}
		else if (self.admin_kick == world)
			sprint(self,#PRINT_HIGH,"No user selected!\n");
		else if (!self.admin_kick.is_connected)
		{
			sprint(self,#PRINT_HIGH,"User has left the server!\n");
			PunishClientCycle();
		}
		else if (self.admin_kick.classname=="spec" && self.g_a == #PUNISH_CURSE)
			sprint(self,#PRINT_HIGH,"Can't curse spectators!\n");
		else if (self.admin_kick.classname=="spec" && self.g_a == #PUNISH_CUFF)
			sprint(self,#PRINT_HIGH,"Can't cuff spectators!\n");
		else if (self.admin_kick.classname != "spec" && self.admin_kick.classname != "player")
			sprint(self,#PRINT_HIGH,"Invalid user selected!\n");
		else
		{
			StartPunishmentVote();
			AllResetMenu();
			return;
		}

		CuTFMenuSound(#MENUSOUND_WRONG);
	}
	else if (input == 10)
	{
		AllResetMenu();
		CuTFMenuSound(#MENUSOUND_SELL);
		BackFlash(self,1);
		self.impulse = 0;
		return;
	}
	
	self.impulse = 0;
};

void() Player_VoteMap = 
{
	if (self.playerclass == #PC_UNDEFINED && self.classname == "player") // Observers
		return;
	
	if (current_voteent != world)
	{
		sprint(self,#PRINT_HIGH,"Already running a vote!\n");
		return;
	}

	if (time < #VOTE_MIN_TIME)
#ifdef COOP_MODE_ENHANCED
	if ( deathmatch || mapname != "start" )
#endif
	{
		sprint(self,#PRINT_HIGH,"Too early for a map vote!\n");
		return;
	}

	if (self.goal_no > time)
	{
		sprint(self,#PRINT_HIGH,"You just have ran a vote!\n");
		return;
	}

	if (ServerUpdating())
	{
		sprint(self,#PRINT_HIGH,"Server update is taking place, no map changes are allowed!\n");
		return;
	}

	if (self.classname == "player")
		self.current_menu = #MENU_VOTEMAP;
	else if (self.classname == "spec")
		self.current_menu = #SPEC_MENU_VOTEMAP;
	else 
		return;
	//RPrint("BUG: Non-spec/player on Player_VoteMap()\n");

	// Gizmo
	self.group_no = #VOTE_NEXTMAP;

	CuTFMenuSound(#MENUSOUND_BUY);
	Menu_VoteMap();
	BackFlash(self,1);
};	

void() Menu_VoteMap =
{
	local string paddedstr,st1,st2,st3,st4,st5,st6,st7,keyst,color;
	local float	voteMapType;
	
	keyst = GetMapString(self.goal_state*6+1);
	if (mapname == keyst)
	{
		color = colstr(keyst,#COLSTR_RED);
		if (self.#cprint_fx & 1)
			keyst = strcat(color," [Ï·˘ÈÓÁ]");
		else
			keyst = strcat(color," €playing›");
		color = keyst;
	}
	else
		color = keyst;
	paddedstr = padstr(color,18);
	if (self.goal_state == 0)
		st1 = strcat("¡ˆ·ÏÈ·‚ÏÂ Ì·Û: ®page 1Ø6©\n\n.. ",paddedstr);
	else if (self.goal_state == 1)
		st1 = strcat("¡ˆ·ÏÈ·‚ÏÂ Ì·Û: ®page 2Ø6©\n\n.. ",paddedstr);
	else if (self.goal_state == 2)
		st1 = strcat("¡ˆ·ÏÈ·‚ÏÂ Ì·Û: ®page 3Ø6©\n\n.. ",paddedstr);
	else if (self.goal_state == 3)
		st1 = strcat("¡ˆ·ÏÈ·‚ÏÂ Ì·Û: ®page 4Ø6©\n\n.. ",paddedstr);
	else if (self.goal_state == 4)
		st1 = strcat("¡ˆ·ÏÈ·‚ÏÂ Ì·Û: ®page 5Ø6©\n\n.. ",paddedstr);
	else
		st1 = strcat("¡ˆ·ÏÈ·‚ÏÂ Ì·Û: ®page 6Ø6©\n\n.. ",paddedstr);
		
	keyst = GetMapString(self.goal_state*6+2);
	if (mapname == keyst)
	{
		color = colstr(keyst,#COLSTR_RED);
		if (self.#cprint_fx & 1)
			keyst = strcat(color," [Ï·˘ÈÓÁ]");
		else
			keyst = strcat(color," €playing›");
		color = keyst;
	}
	else
		color = keyst;
	paddedstr = padstr(color,18);
	st2 = strcat("\n.. ",paddedstr);
		
	keyst = GetMapString(self.goal_state*6+3);
	if (mapname == keyst)
	{
		color = colstr(keyst,#COLSTR_RED);
		if (self.#cprint_fx & 1)
			keyst = strcat(color," [Ï·˘ÈÓÁ]");
		else
			keyst = strcat(color," €playing›");
		color = keyst;
	}
	else
		color = keyst;
	paddedstr = padstr(color,18);
	st3 = strcat("\n.. ",paddedstr);
	
	keyst = GetMapString(self.goal_state*6+4);
	if (mapname == keyst)
	{
		color = colstr(keyst,#COLSTR_RED);
		if (self.#cprint_fx & 1)
			keyst = strcat(color," [Ï·˘ÈÓÁ]");
		else
			keyst = strcat(color," €playing›");
		color = keyst;
	}
	else
		color = keyst;
	paddedstr = padstr(color,18);
	st4 = strcat("\n.. ",paddedstr);

	keyst = GetMapString(self.goal_state*6+5);
	if (mapname == keyst)
	{
		color = colstr(keyst,#COLSTR_RED);
		if (self.#cprint_fx & 1)
			keyst = strcat(color," [Ï·˘ÈÓÁ]");
		else
			keyst = strcat(color," €playing›");
		color = keyst;
	}
	else
		color = keyst;
	paddedstr = padstr(color,18);
	st5 = strcat("\n.. ",paddedstr);

	keyst = GetMapString(self.goal_state*6+6);
	if (mapname == keyst)
	{
		color = colstr(keyst,#COLSTR_RED);
		if (self.#cprint_fx & 1)
			keyst = strcat(color," [Ï·˘ÈÓÁ]");
		else
			keyst = strcat(color," €playing›");
		color = keyst;
	}
	else
		color = keyst;
	paddedstr = padstr(color,18);
	st6 = strcat("\n.. ",paddedstr);

	// Gizmo
	voteMapType = GetByte2( self.group_no );

	// Gizmo - modified AGR vote code
	if ( GetByte1( self.group_no ) == #VOTE_NEXTMAP ) {
		if ( voteMapType == #VOTEMAP_AGR )
			st7 ="\n\n.. ÕÔ‰Â: as next map \n              ¡ÙÙ·„ÎÂÚÛ «Ô “Â‰\n\n.. –ÚÂˆ –·ÁÂ         \n.. ŒÂ¯Ù –·ÁÂ         \n\nÆÆ ≈¯ÈÙ              \n";
#ifdef COOP_MODE_ENHANCED
		else if ( voteMapType == #VOTEMAP_TF )
			st7 ="\n\n.. ÕÔ‰Â: as next map \n              ‘Â·Ì ∆ÔÚÙÚÂÛÛ   \n\n.. –ÚÂˆ –·ÁÂ         \n.. ŒÂ¯Ù –·ÁÂ         \n\nÆÆ ≈¯ÈÙ              \n";
		else if ( voteMapType == #VOTEMAP_COOP )
			st7 ="\n\n.. ÕÔ‰Â: as next map \n              √ÔÔ            \n\n.. –ÚÂˆ –·ÁÂ         \n.. ŒÂ¯Ù –·ÁÂ         \n\nÆÆ ≈¯ÈÙ              \n";
		else if ( voteMapType == #VOTEMAP_INSANECOOP )
			st7 ="\n\n.. ÕÔ‰Â: as next map \n              …ÓÛ·ÓÂ √ÔÔ     \n\n.. –ÚÂˆ –·ÁÂ         \n.. ŒÂ¯Ù –·ÁÂ         \n\nÆÆ ≈¯ÈÙ              \n";
#endif
		else
			st7 ="\n\n.. ÕÔ‰Â: as next map \n\n.. –ÚÂˆ –·ÁÂ         \n.. ŒÂ¯Ù –·ÁÂ         \n\nÆÆ ≈¯ÈÙ              \n";
	} else { //if ( self.group_no == #VOTE_SWITCHMAP )
		if ( voteMapType == #VOTEMAP_AGR )
			st7 ="\n\n.. ÕÔ‰Â: play now°   \n              ¡ÙÙ·„ÎÂÚÛ «Ô “Â‰\n\n.. –ÚÂˆ –·ÁÂ         \n.. ŒÂ¯Ù –·ÁÂ         \n\nÆÆ ≈¯ÈÙ              \n";
#ifdef COOP_MODE_ENHANCED
		else if ( voteMapType == #VOTEMAP_TF )
			st7 ="\n\n.. ÕÔ‰Â: play now°   \n              ‘Â·Ì ∆ÔÚÙÚÂÛÛ   \n\n.. –ÚÂˆ –·ÁÂ         \n.. ŒÂ¯Ù –·ÁÂ         \n\nÆÆ ≈¯ÈÙ              \n";
		else if ( voteMapType == #VOTEMAP_COOP )
			st7 ="\n\n.. ÕÔ‰Â: play now°   \n              √ÔÔ            \n\n.. –ÚÂˆ –·ÁÂ         \n.. ŒÂ¯Ù –·ÁÂ         \n\nÆÆ ≈¯ÈÙ              \n";
		else if ( voteMapType == #VOTEMAP_INSANECOOP )
			st7 ="\n\n.. ÕÔ‰Â: play now°   \n              …ÓÛ·ÓÂ √ÔÔ     \n\n.. –ÚÂˆ –·ÁÂ         \n.. ŒÂ¯Ù –·ÁÂ         \n\nÆÆ ≈¯ÈÙ              \n";
#endif
		else
			st7 ="\n\n.. ÕÔ‰Â: play now°   \n\n.. –ÚÂˆ –·ÁÂ         \n.. ŒÂ¯Ù –·ÁÂ         \n\nÆÆ ≈¯ÈÙ              \n";
	}

	CenterPrint7(self,st1,st2,st3,st4,st5,st6,st7);

	self.#cprint_fx = self.#cprint_fx + 1;
};

void(float input) Menu_VoteMap_Input =
{
	local float	voteType, voteMapType;

	if (input >= 1 && input <= 6)
	{
		if (current_voteent != world)
		{
			sprint(self,#PRINT_HIGH,"Already running a vote!\n");
			AllResetMenu();
			self.impulse = 0;
			return;
		}

		local float nummap;
		
		nummap = input + (self.goal_state*6);

		StartVoteMap(nummap,"");
		AllResetMenu();
	}	
	else if (input == 7)
	{
		voteType = GetByte1( self.group_no );
		voteMapType = GetByte2( self.group_no );

		if ( voteMapType == #VOTEMAP_DEFAULT )
			voteMapType = #VOTEMAP_AGR;
#ifdef COOP_MODE_ENHANCED
		else if ( voteMapType == #VOTEMAP_AGR )
			voteMapType = #VOTEMAP_TF;
		else if ( voteMapType == #VOTEMAP_TF )
			voteMapType = #VOTEMAP_COOP;
		else if ( voteMapType == #VOTEMAP_COOP )
			voteMapType = #VOTEMAP_INSANECOOP;
#endif
		else {
			voteMapType = #VOTEMAP_DEFAULT;

			if ( voteType == #VOTE_NEXTMAP )
				voteType = #VOTE_SWITCHMAP;
			else
				voteType = #VOTE_NEXTMAP;
		}

		self.group_no = voteType;
		self.group_no = AssignByte2( self.group_no, voteMapType );

		CuTFMenuSound(#MENUSOUND_BUY);

		NoCprintFX();
		Menu_VoteMap();
	}	 
	else if (input == 8)
	{
		self.goal_state = self.goal_state - 1;
		if (self.goal_state < 0)
			self.goal_state = 5;
				
		CuTFMenuSound(#MENUSOUND_BROWSE);

		NoCprintFX();
		Menu_VoteMap();
	}	 
	else if (input == 9)
	{
		self.goal_state = self.goal_state + 1;
		if (self.goal_state > 5)
			self.goal_state = 0;
							
		CuTFMenuSound(#MENUSOUND_BROWSE);
		
		NoCprintFX();
		Menu_VoteMap();
	}	 
	else if (input == 10)
	{
		AllResetMenu();
		CuTFMenuSound(#MENUSOUND_SELL);
		BackFlash(self,1);
	}	 

	self.impulse = 0;
};

//===============================================================
// bprints the current voting issue

void() bprintVoteIssue =
{
	if (current_voteent.has_sentry == #VOTE_PUNISH)
	{
		if (current_voteent.dont_do_triggerwork) // Special ban (client has left)
		{
			bprint(#PRINT_HIGH," ®ban ");
			bprint(#PRINT_HIGH,current_voteent.t_s_m);
			bprint(#PRINT_HIGH,"©");
		}
		else
		{
			if (current_voteent.g_a == #PUNISH_CURSE)
				bprint(#PRINT_HIGH," ®curse ");
			else if (current_voteent.g_a == #PUNISH_KICK)
				bprint(#PRINT_HIGH," ®kick ");
			else if (current_voteent.g_a == #PUNISH_BAN)
				bprint(#PRINT_HIGH," ®ban ");
			else if (current_voteent.g_a == #PUNISH_MUTE)
				bprint(#PRINT_HIGH," ®mute ");
			else if (current_voteent.g_a == #PUNISH_CUFF)
				bprint(#PRINT_HIGH," ®cuff ");

			bprint(#PRINT_HIGH,current_voteent.admin_kick.netname);
			bprint(#PRINT_HIGH,"©");
		}
	}
	else if (current_voteent.has_sentry == #VOTE_NEXTMAP) // as next map
	{
		bprint(#PRINT_HIGH," ®"); // FIXME: CPQCCX compiler says 'Not a name' if only "(" is used ???
		bprint(#PRINT_HIGH, current_voteent.netname);
		bprint(#PRINT_HIGH," as next map");

		PrintVoteMapType( ", in ", current_voteent.group_no, " mode" );

		bprint( #PRINT_HIGH, "©" );
	} 
	else if (current_voteent.has_sentry == #VOTE_SWITCHMAP)
	{
		bprint(#PRINT_HIGH," ®switch to ");
		bprint(#PRINT_HIGH,current_voteent.netname);

		PrintVoteMapType( ", in ", current_voteent.group_no, " mode" );

		bprint( #PRINT_HIGH, "©" );
	} else if ( current_voteent.has_sentry == #VOTE_USEOBJECT ) {
		local string objectName;

		objectName = GetUseObjectName( current_voteent.enemy );
		bprint( #PRINT_HIGH, " ®use object " );
		bprint( #PRINT_HIGH, objectName );
		bprint( #PRINT_HIGH, "©" );
	}
};

//==============================================================
// user has used the VoteYes impulse command

void() Player_VoteYes =
{
	if (self.playerclass == #PC_UNDEFINED && self.classname == "player") // Observers
		return;

	if (current_voteent == world)
	{
		sprint(self,#PRINT_HIGH,"Not voting currently!\n");
		return;
	}

	#ifndef VOTING_TEST
	if (current_voteent.admin_kick == self)
	{
		sprint(self,#PRINT_HIGH,"You are not allowed to vote!\n");
		return;
	}
	else if (self.owned_by == #VOTED_NO || self.owned_by == #VOTED_YES)
	{
		// FIXME: Allow the person to change their vote. -randomer 2006-02-24
		sprint(self,#PRINT_HIGH,"You already voted!\n");
	}
	else
	{
	#endif		  
		BackFlash(self,1);
		
		bprint(#PRINT_HIGH,"Votingç ");
		bprint(#PRINT_HIGH,self.netname);
		bprint(#PRINT_HIGH," agrees");

		self.owned_by = #VOTED_YES;

		bprintVoteIssue();
				
		BroadcastSound("misc/basekey");
		
		current_voteent.all_active = current_voteent.all_active + 1;

		if (current_voteent.nextthink < time + #VOTE_TIME_REFRESH)
			current_voteent.nextthink = time + #VOTE_TIME_REFRESH;
				
		bprintVotesLeft();
		CheckVoting(#FALSE);
	#ifndef VOTING_TEST
	}
	#endif
};

//==============================================================
// user has used the VoteNo impulse command

void() Player_VoteNo =
{
	if (self.playerclass == #PC_UNDEFINED && self.classname == "player") // Observers
		return;
	
	if (current_voteent == world)
	{
		sprint(self,#PRINT_HIGH,"Not voting currently!\n");
		return;
	}
	
	#ifndef VOTING_TEST
	if (current_voteent.admin_kick == self)
	{
		sprint(self,#PRINT_HIGH,"You are not allowed to vote!\n");
		return;
	}
	else if (self.owned_by == #VOTED_NO || self.owned_by == #VOTED_YES)
	{
		sprint(self,#PRINT_HIGH,"You already voted!\n");
	}
	else
	{
	#endif
		BackFlash(self,1);

		bprint(#PRINT_HIGH,"Votingç ");
		bprint(#PRINT_HIGH,self.netname);
		bprint(#PRINT_HIGH," disagrees");

		self.owned_by = #VOTED_NO;

		bprintVoteIssue();
		
		BroadcastSound("doors/basetry.wav"); // PZ - was misc/basekey just like voteyes
		// changed to differentiate vote sounds from affirmative to negative
		
		current_voteent.has_holo = current_voteent.has_holo +1;
		
		if (current_voteent.nextthink < time + #VOTE_TIME_REFRESH)
			current_voteent.nextthink = time + #VOTE_TIME_REFRESH;
				
		bprintVotesLeft();
		CheckVoting(#FALSE);

	#ifndef VOTING_TEST
	}
	#endif
};

//========================================================================
// cycles through all clients as target for punishment

void() PunishClientCycle =
{
	local entity te;
	local float num;
	num = #FALSE;

	te = world; // none 
	
	te = find(self.admin_kick, classname, "player");
	while (te != world && num == #FALSE)
	{
		num = #TRUE;

		if (!te.is_connected)
			num = #FALSE;
		
		if (self.admin_kick==te)
			num = #FALSE;

		#ifndef VOTING_TEST
		if (te == self)
			num = #FALSE;
		#endif
		
		if (num == #FALSE) te = find(te, classname, "player");
	}	 
	
	if (te == world) // if out of players on our search lets scan for spectators
	{
		te = find(self.admin_kick, classname, "spec");
		while (te != world && num == #FALSE)
		{
			num = #TRUE;
	
			if (!te.is_connected)
				num = #FALSE;
			
			if (self.admin_kick==te)
				num = #FALSE;

			#ifndef VOTING_TEST
			if (te == self)
				num = #FALSE;
			#endif

			if (num == #FALSE) te = find(te, classname, "spec");
		}
	}

	if (te == world) 
		self.admin_kick=world; // No clients found!
	else
		self.admin_kick = te;
};

//========================================================================
// deletes current vote entity, if it exists, and performs clean up

void() ResetVoteEnt =
{
	if (current_voteent.classname == "voteent")
	{
		if ( IsMapVote() )
			delstr( current_voteent.netname );

		if (current_voteent.dont_do_triggerwork)
		{
			delstr(current_voteent.t_s_h);
			delstr(current_voteent.t_s_m);
		}
		
		dremove(current_voteent);
		current_voteent = world;
	}
	else current_voteent = world;
};

//==========================================================================
// gets number of clients currently on server, including spectators

float() GetNoClients =
{
	return num_players + num_specs;

	/*local entity te;
	local float clients;
	clients = 0;

	te = find(world, classname, "player");
	while (te != world)
	{
		if (!te.has_disconnected)
			clients = clients + 1;
		
		te = find(te, classname, "player");
	}	 

	te = find(world, classname, "spec");
	while (te != world)
	{
		if (!te.has_disconnected)
			clients = clients + 1;
		
		te = find(te, classname, "spec");
	}	 

	return clients;*/
};

void() PunishVote_Think;

//=================================================================
// Start punishment voting, self = player issuer of vote

void() StartPunishmentVote =
{
	if (no_punish)
	{
		CmdMsg("Punishment votes are disabled, sorry!\n");
		return;
	}

	if (self.classname != "player" && self.classname != "spec")
	{
		sprint(self,#PRINT_HIGH,"You can't vote still, join the game first!\n");
		return;
	}
	
	if (mutedtime(self))
	{
		sprint(self,#PRINT_HIGH,"You can't start a vote while muted!\n");
		return;
	}
	
	BackFlash(self,1);

	CleanClientVotes();
	
	local entity voteent;

	voteent = spawn();
	voteent.g_a = self.g_a;
	voteent.think = PunishVote_Think;
	voteent.nextthink = time + #VOTE_TIME;
	voteent.classname = "voteent";
	voteent.owner = world; // ADDED

	voteent.all_active = 1;
	voteent.has_holo = 0;

	voteent.demon_one = self;

	voteent.admin_kick = self.admin_kick;

	voteent.has_sentry = #VOTE_PUNISH;

	self.goal_no = time + #VOTE_DELAY;

	self.owned_by = #VOTED_YES; // we already voted yes

	BroadcastSound("misc/medkey");

	bprint(#PRINT_HIGH,"Votingç ");

	bprint(#PRINT_HIGH,self.netname);
	last_vote_starter = self.netname; // for AGR -PZ
	bprint(#PRINT_HIGH," proposes to ");

	if (self.g_a == #PUNISH_CURSE)
		bprint(#PRINT_HIGH,"curse ");
	else if (self.g_a == #PUNISH_KICK)
		bprint(#PRINT_HIGH,"kick ");
	else if (self.g_a == #PUNISH_MUTE)
		bprint(#PRINT_HIGH,"mute ");
	else if (self.g_a == #PUNISH_BAN)
		bprint(#PRINT_HIGH,"ban ");
	else if (self.g_a == #PUNISH_CUFF)
		bprint(#PRINT_HIGH,"cuff ");

	bprint(#PRINT_HIGH,self.admin_kick.netname);

	bprint(#PRINT_HIGH,", type ¢VoteYes¢ or ¢VoteNo¢ to vote");
	// Gizmo
	bprintVotesNeeded( 1, 0 );
	bprint( #PRINT_HIGH, "\n" );

	current_voteent = voteent;

	current_voteent.dont_do_triggerwork = #FALSE;
		
	ResetClientsMenu(); // reset menus on players/specs which r on MENU_PUNISH or MENU_VOTEMAP

	CheckVoting(#FALSE); // If we are the only player on server, checks
};

void() PunishVote_Think =
{
	CheckVoting(#TRUE);
	
#ifdef NOTDEFINED
	bprint(#PRINT_HIGH,"Votingç Punishment vote has failed");
	bprintVoteIssue();
	bprint(#PRINT_HIGH,"\n");

	BroadcastSound("misc/runekey");

	ResetVoteEnt();
#endif
};

void() VoteMap_Think;

//=================================================================
// Start map voting, self = player issuer of vote

void(float nummap, string themap) StartVoteMap =
{
	local string	temp;
	local float		voteType, voteMapType;

	if (no_votemap)
	{
		CmdMsg("Map voting within the mod is disabled, sorry!\n");
		return;
	}

	if (self.classname != "player" && self.classname != "spec")
	{
		sprint(self,#PRINT_HIGH,"You can't vote still, join the game first!\n");
		return;
	}

	if (time < #VOTE_MIN_TIME)
#ifdef COOP_MODE_ENHANCED
	if ( deathmatch || mapname != "start" )
#endif
	{
		sprint(self,#PRINT_HIGH,"Too early for a map change!\n");
		return;
	}
	
	if (mutedtime(self))
	{
		sprint(self,#PRINT_HIGH,"You can't start a vote while muted!\n");
		return;
	}

	if (ServerUpdating())
	{
		sprint(self,#PRINT_HIGH,"Server update is taking place, no map changes are allowed!\n");
		return;
	}

	voteType = GetByte1( self.group_no );
	voteMapType = GetByte2( self.group_no );

	// PZ - AGR begin
	if ( voteMapType == #VOTEMAP_AGR )
	if ( voteType == #VOTE_NEXTMAP || voteType == #VOTE_SWITCHMAP )
	{
		local float x;
		x = GetNoPlayers(#TRUE, #TRUE);
		if (agr_vote_max != 0 && x > agr_vote_max)
		{
			sprint(self, #PRINT_HIGH, "Votingç Max number of players allowed for an ¡«“ vote is ");
			temp = ftos(agr_vote_max);
			temp = colstr(temp, #COLSTR_NUMBER);
			sprint(self, #PRINT_HIGH, temp);
			sprint(self, #PRINT_HIGH, " players.\n");
			return;
		}
	}
	// AGR end

	BackFlash(self,1);
		
	local entity voteent;

	voteent = spawn();
	voteent.g_a = self.g_a;
	voteent.think = VoteMap_Think;
	voteent.nextthink = time + #VOTE_TIME;
	voteent.classname = "voteent";
	voteent.owner = world; // ADDED

	if (!nummap)
	{
		voteent.netname = themap;

		#ifdef UNABLE_TOVOTE_FORSAME_MAP
		// Don't let votes to switch to current map
		// PZ ..unless they are changing to/from AGR
		if ( voteent.netname == mapname )
		if ( voteType == #VOTE_SWITCHMAP )
		if ( ( ( voteMapType != #VOTEMAP_AGR && !agr) || ( voteMapType == #VOTEMAP_AGR && agr ) ) )
		{
			sprint(self,#PRINT_HIGH,"You can't start voting for a map that is currently being played!\n");
			CuTFMenuSound(#MENUSOUND_WRONG);
			dremove(voteent);
			voteent = world;
			return;
		}
		#endif

		voteent.netname = makestr(voteent.netname);
		voteent.has_tesla = 0;
	}
	else
	{
		voteent.netname = GetMapString(nummap);

		// Abort if empty map name on localinfo
		if (voteent.netname == "")
		{
			sprint(self,#PRINT_HIGH,"You can't choose an empty map slot!\n");
			CuTFMenuSound(#MENUSOUND_WRONG);
			dremove(voteent);
			voteent = world;
			return;
		}

		#ifdef UNABLE_TOVOTE_FORSAME_MAP
		// Don't let votes to switch to current map
		// PZ ..unless they are changing to/from AGR
		if ( voteent.netname == mapname )
		if ( voteType == #VOTE_SWITCHMAP )
		if ( ( ( voteMapType != #VOTEMAP_AGR && !agr ) || ( voteMapType == #VOTEMAP_AGR && agr ) ) )
		{
			sprint(self,#PRINT_HIGH,"You can't start voting for a map that is currently being played!\n");
			CuTFMenuSound(#MENUSOUND_WRONG);
			dremove(voteent);
			voteent = world;
			return;
		}
		#endif

		voteent.netname = makestr(voteent.netname);
		voteent.has_tesla = nummap;
	}

	CleanClientVotes();

	voteent.all_active = 1;
	voteent.has_holo = 0;

	// Gizmo - check for vote nextmap switchmap
	voteent.has_sentry = voteType;		// has_sentry is the generic vote type field

	current_voteent = voteent;

	self.goal_no = time + #VOTE_DELAY;

	self.owned_by = #VOTED_YES; // we already voted yes
	
	voteent.group_no = voteMapType;		// group_no on the vote entity is the map vote type

	current_voteent.dont_do_triggerwork = #FALSE;

	BroadcastSound("misc/medkey");

	themap = colstr(current_voteent.netname,#COLSTR_RED);

	bprint(#PRINT_HIGH,"Votingç ",self.netname);
	last_vote_starter = self.netname; // for AGR -PZ

	if ( voteType == #VOTE_NEXTMAP ) {
		bprint(#PRINT_HIGH," suggests ",themap," as next map");

		PrintVoteMapType( ", in ", voteMapType, " mode" );
	} else /*if ( voteType == #VOTE_SWITCHMAP )*/ {
		bprint(#PRINT_HIGH," wants to play ",themap," right now");

		PrintVoteMapType( ", in ", voteMapType, " mode" );
	}

	bprint(#PRINT_HIGH,", type ¢VoteYes¢ or ¢VoteNo¢ to vote");
	// Gizmo
	bprintVotesNeeded( 1, 0 );
	bprint( #PRINT_HIGH, "\n" );

	ResetClientsMenu(); // reset menus on players/specs which are on MENU_PUNISH or MENU_VOTEMAP

	CheckVoting(#FALSE); // If we are the only player on server must check
};

void() VoteMap_Think =
{
	CheckVoting(#TRUE);
	
#ifdef NOTDEFINED
	bprint(#PRINT_HIGH,"Votingç Map voting failed");

	bprintVoteIssue();

	bprint(#PRINT_HIGH,"\n");

	BroadcastSound("misc/runekey");

	ResetVoteEnt();
#endif
};

//=================================================================

void() StartUseObjectVote = {
	local string objectName, objectAction;

	makevectors( self.v_angle );
	traceline( self.origin + '0 0 16', ( self.origin + '0 0 16' ) + v_forward * 4096, #TL_ANY_SOLID, self );

	if ( !IsValidUseObject( trace_ent ) ) {
		sprint( self, #PRINT_HIGH, "Not a valid object to use!\n" );
		return;
	}

	BroadcastSound( "misc/medkey" );

	objectName = GetUseObjectName( trace_ent );
	objectAction = GetUseObjectAction( trace_ent );
	bprint( #PRINT_HIGH, "Votingç ", self.netname, " wants to force a ", objectName, " to ", objectAction );
	bprint( #PRINT_HIGH, ", type ¢VoteYes¢ or ¢VoteNo¢ to vote" );
	// Gizmo
	bprintVotesNeeded( 1, 0 );
	bprint( #PRINT_HIGH, "\n" );

	BackFlash( self, 1 );
	CleanClientVotes ();

	self.goal_no = time + #VOTE_DELAY;
	self.owned_by = #VOTED_YES;		// we already voted yes

	local entity voteent;

	voteent = spawn ();
	voteent.think = PunishVote_Think;
	voteent.nextthink = time + #VOTE_TIME;
	voteent.classname = "voteent";
	voteent.owner = world; // ADDED
	voteent.all_active = 1;
	voteent.has_holo = 0;
	voteent.enemy = trace_ent;
	voteent.has_sentry = #VOTE_USEOBJECT;

	current_voteent = voteent;

	ResetClientsMenu ();			// reset menus on players/specs which r on MENU_PUNISH or MENU_VOTEMAP
	CheckVoting( #FALSE );			// if we are the only player on server checks
};


//==================================================================
// resets all clients to ready-to-vote state

void() CleanClientVotes =
{
	local entity te;

	te = find(world, classname, "player");
	while (te != world)
	{
		if (te.is_connected)
			te.owned_by = #VOTED_READY;
		
		te = find(te, classname, "player");
	}	 

	te = find(world, classname, "spec");
	while (te != world)
	{
		if (te.is_connected)
			te.owned_by = #VOTED_READY;
		
		te = find(te, classname, "spec");
	}	 
};

//=============================================================================
// clear menus of clients that have vote menus on - WATCHOUT - Using self

void() ResetClientsMenu =
{
	local entity te;

	te = find(world, classname, "player");
	while (te != world)
	{
		if (te.is_connected)
		if (te != self)
		if (te.current_menu == #MENU_PUNISH || te.current_menu == #MENU_VOTEMAP)
		{
			sprint(te,#PRINT_HIGH,"Already running a vote!\n"); 
			CenterPrint(te,"\n");
			te.current_menu = #MENU_DEFAULT;
		}

		te = find(te, classname, "player");
	}	 

	te = find(world, classname, "spec");
	while (te != world)
	{
		if (te.is_connected)
		if (te != self)
		if (te.current_menu == #SPEC_MENU_PUNISH || te.current_menu == #SPEC_MENU_VOTEMAP)
		{
			sprint(te,#PRINT_HIGH,"Already running a vote!\n"); 
			CenterPrint(te,"\n");
			te.current_menu = #SPEC_MENU_NONE;
		}

		te = find(te, classname, "spec");
	}	 
};

//==========================================================================
// called after each vote (yes or no) to see if its a succesfull vote


/*
=============
VotePassed
=============
*/
float( float numFor, float numAgainst, float fraction ) VotePassed = {
//	bprint (#PRINT_HIGH, ftos(numAgainst));
//	bprint (#PRINT_HIGH, "<against> + ((", ftos(num_players - (numFor + numAgainst)), ") / 2) == ");

	// get the number of players that didn't vote, and count them as half a voteno
	// don't count spectators if they didn't vote
	if ( num_players - ( numFor + numAgainst ) > 0 )
		numAgainst = numAgainst + ( ( num_players - ( numFor + numAgainst ) ) * fraction );

//	bprint (#PRINT_HIGH, ftos(numAgainst), "\n");

	if ( numFor > numAgainst )
		return #TRUE;

	return #FALSE;
};

float(float final) CheckVoting =
{
	// this shouldn't be needed
	if (current_voteent == world || current_voteent.classname!="voteent")
	{
		bprint(#PRINT_HIGH,"Votingç Error in voting system!\n");
		ResetVoteEnt();
		return #TRUE;
	}	 

	local float num_for, num_against, num_total;
	local entity te;

	num_for = 0;
	num_against = 0;
	num_total = 0;
	
	// Count the number of votes for, against and total clients.
	te = nextent(world);
	while (te != world) {
		if (te.classname == "player" || te.classname == "spec") {
			num_total = num_total + 1;
			if (te.owned_by == #VOTED_YES) {
				num_for = num_for + 1;
			} else if (te.owned_by == #VOTED_NO) {
				num_against = num_against + 1;
			}
		}
		te = nextent(te);
	}

// GIZMO BEGIN
/*
	// If this is the final check then only count the people who actually voted.
	if (final)
		num_total = num_for + num_against;
*/
	// if this isn't the final check then only do anything if over 50% of the population has voted
//	if (!final && num_for + num_against <= num_total / 2)
	if (!final && num_for <= num_total / 2 && num_against <= num_total / 2)
		return #FALSE;
// GIZMO END

	// If an update is taking place, dont allow map voting
	if ( IsMapVote() )
	if (ServerUpdating())
	{
		bprint(#PRINT_HIGH,"Votingç Server update is taking place, no map changes are allowed\n");
		ResetVoteEnt();
		return #TRUE;
	}

	local float numclients;
	local string st;
	local float uid;
	
	numclients = GetNoClients();
	
	if (current_voteent.has_sentry == #VOTE_PUNISH) // Punishment voting
	{
		// Check for a valid client as target
		if (!current_voteent.dont_do_triggerwork) // only if not a special ban (user left)
		if ((current_voteent.admin_kick.classname != "player" && current_voteent.admin_kick.classname != "spec") || !current_voteent.admin_kick.is_connected)
		{
			bprint(#PRINT_HIGH,"Votingç Invalid client as target for vote!\n");
			ResetVoteEnt();
			return #TRUE;
		}
		
		if (current_voteent.g_a == #PUNISH_CURSE) // Curse
		{
//			if (num_for > num_total * #VOTESNEEDED_CURSE) // success?
			if ( VotePassed( num_for, num_against, #VOTESNEEDED_CURSE ) )
			{
				local float tf;
				
				tf = 0;
				st = infokey(world, "curse");
				
				if (st == string_null) 
					tf = stof(st);
				
				bprint(#PRINT_HIGH,"Votingç Democracy says ");
				bprint(#PRINT_HIGH,current_voteent.admin_kick.netname);
				bprint(#PRINT_HIGH," must be cursed\n");

				BroadcastSound("doors/runeuse");
				
				createBastard(current_voteent.admin_kick,tf);

				ResetVoteEnt(); // removes current vote entity

				return #TRUE;
			}
//			else if (num_against >= num_total * (1 - #VOTESNEEDED_CURSE))
			else
			{
				bprint(#PRINT_HIGH,"Votingç Punishment vote has failed");
				bprintVoteIssue();
				bprint(#PRINT_HIGH,"\n");
				
				BroadcastSound("misc/runekey");
				
				ResetVoteEnt();
			}
		}
		else if (current_voteent.g_a == #PUNISH_KICK) // Kick
		{
//			if (num_for > num_total * #VOTESNEEDED_KICK) // success?
			if ( VotePassed( num_for, num_against, #VOTESNEEDED_KICK ) )
			{
				bprint(#PRINT_HIGH,"Votingç Democracy says ");
				bprint(#PRINT_HIGH,current_voteent.admin_kick.netname);
				bprint(#PRINT_HIGH," must be kicked\n");

				bprint(#PRINT_HIGH, current_voteent.admin_kick.netname);
				bprint(#PRINT_HIGH, " is À…√À≈ƒ from the server\n");

				sprint(current_voteent.admin_kick,#PRINT_HIGH,"\nYou have been À…√À≈ƒ from the server!\n");

				stuffcmd(current_voteent.admin_kick, "disconnect\n"); //Kick them!

				BroadcastSound("player/teledth1");

				ResetVoteEnt(); // removes current vote entity

				return #TRUE;
			}
//			else if (num_against >= num_total * (1 - #VOTESNEEDED_KICK))
			else
			{
				bprint(#PRINT_HIGH,"Votingç Punishment vote has failed");
				bprintVoteIssue();
				bprint(#PRINT_HIGH,"\n");
				
				BroadcastSound("misc/runekey");
				
				ResetVoteEnt();
			}
		}
		else if (current_voteent.g_a == #PUNISH_BAN) // Ban!
		{
//			if (num_for > num_total * #VOTESNEEDED_BAN) // success?
			if ( VotePassed( num_for, num_against, #VOTESNEEDED_BAN ) )
			{
				bprint(#PRINT_HIGH,"Votingç Democracy says ");

				if (current_voteent.dont_do_triggerwork) // Special ban (user has left)
				{					 
					bprint(#PRINT_HIGH,current_voteent.t_s_m);
					bprint(#PRINT_HIGH," must be banned\n");

					bprint(#PRINT_HIGH, current_voteent.t_s_m);
					bprint(#PRINT_HIGH, " is ¬¡ŒŒ≈ƒ from the server\n");

					localcmd("addip ");
					localcmd(current_voteent.t_s_h);
					localcmd(" #BAN_VOTED_TIME");
					localcmd("\n");

					BroadcastSound("doors/runeuse");
				}
				else
				{					 
					bprint(#PRINT_HIGH,current_voteent.admin_kick.netname);
					bprint(#PRINT_HIGH," must be banned\n");

					bprint(#PRINT_HIGH, current_voteent.admin_kick.netname);
					bprint(#PRINT_HIGH, " is ¬¡ŒŒ≈ƒ from the server\n");

					sprint(current_voteent.admin_kick,#PRINT_HIGH,"\nYou have been ¬¡ŒŒ≈ƒ from the server!\n");
					
					stuffcmd(current_voteent.admin_kick, "disconnect\n"); //Kick them!
					
					st = infokey(current_voteent.admin_kick,"ip");
					localcmd("addip ");
					localcmd(st);
					localcmd(" #BAN_VOTED_TIME");
					localcmd("\n");   
					
					BroadcastSound("player/teledth1");
				}				

				ResetVoteEnt(); // removes current vote entity

				return #TRUE;
			}
//			else if (num_against >= num_total * (1 - #VOTESNEEDED_BAN))
			else
			{
				bprint(#PRINT_HIGH,"Votingç Punishment vote has failed");
				bprintVoteIssue();
				bprint(#PRINT_HIGH,"\n");
				
				BroadcastSound("misc/runekey");
				
				ResetVoteEnt();
			}
		}
		else if (current_voteent.g_a == #PUNISH_MUTE) // Mute
		{
//			if (num_for > num_total * #VOTESNEEDED_MUTE) // success?
			if ( VotePassed( num_for, num_against, #VOTESNEEDED_MUTE ) )
			{
				bprint(#PRINT_HIGH,"Votingç Democracy says ");
				bprint(#PRINT_HIGH,current_voteent.admin_kick.netname);
				bprint(#PRINT_HIGH," must be muted =)\n");

				bprint(#PRINT_HIGH, current_voteent.admin_kick.netname);
				bprint(#PRINT_HIGH, " is muted.\n");

				BroadcastSound("doors/runeuse");

				sprint(current_voteent.admin_kick,#PRINT_HIGH,"\nYou have been muted!\n");
				
				uid = getuid(current_voteent.admin_kick);
				st = ftos(uid);

				localcmd("mute 00");
				localcmd(st);
				localcmd(" #MUTE_VOTED_TIME");
				localcmd("\n");

				ResetVoteEnt(); // removes current vote entity

				return #TRUE;
			}
//			else if (num_against >= num_total * (1 - #VOTESNEEDED_MUTE))
			else
			{
				bprint(#PRINT_HIGH,"Votingç Punishment vote has failed");
				bprintVoteIssue();
				bprint(#PRINT_HIGH,"\n");
				
				BroadcastSound("misc/runekey");
				
				ResetVoteEnt();
			}
		}		 
		else if (current_voteent.g_a == #PUNISH_CUFF) // Cuff
		{
//			if (num_for > num_total * #VOTESNEEDED_CUFF) // success?  
			if ( VotePassed( num_for, num_against, #VOTESNEEDED_CUFF ) )
			{
				bprint(#PRINT_HIGH,"Votingç Democracy says ");
				bprint(#PRINT_HIGH,current_voteent.admin_kick.netname);
				bprint(#PRINT_HIGH," is annoying\n");

				bprint(#PRINT_HIGH, current_voteent.admin_kick.netname);
				bprint(#PRINT_HIGH, " is cuffed.\n");

				BroadcastSound("doors/runeuse");

				sprint(current_voteent.admin_kick,#PRINT_HIGH,"\nYou have been cuffed!\n");
				
				uid = getuid(current_voteent.admin_kick);
				st = ftos(uid);

				localcmd("cuff 00");
				localcmd(st);
				localcmd(" #CUFF_VOTED_TIME");
				localcmd("\n");

				ResetVoteEnt(); // removes current vote entity

				return #TRUE;
			}
//			else if (num_against >= num_total * (1 - #VOTESNEEDED_CUFF))
			else
			{
				bprint(#PRINT_HIGH,"Votingç Punishment vote has failed");
				bprintVoteIssue();
				bprint(#PRINT_HIGH,"\n");
				
				BroadcastSound("misc/runekey");
				
				ResetVoteEnt();
			}
		}
	}
	else if (current_voteent.has_sentry == #VOTE_NEXTMAP)
	{
//		if (num_for > num_total * #VOTESNEEDED_NEXTMAP) // success?
		if ( VotePassed( num_for, num_against, #VOTESNEEDED_NEXTMAP ) )
		{
			st = colstr(current_voteent.netname,#COLSTR_RED);

			bprint(#PRINT_HIGH,"Votingç Success° Setting ",st," as next map");
			// Gizmo - print the map vote type
			PrintVoteMapType( ", in ", current_voteent.group_no, " mode" );
			bprint( #PRINT_HIGH, "\n" );

			// Gizmo
			if ( current_voteent.group_no == #VOTEMAP_AGR ) {
				localcmd( "localinfo agr 1\n" );
				if ( coop )
					localcmd( "localinfo _voted_coop 0\n" );
				if ( !deathmatch )
					localcmd( "localinfo _voted_deathmatch 3\n" );
			}

#ifdef COOP_MODE_ENHANCED
			else if ( current_voteent.group_no == #VOTEMAP_TF ) {
				localcmd("localinfo agr \"\"\n"); // PZ - make sure AGR is going to be off
				if ( coop )
					localcmd( "localinfo _voted_coop 0\n" );
				if ( !deathmatch )
					localcmd( "localinfo _voted_deathmatch 3\n" );
			} else if ( current_voteent.group_no == #VOTEMAP_COOP ) {
				localcmd("localinfo agr \"\"\n"); // PZ - make sure AGR is going to be off
				if ( !coop || coop == 3 )
					localcmd( "localinfo _voted_coop 1\n" );
				if ( deathmatch )
					localcmd( "localinfo _voted_deathmatch 0\n" );
			} else if ( current_voteent.group_no == #VOTEMAP_INSANECOOP ) {
				localcmd("localinfo agr \"\"\n"); // PZ - make sure AGR is going to be off
				if ( coop != 3 )
					localcmd( "localinfo _voted_coop 3\n" );
				if ( deathmatch )
					localcmd( "localinfo _voted_deathmatch 0\n" );
			}
#endif
			else {
				localcmd("localinfo agr \"\"\n"); // PZ - make sure AGR is going to be off
				localcmd( "localinfo _voted_coop \"\"\n" );
				localcmd( "localinfo _voted_deathmatch \"\"\n" );
			}

			localcmd("localinfo nmap \"");
			localcmd(current_voteent.netname);
			localcmd("\"\n");
			
			BroadcastSound("misc/runekey");

			ResetVoteEnt(); // removes current vote entity

			return #TRUE;
		}
//		else if (num_against >= num_total * (1 - #VOTESNEEDED_NEXTMAP))
		else
		{
			bprint(#PRINT_HIGH,"Votingç Map voting failed");
			bprintVoteIssue();
			bprint(#PRINT_HIGH,"\n");
			
			BroadcastSound("misc/runekey");
			
			ResetVoteEnt();
		}
	}
	else if (current_voteent.has_sentry == #VOTE_SWITCHMAP)
	{
//		if (num_for > num_total * #VOTESNEEDED_MAP) // success?
		if ( VotePassed( num_for, num_against, #VOTESNEEDED_MAP ) )
		{
			st = colstr(current_voteent.netname,#COLSTR_RED);

			bprint(#PRINT_HIGH,"Votingç Success° Switching map to ",st);
			// Gizmo - print the map vote type
			PrintVoteMapType( ", with ", current_voteent.group_no, " mode" );
			bprint( #PRINT_HIGH, "\n" );

			// Gizmo
			if ( current_voteent.group_no == #VOTEMAP_AGR ) {
				localcmd( "localinfo agr 1\n" );
				if ( coop )
					localcmd( "localinfo _voted_coop 0\n" );
				if ( !deathmatch )
					localcmd( "localinfo _voted_deathmatch 3\n" );
			}

#ifdef COOP_MODE_ENHANCED
			else if ( current_voteent.group_no == #VOTEMAP_TF ) {
				localcmd("localinfo agr \"\"\n"); // PZ - make sure AGR is going to be off
				if ( coop )
					localcmd( "localinfo _voted_coop 0\n" );
				if ( !deathmatch )
					localcmd( "localinfo _voted_deathmatch 3\n" );
			} else if ( current_voteent.group_no == #VOTEMAP_COOP ) {
				localcmd("localinfo agr \"\"\n"); // PZ - make sure AGR is going to be off
				if ( !coop || coop == 3 )
					localcmd( "localinfo _voted_coop 1\n" );
				if ( deathmatch )
					localcmd( "localinfo _voted_deathmatch 0\n" );
			} else if ( current_voteent.group_no == #VOTEMAP_INSANECOOP ) {
				localcmd("localinfo agr \"\"\n"); // PZ - make sure AGR is going to be off
				if ( coop != 3 )
					localcmd( "localinfo _voted_coop 3\n" );
				if ( deathmatch )
					localcmd( "localinfo _voted_deathmatch 0\n" );
			}
#endif
			else {
				localcmd("localinfo agr \"\"\n"); // PZ - make sure AGR is going to be off
				localcmd( "localinfo _voted_coop \"\"\n" );
				localcmd( "localinfo _voted_deathmatch \"\"\n" );
			}

			BroadcastSound("misc/runekey");

			LaunchMap(current_voteent.netname);

			ResetVoteEnt(); // removes current vote entity

			return #TRUE;
		}
//		else if (num_against >= num_total * (1 - #VOTESNEEDED_MAP))
		else
		{
			bprint(#PRINT_HIGH,"Votingç Map voting failed");
			bprintVoteIssue();
			bprint(#PRINT_HIGH,"\n");
			
			BroadcastSound("misc/runekey");
			
			ResetVoteEnt();
		}
	}
	// Gizmo - use object voting
	else if ( current_voteent.has_sentry == #VOTE_USEOBJECT ) {
		local string objectAction;

		if ( VotePassed( num_for, num_against, #VOTESNEEDED_USE ) ) {
			st = GetUseObjectName( current_voteent.enemy );
			objectAction = GetUseObjectAction( current_voteent.enemy );
			bprint( #PRINT_HIGH, "Votingç Success° ", st, " will now ", objectAction, "\n" );

			UseObject( current_voteent.enemy );

			BroadcastSound( "misc/runekey" );
			ResetVoteEnt(); // removes current vote entity

			return #TRUE;
		} else {
			bprint( #PRINT_HIGH, "Votingç Use voting failed" );
			bprintVoteIssue ();
			bprint( #PRINT_HIGH, "\n" );
			
			BroadcastSound( "misc/runekey" );
			
			ResetVoteEnt ();
		}
	}

	return #FALSE;
};

//==========================================================================
// Checks if valid vote entity

float() ValidVoteEnt =
{
	if (current_voteent == world)
		return #FALSE;

	if (current_voteent.classname != "voteent")
		return #FALSE;
	
	return #TRUE;
};


//============================================================
// gets the map localinfo string for the number passed in

string(float themap) GetMapString =
{
	local string st, mapnum, temp;
	
	mapnum = ftos(themap);

	temp = strcat("m",mapnum);
	st = infokey(world,temp);
	
	return st;
};

//===============================================================
// Prints remaining votes for success

/*
=============
bprintVotesNeeded

Prints the number of votes needed to
make the vote not fail when the timer's up.
Note that this may not print anything at all.
=============
*/
void( float num_for, float num_against ) bprintVotesNeeded = {
	local string	st;
	local float		forTemp, againstTemp;
	local float		fraction;

	// only bother if people didn't vote yet
	if ( num_players - ( num_for + num_against ) > 0 ) {
		fraction = 0.5;

		if ( current_voteent.has_sentry == #VOTE_PUNISH ) {
			if (current_voteent.g_a == #PUNISH_CURSE)
				fraction = #VOTESNEEDED_CURSE;
			else if ( current_voteent.g_a == #PUNISH_KICK )
				fraction = #VOTESNEEDED_KICK;
			else if ( current_voteent.g_a == #PUNISH_BAN )
				fraction = #VOTESNEEDED_BAN;
			else if ( current_voteent.g_a == #PUNISH_MUTE )
				fraction = #VOTESNEEDED_MUTE;
			else if ( current_voteent.g_a == #PUNISH_CUFF )
				fraction = #VOTESNEEDED_CUFF;
		} else if ( current_voteent.has_sentry == #VOTE_NEXTMAP )
			fraction = #VOTESNEEDED_NEXTMAP;
		else if ( current_voteent.has_sentry == #VOTE_SWITCHMAP )
			fraction = #VOTESNEEDED_MAP;
		// Gizmo - use object voting
		else if ( current_voteent.has_sentry == #VOTE_USEOBJECT )
			fraction = #VOTESNEEDED_USE;

		num_against = num_against + ( num_players - ( num_for + num_against ) ) * fraction;

		// if the vote won't pass at the end, then print the number of votes needed to make it pass
		if ( num_for <= num_against ) {
			forTemp = num_for;
			againstTemp = num_against;
			do {
				forTemp = forTemp + 1;
				againstTemp = againstTemp - fraction;
			} while ( forTemp <= againstTemp );

			st = colstr( ftos( forTemp - num_for ), #COLSTR_NUMBER );
			bprint( #PRINT_HIGH, " (", st, " needed to not fail)" );
		}
	}
};

void() bprintVotesLeft =
{
	local string st;
	local float num_for, num_against;
	local entity te;

	num_for = 0;
	num_against = 0;
	
	// Count the number of votes for and against.
	te = nextent(world);
	while (te != world) {
		if (te.classname == "player" || te.classname == "spec") {
			if (te.owned_by == #VOTED_YES) {
				num_for = num_for + 1;
			} else if (te.owned_by == #VOTED_NO) {
				num_against = num_against + 1;
			}
		}
		te = nextent(te);
	}

	st = colstr(ftos(num_for), #COLSTR_NUMBER);
	bprint(#PRINT_HIGH, " €", st, " for Ø ");

	st = colstr(ftos(num_against), #COLSTR_NUMBER);
	bprint(#PRINT_HIGH, st, " against");

	// Gizmo - print the number of votes needed for the vote to pass
	bprintVotesNeeded( num_for, num_against );

	bprint( #PRINT_HIGH, "›\n" );
	//›\n
};

//======================================================================================
// The current punishment vote goes to sleep (player to be muted/cuffed hides away)

// Warning: here we assume self is the player leaving server to be punished
void() VoteToSleep =
{
	local string st;
	
	// First clean up any sleeping vote
	CleanUpSleepVote();

	current_voteent.think = VoteSleep_think;
	current_voteent.nextthink = time + #VOTESLEEP_RATECHECK;
	current_voteent.classname = "sleepvote";

	st = infokey(self,"ip");

	current_voteent.message = makestr(st);
	current_voteent.admin_kick = world;
	current_voteent.ltime = time;

	current_voteent = world;

	votesleeping = #TRUE;
};

void() VoteSleep_think =
{
	self.nextthink = time + #VOTESLEEP_RATECHECK;

	if (!ValidVoteEnt())
	{
		if (self.admin_kick != world)
		{
			if (!self.admin_kick.is_connected) // He tries to hide again? lol
				self.admin_kick = world; // reset
			else
				SleepVoteResume(self, self.admin_kick);
		}
	}

	// Check if we should discard this sleeping vote
	if (floor((time - self.ltime) / 60) > #VOTESLEEP_DURATION)
	{
		delstr(self.message);
		dremove(self);
		votesleeping = #FALSE;
	}
};

void() CleanUpSleepVote =
{
	local entity te;

	te = find(world,classname,"sleepvote");

	while (te)
	{
		delstr(te.message);
		dremove(te);

		te = find(te,classname,"sleepvote");
	}

	votesleeping = #FALSE;
};

entity() GetSleepVote =
{
	local entity te;

	te = find(world,classname,"sleepvote");

	return te;
};

void(entity sleepent, entity targetclient) SleepVoteResume =
{
	delstr(sleepent.message);
	
	current_voteent = sleepent;
	current_voteent.think = PunishVote_Think;
	current_voteent.nextthink = time + #VOTE_TIME;
	current_voteent.classname = "voteent";
	current_voteent.admin_kick = targetclient;

	votesleeping = #FALSE;

	BroadcastSound("misc/medkey");

	bprint(#PRINT_HIGH,"Votingç Resuming vote to ");
	if (current_voteent.g_a == #PUNISH_MUTE)
		bprint(#PRINT_HIGH,"mute ");
	else if (current_voteent.g_a == #PUNISH_CUFF)
		bprint(#PRINT_HIGH,"cuff ");
	bprint(#PRINT_HIGH,current_voteent.admin_kick.netname);
	bprintVotesLeft();
};
