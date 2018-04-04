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
    _cmds = [_uid, 'yaina', ['report', 'credits', 'help'], ['ALL']] call YFNC(getDBKey);
    _idx  = (GVAR(commands) select 0) find _owner;
    if (_idx isEqualTo -1) then {
        (GVAR(commands) select 0) pushBack _owner;
        (GVAR(commands) select 1) pushBack (_cmds + ['report', 'credits', 'help']);
    } else {
        (GVAR(commands) select 1) set [_idx, (_cmds + ['report', 'credits', 'help'])];
    };

    // Now...If a command doesn't exist / isn't a BEC command then it's a TRAIT
    private _serverTraits = [];
    {
        if !(_x isEqualTo "ALL") then {
            private _cmd = missionNamespace getVariable format["YAINA_CMD_fnc_%1", _x];
            if (isNil "_cmd" && { !(_x in GVAR(becCommands)) } ) then {
                _serverTraits pushBack _x;
            };
        };
    } forEach _cmds;

    // Send the traits to the client
    YVAR(GLOBAL_TRAITS) = _serverTraits;
    _owner publicVariableClient QYVAR(GLOBAL_TRAITS);

}];

addMissionEventHandler["PlayerDisconnected", {

    params ["_id", "_uid", "_name", "_jip", "_owner"];

    _idx  = (GVAR(commands) select 0) find _owner;
    if (_idx isEqualTo -1) then {
        (GVAR(commands) select 0) deleteAt _idx;
        (GVAR(commands) select 1) deleteAt _idx;
    };

}];
