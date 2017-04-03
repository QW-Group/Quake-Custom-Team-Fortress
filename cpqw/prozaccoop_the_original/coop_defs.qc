// coop_defs.qc

#ifndef COOP_MODE_ENHANCED
#pragma DONT_COMPILE_THIS_FILE
#else


// alternate teams
#define TEAMNO_MONSTERS				100				// team number for monsters

// monster weights, a monster can be inbetween these
#define MWEIGHT_SMALL				80				// small monster
#define MWEIGHT_NORMAL				160
#define MWEIGHT_MEDIUM				290
#define MWEIGHT_LARGE				500
#define MWEIGHT_HUGE				1000

// monster flags
#define MFLAG_HASWEAPON				1				// used for judo, determines if he can be stunned
#define MFLAG_HUMANOID				2				// dogs and other similar monsters won't have this flag
#define MFLAG_ALMOSTHUMANOID		4				// almost looks like a humanoid
#define MFLAG_BITER					8				// the monster can bite (IE: dogs)
#define MFLAG_NOHEART				16				// mainly for warlock heart grabbing
#define MFLAG_NOBREATHING			32				// monster doesn't breathe, (IE: shambler, enforcer (has suit))
#define MFLAG_NOLEGDAMAGE			64				// monster has legs but doesn't take leg damage (tarbabys)
#define MFLAG_NOLEGS				128				// monster doesn't even have legs

// coop monster fields
.float monsterweight;
.float monsterflags;								// MFLAG_*** flags

// coop only player fields
#define is_dead_observer			monsterweight

#endif
