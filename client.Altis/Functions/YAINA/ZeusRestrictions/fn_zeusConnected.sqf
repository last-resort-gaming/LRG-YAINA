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

    // Whitelisting only affects the virtual slots
    if ((typeOf _player) isEqualTo "VirtualCurator_F" && { _idx isEqualTo -1 } ) then {

        // We tell the client to fail, and we schedule a kick
        [{ ["ZeusSlotRestricted", false, 2, false, false] call BIS_fnc_endMission; }] remoteExec["call", remoteExecutedOwner];

        // we kick so they really have gone from the slot and can't just abuse idle
        [{  SERVER_COMMAND_PASSWORD serverCommand _this; }, format ["#kick %1", _puid], 15] call CBAP_fnc_waitAndExecute;

        [format ['event: ascention, allowed: false, player: %1, playerguid: %2', name _player, _puid], "ZeusLog"] call YFNC(log)
    } else {

        // First Time ?
        if (isNil QVAR(playerInit)) then {
            GVAR(playerInit) = true;

            // If they're one of our special slots, we need to move them to blufor
            if ((typeOf player) isEqualTo "VirtualCurator_F") then {

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

                [[], {
                    1 enableChannel true;
                    2 enableChannel true;
                }] remoteExec ["call", remoteExecutedOwner];

                // Show the assention message to everyone
                ["CuratorAssign", [_n, name _player]] remoteExec ["bis_fnc_showNotification"];
            };
        };

        // Log ascention
        [format ['event: ascention, allowed: true, player: %1, playerguid: %2', name _player, _puid], "ZeusLog"] call YFNC(log);

        // Now start the PFH
        [] remoteExec [QFNC(startPFH), remoteExecutedOwner];

    };
};