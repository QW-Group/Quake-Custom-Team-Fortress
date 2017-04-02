void() info_intermission =
{
};

void() SetChangeParms =
{
};

void() SetNewParms =
{
};

void() PutClientInServer =
{
};


void() PlayerPreThink =
{
};
	

void() PlayerPostThink =
{
};

//
//  Dump the internal cl data structure for self
//
void() DumpCL = 
{
	local entity cl;
	local float p;
	local float i;

	p = AddInt(PSTRING_TO_PQUAKEC, &self.netname);
	cl = *SubInt(p, 4 * CL_NAME);

	dprint("--- CLIENT_T ---\n");
	dprint("self = ");
	hex32(&self);
	dprint("cl.active = ");
	hex32(cl[CL_ACTIVE]);
	dprint("cl.spawned = ");
	hex32(cl[CL_SPAWNED]);
	dprint("cl.privileged = ");
	hex32(cl[CL_PRIVILEGED]);
	dprint("cl.message.data = ");
	hex32(AddInt(cl[CL_MESSAGE_DATA], PC_TO_PQUAKEC));
	dprint("cl.message.maxsize = ");
	hex32(cl[CL_MESSAGE_MAXSIZE]);
	dprint("cl.message.cursize = ");
	hex32(cl[CL_MESSAGE_CURSIZE]);
	dprint("&cl.msgbuf = ");
	hex32(AddInt(&cl, 4 * CL_MSGBUF));
	dprint("cl.edict = ");
	hex32(AddInt(cl[CL_EDICT], PC_TO_PQUAKEC));
	p = AddInt(AddInt(&cl, 4 * CL_NAME), PQUAKEC_TO_PSTRING);
	dprint("cl.name = ", @p, "\n");
	dprint("cl.colors = ");
	hex32(cl[CL_COLORS]);
	dprint("cl.ping_times = ");

	for (i = 0 ; i < %16 ; i = i + %1)
		dprint(ftos(cl[CL_PING_TIMES + i] * 1000), " ");		

	dprint("\n");
	dprint("cl.num_pings = ");
	hex32(cl[CL_NUM_PINGS]);
	dprint("cl.spawn_parms = ");

	for (i = 0 ; i < %16 ; i = i + %1)
		dprint(ftos(cl[CL_SPAWN_PARMS + i]), " ");

	dprint("\n");
	dprint("cl.old_frags = ");
	hex32(cl[CL_OLD_FRAGS]);

	dprint("--- QSOCKET_S ---\n");
	cl = *AddInt(cl[CL_NETCONNECTION], PC_TO_PQUAKEC);

	dprint("cl.netconnection.addr = ");
	hex32(cl[QS_ADDR]);
	hex32(cl[AddInt(QS_ADDR, %1)]);
	hex32(cl[AddInt(QS_ADDR, %2)]);
	hex32(cl[AddInt(QS_ADDR, %3)]);
	dprint("cl.netconnection.in_addr = ");
	hex32(cl[QS_IN_ADDR]);
	p = AddInt(AddInt(&cl, 4 * QS_ADDRESS), PQUAKEC_TO_PSTRING);
	dprint("cl.netconnection.address = ", @p, "\n");
};

//
//  Sample code: mask a player's IP address.
//
//  Only coded for big endian machines!
//
void() FixAddress = 
{
	local string old, new;
	local entity cl, qs;

	cl = *SubInt(AddInt(PSTRING_TO_PQUAKEC, &self.netname), 4 * CL_NAME);
	qs = *AddInt(cl[CL_NETCONNECTION], PC_TO_PQUAKEC);

	new = @AddInt(AddInt(&qs, 4 * QS_ADDRESS), PQUAKEC_TO_PSTRING);
	old = @AddInt(&new, %32);

	strcpy(old, new);

	local float dotcount;
	local float pch;
	local float px;
	px = AddInt(&"xxx", PSTRING_TO_PQUAKEC);
	pch = AddInt(&new, PSTRING_TO_PQUAKEC);
	pch = AddInt(pch, %-3);
	&%116 = 0;
	for (dotcount = 0 ; dotcount < 3 ; pch = AddInt(pch, %1))
	{
		&%113 = (*pch)[0];
		if (world[%5] == '.')
			dotcount = dotcount + 1;
	}
	pch = AddInt(pch, %3);
	(*pch)[0] = (*px)[0];

	dprint("old = ", old, "\n");
	dprint("new = ", new, "\n");
};

void() ClientConnect =
{	
	// enable dprint
	cvar_set("developer", "1");

	DumpCL();
	FixAddress();

	// so that the view will be upright (not that it matters)
	self.health = 100;

	cvar_set("developer", "0");
};

//
//  Escape sequence test.. connect to the server and type "kill"
//
void() ClientKill =
{
	centerprint(self, "\.This\. \b\<\.is\.\>\b a \[test\]\n",
		"\(testing\) \(\1\=\2\=\3\)\n",
		"\{1}\{2}\{3}\n",
		"\{4}\-\{6}\n",
		"\{7}\{8}\{9}\n",
		"\b\{11}\{13}\b\n");

};

void() ClientDisconnect =
{
};

