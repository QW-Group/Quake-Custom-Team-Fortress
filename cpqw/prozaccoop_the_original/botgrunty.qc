/* ------------------------------------------------------------------------------------
** ------------------------------------GRUNTYBOT(tm)-----------------------------------
** -- Your new, improved artificially intelligent mercenary from beyond the Void	 --
** -- Use with caution																  -
** -- Do not expose to excessive amounts of radiation								  -
** -- Share and Enjoy!																 --
** --- Copyright(c)2000 By Dwarven Star Interactive Industrial Industry Enterprises ---
** ----------------------------------------------------------------------------------*/

// Prototypes


// A new, improved, multi-directional waypoint
// Things we'll need:
//
// Targetname, for improved map support
// Target, for improved map support
// message, string1, string2, string3 and/or string4 for branches in movement

void() custom_bot_point =
{
	if (!self.targetname)
		objerror("custom_bot_point: no targetname");
	
	
	
};