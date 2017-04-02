void() main =
{
};

float framecount;

//
// This function was created to test various aspects of the compiler and
// serves as a good example of the advanced features which are supported.
//
void () RunTests = 
{
	local string s = "000":"001":"002":"003";
	local float i, p, p2;
	local entity e;

	dprint("*** Running compiler tests - pairs of lines should match exactly ***\n");

	dprint("--- integer test ---\n");
	dprint(ftos(((5 * %4) - %3) / %1), "\n");
	dprint("17\n");

	dprint("--- string test ---\n");
	p = &s;
	dprint((@p)[%8], "\n");
	dprint("002\n");

	dprint("--- direct pointer test ---\n");
	&%100 = 23;
	dprint(ftos(world.absmin_x), "\n");
	dprint("23\n");

	dprint("--- array test ---\n");
	p = &world + %4;
	i = %0;
	while (i < %3)
	{
		(*p)[i] = (i / %1) + 5;
		i = i + %1;
	}
	e = world + %4;
	i = %0;
	while (i < %3)
	{
		dprint(ftos(e[i]), " ");
		i = i + %1;
	}
	dprint("\n5 6 7\n");

	dprint("--- hex32 test ---\n");
	hex32(%65534);
	dprint("0000fffe  (65534)\n");
	hex32(%-5);
	dprint("fffffffb  (-5)\n");

	dprint("--- quakec pointer test ---\n");
	p = AddInt(&s, PSTRING_TO_PQUAKEC);
	p2 = AddInt(&mapname, PSTRING_TO_PQUAKEC);
	(*p)[%1] = (*p2)[0];
	dprint(s[%4], "\n");
	dprint("dm3\n");
	p = AddInt(&mapname, PSTRING_TO_PQUAKEC);
	p = AddInt((*p)[%867], PC_TO_PQUAKEC);
	hex32(p);
	dprint("ffffffa0  (-96)\n");

	dprint("*** End of tests ***\n");
};

//
//  Print out contents of the internal sv data structure.
//  The sv entity is initialized in InternalInit
//
void () DumpSV = 
{
	local float p;

	dprint("--- SERVER_T ---\n");
	dprint("sv.active = ");
	hex32(sv[SV_ACTIVE]);
	dprint("sv.paused = ");
	hex32(sv[SV_PAUSED]);
	dprint("sv.loadgame = ");
	hex32(sv[SV_LOADGAME]);
	dprint("sv.time = ");
	hex32(sv[SV_TIME]);
	dprint("          ");
	hex32(sv[SV_TIME + %1]);
	p = AddInt(AddInt(&sv, 4 * SV_NAME), PQUAKEC_TO_PSTRING);
	dprint("sv.name = ", @p, "\n");
	p = AddInt(AddInt(&sv, 4 * SV_MODELNAME), PQUAKEC_TO_PSTRING);
	dprint("sv.modelname = ", @p, "\n");
	dprint("sv.num_edicts = ");
	hex32(sv[SV_NUM_EDICTS]);
	dprint("sv.max_edicts = ");
	hex32(sv[SV_MAX_EDICTS]);
	dprint("sv.edicts = ");
	hex32(AddInt(sv[SV_EDICTS], PC_TO_PQUAKEC));
	dprint("sv.state = ");
	hex32(sv[SV_STATE]);
	dprint("sv.signon.data = ");
	hex32(AddInt(sv[SV_SIGNON_DATA], PC_TO_PQUAKEC));
	dprint("sv.signon.maxsize = ");
	hex32(sv[SV_SIGNON_MAXSIZE]);
	dprint("sv.signon.cursize = ");
	hex32(sv[SV_SIGNON_CURSIZE]);
	dprint("&sv.signon_buf = ");
	hex32(AddInt(&sv, 4 * SV_SIGNON_BUF));
};

//
//  Print out the contents of the progs header.
//  The progs entity is initialized by the compiler.
//
void () DumpProgs = 
{
	dprint("--- DPROGRAMS_T ---\n");
	dprint("progs.version = ");
	hex32(progs[PR_VERSION]);
	dprint("progs.crc = ");
	hex32(progs[PR_CRC]);
	dprint("progs.ofs_statements = ");
	hex32(progs[PR_OFS_STATEMENTS]);
	dprint("progs.numstatements = ");
	hex32(progs[PR_NUMSTATEMENTS]);
	dprint("progs.ofs_globaldefs = ");
	hex32(progs[PR_OFS_GLOBALDEFS]);
	dprint("progs.numglobaldefs = ");
	hex32(progs[PR_NUMGLOBALDEFS]);
	dprint("progs.ofs_fielddefs = ");
	hex32(progs[PR_OFS_FIELDDEFS]);
	dprint("progs.numfielddefs = ");
	hex32(progs[PR_NUMFIELDDEFS]);
	dprint("progs.ofs_functions = ");
	hex32(progs[PR_OFS_FUNCTIONS]);
	dprint("progs.numfunctions = ");
	hex32(progs[PR_NUMFUNCTIONS]);
	dprint("progs.ofs_strings = ");
	hex32(progs[PR_OFS_STRINGS]);
	dprint("progs.numstrings = ");
	hex32(progs[PR_NUMSTRINGS]);
	dprint("progs.ofs_globals = ");
	hex32(progs[PR_OFS_GLOBALS]);
	dprint("progs.numglobals = ");
	hex32(progs[PR_NUMGLOBALS]);
	dprint("progs.entityfields = ");
	hex32(progs[PR_ENTITYFIELDS]);
};

//
//  Example of the '#' optimization
//
void (string s1, string s2, string s3) twice = 
{
	dprint(#, #, #, " <- first time!\n");
	dprint(#, #, #, " <- second time!\n");
};

//
//  First QuakeC function to be called.  Always call InternalInit from
//  this function before you even think of doing anything else.
//
void() worldspawn =
{
	// enable dprint
	cvar_set("developer", "1");

	// Call this right away!
	InternalInit();

	// quake complains if this isn't precached
	precache_model("progs/player.mdl");

	// main tests
	RunTests();

	// Some other stuff you can play around with

	//DumpSV();
	//DumpProgs();
	//twice("This ", "is ", "a test");
	//fnstring(&worldspawn);
	//fnstring(&fnstring);

	// This one is really cool.. it inspects the hunk and finds everything in it.

	//InitHunkSearch();


local entity e;
local string s = "Hi tXXXXhere";
local float psource, pdest;

e = *%600;
psource = AddInt(&s, PSTRING_TO_PQUAKEC);
e[0] = (*psource)[0];
e[%1] = (*psource)[%2];
pdest = AddInt(&e, PQUAKEC_TO_PSTRING);
dprint(@pdest, "\n");


	cvar_set("developer", "0");
};
	
void() StartFrame =
{
	// enable dprint
	cvar_set("developer", "1");

	framecount = framecount + 1;

	if (lasth)
		SearchHunk();

	cvar_set("developer", "0");
};
