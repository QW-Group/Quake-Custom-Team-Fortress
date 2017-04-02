/*
Copyright (C) 1996-1997 Id Software, Inc.

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  

See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

*/
// server.h

#define	QW_SERVER

#define	MAX_MASTERS	8				// max recipients for heartbeat packets

#define	MAX_SIGNON_BUFFERS	8

typedef enum {
	ss_dead,			// no map loaded
	ss_loading,			// spawning level edicts
	ss_active			// actively running
} server_state_t;
// some qc commands are only valid before the server has finished
// initializing (precache commands, static sounds / objects, etc)

typedef struct
{
	qboolean	active;				// false when server is going down
	server_state_t	state;			// precache commands are only valid during load

	double		time;
	
	int			lastcheck;			// used by PF_checkclient
	double		lastchecktime;		// for monster ai 

	qboolean	paused;				// are we paused?

	//check player/eyes models for hacks
	unsigned	model_player_checksum;
	unsigned	eyes_player_checksum;
	
	char		name[64];			// map name
	char		modelname[MAX_QPATH];		// maps/<name>.bsp, for model_precache[0]
	struct model_s 	*worldmodel;
	char		*model_precache[MAX_MODELS];	// NULL terminated
	char		*sound_precache[MAX_SOUNDS];	// NULL terminated
	char		*lightstyles[MAX_LIGHTSTYLES];
	struct model_s		*models[MAX_MODELS];

	int			num_edicts;			// increases towards MAX_EDICTS
	edict_t		*edicts;			// can NOT be array indexed, because
									// edict_t is variable sized, but can
									// be used to reference the world ent

	byte		*pvs, *phs;			// fully expanded and decompressed

	// added to every client's unreliable buffer each frame, then cleared
	sizebuf_t	datagram;
	byte		datagram_buf[MAX_DATAGRAM];

	// added to every client's reliable buffer each frame, then cleared
	sizebuf_t	reliable_datagram;
	byte		reliable_datagram_buf[MAX_MSGLEN];

	// the multicast buffer is used to send a message to a set of clients
	sizebuf_t	multicast;
	byte		multicast_buf[MAX_MSGLEN];

	// the master buffer is used for building log packets
	sizebuf_t	master;
	byte		master_buf[MAX_DATAGRAM];

	// the signon buffer will be sent to each client as they connect
	// includes the entity baselines, the static entities, etc
	// large levels will have >MAX_DATAGRAM sized signons, so 
	// multiple signon messages are kept
	sizebuf_t	signon;
	int			num_signon_buffers;
	int			signon_buffer_size[MAX_SIGNON_BUFFERS];
	byte		signon_buffers[MAX_SIGNON_BUFFERS][MAX_DATAGRAM];
} server_t;


#define	NUM_SPAWN_PARMS			16

typedef enum
{
	cs_free,		// can be reused for a new connection
	cs_zombie,		// client has been disconnected, but don't reuse
					// connection for a couple seconds
	cs_connected,	// has been assigned to a client_t, but not in game yet
	cs_spawned		// client is fully in game
} client_state_t;

typedef struct
{
	// received from client

	// reply
	double				senttime;
	float				ping_time;
	packet_entities_t	entities;
} client_frame_t;

#define MAX_BACK_BUFFERS 4

typedef enum {
	clc_ok,	
	clc_wait1,
	clc_wait2,
	clc_unchecked
} kkclc_t;

typedef enum {
        ft_ban,         // cuff penatly save over disconnect
        ft_mute,        // mute penalty save over disconnect
        ft_cuff         // cuff penatly save over disconnect
} filtertype_t;

typedef struct client_s
{
	client_state_t	state;

	int				spectator;			// non-interactive

	qboolean		sendinfo;			// at end of frame, send info to all
										// this prevents malicious multiple broadcasts
	float			lastnametime;		// time of last name change
	int				lastnamecount;		// time of last name change
	unsigned		checksum;			// checksum for calcs
	qboolean		drop;				// lose this guy next opportunity
	int				lossage;			// loss percentage

	int				userid;							// identifying number
	char			userinfo[MAX_INFO_STRING];		// infostring

	usercmd_t		lastcmd;			// for filling in big drops and partial predictions
	double			localtime;			// of last message
	int				oldbuttons;

	float			maxspeed;			// localized maxspeed
	float			entgravity;			// localized ent gravity

	edict_t			*edict;				// EDICT_NUM(clientnum+1)
	char			name[32];			// for printing to other people
										// extracted from userinfo
	int				messagelevel;		// for filtering printed messages

	// the datagram is written to after every frame, but only cleared
	// when it is sent out to the client.  overflow is tolerated.
	sizebuf_t		datagram;
	byte			datagram_buf[MAX_DATAGRAM];

	// back buffers for client reliable data
	sizebuf_t	backbuf;
	int			num_backbuf;
	int			backbuf_size[MAX_BACK_BUFFERS];
	byte		backbuf_data[MAX_BACK_BUFFERS][MAX_MSGLEN];

	double			connection_started;	// or time of disconnect for zombies
	qboolean		send_message;		// set on frames a datagram arived on

// spawn parms are carried from level to level
	float			spawn_parms[NUM_SPAWN_PARMS];

// client known data for deltas	
	int				old_frags;
	
	int				stats[MAX_CL_STATS];


	client_frame_t	frames[UPDATE_BACKUP];	// updates can be deltad from here

	FILE			*download;			// file being downloaded
	int				downloadsize;		// total bytes
	int				downloadcount;		// bytes sent

	int				spec_track;			// entnum of player tracking

	double			whensaid[10];       // JACK: For floodprots
 	int			whensaidhead;       // Head value for floodprots
 	double			lockedtill;

	qboolean		upgradewarn;		// did we warn him?

	FILE			*upload;
	char			uploadfn[MAX_QPATH];
	netadr_t		snap_from;
	qboolean		remote_snap;
 
//===== NETWORK ============
	int				chokecount;
	int				delta_sequence;		// -1 = no compression
	netchan_t		netchan;
	// KK hack copied from QuakeForge anti-cheat
        int                     msecs, msec_cheating;
        double                  last_check;
	double			cuff_time; // KK handcuff (no attack/impulses)
	double			clctime;   // KK clc code
	int			clcnum;
	kkclc_t			clcheck;
	qboolean		schiz;

	// phrosty - db logging.
	unsigned int databaseid;
} client_t;
				// KK color console support
#define COLOR_LEN	15	// ansi code length, eg "^[[01;33m"
extern char color[][COLOR_LEN];	// ansi color codes 
				// index of color codes (0..3 used for teams)
#define COLOR_SPEC	4	// spectator names
#define COLOR_TEXT	5	// default text color
#define COLOR_CHAT	6	// chat from players
#define COLOR_CONN	7	// (dis)connect info
#define COLOR_RCON	8	// rcon messages
extern char *KK_Team_Color(client_t *cl); // returns client's team color code
extern qboolean dont_sysprint_in_bdcast;  // stop broadcast sysprint (for color)
extern qboolean rcon_from_user;           // current command is a from a user
extern int team_no_offset;                // offset of "team_no" in edict
extern int real_owner_offset;             // offset of "real_owner" in edict

extern int cltype_offset;
extern int clversion_offset;
extern int runes_owned_offset;
extern int job_offset;

// a client can leave the server in one of four ways:
// dropping properly by quiting or disconnecting
// timing out if no valid messages are received for timeout.value seconds
// getting kicked off by the server operator
// a program error, like an overflowed reliable buffer

//=============================================================================


#define	STATFRAMES	100
typedef struct
{
	double	active;
	double	idle;
	int		count;
	int		packets;

	double	latched_active;
	double	latched_idle;
	int		latched_packets;
} svstats_t;

// MAX_CHALLENGES is made large to prevent a denial
// of service attack that could cycle all of them
// out before legitimate users connected
#define	MAX_CHALLENGES	1024

typedef struct
{
	netadr_t	adr;
	int			challenge;
	int			time;
} challenge_t;

typedef struct
{
	int			spawncount;			// number of servers spawned since start,
									// used to check late spawns
	client_t	clients[MAX_CLIENTS];
	int			serverflags;		// episode completion information
	
	double		last_heartbeat;
	int			heartbeat_sequence;
	svstats_t	stats;

	char		info[MAX_SERVERINFO_STRING];

	// log messages are used so that fraglog processes can get stats
	int			logsequence;	// the message currently being filled
	double		logtime;		// time of last swap
	sizebuf_t	log[2];
	byte		log_buf[2][MAX_DATAGRAM];

	challenge_t	challenges[MAX_CHALLENGES];	// to prevent invalid IPs from connecting
} server_static_t;

//=============================================================================

// edict->movetype values
#define	MOVETYPE_NONE			0		// never moves
#define	MOVETYPE_ANGLENOCLIP	1
#define	MOVETYPE_ANGLECLIP		2
#define	MOVETYPE_WALK			3		// gravity
#define	MOVETYPE_STEP			4		// gravity, special edge handling
#define	MOVETYPE_FLY			5
#define	MOVETYPE_TOSS			6		// gravity
#define	MOVETYPE_PUSH			7		// no clip to world, push and crush
#define	MOVETYPE_NOCLIP			8
#define	MOVETYPE_FLYMISSILE		9		// extra size to monsters
#define	MOVETYPE_BOUNCE			10

// edict->solid values
#define	SOLID_NOT				0		// no interaction with other objects
#define	SOLID_TRIGGER			1		// touch on edge, but not blocking
#define	SOLID_BBOX				2		// touch on edge, block
#define	SOLID_SLIDEBOX			3		// touch on edge, but not an onground
#define	SOLID_BSP				4		// bsp clip, touch on edge, block

// edict->deadflag values
#define	DEAD_NO					0
#define	DEAD_DYING				1
#define	DEAD_DEAD				2

#define	DAMAGE_NO				0
#define	DAMAGE_YES				1
#define	DAMAGE_AIM				2

// edict->flags
#define	FL_FLY					1
#define	FL_SWIM					2
#define	FL_GLIMPSE				4
#define	FL_CLIENT				8
#define	FL_INWATER				16
#define	FL_MONSTER				32
#define	FL_GODMODE				64
#define	FL_NOTARGET				128
#define	FL_ITEM					256
#define	FL_ONGROUND				512
#define	FL_PARTIALGROUND		1024	// not all corners are valid
#define	FL_WATERJUMP			2048	// player jumping out of water
// DO NOT USE '4096'!! It's used by quakeC
#define FL_FINALIZED			8192 // OfN - Finalized (SVC_FINALE) player (Warning: Hard coded on server!)
#define FL_FINDABLE_NONSOLID	16384 // OfN - Any entity with this can be "found" with findradius(), even if SOLID_NOT

// OfN - Traceline modes
#define TL_ANY_SOLID    0 // will hit any solid, but not triggers
#define TL_BSP_ONLY     1 // will hit BSP only
// Warning: do not use 2, it's used elsewhere (with MOVE_MISILE)
#define TL_TRIGGERS     3 // Scan for triggers (Triggers must be flagged with FL_FINDABLE_NONSOLID)
#define TL_EVERYTHING   4 // Scan for anything (Any Triggers/nonSolid entities must be flagged with FL_FINDABLE_NONSOLID)

// entity effects

//define	EF_BRIGHTFIELD			1
//define	EF_MUZZLEFLASH 			2
#define	EF_BRIGHTLIGHT 			4
#define	EF_DIMLIGHT 			8


#define	SPAWNFLAG_NOT_EASY			256
#define	SPAWNFLAG_NOT_MEDIUM		512
#define	SPAWNFLAG_NOT_HARD			1024
#define	SPAWNFLAG_NOT_DEATHMATCH	2048

#define	MULTICAST_ALL			0
#define	MULTICAST_PHS			1
#define	MULTICAST_PVS			2

#define	MULTICAST_ALL_R			3
#define	MULTICAST_PHS_R			4
#define	MULTICAST_PVS_R			5

//============================================================================

extern	cvar_t	sv_mintic, sv_maxtic;
extern	cvar_t	sv_maxspeed;
extern	cvar_t	sv_cheatpc;		// KK hack
extern	cvar_t	sv_maxrate;		// KK hack

extern	netadr_t	master_adr[MAX_MASTERS];	// address of the master server

extern	cvar_t	spawn;
extern	cvar_t	teamplay;
extern	cvar_t	deathmatch;
extern	cvar_t	fraglimit;
extern	cvar_t	timelimit;

extern	server_static_t	svs;				// persistant server info
extern	server_t		sv;					// local server

extern	client_t	*host_client;

extern	edict_t		*sv_player;

extern	char		localmodels[MAX_MODELS][5];	// inline model names for precache

extern	char		localinfo[MAX_LOCALINFO_STRING+1];

extern	int			host_hunklevel;
extern	FILE		*sv_logfile;
extern	FILE		*sv_fraglogfile;

// OfN
#define MAX_PINMSGITEM_STRING   256
#define MAX_PINMSGSIGN_STRING    64
#define NUM_PINMSGS               4

// Pinned message struct
typedef struct 
{
	//qboolean isUsed;
	char msg[MAX_PINMSGITEM_STRING];
	char sign[MAX_PINMSGSIGN_STRING];
	unsigned int counter;
} Pinmsg_Item;

// sv_init.c
extern Pinmsg_Item pinmsg[NUM_PINMSGS];
extern char pinmsg_cmdbuffer[MAX_PINMSGITEM_STRING]; // Buffer for rcon pinmsg command

// Extra string buffer stuff for progs
#define MAX_BUFFER_STRINGS        64
#define MAX_BUFFER_STRINGS_LEN   256

typedef struct 
{
	dfunction_t* OwnerFunction;
	qboolean isUsed;
	char str[MAX_BUFFER_STRINGS_LEN];
} Progs_StrBufferItem;

Progs_StrBufferItem ProgsStringsBuffer[MAX_BUFFER_STRINGS];

unsigned int NumStrBuffersUsed;

//char* UseStringBuffer(char* thestring); // pr_cmds.c
char* GetNewStringBuffer();
void CheckUnusedStrBuffers(); // pr_cmds.c
void ResetStrBuffers(); // pr_cmds.c - used on sv_init.c
//void SV_DisplayPinmsgs(client_t* theclient); // sv_main.c

edict_t* KK_Match_Str2 (char *substr); // sv_ccmds.c
char *Name_of_sender (void); // sv_main.c

// Permanent strings stuff
#define MAX_PERM_STRING_LEN 32
#define MAX_PERM_STRINGS 4*MAX_CLIENTS //Estimated need by prozac

typedef struct
{
	qboolean isUsed;
	char str[MAX_PERM_STRING_LEN];
} Progs_PermStringItem;

Progs_PermStringItem ProgsPermString[MAX_PERM_STRINGS];

char* UsePermString(char* thestring);
void ResetPermStrings();

dfunction_t* PR_GetReturningFunction();
void SV_RetrieveClientVersion(client_t* theclient);
void ConvertConsoleStringChars(char* st);

void SV_EntUsage_f (void);
void SV_PrecacheUsage_f (void);

// OfN - END

//===========================================================

//
// sv_main.c
//
void SV_Shutdown (void);
void SV_Frame (float time);
void SV_FinalMessage (char *message);
void SV_DropClient (client_t *drop);

int SV_CalcPing (client_t *cl);
void SV_FullClientUpdate (client_t *client, sizebuf_t *buf);

int SV_ModelIndex (char *name);

qboolean SV_CheckBottom (edict_t *ent);
qboolean SV_movestep (edict_t *ent, vec3_t move, qboolean relink);

void SV_WriteClientdataToMessage (client_t *client, sizebuf_t *msg);

void SV_MoveToGoal (void);

void SV_SaveSpawnparms (void);

void SV_Physics_Client (edict_t	*ent);

void SV_ExecuteUserCommand (char *s);
void SV_InitOperatorCommands (void);

void SV_SendServerinfo (client_t *client);
void SV_ExtractFromUserinfo (client_t *cl);


void Master_Heartbeat (void);
void Master_Packet (void);

//
// sv_init.c
//
void SV_SpawnServer (char *server);
void SV_FlushSignon (void);


//
// sv_phys.c
//
void SV_ProgStartFrame (void);
void SV_Physics (void);
void SV_CheckVelocity (edict_t *ent);
void SV_AddGravity (edict_t *ent, float scale);
qboolean SV_RunThink (edict_t *ent);
void SV_Physics_Toss (edict_t *ent);
void SV_RunNewmis (void);
void SV_Impact (edict_t *e1, edict_t *e2);
void SV_SetMoveVars(void);

//
// sv_send.c
//
void SV_SendClientMessages (void);

void SV_Multicast (vec3_t origin, int to);
void SV_StartSound (edict_t *entity, int channel, char *sample, int volume,
    float attenuation);
void SV_ClientPrintf (client_t *cl, int level, char *fmt, ...);
void SV_BroadcastPrintf (int level, char *fmt, ...);
void SV_BroadcastCommand (char *fmt, ...);
void SV_SendMessagesToAll (void);
void SV_FindModelNumbers (void);

//
// sv_user.c
//
void SV_ExecuteClientMessage (client_t *cl);
void SV_UserInit (void);
void SV_TogglePause (const char *msg);


//
// svonly.c
//
typedef enum {RD_NONE, RD_CLIENT, RD_PACKET} redirect_t;
void SV_BeginRedirect (redirect_t rd);
void SV_EndRedirect (void);

//
// sv_ccmds.c
//
void SV_Status_f (void);

//
// sv_ents.c
//
void SV_WriteEntitiesToClient (client_t *client, sizebuf_t *msg);

//
// sv_nchan.c
//

void ClientReliableCheckBlock(client_t *cl, int maxsize);
void ClientReliable_FinishWrite(client_t *cl);
void ClientReliableWrite_Begin(client_t *cl, int c, int maxsize);
void ClientReliableWrite_Angle(client_t *cl, float f);
void ClientReliableWrite_Angle16(client_t *cl, float f);
void ClientReliableWrite_Byte(client_t *cl, int c);
void ClientReliableWrite_Char(client_t *cl, int c);
void ClientReliableWrite_Float(client_t *cl, float f);
void ClientReliableWrite_Coord(client_t *cl, float f);
void ClientReliableWrite_Long(client_t *cl, int c);
void ClientReliableWrite_Short(client_t *cl, int c);
void ClientReliableWrite_String(client_t *cl, char *s);
void ClientReliableWrite_SZ(client_t *cl, void *data, int len);

