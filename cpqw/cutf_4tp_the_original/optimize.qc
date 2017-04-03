/*======================================================
	OPTIMIZE.QC			Custom TeamFortress v2.1	
	(c) Craig Hauser				10/4/00
========================================================
This has the optimizations that I have done, basically if
I saw something similar being run in multi places I made
a function and put it here.
======================================================*/
float (float t1, float t2) Teammate;
float (entity targ, entity check) visible2;
float (entity targ, entity check) visible2x;
void(entity targ, entity inflictor, entity attacker, float damage, float T_flags, float T_AttackType) TF_T_Damage;
#ifdef COOP_MODE_ENHANCED
float( entity test ) COOP_IsCoopMonster;
#endif
//checks client passed into and returns true if valid used for sents etc
//entity looking at, entity thats looking, (0-1) checks visible, (0-range) checks range, (0-1) do special tesla checks, (0-1) should check for ceasefire
float(entity targ, entity checker, float chkvis, float chkrng, float istesla, float chkcease) Pharse_Client =
{
		if (targ.classname != "player")
			return #FALSE;
#ifdef QUAKE_WORLD // culled by KK. was QUAKE_WORLD
		if (chkcease)
			/*if (infokey(world,"ceasefire")=="on")
				return #FALSE;*/
            if (ceasefire)
                return #FALSE;
#endif
		if (targ.playerclass == #PC_UNDEFINED)
			return #FALSE;
		if (targ.done_custom & #CUSTOM_BUILDING)
			return #FALSE;
		if (targ.health <= 0)
			return #FALSE;
		if (!targ.is_connected)
			return #FALSE;
		if (teamplay)
		{
			if (Teammate(targ.team_no, checker.team_no))
				{
					if (istesla)
					{
						if (!(checker.tf_items & #NIT_SECURITY_CAMERA)) //CH Cyto's idea
							return #FALSE;
					} else
					{
						return #FALSE;
					}
				}
			if (Teammate(targ.undercover_team,checker.team_no))
				{
					if (istesla)
					{
						//- OfN jammer only for scanner -// nope
                        if (!(checker.tf_items & #NIT_AUTOID) || targ.cutf_items & #CUTF_JAMMER)
                        //if (!(checker.tf_items & #NIT_AUTOID))
							return #FALSE;
					}
					else
					{						
                        if (! (checker.classname == "building_sensor" && checker.all_active & #IMPROVED_FOUR)) 
                            return #FALSE;

                        // - OfN return #FALSE;
					}
				}
		}
		if (targ == checker.real_owner)
		{
			if (istesla)
			{
				if (!(checker.tf_items & #NIT_SECURITY_CAMERA)) //CH Cyto's idea
					return #FALSE;
			} else
			{
				return #FALSE;
			}
		}
		if (targ.is_feigning)
		{
			if (istesla)
			{
				if (!(checker.tf_items & #NIT_AUTOID))
					return #FALSE;
			}
			else //if (checker.classname != "monster_army") - OfN soldiers cant detect feigning spies now
			{
				return #FALSE;
			}
		}
		if (targ.flags & #FL_NOTARGET)
			return #FALSE;
		if (targ.items & #IT_INVISIBILITY && (checker.classname != "building_sensor")) //|| checker.classname != "monster_army"))
			return #FALSE;
#ifdef COOP_MODE_ENHANCED
		// never check thief here if checker is a monster
		if (targ.job & #JOB_THIEF && (targ.job & #JOB_ACTIVE || targ.job & #JOB_FULL_HIDE) && !COOP_IsCoopMonster( checker ))
#else
		if (targ.job & #JOB_THIEF && (targ.job & #JOB_ACTIVE || targ.job & #JOB_FULL_HIDE))
#endif
		{
			if (istesla)
			{
				//- OfN jammer only for scanner -// nope
                if (!(checker.tf_items & #NIT_AUTOID) || targ.cutf_items & #CUTF_JAMMER)
                //if (!(checker.tf_items & #NIT_AUTOID))
					return #FALSE;
			}
			else if (checker.classname != "building_sensor")// && checker.classname != "monster_army" && checker.classname != "monster_demon1")
				return #FALSE;
		}
		if (chkvis && checker.classname == "building_sentrygun" && !(checker.tf_items & #NIT_TURRET)) // - OfN - hackish fix for sentry gun targetting
		{
            if (!visible2x(targ,checker)) // - OfN - hackish fix for sentry gun targetting
 				return #FALSE;
        }
        else if (chkvis)
			if (!visible2(targ,checker))
 				return #FALSE;
		if (chkrng)
		{
			local float r;
			
			r = vlen(targ.origin - checker.origin);
			if (r > chkrng)
				return #FALSE;
		}
	return #TRUE;
};
//gives entity passed into number of frags passed
//entity gets frag, entity gave frag, give this many frags, (0-1) log frags, 1=real_frag 2=frag, (0-1) checks real_frag, (0-1) check frag vamp (takes from targ)

void(entity atk, entity targ, float numfrags, float fraggetlog, float howgive, float chkreal, float chkvamp) Give_Frags_Out =
{
/*
local string st;
bprint(#PRINT_HIGH, "atk:");
bprint(#PRINT_HIGH, atk.classname);
bprint(#PRINT_HIGH, " targ:");
bprint(#PRINT_HIGH, targ.classname);
bprint(#PRINT_HIGH, " Frag:");
st = ftos(numfrags);
bprint(#PRINT_HIGH, st);
bprint(#PRINT_HIGH, " log:");
if (fraggetlog)
	bprint(#PRINT_HIGH, "yes");
else
	bprint(#PRINT_HIGH, "no");
bprint(#PRINT_HIGH, " howgive:");
if (howgive == 1)
	bprint(#PRINT_HIGH, "real_frags");
else if (howgive == 2)
	bprint(#PRINT_HIGH, "frags");
else
	bprint(#PRINT_HIGH, "ERROR");
bprint(#PRINT_HIGH, " real:");
if (chkreal)
	bprint(#PRINT_HIGH, "yes");
else
	bprint(#PRINT_HIGH, "no");
bprint(#PRINT_HIGH, " vamp:");
if (chkvamp)
	bprint(#PRINT_HIGH, "yes");
else
	bprint(#PRINT_HIGH, "no");
bprint(#PRINT_HIGH, "\n");
*/
	if (atk.classname == "monster_army")
	{
		atk.frags = atk.frags + numfrags;
		atk.real_frags = atk.real_frags;
	}
	else
	{
		if (howgive == 2)
			atk.frags = atk.frags + numfrags;
		else if (howgive == 1)
			atk.real_frags = atk.real_frags + numfrags;
		else
			bprint(#PRINT_HIGH, "Error in Give_Frags_Out!\n");
			
		#ifdef QUAKE_WORLD
			if (fraggetlog)
			{
				logfrag (targ, atk);
			}
		#endif
		if (chkvamp)
		{
			if (teamplay & #TEAMPLAY_VAMPIRE)
			{
				targ.real_frags = targ.real_frags - numfrags;
				if (!(toggleflags & #TFLAG_TEAMFRAGS))
					targ.frags = targ.real_frags;
			}
		}	
	
		if (chkreal)
		{
		 	if (!(toggleflags & #TFLAG_TEAMFRAGS))
		 	{
				atk.frags = atk.real_frags;
			}
		}
	}
};
//replaces det guns
//classname to find, entity checking, (0-1) check for ownership
void(string search, entity person, float chkown, float type) Find_And_Dmg =
{
	local entity te;
	
    te = find(world, classname, search);
	
    if (type)
    {
        while (te)
        {
            if (chkown)
            {
                if (te.real_owner == person && type & te.dont_do_triggerwork)
                    TF_T_Damage(te, world, world, te.health+100, 0, 0);
            }
            else
            {
                if (type & te.dont_do_triggerwork)
                    TF_T_Damage(te, world, world, te.health+100, 0, 0);
            }
            te = find(te, classname, search);
        }
        
        return;
    }

    while (te)
	{
		if (chkown)
		{
			if (te.real_owner == person)
				TF_T_Damage(te, world, world, te.health+100, 0, 0);
		}
		else
		{
			TF_T_Damage(te, world, world, te.health+100, 0, 0);
		}
		te = find(te, classname, search);
	}
};

float () isMelee =
{
	if (self.current_weapon == #WEAP_AXE || self.current_weapon == #WEAP_SPANNER || self.current_weapon == #WEAP_MEDIKIT)
		return #TRUE;
	else
		return #FALSE;
};

/*
==========================================================================
OfN - Optimize what?

---------------------------
Bit/Byte/Decimal reference:
---------------------------
1  1 1
2  2 2
3  3 4
4  4 8
5  5 16 
6  6 32
7  7 64
8  8 128

9  1 256
10 2 512
11 3 1024
12 4 2048
13 5 4096
14 6 8192
15 7 16384
16 8 32768

17 1 65536
18 2 131072
19 3 262144
20 4 524288
21 5 1048576
22 6 2097152
23 7 4194304
24 8 8388608
---------------------------------
QuakeC floats are all 24-bit wide
So, we can use 3 bytes on them !!
---------------------------------

Functions to handle multiple integers (byte wide) on a single float:
==========================================================================
*/

//==========================================
// Retrieval of byte values

float (float value) GetByte1 =
{
    return value & 255;
};

float (float value) GetByte2 =
{
    local float res;

    res = value & 65280;
    res = res / 256;
    
    return res;
};

float (float value) GetByte3 =
{
    local float res;

    res = value & 16711680;
    res = res / 65536;
    
    return res;
};

//=======================================
// Transform values into different bytes

float (float value) MakeByte2 =
{
    value = floor(value);
    if (value < 0)
        value = 0;
    if (value > 255)
        value = 255;
    return value * 256;
};

float (float value) MakeByte3 =
{
    value = floor(value);
    if (value < 0)
        value = 0;
    if (value > 255)
        value = 255;
    return value * 65536;
};

//=====================================
// Assign value to different bytes

float (float targetval, float value) AssignByte1 =
{
    value = floor(value);
    if (value < 0)
        value = 0;
    if (value > 255)
        value = 255;
    targetval = targetval - (targetval & 255);
    targetval = targetval + value;

    return targetval;
};

float (float targetval, float value) AssignByte2 =
{
    targetval = targetval - (targetval & 65280);
    targetval = targetval + MakeByte2(value);

    return targetval;
};

float (float targetval, float value) AssignByte3 =
{
    targetval = targetval - (targetval & 16711680);
    targetval = targetval + MakeByte3(value);

    return targetval;
};

//===============================================================================
// Special bitfield handling for warlock's .demon_blood float
// bit usage is: 6 bits (hearts) -> 10 bits (meat) -> 8 bits (heads)
// so the 3rd value doesnt require special functions

float(float value) GetWarlock1 =
{
    return value & 63;
};

float(float value) GetWarlock2 =
{
    local float res;

    res = value & 65472;
    res = res / 64;
    
    return res;    
};

float (float value) MakeWarlock2 =
{
    value = floor(value);
    if (value < 0)
        value = 0;
    if (value > 1023)
        value = 1023;
    return value * 64;
};

float(float targetval, float value) AssignWarlock1 =
{
    value = floor(value);
    if (value < 0)
        value = 0;
    if (value > 63)
        value = 63;

    targetval = targetval - (targetval & 63);
    targetval = targetval + value;

    return targetval;
};

float(float targetval, float value) AssignWarlock2 =
{
    targetval = targetval - (targetval & 65472);
    targetval = targetval + MakeWarlock2(value);

    return targetval;
};

//==============================================================
// Returns the power of 2 corresponding to the given integer

float(float input) itob =
{
    if (input == 1) return 1;
    if (input == 2) return 2;
    if (input == 3) return 4;
    if (input == 4) return 8;
    if (input == 5) return 16;
    if (input == 6) return 32;
    if (input == 7) return 64;
    if (input == 8) return 128;
    if (input == 9) return 256;
    if (input == 10) return 512;
    if (input == 11) return 1024;
    if (input == 12) return 2048;
    if (input == 13) return 4096;
    if (input == 14) return 8192;
    if (input == 15) return 16384;
    if (input == 16) return 32768;
    if (input == 17) return 65536;
    if (input == 18) return 131072;
    if (input == 19) return 262144;
    if (input == 20) return 524288;
    if (input == 21) return 1048576;
    if (input == 22) return 2097152;
    if (input == 23) return 4194304;
    if (input == 24) return 8388608;

    return 0;
};
