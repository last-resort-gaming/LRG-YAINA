/*
	author: Martin
	description: none
	returns: nothing
*/

#include "defines.h";

if(!isServer) exitWith {};

[{
    for "_i" from count(GVAR(respawnList)) to 0 step -1 do {
        (GVAR(respawnList) select _i) params ["_veh", "_vehType", "_pos", "_dir", "_tex", "_coPilotEnabled", "_loadout", "_animationInfo", "_pylonLoadout", "_respawnTime", "_abandonDistance", "_hasKeys", "_persistVars"];

        // If the vehicle is not alive / null then we remove from the respawn
        // list and schedule a delete it in 30 seconds just in case it
        // doesn't get removed when not alive

        _respawn = false;
        if (!alive _veh || isNull _veh) then {

            GVAR(respawnList) deleteAt _i;
            _respawn = true;

        } else {

            // E.g. UAVs don't have a distance.
            if !(_abandonDistance isEqualTo 0) then {

                // If it's less than 5m from start pos, just bail
                if (_veh distance2D _pos < 5) exitWith {};

                // If it's within a BASE area, just bail
                if !(call { {_veh inArea _x} count BASE_PROTECTION_AREAS; } isEqualTo 0) exitWith {};

                // If the vehicle is owned, then the abandonDistance is doubled;
                _owner = _veh getVariable QVAR(owner);
                if(!isNil "_owner") then {
                    _abandonDistance =  _abandonDistance * 2;
                };

                // If players near, we can bail out
                if (call {
                    {
                        if ((_veh distance2D _x) < _abandonDistance) exitWith {true};
                        false;
                    } forEach allPlayers;
                }) exitWith {};

                // Else we are abandoned, delete this and respawn
                GVAR(respawnList) deleteAt _i;
                deleteVehicle _veh;

                _respawn = true;
            };
        };

        // Then we just trigger a respawn in _respawnTime
        if(_respawn) then {
            [{
                params ["_vehType", "_pos", "_dir", "_tex", "_coPilotEnabled", "_loadout", "_animationInfo", "_pylonLoadout", "_respawnTime", "_abandonDistance", "_hasKeys", "_persistVars"];

                _nv = createVehicle [_vehType, [0,0,0], [], 0, "CAN_COLLIDE"];

                // reset textures
                {
                    _nv setObjectTexture [_forEachIndex, _x];
                } forEach _tex;

                // reset animations
                { _nv animate [_x select 0, _x select 1, true]; } forEach _animationInfo;

                // Then move to intended location
                _nv setDir _dir;
                _nv setPosATL _pos;

                // restore copilot action
                _nv enableCopilot _coPilotEnabled;

                if (_nv isKindOf "UAV") then {

                    // Clear spawned loadout
                    { _nv removeWeaponGlobal getText (configFile >> "CfgMagazines" >> _x >> "pylonWeapon"); } forEach getPylonMagazines _nv;

                    // Reload the same pylons as before
                    {
                        _nv setPylonLoadout [_forEachIndex + 1, _x, true, [0]];
                    } forEach _pylonLoadout;

                    // And lastly add the crew
                    createVehicleCrew _nv;
                };

                // restore persistant vars
                { _nv setVariable _x; } forEach _persistVars;

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

            }, [_vehType, _pos, _dir, _tex, _coPilotEnabled, _loadout, _animationInfo, _pylonLoadout, _respawnTime, _abandonDistance, _hasKeys, _persistVars], _respawnTime] call CBA_fnc_waitAndExecute;
        };

    };
}, 10, []] call CBA_fnc_addPerFrameHandler;