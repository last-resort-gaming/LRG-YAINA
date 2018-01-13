#include "..\defines.h"

#define PREFIX  YAINA_MM

#define FNC(s)  ##PREFIX##_fnc_##s
#define GVAR(s) ##PREFIX##_##s
#define QVAR(s) Q(GVAR(s))
#define QFNC(s) Q(FNC(s))

#define OFNC(s) ##PREFIX##_OBJ_fnc_##s
#define QOFNC(s) Q(OFNC(s))

#define INCR(s) s = (s) + 1

#define SFNC(s) YAINA_SPAWNS##_fnc_##s

#define CONCURRENT_MAOs 2
#define CONCURRENT_IAOs 1