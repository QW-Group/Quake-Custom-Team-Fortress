/*================================================================//
// cppreqcc.cpp            CPpreQCC 1.4 - Preprocessor for QuakeC //
//----------------------------------------------------------------//
// Written using borland C++ 5 by S.F.Grunwaldt aka OfteN[cp]     //
//                                                                //
// Pulseczar removed references to windows.h, fixed warnings,     //
// standardized indentation, and fixed a few runtime errors,      //
// including a string buffer overflow. (3/26/2010)                //
//================================================================//
// Currently compatible with Microsoft Visual C++ 6 (only?)

// This program was created because the original preqcc crashed
// randomly when processing Prozac CustomTF, and i reached a 
// point it didnt run without crashing.
// So this proggy is basically a clone of the original QuakeC
// preprocessor, that was what i needed. (written from scratch)
// It is mostly a slow program, so.. optimize it! :)

It has the same pragma's and behaves the same way, except:

"#INCLUDE" directive is not supported (use INCLUDELIST)
"PROGS_DAT" pragma is not supported (always uses "..\prozac.dat")
"PROGS_SRC" pragma is not supported (always uses "progs.src")
"KEEP_NEWLINES_X" pragmas are not supported (always keeps newlines)

//================================================================*/

#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <float.h>

#include "cppreqcc.h"

char* defines_c[] =
{
	// temporary entities
	"TE_SPIKE",
	"TE_SUPERSPIKE",
	"TE_GUNSHOT",
	"TE_EXPLOSION",
	"TE_TAREXPLOSION",
	"TE_WIZSPIKE",
	"TE_KNIGHTSPIKE",
	"TE_LAVASPLASH",
	"TE_TELEPORT",
	"TE_LIGHTNING1",
	"TE_LIGHTNING2",
	"TE_LIGHTNING3",
	"TE_BLOOD",
	"TE_LIGHTNINGBLOOD",
	// Sound Channel of entities
	"CHAN_AUTO",
	"CHAN_WEAPON",
	"CHAN_VOICE",
	"CHAN_ITEM",
	"CHAN_BODY",
	"CHAN_NO_PHS_ADD",
	// Sound Attenuation
	"ATTN_NONE",
	"ATTN_NORM",
	"ATTN_IDLE",
	"ATTN_STATIC",
	// Contents of level areas
	"CONTENT_EMPTY",
	"CONTENT_SOLID",
	"CONTENT_WATER",
	"CONTENT_SLIME",
	"CONTENT_LAVA",
	"CONTENT_SKY",
	// Entity light effects
	"EF_BRIGHTFIELD",
	"EF_MUZZLEFLASH",
	"EF_BRIGHTLIGHT",
	"EF_DIMLIGHT",
	"EF_FLAG1",
	"EF_FLAG2",
	"EF_BLUE",
	"EF_RED",
	// Existing Items
	"IT_AXE",
	"IT_SHOTGUN",
	"IT_SUPER_SHOTGUN",
	"IT_NAILGUN",
	"IT_SUPER_NAILGUN",
	"IT_GRENADE_LAUNCHER",
	"IT_ROCKET_LAUNCHER",
	"IT_LIGHTNING",
	"IT_EXTRA_WEAPON",
	"IT_SHELLS",
	"IT_NAILS",
	"IT_ROCKETS",
	"IT_CELLS",
	"IT_ARMOR1",
	"IT_ARMOR2",
	"IT_ARMOR3",
	"IT_SUPERHEALTH",
	"IT_KEY1",
	"IT_KEY2",
	"IT_INVISIBILITY",
	"IT_INVULNERABILITY",
	"IT_SUIT",
	"IT_QUAD",
	// Behavior of solid objects
	"SOLID_NOT",
	"SOLID_TRIGGER",
	"SOLID_BBOX",
	"SOLID_SLIDEBOX",
	"SOLID_BSP",
	// Type of movements
	"MOVETYPE_NONE",
	"MOVETYPE_ANGLENOCLIP",
	"MOVETYPE_ANGLECLIP",
	"MOVETYPE_WALK",
	"MOVETYPE_STEP",
	"MOVETYPE_FLY",
	"MOVETYPE_TOSS",
	"MOVETYPE_PUSH",
	"MOVETYPE_NOCLIP",
	"MOVETYPE_FLYMISSILE",
	"MOVETYPE_BOUNCE",
	"MOVETYPE_BOUNCEMISSILE",
	// Entity can solid take damage
	"DAMAGE_NO",
	"DAMAGE_YES",
	"DAMAGE_AIM",
	// Entity dead flag
	"DEAD_NO",
	"DEAD_DYING",
	"DEAD_DEAD",
	"DEAD_RESPAWNABLE",
	// Spawnflags
	"DOOR_START_OPEN",
	"SPAWN_CRUCIFIED",
	"PLAT_LOW_TRIGGER",
	"SPAWNFLAG_NOTOUCH",
	"SPAWNFLAG_NOMESSAGE",
	"PLAYER_ONLY",
	"SPAWNFLAG_SUPERSPIKE",
	"SECRET_OPEN_ONCE",
	"PUSH_ONCE",
	"WEAPON_SHOTGUN",
	"H_ROTTEN",
	"WEAPON_BIG2",
	"START_OFF",
	"SILENT",
	"SPAWNFLAG_LASER",
	"SECRET_1ST_LEFT",
	"WEAPON_ROCKET",
	"H_MEGA",
	"DOOR_DONT_LINK",
	"SECRET_1ST_DOWN",
	"WEAPON_SPIKES",
	"DOOR_GOLD_KEY",
	"SECRET_NO_SHOOT",
	"WEAPON_BIG",
	"DOOR_SILVER_KEY",
	"SECRET_YES_SHOOT",
	"DOOR_TOGGLE",
	"FL_FLY",
	"FL_SWIM",
	"FL_CLIENT",
	"FL_INWATER",
	"FL_MONSTER",
	"FL_GODMODE",
	"FL_NOTARGET",
	"FL_ITEM",
	"FL_ONGROUND",
	"FL_PARTIALGROUND",
	"FL_WATERJUMP",
	"FL_JUMPRELEASED",
	// Network Protocol
	"MSG_BROADCAST",
	"MSG_ONE",
	"MSG_ALL",
	"MSG_INIT",
	"MSG_MULTICAST",
	"PRINT_LOW",
	"PRINT_MEDIUM",
	"PRINT_HIGH",
	"PRINT_CHAT",
	"MULTICAST_ALL",
	"MULTICAST_PHS",
	"MULTICAST_PVS",
	"MULTICAST_ALL_R",
	"MULTICAST_PHS_R",
	"MULTICAST_PVS_R",
	"SVC_SETVIEWPORT",
	"SVC_SETANGLES",
	"SVC_TEMPENTITY",
	"SVC_KILLEDMONSTER",
	"SVC_FOUNDSECRET",
	"SVC_INTERMISSION",
	"SVC_FINALE",
	"SVC_CDTRACK",
	"SVC_SELLSCREEN",
	"SVC_UPDATE",
	"SVC_SMALLKICK",
	"SVC_BIGKICK",
	"SVC_MUZZLEFLASH",
	"TRUE",
	"FALSE",
	"RANGE_MELEE",
	"RANGE_NEAR",
	"RANGE_MID",
	"RANGE_FAR",
	"STATE_TOP",
	"STATE_BOTTOM",
	"STATE_UP",
	"STATE_DOWN",
	"VEC_ORIGIN",
	"VEC_HULL_MIN",
	"VEC_HULL_MAX",
	"VEC_HULL2_MIN",
	"VEC_HULL2_MAX",
	"UPDATE_GENERAL",
	"UPDATE_STATIC",
	"UPDATE_BINARY",
	"UPDATE_TEMP",
	"AS_STRAIGHT",
	"AS_SLIDING",
	"AS_MELEE",
	"AS_MISSILE",
	NULL
};


//--------------------------------------------------------------//

FILE* inf;
FILE* outf;

char* memfile; // This will point to the current file placed in memory
char* targetmem; // points to the memory containing the processed data

// This will contain the size of the file currently open
unsigned int fsize;
unsigned int targetmempos;
unsigned int targetmemsize;

unsigned int filecount; // counter for files included from current source code
char curfile[MAX_ST_SIZE]; // filename of current file

int flinescount; // file lines count
int glinescount; // global number of lines count

bool we_r_parsing; // Current parsing status
bool we_r_bcomented; // Are we comented out with /* */ block?
bool we_r_lcomented; // The line we r currently processing is comented with //

unsigned int q_filepos; // our current position on the file queue to be processed
unsigned int q_filenum; // the number of files on queue

struct fileitem
{
	char filename[MAX_ST_SIZE]; // name of the file
	char invoked_by[MAX_ST_SIZE]; // filename of the file where this one was included
	int on_line; // line where it was invoked
	bool compile; // should we compile this file?
};
fileitem* filequeue[MAX_FILE_QUEUE]; // array of pointers to our queue of files to process

unsigned int q_parsepos; // our current position on the parsing queue
unsigned int q_parsenum; // the number of items on queue

struct parseitem
{
	bool causes_parse; // the condition on this #IFDEF or #IFNDEF caused parsing? (excludes code?)
	bool type; // it was an IFNDEF or IFDEF?
	bool inversed; // are we in 'inversed' status after an ELSE ?
	int on_line; // where this parsing condition occured on source code?
};
parseitem* parsequeue[MAX_PARSE_QUEUE]; // array of pointers to our parse queue

unsigned int gdefscount; // global defines counter
unsigned int fdefscount; // file defines counter

unsigned int gbytesread;
unsigned int gbyteswritten;

struct defineitem
{
	char identifier[MAX_ST_SIZE]; // name of the define
	bool is_defined; // if false, this define identifier was 'undefined' so we should ignore it
	char value[MAX_ST_SIZE]; // the current value assigned to this define (string even for floats)
	bool is_used; // flag to determine if this define is ever used on code
	char defined_by[MAX_ST_SIZE]; // filename where it was defined
	int on_line; // line of quakeC code where this value was defined
};
defineitem* deflist[MAX_DEFINES]; // pointer to out define list array

// Pragma variables
// Preprocessor settings vars
bool check_redefines;
bool keep_newlines;
bool keep_comments;
bool check_unused;

//char progs_src[MAX_ST_SIZE];
//char progs_dat[MAX_ST_SIZE];

// Scanning status
int scan_status;
unsigned int scan_offset;

int curkeywtype;
int curpragmatype;

unsigned int bytesread;

char curident[MAX_ST_SIZE]; // tmpident
char curvalue[MAX_ST_SIZE];

bool quote_state;

int parse_stack;

// Time Stats
unsigned long startticks;

bool fastmode;

//=========================================================================
// Main program function

int main(int argc, char **argv)
{
	// Get current tick for stats
	// PZ: TODO Need GNU replacement
	//startticks = GetTickCount();
		
	// Initialize stuff
	char tstr[32]; // Temp string

	fastmode = false;

	// Get fast mode from command line
	if (argc > 1)
	{
		strncpy(tstr,argv[1],31);
		tstr[31]='\0';
		
		if (strcmpi(tstr," -fast"))
			fastmode = true;
	}

	gdefscount = 0;
	fdefscount = 0;

	we_r_parsing = false;
	we_r_lcomented = false;
	we_r_bcomented = false;

	glinescount = 0;
	flinescount = 0;

	curfile[0] = '\0';

	memfile = NULL;
	targetmem = NULL;

	check_redefines = true;
	keep_newlines = true;
	check_unused = true;

	gbytesread = 0;
	gbyteswritten = 0;

	// Init our file queue array pointers to NULL
	for (int i = 0; i < MAX_FILE_QUEUE; i++)
		filequeue[i] = NULL;
	// Init to NULL parse queue array pointers
	for (int i = 0; i < MAX_PARSE_QUEUE; i++)
		parsequeue[i] = NULL;
	// Init to NULL pointers to defines
	for (int i = 0; i < MAX_DEFINES; i++)
		deflist[i] = NULL;

	q_parsepos = 0;
	q_parsenum = 0;

	q_filepos = 0;
	q_filenum = 0;

	scan_status = SCN_STATUS_IDLE;
	// done - stuff ready

	// Start-initialize message
	PrintIt(ST_START);

	// Put 'preprogs' on queue of files to process
	// PZ: allocate the string given to PutFileInQueue() because this string
	// will need to be modified by CleanStr().
	char preprogs[] = ST_PREPROGS_SRC;
	PutFileInQueue(preprogs);
	
	//---------- FILE CYCLING LOOP -----------------//
	for (unsigned int f=0; f<q_filenum; f++)
	{
		// Set current file string
		strcpy(curfile,filequeue[q_filepos]->filename);

		// open the input file
		inf = fopen(curfile, "rb");
		// If failed to open, exit
		if (!inf)
		{
			if (q_filepos == 0)
				ErrorExit("Can't open 'preprogs.src' file!\n");
			else
			{
				char tempstr[MAX_ST_SIZE+21];
				tempstr[0] = '\0';
				strcat(tempstr,"Can't open '");
				strcat(tempstr,curfile);
				strcat(tempstr,"' file!");
				PrintSourceError(filequeue[q_filepos]->invoked_by,
					filequeue[q_filepos]->on_line,
					tempstr);
			}
		}

		// Get file size
		fseek(inf, 0, SEEK_END);
		fsize = ftell(inf);
		fseek(inf, 0, SEEK_SET);

		// Check if memory pointers are clean
		if (memfile != NULL || targetmem != NULL)
			ErrorExit("Memory error!\n");

		// Allocate memory for source and output file
		memfile = (char*)malloc(fsize + 2);
		targetmem = (char*)malloc(fsize + 2); // Expanded with realloc by MAX_ST_SIZE byte increments if needed
		if (memfile == NULL || targetmem == NULL)
			ErrorExit("Failed memory allocation!\n");
		
		// LOAD FILE
		if (!fread(memfile, 1, fsize, inf))
		{
			if (q_filepos == 0)
				ErrorExit("Can't load 'preprogs.src' file!\n");
			else
			{
				char tempstr[MAX_ST_SIZE+21];
				tempstr[0] = '\0';
				strcat(tempstr,"Can't load '");
				strcat(tempstr,curfile);
				strcat(tempstr,"' file!");
				PrintSourceError(filequeue[q_filepos]->invoked_by,
					 filequeue[q_filepos]->on_line,
					 tempstr);
			}
		}

		// display load message		
		if (fastmode)
		{
			PrintIt("parsing ");
			PrintIt(curfile);
			PrintIt("\n");;
		}
		else
		{			
			PrintIt(curfile);
			sprintf(tstr,"%d",fsize);
			PrintIt(" (");
			PrintIt(tstr);
			PrintIt(" bytes) loaded.\n");
		}

		memfile[fsize] = '\r';
		memfile[fsize+1] = '\n';
		fsize += 2;

		// Increase bytes read var
		gbytesread += fsize;

		// Prepare vars
		targetmemsize = fsize;
		targetmempos = 0; // our pos on the output memory stream to be the final file
		scan_status = SCN_STATUS_IDLE;
		scan_offset = 0;
		curkeywtype = 0;
		curpragmatype = 0;
		flinescount = 0;
		fdefscount = 0;
		filecount = 0;
		we_r_parsing = false;
		we_r_lcomented = false;
		we_r_bcomented = false;
		quote_state = false;
		parse_stack = 0;

		// do it jimmy!
		ProcessFile();

		// Perform cycle cleanup
		if (memfile != NULL)
		{
			free(memfile);
			memfile = NULL;
		}

		// Close file
		fclose(inf);

		// display message
		if (q_filepos == 0)
		{
			PrintIt("Pre-progs source (");
			sprintf(tstr,"%d",q_filenum);
			PrintIt(tstr);
			PrintIt(" queued files) processed.\n");
		}
		else
		{
			if (!filequeue[q_filepos]->compile)
			{
				// display processed message
				if (fastmode)
				{
					;//PrintIt(" done.\n");
				}
				else
				{
					sprintf(tstr,"%d",targetmempos);
					PrintIt(curfile);

					PrintIt(" (");
					PrintIt(tstr);
					PrintIt(" bytes) processed. ");

					sprintf(tstr,"%d",fdefscount);
					PrintIt(tstr);
					PrintIt(" defines, ");

					sprintf(tstr,"%d",flinescount+1);
					PrintIt(tstr);
					PrintIt(" lines.\n");
				}
			}
			else
			{
				ChangeFilename(curfile);

				outf = fopen(curfile, "wb");
				// If failed to open, exit
				if (!outf)
				{
					if (q_filepos == 0)
						ErrorExit("Can't create/open 'preprogs.src'!\n");
					else
					{
						char tempstr[MAX_ST_SIZE+21];
						tempstr[0] = '\0';
						strcat(tempstr,"Failed writing to file, '");
						strcat(tempstr,curfile);
						strcat(tempstr,"'!");
						PrintSourceError(filequeue[q_filepos]->invoked_by,
								filequeue[q_filepos]->on_line,
								tempstr);
					}
				}

				// WRITE FILE
				if (!fwrite(targetmem, 1, targetmempos, outf))
				{
					if (q_filepos == 0)
						ErrorExit("Can't write 'preprogs.src' file!\n");
					else
					{
						char tempstr[MAX_ST_SIZE+21];
						tempstr[0] = '\0';
						strcat(tempstr,"Can't write '");
						strcat(tempstr,curfile);
						strcat(tempstr,"' file!");
						PrintSourceError(filequeue[q_filepos]->invoked_by,
								filequeue[q_filepos]->on_line,
								tempstr);
					}
				}

				// Close file
				fclose(outf);

				// display written message
				if (fastmode)
				{
					;
				}
				else
				{
					PrintIt(curfile);

					sprintf(tstr,"%d",targetmempos);
					PrintIt(" (");
					PrintIt(tstr);
					PrintIt(" bytes) written. ");

					sprintf(tstr,"%d",fdefscount);
					PrintIt(tstr);
					PrintIt(" defines, ");

					sprintf(tstr,"%d",flinescount+1);
					PrintIt(tstr);
					PrintIt(" lines.\n");
				}

				gbyteswritten += targetmempos;
			}

		}

		// Clean targetmem
		if (targetmem != NULL)
		{
			free(targetmem);
			targetmem = NULL;
		}

		q_filepos++;
	}
	//------ END OF FILE CYCLING LOOP -------//

	// If enabled, check unused stuff
	if (check_unused)
		CheckUnused();

	// Print global stats
	PrintIt("------------ Preprocessor Results --------------\n");
	sprintf(tstr,"%d",gdefscount);
	PrintIt(tstr);
	PrintIt(" defines, ");
	sprintf(tstr,"%d",glinescount);
	PrintIt(tstr);
	PrintIt(" lines of code in ");
	sprintf(tstr,"%d",q_filenum);
	PrintIt(tstr);
	PrintIt(" files.\n");

	// Bytes read/written stats
	// PZ: fixed string overflow here that was causing a crash
	char temp[128];
	sprintf(temp, "%d bytes read and %d bytes written.\n", gbytesread, gbyteswritten);
	PrintIt(temp);

	// Write progs.src
	outf = fopen("progs.src", "wb");

	// If failed to open, exit
	if (!outf)
		ErrorExit("Can't open/create 'progs.src' for writing!\n");

	// Writing PROGS.SRC !!
	PrintIt("Writing \"progs.src\" ...\n");

	// First line. Target progs filename
	PrintFile(outf, "../prozac.dat\n");

	int g;
	g = 0;
	for (int f = 1; f < q_filenum; f++)
	{
		if (filequeue[f]->compile)
		{
			ChangeFilename(filequeue[f]->filename);
			CleanStr(filequeue[f]->filename);
			PrintFile(outf, filequeue[f]->filename);
			PrintFile(outf, "\n");
			g++;
		}
	}

	PrintIt("progs.src (");
	sprintf(tstr,"%d",g);
	PrintIt(tstr);
	PrintIt(" files included) written.\n");

	// Close file
	fclose(outf);

	// Get time elapsed
	// PZ: TODO Need GNU replacement
	//unsigned long endtime = GetTickCount();
	
	//..and print it
	// PZ: Need GNU replacement
	//PrintIt("Time elapsed: ");
	//sprintf(tstr,"%.1f",float(endtime - startticks) /1000);
	//PrintIt(tstr);
	//PrintIt(" seconds.\n------------------------------------------------\n");
	PrintIt("------------------------------------------------\n");

	// Hopefully all is ok and job done... //
	if (!fastmode)
		PrintIt(ST_SUCCESS);

	PerformCleanUp();

	return 0;
}

//=================================================================================
// Char-by-char loop for processing files - File already loaded and prepared here

void ProcessFile()
{
	unsigned int k;
	unsigned int i;

	// Process LOOP for each file
	for (i=0; i<fsize; i++)
	{
		if (scan_status==SCN_STATUS_IDLE) // idle status, anything may come in
		{
			switch (memfile[i])
			{
				case '/':

					if (i>0) // not on first char..
					{
						if (memfile[i-1]=='/') // and this is the second '/'..
							we_r_lcomented = true; // we are comented out for this line
						else if (memfile[i-1]=='*')
							we_r_bcomented = false; // we r not block comented anymore
					}

					break;

				case '*':

					if (i>0) // not on first char..
						if (memfile[i-1]=='/' && !we_r_lcomented) 
							// we r not block comented and it was preceeded by a '/'
							we_r_bcomented = true; // we are comented out for this line

					break;

				case '"':

					if (!we_r_lcomented && !we_r_bcomented && !we_r_parsing)
						quote_state = !quote_state;

					break;

				case '#':

					if (!we_r_lcomented && !we_r_bcomented) // if we arent comented out currently..
					{
						if (i+1 < fsize)
						{
							if (memfile[i+1]>=0x30 && memfile[i+1]<=0x39)
							{
								; // its a built-in declaration, do nothing
							}
							else
							{
								scan_status = SCN_STATUS_KEYWORD; // change mode --->
								scan_offset = i + 1; // <----> save pos
							}
						}
					}

					break;
			}
		}
		else if (scan_status == SCN_STATUS_KEYWORD) // expecting a keyword or define identifier
		{
			switch (memfile[i])
			{
				case '!':
				case '*':
				case '+':
				case '-':
				case '=':
				case ')':
				case '(':
				case '/':
				case '.':
				case ',':
				case '<':
				case '>':
				case '{':
				case '}':
				case '"':
				case '&':
				case '|':
				case ';': // separators, GET KEYWORD, if the directive wants data, return an ERROR

					if (scan_offset == i) // Empty keyword error
						PrintSourceError(curfile,flinescount,"#..? Directive or identifier expected.");

					curkeywtype = GetKeywordType(i);

					if (DirectiveWantsData(curkeywtype))
						PrintSourceError(curfile,flinescount,
								"Illegal separator use in directive or identifier.");

					ExecuteDirective(i);                    
					break;

				case ' ': // Space or tab char, special separators
				case 0x09: // GET KEYWORD, SET NEW STATUS

					if (scan_offset == i) // Empty keyword error
						PrintSourceError(curfile,flinescount,"#..? Directive or identifier expected.");

					curkeywtype = GetKeywordType(i);

					ExecuteDirective(i); // UPDATES GLOBALS, STATUS, AND APPLY CHANGES (reads curkeywtype var)
					break;

				case 0x0D:
				case 0x0A: // GET KEYWORD, IF VALUE NEEDED, RETURN ERROR

					if (scan_offset == i) // Empty keyword error
						PrintSourceError(curfile,flinescount,"#..? Directive or identifier expected.");

					curkeywtype = GetKeywordType(i);

					if (DirectiveWantsData(curkeywtype))
						PrintSourceError(curfile,flinescount,"Unexpected end of line.");

					ExecuteDirective(i);
					break;

				case '#':

					if (scan_offset == i) // consecutive #?
					{
						PrintSourceWarning(curfile,flinescount,"Consecutive '#'s. (results in a single char)");
						scan_status = SCN_STATUS_IDLE;
					}
					else
						PrintSourceError(curfile,flinescount,"Invalid '#' char inside keyword.");

					break;
			}
		}
		else if (scan_status == SCN_STATUS_PRAGMA) // expecting a pragma identifier
		{
			switch (memfile[i])
			{
				case '!':
				case '*':
				case '+':
				case '-':
				case '=':
				case ')':
				case '(':
				case '/':
				case '.':
				case ',':
				case '<':
				case '>':
				case '{':
				case '}':
				case '"':
				case '&':
				case '|':
				case ';': // separators, illegal expecting a pragma, return an ERROR

					PrintSourceError(curfile,flinescount,"Pragma identifier expected.");
					break;

				case ' ': // Space or tab char, legal
				case 0x09: // GET KEYWORD, SET NEW STATUS

					curpragmatype = GetPragmaType(i);

					// Unsupported pragma?
					if (curpragmatype == 0)
						PrintSourceError(curfile,flinescount,"Unknown/Unsupported pragma.");

					if (curpragmatype != PRAGMA_EMPTYSTILL) // if pragma wasnt empty..
						ExecutePragma(i); // UPDATES GLOBALS, STATUS, AND APPLY CHANGES (reads curkeywtype var)

					break;

				case 0x0D:
				case 0x0A: // GET KEYWORD, IF VALUE NEEDED, RETURN ERROR

					if (scan_offset == i) // end of line just before PRAGMA
						PrintSourceError(curfile,flinescount,"Pragma identifier expected.");

					curpragmatype = GetPragmaType(i);

					// Unsupported pragma?
					if (curpragmatype == 0)
						PrintSourceError(curfile,flinescount,"Unknown/Unsupported pragma.");

					if (curpragmatype != -1) // if pragma wasnt empty..
						ExecutePragma(i); // UPDATES GLOBALS, STATUS, AND APPLY CHANGES (reads curkeywtype var)

					break;

				case '#':

					PrintSourceError(curfile,flinescount,"Invalid '#' char, pragma identifier expected.");
					break;
			}
		}
		else if (scan_status == SCN_STATUS_VALUE) // watching for data for define, parse quotes? nope..
		{
			if (i - scan_offset > MAX_ST_SIZE - 1)
				PrintSourceError(curfile,flinescount,"Value exceeds string char max (255)");

			switch (memfile[i])
			{
				case 0x0D:
				case 0x0A:

					// Get current value string
					for (k = 0; k < (i - scan_offset); k++)
						curvalue[k] = memfile[scan_offset + k];

					if (IsNotEmpty(curvalue)!=0)
						PutDefineInList(curident,curvalue);
					else // Use a default value for our define, as VALUE is empty
						PutDefineInList(curident,"1\0");

					scan_status = SCN_STATUS_IDLE;
					break;
			}
		}
		else if (scan_status == SCN_STATUS_LIST) // we r inside an include list
		{
			if (i - scan_offset > MAX_ST_SIZE - 1)
				PrintSourceError(curfile,flinescount,"Filename string exceeds char max (255)");

			switch (memfile[i])
			{
				case 0x0D:
				case 0x0A:

					// Get current filename string
					for (k = 0; k < (i - scan_offset); k++)
						curvalue[k] = memfile[scan_offset + k];

					if (IsNotEmpty(curvalue)!=0)
					{
						PutFileInQueue(curvalue);
					}

					scan_offset = i + 1;
					memset(curvalue,0,MAX_ST_SIZE);

					break;

				case '#':

					// Check for end of list
					if (IsValidEndList(i))
					{
						i = i + 7; // update our pos, as we dont want ENDLIST to be written on output file
						scan_status = SCN_STATUS_IDLE;
					}
					else
						PrintSourceError(curfile,flinescount,"Directives not supported inside INCLUDELIST.");

					break;
			}
		}
		else if (scan_status == SCN_STATUS_DEFINE) 
		// waiting a define identifier for a DEFINE, UNDEF, IFDEF, IFNDEF
		{
			if (i - scan_offset > MAX_ST_SIZE - 1)
				PrintSourceError(curfile,flinescount,"Identifier exceeds string char max (255)");

			switch (memfile[i])
			{
				case 0x0D:
				case 0x0A:

					if (scan_offset == i) // end of line just before keyword
						PrintSourceError(curfile,flinescount,"Define identifier expected.");

					// Get current identifier string
					for (k = 0; k < (i - scan_offset); k++)
						curident[k] = memfile[scan_offset + k];

					if (IsNotEmpty(curident)!=0)
					{
						CleanStr(curident);

						int numdefine = IsDefined(curident);

						char temp[] = "1\0"; // PZ

						switch (curkeywtype)
						{
							case DIRECTIVE_IFDEF:

								// Add our new parsing item to queue
								if (numdefine == 0) // not defined
									PutParseInQueue(PARSE_IFDEF, true);
								else // defined
								{
									PutParseInQueue(PARSE_IFDEF, false);
									deflist[numdefine -1]->is_used = true;
								}

								scan_status = SCN_STATUS_IDLE;

								break;

							case DIRECTIVE_IFNDEF:

								// Add our new parsing item to queue
								if (numdefine == 0) // not defined
									PutParseInQueue(PARSE_IFNDEF, false);
								else // defined
								{
									PutParseInQueue(PARSE_IFNDEF, true);
									deflist[numdefine -1]->is_used = true;
								}

								scan_status = SCN_STATUS_IDLE;

								break;

							case DIRECTIVE_UNDEF:

								if (numdefine == 0) // not defined
									PrintSourceWarning(curfile,flinescount,"Nothing to undefine, not defined.");
								else // defined
									UndefineItem(numdefine);

								scan_status = SCN_STATUS_IDLE;

								break;

							case DIRECTIVE_DEFINE:

								// Add our new define with a "1" default value
								// PZ: allocate the 2nd string given to PutDefineInList() because this string
								// will need to be modified by CleanStr().
								PutDefineInList(curident, temp);
								scan_status = SCN_STATUS_IDLE;
								break;

								default:

								ErrorExit("Invalid 'curkeywtype' in processfile() function!\n");
						}

						scan_status = SCN_STATUS_IDLE;
					}
					else // end of line and empty identifier
						PrintSourceError(curfile,flinescount,"Define identifier expected.");

					break;

				case 0x09:
				case ' ':

					// Get current identifier string
					for (k = 0; k < (i - scan_offset); k++)
						curident[k] = memfile[scan_offset + k];

					if (IsNotEmpty(curident)!=0)
					{
						CleanStr(curident);

						int numdefine = IsDefined(curident);

						switch (curkeywtype)
						{
							case DIRECTIVE_IFDEF:

								// Add our new parsing item to queue
								if (numdefine == 0) // not defined
									PutParseInQueue(PARSE_IFDEF, true);
								else // defined
								{
									PutParseInQueue(PARSE_IFDEF, false);
									deflist[numdefine -1]->is_used = true;
								}

								scan_status = SCN_STATUS_IDLE;
								break;

							case DIRECTIVE_IFNDEF:

								// Add our new parsing item to queue
								if (numdefine == 0) // not defined
									PutParseInQueue(PARSE_IFNDEF, false);
								else // defined
								{
									PutParseInQueue(PARSE_IFNDEF, true);
									deflist[numdefine -1]->is_used = true;
								}

								scan_status = SCN_STATUS_IDLE;
								break;

							case DIRECTIVE_UNDEF:

								if (numdefine == 0) // not defined
									PrintSourceWarning(curfile,flinescount,"Nothing to undefine, not defined.");
								else // defined
									UndefineItem(numdefine);

								scan_status = SCN_STATUS_IDLE;
								break;

							case DIRECTIVE_DEFINE:

								scan_status = SCN_STATUS_VALUE; // we need the value string
								memset(curvalue,0,MAX_ST_SIZE);
								scan_offset = i + 1;

								break;

							default:

								ErrorExit("Invalid 'curkeywtype' in processfile() function!\n");
						}
					}
			}
		}

		if ((scan_status == SCN_STATUS_IDLE && !we_r_parsing) || // If we r in idle status and not parsing
			(memfile[i]==0x0A || memfile[i]==0x0D)) // or it is a line break, and keepnewlines pragma is on..
		{
			WriteOutChar(memfile[i]);

			if (memfile[i]==0x0D)
			{
				we_r_lcomented = false;
				flinescount++;
			}
			else if (memfile[i]==0x0A)
			{
				we_r_lcomented = false;

				if (i>0) // not on first char..
					if (memfile[i-1]!=0x0D) // only counts a line break if we found a 0x0a first
					{
						flinescount++;
						glinescount++;
					}
			}
		}
	}

	// CHECK FOR ERRORS FINISHING

	//- Parsing error -//
	if (q_parsenum > 0)
	{
		if (parsequeue[q_parsenum-1]->type == PARSE_IFDEF)
			PrintSourceError(curfile,parsequeue[q_parsenum-1]->on_line,"IFDEF without ENDIF");
		else if (parsequeue[q_parsenum-1]->type == PARSE_IFNDEF)
			PrintSourceError(curfile,parsequeue[q_parsenum-1]->on_line,"IFNDEF without ENDIF");
	}

	// If we are inside a list
	if (scan_status == SCN_STATUS_LIST)
		PrintSourceError(curfile,flinescount,"Not found ENDLIST for INCLUDELIST!");

	// Check for quoted state ending
	if (quote_state)
		PrintSourceWarning(curfile,flinescount,"File ends in quote state.");

	// Check for block commented end
	if (we_r_bcomented)
		PrintSourceWarning(curfile,flinescount,"File ends block-commented.");

	// Update global line counter //
	glinescount += flinescount;
}

//======================================================================
// Outputs the byte to the target memory and expands memory if needed

void WriteOutChar(char data)
{
	if (targetmempos >= targetmemsize) // Do we need more memory for output?
		ExpandTargetMem();

	targetmem[targetmempos] = data;
	targetmempos ++;
}

//==============================================
// prints a string to console output

void PrintIt (char* what)
{
	printf(what);
}

//===============================================
// Puts the given text into the current file

void PrintFile (FILE* file, char* what)
{
	fprintf(file, what);
}

//==================================================================
// We've found something to warn about, report to console output

void PrintSourceWarning (char* thefile, int theline, char* what)
{
	if (fastmode) return;
	
	theline++;

	char tempstr[20];
	sprintf(tempstr,"%d",theline);

	PrintIt(thefile);
	PrintIt(":");
	PrintIt(tempstr);
	PrintIt(":WARNING! ");
	PrintIt(what);
	PrintIt("\n");
}

//=======================================================================
// Reports some information on the code

void PrintSourceInfo (char* thefile, int theline, char* what)
{
	if (fastmode) return;
	
	theline++;

	char tempstr[20];
	sprintf(tempstr,"%d",theline);

	PrintIt(thefile);
	PrintIt(":");
	PrintIt(tempstr);
	PrintIt(":INFO ");
	PrintIt(what);
	PrintIt("\n");
}

//===================================================================
// reports an error on the quakeC source code and exit

void PrintSourceError (char* thefile, int theline, char* what)
{
	theline++;

	char tempstr[20];
	sprintf(tempstr,"%d",theline);

	PrintIt(thefile);
	PrintIt(":");
	PrintIt(tempstr);
	PrintIt(":ERROR! ");
	PrintIt(what);
	PrintIt("\n");

	SourceErrorExit(); // Exits the program
}

//===================================================================
// Expands by MAX_ST_SIZE bytes the memory allocated for output file

void ExpandTargetMem()
{
	// we need 128 more as max, as value strings can become 127 chars + NULL
	targetmem = (char*)realloc(targetmem, targetmemsize + MAX_ST_SIZE);

	if (targetmem == NULL)
		ErrorExit("Error expanding memory for output file!\n");

	targetmemsize = targetmemsize + MAX_ST_SIZE;
}

//===========================================================================
// reports a program error and exits the program with 2 errorlevel

void ErrorExit(char *msg)
{
	PrintIt("PROGRAM ERROR! ");
	PrintIt(msg);
	PerformCleanUp();
	exit(2);
}

//==================================================================
// Exit program, error in quakeC source code found

void SourceErrorExit()
{
	PrintIt("Can't continue, error found.\n");
	PerformCleanUp();
	exit(1);
}

//============================================================
// performs clean up tasks b4 exit program

void PerformCleanUp ()
{
	unsigned int i;

	// file clean-up?
	if (inf)  fclose(inf);
	if (outf) fclose(outf);

	// Is our file buffer clean?
	if (memfile != NULL)
		free(memfile);
	if (targetmem != NULL)
		free(targetmem);

	// Free our file queue items
	for (i = 0; i < MAX_FILE_QUEUE && i < q_filenum; i++)
	{
		if (filequeue[i]!=NULL)
			delete filequeue[i];
	}

	// Free our parse queue items
	for (i = 0; i < MAX_PARSE_QUEUE && i < q_parsenum; i++)
	{
		if (parsequeue[i]!=NULL)
			delete parsequeue[i];
	}

	// Free our define list
	for (i = 0; i < MAX_DEFINES && i < gdefscount; i++)
	{
		if (deflist[i]!=NULL)
			delete deflist[i];
	}
}

//=================================================================
// adds a filename to the queue of files to process

void PutFileInQueue(char *fname)
{
	// Clean filename to add
	CleanStr(fname);

	// Is this file already on queue?
	bool alreadyin = false;

	// Search for this file in queue
	for (unsigned int s=0; s < q_filenum; s++)
	{
		if (strcmp(fname,filequeue[s]->filename)==0)
			alreadyin = true;
	}

	// Report warning, and exit function, if file was in queue
	if (alreadyin)
	{
		char tmpstr[MAX_ST_SIZE+28];
		memset(tmpstr,0,MAX_ST_SIZE+28);
		strcat(tmpstr,"Attempt to add \"");
		strcat(tmpstr,fname);
		strcat(tmpstr,"\" to file queue again!");
		PrintSourceWarning(curfile,flinescount,tmpstr);
		return;
	}

	// Create new item
	filequeue[q_filenum] = new fileitem;

	// check for memory error..
	if (filequeue[q_filenum] == NULL)
		ErrorExit("Memory error on 'PutFileInQueue()' function!\n");

	// set all string field chars to NULL
	for (int i = 0; i < MAX_ST_SIZE; i++)
	{
		filequeue[q_filenum]->filename[i] = '\0';
		filequeue[q_filenum]->invoked_by[i] = '\0';
	}

	// apply fields
	strcpy(filequeue[q_filenum]->filename, fname);
	strcpy(filequeue[q_filenum]->invoked_by, curfile); // current file beeing processed
	filequeue[q_filenum]->on_line = flinescount; // current line beeing processed
	filequeue[q_filenum]->compile = true;
	// item ready

	q_filenum++; // we added a file to the queue!
	filecount++; // files added from the current source file

	if (q_filenum >= MAX_FILE_QUEUE) // we reached max?
		ErrorExit("Maximum file queue reached! (256 files max)\n");

}

//=================================================================
// adds a new define item to the list of defines

void PutDefineInList(char* ident, char* value)
{
	// clean up strings
	CleanStr(ident);
	CleanStr(value);

	// Check for redefines
	defineitem* theitem;
	int numdefine = IsInDefList(ident); // is it in defines list? (even if udefined)

	if (numdefine == 0) // Not defined, we need a new one
	{
		deflist[gdefscount] = new defineitem; // Allocate our new item in memory
		theitem = deflist[gdefscount];

		//set our initial define state
		memset(theitem->defined_by,0,MAX_ST_SIZE);
		strcpy(theitem->defined_by,curfile);
		theitem->is_used = false;
		theitem->on_line = flinescount;

		gdefscount++; // we added an IFDEF or IFNDEF to the parse queue!
	}
	else
	{   // we got a match, make the pointer go for it
		theitem = deflist[numdefine - 1]; // IsDefined does a return++

		// report redefinition warning, if enabled
		if (check_redefines)
			PrintSourceWarning(curfile,flinescount,"Value for identifier redefined.");
	}

	// check for memory error or wrong pointer..
	if (theitem == NULL)
		ErrorExit("Memory error or wrong pointer operation on 'PutDefineInList()' function!\n");

	// set all string field chars to NULL
	for (unsigned int l = 0; l < MAX_ST_SIZE; l++)
	{
		theitem->value[l] = '\0';
		theitem->identifier[l] = '\0';
	}

	ParseValue(value);

	// apply fields
	theitem->is_defined = true;
	strcpy(theitem->identifier,ident);
	strcpy(theitem->value,value);
	// item ready    

	if (gdefscount >= MAX_DEFINES)
		ErrorExit("Max number of defines reached!");

	fdefscount++; // increase file defs counter too!
}

//======================================================================================
// Marks as undefined an item on the defines list, returns false if not successfull

void UndefineItem(unsigned int numdefine)
{
	numdefine--; // compensate IsDefined return++;

	if (numdefine >= gdefscount)
		ErrorExit("Define location is beyond array in 'undefineItem()' function.\n");

	if (deflist[numdefine]->is_defined == false)
		PrintSourceWarning(curfile,flinescount,"Already undefined.");

	deflist[numdefine]->is_defined = false;

	deflist[numdefine]->is_used = true; // TODO: make this better
}

//=================================================================
// adds a new parse item to the queue

void PutParseInQueue(bool type, bool causes_parse)
{
	parsequeue[q_parsenum] = new parseitem;

	// check for memory error..
	if (parsequeue[q_parsenum] == NULL)
		ErrorExit("Memory error on 'PutParseInQueue()' function!\n");

	// apply fields
	parsequeue[q_parsenum]->type = type; // IFDEF or IFNDEF (for error reporting purposses only)
	parsequeue[q_parsenum]->causes_parse = causes_parse; // does it make to exclude source code?
	parsequeue[q_parsenum]->inversed = false; // this is set to TRUE if an ELSE is found
	parsequeue[q_parsenum]->on_line = flinescount; // current line beeing processed
	// item ready

	q_parsenum++; // we added an IFDEF or IFNDEF to the parse queue!

	if (q_parsenum >= MAX_PARSE_QUEUE) // we reached max?
		PrintSourceError(curfile,flinescount,
				"Maximum parse depht reached! (16 consecutive IFDEF/IFNDEF's max)");

	// Update globals for parsing here
	we_r_parsing = causes_parse; // DONE?
}

//===================================================================================================
// We've just found an ELSE, so we need to inverse parsing globals and update parse queue

void InvertParseItem()
{
	// Check errors
	if (q_parsenum <= 0) // ELSE without an IFDEF or IFNDEF?
		PrintSourceError(curfile,flinescount,"ELSE without IFDEF/IFNDEF");

	if (parsequeue[q_parsenum - 1]->inversed == true) // already inversed (DOUBLE ELSE)
		PrintSourceError(curfile,flinescount,"Consecutive ELSE");

	// Ok, update status and queue item..
	we_r_parsing = !we_r_parsing; // invert current status
	parsequeue[q_parsenum - 1]->inversed = true;
}

//===================================================================================================
// We've just found an ENDIF, we resolved last IFDEF or IFNDEF so we need to update parse queue
// and update parsing globals

void ResolveParseItem()
{
	// Exit on error
	if (q_parsenum < 1)
		PrintSourceError(curfile,flinescount,"ENDIF without IFDEF/IFNDEF");

	if (parsequeue[q_parsenum - 1])
		delete parsequeue[q_parsenum - 1]; // remove from memory
	parsequeue[q_parsenum - 1] = NULL; // resets pointer

	q_parsenum--; // we resolved an IFDEF or IFNDEF from the parse queue!

	if (q_parsenum <= 0) // we are not under any IFDEF or IFNDEF! cool!! :)
	{
		we_r_parsing = false;
	}
	else // we went a step below in our parsing queue
	{
		if (parsequeue[q_parsenum - 1]->inversed) // are we inversed with an ELSE ?
			we_r_parsing = !(parsequeue[q_parsenum - 1]->causes_parse);
		else
			we_r_parsing = parsequeue[q_parsenum - 1]->causes_parse;
	}
}

//========================================================================================================
// Gets type of keyword that correspong to the string marked by the offset on memfile, and size of bytes

int GetKeywordType(int curpos)
{
	if ((curpos - scan_offset) > MAX_ST_SIZE - 1)
		PrintSourceError(curfile,flinescount,"Keyword too long! (max 255 chars)");

	char tkey[MAX_ST_SIZE];
	memset(tkey, 0, MAX_ST_SIZE); // Fill it all with NULL

	// Create the NULL-terminated string, with the supposed keyword in
	for (unsigned int z=0; z < (curpos - scan_offset); z++)
	{
		tkey[z] = memfile[scan_offset + z];
	}

	CleanStr(tkey);

	int type =GetDirectiveType(tkey);

	if (we_r_parsing && type == DIRECTIVE_IDENT)
		return type;

	if (we_r_parsing && type != DIRECTIVE_ENDIF && type != DIRECTIVE_ELSE &&
		type != DIRECTIVE_IFDEF && type != DIRECTIVE_IFNDEF)
	return DIRECTIVE_IDENT;

	if (type != DIRECTIVE_IDENT)
		return type;

	// not a directive...

	// so should be a defined value, lets search for it and write out to output if so
	int numdef = IsDefined(tkey);

	if (numdef == 0) // not on defines list
	{
		char tempstr[MAX_ST_SIZE + 35];
		tempstr[0] = '\0';
		strcat(tempstr,"Unknown identifier, \"");
		strcat(tempstr,tkey);
		strcat(tempstr,"\" not defined!");

		PrintSourceError(curfile,flinescount,tempstr);
	}
	else // its a define, output real value to memtarget
	{
		numdef--; // cause isDefined returns the item + 1

		for (unsigned int z = 0; z < strlen(deflist[numdef]->value); z++)
			WriteOutChar(deflist[numdef]->value[z]);

		// Set the new state on define used
		deflist[numdef]->is_used = true;
	}

	return DIRECTIVE_IDENT;
}

bool DirectiveWantsData(int tkeyw)
{
	switch (tkeyw)
	{
		case DIRECTIVE_IFDEF:
		case DIRECTIVE_IFNDEF:
		case DIRECTIVE_UNDEF:
		case DIRECTIVE_INCLUDE:
		case DIRECTIVE_DEFINE:
		case DIRECTIVE_PRAGMA:

			return true;

		default:

			return false;
	}
}


//========================================================================================================
// Gets type of PRAGMA that correspond to the string marked by the offset on memfile, and size of bytes

int GetPragmaType(int curpos)
{
	if ((curpos - scan_offset) > MAX_ST_SIZE - 1)
		PrintSourceError(curfile,flinescount,"Pragma identifier way too long! (max 255 chars)");

	char tkey[MAX_ST_SIZE];
	memset(tkey, 0, MAX_ST_SIZE); // Fill it all with NULL

	// Create the NULL-terminated string, with the supposed pragma in
	for (unsigned int z=0; z < (curpos - scan_offset); z++)
	{
		tkey[z] = memfile[scan_offset + z];
	}

	// Check if current string is empty still
	if (IsNotEmpty(tkey)==0)
		return PRAGMA_EMPTYSTILL;

	// Clean spaces and tabs between directive and pragma identifier
	CleanStr(tkey);

	//- START STRING COMPARISONS TO GET TYPE OF PRAGMA -//
	if (strlen(tkey) == strlen(ST_PRAGMA_COMPILE))
	{
		if (strcmp(tkey,ST_PRAGMA_COMPILE)==0)
			return PRAGMA_COMPILE;
	}

	if (strlen(tkey) == strlen(ST_PRAGMA_NOCOMPILE))
	{
		if (strcmp(tkey,ST_PRAGMA_NOCOMPILE)==0)
			return PRAGMA_NOCOMPILE;
	}

	if (strlen(tkey) == strlen(ST_PRAGMA_CHECKREDEFS_ON))
	{
		if (strcmp(tkey,ST_PRAGMA_CHECKREDEFS_ON)==0)
			return PRAGMA_CHECKREDEFS_ON;
	}

	if (strlen(tkey) == strlen(ST_PRAGMA_CHECKREDEFS_OFF))
	{
		if (strcmp(tkey,ST_PRAGMA_CHECKREDEFS_OFF)==0)
			return PRAGMA_CHECKREDEFS_OFF;
	}

	if (strlen(tkey) == strlen(ST_PRAGMA_CHECKUNUSED_ON))
	{
		if (strcmp(tkey,ST_PRAGMA_CHECKUNUSED_ON)==0)
			return PRAGMA_CHECKUNUSED_ON;
	}

	if (strlen(tkey) == strlen(ST_PRAGMA_CHECKUNUSED_OFF))
	{
		if (strcmp(tkey,ST_PRAGMA_CHECKUNUSED_OFF)==0)
			return PRAGMA_CHECKUNUSED_OFF;
	}
	
	/*else if (strlen(tkey) == strlen(ST_PRAGMA_PROGSSRC))
	{
	if (memcmp(tkey,ST_PRAGMA_PROGSSRC,strlen(ST_PRAGMA_PROGSSRC) == 0)) // same string
		return PRAGMA_PROGSSRC;
	}
	else if (strlen(tkey) == strlen(ST_PRAGMA_PROGSDAT))
	{
	if (memcmp(tkey,ST_PRAGMA_PROGSDAT,strlen(ST_PRAGMA_PROGSDAT) == 0)) // same string
		return PRAGMA_PROGSDAT;
	} */

	// not a supported pragma...
	return PRAGMA_UNSUPPORTED;
}

/*bool PragmaWantsData(int tkeyw)
{
	switch (tkeyw)
	{
	case PRAGMA_PROGSDAT:
	case PRAGMA_PROGSSRC:

		return true;

	default:

		return false;
	}
}*/

//=========================================================================================
// We've just found a pragma keyword, apply stuff
// changes status, updates globals, add new parse items.. etc.-

void ExecutePragma(int curpos)
{
	switch (curpragmatype)
	{
		// PRAGMAS THAT DOESNT REQUIRE ANY PARAM - THEY DO SOMETHING BY THEIRSELVES //
		case PRAGMA_COMPILE:

			filequeue[q_filepos]->compile=true;
			scan_status = SCN_STATUS_IDLE;
			PrintSourceInfo(curfile,flinescount,"File marked to COMPILE");
			break;

		case PRAGMA_NOCOMPILE:

			filequeue[q_filepos]->compile=false;
			scan_status = SCN_STATUS_IDLE;
			PrintSourceInfo(curfile,flinescount,"File marked to NOT COMPILE");
			break;

		case PRAGMA_CHECKREDEFS_ON:

			check_redefines = true;
			PrintSourceInfo(curfile,flinescount,"Redefinition check is turned ON");
			scan_status = SCN_STATUS_IDLE;
			break;

		case PRAGMA_CHECKREDEFS_OFF:

			check_redefines = false;
			PrintSourceInfo(curfile,flinescount,"Redefinition check is turned OFF");
			scan_status = SCN_STATUS_IDLE;
			break;

		case PRAGMA_CHECKUNUSED_ON:
			
			check_unused = true;
			PrintSourceInfo(curfile,flinescount,"Unused items check is turned ON");
			scan_status = SCN_STATUS_IDLE;
			break;

		case PRAGMA_CHECKUNUSED_OFF:
			
			check_unused = false;
			PrintSourceInfo(curfile,flinescount,"Unused items check is turned OFF");
			scan_status = SCN_STATUS_IDLE;
			break;

		// Require a quoted string (filename)
		//case PRAGMA_PROGSSRC:
		//case PRAGMA_PROGSDAT:

		//    scan_status = SCN_STATUS_VALUE;
		//    break;

		default:

			ErrorExit("Unknown PRAGMA in 'ExecutePragma()' function!\n");
	}
}

//================================================================================
// returns the number of define (+1) in queue array if the string is a current define
// returns 0 if ident was not defined

unsigned int IsDefined(char* ident)
{
	// Clean empty limits on string edges
	CleanStr(ident);

	// Is there any defined values?
	if (gdefscount <= 0)
		return 0;// nope, so.. not defined

	// See all defines for a matching one:
	for (unsigned int d = 0; d < gdefscount; d++)
	{
		if (deflist[d] == NULL)
			; // FIXME: why the fuck this??
		else if (deflist[d]->is_defined) // if we rnt undefined
			if (strcmp(deflist[d]->identifier,ident) == 0) // matches string
				return d + 1;
	}

	return 0;
}

unsigned int IsInDefList(char* ident)
{
	// Clean empty limits on string edges
	CleanStr(ident);

	// Is there any defined values?
	if (gdefscount <= 0)
		return 0;// nope, so.. not defined

	// See all defines for a matching one:
	for (unsigned int d = 0; d < gdefscount; d++)
	{
		if (deflist[d] == NULL)
			; // FIXME:
		else if (strcmp(deflist[d]->identifier,ident) == 0) // matches string
			return d + 1;
	}

	return 0;
}

//=========================================================================================
// We've just found a directive keyword, apply stuff
// changes status, updates globals, add new parse items.. etc.-

void ExecuteDirective(int curpos)
{
	switch (curkeywtype)
	{
		// DIRECTIVES THAT DOESNT REQUIRE ANY PARAM - THEY DO SOMETHING BY THEIRSELVES //
		case DIRECTIVE_ENDIF:

			if (parse_stack > 0)
			{
				parse_stack--;
				scan_status = SCN_STATUS_IDLE;
				return;
			}

			ResolveParseItem();
			scan_status = SCN_STATUS_IDLE;
			break;

		case DIRECTIVE_ELSE:

			if (parse_stack > 0)
			{
				scan_status = SCN_STATUS_IDLE;
				return;
			}

			InvertParseItem();
			scan_status = SCN_STATUS_IDLE;
			break;

		case DIRECTIVE_INCLUDELIST:

			//TODO: Make directives on includelist possible
			/*if (scan_status == SCN_STATUS_LIST)
			PrintSourceError(curfile,flinescount,"Already on a INCLUDELIST!");*/

			PrintSourceInfo(curfile,flinescount,"Include list found");

			scan_status = SCN_STATUS_LIST;
			memset(curvalue,0,MAX_ST_SIZE);
			scan_offset = curpos + 1;
			break;

		case DIRECTIVE_ENDLIST:

			// Error cause endlist is checked in another place
			PrintSourceError(curfile,flinescount,"ENDLIST without INCLUDELIST");
			scan_status = SCN_STATUS_IDLE;
			break;

		// DIRECTIVES THAT REQUIRE SOME KIND OF DATA - UPDATE STATUS //
		case DIRECTIVE_IFDEF:

			if (we_r_parsing)
			{
				parse_stack++;
				scan_status = SCN_STATUS_IDLE;
				return;
			}

			memset(curident,0,MAX_ST_SIZE); // Reset our identifier string
			scan_status = SCN_STATUS_DEFINE;
			scan_offset = curpos + 1;
			break;

		case DIRECTIVE_IFNDEF:

			if (we_r_parsing)
			{
				parse_stack++;
				return;
			}

			memset(curident,0,MAX_ST_SIZE); // Reset our identifier string
			scan_status = SCN_STATUS_DEFINE;
			scan_offset = curpos + 1;
			break;

		case DIRECTIVE_DEFINE:

			memset(curident,0,MAX_ST_SIZE); // Reset our identifier string
			scan_status = SCN_STATUS_DEFINE;
			scan_offset = curpos + 1;
			break;

		case DIRECTIVE_UNDEF:

			memset(curident,0,MAX_ST_SIZE); // Reset our identifier string
			scan_status = SCN_STATUS_DEFINE;
			scan_offset = curpos + 1;
			break;

		/*case DIRECTIVE_INCLUDE:

			memset(tmpident,null);
			scan_status = SCN_STATUS_VALUE;
			scan_offset = curpos + 1;
			break;*/

		case DIRECTIVE_PRAGMA:

			scan_status = SCN_STATUS_PRAGMA;
			scan_offset = curpos + 1;
			break;

		case DIRECTIVE_IDENT:

			// we've just replaced a define, we should restore status
			scan_status = SCN_STATUS_IDLE;
			break;

		default:

			ErrorExit("Unknown directive in 'ExecuteDirective()' function!\n");
	}
}

//======================================================================================
// returns TRUE if char do currently is a separator

bool CharIsSeparator(char tchar)
{
	if (tchar == 0x09) // TAB is a separator too
		return true;
	if (tchar == ' ')
		return true;
	if (tchar == '!')
		return true;
	if (tchar == '*')
		return true;
	if (tchar == '+')
		return true;
	if (tchar == '-')
		return true;
	if (tchar == '=')
		return true;
	if (tchar == ')')
		return true;
	if (tchar == '(')
		return true;
	if (tchar == '/')
		return true;
	if (tchar == ',')
		return true;
	if (tchar == '.')
		return true;
	if (tchar == '>')
		return true;
	if (tchar == '<')
		return true;
	if (tchar == '{')
		return true;
	if (tchar == '}')
		return true;
	if (tchar == '\"')
		return true;

	return false;
}
/*
// new line chars
bool CharIsNewLine(char tchar)
{
	if (tchar == 0x0D || tchar == 0x0A)
		return true;

	return false;
}*/

//======================================================================
// returns the length of string excluding spaces and TAB chars

int IsNotEmpty(char* tstr)
{
	if (strlen(tstr) == 0) return 0;

	int numvalid = 0; // valid chars on string

	for (unsigned int i=0; i < strlen(tstr); i++)
	{
		if (tstr[i]!=' ' && tstr[i]!=0x09 && tstr[i]!=0x0A && tstr[i]!=0x0D)
			numvalid++;
	}

	return numvalid;
}

//==========================================================================
// Cuts the spaces and tabs from the string

void CleanStr(char* tstr)
{
	int len = strlen(tstr);

	if (len <= 0)
		return;

	char tempstr[MAX_ST_SIZE];
	memset(tempstr,0,MAX_ST_SIZE);
	
	unsigned int pos1 = 0;
	unsigned int pos2 = len;
	
	// get starting pos
	while (IsEmptyChar(tstr[pos1]) && pos1 < MAX_ST_SIZE - 1)
		pos1++;
	
	// get final pos
	while ((IsEmptyChar(tstr[pos2]) || tstr[pos2]== '\0') && pos2 > 0)
		pos2--;
	
	// Parse string into limits 
	for (unsigned int a=pos1; a < pos2 + 1; a++)
		tempstr[a - pos1] = tstr[a];
	
	strcpy(tstr,tempstr);
}

//=================================================================================================
// returns true, if the string following the '#' on current scanning pos is an ENDLIST directive

bool IsValidEndList(unsigned int curpos)
{
	// check for errors
	if (curpos + 1 + 7 > fsize) // if check goes beyond file..
		return false;

	char thestr[8];

	// Make the input string on memfile
	for (int i=0; i < 7; i++)
	{
		thestr[i] = memfile[curpos + 1 + i];
	}

	// make it null-terminated
	thestr[7] = '\0';

	// String matches?
	if (strcmp(thestr,ST_DIR_ENDLIST)==0)
		return true;
	else
		return false;
}

//=============================================================================
// returns true if the char should be removed when cleaning a string

bool IsEmptyChar(char tchar)
{
	if (tchar == 0x09 || tchar == 0x0D || tchar == 0x0A || tchar == ' ')
		return true;

	return false;
}

//=======================================================================================
// Arranges our string to put out any comments and translate defines in define values

void ParseValue(char* tvalue)
{
	int wherecomment = 999; // no where

	char finalstr[MAX_ST_SIZE*2];
	memset(finalstr,0,MAX_ST_SIZE*2);

	// find begining of comments
	bool done = false;
	for (int i=0; i < MAX_ST_SIZE - 1 && !done; i++)
	{
		if (tvalue[i]=='/')
			if (tvalue[i+1]=='/')
			{
				wherecomment = i;
				done = true;
			}
	}

	// Remove comments
	for (int i=wherecomment; i < MAX_ST_SIZE; i++)
		tvalue[i] = '\0';

	CleanStr(tvalue);        

	// Replace defines with their value
	for (int i=0; i < MAX_ST_SIZE - 1 && tvalue[i]!='\0'; i++)
	{
		if (tvalue[i]=='#') // found a keyword?
		{
			// get the end of keyword
			int z;
			for (z=i+1; true; z++)
			{
				if (IsEmptyChar(tvalue[z]) != false)
					break;
				if (CharIsSeparator(tvalue[z]) != false)
					break;
				if (tvalue[z]=='\0')
					break;
				if (z >= MAX_ST_SIZE - i -1)
					break;
				if (tvalue[z]=='#')
					PrintSourceError(curfile,flinescount,"Illegal use of '#' char.");
			}

			// z-- FIXME: wtf
			z--;

			// Check errors
			if (z == i + 1) // empty keyword
				PrintSourceError(curfile,flinescount,"Empty keyword on define value.");

			// get the identifier string
			char ident[MAX_ST_SIZE];
			memset(ident,0,MAX_ST_SIZE);
			int x;
			for (x=i+1; x<(z+1); x++)
				ident[x-i-1] = tvalue[x];

			// make sure it isnt a reserved word
			if (GetDirectiveType(ident)!=DIRECTIVE_IDENT)
				PrintSourceError(curfile,flinescount,"Illegal use of preprocessor reserved word.");

			// Update main char loop position
			i = i + strlen(ident);

			int numdef = IsDefined(ident);
			if (numdef == 0)
			{
				PrintSourceError(curfile,flinescount,"Undefined symbol as define value.");
			}
			else // Add it to our final string
			{
				// set to true the is_used flag
				deflist[numdef-1]->is_used = true;

				strcat(finalstr,deflist[numdef-1]->value);
				if (strlen(finalstr) >= MAX_ST_SIZE - 1)
					PrintSourceError(curfile,flinescount,"Resulting string value exceeds char limit! (255)");
			}
		}
		else
		{
			char tmpstr[2];
			tmpstr[0]=tvalue[i];
			tmpstr[1]='\0';
			strcat(finalstr,tmpstr);

			// Exceeds string limit max?
			if (strlen(finalstr) >= MAX_ST_SIZE - 1)
				PrintSourceError(curfile,flinescount,"Resulting string value exceeds char limit! (255)");
		}
	}

	CleanStr(finalstr);

	strcpy(tvalue, finalstr);
}

//===================================================================================================
// returns the directive ID number for the string passed, if none, DIRECTIVE_IDENT is returned

int GetDirectiveType(char* tkey)
{
	//- START STRING COMPARISONS TO GET TYPE OF DIRECTIVE -//
	if (strlen(tkey) == strlen(ST_DIR_IFDEF))
	{
		if (strcmp(tkey,ST_DIR_IFDEF)==0)
			return DIRECTIVE_IFDEF;
	}

	if (strlen(tkey) == strlen(ST_DIR_IFNDEF))
	{
		if (strcmp(tkey,ST_DIR_IFNDEF)==0)
			return DIRECTIVE_IFNDEF;
	}

	if (strlen(tkey) == strlen(ST_DIR_ELSE))
	{
		if (strcmp(tkey,ST_DIR_ELSE)==0)
			return DIRECTIVE_ELSE;
	}

	if (strlen(tkey) == strlen(ST_DIR_ENDIF))
	{
		if (strcmp(tkey,ST_DIR_ENDIF)==0)
			return DIRECTIVE_ENDIF;
	}

	if (strlen(tkey) == strlen(ST_DIR_DEFINE))
	{
		if (strcmp(tkey,ST_DIR_DEFINE)==0)
			return DIRECTIVE_DEFINE;
	}

	if (strlen(tkey) == strlen(ST_DIR_UNDEF))
	{
		if (strcmp(tkey,ST_DIR_UNDEF)==0)
			return DIRECTIVE_UNDEF;
	}

	if (strlen(tkey) == strlen(ST_DIR_PRAGMA))
	{
		if (strcmp(tkey,ST_DIR_PRAGMA)==0)
			return DIRECTIVE_PRAGMA;
	}

	if (strlen(tkey) == strlen(ST_DIR_INCLUDELIST))
	{
		if (strcmp(tkey,ST_DIR_INCLUDELIST)==0)
			return DIRECTIVE_INCLUDELIST;
	}

	if (strlen(tkey) == strlen(ST_DIR_ENDLIST))
	{
		if (strcmp(tkey,ST_DIR_ENDLIST)==0)
			return DIRECTIVE_ENDLIST;
	}

	if (strlen(tkey) == strlen(ST_DIR_INCLUDE))
	{
		if (strcmp(tkey,ST_DIR_INCLUDE)==0)
			return DIRECTIVE_INCLUDE;
	}

	return DIRECTIVE_IDENT;
}

//========================================================================
// convert xxxx.qc into xxxxx.qcp

void ChangeFilename(char *fname)
{
	char tmpname[MAX_ST_SIZE];
	int i;
	
	memset(tmpname,0,MAX_ST_SIZE);
		
	for (i=0; i < MAX_ST_SIZE - 1 && fname[i]!='.'; i++)
		tmpname[i] = fname[i];

	tmpname[i]='\0';
	strcat(tmpname,".qcp\0");

	strcpy(fname,tmpname);
}

//========================================================================
// At the end of main program execution, report any unused defines

void CheckUnused()
{
	if (fastmode) return;

	char tstr[MAX_ST_SIZE+21];
	PrintIt("------------------------------------------------\nChecking unused items...\n");
	unsigned int counter = 0;

	int z;

	// Lets scan for unused stuff
	for (unsigned int i = 0; i < gdefscount; i++)
	{		
		if (!deflist[i]->is_used) //Unused?
		{			
			// Skip default definitions
			z = 0;

			while (defines_c[z])
			{
				if (!strcmp(defines_c[z],deflist[i]->identifier))
				{
					z = 999999;
					break;
				}

				z++;
			}

			if (z!=999999)
			{
				tstr[0] = '\0';
				strcpy(tstr,"Definition \"");
				strcat(tstr,deflist[i]->identifier);
				strcat(tstr,"\" is never used");
				PrintSourceWarning(deflist[i]->defined_by,deflist[i]->on_line,tstr);
				counter ++;
			}
		}
	}
	
	// Report results
	if (counter > 0)
	{
		sprintf(tstr,"%d",counter);
		PrintIt("Unused items: ");
		PrintIt(tstr);
		PrintIt(" defines.\n");
	}
	else
	{
		PrintIt("No unused defines.\n");
	}
}
