#define VEH_PREFIX  YAINA_VEH

#define Q(s) #s
#define FNC(s)  ##VEH_PREFIX##_fnc_##s
#define GVAR(s) ##VEH_PREFIX##_##s
#define QVAR(s) Q(GVAR(s))
#define QFNC(s) Q(FNC(s))