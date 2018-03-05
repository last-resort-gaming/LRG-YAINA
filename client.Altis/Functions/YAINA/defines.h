// Common defines for all YAINA

#include "map_defines.h"

//////////////////////////////////////////////
// GLOBALS
//////////////////////////////////////////////

#define Q(s) #s
#define YVAR(s) YAINA_##s
#define QYVAR(s) Q(YVAR(s))
#define YFNC(s) YAINA_fnc_##s
#define QYFNC(s) Q(YFNC(s))

#define INCR(s) s = (s) + 1
#define LTIME ([serverTime, time] select isServer)

//////////////////////////////////////////////
// PREFIXED
//////////////////////////////////////////////

#define FNC(s)  ##PREFIX##_fnc_##s
#define QFNC(s) Q(FNC(s))
#define GVAR(s) ##PREFIX##_##s
#define QVAR(s) Q(GVAR(s))

//////////////////////////////////////////////
// FROM CBA
//////////////////////////////////////////////
#define DEBUG_MODE_FULL 1

/* -------------------------------------------
Macros: ARR_#()
    Create list from arguments. Useful for working around , in macro parameters.
    1-8 arguments possible.

Parameters:
    VARIABLE(1-8) - elements for the list

Author:
    Nou
------------------------------------------- */
#define ARR_1(ARG1) ARG1
#define ARR_2(ARG1,ARG2) ARG1, ARG2
#define ARR_3(ARG1,ARG2,ARG3) ARG1, ARG2, ARG3
#define ARR_4(ARG1,ARG2,ARG3,ARG4) ARG1, ARG2, ARG3, ARG4
#define ARR_5(ARG1,ARG2,ARG3,ARG4,ARG5) ARG1, ARG2, ARG3, ARG4, ARG5
#define ARR_6(ARG1,ARG2,ARG3,ARG4,ARG5,ARG6) ARG1, ARG2, ARG3, ARG4, ARG5, ARG6
#define ARR_7(ARG1,ARG2,ARG3,ARG4,ARG5,ARG6,ARG7) ARG1, ARG2, ARG3, ARG4, ARG5, ARG6, ARG7
#define ARR_8(ARG1,ARG2,ARG3,ARG4,ARG5,ARG6,ARG7,ARG8) ARG1, ARG2, ARG3, ARG4, ARG5, ARG6, ARG7, ARG8

/* -------------------------------------------
Macro: RETDEF()
    If a variable is undefined, return the default value. Otherwise, return the
    variable itself.

Parameters:
    VARIABLE - the variable to check
    DEFAULT_VALUE - the default value to use if variable is undefined

Example:
    (begin example)
        // _var is undefined
        hintSilent format ["_var=%1", RETDEF(_var,5)]; // "_var=5"
        _var = 7;
        hintSilent format ["_var=%1", RETDEF(_var,5)]; // "_var=7"
    (end example)
Author:
    654wak654
------------------------------------------- */
#define RETDEF(VARIABLE,DEFAULT_VALUE) (if (isNil {VARIABLE}) then [{DEFAULT_VALUE}, {VARIABLE}])

/* -------------------------------------------
Macro: RETNIL()
    If a variable is undefined, return the value nil. Otherwise, return the
    variable itself.

Parameters:
    VARIABLE - the variable to check

Example:
    (begin example)
        // _var is undefined
        hintSilent format ["_var=%1", RETNIL(_var)]; // "_var=any"
    (end example)

Author:
    Alef (see CBA issue #8514)
------------------------------------------- */
#define RETNIL(VARIABLE) RETDEF(VARIABLE,nil)

/* -------------------------------------------

Macros: TRACE_n()
    Log a message and 1-8 variables to the RPT log.

    Only run if <DEBUG_MODE_FULL> is defined.

    TRACE_1(MESSAGE,A) - Log 1 variable.
    TRACE_2(MESSAGE,A,B) - Log 2 variables.
    TRACE_3(MESSAGE,A,B,C) - Log 3 variables.
    TRACE_4(MESSAGE,A,B,C,D) - Log 4 variables.
    TRACE_5(MESSAGE,A,B,C,D,E) - Log 5 variables.
    TRACE_6(MESSAGE,A,B,C,D,E,F) - Log 6 variables.
    TRACE_7(MESSAGE,A,B,C,D,E,F,G) - Log 7 variables.
    TRACE_8(MESSAGE,A,B,C,D,E,F,G,H) - Log 8 variables.
    TRACE_9(MESSAGE,A,B,C,D,E,F,G,H,I) - Log 9 variables.

Parameters:
    MESSAGE -  Message to add to the trace [String]
    A..H - Variable names to log values of [Any]

Example:
    (begin example)
        TRACE_3("After takeoff",_vehicle player,getPos (_vehicle player), getPosASL (_vehicle player));
    (end)

Author:
    Spooner
------------------------------------------- */
#define PFORMAT_1(MESSAGE,A) \
    format ['%1: A=%2', MESSAGE, RETNIL(A)]

#define PFORMAT_2(MESSAGE,A,B) \
    format ['%1: A=%2, B=%3', MESSAGE, RETNIL(A), RETNIL(B)]

#define PFORMAT_3(MESSAGE,A,B,C) \
    format ['%1: A=%2, B=%3, C=%4', MESSAGE, RETNIL(A), RETNIL(B), RETNIL(C)]

#define PFORMAT_4(MESSAGE,A,B,C,D) \
    format ['%1: A=%2, B=%3, C=%4, D=%5', MESSAGE, RETNIL(A), RETNIL(B), RETNIL(C), RETNIL(D)]

#define PFORMAT_5(MESSAGE,A,B,C,D,E) \
    format ['%1: A=%2, B=%3, C=%4, D=%5, E=%6', MESSAGE, RETNIL(A), RETNIL(B), RETNIL(C), RETNIL(D), RETNIL(E)]

#define PFORMAT_6(MESSAGE,A,B,C,D,E,F) \
    format ['%1: A=%2, B=%3, C=%4, D=%5, E=%6, F=%7', MESSAGE, RETNIL(A), RETNIL(B), RETNIL(C), RETNIL(D), RETNIL(E), RETNIL(F)]

#define PFORMAT_7(MESSAGE,A,B,C,D,E,F,G) \
    format ['%1: A=%2, B=%3, C=%4, D=%5, E=%6, F=%7, G=%8', MESSAGE, RETNIL(A), RETNIL(B), RETNIL(C), RETNIL(D), RETNIL(E), RETNIL(F), RETNIL(G)]

#define PFORMAT_8(MESSAGE,A,B,C,D,E,F,G,H) \
    format ['%1: A=%2, B=%3, C=%4, D=%5, E=%6, F=%7, G=%8, H=%9', MESSAGE, RETNIL(A), RETNIL(B), RETNIL(C), RETNIL(D), RETNIL(E), RETNIL(F), RETNIL(G), RETNIL(H)]

#define PFORMAT_9(MESSAGE,A,B,C,D,E,F,G,H,I) \
    format ['%1: A=%2, B=%3, C=%4, D=%5, E=%6, F=%7, G=%8, H=%9, I=%10', MESSAGE, RETNIL(A), RETNIL(B), RETNIL(C), RETNIL(D), RETNIL(E), RETNIL(F), RETNIL(G), RETNIL(H), RETNIL(I)]


#ifdef DEBUG_MODE_FULL
#define TRACE(MESSAGE) diag_log str diag_frameNo + ' ' + (MESSAGE)
#define TRACE_1(MESSAGE,A) diag_log PFORMAT_1(str diag_frameNo + ' ' + (MESSAGE),A)
#define TRACE_2(MESSAGE,A,B) diag_log PFORMAT_2(str diag_frameNo + ' ' + (MESSAGE),A,B)
#define TRACE_3(MESSAGE,A,B,C) diag_log PFORMAT_3(str diag_frameNo + ' ' + (MESSAGE),A,B,C)
#define TRACE_4(MESSAGE,A,B,C,D) diag_log PFORMAT_4(str diag_frameNo + ' ' + (MESSAGE),A,B,C,D)
#define TRACE_5(MESSAGE,A,B,C,D,E) diag_log PFORMAT_5(str diag_frameNo + ' ' + (MESSAGE),A,B,C,D,E)
#define TRACE_6(MESSAGE,A,B,C,D,E,F) diag_log PFORMAT_6(str diag_frameNo + ' ' + (MESSAGE),A,B,C,D,E,F)
#define TRACE_7(MESSAGE,A,B,C,D,E,F,G) diag_log PFORMAT_7(str diag_frameNo + ' ' + (MESSAGE),A,B,C,D,E,F,G)
#define TRACE_8(MESSAGE,A,B,C,D,E,F,G,H) diag_log PFORMAT_8(str diag_frameNo + ' ' + (MESSAGE),A,B,C,D,E,F,G,H)
#define TRACE_9(MESSAGE,A,B,C,D,E,F,G,H,I) diag_log PFORMAT_9(str diag_frameNo + ' ' + (MESSAGE),A,B,C,D,E,F,G,H,I)
#else
#define TRACE(MESSAGE) /* disabled */
#define TRACE_1(MESSAGE,A) /* disabled */
#define TRACE_2(MESSAGE,A,B) /* disabled */
#define TRACE_3(MESSAGE,A,B,C) /* disabled */
#define TRACE_4(MESSAGE,A,B,C,D) /* disabled */
#define TRACE_5(MESSAGE,A,B,C,D,E) /* disabled */
#define TRACE_6(MESSAGE,A,B,C,D,E,F) /* disabled */
#define TRACE_7(MESSAGE,A,B,C,D,E,F,G) /* disabled */
#define TRACE_8(MESSAGE,A,B,C,D,E,F,G,H) /* disabled */
#define TRACE_9(MESSAGE,A,B,C,D,E,F,G,H,I) /* disabled */
#endif
