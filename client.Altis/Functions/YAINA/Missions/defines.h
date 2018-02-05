
#define PREFIX  YAINA_MM

#define OFNC(s) ##PREFIX##_OBJ_fnc_##s
#define QOFNC(s) Q(OFNC(s))
#define SFNC(s) YAINA_SPAWNS##_fnc_##s
#define QSFNC(s) Q(SFNC(s))

#define CONCURRENT_MAOs 2
#define CONCURRENT_IAOs 1

// GENERAL INCLUDE
#include "..\defines.h"
