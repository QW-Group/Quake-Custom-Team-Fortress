/*
 *  QWProgs-TF2003
 *  Copyright (C) 2004  [sd] angel
 *
 *  This code is based on Q3 VM code by Id Software, Inc.
 *
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 *
 *
 *  $Id: g_consts.h,v 1.3 2004/12/23 03:16:14 AngelD Exp $
 */

//
// constants
//
// edict.flags
#define FL_FLY 1
#define FL_SWIM 2
#define FL_CLIENT 8		// set for all client edicts
#define FL_INWATER 16		// for enter / leave water splash
#define FL_MONSTER 32
#define FL_GODMODE 64		// player cheat
#define FL_NOTARGET 128		// player cheat
#define FL_ITEM 256		// extra wide size for bonus items
#define FL_ONGROUND 512		// standing on something
#define FL_PARTIALGROUND 1024	// not all corners are valid
#define FL_WATERJUMP 2048	// player jumping out of water
#define FL_JUMPRELEASED 4096	// for jump debouncing

// edict.movetype values
#define MOVETYPE_NONE   0	// never moves
//#define MOVETYPE_ANGLENOCLIP 1 
//#define MOVETYPE_ANGLECLIP 2 
#define MOVETYPE_WALK   3	// players only
#define MOVETYPE_STEP   4	// discrete, not real time unless fall
#define MOVETYPE_FLY   5
#define MOVETYPE_TOSS   6	// gravity
#define MOVETYPE_PUSH   7	// no clip to world, push and crush
#define MOVETYPE_NOCLIP   8
#define MOVETYPE_FLYMISSILE  9	// fly with extra size against monsters
#define MOVETYPE_BOUNCE   10
#define MOVETYPE_BOUNCEMISSILE 11	// bounce with extra size

// edict.solid values
#define SOLID_NOT  0		// no interaction with other objects
#define SOLID_TRIGGER 1		// touch on edge, but not blocking
#define SOLID_BBOX  2		// touch on edge, block
#define SOLID_SLIDEBOX 3	// touch on edge, but not an onground
#define SOLID_BSP  4		// bsp clip, touch on edge, block

// range values
#define RANGE_MELEE 0
#define RANGE_NEAR 1
#define RANGE_MID 2
#define RANGE_FAR 3

// deadflag values

#define DEAD_NO    0
#define DEAD_DYING   1
#define DEAD_DEAD   2
#define DEAD_RESPAWNABLE 3

// takedamage values

#define DAMAGE_NO 0
#define DAMAGE_YES 1
#define DAMAGE_AIM 2

// items
#define IT_AXE 4096
#define IT_SHOTGUN 1
#define IT_SUPER_SHOTGUN 2
#define IT_NAILGUN 4
#define IT_SUPER_NAILGUN 8
#define IT_GRENADE_LAUNCHER 16
#define IT_ROCKET_LAUNCHER 32
#define IT_LIGHTNING 64
#define IT_EXTRA_WEAPON 128

#define IT_SHELLS 256
#define IT_NAILS 512
#define IT_ROCKETS 1024
#define IT_CELLS 2048

#define IT_ARMOR1 8192
#define IT_ARMOR2 16384
#define IT_ARMOR3 32768
#define IT_SUPERHEALTH 65536

#define IT_KEY1 131072
#define IT_KEY2 262144

#define IT_INVISIBILITY 524288
#define IT_INVULNERABILITY 1048576
#define IT_SUIT 2097152
#define IT_QUAD 4194304
#define IT_HOOK 8388608

// point content values

#define CONTENT_EMPTY -1
#define CONTENT_SOLID -2
#define CONTENT_WATER -3
#define CONTENT_SLIME -4
#define CONTENT_LAVA -5
#define CONTENT_SKY  -6

#define STATE_TOP 0
#define STATE_BOTTOM 1
#define STATE_UP 2
#define STATE_DOWN 3



// sound channels
// channel 0 never willingly overrides
// other channels (1-7) allways override a playing sound on that channel
#define CHAN_AUTO 0
#define CHAN_WEAPON 1
#define CHAN_VOICE 2
#define CHAN_ITEM 3
#define CHAN_BODY 4
#define CHAN_NO_PHS_ADD 8

#define ATTN_NONE 0
#define ATTN_NORM 1
#define ATTN_IDLE 2
#define ATTN_STATIC 3


// update types

#define UPDATE_GENERAL 0
#define UPDATE_STATIC 1
#define UPDATE_BINARY 2
#define UPDATE_TEMP 3

// entity effects

#define EF_BRIGHTFIELD 1
#define EF_MUZZLEFLASH 2
#define EF_BRIGHTLIGHT 4
#define EF_DIMLIGHT 8
#define EF_FLAG1   16
#define EF_FLAG2  32
#define EF_BLUE   64
#define EF_RED  128

// messages
// Since BROADCAST is never used in QW 1.5, and MULTICAST is used instead,
// just define BROADCAST as MULTICAST for QW 1.5
#define MSG_MULTICAST   4
#define MSG_BROADCAST  MSG_MULTICAST
#define MSG_ONE   1		// reliable to one (msg_entity)
#define MSG_ALL   2		// reliable to all
#define MSG_INIT  3		// write to the init string


// message levels
#define PRINT_LOW   0		// pickup messages
#define PRINT_MEDIUM  1		// death messages
#define PRINT_HIGH   2		// critical messages
#define PRINT_CHAT   3		// also goes to chat console

// multicast sets
#define MULTICAST_ALL    0	// every client
#define MULTICAST_PHS    1	// within hearing
#define MULTICAST_PVS    2	// within sight
#define MULTICAST_ALL_R  3	// every client, reliable
#define MULTICAST_PHS_R  4	// within hearing, reliable
#define MULTICAST_PVS_R  5	// within sight, reliable



#define AS_STRAIGHT 1
#define AS_SLIDING 2
#define AS_MELEE 3
#define AS_MISSILE 4


#define	SPAWNFLAG_NOT_EASY			256
#define	SPAWNFLAG_NOT_MEDIUM		512
#define	SPAWNFLAG_NOT_HARD			1024
#define	SPAWNFLAG_NOT_DEATHMATCH	2048

// protocol bytes
#define SVC_TEMPENTITY 23
#define SVC_KILLEDMONSTER 27
#define SVC_FOUNDSECRET 28
#define SVC_INTERMISSION 30
#define SVC_FINALE 31
#define SVC_CDTRACK 32
#define SVC_SELLSCREEN 33
#define SVC_SETINFO 51

#define SVC_SMALLKICK  34
#define SVC_BIGKICK   35
#define SVC_MUZZLEFLASH  39


#define TE_SPIKE   0
#define TE_SUPERSPIKE  1
#define TE_GUNSHOT   2
#define TE_EXPLOSION  3
#define TE_TAREXPLOSION  4
#define TE_LIGHTNING1  5
#define TE_LIGHTNING2  6
#define TE_WIZSPIKE   7
#define TE_KNIGHTSPIKE  8
#define TE_LIGHTNING3  9
#define TE_LAVASPLASH  10
#define TE_TELEPORT   11
#define TE_BLOOD         12
#define TE_LIGHTNINGBLOOD 13


// multicast sets
#define MULTICAST_ALL    0	// every client
#define MULTICAST_PHS    1	// within hearing
#define MULTICAST_PVS    2	// within sight
#define MULTICAST_ALL_R  3	// every client, reliable
#define MULTICAST_PHS_R  4	// within hearing, reliable
#define MULTICAST_PVS_R  5	// within sight, reliable
