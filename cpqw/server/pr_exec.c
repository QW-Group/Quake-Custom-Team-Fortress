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

#include "qwsvdef.h"



#include <time.h> // OfN - For date stamp on crash log items

// OfN
qboolean crashlog_running;
FILE *crashlog_file;

/*

*/

typedef struct
{
	int				s;
	dfunction_t		*f;
} prstack_t;

#define	MAX_STACK_DEPTH		36 // OfN - was 32
prstack_t	pr_stack[MAX_STACK_DEPTH];
int			pr_depth;

#define	LOCALSTACK_SIZE		2048
int			localstack[LOCALSTACK_SIZE];
int			localstack_used;


qboolean	pr_trace;
dfunction_t	*pr_xfunction;
int			pr_xstatement;


int		pr_argc;

char *pr_opnames[] =
{
"DONE",

"MUL_F",
"MUL_V", 
"MUL_FV",
"MUL_VF",
 
"DIV",

"ADD_F",
"ADD_V", 
  
"SUB_F",
"SUB_V",

"EQ_F",
"EQ_V",
"EQ_S", 
"EQ_E",
"EQ_FNC",
 
"NE_F",
"NE_V", 
"NE_S",
"NE_E", 
"NE_FNC",
 
"LE",
"GE",
"LT",
"GT", 

"INDIRECT",
"INDIRECT",
"INDIRECT", 
"INDIRECT", 
"INDIRECT",
"INDIRECT", 

"ADDRESS", 

"STORE_F",
"STORE_V",
"STORE_S",
"STORE_ENT",
"STORE_FLD",
"STORE_FNC",

"STOREP_F",
"STOREP_V",
"STOREP_S",
"STOREP_ENT",
"STOREP_FLD",
"STOREP_FNC",

"RETURN",
  
"NOT_F",
"NOT_V",
"NOT_S", 
"NOT_ENT", 
"NOT_FNC", 
  
"IF",
"IFNOT",
  
"CALL0",
"CALL1",
"CALL2",
"CALL3",
"CALL4",
"CALL5",
"CALL6",
"CALL7",
"CALL8",
  
"STATE",
  
"GOTO", 
  
"AND",
"OR", 

"BITAND",
"BITOR"
};

char *PR_GlobalString (int ofs);
char *PR_GlobalStringNoContents (int ofs);


//=============================================================================

/*
=================
PR_PrintStatement
=================
*/
void PR_PrintStatement (int index)
{
	int		i, op, a, b, c;

	if (pr_statements) {
		op = pr_statements[index].op;
		a = pr_statements[index].a;
		b = pr_statements[index].b;
		c = pr_statements[index].c;
	} else {
		op = pr_statements7[index].op;
		a = pr_statements7[index].a;
		b = pr_statements7[index].b;
		c = pr_statements7[index].c;
	}
	
	if ( (unsigned)op < sizeof(pr_opnames)/sizeof(pr_opnames[0]))
	{
		Con_Printf ("%s ",  pr_opnames[op]);
		i = strlen(pr_opnames[op]);
		for ( ; i<10 ; i++)
			Con_Printf (" ");
	}
		
	if (op == OP_IF || op == OP_IFNOT)
		Con_Printf ("%sbranch %i",PR_GlobalString(a),b);
	else if (op == OP_GOTO)
	{
		Con_Printf ("branch %i",a);
	}
	else if ( (unsigned)(op - OP_STORE_F) < 6)
	{
		Con_Printf ("%s",PR_GlobalString(a));
		Con_Printf ("%s", PR_GlobalStringNoContents(b));
	}
	else
	{
		if (a)
			Con_Printf ("%s",PR_GlobalString(a));
		if (b)
			Con_Printf ("%s",PR_GlobalString(b));
		if (c)
			Con_Printf ("%s", PR_GlobalStringNoContents(c));
	}
	Con_Printf ("\n");
}

/*
============
PR_StackTrace
============
*/
void PR_StackTrace (void)
{
	dfunction_t	*f;
	int			i;
	
	if (pr_depth == 0)
	{
		Con_Printf ("<NO STACK>\n");
		return;
	}
	
	pr_stack[pr_depth].f = pr_xfunction;
	for (i=pr_depth ; i>=0 ; i--)
	{
		f = pr_stack[i].f;
		
		if (!f)
		{
			Con_Printf ("<NO FUNCTION>\n");
		}
		else
			Con_Printf ("%12s : %s\n", PR_GetString(f->s_file), PR_GetString(f->s_name));		
	}
}


/*
============
PR_Profile_f

============
*/
void PR_Profile_f (void)
{
	dfunction_t	*f, *best;
	int			max;
	int			num;
	int			i;
	
	num = 0;	
	do
	{
		max = 0;
		best = NULL;
		for (i=0 ; i<progs->numfunctions ; i++)
		{
			f = &pr_functions[i];
			if (f->profile > max)
			{
				max = f->profile;
				best = f;
			}
		}
		if (best)
		{
			if (num < 10)
				Con_Printf ("%7i %s\n", best->profile, PR_GetString(best->s_name));
			num++;
			best->profile = 0;
		}
	} while (best);
}


/*
============
PR_RunError

Aborts the currently executing function
============
*/
void PR_RunError (char *error, ...)
{
	va_list		argptr;
	char		string[1024];

	va_start (argptr,error);
	vsprintf (string,error,argptr);
	va_end (argptr);

	CrashLog_Start();

	PR_PrintStatement (pr_xstatement);
	PR_StackTrace ();
	Con_Printf ("%s\n", string);

	//CrashLog_End(); done at SV_Error --> Sys_Error so it logs any error
	
	pr_depth = 0;		// dump the stack so SV_Error can shutdown functions

	SV_Error ("Program error");
}

/*
============================================================================
PR_ExecuteProgram

The interpretation main loop
============================================================================
*/

/*
====================
PR_EnterFunction

Returns the new program statement counter
====================
*/
int PR_EnterFunction (dfunction_t *f)
{
	int		i, j, c, o;

	pr_stack[pr_depth].s = pr_xstatement;
	pr_stack[pr_depth].f = pr_xfunction;	
	pr_depth++;
	if (pr_depth >= MAX_STACK_DEPTH)
		PR_RunError ("stack overflow");

// save off any locals that the new function steps on
	c = f->locals;
	if (localstack_used + c > LOCALSTACK_SIZE)
		PR_RunError ("PR_ExecuteProgram: locals stack overflow\n");

	for (i=0 ; i < c ; i++)
		localstack[localstack_used+i] = ((int *)pr_globals)[f->parm_start + i];
	localstack_used += c;

// copy parameters
	o = f->parm_start;
	for (i=0 ; i<f->numparms ; i++)
	{
		for (j=0 ; j<f->parm_size[i] ; j++)
		{
			((int *)pr_globals)[o] = ((int *)pr_globals)[OFS_PARM0+i*3+j];
			o++;
		}
	}

	pr_xfunction = f;
	return f->first_statement - 1;	// offset the s++
}

/*
====================
PR_LeaveFunction
====================
*/
int PR_LeaveFunction (void)
{
	int		i, c;

	// OfN - Clear any string buffers used on this function
	if (NumStrBuffersUsed)
		CheckUnusedStrBuffers();
	
	if (pr_depth <= 0)
		SV_Error ("prog stack underflow");

// restore locals from the stack
	c = pr_xfunction->locals;
	localstack_used -= c;
	if (localstack_used < 0)
		PR_RunError ("PR_ExecuteProgram: locals stack underflow\n");

	for (i=0 ; i < c ; i++)
		((int *)pr_globals)[pr_xfunction->parm_start + i] = localstack[localstack_used+i];

// up stack
	pr_depth--;
	pr_xfunction = pr_stack[pr_depth].f;
	return pr_stack[pr_depth].s;
}


/*
====================
PR_ExecuteProgram
====================
*/
void PR_ExecuteProgram (func_t fnum)
{
	eval_t	*a, *b, *c;
	int			s;
	dstatement_t	*st;
	dstatement7_t	*st7;		//KK ptr to statement progs v7+
	dfunction_t	*f, *newf;
	int		runaway;
	int		i;
	edict_t	*ed;
	int		exitdepth;
	eval_t	*ptr;

	if (!fnum || fnum >= progs->numfunctions)
	{
		if (pr_global_struct->self)
			ED_Print (PROG_TO_EDICT(pr_global_struct->self));
		SV_Error ("PR_ExecuteProgram: NULL function");
	}
	
	f = &pr_functions[fnum];

	runaway = 100000;
	pr_trace = false;

// make a stack frame
	exitdepth = pr_depth;

	s = PR_EnterFunction (f);
	
while (1)
{
	s++;	// next statement

	st  = &pr_statements[s];
	st7 = &pr_statements7[s];
#define ST(field)	(pr_statements? st->field : st7->field)

	if (pr_statements) {			// progs v6 NUMGLOBALS QF hack
		int ofsa = st->a;
		int ofsb = st->b;
		int ofsc = st->c;
		if (st->a & 0x8000) ofsa = (int)st->a + 0xFFFF;
		if (st->b & 0x8000) ofsb = (int)st->b + 0xFFFF;
		if (st->c & 0x8000) ofsc = (int)st->c + 0xFFFF;
		a = (eval_t *)&pr_globals[ofsa];
		b = (eval_t *)&pr_globals[ofsb];
		c = (eval_t *)&pr_globals[ofsc];
	} else {				// KK progs v7+
		a = (eval_t *)&pr_globals[st7->a];
		b = (eval_t *)&pr_globals[st7->b];
		c = (eval_t *)&pr_globals[st7->c];
	}
	
	if (--runaway == 0)
		PR_RunError ("runaway loop error");
		
	pr_xfunction->profile++;
	pr_xstatement = s;
	
	if (pr_trace)
		PR_PrintStatement (s);
		
	switch (ST(op))
	{
	case OP_ADD_F:
		c->_float = a->_float + b->_float;
		break;
	case OP_ADD_V:
		c->vector[0] = a->vector[0] + b->vector[0];
		c->vector[1] = a->vector[1] + b->vector[1];
		c->vector[2] = a->vector[2] + b->vector[2];
		break;
		
	case OP_SUB_F:
		c->_float = a->_float - b->_float;
		break;
	case OP_SUB_V:
		c->vector[0] = a->vector[0] - b->vector[0];
		c->vector[1] = a->vector[1] - b->vector[1];
		c->vector[2] = a->vector[2] - b->vector[2];
		break;

	case OP_MUL_F:
		c->_float = a->_float * b->_float;
		break;
	case OP_MUL_V:
		c->_float = a->vector[0]*b->vector[0]
				+ a->vector[1]*b->vector[1]
				+ a->vector[2]*b->vector[2];
		break;
	case OP_MUL_FV:
		c->vector[0] = a->_float * b->vector[0];
		c->vector[1] = a->_float * b->vector[1];
		c->vector[2] = a->_float * b->vector[2];
		break;
	case OP_MUL_VF:
		c->vector[0] = b->_float * a->vector[0];
		c->vector[1] = b->_float * a->vector[1];
		c->vector[2] = b->_float * a->vector[2];
		break;

	case OP_DIV_F:
		c->_float = a->_float / b->_float;
		break;
	
	case OP_BITAND:
		c->_float = (int)a->_float & (int)b->_float;
		break;
	
	case OP_BITOR:
		c->_float = (int)a->_float | (int)b->_float;
		break;
	
		
	case OP_GE:
		c->_float = a->_float >= b->_float;
		break;
	case OP_LE:
		c->_float = a->_float <= b->_float;
		break;
	case OP_GT:
		c->_float = a->_float > b->_float;
		break;
	case OP_LT:
		c->_float = a->_float < b->_float;
		break;
	case OP_AND:
		c->_float = a->_float && b->_float;
		break;
	case OP_OR:
		c->_float = a->_float || b->_float;
		break;
		
	case OP_NOT_F:
		c->_float = !a->_float;
		break;
	case OP_NOT_V:
		c->_float = !a->vector[0] && !a->vector[1] && !a->vector[2];
		break;
	case OP_NOT_S:
		c->_float = !a->string || !*PR_GetString(a->string);
		break;
	case OP_NOT_FNC:
		c->_float = !a->function;
		break;
	case OP_NOT_ENT:
		c->_float = (PROG_TO_EDICT(a->edict) == sv.edicts);
		break;

	case OP_EQ_F:
		c->_float = a->_float == b->_float;
		break;
	case OP_EQ_V:
		c->_float = (a->vector[0] == b->vector[0]) &&
					(a->vector[1] == b->vector[1]) &&
					(a->vector[2] == b->vector[2]);
		break;
	case OP_EQ_S:
		c->_float = !strcmp(PR_GetString(a->string), PR_GetString(b->string));
		break;
	case OP_EQ_E:
		c->_float = a->_int == b->_int;
		break;
	case OP_EQ_FNC:
		c->_float = a->function == b->function;
		break;


	case OP_NE_F:
		c->_float = a->_float != b->_float;
		break;
	case OP_NE_V:
		c->_float = (a->vector[0] != b->vector[0]) ||
					(a->vector[1] != b->vector[1]) ||
					(a->vector[2] != b->vector[2]);
		break;
	case OP_NE_S:
		c->_float = strcmp(PR_GetString(a->string), PR_GetString(b->string));
		break;
	case OP_NE_E:
		c->_float = a->_int != b->_int;
		break;
	case OP_NE_FNC:
		c->_float = a->function != b->function;
		break;

//==================
	case OP_STORE_F:
	case OP_STORE_ENT:
	case OP_STORE_FLD:		// integers
	case OP_STORE_S:
	case OP_STORE_FNC:		// pointers
		b->_int = a->_int;
		break;
	case OP_STORE_V:
		b->vector[0] = a->vector[0];
		b->vector[1] = a->vector[1];
		b->vector[2] = a->vector[2];
		break;
		
	case OP_STOREP_F:
	case OP_STOREP_ENT:
	case OP_STOREP_FLD:		// integers
	case OP_STOREP_S:
	case OP_STOREP_FNC:		// pointers
		ptr = (eval_t *)((byte *)sv.edicts + b->_int);
		ptr->_int = a->_int;
		break;
	case OP_STOREP_V:
		ptr = (eval_t *)((byte *)sv.edicts + b->_int);
		ptr->vector[0] = a->vector[0];
		ptr->vector[1] = a->vector[1];
		ptr->vector[2] = a->vector[2];
		break;
		
	case OP_ADDRESS:
		ed = PROG_TO_EDICT(a->edict);
#ifdef PARANOID
		NUM_FOR_EDICT(ed);		// make sure it's in range
#endif
		if (ed == (edict_t *)sv.edicts && sv.state == ss_active)
			PR_RunError ("assignment to world entity");
		c->_int = (byte *)((int *)&ed->v + b->_int) - (byte *)sv.edicts;
		break;
		
	case OP_LOAD_F:
	case OP_LOAD_FLD:
	case OP_LOAD_ENT:
	case OP_LOAD_S:
	case OP_LOAD_FNC:
		ed = PROG_TO_EDICT(a->edict);
#ifdef PARANOID
		NUM_FOR_EDICT(ed);		// make sure it's in range
#endif
		a = (eval_t *)((int *)&ed->v + b->_int);
		c->_int = a->_int;
		break;

	case OP_LOAD_V:
		ed = PROG_TO_EDICT(a->edict);
#ifdef PARANOID
		NUM_FOR_EDICT(ed);		// make sure it's in range
#endif
		a = (eval_t *)((int *)&ed->v + b->_int);
		c->vector[0] = a->vector[0];
		c->vector[1] = a->vector[1];
		c->vector[2] = a->vector[2];
		break;
		
//==================

	case OP_IFNOT:
		//if (st->b & 0x8000) Sys_Printf("Whooops on b in ifnot\n");
		if (!a->_int)
			s += ST(b) - 1;	// offset the s++
		break;
		
	case OP_IF:
		//if (st->b & 0x8000) Sys_Printf("Whooops on b in if\n");
		if (a->_int)
			s += ST(b) - 1;	// offset the s++
		break;
		
	case OP_GOTO:
		//if (st->a & 0x8000) Sys_Printf("Whooops on a in goto\n");
		s += ST(a) - 1;	// offset the s++
		break;
		
	case OP_CALL0:
	case OP_CALL1:
	case OP_CALL2:
	case OP_CALL3:
	case OP_CALL4:
	case OP_CALL5:
	case OP_CALL6:
	case OP_CALL7:
	case OP_CALL8:
		pr_argc = ST(op) - OP_CALL0;
		if (!a->function)
			PR_RunError ("NULL function");

		newf = &pr_functions[a->function];

		if (newf->first_statement < 0)
		{	// negative statements are built in functions
			i = -newf->first_statement;
			if (i >= pr_numbuiltins)
				PR_RunError ("Bad builtin call number");
			pr_builtins[i] ();
			break;
		}

		s = PR_EnterFunction (newf);
		break;

	case OP_DONE:
	case OP_RETURN:
		//if (st->a & 0x8000) Sys_Printf("Whooops on a in return\n");
		pr_globals[OFS_RETURN] = pr_globals[ST(a)];
		pr_globals[OFS_RETURN+1] = pr_globals[ST(a)+1];
		pr_globals[OFS_RETURN+2] = pr_globals[ST(a)+2];
	
		s = PR_LeaveFunction ();
		if (pr_depth == exitdepth)
			return;		// all done
		break;
		
	case OP_STATE:
		ed = PROG_TO_EDICT(pr_global_struct->self);
		ed->v.nextthink = pr_global_struct->time + 0.1;
		if (a->_float != ed->v.frame)
		{
			ed->v.frame = a->_float;
		}
		ed->v.think = b->function;
		break;
		
	default:
		PR_RunError ("Bad opcode %i", ST(op));
	}
}

}

/*----------------------*/

char *pr_strtbl[MAX_PRSTR];
int num_prstr;

char *PR_GetString(int num)
{
	if (num < 0) {
//Con_DPrintf("GET:%d == %s\n", num, pr_strtbl[-num]);
		return pr_strtbl[-num];
	}
	return pr_strings + num;
}

int PR_SetString(char *s)
{
	int i;

	if (s - pr_strings < 0) {
		for (i = 0; i <= num_prstr; i++)
			if (pr_strtbl[i] == s)
				break;
		if (i < num_prstr)
			return -i;
		if (num_prstr == MAX_PRSTR - 1)
			Sys_Error("MAX_PRSTR");
		num_prstr++;
		pr_strtbl[num_prstr] = s;
//Con_DPrintf("SET:%d == %s\n", -num_prstr, s);
		return -num_prstr;
	}
	return (int)(s - pr_strings);
}

//=====================================================
// OfN - Crash log related functions

extern cvar_t sv_crashlog;

void CrashLog_Start()
{
	char	name[MAX_OSPATH];
	char* timestamp;
	time_t timedata;

	//if (Cvar_VariableValue("sv_crashlog")==0)
	if (sv_crashlog.value == 0 || crashlog_running) // this better than the above :)
		return;
	
	timedata = time(NULL);
	timestamp = ctime(&timedata);
	
	sprintf (name, "%s/crash.log", com_gamedir);
	
	crashlog_file = fopen(name,"a");

	if (crashlog_file)
	{				
		fprintf(crashlog_file,"=================================\nCrash on %s=================================\n",timestamp);
		crashlog_running = true;
	}
	else
		Con_Printf("Crash log file initialization failed!\n");
}

void CrashLog_Append(char* text)
{
	if (!crashlog_running || !crashlog_file) return;

	fprintf(crashlog_file, "%s", text);
}

void CrashLog_End()
{
	if (!crashlog_running) return;

	crashlog_running = false;
	
	if (crashlog_file)
		fclose(crashlog_file);
}

//============================================================
// Used for string buffer discarding, returns parent function

dfunction_t* PR_GetReturningFunction()
{	
	return pr_stack[pr_depth-1].f;
}
