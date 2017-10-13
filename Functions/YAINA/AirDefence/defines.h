#include "..\defines.h"

#define PREFIX  YAINA_AD

#define FNC(s)  ##PREFIX##_fnc_##s
#define GVAR(s) ##PREFIX##_##s

#define AIR_DEFENCES [ \
    AirDefence1, \
    AirDefence2, \
    AirDefence3, \
    AirDefence4, \
    AirDefence5, \
    AirDefence6, \
    AirDefence7 \
]

#define AIR_DEFENCE_TERMINALS [ \
    AirDefenseSwitch1 \
]