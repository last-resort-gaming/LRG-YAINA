/*
	author: Martin
	description: none
	returns: nothing
*/

//if(!isServer) exitWith {};
//if(remoteExecutedOwner isEqualTo 0) exitWith {};

#include "defines.h"

params ["_player"];

if ((owner _player) isEqualTo remoteExecutedOwner) then {
    private _puid = getPlayerUID _player;
    private _idx = (YVAR(zeuslist) select 0) find _puid;

    if (_idx isEqualTo -1) then {

        // We tell the client to fail, and we schedule a kick
        [{ ["ZeusSlotRestricted", false, 2, false, false] call BIS_fnc_endMission; }] remoteExec["call", remoteExecutedOwner];

        // we kick so they really have gone from the slot and can't just abuse idle
        [{  SERVER_COMMAND_PASSWORD serverCommand _this; }, format ["#kick %1", _puid], 15] call CBAP_fnc_waitAndExecute;

        [format ["ZeusRestriction: %1 (%2) was removed from the slot", name _player, _puid], "ZeusLog"] call YFNC(log)
    } else {
        // We are allowed, so now we create a group for this zeuser on west, and register the group in groups so
        // everyone can see they're online, and once they've switched side, we allow them to talk on side + command

        _n = "Zeus 1";
        if (isPlayer zeus2 && zeus2 isEqualTo _player) then {
            _n = "Zeus 2";
        };

        _g = createGroup west;
        [_player] joinSilent _g;

        ["RegisterGroup", [_g, _player, [nil, _n, false]]] call BIS_fnc_dynamicGroups;
        ["SetPrivateState", [_g, true]] call BIS_fnc_dynamicGroups;

        // Now we allow them to listen on side / command
        [[], {
            1 enableChannel true;
            2 enableChannel true;
        }] remoteExec ["call", remoteExecutedOwner];

    };
};