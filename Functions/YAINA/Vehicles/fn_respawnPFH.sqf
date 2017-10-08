/*
	author: Martin
	description: none
	returns: nothing
*/

#include "defines.h";

if(!isServer) exitWith {};

[{
    for "_i" from count(GVAR(respawnList)) to 0 step -1 do {
        (GVAR(respawnList) select _i) params ["_veh", "_vehType", "_pos", "_dir", "_loadout", "_respawnTime", "_abandonDistance", "_hasKeys"];

        // If the vehicle is not alive / null then we remove from the respawn
        // list and schedule a delete it in 30 seconds just in case it
        // doesn't get removed when not alive

        _respawn = false;

        if (!alive _veh || isNull _veh) then {

            GVAR(respawnList) deleteAt _i;

            // We do this so teh burn out can happen nicely if it's in that state
            [{ params ["_veh"]; if(!isNull "_veh") then { deleteVehicle _veh; }; }, [_veh], 30] call CBA_fnc_waitAndExecute;

            _respawn = true;

        } else {

            // If the vehicle is owned, then the abandonDistance is doubled;
            if(!isNil { _veh getVariable QVAR(owner) }) then { _abandonDistance =  _abandonDistance * 2; };

            // If players near, we can bail out
            if (call {
                {
                    if ((_veh distance2D _x) < _abandonDistance || {_veh distance2D _pos < 5}) exitWith {true};
                    false;
                } forEach allPlayers;
            }) exitWith {false};

            // Else we are abandoned, delete this and respawn
            GVAR(respawnList) deleteAt _i;
            deleteVehicle _veh;

            _respawn = true;
        };

        // Then we just trigger a respawn in _respawnTime
        if(_respawn) then {
            [{
                params ["_vehType", "_pos", "_dir", "_loadout", "_respawnTime", "_abandonDistance", "_hasKeys"];

                _nv = createVehicle [_vehType, _pos, [], 0, "CAN_COLLIDE"];
                _nv setDir _dir;

                // handle inventories
                clearWeaponCargoGlobal _nv;
                clearMagazineCargoGlobal _nv;
                clearItemCargoGlobal _nv;
                clearBackpackCargoGlobal _nv;

                for "_l" from 0 to (count _loadout) do {

                    _cargoItems  = (_loadout select _l) select 0;
                    _cargoCounts = (_loadout select _l) select 1;

                    if (_l isEqualTo 0) then {
                        for "_x" from 0 to ((count _cargoItems) - 1) do {
                            _nv addBackpackCargoGlobal [_cargoItems select _x, _cargoCounts select _x];
                        };
                    } else {
                        for "_x" from 0 to ((count _cargoItems) - 1) do {
                            _nv addItemCargoGlobal [_cargoItems select _x, _cargoCounts select _x];
                        };
                    };
                };

                // Re-Init Vehicle
                [_nv, _hasKeys, _respawnTime, _abandonDistance] call FNC(initVehicle);

                true;

            }, [_vehType, _pos, _dir, _loadout, _respawnTime, _abandonDistance, _hasKeys], _respawnTime] call CBA_fnc_waitAndExecute;
        };

    };
}, 10, []] call CBA_fnc_addPerFrameHandler;