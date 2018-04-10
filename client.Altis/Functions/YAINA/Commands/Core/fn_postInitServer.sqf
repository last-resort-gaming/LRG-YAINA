  /*
	author: Martin
	description: none
	returns: nothing
*/

#include "..\defines.h"

if !(isServer) exitWith {};

// Pass Through Commands
GVAR(becCommands) = ["60mban", "24hban", "72hban", "hrestart"];
publicVariable QVAR(becCommands);

// Mapping of commands to individual owners
GVAR(commands) = [[], []];

// We dump the commands into the ownerIDs when folks log so to refersh their
// Commands list they just need to re-log
addMissionEventHandler["PlayerConnected", {

    params ["_id", "_uid", "_name", "_jip", "_owner"];

    // Already Set ?
    _cmds = [_uid, 'yaina', [], ['ALL']] call YFNC(getDBKey);

    // We always add 'report', 'credits', 'help'
    { _cmds pushBackUnique _x, nil; } count ['report', 'credits', 'help'];

    _idx  = (GVAR(commands) select 0) find _owner;
    if (_idx isEqualTo -1) then {
        (GVAR(commands) select 0) pushBack _owner;
        (GVAR(commands) select 1) pushBack _cmds;
    } else {
        (GVAR(commands) select 1) set [_idx, _cmds];
    };

}];

addMissionEventHandler["PlayerDisconnected", {

    params ["_id", "_uid", "_name", "_jip", "_owner"];

    _idx  = (GVAR(commands) select 0) find _owner;
    if (_idx isEqualTo -1) then {
        (GVAR(commands) select 0) deleteAt _idx;
        (GVAR(commands) select 1) deleteAt _idx;
    };

}];
