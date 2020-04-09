/*
Function: YAINA_ZEUS_fnc_zeusConnected

Description:
	Handles initialization if a Zeus connected to the server,
    checks if they have access to the slot and sets up the migration.

Parameters:
	_player - The player that connected

Return Values:
	None

Examples:
    Nothing to see here

Author:
	Martin
*/

//if(!isServer) exitWith {};
//if(remoteExecutedOwner isEqualTo 0) exitWith {};

#include "defines.h"

params ["_player"];

if ((owner _player) isEqualTo remoteExecutedOwner) then {
    private _puid = getPlayerUID _player;

    // Do they have zeus access ?
    private _idx = (YVAR(zeuslist) select 0) find _puid;

    // Whitelisting only affects the virtual slots
    if ((typeOf _player) isEqualTo "VirtualCurator_F" && { _idx isEqualTo -1 } && { !([['zeus-whitelist'], _player] call YFNC(testTraits)) } ) then {

        // We tell the client to fail, and we schedule a kick
        [{ ["ZeusSlotRestricted", false, 2, false, false] call BIS_fnc_endMission; }] remoteExec["call", remoteExecutedOwner];

        // we kick so they really have gone from the slot and can't just abuse idle
        [{  SERVER_COMMAND_PASSWORD serverCommand _this; }, format ["#kick %1", _puid], 15] call CBA_fnc_waitAndExecute;

        [format ['event: ascention, allowed: false, player: %1, playerguid: %2', name _player, _puid], "ZeusLog"] call YFNC(log);
    } else {

        // If they're one of our special slots, we need to move them to blufor

        if ((typeOf _player) isEqualTo "VirtualCurator_F") then {
            if (isNil { (group _player) getVariable QVAR(playerInit) } ) then {

                // We are allowed, so now we create a group for this zeuser on west, and register the group in groups so
                // everyone can see they're online, and once they've switched side, we allow them to talk on side + command

                _n = "Zeus";

                if (isPlayer zeus1 && zeus1 isEqualTo _player) then {
                    _n = "Zeus 1";
                };
                if (isPlayer zeus2 && zeus2 isEqualTo _player) then {
                    _n = "Zeus 2";
                };
                if (isPlayer zeus3 && zeus3 isEqualTo _player) then {
                    _n = "Zeus 3";
                };
                if (isPlayer zeus4 && zeus4 isEqualTo _player) then {
                    _n = "Zeus 4";
                };


				_g = createGroup west;
                _g setVariable [QVAR(playerInit), true];
                [_player] joinSilent _g;

                ["RegisterGroup", [_g, _player, [nil, _n, false]]] call BIS_fnc_dynamicGroups;
                ["SetPrivateState", [_g, true]] call BIS_fnc_dynamicGroups;

                [[], {
                    1 enableChannel true;
                    2 enableChannel true;
                    // Use CHVD distance if available
                    _vd = ((profileNamespace getVariable ["CHVD_air",   viewDistance]) min 12000);
                    _vo = ((profileNamespace getVariable ["CHVD_airObj",viewDistance]) min 12000);
                    diag_log format["setting vd/vo to %1 %2", _vd, _vo];
                    setViewDistance _vd;
                    setObjectViewDistance _vo;
                }] remoteExec ["call", remoteExecutedOwner];

                // Show the assention message to everyone
                ["CuratorAssign", [_n, name _player]] remoteExec ["bis_fnc_showNotification"];
            };
        };


        [[], {
            // Use CHVD distance if available
            _vd = ((profileNamespace getVariable ["CHVD_air", viewDistance]) min 12000);
            _vo = ((profileNamespace getVariable ["CHVD_airObj",viewDistance]) min 12000);
            setViewDistance _vd;
            diag_log format["setting vd/vo to %1 %2 part 2", _vd, _vo];
            setObjectViewDistance _vo;
        }] remoteExec ["call", remoteExecutedOwner];

        // Catch any new units that maybe lurking around from modules that don't add to all curators
        (getAssignedCuratorLogic _player) addCuratorEditableObjects [allUnits, true];

        // Log ascention
        [format ['event: ascention, allowed: true, player: %1, playerguid: %2', name _player, _puid], "ZeusLog"] call YFNC(log);

        // Now start the PFH
        [] remoteExec [QFNC(startPFH), remoteExecutedOwner];

    };
};