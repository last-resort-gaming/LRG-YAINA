#include "..\defines.h"

#define PREFIX  YAINA_METRICS

#define FNC(s)  ##PREFIX##_fnc_##s
#define GVAR(s) ##PREFIX##_##s
#define QVAR(s) Q(GVAR(s))
#define QFNC(s) Q(FNC(s))