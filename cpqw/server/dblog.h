/*
Copyright (C) 2008 Cory Nelson (phrosty@gmail.com)

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

#ifndef CPQWSV_DBLOG_H_INCLUDED
#define CPQWSV_DBLOG_H_INCLUDED

/*
	call when a new map starts.

	uses the cvars "db_name", "db_host", "db_port", "db_user", and "db_pass".
	if "db_name" is an empty string, logging to database is disabled.
	if anything else is an empty string, it uses database defaults.
*/
void DB_MapStarted(const char *name);

/* call when a map ends, or qwsv closes. */
void DB_MapStopped(void);

/* call when a player connects or changes names. */
unsigned int DB_GetPlayerId(const char *name);

/*
	call when a player kills another.

	aid/vid: player ids.  NOT userid, must get with DB_GetPlayerId.
	aflags/vflags: flags (16 bits max).  armor type, runes, auras, etc.
	aspeed: speed of attacker at time of firing.
	vspeed: speed of victim at time of hit.
	speed: speed of weapon shot.  0 for hitscan.
	distance: distance shot traveled.
	weapon: weapon/build/summon id.
*/
void DB_LogFrag(unsigned int aid, unsigned int aflags, unsigned int aspeed,
					 unsigned int vid, unsigned int vflags, unsigned int vspeed,
					 unsigned int speed, unsigned int distance, unsigned int weapon);


#endif
