#include "..\defines.h"

#define SPAWNS_PREFIX  YAINA_SPAWNS

#define FNC(s)  ##SPAWNS_PREFIX##_fnc_##s
#define GVAR(s) ##SPAWNS_PREFIX##_##s
#define QVAR(s) Q(GVAR(s))
#define QFNC(s) Q(FNC(s))
