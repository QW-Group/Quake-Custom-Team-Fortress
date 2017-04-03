/*
	gweapons.qc - Gizmo's new Coop weapons

	FIXME: rename file?
*/


//==============================================================

entity	solidTestEntity;

/*
===============
RemoveTestEntity

This is just used to remove the test entity after
half a second, to avoid create and removing a bunch
of entities and causing the server's sv.num_edicts to
increase a great deal.
===============
*/
void() RemoveTestEntity = {
	solidTestEntity = world;
	remove( self );
};

/*
===============
InSolid

Checks if the entity is inside the world or another entity.
===============
*/
float (entity ent) InSolid =
{
	local entity	oself;
	local vector	oldownerorg, oldorg, neworg;
	local float		ret;

/*
	local float oldsolid;

	// first make sure the entity won't get in the way
	oldsolid = ent.solid;
	ent.solid = #SOLID_NOT;

	// create an entity to test with
	tent = spawn ();
	tent.solid = #SOLID_SLIDEBOX;
	tent.movetype = #MOVETYPE_STEP;
	setsize (tent, ent.mins, ent.maxs);
	setorigin (tent, ent.origin);

	oself = self;
	self = tent;

	self.origin_z = self.origin_z + 1;
	ret = droptofloor ();

	//ret = walkmove (0, 0);

	self = oself;

	// reset the entity's solid state
	ent.solid = oldsolid;

	remove (tent);
	return ret;
*/

	// 2/28/08: since we can't use ent.owner as the owner for solidTestEntity.owner, link ent.owner out of the way
	if ( ent.owner != world ) {
		oldownerorg = ent.owner.origin;
		ent.owner.origin_z = ent.owner.origin_z + ent.owner.maxs_z * 2;
		setorigin( ent.owner, ent.owner.origin + '0 0 200' );
	}

	// don't spam a bunch of entity spawn() and remove() calls if this is called often
	if ( !solidTestEntity ) {
		solidTestEntity = spawn();
		solidTestEntity.think = RemoveTestEntity;
	}

	solidTestEntity.nextthink = time + 0.6;

	solidTestEntity.owner = ent;
	solidTestEntity.solid = #SOLID_SLIDEBOX;
	solidTestEntity.movetype = #MOVETYPE_STEP;
	//solidTestEntity.flags = #FL_FLY;
	solidTestEntity.flags = #FL_ONGROUND | #FL_PARTIALGROUND;
	setsize (solidTestEntity, ent.mins, ent.maxs);
	setorigin (solidTestEntity, ent.origin);

// check if we're inside something
	oself = self;
	self = solidTestEntity;

	oldorg = solidTestEntity.origin;
	ret = walkmove (0, 0);
	neworg = solidTestEntity.origin;
	setorigin (solidTestEntity, oldorg);

	if (oldorg != neworg && !droptofloor())
		ret = #FALSE;

	self = oself;

	// set origin back to normal if needed
	if ( ent.owner != world )
		setorigin( ent.owner, oldownerorg );

	// make sure the test entity can't interact with anything now
	solidTestEntity.solid = #SOLID_NOT;
	solidTestEntity.movetype = #MOVETYPE_NONE;
	solidTestEntity.owner = world;

	return !ret;
//	return qc_droptofloor (ent, 4096, #TRUE);
};

//==============================================================

#ifndef NO_ZEROGRAVGUN

/*
=============================
Zero-Gravity gun
=============================
*/

#define ZG_PICKUPDIST_EXTRA			48				// extra distance added to pickupee's maxs, was 32


// FIXME: change some of these to macros
.entity	pickedupobject_hands;
.entity	pickupthink_hands;
.entity	_oldowner;
.entity	pickedupby;								// set if the object is being picked up
.float	oldmovetype;

float		unlockedZeroGrav;							// set to TRUE if unlocked

void (entity pickuper, float toss) zg_drop;
float (entity pickupee) zg_getpickupdist;

//=======================

void (entity pickuper, entity pickupee, vector destt) zg_movetowards =
{
	local float vel, distfrompickuper;

	vel = vlen (pickupee.origin - destt);
	distfrompickuper = vlen(pickuper.origin - pickupee.origin);

	if (distfrompickuper > zg_getpickupdist(pickupee) + 32) {
		pickupee.velocity = '0 0 0';
		zg_drop (pickuper, #FALSE);
		return;
	}

	if (pickupee.origin != destt)
		pickupee.velocity = pickuper.velocity + ((normalize(destt - pickupee.origin) * vel) * 10);
	else
		pickupee.velocity = pickuper.velocity;
};


float (entity pickupee) zg_getpickupdist =
{
	local float sizex, sizey;

	if (pickupee.solid == #SOLID_NOT || pickupee.solid == #SOLID_TRIGGER || (!pickupee.mins_x && !pickupee.maxs_x))
		return #ZG_PICKUPDIST_EXTRA;

	sizex = pickupee.maxs_x + #ZG_PICKUPDIST_EXTRA/*(pickupee.mins_x * -1) + pickupee.maxs_x*/;
	sizey = pickupee.maxs_y + #ZG_PICKUPDIST_EXTRA/*(pickupee.mins_y * -1) + pickupee.maxs_y*/;

	// go for the biggest side
	if (sizex >= sizey)
		return sizex;
	else
		return sizey;
};


float (entity source, entity targ) zg_infront =
{
	local vector	vec;
	local float		dot;
	
	makevectors (source.angles);	// BUG: this makes up and down not work, use .v_angle for players instead

	vec = normalize (targ.origin - source.origin);
	dot = vec * v_forward;
	
	if ( dot > 0.3)
	{
		return #TRUE;
	}
	return #FALSE;
};


float (entity tester, entity test) zg_invalidtarget =
{
	if (test.solid == #SOLID_BSP || test == world /*|| test.movetype == #MOVETYPE_NONE*/ || test.pickedupby != world)
		return #TRUE;
	if (/*test.flags & #FL_MONSTER ||*/ !zg_infront(tester, test))
		return #TRUE;
	if (IsBuilding(test) && test.real_owner != tester)
		return 2;

	if (!unlockedZeroGrav) {
		if (test.flags & #FL_ITEM)
			return 3;
		if (test.flags & #FL_CLIENT || test.classname == "player")
			return #TRUE;
	}

	if (unlockedZeroGrav < 2) {
		if (test.movetype == #MOVETYPE_NONE || test.flags & #FL_MONSTER)
			return #TRUE;
	}

	return #FALSE;
};

entity (entity source) zg_findtarget =
{
	local entity radiusent;
	local float ret, badpickup;

	badpickup = 0;

	makevectors (source.v_angle);

	// try directly at what we're looking at
	traceline (source.origin, (source.origin + '0 0 16') + v_forward*64, #TL_ANY_SOLID, source);

	if (trace_fraction != 1.0 && !(ret = zg_invalidtarget(source, trace_ent)))
		return trace_ent;

	if (ret > 1)
		badpickup = ret;

	// if nothing's directly infront try scanning for something
	radiusent = findradius (source.origin, 64);

	while (radiusent) {
		if (!(ret = zg_invalidtarget(source, radiusent)))
			return radiusent;

		if (ret > 1)
			badpickup = ret;

		radiusent = radiusent.chain;
	}

	if (source.flags & #FL_CLIENT) {
		if (badpickup == 2)
			sprint (source, #PRINT_HIGH, "Sorry, only the owner can pickup his builds!\n");
		else if (badpickup == 3)
			sprint (source, #PRINT_HIGH, "Sorry, picking up items is disabled!\n");
		else
			sprint (source, #PRINT_HIGH, "There's nothing there to pickup\n");
	}

	return world;
};


//=======================


void () zg_think =
{
	local entity pickuper, pickupee;

	pickuper = self.owner;
	pickupee = self.owner.pickedupobject_hands;

	// remove onground flag
	pickupee.flags = pickupee.flags - (pickupee.flags & (#FL_ONGROUND | #FL_PARTIALGROUND));

	// if the pickuper doesn't have anything picked up then remove ourself
	// FIXME: this should never happen, zg_drop should be the only thing that messes with pickupee and removes the thinker
	if (pickupee == world)
		remove (self);

	if ( pickupee.classname == "player" ) {
		if ( pickupee.gravity ) {
			pickupee.oldmovetype = pickupee.gravity;
			pickupee.gravity = 0;
		}
	} else {
		// 10/12/07: if the pickupee's movetype has changed, save it and reset it back to MOVETYPE_FLY, can happen
		// FIXME: if the object's new movetype is actually set somewhere to MOVETYPE_FLY, there's no way to know it changed, and the old movetype will still be set when dropped instead of fly
		if ( pickupee.movetype != #MOVETYPE_FLY ) {
			pickupee.oldmovetype = pickupee.movetype;
			pickupee.movetype = #MOVETYPE_FLY;
		}
	}

	// check if the pickuper is dead
	if (pickuper.health <= 0 || (pickupee.takedamage && pickupee.health <= 0) || pickupee.model == "" || !pickuper.is_connected) {	// *
		zg_drop (pickuper, #FALSE);
		return;
	}

	makevectors (pickuper.v_angle);

	// this is based upon the entity's size
/*
	// there's a bug in cpqwsv, for some reason the trace_endpos is screwed on this, works fine on other qwsv's
	traceline (pickuper.origin, (pickuper.origin + '0 0 16') + v_forward*zg_getpickupdist(pickupee), #TL_BSP_ONLY, pickuper);
*/
	trace_endpos = (pickuper.origin + '0 0 16') + v_forward*zg_getpickupdist(pickupee);

	zg_movetowards (pickuper, pickupee, trace_endpos);

	self.nextthink = time + 0.05;
};


void (entity pickuper, float toss) zg_drop =
{
	local entity pickupee, oldself;

	pickupee = pickuper.pickedupobject_hands;

	makevectors (pickuper.v_angle);

	// checked based upon the entity's size
	//traceline (pickuper.origin, (pickuper.origin + '0 0 16') + v_forward*64, #TL_ANY_SOLID, pickuper);

	// make sure we have something picked up
	if (pickuper.pickedupobject_hands == world)
		return;

	/*
	if ((trace_fraction != 1.0 || zg_insolid(pickupee)) && !(pickuper.health <= 0 || (pickupee.takedamage && pickupee.health <= 0) || pickupee.model == "")) {
		if (pickuper.flags & #FL_CLIENT)
			sprint (pickuper, #PRINT_HIGH, "Not enough room here\n");

		return;
	}
	*/

	// fix pickuper and pickupee
	remove (pickuper.pickupthink_hands);

	if (toss) {
		pickupee.velocity = v_forward * 500;

		if (pickupee.oldmovetype != #MOVETYPE_FLY && pickupee.oldmovetype != #MOVETYPE_FLYMISSILE)
			pickupee.velocity = pickupee.velocity + v_up * 200;
	} else
		pickupee.velocity_z = pickupee.velocity_z + 10;	// *

	// 1/18/07: Gizmo - added this above InSolid() so it can check properly, and also if it fails
	pickuper.owner = pickuper._oldowner;

	// before we reset owner, check if we're inside him
	if (InSolid(pickupee)) {
		oldself = self;
		self = pickupee;
		self.velocity = '0 0 0';
		pickuper.owner = pickupee;
		droptofloor ();
		self = oldself;
	}

	pickuper.owner = pickuper._oldowner;

	// players are handled differently
	if ( pickupee.classname == "player" )
		pickupee.gravity = pickupee.oldmovetype;
	else
		pickupee.movetype = pickupee.oldmovetype;

	pickupee.pickedupby = world;					// *

	pickuper.pickedupobject_hands = world;

	// reset weaponmodel
	if (pickuper.health > 0) {
		oldself = self;
		self = pickuper;
		W_SetCurrentAmmo ();
		self = oldself;
	}
};

//#define ZGG_DETPACK_RESTRICTION_TESTING
void (entity pickuper) zg_pickup =
{
	local entity thinker;

	trace_ent = zg_findtarget (pickuper);

	if (!trace_ent)
		return;

	// make sure we're not already picking something up
	if (pickuper.pickedupobject_hands != world)
		return;

#ifndef ZGG_DETPACK_RESTRICTION_TESTING

	if (deathmatch && (trace_ent.classname == "detpack" || trace_ent.classname == "building_dispenser"))
	{
		sprint(pickuper, #PRINT_HIGH, "For the time being, can't pickup detpacks/dispensers at all.\n");
		return;
	}

#endif

	// setup pickuper and pickupee
	pickuper._oldowner = pickuper.owner;			// *
	pickuper.owner = trace_ent;					// *

	// players are handled differently, since .gravity only works on players
	if ( trace_ent.classname == "player" ) {
		trace_ent.oldmovetype = trace_ent.gravity;
		trace_ent.gravity = 0;
	} else {
		trace_ent.oldmovetype = trace_ent.movetype;
		trace_ent.movetype = #MOVETYPE_FLY;
	}
	trace_ent.pickedupby = pickuper;				// * for knowing if it's picked up

	trace_ent.flags = trace_ent.flags - #FL_ONGROUND;	// *

	// fire the onpickup event on the pickupee
	//if (trace_ent.onpickup)
	//	trace_ent.onpickup (pickuper, trace_ent);


	pickuper.pickedupobject_hands = trace_ent;

#ifdef ZGG_DETPACK_RESTRICTION_TESTING

 	local float ran;

	ran = random();

sprint(pickuper, #PRINT_HIGH, "ran = ");
local string tmp; tmp = ftos(ran);
sprint(pickuper, #PRINT_HIGH, tmp); sprint(pickuper, #PRINT_HIGH, "\n");

	if (deathmatch && trace_ent.classname == "detpack")
	{
		sprint(pickuper, #PRINT_HIGH, "Careful. Detpacks and zero gravity guns don't get along very well..\n");
		// calc random number
		if ((trace_ent.owner.team_no == pickuper.team_no && ran < #ZGG_FRIENDLY_DETPACK_EXPLODE_CHANCE) ||
			(trace_ent.owner.team_no != pickuper.team_no && ran < #ZGG_ENEMY_DETPACK_EXPLODE_CHANCE))
		{
if (trace_ent.owner.team_no == pickuper.team_no)
	sprint(pickuper, #PRINT_HIGH, "FRIENDLY DET: BEEEEEEEP!\n");
else
	sprint(pickuper, #PRINT_HIGH, "ENEMY DET: BEEEEEEEP!\n");
			// beep error sound
			sound(trace_ent, #CHAN_WEAPON, "sub/locked.wav", 1, #ATTN_NORM);
			// explode 2 seconds later
			if (trace_ent.nextthink > time + 2)
				trace_ent.nextthink = time + 2;
			trace_ent.linked_list.health = 0; // stop the detpack's timer
		}
	}

#endif

	// create the thinker
	thinker = spawn ();
	thinker.owner = pickuper;

	thinker.nextthink = time + 0.01;
	thinker.think = zg_think;

	pickuper.pickupthink_hands = thinker;
};


void (entity pickuper, float toss) zg_togglepickup =
{
	// check for unlocking the gravity gun here instead of every frame
	if (infokey(world, "zg_unlocked") != "") {
		unlockedZeroGrav = stof (infokey(world, "zg_unlocked"));
		localcmd ("localinfo zg_unlocked \"\"\n");
		localcmd ("serverinfo zg_unlocked \"\"\n");
	}

	if (pickuper.pickedupobject_hands == world)
		zg_pickup (pickuper);
	else
		zg_drop (pickuper, toss);
};
#endif
