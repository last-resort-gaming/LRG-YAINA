#include "..\defines.h"

#define PREFIX  YAINA_AD

#define FNC(s)  ##PREFIX##_fnc_##s
#define GVAR(s) ##PREFIX##_##s

#define AIR_DEFENCES [ \
    HQ_AA1C, \
    HQ_AA2C, \
    HQ_AA3C, \
    HQ_AA4C, \
    USS_AA1, \
    USS_AA2, \
    USS_AA3, \
    USS_AA4, \
    USS_AA5, \
    USS_AA6, \
    USS_AA7, \
    INS_AA1C, \
    INS_AA2C \
]

#define AIR_DEFENCE_TERMINALS [ \
    AirDefenceSwitch1, \
    AirDefenceSwitch2, \
    Laptop_USS_F \
]