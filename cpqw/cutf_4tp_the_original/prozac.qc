/*=======================================================//
// prozac.QC - CustomTF 3.2.OfN           - 15/11/2004 - //
// by Sergio Fumaña Grunwaldt - OfteN [cp]               //
=========================================================//
 ProZac Message Of The Day (MOTD) and un/related stuff :)
=========================================================*/

#define MSG_OFTEN_CUTFVERSION "Running Coop progs version 1.0.9.0 Û1¯30¯2009Ý\n"

#define MSG_INFO "\nType ¢cmd help¢ to see additional client commands.\n"

//#define MSG_CUTFVERSION "CustomÔÆ version ö3®2®OfN"
//WK #define MSG_CUTFVERSION   "ÐÒÏÚÁÃ CustomÔÆ ö•®”®OfN˜" //<-- 3.2.OfN6

//#ifdef COOP_MODE_ENHANCED
//#define MSG_CUTFVERSION		"ÐÒÏÚÁÃ CustomÔÆ COOP VERSION 1.0.9.0 (1-30-09)"
//#else
#define MSG_CUTFVERSION		"CustomTF Æïò Ôèå Ðåïðìå"
//#endif

// Welcome to CustomTF For The People\nwhere the PLAYERS decide how the game is played!\n
#define MSG_INTRO  "Welcome to CustomTF Æïò Ôèå Ðåïðìå\nwhere the ÐÌÁÙÅÒÓ decide\nhow the game is played!\n\nPlease give your input at:\n\nãõóôïíôæ®îåô¯æïòõí\n\nžžžžžžžžžžžžžžžžžžžžžžžžžžžžŸ\n\n"
#define MSG_INTRO2 "Based on Ôèå Çéúíï's Coop mod\nwhich is based on Prozac CuTF Classic\n\nHosted by PhoenixLabs.org\n\n" // žžžžžžžžžžžžžžžžžžžžžžžžžžŸ\n\n
#define MSG_INTRO3 "\nPress '' to skip"
//http:¯¯kickme®to¯customtf"


//WK 152 Default, must be > 6.
#define MOTD_FINISHED 1600 //WK 1/7/7 420 //242 		//Delay in 1/10th seconds for motd to show

void() PrintProzacMOTD =
{
    local string st;
    local string st2; 
    local float x;

    st = "Celebrating “• years of CustomTF!!\n\n";
    
    if ((self.#cprint_fx & 3) == 3)
        st = colstr(st,#COLSTR_MIX1);
    else if (self.#cprint_fx & 2)
        st = colstr(st,#COLSTR_RED);
    else if (self.#cprint_fx & 1)
        st = colstr(st,#COLSTR_MIX2);

    st2 = #MSG_INTRO3;
    x = floor(time);
    if (x - (2 * floor(x / 2)) == 0) // x mod 2 == 0
        st2 = colstr(st2, #COLSTR_RED);
    
    CenterPrint4(self,#MSG_INTRO,#MSG_INTRO2,st,st2);

    self.#cprint_fx = self.#cprint_fx + 1;
};

void() PrintProzacIntro =
{
    if (!no_votemap && !no_punish)
        sprint(self,#PRINT_HIGH,"\nVoting You can issue a vote by using the ¢VoteMap¢ and ¢Punish¢ commands.\n");
    else
    {
        if (!no_punish)
            sprint(self,#PRINT_HIGH,"\nVoting You can issue a vote by using ¢VoteMap¢ command.\n");
        else if (!no_votemap)
            sprint(self,#PRINT_HIGH,"\nVoting You can issue a vote by using ¢Punish¢ command.\n");
    }

    //sprint (self, #PRINT_HIGH, #MSG_INFO, "\n",#MSG_OFTEN_CUTFVERSION, "\nžžŸ ", #MSG_CUTFVERSION, " žžžŸ\n       Éîæïòíáôéïî èïíåðáçå:\n     www®telefragged®com¯shaka\nžžžžžžžžžžžžžžžžžžžžžžžžžžžžžžžžžžŸ\n\n");
    sprint (self, #PRINT_HIGH, #MSG_INFO, "\n",#MSG_OFTEN_CUTFVERSION, "\nžžŸ ", #MSG_CUTFVERSION, " žžŸ\n    Please give your input at:\n       customtf®net¯forum\nžžžžžžžžžžžžžžžžžžžžžžžžžžžžžžžŸ\n\n");

	// Gizmo
#ifdef COOP_MODE_ENHANCED
	if ( coop == 3 && !deathmatch ) {
		local string	str;

		str = colstr( "œThis server is in Insane Coop modeœ\n", #COLSTR_RED );
		sprint( self, #PRINT_HIGH, str );
	}
#endif

	// PZ - Attackers Go Red mode
	if (agr) { AGR_introducePlayer(); sprint(self, #PRINT_HIGH, "\n"); }
};
