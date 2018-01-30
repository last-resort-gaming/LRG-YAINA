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
        [{  SERVER_COMMAND_PASSWORD serverCommand _this; }, format ["#kick %1", _puid], 5] call CBAP_fnc_waitAndExecute;

        [format ["ZeusRestriction: %1 (2) was removed from the slot", name _player, _puid]] call YFNC(log)
    };
};