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
Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.*/




#include "qwsvdef.h"
#include "dblog.h"

#undef PROTOCOL_VERSION /* conflict between mysql and qwsv */

#if defined(_WIN32)
#include <windows.h>
#endif

#include <mysql.h>

/* MySQL connection */
static MYSQL *g_mysql;
static MYSQL_STMT *g_select_map;
static MYSQL_STMT *g_select_player;
static MYSQL_STMT *g_insert_map;
static MYSQL_STMT *g_insert_player;
static MYSQL_STMT *g_insert_game;
static MYSQL_STMT *g_insert_frag;

/* current game id */
static unsigned int g_gameid;

/* allocates and prepares a statement.  does not free statement if prepare fails. */
static int prepare(MYSQL_STMT **pstmt, MYSQL *db, const char *sql) {
	MYSQL_STMT *stmt;
	int ret;

	stmt = mysql_stmt_init(db);
	if(!stmt) {
		Sys_Printf("WARNING: database error.  %s\n", mysql_error(db));
		return -1;
	}

	*pstmt = stmt;

	ret = mysql_stmt_prepare(stmt, sql, strlen(sql));
	if(ret) {
		Sys_Printf("WARNING: database error.  %s\n", mysql_stmt_error(stmt));
		return -1;
	}

	return 0;
}

/* binds, executes, and fetches in one go.  returns NULL on success or error message on failure. */
static int execute(MYSQL_STMT *stmt, MYSQL_BIND *params, MYSQL_BIND *result, unsigned int *id) {
	int ret;

	if(params) {
		ret = mysql_stmt_bind_param(stmt, params);
		if(ret) goto err;
	}

	ret = mysql_stmt_execute(stmt);
	if(ret) goto err;

	if(result) {
		ret = mysql_stmt_bind_result(stmt, result);
		if(ret) goto err;
		
		ret = mysql_stmt_fetch(stmt);
		if(ret == 1) goto err;
	}

	if(id) {
		*id = mysql_stmt_insert_id(stmt);
	}

	mysql_stmt_reset(stmt);
	return 0;

err:
	Sys_Printf("WARNING: database error.  %s\n", mysql_stmt_error(stmt));
	mysql_stmt_reset(stmt);
	return -1;
}

/*
	retrieves an id for a name.  used for map and player names.
*/
static unsigned int getidforname(MYSQL_STMT *selectstmt, MYSQL_STMT *insertstmt, const char *name) {
	unsigned int id;

	/* get a id */
	{
		MYSQL_BIND param = {0};
		MYSQL_BIND result = {0};

		param.buffer_type = MYSQL_TYPE_STRING;
		param.buffer = (char*)name;
		param.buffer_length = strlen(name);
		param.length = &param.buffer_length;

		result.buffer_type = MYSQL_TYPE_LONG;
		result.buffer = &id;
		result.buffer_length = sizeof(id);
		result.length = &result.buffer_length;
		result.is_unsigned = 1;

		if(execute(selectstmt, &param, &result, NULL))
			return 0;
	}

	/* if no entry existed, insert */
	if(!id) {
		MYSQL_BIND param = {0};

		param.buffer_type = MYSQL_TYPE_STRING;
		param.buffer = (char*)name;
		param.buffer_length = strlen(name);
		param.length = &param.buffer_length;

		if(execute(insertstmt, &param, NULL, &id))
			return 0;
	}

	return id;
}

/*
	initializes connections and global vars.
*/
static void init(void) {
	MYSQL *db;
	const char *host, *user, *pass, *dbname;
	unsigned int port;

	g_mysql = NULL;

	dbname = Cvar_VariableString("db_name");
	if(!*dbname) return;

	host = Cvar_VariableString("db_host");
	if(!*host) host = NULL;

	port = (unsigned int)strtol(Cvar_VariableString("db_port"), NULL, 10);
	if(port > 65535) port = 0;

	user = Cvar_VariableString("db_user");
	if(!*user) user = NULL;

	pass = Cvar_VariableString("db_pass");
	if(!*pass) pass = NULL;

	g_mysql = mysql_init(NULL);
	if(!g_mysql) return;
	
	db = mysql_real_connect(g_mysql, host, user, pass, dbname, port, NULL, 0);
	if(!db) {
		Sys_Printf("WARNING: database error.  %s\n", mysql_error(g_mysql));
		goto err1;
	}

	if(prepare(&g_select_map, db, "SELECT id FROM t_maps WHERE name=?"))
		goto err1;

	if(prepare(&g_select_player, db, "SELECT id FROM t_players WHERE name=?"))
		goto err2;

	if(prepare(&g_insert_map, db, "INSERT INTO t_maps(name) VALUES(?)"))
		goto err3;

	if(prepare(&g_insert_player, db, "INSERT INTO t_players(name) VALUES(?)"))
		goto err4;

	if(prepare(&g_insert_game, db, "INSERT INTO t_games(mapid,playdate) VALUES(?,?)"))
		goto err5;

	if(prepare(&g_insert_frag, db, "INSERT INTO t_frags(gameid,attackerid,attackerflags,attackerspeed,victimid,victimflags,victimspeed,speed,distance,weapon) VALUES(?,?,?,?,?,?,?,?,?,?)"))
		goto err6;

	return;

err6:
	mysql_stmt_close(g_insert_game);

err5:
	mysql_stmt_close(g_insert_player);

err4:
	mysql_stmt_close(g_insert_map);

err3:
	mysql_stmt_close(g_select_player);

err2:
	mysql_stmt_close(g_select_map);

err1:
	mysql_close(g_mysql);
	g_mysql = NULL;
}

/*
	call when a new map starts.

	uses the cvars "db_name", "db_host", "db_port", "db_user", and "db_pass".
	if "db_name" is an empty string, logging to database is disabled.
	if anything else is an empty string, it uses database defaults.
*/
void DB_MapStarted(const char *name) {
	MYSQL_BIND params[2] = {0};
	unsigned int mapid;
	unsigned int playdate;
	int ret;

	init();
	if(!g_mysql) return;

	playdate = (unsigned int)time(NULL);

	mapid = getidforname(g_select_map, g_insert_map, name);
	if(!mapid) return;

	/* insert game */
	
	params[0].buffer_type = MYSQL_TYPE_LONG;
	params[0].buffer = &mapid;
	params[0].buffer_length = sizeof(mapid);
	params[0].length = &params[0].buffer_length;
	params[0].is_unsigned = 1;

	params[1].buffer_type = MYSQL_TYPE_LONG;
	params[1].buffer = &playdate;
	params[1].buffer_length = sizeof(playdate);
	params[1].length = &params[1].buffer_length;
	params[1].is_unsigned = 1;

	if(execute(g_insert_game, params, NULL, &g_gameid))
		return;
}

/*
	call when a map ends, or qwsv closes.
	closes all database connections and frees any allocated structures.
*/
void DB_MapStopped(void) {
	if(g_mysql) {
		mysql_stmt_close(g_select_map);
		mysql_stmt_close(g_select_player);
		mysql_stmt_close(g_insert_map);
		mysql_stmt_close(g_insert_player);
		mysql_stmt_close(g_insert_game);
		mysql_stmt_close(g_insert_frag);
		mysql_close(g_mysql);
		g_mysql = NULL;
	}
}

/* call when a player connects or changes names. */
unsigned int DB_GetPlayerId(const char *name) {
	unsigned int ret;

	if(g_mysql) {
		ret = getidforname(g_select_player, g_insert_player, name);
		assert(ret != 0);
	}
	else {
		ret = 0;
	}

	return ret;
}

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
					 unsigned int speed, unsigned int distance, unsigned int weapon)
{
	MYSQL_BIND params[10] = {0};

	if(!g_mysql) return;

	// insert into db.
	
	params[0].buffer_type = MYSQL_TYPE_LONG;
	params[0].buffer = &g_gameid;
	params[0].buffer_length = sizeof(g_gameid);
	params[0].length = &params[0].buffer_length;
	params[0].is_unsigned = 1;
	
	params[1].buffer_type = MYSQL_TYPE_LONG;
	params[1].buffer = &aid;
	params[1].buffer_length = sizeof(aid);
	params[1].length = &params[0].buffer_length;
	params[1].is_unsigned = 1;
	
	params[2].buffer_type = MYSQL_TYPE_LONG;
	params[2].buffer = &aflags;
	params[2].buffer_length = sizeof(aflags);
	params[2].length = &params[0].buffer_length;
	params[2].is_unsigned = 1;
	
	params[3].buffer_type = MYSQL_TYPE_LONG;
	params[3].buffer = &aspeed;
	params[3].buffer_length = sizeof(aspeed);
	params[3].length = &params[0].buffer_length;
	params[3].is_unsigned = 1;
	
	params[4].buffer_type = MYSQL_TYPE_LONG;
	params[4].buffer = &vid;
	params[4].buffer_length = sizeof(vid);
	params[4].length = &params[0].buffer_length;
	params[4].is_unsigned = 1;
	
	params[5].buffer_type = MYSQL_TYPE_LONG;
	params[5].buffer = &vflags;
	params[5].buffer_length = sizeof(vflags);
	params[5].length = &params[0].buffer_length;
	params[5].is_unsigned = 1;
	
	params[6].buffer_type = MYSQL_TYPE_LONG;
	params[6].buffer = &vspeed;
	params[6].buffer_length = sizeof(vspeed);
	params[6].length = &params[0].buffer_length;
	params[6].is_unsigned = 1;
	
	params[7].buffer_type = MYSQL_TYPE_LONG;
	params[7].buffer = &speed;
	params[7].buffer_length = sizeof(speed);
	params[7].length = &params[0].buffer_length;
	params[7].is_unsigned = 1;
	
	params[8].buffer_type = MYSQL_TYPE_LONG;
	params[8].buffer = &distance;
	params[8].buffer_length = sizeof(distance);
	params[8].length = &params[0].buffer_length;
	params[8].is_unsigned = 1;
	
	params[9].buffer_type = MYSQL_TYPE_LONG;
	params[9].buffer = &weapon;
	params[9].buffer_length = sizeof(weapon);
	params[9].length = &params[0].buffer_length;
	params[9].is_unsigned = 1;
	
	execute(g_insert_frag, params, NULL, NULL);
}

