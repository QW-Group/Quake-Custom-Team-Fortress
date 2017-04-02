/*================================================================//
// cppreqcc.h              CPpreQCC 1.4 - Preprocessor for QuakeC //
//----------------------------------------------------------------//
// Written using borland C++ 5 by OfteN[cp] aka SuperCOCK2000 :)  //
//================================================================//
// Program constants and function declarations                    //
//================================================================*/

// Functions
void ErrorExit(char *msg);
void PerformCleanUp ();
void PrintIt (char* what);
void PrintSourceWarning (char* thefile, int theline, char* what);
void PrintSourceError (char* thefile, int theline, char* what);
void PrintSourceInfo (char* thefile, int theline, char* what);
void PutFileInQueue(char* fname);
void PutParseInQueue(bool type, bool causes_parse);
void ResolveParseItem();
void InvertParseItem();
void SourceErrorExit();
void ProcessFile();
bool CharIsSeparator(char tchar);
//bool CharIsNewLine(char tchar);
int GetKeywordType(int curpos);
int GetPragmaType(int curpos);
bool DirectiveWantsData(int tkeyw);
void ExecuteDirective(int curpos);
unsigned int IsDefined(char* ident);
void WriteOutChar(char data);
void PutDefineInList(char* ident, char* value);
void ExpandTargetMem();
int IsNotEmpty(char* tstr);
//bool PragmaWantsData(int tkeyw);
void ExecutePragma(int curpos);
void CleanStr(char* tstr);
void UndefineItem(unsigned int numdefine);
unsigned int IsInDefList(char* ident);
bool IsValidEndList(unsigned int curpos);
bool IsEmptyChar(char tchar);
int GetDirectiveType(char* tkey);
void ParseValue(char* tvalue);
void ChangeFilename(char *fname);
void PrintFile (FILE*, char*);
void CheckUnused();

// String messages
#define ST_START    "CPPreQCC v1.5 - Written by OfteN[cp] for Prozac CustomTF\nInitializing...\n"
#define ST_SUCCESS  "Job done! Have a nice day.\nTime for compiler errors.. :)\n"
#define ST_BOXERROR "wtf.. ERROR, damnit!"

// preprogs filename default - TODO: make command line param
#define ST_PREPROGS_SRC "preprogs.src"
#define ST_SEPARATORS " !*+-=)(/,.><{}\""
#define NUM_SEPARATORS 16

// Several stuff maximums
#define MAX_FILE_QUEUE    256// max files to process
#define MAX_PARSE_QUEUE    16// max depth of consecutive IFDEF or IFNDEFS
#define MAX_ST_SIZE       256// maximum string size
#define MAX_DEFINES      4096 // PZ: doubled it

// line Scan status flags
#define SCN_STATUS_IDLE         0//write output, searching for anything
#define SCN_STATUS_KEYWORD      1//skips output, awaiting a directive or define identifier
#define SCN_STATUS_VALUE        2//skips output, awaiting some kind of value (after a define or a pragma)
#define SCN_STATUS_LIST         3//skips output, we r inside an include list
#define SCN_STATUS_PRAGMA       4//skips output, awaiting the pragma keyword
#define SCN_STATUS_DEFINE       5//skips output, we r waiting for the defined value after a IFDEF, UNDEF, DEFINE or IFNDEF

//===============================================================
// DIRECTIVES

// Supported directives
#define ST_DIR_IFDEF        "ifdef"
#define ST_DIR_IFNDEF       "ifndef"
#define ST_DIR_ELSE         "else"
#define ST_DIR_ENDIF        "endif"
#define ST_DIR_DEFINE       "define"
#define ST_DIR_UNDEF        "undef"
#define ST_DIR_PRAGMA       "pragma"
#define ST_DIR_INCLUDELIST  "includelist"
#define ST_DIR_ENDLIST      "endlist"
#define ST_DIR_INCLUDE      "include"

// directives ID // GetDirective() return values
#define DIRECTIVE_IDENT         0//not a directive, an identifier probably
#define DIRECTIVE_IFDEF         1
#define DIRECTIVE_IFNDEF        2
#define DIRECTIVE_ELSE          3
#define DIRECTIVE_ENDIF         4
#define DIRECTIVE_DEFINE        5
#define DIRECTIVE_UNDEF         6
#define DIRECTIVE_PRAGMA        7
#define DIRECTIVE_INCLUDELIST   8
#define DIRECTIVE_ENDLIST       9
#define DIRECTIVE_INCLUDE       10

//================================================
// PRAGMAS

// Supported pragmas
#define ST_PRAGMA_COMPILE           "COMPILE_THIS_FILE"
#define ST_PRAGMA_NOCOMPILE         "DONT_COMPILE_THIS_FILE"
#define ST_PRAGMA_PROGSSRC          "PROGS_SRC"
#define ST_PRAGMA_PROGSDAT          "PROGS_DAT"
#define ST_PRAGMA_CHECKREDEFS_ON    "CHECK_REDEFINES_ON"
#define ST_PRAGMA_CHECKREDEFS_OFF   "CHECK_REDEFINES_OFF"
#define ST_PRAGMA_KEEPNEWLINES_ON   "KEEP_NEWLINES_ON"
#define ST_PRAGMA_KEEPNEWLINES_OFF  "KEEP_NEWLINES_OFF"
#define ST_PRAGMA_KEEPCOMMENTS_ON   "KEEP_COMMENTS_ON"
#define ST_PRAGMA_KEEPCOMMENTS_OFF  "KEEP_COMMENTS_OFF"
#define ST_PRAGMA_CHECKUNUSED_ON    "CHECK_UNUSED_ON"
#define ST_PRAGMA_CHECKUNUSED_OFF   "CHECK_UNUSED_OFF"

// pragmas ID // GetPragma() return values
#define PRAGMA_EMPTYSTILL       -1
#define PRAGMA_UNSUPPORTED      0//means error, or unknown pragma

#define PRAGMA_COMPILE          1//implemented
#define PRAGMA_NOCOMPILE        2//implemented

#define PRAGMA_PROGSSRC         3//TODO
#define PRAGMA_PROGSDAT         4//TODO

#define PRAGMA_CHECKREDEFS_ON   5//implemented
#define PRAGMA_CHECKREDEFS_OFF  6//implemented

#define PRAGMA_KEEPNEWLINES_ON  7//TODO
#define PRAGMA_KEEPNEWLINES_OFF 8//TODO

#define PRAGMA_KEEPCOMMENTS_ON  9//TODO
#define PRAGMA_KEEPCOMMENTS_OFF 10//TODO

#define PRAGMA_CHECKUNUSED_ON   11
#define PRAGMA_CHECKUNUSED_OFF  12

//=====================================
// PARSE TYPES

#define PARSE_IFDEF     0
#define PARSE_IFNDEF    1
