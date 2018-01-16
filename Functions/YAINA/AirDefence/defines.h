#include "..\defines.h"

#define PREFIX  YAINA_AD

#define FNC(s)  ##PREFIX##_fnc_##s
#define QFNC(s) Q(FNC(s))
#define GVAR(s) ##PREFIX##_##s
