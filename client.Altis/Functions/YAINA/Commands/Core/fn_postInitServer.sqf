  /*
	author: Martin
	description: none
	returns: nothing
*/

#include "..\defines.h"

if(isServer) then {

    // Pretty map of commands, easy to assign, but a pain to check against
    GVAR(commandMap) = [
        [
            5,
            4,
            3,
            2,
            1
        ],
        [
            ["help", "credits", "report"],
            ["abusemsg", "ffmsg", "helimsg", "hqmsg", "lwmsg", "mertmsg", "pilotmsg", "uavmsg", "ugmsg", "vehmsg", "warn", "kick", "60mban", "stable"],
            ["addcredits", "mmpause", "mmstart","mmlist", "mmstop", "revive", "restart", "24hban", "72hban"],
            ["setadmin", "settrait", "zeuslist", "zeusadd", "zeusdel", "hrestart"],
            []
        ]
    ];

    // So we format it to just an assoc array
    GVAR(commands) = [[], []];
    {
        _lvl = _x;
        {
            (GVAR(commands) select 0) pushBack _x;
            (GVAR(commands) select 1) pushBack _lvl;
            nil
        } count ((GVAR(commandMap) select 1) select _forEachIndex);
    } forEach (GVAR(commandMap) select 0);

    GVAR(becCommands) = ["60mban", "24hban", "72hban", "hrestart"];

    publicVariable QVAR(commands);
    publicVariable QVAR(becCommands);

};