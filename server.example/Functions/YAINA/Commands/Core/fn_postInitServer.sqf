/*
	author: Martin
	description: none
	returns: nothing
*/

#include "..\defines.h"

if(isServer) then {

    // we dispatch a list of server commands to clients
    GVAR(commands) = [
        ["help", "credits", "addcredits", "mmpause", "mmstart", "mmlist", "mmstop", "report", "setadmin", "settrait", "revive","zeuslist", "zeusadd", "zeusdel", "abusemsg", "ffmsg", "helimsg", "hqmsg", "lwmsg", "mertmsg", "pilotmsg", "uavmsg", "ugmsg", "vehmsg", "30mban", "24hban", "72hban", "servermsg"],
        [0, 0, 3, 3, 3, 3, 3, 0, 3, 3, 3, 3,3,3, 1,1,1,1,1,1,1,1,1,1,3,3,3, 0]
    ];

    GVAR(becCommands) = ["30mban", "24hban", "72hban"];

    publicVariable QVAR(commands);
    publicVariable QVAR(becCommands);

    _cmdMax = 0;
    { if (_x > _cmdMax) then { _cmdMax = _x; }; true } count ((GVAR(commands) select 0) apply { count _x; });
    GVAR(cmdMax) = _cmdMax;

};